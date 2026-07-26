# credential_manager_web

Web implementation of the `credential_manager` plugin.

This package provides the Web-specific implementation using:
- **WebAuthn API** for passkey authentication
- **Credential Management API** for password credentials
- **Google Identity Services (GIS)**, backed by FedCM on supporting browsers, for Google Sign-In

## Usage

This package is automatically included when you use `credential_manager` on Web. You typically don't need to import this package directly.

## Features

- ✅ Passkey registration and authentication (WebAuthn)
- ✅ Password credential management
- ✅ Google Sign-In via Google Identity Services, backed by FedCM (privacy-preserving, no third-party cookies)
- ✅ Same API structure as Android/iOS implementations

## Setup

### 1. Load the JavaScript bundle

Add this to `web/index.html`, before `flutter_bootstrap.js`, in every app that depends on this package (it is
**not** injected automatically):

```html
<script src="assets/packages/credential_manager_web/web/passkey_authenticator.js"></script>
```

### 2. Google Sign-In (Google Identity Services)

For Google Sign-In support, see [GOOGLE_SIGNIN_SETUP.md](./GOOGLE_SIGNIN_SETUP.md) for detailed configuration
instructions (OAuth client setup, authorized origins, troubleshooting).

**Quick Start:**
1. Get a Google Web OAuth 2.0 Client ID from [Google Cloud Console](https://console.cloud.google.com/) and add
   your app's origins under "Authorized JavaScript origins"
2. Initialize with your client ID:
   ```dart
   await credentialManager.init(
     preferImmediatelyAvailableCredentials: true,
     googleClientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com',
   );
   ```
3. Use Google Sign-In:
   ```dart
   final credential = await credentialManager.saveGoogleCredential(
     useButtonFlow: true, // true = button flow, false = One Tap
   );
   ```

## Browser Support

- **Passkeys**: Chrome 67+, Edge 18+, Safari 13+, Firefox 60+
- **Password Credentials**: Chrome 51+, Edge 79+, Safari 13+
- **Google Sign-In (GIS/FedCM)**: full FedCM-backed experience on Chromium-based browsers (Chrome/Edge 108+); GIS
  falls back to its standard flow elsewhere

## Implementation Details

This package uses:
- `@github/webauthn-json` library for WebAuthn operations
- Native `navigator.credentials` API for password credentials
- Google Identity Services (`https://accounts.google.com/gsi/client`), lazily loaded, for Google Sign-In
- Dart JavaScript interop (`dart:js_interop`)

## Documentation

- [Google Sign-In Setup Guide](./GOOGLE_SIGNIN_SETUP.md) - Complete guide for Google Sign-In setup

## Requirements

- Modern browsers with WebAuthn and Credential Management API support
- HTTPS (required for WebAuthn and Credential Management API, except localhost)

## License

See the [LICENSE](LICENSE) file for details.

