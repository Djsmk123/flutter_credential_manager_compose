# 4.1.0
- Explicitly target JVM 17 for Kotlin to match Java compilation after the built-in Kotlin migration, fixing
  `compileDebugKotlin` failures for consuming apps that disable built-in Kotlin and run Gradle on JDK 21 or
  newer (Kotlin previously defaulted to targeting whichever JVM ran Gradle, instead of matching Java's JVM 17).
- No breaking changes to the public Dart API.

## 4.0.0
- Bumped `credential_manager_platform_interface` to `^4.0.0` (required for `prepareCredentials` and
  `allowCredentials`)
- `getCredentials` now applies the `preferImmediatelyAvailableCredentials` value supplied during initialization.
- Added Android 14+ credential preparation: a new `prepareCredentials` call prefetches a matching credential
  request ahead of time. A matching `getCredentials` call consumes the prepared handle and falls back to the
  normal request if the prefetched data can no longer be used.
- Fixed compiling against `androidx.credentials` 1.6.0: apps that also depend on `google_sign_in` (which pulls
  in 1.6.0) no longer crash with `NoSuchMethodError` when creating a passkey, since Gradle unifies the runtime
  classpath to the highest requested version.
- No breaking changes to the public Dart API.

## 3.1.0
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
