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
- **"Works on Android, nothing on iOS" for Google Sign-In** → expected. `saveGoogleCredential` /
  `FetchOptionsAndroid(googleCredential: true)` are Android-only in practice.
- **"getCredentials returns nothing but doesn't throw"** → check on Android specifically: an empty
  `Credentials` (all fields null) is a valid non-error "nothing found" result, distinct from a
  thrown 202. Always null-check the result even inside a successful `try` block.
