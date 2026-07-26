#!/bin/bash
# Automates the mechanical parts of a release: detects which packages have real
# (non-doc) code changes since the last release, asks Claude Code in headless
# mode ONLY to classify each change as "minor" or "major" per this repo's
# version-bump convention (bug fix/small change -> minor; migration/new
# feature/breaking change -> major — see CLAUDE.md), then bumps
# pubspec.yaml/CHANGELOG.md, propagates the bump to dependents, runs the
# make check gate, and opens a PR to develop.
#
# This intentionally stops at "PR opened against develop". It never merges a
# PR, never promotes develop -> main, and never runs `flutter pub publish`
# (dry-run or real) — those stay manual/interactive steps per this repo's
# safety policy (CLAUDE.md: main requires human review; a real publish is
# irreversible and needs explicit per-package confirmation). See the
# `publish-release` skill for those remaining steps.
#
# Usage:
#   packages/scripts/auto-release.sh [--dry-run] [--base <ref>] [--yes] [--model <model>]
#
#   --dry-run       Show the classification + version-bump plan, change nothing.
#   --base <ref>    Ref to diff against to find changes (default: origin/main).
#   --yes           Skip the confirmation prompt before branching/committing/pushing.
#   --model <model> Model passed to `claude --model` for classification (default: haiku).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

DRY_RUN=false
BASE_REF="origin/main"
ASSUME_YES=false
CLASSIFY_MODEL="haiku"

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run) DRY_RUN=true; shift ;;
    --base) BASE_REF="$2"; shift 2 ;;
    --yes) ASSUME_YES=true; shift ;;
    --model) CLASSIFY_MODEL="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,25p' "${BASH_SOURCE[0]}"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { echo -e "${BLUE}ℹ${NC} $1"; }
ok()      { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
fail()    { echo -e "${RED}✗${NC} $1" >&2; exit 1; }

command -v claude >/dev/null 2>&1 || fail "claude CLI not found on PATH"
command -v gh >/dev/null 2>&1 || fail "gh CLI not found on PATH"

# Ordered so that a package always appears after everything it depends on.
PACKAGE_ORDER=(credential_manager_platform_interface credential_manager_android credential_manager_ios credential_manager_web credential_manager)

# Source paths (relative to packages/<name>/) whose changes count as "real"
# code changes for a package, as opposed to docs/example/CI churn.
code_paths_for() {
  case "$1" in
    credential_manager_platform_interface) echo "lib" ;;
    credential_manager_android) echo "lib android/src" ;;
    credential_manager_ios) echo "lib ios/credential_manager_ios/Sources" ;;
    credential_manager_web) echo "lib web/passkey_authenticator.js" ;;
    credential_manager) echo "lib" ;; # example/ deliberately excluded: not published
  esac
}

# Packages that depend on a given package (direct edges of the fixed graph).
dependents_of() {
  case "$1" in
    credential_manager_platform_interface) echo "credential_manager_android credential_manager_ios credential_manager_web credential_manager" ;;
    credential_manager_android) echo "credential_manager" ;;
    credential_manager_ios) echo "credential_manager" ;;
    credential_manager_web) echo "credential_manager" ;;
    credential_manager) echo "" ;;
  esac
}

get_version() { grep "^version:" "packages/$1/pubspec.yaml" | sed 's/version: *//' | tr -d ' \r'; }

bump_version() {
  local version=$1 kind=$2
  IFS='.' read -r major minor patch <<< "$version"
  if [ "$kind" = "major" ]; then
    echo "$((major + 1)).0.0"
  else
    echo "${major}.$((minor + 1)).0"
  fi
}

info "Fetching $BASE_REF..."
git fetch origin "${BASE_REF#origin/}" --quiet 2>/dev/null || true

# bash 3.2 (macOS default) has no associative arrays, so per-package decision/
# version state lives in a scratch dir instead of `declare -A`.
STATE_DIR=$(mktemp -d)
trap 'rm -rf "$STATE_DIR"' EXIT

decision_of() { cat "$STATE_DIR/$1.decision" 2>/dev/null || true; }
set_decision() { printf '%s' "$2" > "$STATE_DIR/$1.decision"; }
version_of() { cat "$STATE_DIR/$1.version" 2>/dev/null || true; }
set_version() { printf '%s' "$2" > "$STATE_DIR/$1.version"; }

classify_package() {
  local pkg=$1
  local paths
  paths=$(code_paths_for "$pkg")
  local diff
  diff=$(cd "packages/$pkg" && git diff "$BASE_REF"...HEAD -- $paths 2>/dev/null || true)

  if [ -z "$diff" ]; then
    return
  fi

  info "Classifying $pkg (real code changes detected)..."
  # Built via a temp file (not an interpolated heredoc) so diff content
  # containing backticks/$()/etc. can't be misparsed by the shell.
  local prompt_file
  prompt_file=$(mktemp)
  {
    printf 'Classify this code change per the flutter_credential_manager_compose repo'\''s own\n'
    printf 'version-bump convention (not standard semver):\n'
    printf -- '- Bug fix / small change -> minor\n'
    printf -- '- Migration / new feature / breaking change -> major\n\n'
    printf 'Package: %s\n\n' "$pkg"
    printf 'Diff:\n'
    printf '%s\n' "$diff"
    printf '\nRespond with exactly one word, lowercase, no punctuation: major or minor.\n'
  } > "$prompt_file"

  local result
  result=$(claude -p --model "$CLASSIFY_MODEL" --output-format text < "$prompt_file" 2>/dev/null \
    | tr '[:upper:]' '[:lower:]' | grep -oE 'major|minor' | head -1)
  rm -f "$prompt_file"

  if [ "$result" != "major" ] && [ "$result" != "minor" ]; then
    warn "Could not get a clean classification for $pkg (got: '$result') — defaulting to minor"
    result="minor"
  fi
  set_decision "$pkg" "$result"
  ok "$pkg -> $result bump"
}

for pkg in "${PACKAGE_ORDER[@]}"; do
  classify_package "$pkg"
done

# Propagate: any package whose dependency got bumped needs at least a minor
# bump too, even with no code changes of its own, so its constraint can be
# updated. A package's own classification (if it has real changes) wins if
# it's already "major".
for pkg in "${PACKAGE_ORDER[@]}"; do
  for dep in "${PACKAGE_ORDER[@]}"; do
    if [[ " $(dependents_of "$dep") " == *" $pkg "* ]] && [ -n "$(decision_of "$dep")" ] && [ -z "$(decision_of "$pkg")" ]; then
      set_decision "$pkg" "minor"
    fi
  done
done

any_change=false
for pkg in "${PACKAGE_ORDER[@]}"; do
  if [ -n "$(decision_of "$pkg")" ]; then
    any_change=true
    old_version=$(get_version "$pkg")
    printf '%s' "$old_version" > "$STATE_DIR/$pkg.oldversion"
    set_version "$pkg" "$(bump_version "$old_version" "$(decision_of "$pkg")")"
  fi
done
old_version_of() { cat "$STATE_DIR/$1.oldversion" 2>/dev/null || true; }

if [ "$any_change" = false ]; then
  ok "No packages have code changes since $BASE_REF. Nothing to release."
  exit 0
fi

echo ""
info "Release plan:"
for pkg in "${PACKAGE_ORDER[@]}"; do
  if [ -n "$(decision_of "$pkg")" ]; then
    printf "  %-40s %s -> %s (%s)\n" "$pkg" "$(old_version_of "$pkg")" "$(version_of "$pkg")" "$(decision_of "$pkg")"
  fi
done
echo ""

if [ "$DRY_RUN" = true ]; then
  ok "Dry run only — no files changed."
  exit 0
fi

if [ "$ASSUME_YES" != true ]; then
  read -p "Apply this plan and open a PR against develop? (y/N): " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || { info "Aborted."; exit 0; }
fi

git checkout develop
git pull origin develop --quiet
slug="auto-release-$(date +%Y%m%d-%H%M%S)"
git checkout -b "$slug"

for pkg in "${PACKAGE_ORDER[@]}"; do
  [ -z "$(decision_of "$pkg")" ] && continue
  new_version=$(version_of "$pkg")
  pubspec="packages/$pkg/pubspec.yaml"
  sed -i.bak "s/^version: .*/version: $new_version/" "$pubspec" && rm "$pubspec.bak"

  # Update this package's constraint in every dependent's pubspec.yaml.
  for dependent in $(dependents_of "$pkg"); do
    [ -z "$(decision_of "$dependent")" ] && continue
    dep_pubspec="packages/$dependent/pubspec.yaml"
    sed -i.bak "s/^\(  $pkg: \)\^.*/\1^$new_version/" "$dep_pubspec" && rm "$dep_pubspec.bak"
  done

  changelog="packages/$pkg/CHANGELOG.md"
  commits=$(cd "packages/$pkg" && git log "$BASE_REF"...HEAD --format="- %s" -- $(code_paths_for "$pkg") 2>/dev/null || true)
  [ -z "$commits" ] && commits="- (add release notes here)"
  entry="# $new_version
$commits

"
  # Demote the previous newest ("# x.y.z") entry to "## x.y.z" and prepend the new one.
  if head -1 "$changelog" | grep -qE '^# '; then
    sed -i.bak '1s/^# /## /' "$changelog" && rm "$changelog.bak"
  fi
  tmp=$(mktemp)
  printf '%s' "$entry" > "$tmp"
  cat "$changelog" >> "$tmp"
  mv "$tmp" "$changelog"

  ok "Bumped $pkg to $new_version"
done

info "Running make bootstrap && make check..."
make bootstrap
make check

git add -A
commit_msg="chore: auto-release $(for pkg in "${PACKAGE_ORDER[@]}"; do [ -n "$(decision_of "$pkg")" ] && echo -n "$pkg@$(version_of "$pkg") "; done)"
git commit -m "$commit_msg"
git push -u origin "$slug"

pr_body="Auto-generated release plan (classified by \`claude --model $CLASSIFY_MODEL\`, review before merging):

$(for pkg in "${PACKAGE_ORDER[@]}"; do [ -n "$(decision_of "$pkg")" ] && echo "- \`$pkg\`: $(old_version_of "$pkg") -> $(version_of "$pkg") ($(decision_of "$pkg"))"; done)

CHANGELOG entries were drafted from commit subjects touching each package's source paths since \`$BASE_REF\` — edit them before merging if they need more context.

This PR does not merge itself, promote to main, or publish — do those manually per the \`publish-release\` skill once this looks right."

gh pr create --base develop --title "$commit_msg" --body "$pr_body"

ok "Done. Review the CHANGELOG entries in the PR before merging."
