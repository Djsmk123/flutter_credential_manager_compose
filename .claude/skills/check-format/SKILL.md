---
name: check-format
description: Format and check this monorepo (Dart format at 120 cols, flutter analyze, SwiftLint, Detekt) via the root Makefile. Use before committing, opening a PR, or whenever the user asks to "format", "check", "lint", or "run checks" on this repo.
---

# Check & format this repo

This repo has a root `Makefile` wrapping melos + the native linters. Prefer these targets
over calling `dart format` / `flutter analyze` / `swiftlint` / `detekt` directly, so behavior
stays consistent with CI (`.github/workflows/ci.yml` runs the equivalent checks).

```
make bootstrap      # dart pub global activate melos && melos bootstrap
make format         # dart format --set-exit-if-changed . across every package (fixes in place)
make format-check   # same, but fails instead of writing (what CI runs)
make analyze        # flutter analyze across every package via melos
make lint-ios       # swiftlint lint --strict for credential_manager_ios (needs: brew install swiftlint)
make lint-android    # ./gradlew detekt for credential_manager_android
make lint           # lint-ios + lint-android
make check          # format-check + analyze + lint -- the full CI-equivalent gate
```

## When to use which

- Before committing or opening a PR: run `make check`. If `format-check` fails, run
  `make format` to fix it in place, then re-run `make check`.
- After editing Dart code: `make format && make analyze` is enough (skip native lint if
  neither `ios/` nor `android/` native sources changed).
- After editing Swift sources in `packages/credential_manager_ios`: `make lint-ios`.
- After editing Kotlin sources in `packages/credential_manager_android`: `make lint-android`.
- First time in a fresh checkout, or after adding/bumping a dependency: `make bootstrap` first.

## Notes

- `format`/`format-check`/`analyze` require `melos` (installed automatically by `make bootstrap`
  or `make format`/`make analyze` themselves via `dart pub global activate melos`).
- `lint-ios` requires SwiftLint (`brew install swiftlint` if missing) and only runs on macOS.
- `lint-android` requires a JDK and the Android SDK to be resolvable (already true in this repo's
  CI and in a normal Flutter dev setup); it uses the plugin module's own Gradle wrapper.
- If `make check` reports violations that look pre-existing/out of scope (rather than caused by
  the current change), don't silently rewrite unrelated code — see the `detekt.yml` and
  `.swiftlint.yml` configs for rules that were deliberately relaxed with a documented reason.
