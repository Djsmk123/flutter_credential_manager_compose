# 3.0.1
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

