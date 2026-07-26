# 3.0.0
- **Breaking:** `CredentialManagerPlatform.saveGoogleCredential` gains an optional named `{String?
  nonce}` parameter. This was actually added in a prior commit without a version bump — the
  package published as `2.0.8` on pub.dev predates this change and does not have `nonce`, which
  broke `flutter pub get`/analysis for anyone resolving `credential_manager_platform_interface` from
  pub.dev (this repo's own melos workspace masked it locally via path-based resolution). Publishing
  this as a new major version is a correction, not new API surface.
- Any external `CredentialManagerPlatform` implementation overriding `saveGoogleCredential(bool
  useButtonFlow)` without the `nonce` parameter will fail to compile against this version — add
  `{String? nonce}` to your override (Dart requires overrides to declare every named parameter of
  the overridden method, even optional ones).
- No other functional changes; remaining diffs since `2.0.8` are formatting-only (120-column
  reformat).

## 2.0.8
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

