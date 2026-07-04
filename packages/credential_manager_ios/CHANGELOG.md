# 3.0.1
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

