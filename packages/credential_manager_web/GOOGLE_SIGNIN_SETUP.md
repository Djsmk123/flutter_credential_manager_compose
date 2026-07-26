# Google Sign-In Setup on Web

This document explains how to configure Google Sign-In for the web platform. It's powered by
[Google Identity Services](https://developers.google.com/identity/gsi/web/guides/overview) (GIS), which
routes the handshake through the browser's native [FedCM](https://developer.chrome.com/docs/identity/fedcm/overview)
UI on supporting browsers — the same officially-documented path Google recommends for third-party sites.

> **Why GIS and not raw FedCM?** An earlier version of this package called
> `navigator.credentials.get({identity: {providers: [{configURL: 'https://accounts.google.com/gsi/fedcm.json', ...}]}})`
> directly. That path isn't documented or supported for third-party relying parties: it fails with a 403 on the
> wrong config path, and even once the config/params/mode shape is corrected it still fails once an account is
> picked, with a `Required parameter is missing: response_type` error from Google's backend. GIS handles this
> handshake correctly and is the path this package now uses.

## Prerequisites

1. **Google Web OAuth Client ID**: create one in [Google Cloud Console](https://console.cloud.google.com/) → APIs &
   Services → Credentials → "Create Credentials" → OAuth client ID → Application type **Web application**.
2. **Authorized JavaScript origins**: add every origin you'll run the app from, e.g. `http://localhost:5173` for
   local dev and `https://yourdomain.com` for production. GIS validates the calling origin against this list —
   requests fail with a `400` error if it's missing, with no trailing-slash tolerance.
3. **Browser support**: Chromium-based browsers (Chrome, Edge) get the full FedCM-backed experience; other browsers
   fall back to GIS's standard (non-FedCM) flow.
4. **Secure context**: HTTPS in production, or `http://localhost` during development.
5. **Load the JS bundle**: add the plugin's `<script>` tag to `web/index.html` (see the package
   [README](./README.md#setup)) — it is not injected automatically.

## Configuration

Provide your Web client ID when initializing the plugin:

```dart
await credentialManager.init(
  preferImmediatelyAvailableCredentials: true,
  googleClientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com',
);
```

No further per-endpoint configuration is required — GIS's client script (`https://accounts.google.com/gsi/client`)
is loaded lazily on first use of `saveGoogleCredential`/`getCredentials`.

## Usage

### Google Sign-In only

#### Button flow (`useButtonFlow: true`)

Renders Google's real Sign-In button off-screen and forwards the click from your own button's press, so it still
counts as direct user interaction:

```dart
final credential = await credentialManager.saveGoogleCredential(
  useButtonFlow: true,
);
```

#### One Tap / passive flow (`useButtonFlow: false`)

Shows Google's One Tap prompt without requiring a prior click:

```dart
final credential = await credentialManager.saveGoogleCredential(
  useButtonFlow: false,
);
```

#### Custom nonce (optional)

```dart
final credential = await credentialManager.saveGoogleCredential(
  useButtonFlow: false,
  nonce: 'a-value-your-backend-issued', // omit to use a securely-generated random one
);
```

### Unified credential fetch

Similar to Android's Credential Manager, `getCredentials()` tries passkeys first, then falls back to Google
Sign-In:

```dart
final credentials = await credentialManager.getCredentials(
  passKeyOption: CredentialLoginOptions(
    challenge: 'your-challenge',
    rpId: 'localhost',
    userVerification: 'required',
  ),
  fetchOptions: FetchOptionsAndroid(
    passKey: true,
    googleCredential: true,
    passwordCredential: false, // not supported by the unified fetch on Web
  ),
);
```

## Response Format

`saveGoogleCredential`/`getCredentials` return a `GoogleIdTokenCredential`, matching Android/iOS:

```dart
GoogleIdTokenCredential(
  email: 'user@example.com',
  idToken: 'eyJhbGciOiJSUzI1NiIs...', // JWT ID token - validate this on your server
  displayName: 'John Doe',
  givenName: 'John',
  familyName: 'Doe',
  phoneNumber: '+1234567890',
  profilePictureUri: Uri.parse('https://...'),
)
```

## Security Considerations

1. **Validate the ID token server-side** — the client only decodes the JWT payload for convenience; it does not
   verify the signature.
2. **Never expose your OAuth Client Secret** in client-side code — only the Client ID is needed here.
3. **Nonce**: pass your own value when you need to tie the sign-in request to something your backend already
   issued (e.g. to prevent replay); otherwise a securely-generated random nonce is used automatically.

## Troubleshooting

### Error: "Google Client ID is not configured"
Provide `googleClientId` in `init()`.

### Error 400: `invalid_request` / origin mismatch after picking an account
Your calling origin isn't in the OAuth client's "Authorized JavaScript origins" list — add it exactly (scheme,
host, and port), then retry.

### "Google One Tap was not shown or was dismissed"
The user isn't signed in to a Google account in the browser, previously dismissed the prompt (Google backs off for
a while after a dismissal), or the browser/profile has third-party sign-in prompts disabled at
`chrome://settings/content/federatedIdentityApi`.

### Button flow does nothing
Some browsers only preserve "transient user activation" for a very short window between your button's click and
the forwarded click on Google's hidden button. Make sure `saveGoogleCredential` is called synchronously from the
click handler (no `await` before it) and isn't delayed by other work.

### Initialization error: "CredentialManagerWeb JavaScript bundle not found"
The `<script>` tag for `packages/credential_manager_web/web/passkey_authenticator.js` is missing from
`web/index.html`, or the app was served from a path where that relative path doesn't resolve.

## Additional Resources

- [Google Identity Services overview](https://developers.google.com/identity/gsi/web/guides/overview)
- [Migrate to FedCM (Google)](https://developers.google.com/identity/gsi/web/guides/fedcm-migration)
- [FedCM API (Chrome for Developers)](https://developer.chrome.com/docs/identity/fedcm/overview)
