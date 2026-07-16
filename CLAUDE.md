# CLAUDE.md

Guidance for Claude Code when working in this repo.

## What this is

`flutter_credential_manager_compose` — a federated Flutter plugin exposing Android's Jetpack
Credential Manager (one-tap sign-in, passkeys) and iOS Keychain/Autofill behind one Dart API.

Packages (`packages/<name>`, melos-managed native Dart pub workspace, root `pubspec.yaml`):

```
credential_manager_platform_interface   (no internal deps)          v2.0.8
        ^                    ^
credential_manager_android   credential_manager_ios                 v3.0.1
        ^                            ^
              credential_manager (umbrella, + /example app)         v3.0.1
```

- `credential_manager_ios` ships **both** CocoaPods (`ios/credential_manager_ios.podspec`) and
  Swift Package Manager (`ios/credential_manager_ios/Package.swift`) — same `Sources/` directory,
  single source of truth. SPM is Flutter's default from 3.24+; CocoaPods stays supported.
- Docs site lives in `docSite/` (Vite/React), deployed to
  https://djsmk123.github.io/flutter_credential_manager_compose/ — includes an
  iOS Configuration page section on enabling/migrating to SPM.

## Repo tooling

- **Melos** (`^8.1.0`) — config lives in root `pubspec.yaml`'s `melos:` key (melos 8 dropped
  standalone `melos.yaml`); package list comes from the native `workspace:` field. Each member
  package has `resolution: workspace` and `sdk: '>=3.5.0 <4.0.0'`.
- **Makefile** (root) wraps melos + native linters so local dev, pre-commit, and CI run the
  exact same commands:
  - `make bootstrap` — activate melos + `melos bootstrap`
  - `make format` / `make format-check` — `dart format --line-length 120 --page-width 120`
    (fix vs. `--set-exit-if-changed`)
  - `make analyze` — `flutter analyze` across every package
  - `make lint-ios` — SwiftLint (`--strict`) on `credential_manager_ios`
  - `make lint-android` — Detekt on `credential_manager_android`
  - `make lint` — both native linters
  - `make check` — `format-check` + `analyze` + `lint`, the full CI-equivalent gate
- **Pre-commit** (`.pre-commit-config.yaml`) runs `make format` and `make analyze` on Dart files
  (excludes `docSite/`).
- **Line length is 120 columns everywhere** (Dart `formatter: page_width: 120` in each package's
  `analysis_options.yaml`, SwiftLint `line_length`, Detekt `formatter.MaximumLineLength`) — not
  Dart's 80-column default. Note: `dart format` only produces the "tall style" (matching this
  codebase) once the package's language version resolves via `pub get`/`melos bootstrap` —
  running it on an unbootstrapped checkout silently falls back to old short-style output
  regardless of width flags. Always bootstrap first.
- **Lint configs** (`packages/credential_manager_ios/.swiftlint.yml`,
  `packages/credential_manager_android/android/detekt.yml`) are held at zero violations.
  A few rules are deliberately relaxed with a documented reason inline (legacy package naming
  with an underscore; generic exception catching at the Flutter method-channel boundary) —
  don't "fix" those without cause, and don't add new suppressions without the same kind of
  documented justification.

## CI (`.github/workflows/ci.yml`)

Runs on PRs into `main` or `develop`: `format` / `analyze` / `android-build` / `android-lint` /
`ios-build` / `ios-lint`, all gated by a `dorny/paths-filter@v3` `changes` job so each job only
runs when a PR actually touches its relevant paths — `format`/`analyze` need `dart` (any `.dart`
file, package `pubspec.yaml`/`analysis_options.yaml`, root `pubspec.yaml`, or the workflow file
itself); `android-build`/`android-lint` need `android`; `ios-build`/`ios-lint` need `ios`
(`packages/credential_manager_android/**` + shared deps for android; analogous for ios). A
docs-only PR (`docSite/**`) now skips every Dart/native job.

## Branching & releases

- Flow is `main → develop → feature branches`. Feature/release branches cut from `develop`,
  PR'd back to `develop`; `develop` is later promoted to `main` via its own PR. Publishing to
  pub.dev happens from `main`.
- GitHub has "automatically delete head branches" enabled, so `develop` gets deleted every time
  it's a merged PR's head (e.g. after a `develop → main` promotion). Recreate with
  `git push origin main:develop`.
- `main` has branch protection requiring 1 approving review — the agent cannot merge PRs into
  it itself; a human must merge (or explicitly request `--admin`, which should not be assumed).
- Version bump convention is **this repo's own, not standard semver**: bug fix/small change →
  minor bump; migration/new feature/breaking change → major bump. Follow it as-is.

## Skills

- **`check-format`** — wraps the Makefile; use before committing/opening a PR, or whenever
  asked to format/check/lint. Prefer `make check`/`make format` over calling
  `dart format`/`flutter analyze`/`swiftlint`/`detekt` directly.
- **`publish-release`** — full release flow: version bump + CHANGELOG propagation across the
  dependency graph, release branch off `develop`, PR to `develop`, promote `develop` to `main`,
  then dry-run and real `flutter pub publish` in dependency order
  (`platform_interface` → `android` → `ios` → `credential_manager`), with explicit per-package
  confirmation before any real (non-dry-run) publish. Never merges PRs or publishes without
  the user's explicit go-ahead at each step — these are irreversible/shared actions.
- **`credential-manager-expert`** — domain-expert reference on the plugin's actual API surface
  (Dart method signatures, model field nesting, `CredentialException` codes) and native setup
  (Android Digital Asset Links/proguard/Google OAuth, iOS Associated Domains/AASA/SPM). Built
  from source, not general WebAuthn knowledge, because the docs site has shipped incorrect
  method names and field nesting before. Use when writing/reviewing code against this plugin's
  API or debugging passkey/autofill/Google Sign-In setup.

Skill files live at `.claude/skills/<name>/SKILL.md` (plus `references/` for the expert skill) —
read them for full step-by-step detail rather than re-deriving the flow from scratch.

## Working conventions in this repo

- CHANGELOG format: newest entry uses `# X.Y.Z` (single `#`), older entries use `## X.Y.Z` —
  demote the previous top entry when adding a new one.
- Don't duplicate Swift/Kotlin sources between CocoaPods and SPM, or between lint config and
  code — one source of truth per concern.
- Direct pushes to `main` bypassing the PR flow are exceptional and require the user's explicit,
  specific authorization each time — not implied by earlier approvals.
