# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Flutter federated plugin providing unified credential management across Android and iOS:
- **Android**: Uses Jetpack Credential Manager API for username/password, passkeys, and Google Sign-in
- **iOS**: Uses Keychain and Autofill for credential storage

Documentation: https://djsmk123.github.io/flutter_credential_manager_compose/

## Monorepo Structure

This is a federated plugin with multiple interdependent packages:

```
packages/
├── credential_manager/              # Main Flutter-facing API
│   ├── lib/
│   │   ├── credential_manager.dart  # Public API entry point
│   │   └── src/
│   │       ├── credential_manager_core.dart
│   │       └── utils/encryption.dart
│   └── example/                     # Example app demonstrating plugin usage
├── credential_manager_platform_interface/  # Shared models, exceptions, utilities
│   └── lib/src/
│       ├── credential_manager_platform_interface.dart  # Platform interface definition
│       ├── models/                  # Shared models (Credentials, PasswordCredential, etc.)
│       ├── exceptions/              # Exception classes
│       └── utils/                   # Type definitions and parsers
├── credential_manager_android/      # Android platform implementation
│   ├── lib/                         # Dart method channel binding
│   └── android/src/main/kotlin/     # Kotlin implementation using Jetpack Credential Manager
└── credential_manager_ios/          # iOS platform implementation
    ├── lib/                         # Dart method channel binding
    └── ios/Classes/                 # Swift implementation using Keychain/AuthenticationServices
```

**Architecture Pattern**: The plugin uses Flutter's federated plugin architecture. The platform interface defines contracts, and platform-specific packages implement them using method channels.

## Development Commands

### Flutter/Dart

```bash
# Run analysis on all packages (pre-commit enforces this)
./scripts/run_flutter_analyze.sh

# Format Dart code
dart format .

# Run example app (from packages/credential_manager/example/)
cd packages/credential_manager/example
flutter run

# Run tests in a specific package
cd packages/credential_manager_platform_interface
flutter test
```

### Pre-commit Hooks

The project uses pre-commit hooks that automatically:
1. Format all Dart files with `dart format`
2. Run `flutter analyze` across all packages (commits blocked on analyzer errors)

Setup once:
```bash
pip3 install --user pre-commit
python3 -m pre_commit install
# Optional: run on entire repo
python3 -m pre_commit run --all-files
```

### Documentation Site

The `docSite/` directory contains a Vite + React + TypeScript static site:

```bash
cd docSite
npm install
npm run dev          # Development server
npm run build        # Production build
npm run lint         # ESLint
npm run preview      # Preview production build
```

Deployment is automated via `.github/workflows/docs-deploy.yml` (GitHub Pages).

## Key Architectural Concepts

### Platform Channel Communication

- Platform-specific packages (Android/iOS) register themselves with the platform interface via `CredentialManagerPlatform.instance`
- Main package calls methods on the platform interface, which delegates to the registered platform implementation
- Native code communicates back via method channel results or error callbacks

### Dependency Chain

For local development, packages use path dependencies. The dependency order is:
1. `credential_manager_platform_interface` (defines interface)
2. `credential_manager_android` / `credential_manager_ios` (implement interface)
3. `credential_manager` (uses implementations)

See `PUBLISHING.md` for the publishing workflow and circular dependency considerations.

### Android Implementation Details

- **Gradle**: Plugin uses AGP 8.11.1 / Kotlin 1.9.22 (`packages/credential_manager_android/android/build.gradle`)
- **Example app**: Uses AGP 8.4.2 / Kotlin 2.0.20
- **Min SDK**: 21 (Android 5.0)
- **Compile SDK**: 36
- **Key dependencies**: androidx.credentials:1.5.0, Google Sign-in, Play Services

### iOS Implementation Details

- **Swift**: AuthenticationServices framework for passkeys
- **Keychain**: Secure credential storage
- **CBOR**: Used for passkey credential encoding/decoding (`cbor: ^6.3.5`)

### Exception Handling

All credential errors are defined in `packages/credential_manager_platform_interface/lib/src/exceptions/exceptions.dart`. The platform interface provides `PlatformExceptionHandler` for standardized error handling across platforms.

## Common Development Patterns

### Adding a New Credential Type

1. Define model in `credential_manager_platform_interface/lib/src/models/`
2. Add method to `CredentialManagerPlatform` interface
3. Implement in Android (`credential_manager_android/.../CredentialManager.kt`)
4. Implement in iOS (`credential_manager_ios/.../CredentialManagerPlugin.swift`)
5. Expose in main package (`credential_manager/lib/credential_manager.dart`)
6. Update documentation site

### Testing Platform-Specific Code

- **Android**: Kotlin tests in `packages/credential_manager_android/android/src/test/kotlin/`
- **iOS**: Swift tests via Xcode project
- **Dart**: Widget/unit tests in respective `test/` directories

### Version Management

All packages should maintain version parity (currently 2.0.8). Update all four packages simultaneously when releasing.

## Quick Reference

- **Primary docs**: https://djsmk123.github.io/flutter_credential_manager_compose/
- **Platform interface**: `packages/credential_manager_platform_interface/lib/src/credential_manager_platform_interface.dart`
- **Android impl**: `packages/credential_manager_android/android/src/main/kotlin/.../CredentialManager.kt`
- **iOS impl**: `packages/credential_manager_ios/ios/Classes/CredentialManagerPlugin.swift`
- **Error codes**: See exceptions.dart and docSite Usage page
