# 2.1.0

- Fixed the `<script>` tag path documented in the README, Google Sign-In setup guide, and example
  app's `web/index.html`: `flutter build web` places plugin `web/` assets under
  `assets/packages/<pkg>/...`, not a top-level `packages/<pkg>/...` — the old path only happened to
  resolve under `flutter run`'s dev server, and 404'd on real static deploys (e.g. Netlify)
- No changes to the package's Dart/JS source or public API

## 2.0.7

- Initial release of Web implementation package
- Web-specific implementation using Web Authentication API (WebAuthn) and Credential Management API
- Supports password credentials, passkeys, and Google Sign-In

