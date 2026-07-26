# 3.1.0
- Bumped `credential_manager_platform_interface` to `^3.0.0` (required — the previously-declared
  `^2.0.8` resolves to a published version that predates the `nonce` parameter this package's
  `saveGoogleCredential` override already relies on)
- Security fix: the unified `getCredentials` Google option no longer generates an internal,
  unverifiable nonce — it was never surfaced to the caller/backend for validation, so it provided
  no real replay protection. Use `saveGoogleCredential(nonce: ...)` when nonce verification against
  your backend is needed.

## 3.0.1
- Added Detekt static analysis configuration and CI checks; fixed all reported violations (replaced a wildcard import with explicit imports, renamed a file to match its top-level class, wrapped long lines)
- No functional or API changes

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

- Initial release of Android implementation package
- Android-specific implementation using Jetpack Credential Manager API
- Supports password credentials, passkeys, and Google Sign-In

