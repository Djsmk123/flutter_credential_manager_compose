# 2.0.8
- Added `isGmsAvailable` to platform interface
- Handle `exception code 209` for Google Play Services not available
- on Android, Google account is not logged in, the plugin will  launch Google Sign-In flow.
- Updated documentation


## 2.0.7
- Fixed plugin score issues

## 2.0.6

- Added exceptions and utilities to platform interface package
- Exported `CredentialException` and related exception classes
- Exported utility classes: `CredentialType`, `PlatformExceptionHandler`, and `CredentialResponseParser`
- Improved modular architecture by centralizing shared code in platform interface

## 2.0.5

- Initial release of platform interface package
- Provides abstract `CredentialManagerPlatform` class
- Supports modular plugin architecture

