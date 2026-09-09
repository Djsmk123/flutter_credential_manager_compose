## Output contract

You are reviewing PR #{{PR_NUMBER}} in this repository. Get the diff yourself first, e.g.:

```
gh pr diff {{PR_NUMBER}}
gh pr view {{PR_NUMBER}} --json files -q '.files[].path'
```

Only comment on lines that actually change in this diff (added/modified lines — the "RIGHT"
side of the hunk). Read surrounding files/context as needed to judge correctness, but do not
raise findings about pre-existing code the PR doesn't touch.

Respond with **only** a raw JSON array (no markdown fences, no prose before or after). Each
element:

```json
{
  "severity": "critical|high|medium|low",
  "category": "correctness|security|test-coverage|simplification|efficiency|reuse|release-hygiene|other",
  "title": "short label, <=60 chars",
  "file": "repo-relative path exactly as it appears in the diff",
  "line": 123,
  "description": "one to three sentences: the concrete defect and, where relevant, the failure scenario (bad input/state -> wrong output/crash)"
}
```

`line` must be a line number that exists in the new version of the file on the diff's RIGHT
side. If you have no findings, respond with exactly `[]`. Do not invent findings to have
something to report.
