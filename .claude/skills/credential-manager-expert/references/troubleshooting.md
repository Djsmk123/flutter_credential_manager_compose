# Troubleshooting & Exception Codes

Ground truth from `packages/credential_manager_platform_interface/lib/src/utils/platform_exception_handler.dart`
and `.../src/exceptions/exceptions.dart`. Every code below is a real, currently-thrown
`CredentialException.code` value — this is the mapping the plugin itself uses internally, not a
guess.

## Full code table

| Code | Message | When it fires / what to do |
|---|---|---|
| 101 | Initialization failure | `init()` failed at the platform layer. Check native setup (see `android-setup.md` / `ios-setup.md`). |
| 102 | Plugin exception | Generic platform-channel error; inspect `details`. |
| 103 | Not implemented | Called a method the current platform doesn't support (e.g. passkeys on an unsupported OS version). |
| 201 | Login cancelled (or "Login with Google cancelled" for Google flows) | User dismissed the system UI. **Not an error** — handle silently, don't show a toast. |
| 202 | No credentials found | Fetch returned nothing. Android instead often returns an empty `Credentials` object rather than throwing this — check both paths. |
| 203 | Mismatched credentials | The stored credential doesn't match what was requested (e.g. RP ID mismatch). |
| 204 | Login failed | Generic failure during credential retrieval. |
| 205 | Temporarily blocked | Too many cancelled sign-in prompts in a row; also raised on iOS when the underlying error contains `[28436]`. Back off and let the user retry later — don't immediately re-prompt. |
| 206 | Credential fetch options not enabled | You called `getCredentials` without the right `fetchOptions` flags set for what you're trying to retrieve. |
| 207 | No Google account present | Android found no signed-in Google account. **The plugin automatically opens the "Add account" settings screen** — don't duplicate that by also showing your own account-picker. |
| 208 | RequestJson is required for passkey | You need a `passKeyOption` (for reads) or a properly-built `request` (for creates) — one was missing/malformed. |
| 209 | Google Play Services not available | Check `credentialManager.isGmsAvailable` *before* attempting Google flows to avoid ever hitting this. |
| 301 | Save Credentials cancelled (or "Save Google Credentials cancelled") | User dismissed the save prompt. Not an error. |
| 302 | Create Credentials failed | Generic failure while saving. |
| 401 | Encryption failed | Internal storage failure. |
| 402 | Decryption failed | Internal storage failure, often means corrupted/tampered stored data. |
| 501 | Received an invalid Google ID token response | Malformed response from Google — check `googleClientId` is the **Web** OAuth client ID, not the Android one (common cause). |
| 502 | Invalid request | Malformed request sent to the platform layer. |
| 503 | Google client is not initialized yet | Called a Google-related method before `init()` completed, or `init()` was called without `googleClientId`. |
| 504 | Credentials operation failed | Also the fallback/default code for any unmapped native error — check `details` for the real underlying message. |
| 505 | Google credential decode error | Failed to parse the Google ID token response. |
| 601 | User cancelled passkey operation | Not an error — same idea as 201/301 but passkey-specific. |
| 602 | Passkey creation failed | Failure during `savePasskeyCredentials`. Check Digital Asset Links (Android) / Associated Domains (iOS) setup first — this is the most common root cause. |
| 603 | Passkey failed to fetch | Failure during `getCredentials(passKeyOption: ...)`. Same setup issues as 602 are the usual culprit. |

## Recommended error-handling pattern

Treat "cancelled" codes (201, 301, 601) as normal user behavior, not failures:

```dart
try {
  await credentialManager.savePasswordCredentials(
    PasswordCredential(username: username, password: password),
  );
} on CredentialException catch (e) {
  switch (e.code) {
    case 201:
    case 301:
      // user cancelled — no error UI needed
      break;
    case 209:
      // Play Services unavailable — you should have checked isGmsAvailable earlier
      break;
    default:
      // real failure — surface e.message / e.code to the user or your error tracker
  }
}
```

There is only ever one exception type — `CredentialException` — never write `catch
(CredentialCancelledException e)` or similar; that class does not exist and code written against
it will fail to compile.

## Common root causes, by symptom

- **"Passkey creation/fetch always fails, no matter what I pass"** → almost always a Digital Asset
  Links (Android) or Associated Domains / `apple-app-site-association` (iOS) setup problem, not a
  Dart bug. Validate the hosted files directly (`curl`, Branch AASA validator) before debugging Dart
  code further.
- **"Google Sign-In throws 501/503"** → wrong client ID type. `googleClientId` passed to `init()`
  must be the **Web application** OAuth client, not the Android one.
- **"Nothing happens when I focus the password field on iOS"** → the field is missing
  `autofillHints`, or it's not inside an `AutofillGroup`, or Associated Domains/AASA isn't set up.
- **"Works on Android, nothing on iOS" for Google Sign-In** → expected. `saveGoogleCredential` is
  implemented for Android and Web, but **not** iOS.
- **"getCredentials returns nothing but doesn't throw"** → check on Android specifically: an empty
  `Credentials` (all fields null) is a valid non-error "nothing found" result, distinct from a
  thrown 202. Always null-check the result even inside a successful `try` block.

## Web-specific issues

See `references/web-setup.md` for the full setup guide. Quick triage:

- **`CredentialException(code: 101, message: 'Initialization failure: JavaScript not loaded')`** →
  the `<script src="packages/credential_manager_web/web/passkey_authenticator.js">` tag is missing
  from `web/index.html`, or the app is served from a base path where that relative path doesn't
  resolve.
- **Error 400 from Google after picking an account, or sign-in silently fails** → the app's exact
  origin (scheme + host + port, no trailing slash) isn't in the Google Cloud OAuth Web client's
  "Authorized JavaScript origins." This is required for Web even though it's optional for
  Android-only projects.
- **`[GSI_LOGGER]: FedCM get() rejects with NetworkError: Error retrieving a token` /
  "FedCM was disabled either temporarily based on previous user action or permanently via site
  settings"** → not a plugin bug. The browser has disabled FedCM prompts for this site (repeated
  dismissals trigger a cooldown, or the user/an extension turned it off). Tell the user to click the
  icon left of the URL bar (or visit `chrome://settings/content/federatedIdentityApi`) to re-enable
  third-party sign-in for the site.
- **`HTTP ERROR 403 / Access to localhost was denied`** while testing locally on macOS → almost
  always port `5000` or `7000`, which macOS's ControlCenter/AirPlay Receiver reserves. Not a Flutter
  or plugin issue — use a different port (e.g. `5173`) and update the OAuth client's authorized
  origins to match.
- **Do not suggest reintroducing raw FedCM** (`navigator.credentials.get({identity: {providers:
  [{configURL: 'https://accounts.google.com/gsi/fedcm.json', ...}]}})`) as "a simpler alternative" to
  GIS if someone asks to remove the GIS dependency — this repo tried exactly that and hit a 403
  (wrong path) then a `Required parameter is missing: response_type` error from Google's backend
  after fixing the path. GIS is the documented, working integration; don't regress to raw FedCM.
- **Password credential *retrieval* on Web** → not exposed on the public API at all currently
  (`savePasswordCredentials` works; there's no public `getPasswordCredentials`/fetch path on Web).
  Don't invent one — say so.
