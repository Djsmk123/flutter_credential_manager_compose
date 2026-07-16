# API Reference

Ground truth extracted from:
- `packages/credential_manager/lib/src/credential_manager_core.dart`
- `packages/credential_manager_platform_interface/lib/src/**`

If the code has moved on since this was written, re-read those files rather than trusting this
verbatim — but as of the plugin versions in this repo's `CLAUDE.md` (platform_interface 2.0.8,
android/ios/credential_manager 3.0.1), this is exact.

## `CredentialManager`

Instantiate directly — the constructor registers the right platform plugin for you:

```dart
final credentialManager = CredentialManager();
```

| Member | Signature |
|---|---|
| `isSupportedPlatform` | `bool` getter — `Platform.isAndroid \|\| Platform.isIOS` |
| `isGmsAvailable` | `bool` getter — Android Play Services availability, always `true` on iOS, set during `init` |
| `getPlatformVersion()` | `Future<String?>` |
| `init(...)` | `Future<void> init({required bool preferImmediatelyAvailableCredentials, String? googleClientId})` |
| `savePasswordCredentials(credential)` | `Future<void> savePasswordCredentials(PasswordCredential credential)` |
| `savePasskeyCredentials(...)` | `Future<PublicKeyCredential> savePasskeyCredentials({required CredentialCreationOptions request})` |
| `getCredentials(...)` | `Future<Credentials> getCredentials({CredentialLoginOptions? passKeyOption, FetchOptionsAndroid? fetchOptions})` |
| `saveGoogleCredential(...)` | `Future<GoogleIdTokenCredential?> saveGoogleCredential({bool useButtonFlow = false})` |
| `logout()` | `Future<void> logout()` |

`preferImmediatelyAvailableCredentials`: when `true`, tells the authorization controller to prefer
credentials already available on-device rather than round-tripping to platform native flows.
Defaults to `false` when omitted (note the constructor makes it a *required* named param on
`CredentialManager.init`, even though the underlying platform interface treats it as a plain bool).

`useButtonFlow`: `true` = classic "Sign in with Google" button/alert-dialog flow. `false` = the
newer Credential Manager one-tap UI.

## Models

### `PasswordCredential`
```dart
class PasswordCredential {
  PasswordCredential({String? username, String? password});
  String? username;   // mutable getter/setter
  String? password;   // mutable getter/setter
}
```

### `Credentials` (return type of `getCredentials`)
```dart
class Credentials {
  final PasswordCredential? passwordCredential;
  final GoogleIdTokenCredential? googleIdTokenCredential;
  final PublicKeyCredential? publicKeyCredential;
}
```
Exactly one is populated per call, depending on `fetchOptions`/what was found. On Android, "not
found" returns an empty `Credentials` (all null) rather than throwing `CredentialException`.

### `GoogleIdTokenCredential`
```dart
class GoogleIdTokenCredential {
  final String email;          // required
  final String idToken;        // required
  final String? displayName;
  final String? familyName;
  final String? givenName;
  final String? phoneNumber;
  final Uri? profilePictureUri;
}
```

### `FetchOptionsAndroid`
```dart
FetchOptionsAndroid({
  bool passKey = false,
  bool googleCredential = false,
  bool passwordCredential = false,
});
// FetchOptionsAndroid.all() sets all three true
```
Android-specific fetch filter, passed to `getCredentials(fetchOptions: ...)`. On iOS this parameter
is effectively ignored — iOS auto-detects what to fetch from context (e.g. `AutofillGroup` for
passwords, `conditionalUI` for passkeys).

### `CredentialLoginOptions` (reading a passkey via `getCredentials(passKeyOption: ...)`)
```dart
CredentialLoginOptions({
  required String challenge,
  required String rpId,
  required String userVerification,
  int timeout = 1800000,        // 30 minutes, ms
  bool conditionalUI = false,   // iOS-only: shows passkey hint on keyboard when true
});
```
Required on **both platforms** if you want passkey credentials back — omitting it when you actually
want a passkey throws. It's fine to omit when you only want password/Google credentials.

### `CredentialCreationOptions` (creating a passkey via `savePasskeyCredentials`)
```dart
CredentialCreationOptions({
  required String challenge,
  required Rp rp,                                       // Rp(name, id)
  required User user,                                    // User(id, name, displayName)
  required List<PublicKeyCredentialParameters> pubKeyCredParams,
  int timeout = 1800000,
  String attestation = 'none',
  required List<ExcludeCredential> excludeCredentials,   // can be []
  required AuthenticatorSelectionCriteria authenticatorSelection,
});
```
Typically constructed via `CredentialCreationOptions.fromJson(map)` from a server-issued challenge
payload. Example JSON shape (this is what a typical WebAuthn-style backend returns, with Android
requiring a couple of extra platform-specific fields):

```dart
final credentialCreationOptions = {
  "challenge": "<base64url-encoded challenge from your server>",
  "rp": {"name": "My App", "id": rpId},           // rpId = your domain, e.g. "example.com"
  "user": {
    "id": encodedUserId,      // base64url-encoded, stable per-user identifier
    "name": username,
    "displayName": username,
  },
  "excludeCredentials": [],   // existing credential IDs to exclude, or []
};

if (Platform.isAndroid) {
  credentialCreationOptions.addAll({
    "pubKeyCredParams": [
      {"type": "public-key", "alg": -7},    // ES256
      {"type": "public-key", "alg": -257},  // RS256
    ],
    "timeout": 1800000,
    "attestation": "none",
    "authenticatorSelection": {
      "authenticatorAttachment": "platform",
      "residentKey": "required",       // required on Android
      "userVerification": "required",
    },
  });
}

final credential = await credentialManager.savePasskeyCredentials(
  request: CredentialCreationOptions.fromJson(credentialCreationOptions),
);
```

`Rp`: `{name, id}`. `User`: `{id, name, displayName}`. `PublicKeyCredentialParameters`:
`{type, alg}` (COSE algorithm identifiers — `-7` = ES256, `-257` = RS256).
`AuthenticatorSelectionCriteria`: `{authenticatorAttachment?, requireResidentKey?, residentKey?,
userVerification?}` — all optional but Android needs `residentKey: "required"` in practice.
`ExcludeCredential`: `{id, type}`.

### `PublicKeyCredential` (return type of `savePasskeyCredentials`, and
`Credentials.publicKeyCredential`)

```dart
class PublicKeyCredential {
  String? rawId;
  String? authenticatorAttachment;
  String? type;                          // defaults to 'public-key'
  String? id;
  Response? response;                    // nested — see below
  List<String>? transports;
  ClientExtensionResults? clientExtensionResults;
  int? publicKeyAlgorithm;               // TOP LEVEL, not under .response
  String? publicKey;                     // TOP LEVEL, not under .response
}
```

### `Response` (nested under `PublicKeyCredential.response`)
```dart
class Response {
  String? clientDataJSON;      // NESTED here, not on PublicKeyCredential directly
  String? attestationObject;
  String? authenticatorData;
  String? publicKey;           // note: Response also has its own publicKey field
  List<String>? transports;
  String? signature;
  String? userHandle;
}
```

Common mapping mistake to avoid when building a registration/assertion payload to send to a server:

```dart
final registrationResponse = {
  "id": credential.id,
  "rawId": credential.rawId,
  "type": credential.type,
  "clientDataJSON": credential.response?.clientDataJSON,   // nested under response
  "attestationObject": credential.response?.attestationObject,
  "authenticatorData": credential.response?.authenticatorData,
  "publicKey": credential.publicKey,                        // top-level on credential
  "publicKeyAlgorithm": credential.publicKeyAlgorithm,       // top-level on credential
  "transports": credential.transports,                       // top-level on credential
};
```

### `ClientExtensionResults` / `CredProps`
```dart
class ClientExtensionResults { CredProps? credProps; }
class CredProps { bool? rk; }   // whether the credential is a resident/discoverable key
```

## `CredentialException`

```dart
class CredentialException implements Exception {
  final int code;
  final String message;
  final dynamic details;
}
```

The only exception type this plugin throws. See `troubleshooting.md` for the full code table.
