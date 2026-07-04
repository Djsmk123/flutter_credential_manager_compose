---
name: publish-release
description: End-to-end release flow for this monorepo (credential_manager_platform_interface, credential_manager_android, credential_manager_ios, credential_manager) - version bump, CHANGELOG, release branch off develop + PR to develop, promote develop to main, then post-merge dry-run and real publish to pub.dev in dependency order. Use when the user asks to "release", "publish a new version", "cut a release", or "bump version" for any of these packages.
---

# Publishing a new version

This repo is a federated plugin monorepo managed with melos (root `pubspec.yaml` +
`melos:` config, native Dart pub workspace) with four interdependent pub.dev packages,
not necessarily in lockstep — only bump what actually changed (see Step 2). Prefer the
root `Makefile` (see the `check-format` skill) for formatting/analyzing/linting over calling
the underlying tools directly — `make check` is the CI-equivalent gate.

```
credential_manager_platform_interface   (no internal deps)
        ^                    ^
credential_manager_android   credential_manager_ios   (each depends on platform_interface)
        ^                            ^
              credential_manager      (depends on platform_interface + android + ios)
```

Package locations: `packages/<name>/pubspec.yaml` + `packages/<name>/CHANGELOG.md`.

## Step 1 — Determine version bump type

Ask the user (or infer from the change) what kind of change this is, per this repo's convention:

- **Bug fix / small change** → bump **minor** version (e.g. 2.0.8 → 2.1.0)
- **Migration or new feature / breaking change** → bump **major** version (e.g. 2.0.8 → 3.0.0)

Note: this is this project's own convention, not standard semver (which would use patch/minor).
Follow it exactly as stated — don't "correct" it to patch bumps.

## Step 2 — Figure out which packages need a bump

Find which package(s) contain the actual code change (git diff / changed files). Then propagate
upward through the dependency graph above — any package that depends on a bumped package must
also get a version bump (at minimum a matching bump, since its pubspec pins the dependency with
a `^` constraint that needs updating to the new version):

- Change in `credential_manager_platform_interface` → also bump android, ios, and credential_manager.
- Change in `credential_manager_android` only → also bump credential_manager (it depends on android).
- Change in `credential_manager_ios` only → also bump credential_manager (it depends on ios).
- Change in `credential_manager` only (example/docs/app-level) → bump only credential_manager.

When in doubt, ask the user which packages are in scope rather than guessing.

## Step 3 — Create a release branch

This repo uses `main → develop → feature branches`: feature/release branches are cut from
`develop`, PR'd back into `develop`, and `develop` is later promoted to `main` via its own PR
(see Step 6). Branch off `develop`, following this repo's naming convention
`<issue-number>-kebab-slug` (see `git branch -a` for examples), or a plain kebab-slug.

```
git checkout develop && git pull origin develop
git checkout -b <slug>
```

Note: this repo has "automatically delete head branches" enabled on GitHub, so `develop` gets
deleted every time it's the head of a merged PR (e.g. after a `develop → main` promotion). If
`git checkout develop && git pull` fails because the branch is gone, recreate it from `main`:
`git push origin main:develop`.

## Step 4 — Bump versions + CHANGELOGs

For every package identified in Step 2:

1. Update `version:` in `packages/<name>/pubspec.yaml`.
2. For packages that depend on another bumped package, update that dependency's `^` constraint
   in the `dependencies:` section to the new version too.
3. Add a new top entry to `packages/<name>/CHANGELOG.md`. Match the existing format exactly:
   the newest entry uses `# X.Y.Z` (single `#`), all older entries use `## X.Y.Z`. When adding a
   new top entry, demote the previous newest entry from `# ` to `## `. Write real bullet points
   describing the change — don't leave placeholders.
4. If `credential_manager` (the umbrella package) itself isn't code-changed but its pinned
   dependencies were bumped, still add a CHANGELOG entry there noting the dependency bump.

Then regenerate lockfiles and verify:

```
make bootstrap
make check
```

Fix anything `make check` flags (formatting, analyzer, SwiftLint, Detekt) before proceeding.

## Step 5 — Commit, push, open PR to develop

Commit with a `chore: release vX.Y.Z for <packages>` style message (see `git log` for tone),
push the branch, and open a PR targeting `develop` with `gh pr create`:

```
gh pr create --base develop --title "chore: release vX.Y.Z" --body "..."
```

Do **not** merge the PR yourself — merging is a shared, hard-to-reverse action. Tell the user
the PR is ready and wait for them to merge it (or explicitly ask you to merge).

## Step 6 — Promote develop to main, then publish

Once the release PR (and anything else queued) is merged into `develop`, `develop` needs to
reach `main` before publishing — pub.dev releases are cut from `main`. Open a second PR:

```
git checkout develop && git pull origin develop
gh pr create --base main --head develop --title "chore: release vX.Y.Z" --body "..."
```

Again, wait for explicit confirmation before merging this one too. After it's merged:

```
git checkout main && git pull origin main
```

## Step 7 — Dry run, in dependency order

Publish (dry run first) in this fixed order so dependents can resolve the just-bumped versions
of packages earlier in the graph:

1. `credential_manager_platform_interface`
2. `credential_manager_android`
3. `credential_manager_ios`
4. `credential_manager` (last — depends on all three)

`packages/scripts/publish-script.sh --dry-run` is an interactive menu and does **not** handle
piped/non-TTY stdin reliably (it can hang or spin on invalid input when driven non-interactively
in a Bash tool call). Prefer running the underlying command directly per package instead:

```
(cd packages/<name> && flutter pub get && flutter pub publish --dry-run)
```

Only include packages identified in Step 2 — don't publish unchanged packages. A dry run should
report 0 warnings; investigate anything else before proceeding.

## Step 8 — Real publish (requires explicit user confirmation)

`flutter pub publish` is irreversible and public — a package version can never be replaced or
deleted from pub.dev once published. Before running the non-dry-run publish for **any** package:

- Confirm all dry runs in Step 7 passed cleanly.
- Explicitly ask the user, per package, whether to publish now — don't infer consent from an
  earlier general "yes" about the release as a whole.

Publish strictly in the same dependency order as Step 7, one package at a time, waiting for
each to actually appear on pub.dev before publishing the next dependent (a dependent's
`^x.y.z` constraint won't resolve against a version that only exists in git, it must be live
on pub.dev first — check `https://pub.dev/api/packages/<name>` for the new version before
moving on, it can take a few minutes to propagate):

```
(cd packages/<name> && flutter pub publish --force)
```

`--force` here skips `flutter pub publish`'s own y/N prompt — that's fine since you've already
gotten the user's explicit go-ahead for this exact package in this exact step; it does not mean
skipping the confirmation itself.

## Notes

- If a package's change doesn't warrant a version bump (e.g. pure CI/doc change with no
  pub.dev-relevant code), skip it — don't force lockstep versioning across all four packages
  unless the change actually touches them.
- If publishing fails partway through the ordered sequence, stop and report which packages are
  live vs. still pending rather than continuing past a failure.
