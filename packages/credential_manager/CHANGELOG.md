## 0.0.1

- Initial release.

## 0.0.2

- Added encryption.
- No breaking changes.
- Added documentation.

## 0.0.3

- Implemented remaining ActivityAware lifecycle methods. Thanks to [Granfalloner](https://github.com/Granfalloner).

## 0.0.4

- Migrated to latest version of Jetpack library ([release notes](https://developer.android.com/jetpack/androidx/releases/credentials#groovy)).
- Added Google Sign-in with Credential Manager.

## 0.0.5

- Updated all dependencies to latest versions. Thanks to [@jlafazia-figure](https://github.com/jlafazia-figure).
- Bug fixes and improvements in example application.
- Updated README.md with latest information.

## 1.0.0

- Added Passkey support.
- Autofill from website.
- Fixed bugs and improved code.

## 1.0.1

- Fixed example application (package ID).
- Provided rpId for testing purposes.

## 1.0.2

- Added missing fields to `Response` object for `PublicKeyCredential`.

## 1.0.3

- Added Google button flow for Google login. Thanks to [@wildsylvan](https://github.com/wildsylvan).

## 1.0.4

- Added logout functionality using `clearCredential()`, updated example application, documentation, and dependencies.

## 1.0.4+1

- Updated documentation.
- Updated example application.
- Updated dependencies.
- Updated README.md.
- Updated CHANGELOG.md.
- Updated LICENSE.
- Updated pubspec.yaml.
- Updated errors.md.

## 2.0.0

- Added Password Credentials and Passkey Credentials support for iOS.
- Breaking changes in Android.
- Removed Encrypted Credentials (password-based) from both platforms.

## 2.0.1

- Fixed example application (`enableInlineAutofill`) for iOS by default.

## 2.0.2

- Updated documentation.

## 2.0.3

- Migrated example application to Gradle 8.10.2.
- Updated dependencies.
- Added decoding of `attestationObject` to extract `publicKey` and `authenticatorData` for passkey credential registration (iOS only).
- Improved example application.

## 2.0.4

### Dependencies
- Updated Android and Flutter dependencies for improved stability and compatibility. ([3a870fa](https://github.com/your-repo/commit/3a870fa))
- Updated Android Gradle plugin version to 8.4.2.
- Upgraded package versions and fixed iOS-related errors.

### iOS Fixes
- Refactored UIWindow retrieval logic in `PasskeyAuthentication` and `PasskeyRegistration` to address build issues on iOS.
- Fixed iOS build issues in the example project.

### Documentation & CI
- Enhanced README and overall documentation.
- Updated static analysis and caching workflows in `static.yml` to improve CI efficiency.

## 2.0.5

### Major Refactoring: Modular Architecture
- **BREAKING CHANGE**: Refactored plugin into modular architecture with separate packages:
  - `credential_manager` - Main plugin package with shared code (models, exceptions, utilities)
  - `credential_manager_platform_interface` - Platform-agnostic interface
  - `credential_manager_android` - Android-specific implementation
  - `credential_manager_ios` - iOS-specific implementation
- All packages are now located in the `packages/` directory
- Improved maintainability and code organization

### Code Optimization
- **Removed ~300+ lines of duplicate code** between Android and iOS implementations
- Created shared utilities:
  - `CredentialType` enum - Centralized credential type definitions
  - `PlatformExceptionHandler` - Unified error handling for both platforms
  - `CredentialResponseParser` - Shared credential response parsing logic
- Android implementation reduced from ~326 lines to 177 lines
- iOS implementation reduced from ~410 lines to 250 lines

### Bug Fixes
- Fixed `AssertionError` for uninitialized `CredentialManagerPlatform.instance`
- Implemented automatic platform registration in `CredentialManager` constructor
- Fixed platform-specific implementations not being registered automatically

### Platform Registration
- Added automatic platform implementation registration
- Platform implementations are now registered when `CredentialManager` is instantiated
- Improved error messages for uninitialized platform instances

### Testing & Migration
- ✅ iOS migration tested and working
- ✅ Android migration tested and working
- All platform implementations verified and functional

### Developer Experience
- Added analysis error checking script (`packages/scripts/analysis_error.sh`)
- Improved code organization and maintainability
- Better separation of concerns between platforms
- All packages pass static analysis with no errors

### Documentation
- Updated package structure documentation
- Enhanced README with modular architecture information
- Improved code comments and documentation
