MELOS := PATH="$$PATH:$$HOME/.pub-cache/bin" melos

.PHONY: bootstrap format format-check analyze lint-ios lint-android lint check pr-review pigeon

## Install melos (if needed) and bootstrap the workspace
bootstrap:
	dart pub global activate melos
	$(MELOS) bootstrap

## Format all Dart sources in place (explicit 120-column width)
format:
	$(MELOS) run format:fix

## Check Dart formatting without modifying files (explicit 120-column width; fails if anything is unformatted)
format-check:
	$(MELOS) run format

## Run flutter analyze across every package
analyze:
	$(MELOS) run analyze

## Run SwiftLint on credential_manager_ios (must be installed: brew install swiftlint)
lint-ios:
	cd packages/credential_manager_ios && swiftlint lint --strict

## Run Detekt on credential_manager_android
lint-android:
	cd packages/credential_manager_android/android && ./gradlew detekt --no-daemon

## Run all native linters (SwiftLint + Detekt)
lint: lint-ios lint-android

## Run everything CI checks: format, analyze, and native lint
check: format-check analyze lint

## Regenerate the Pigeon-generated host APIs from each package's pigeons/messages.dart
## (Android: Kotlin + Dart, iOS: Swift + Dart). Re-run after editing a schema; the generated
## files are committed, not gitignored.
pigeon:
	cd packages/credential_manager_android && dart run pigeon --input pigeons/messages.dart
	cd packages/credential_manager_ios && dart run pigeon --input pigeons/messages.dart

## Run the local AI PR reviewer against a PR number (requires gh, jq, claude). Usage: make pr-review PR=123 [DRY_RUN=1]
pr-review:
	@if [ -z "$(PR)" ]; then echo "usage: make pr-review PR=<number> [DRY_RUN=1]" >&2; exit 1; fi
	scripts/pr-review/review.sh $(PR) $(if $(DRY_RUN),--dry-run,)
