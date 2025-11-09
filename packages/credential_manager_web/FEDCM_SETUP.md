# Unified Credential Management on Web

This document explains how to configure and use unified credential management on the web platform, similar to Android's Credential Manager.

## Overview

The web implementation provides a unified credential management system that supports:
- **Passkeys** (via WebAuthn API)
- **Google Sign-In** (via FedCM - Federated Credential Management API)

This unified approach matches Android's Credential Manager behavior, where you can fetch passkeys or Google Sign-In credentials from a single method call.

**References:**
- [FedCM Documentation](https://developer.chrome.com/docs/identity/fedcm/overview)
- [WebAuthn API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Authentication_API)

## Prerequisites

1. **Google Client ID**: You need a Google OAuth 2.0 Client ID configured in the [Google Cloud Console](https://console.cloud.google.com/)
2. **Browser Support**: FedCM is currently supported in Chrome and other Chromium-based browsers
3. **HTTPS**: FedCM requires HTTPS (except for `localhost`)

## Configuration

### 1. Initialize with Google Client ID

When initializing the credential manager, provide your Google Client ID:

```dart
await credentialManager.init(
  preferImmediatelyAvailableCredentials: true,
  googleClientId: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
);
```

### 2. Google FedCM Configuration

Google's FedCM implementation is automatically configured. The implementation uses:
- **Config URL**: `https://accounts.google.com/gsi/fedcm/config.json`

This config URL is used by the browser to discover Google's FedCM endpoints:
- Accounts endpoint
- Client metadata endpoint  
- ID token endpoint

**Note**: As the RP (Relying Party), you don't need to configure these endpoints directly. The browser fetches them from Google's config URL automatically.

## Usage

### Unified Credential Fetch (Recommended)

Similar to Android's Credential Manager, use `getCredentials()` to fetch passkeys or Google Sign-In:

```dart
// Fetch credentials - tries passkeys first, then Google Sign-In
final credentials = await credentialManager.getCredentials(
  passKeyOption: CredentialLoginOptions(
    challenge: 'your-challenge',
    rpId: 'localhost',
    userVerification: 'required',
  ),
  fetchOptions: FetchOptionsAndroid(
    passKey: true,        // Enable passkey fetch
    googleCredential: true, // Enable Google Sign-In fetch
    passwordCredential: false, // Not supported on web
  ),
);
```

The method will:
1. Try to fetch passkeys first (if `passKey: true` and `passKeyOption` provided)
2. Fall back to Google Sign-In via FedCM (if `googleCredential: true`)
3. Return the first available credential

### Google Sign-In Only

For Google Sign-In only:

#### Active Mode (Button Flow)

Requires user interaction (button click):

```dart
final credential = await credentialManager.saveGoogleCredential(
  useButtonFlow: true,
);
```

#### Passive Mode (Automatic)

Shows automatically when user is signed in:

```dart
final credential = await credentialManager.saveGoogleCredential(
  useButtonFlow: false,
);
```

### Passkey Only

For passkey authentication only:

```dart
final credentials = await credentialManager.getCredentials(
  passKeyOption: CredentialLoginOptions(
    challenge: 'your-challenge',
    rpId: 'localhost',
    userVerification: 'required',
  ),
  fetchOptions: FetchOptionsAndroid(
    passKey: true,
    googleCredential: false,
  ),
);
```

## Response Format

The method returns a `GoogleIdTokenCredential` object with the following properties:

```dart
GoogleIdTokenCredential(
  email: 'user@example.com',
  idToken: 'eyJhbGciOiJSUzI1NiIs...', // JWT ID token
  displayName: 'John Doe',
  givenName: 'John',
  familyName: 'Doe',
  phoneNumber: '+1234567890',
  profilePictureUri: Uri.parse('https://...'),
)
```

## Implementation Details

### Unified Credential Fetch

The `getCredentials()` method works similarly to Android's Credential Manager:

1. **Priority Order**: Tries passkeys first, then Google Sign-In
2. **Passkey Fetch**: Uses WebAuthn API (`navigator.credentials.get()` with `publicKey`)
3. **Google Sign-In Fetch**: Uses FedCM API (`navigator.credentials.get()` with `identity`)
4. **Unified Response**: Returns credentials in the same format as Android/iOS

### How Google Sign-In Works (FedCM)

1. **FedCM Request**: The implementation calls `navigator.credentials.get()` with FedCM configuration
2. **Browser UI**: Chrome shows a browser-mediated sign-in dialog
3. **Token Exchange**: The FedCM token is decoded/extracted (JWT format)
4. **Response**: Returns the Google credential data in the same format as Android/iOS

### How Passkeys Work (WebAuthn)

1. **WebAuthn Request**: Uses `@github/webauthn-json` library for WebAuthn operations
2. **Browser UI**: Browser shows passkey authentication dialog
3. **Response**: Returns passkey credential in standard WebAuthn format

### Token Exchange

The FedCM token returned by the browser is a JWT that contains user information. The implementation:
- Decodes the JWT to extract user claims
- Returns the token and user data in the standard `GoogleIdTokenCredential` format

**Note**: For production, you may need to implement server-side token exchange depending on Google's FedCM implementation.

## Browser Compatibility

### Passkeys (WebAuthn)
- ✅ Chrome 67+
- ✅ Edge 18+
- ✅ Safari 13+
- ✅ Firefox 60+

### Google Sign-In (FedCM)
- ✅ Chrome 108+
- ✅ Edge 108+
- ✅ Other Chromium-based browsers
- ❌ Firefox (not yet supported)
- ❌ Safari (not yet supported)

**Note**: For browsers that don't support FedCM, you'll need to provide a fallback OAuth 2.0 implementation for Google Sign-In.

## Fallback Strategy

Since FedCM is not supported in all browsers, you should:

1. **For Unified Credential Fetch**: The `getCredentials()` method will automatically try passkeys first, which work in more browsers
2. **For Google Sign-In Only**: Check for errors and provide a fallback:

```dart
if (credentialManager.isSupportedPlatform) {
  try {
    // Try unified fetch first
    final credentials = await credentialManager.getCredentials(
      passKeyOption: passKeyLoginOption,
      fetchOptions: FetchOptionsAndroid(
        passKey: true,
        googleCredential: true,
      ),
    );
  } on CredentialException catch (e) {
    // Fallback to traditional OAuth flow for Google Sign-In
    if (e.message.contains('not supported') || e.message.contains('FedCM')) {
      // Use alternative OAuth implementation
    }
  }
}
```

## Security Considerations

1. **HTTPS Required**: FedCM only works over HTTPS (except localhost)
2. **Token Validation**: Always validate the ID token on your server
3. **Client ID**: Never expose your Google Client Secret in client-side code
4. **Privacy**: FedCM is designed to be privacy-preserving and doesn't use third-party cookies

## Troubleshooting

### Error: "Google Client ID is not configured"
- Make sure you provide `googleClientId` in the `init()` method

### Error: "Credential Management API is not supported"
- FedCM requires a modern Chromium-based browser
- Check browser compatibility

### Error: "No Google credential returned"
- User may have cancelled the sign-in
- User may not be signed in to Google
- Check browser console for FedCM-specific errors

### Error: "Error retrieving a token" or "FedCM network error"

This is the most common FedCM error. It indicates that FedCM cannot retrieve a token from Google's identity provider. Check the following:

#### 1. **Google Cloud Console OAuth Client Configuration**

In your [Google Cloud Console](https://console.cloud.google.com/), verify:

- **JavaScript Origins**: Must include your exact domain and port
  - For localhost: `http://localhost` and `http://localhost:PORT` (e.g., `http://localhost:8080`)
  - For production: `https://yourdomain.com`
  - **Important**: No trailing slashes, exact match required

- **Authorized Redirect URIs**: Should include your domain
  - For localhost: `http://localhost:PORT`
  - For production: `https://yourdomain.com`

- **OAuth Consent Screen**: Must be properly configured
  - Developer email address is set
  - App name and support email are filled
  - Scopes are defined (at minimum: `openid`, `email`, `profile`)

#### 2. **Browser Settings**

- **Chrome**: Go to `chrome://settings/content/federatedIdentityApi`
  - Ensure "Sites can show sign-in prompts from identity services" is **enabled**
  - If disabled, enable it and restart the browser

- **Third-party cookies**: While FedCM doesn't use third-party cookies, ensure your browser allows first-party cookies

#### 3. **Testing Environment**

- **HTTPS**: FedCM requires HTTPS (except for `localhost`)
- **Localhost**: Works without HTTPS, but ensure the port matches your JavaScript origins
- **Clear cache**: Try in an incognito/private window to rule out cache issues

#### 4. **Debug Steps**

1. Open browser DevTools (F12)
2. Check the Console tab for FedCM-specific errors
3. Check the Network tab for failed requests to `accounts.google.com`
4. Verify your Google Client ID is correct (no typos, includes `.apps.googleusercontent.com`)
5. Test with a minimal example to isolate the issue

#### 5. **Common Configuration Mistakes**

- ❌ Wrong JavaScript origin format: `http://localhost/` (trailing slash)
- ✅ Correct: `http://localhost:8080` (no trailing slash, includes port)

- ❌ Missing port in localhost origin
- ✅ Include port: `http://localhost:8080`

- ❌ OAuth consent screen not published (for external users)
- ✅ Publish the consent screen or add test users

#### 6. **Error Message Details**

The improved error handling now provides specific guidance:
- If you see "FedCM network error", check JavaScript origins and OAuth configuration
- If you see "User canceled", the user dismissed the sign-in prompt
- If you see "No account available", the user isn't signed in to Google

## Additional Resources

- [FedCM Overview](https://developer.chrome.com/docs/identity/fedcm/overview)
- [FedCM Setup and Debug](https://developer.chrome.com/docs/identity/fedcm/setup)
- [Google Identity Services](https://developers.google.com/identity)

