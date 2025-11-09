# credential_manager_web

Web implementation of the `credential_manager` plugin.

This package provides the Web-specific implementation using:
- **WebAuthn API** for passkey authentication
- **Credential Management API** for password credentials
- **FedCM (Federated Credential Management API)** for Google Sign-In

## Usage

This package is automatically included when you use `credential_manager` on Web. You typically don't need to import this package directly.

## Features

- ✅ Passkey registration and authentication (WebAuthn)
- ✅ Password credential management
- ✅ Google Sign-In via FedCM (privacy-preserving, no third-party cookies)
- ✅ Same API structure as Android/iOS implementations

## Setup

### Google Sign-In (FedCM)

For Google Sign-In support, see [FEDCM_SETUP.md](./FEDCM_SETUP.md) for detailed configuration instructions.

**Quick Start:**
1. Get a Google OAuth 2.0 Client ID from [Google Cloud Console](https://console.cloud.google.com/)
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
     useButtonFlow: true, // true = active mode, false = passive mode
   );
   ```

## Browser Support

- **Passkeys**: Chrome 67+, Edge 18+, Safari 13+, Firefox 60+
- **Password Credentials**: Chrome 51+, Edge 79+, Safari 13+
- **FedCM (Google Sign-In)**: Chrome 108+, Edge 108+ (Chromium-based browsers only)

## Implementation Details

This package uses:
- `@github/webauthn-json` library for WebAuthn operations
- Native `navigator.credentials` API for password and FedCM operations
- Dart FFI (`dart:js_interop`) for JavaScript interop

## Documentation

- [FedCM Setup Guide](./FEDCM_SETUP.md) - Complete guide for Google Sign-In setup

## Requirements

- Modern browsers with WebAuthn and Credential Management API support
- HTTPS (required for WebAuthn and Credential Management API, except localhost)

## License

See the [LICENSE](../LICENSE) file for details.

