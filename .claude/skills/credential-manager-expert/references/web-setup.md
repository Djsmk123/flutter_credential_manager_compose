# Web Native Setup

Ground truth from `packages/credential_manager_web/lib/**`, `packages/credential_manager_web/GOOGLE_SIGNIN_SETUP.md`,
`packages/credential_manager/lib/src/credential_manager_core.dart`, and this repo's own build/CI
history (several of the gotchas below were real failures hit while building this feature, not
theoretical). Copy these exactly rather than reconstructing from general WebAuthn/FedCM knowledge —
Web is the newest platform here and has the least margin for guessing.

## 1. Load the JavaScript bundle (required, not automatic)

Unlike Android/iOS, `credential_manager_web` does **not** wire itself up automatically. Every app
that runs on Web must add this `<script>` tag to `web/index.html`, **before** Flutter boots
(before `flutter_bootstrap.js`):

```html
<body>
  <script src="packages/credential_manager_web/web/passkey_authenticator.js"></script>
  <script src="flutter_bootstrap.js" async></script>
</body>
```

Skip this and `CredentialManager().init(...)` throws:

```
CredentialException(code: 101, message: 'Initialization failure: JavaScript not loaded', ...)
```

The bundle is built from `packages/credential_manager_web/lib/javascript/src/index.ts` via
`npm run build` (rollup) inside `lib/javascript/`, outputting to `web/passkey_authenticator.js`. If
you edit the TypeScript source, you must rebuild and commit the regenerated `.js` file — it is not
built automatically as part of `flutter build`/`flutter run`.

## 2. Why the umbrella package doesn't just `import` credential_manager_web directly

`credential_manager_web`'s Dart files use `dart:js_interop` (`JSString`, `JSBoolean`, `JSPromise`,
etc.), which only resolves when the Dart compiler targets Web. If `credential_manager_core.dart`
imported it unconditionally, Android/iOS builds fail outright — this is a real CI failure this repo
hit, not a hypothetical:

```
Error: 'JSString' isn't a type.
...
FileSystemException(uri=org-dartlang-untranslatable-uri:dart%3Ajs_interop; ...)
```

The fix (already in place — don't undo it if refactoring `credential_manager_core.dart`): the web
plugin is registered through a conditional import gated on `dart.library.js_interop`:

```dart
import 'web_registration_stub.dart' if (dart.library.js_interop) 'web_registration_web.dart' as web_registration;
```

`web_registration_stub.dart` is a no-op used on Android/iOS; `web_registration_web.dart` (only
compiled for Web) calls `CredentialManagerWebPlugin.registerWithManual()`. If you ever add another
Web-only Dart dependency to the umbrella package, use this same pattern — never a bare
`import 'package:credential_manager_web/...'`.

## 3. Google Sign-In on Web (Google Identity Services, backed by FedCM)

Full details: `packages/credential_manager_web/GOOGLE_SIGNIN_SETUP.md`. Summary:

- Implemented via **Google Identity Services (GIS)** (`https://accounts.google.com/gsi/client`,
  lazily loaded on first use), which uses the browser's native **FedCM** UI on supporting browsers.
  This is Google's officially documented integration path for third-party sites.
- **Do not** reintroduce a raw `navigator.credentials.get({identity: {providers: [{configURL:
  'https://accounts.google.com/gsi/fedcm.json', ...}]}})` call as the primary implementation. An
  earlier version of this plugin did exactly that and it does not work reliably for third-party
  relying parties — it 403'd on an incorrect config path, and even after correcting the
  `configURL`/`params.nonce`/top-level `mode` shape (per Chrome's official FedCM RP guide), it still
  failed post-account-selection with a Google backend error: `Required parameter is missing:
  response_type`. GIS is the fix, not raw FedCM.
- Reuse the same **Web application** OAuth client ID you created for Android (see
  `android-setup.md` step 3) — but for Web, **do** fill in "Authorized JavaScript origins" with
  every origin you'll run the app from. GIS validates the calling origin against this list;
  requests fail with a `400` error if it's missing, with no trailing-slash tolerance.
- Pass it the same way as Android:

```dart
await credentialManager.init(
  preferImmediatelyAvailableCredentials: true,
  googleClientId: '<your-web-client-id>.apps.googleusercontent.com',
);
```

- `saveGoogleCredential(bool useButtonFlow, {String? nonce})`:
  - `useButtonFlow: false` (One Tap / passive) → `google.accounts.id.prompt()`.
  - `useButtonFlow: true` (button flow) → renders GIS's real button into an off-screen container
    and forwards the click, so it still counts as a genuine user interaction (same technique the
    official `google_sign_in_web` plugin uses). This relies on transient user activation — call it
    synchronously from the click handler, don't `await` something else first.
  - `nonce`: optional. Omit it and a cryptographically random one is generated via
    `crypto.getRandomValues` — mirroring Android's `SecureRandom`-backed nonce for
    `GetGoogleIdOption`/`GetSignInWithGoogleOption`.

### Browser-side gotchas that look like plugin bugs but aren't

- **"FedCM was disabled either temporarily based on previous user action or permanently via site
  settings"** with `[GSI_LOGGER]: FedCM get() rejects with NetworkError: Error retrieving a token.`
  in the console — this is the browser, not the plugin. Chrome disables FedCM prompts for a site
  after the user dismisses them a few times, or the user (or an extension) has explicitly turned it
  off. Fix: click the icon to the left of the URL bar (or `chrome://settings/content/federatedIdentityApi`)
  and re-enable third-party sign-in for the site, or wait out the cooldown.
- **Port 5000 (and 7000) on macOS**: reserved by ControlCenter/AirPlay Receiver. Serving your dev
  build there produces a generic `HTTP ERROR 403 / Access to localhost was denied` page that has
  nothing to do with this plugin. Use any other port (e.g. `5173`) for `flutter run -d chrome
  --web-port` / your dev server, and register that exact `http://localhost:PORT` origin in the
  OAuth client.

## 4. Passkeys & password credentials (WebAuthn / Credential Management API)

- Passkeys use `@github/webauthn-json` over the browser's native WebAuthn API — no separate
  Digital Asset Links / Associated Domains file is required the way Android/iOS need (Web relies on
  the browser's own origin-bound WebAuthn security model instead). Any modern WebAuthn-capable
  browser works; there's no OS-version gate like Android 14+/iOS 16+.
- `savePasswordCredentials` uses `navigator.credentials.create()` (Credential Management API)
  directly, same as Android/iOS.
- **Retrieval is more limited on Web than the other platforms**: `credential_manager_web` has an
  internal `getPasswordCredentials()` that calls `navigator.credentials.get()`, but it is **not**
  exposed on `CredentialManagerPlatform` or the umbrella `CredentialManager` — there is no public
  Dart API to fetch password credentials on Web today. The unified `getCredentials(fetchOptions:
  ...)` entry point on Web tries passkey first, then falls back to Google Sign-In; it silently does
  **not** fetch password credentials even if `FetchOptionsAndroid(passwordCredential: true)` is set.
  If a user asks for "get saved password on web," say plainly that this plugin doesn't currently
  support it (save-only), rather than inventing a method call.
- Requires a secure context: HTTPS in production, or `http://localhost` during development.
