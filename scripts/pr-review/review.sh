#!/usr/bin/env bash
# Local PR reviewer.
#
# Fans out specialist Claude Code review passes over a GitHub PR's diff (security,
# test-coverage, and whichever of android/ios/dart apply to the changed files), synthesizes
# the results with a primary reviewer pass, and posts the surviving findings as inline PR
# review comments. Modeled on the "LLM as one bounded, structured-output stage in a normal
# pipeline" pattern from https://www.huuhka.net/building-your-own-pr-reviewer-with-coding-agents/,
# right-sized to a single local script instead of a hosted event-driven service.
#
# Usage:
#   scripts/pr-review/review.sh <pr-number> [--dry-run]
#
# Requires: gh (authenticated), jq, claude (Claude Code CLI, logged in).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"

usage() {
  echo "Usage: $0 <pr-number> [--dry-run]" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage
PR="$1"
DRY_RUN=false
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=true

for bin in gh jq claude; do
  command -v "$bin" >/dev/null 2>&1 || { echo "error: '$bin' is required on PATH" >&2; exit 1; }
done

REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
echo "==> Reviewing $REPO#$PR"

PR_JSON="$(gh pr view "$PR" --json headRefOid,files)"
HEAD_SHA="$(jq -r '.headRefOid' <<<"$PR_JSON")"
FILES="$(jq -r '.files[].path' <<<"$PR_JSON")"

echo "==> Files changed:"
sed 's/^/    /' <<<"$FILES"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

# --- pick specialists based on touched paths ---
SPECIALISTS=(security tests hygiene)
NEEDS_DOCS=false
grep -q '^packages/credential_manager_android/' <<<"$FILES" && { SPECIALISTS+=(android); NEEDS_DOCS=true; }
grep -q '^packages/credential_manager_ios/' <<<"$FILES" && { SPECIALISTS+=(ios); NEEDS_DOCS=true; }
grep -q '^packages/credential_manager_web/' <<<"$FILES" && { SPECIALISTS+=(web); NEEDS_DOCS=true; }
grep -qE '\.dart$' <<<"$FILES" && { SPECIALISTS+=(dart); NEEDS_DOCS=true; }
# pubspec.yaml changes alone (e.g. a version bump with no code) don't need the API/setup-docs
# reviewer — NEEDS_DOCS is only set by an actual source-surface change above.
$NEEDS_DOCS && SPECIALISTS+=(docs)

echo "==> Specialists: ${SPECIALISTS[*]}"

# Read-only tool set: specialists inspect the diff/repo but never edit anything.
CLAUDE_FLAGS=(
  --permission-mode bypassPermissions
  --allowedTools "Read Grep Glob Bash(gh pr diff*) Bash(gh pr view*) Bash(git log*) Bash(git show*)"
  --output-format json
  -p
)

render_prompt() {
  local file="$1"
  local text
  text="$(cat "$PROMPTS_DIR/_schema.md" "$file")"
  text="${text//\{\{PR_NUMBER\}\}/$PR}"
  printf '%s' "$text"
}

run_specialist() {
  local name="$1"
  local out_file="$WORKDIR/${name}.json"
  echo "    -> running $name reviewer..."
  local prompt
  prompt="$(render_prompt "$PROMPTS_DIR/${name}.md")"
  if ! claude "${CLAUDE_FLAGS[@]}" "$prompt" | jq -r '.result' >"$out_file" 2>"$WORKDIR/${name}.log"; then
    echo "    !! $name reviewer failed, treating as no findings (see $WORKDIR/${name}.log)" >&2
    echo "[]" >"$out_file"
  fi
  jq -e . "$out_file" >/dev/null 2>&1 || echo "[]" >"$out_file"
}

pids=()
for s in "${SPECIALISTS[@]}"; do
  run_specialist "$s" &
  pids+=($!)
done
for pid in "${pids[@]}"; do
  wait "$pid"
done

echo "==> Specialist findings:"
for s in "${SPECIALISTS[@]}"; do
  n="$(jq 'length' "$WORKDIR/${s}.json")"
  echo "    $s: $n"
done

RAW_FINDINGS="$(jq -s 'add' "$WORKDIR"/*.json)"

if [[ "$(jq 'length' <<<"$RAW_FINDINGS")" -eq 0 ]]; then
  echo "==> No specialist findings. Nothing to synthesize or post."
  exit 0
fi

# --- synthesize ---
echo "==> Synthesizing findings with primary reviewer..."
SYNTH_PROMPT="$(render_prompt "$PROMPTS_DIR/primary.md")"
SYNTH_PROMPT="${SYNTH_PROMPT//\{\{FINDINGS_JSON\}\}/$RAW_FINDINGS}"

FINAL_JSON="$(claude "${CLAUDE_FLAGS[@]}" "$SYNTH_PROMPT" | jq -r '.result')"
jq -e . <<<"$FINAL_JSON" >/dev/null 2>&1 || FINAL_JSON="[]"
echo "$FINAL_JSON" >"$WORKDIR/final.json"

COUNT="$(jq 'length' <<<"$FINAL_JSON")"
echo "==> $COUNT finding(s) after synthesis"
[[ "$COUNT" -eq 0 ]] && { echo "Nothing to post."; exit 0; }

# --- post inline review comments ---
jq -c 'map(. as $f | . + {_rank: (["critical","high","medium","low"] | index($f.severity))})
       | sort_by(._rank) | .[] | del(._rank)' <<<"$FINAL_JSON" |
while IFS= read -r finding; do
  title="$(jq -r '.title' <<<"$finding")"
  severity="$(jq -r '.severity' <<<"$finding")"
  category="$(jq -r '.category // "general"' <<<"$finding")"
  file="$(jq -r '.file' <<<"$finding")"
  line="$(jq -r '.line' <<<"$finding")"
  desc="$(jq -r '.description' <<<"$finding")"

  echo "----"
  echo "[$severity] $file:$line — $title"

  $DRY_RUN && continue

  body="**[$severity] $title** _(${category})_

${desc}"

  if ! gh api "repos/$REPO/pulls/$PR/comments" \
    -f commit_id="$HEAD_SHA" \
    -f path="$file" \
    -F line="$line" \
    -f side="RIGHT" \
    -f body="$body" >/dev/null; then
    echo "    (failed to post inline comment — line may be outside the diff hunk; falling back to a general PR comment)"
    gh pr comment "$PR" --body "**[$severity] ${file}:${line} — ${title}** _(${category})_

${desc}" >/dev/null
  fi
done

echo "==> Done."
