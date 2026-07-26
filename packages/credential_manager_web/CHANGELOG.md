# 2.2.0
- Bumped `credential_manager_platform_interface` to `^3.0.0` (required — the previously-declared
  `^2.0.8` resolves to a published version that predates the `nonce` parameter this package's
  `saveGoogleCredential` override already relies on)
- Fixed `getPasswordCredentials` requesting a WebAuthn assertion (`publicKey` options) instead of a
  stored password credential (`password: true`) — it could never succeed at its stated purpose
- `cancelCurrentAuthenticatorOperation` now cancels an in-flight Google Identity Services flow too
  (previously a no-op for anything but WebAuthn, leaving a pending `saveGoogleCredential` unresolved)
- Added a defensive 30s timeout to the passive Google One Tap prompt path, since FedCM can leave the
  request pending indefinitely without a display/skip notification
- Renamed the internal `_googleClientId` parameter on the JS `initialize` method to `googleClientId`
  (was misleadingly underscore-prefixed despite being used) and clarified its documentation
- Raised the minimum `flutter` SDK constraint to `3.24.0` (first release paired with Dart 3.5,
  matching this package's existing `sdk: '>=3.5.0'` constraint)

## 2.1.0

- Fixed the `<script>` tag path documented in the README, Google Sign-In setup guide, and example
  app's `web/index.html`: `flutter build web` places plugin `web/` assets under
  `assets/packages/<pkg>/...`, not a top-level `packages/<pkg>/...` — the old path only happened to
  resolve under `flutter run`'s dev server, and 404'd on real static deploys (e.g. Netlify)
- No changes to the package's Dart/JS source or public API

## 2.0.7

- Initial release of Web implementation package
- Web-specific implementation using Web Authentication API (WebAuthn) and Credential Management API
- Supports password credentials, passkeys, and Google Sign-In

