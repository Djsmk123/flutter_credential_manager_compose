# 3.2.0
- **Fixes #92: passkey registration/authentication silently hangs since 3.0.1.** `savePassKeyCredentials`
  and `getPasskeyCredentials` created `PasskeyService` as a local variable with no strong reference
  held anywhere; once the enclosing method returned, it deallocated immediately. Since
  `ASAuthorizationController`'s delegate and presentation-context-provider are held weakly, this
  silently dropped the completion callback (success or failure) and the Dart `Future` never
  resolved — no exception, no error code, forever. `[weak self]` in `PasskeyService`'s own
  completion closures (added in 3.0.1's SwiftLint cleanup) is what exposed this: previously an
  unintentional retain cycle kept the object graph alive long enough to mask the bug.
- `CredentialManagerPlugin` now holds a strong reference to each in-flight `PasskeyService` for the
  duration of its call, removed once its own `FlutterResult` fires. Uses a collection rather than a
  single slot, so overlapping passkey calls (e.g. register and get in flight together) don't cause
  one call's `PasskeyService` to release another's out from under its still-active authorization.
- No breaking changes to the public Dart API

## 3.1.0
- Bumped `credential_manager_platform_interface` to `^3.0.0` (required — the previously-declared
  `^2.0.8` resolves to a published version that predates the `nonce` parameter this package's
  `saveGoogleCredential` override already relies on)
- `savePasswordCredentials` and `saveGoogleCredential` now throw an explicit `CredentialException`
  (code 103, "Not implemented") instead of silently reporting success without saving
  (`savePasswordCredentials`) or surfacing an uncaught `MissingPluginException` from a
  method-channel call with no native handler (`saveGoogleCredential`) — neither has a native Swift
  implementation on iOS today
- No breaking changes to the public Dart API

## 3.0.1
- Added SwiftLint configuration and CI checks; fixed all reported violations (force casts replaced with safe casts, wrapped long lines, aligned switch cases, extracted long functions)
- No functional or API changes

## 3.0.0
- Added Swift Package Manager (SPM) support via a new `Package.swift` manifest, alongside the existing CocoaPods podspec
- Moved Swift sources from `ios/Classes` to `ios/credential_manager_ios/Sources/credential_manager_ios` (single source of truth for both CocoaPods and SPM)
- No breaking changes to the Dart API; existing CocoaPods-based apps continue to work unchanged

## 2.0.8
- Added `isGmsAvailable` to platform interface
- Handle `exception code 209` for Google Play Services not available
- on Android, Google account is not logged in, the plugin will  launch Google Sign-In flow.
- Updated documentation

## 2.0.7
- Fixed plugin score issues

## 2.0.6

- Removed plugin_platform_interface dependency

## 2.0.5

- Initial release of iOS implementation package
- iOS-specific implementation using Keychain and Autofill
- Supports password credentials, passkeys, and Google Sign-In
- Includes iOS-specific passkey attestation parsing

