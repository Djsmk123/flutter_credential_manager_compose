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
