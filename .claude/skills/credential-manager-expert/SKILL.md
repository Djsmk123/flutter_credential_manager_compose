---
name: credential-manager-expert
description: Expert on the flutter_credential_manager_compose plugin (pub.dev package "credential_manager") — Android Jetpack Credential Manager, iOS Keychain/AutoFill, passkeys (FIDO2/WebAuthn), password credentials, and Google Sign-In in Flutter. Use this skill whenever the user asks about implementing passkeys, biometric sign-in, password autofill, "one tap" or "one-tap" Google sign-in, Credential Manager errors/exception codes, Digital Asset Links / assetlinks.json, Associated Domains / apple-app-site-association, Swift Package Manager vs CocoaPods for this plugin, or when writing/reviewing/debugging any Dart code that imports credential_manager, credential_manager_platform_interface, credential_manager_android, or credential_manager_ios. Also use it for questions phrased generically like "how do I save a login in my Flutter app" or "how do I let iOS/Android suggest a password" — those almost always mean this plugin's password-credential or passkey flow. Trigger even if the user doesn't name the package explicitly, as long as they're working in this repo or clearly building on this plugin.
---

# Credential Manager Expert

You are acting as the resident expert on `flutter_credential_manager_compose`, a federated Flutter
plugin that wraps Android's Jetpack Credential Manager and iOS Keychain/AutoFill behind one Dart
API. Your job is to write, review, and debug code against the *actual* current API — not the
plausible-sounding API an LLM might guess at. This plugin has a real history of docs drifting from
code (wrong method names, wrong field nesting, invented exception classes), so treat every claim in
this file as ground truth extracted directly from source, and re-verify against source if the code
in this repo has moved on since.

## Package layout

```
credential_manager_platform_interface   (Dart contracts: models, exceptions, CredentialManagerPlatform)
        ^                    ^
credential_manager_android   credential_manager_ios      (native Kotlin / Swift implementations)
        ^                            ^
              credential_manager     (umbrella package — this is what apps actually import)
```

Always `import 'package:credential_manager/credential_manager.dart';` in application code — it
re-exports everything from the platform interface (models, exceptions, `CredentialManager`).

## The core API, exactly as it exists today

`CredentialManager` (from `credential_manager_core.dart`) is an **instance-based** class — not
static methods. This has been a recurring source of hallucination; there is no
`CredentialManager.save(...)` static API. Always construct one:

```dart
final credentialManager = CredentialManager();

if (credentialManager.isSupportedPlatform) {   // Platform.isAndroid || Platform.isIOS
  await credentialManager.init(
    preferImmediatelyAvailableCredentials: true,  // required named param
    googleClientId: '<your-web-client-id>',       // optional, only needed for Google Sign-In
  );
}

if (!credentialManager.isGmsAvailable) {
  // Android-only signal (always true on iOS). False means Google Play Services is missing —
  // don't launch Google flows, you'll otherwise hit exception code 209.
}
```

Full method surface (get the exact signature right — these are commonly mis-typed):

| Method | Signature | Notes |
|---|---|---|
| `savePasswordCredentials` | `Future<void> savePasswordCredentials(PasswordCredential credential)` | **Plural** "Credentials". `savePasswordCredential` (singular) does not exist — this exact typo has shipped in the docs before. |
| `savePasskeyCredentials` | `Future<PublicKeyCredential> savePasskeyCredentials({required CredentialCreationOptions request})` | Registers/creates a passkey. |
| `getCredentials` | `Future<Credentials> getCredentials({CredentialLoginOptions? passKeyOption, FetchOptionsAndroid? fetchOptions})` | One entry point for reading back password, passkey, or Google credentials. |
| `saveGoogleCredential` | `Future<GoogleIdTokenCredential?> saveGoogleCredential({bool useButtonFlow = false})` | Android-only in practice. |
| `logout` | `Future<void> logout()` | Android-only effect (clears session); no-op on iOS. |
| `getPlatformVersion` | `Future<String?> getPlatformVersion()` | Diagnostic only. |

Getters: `isSupportedPlatform` (bool), `isGmsAvailable` (bool, set during `init`).

## Models — get the field nesting right

This is the single most common mistake when generating code against this plugin. `PublicKeyCredential`
has some fields directly on it and others nested one level down in `.response`. Don't guess — use
this table:

**`PasswordCredential`**: `username`, `password` (both `String?`, mutable getters/setters).

**`PublicKeyCredential`** (top level): `id`, `rawId`, `type`, `authenticatorAttachment`,
`transports` (`List<String>?`), `clientExtensionResults`, `publicKeyAlgorithm` (`int?`),
`publicKey` (`String?`), and `response` (a nested `Response` object).

**`PublicKeyCredential.response`** (nested `Response` class): `clientDataJSON`, `attestationObject`,
`authenticatorData`, `publicKey`, `transports`, `signature`, `userHandle`.

So: `credential.publicKeyAlgorithm` — NOT `credential.response.publicKeyAlgorithm`. But
`credential.response.clientDataJSON` — NOT `credential.clientDataJSON`. When in doubt, check
`references/api-reference.md` for the full field list rather than inferring from WebAuthn spec
naming conventions, because this plugin's shape doesn't perfectly mirror the browser
`PublicKeyCredential` JS object.

**`Credentials`** (the return type of `getCredentials`): a bag with three optional fields —
`passwordCredential`, `publicKeyCredential`, `googleIdTokenCredential` — exactly one of which is
populated depending on what was fetched/found. Always null-check before use; on Android a "not
found" result comes back as an empty `Credentials` object rather than throwing.

**`GoogleIdTokenCredential`**: `email`, `idToken` (required), plus optional `displayName`,
`familyName`, `givenName`, `phoneNumber`, `profilePictureUri`.

**`FetchOptionsAndroid`**: `passKey`, `googleCredential`, `passwordCredential` (all default `false`
in the constructor — pass the ones you want `true`). Android-specific; harmless but unused on iOS.

**`CredentialLoginOptions`** (for reading a passkey): `challenge` and `rpId` required,
`userVerification` required, `timeout` (default 1800000ms/30min), `conditionalUI` (iOS-only,
default `false` — shows the passkey hint on the keyboard when `true`).

**`CredentialCreationOptions`** (for creating a passkey): `challenge`, `rp` (`Rp(name, id)`),
`user` (`User(id, name, displayName)`), `pubKeyCredParams`, `excludeCredentials`,
`authenticatorSelection`, `timeout` (default 1800000), `attestation` (default `'none'`). Usually
built with `CredentialCreationOptions.fromJson(map)` from a server-issued challenge — see
`references/api-reference.md` for the full JSON shape including Android-only fields
(`pubKeyCredParams`, `authenticatorSelection` needs `residentKey: "required"` on Android).

## Exceptions

Only one exception type exists: `CredentialException implements Exception`, with `code` (int),
`message` (String), `details` (dynamic). There is no `CredentialCancelledException`,
`CredentialRequestException`, or similar — do not invent subclasses.

```dart
try {
  await credentialManager.savePasswordCredentials(PasswordCredential(username: u, password: p));
} on CredentialException catch (e) {
  if (e.code == 201) {
    // user cancelled — expected, don't show an error toast
  } else {
    // real failure — see references/troubleshooting.md for the full code table
  }
}
```

Codes worth knowing without opening the reference: **201** = user cancelled (all flows), **202** =
no credentials found, **207** = no Google account on device (plugin auto-opens account settings),
**209** = Google Play Services unavailable, **601–603** = passkey-specific failures. Full table with
every code and when it fires: `references/troubleshooting.md`.

## Platform support matrix

- **Passwords**: Android (Credential Manager) + iOS (Keychain/AutoFill via `AutofillGroup` +
  `autofillHints`). Both platforms.
- **Passkeys**: Android 14+ and iOS 16+ only. Older OS versions throw — always gate passkey UI
  behind a version/capability check rather than assuming availability.
- **Google Sign-In**: Android only in practice (`saveGoogleCredential`/`googleCredential` fetch
  option). Don't wire it into an iOS-only code path.
- **`logout()`**: clears Android session state; no meaningful effect on iOS.

## When you need native setup details

Don't try to reconstruct Android manifest/proguard rules or iOS entitlements from memory — read the
relevant reference file, because these involve exact JSON/XML shapes that are easy to get subtly
wrong (wrong relation strings in `assetlinks.json`, wrong Associated Domains prefix, etc.):

- **Android native setup** (proguard, Digital Asset Links / `assetlinks.json`, Google Cloud Console
  OAuth client, SHA-1 fingerprints): `references/android-setup.md`
- **iOS native setup** (Associated Domains, `apple-app-site-association`, Keychain Sharing
  capability, SPM vs CocoaPods): `references/ios-setup.md`
- **Full API reference** (every class/method/field, JSON shapes for passkey creation options):
  `references/api-reference.md`
- **Exception code table + common failure scenarios and fixes**: `references/troubleshooting.md`

## Versioning convention (if asked to bump versions)

This repo does **not** use standard semver bump rules. Bug fix or small change → **minor** bump.
Migration, new feature, or breaking change → **major** bump. This is intentional and documented in
the repo's own `CLAUDE.md` — follow it as-is, don't "correct" it to standard semver.

## A note on trust

This plugin's own documentation site has shipped incorrect method names, wrong field nesting, and
fictional exception types before — all traced back to LLM-plausible-sounding code that was never
checked against source. When writing example code for this plugin, prefer copying patterns from
this file (which was built by reading the actual `.dart` source) over generating from general
WebAuthn/Credential-Manager knowledge, since this plugin's Dart surface has its own specific shape
that doesn't map 1:1 onto the underlying platform APIs or the browser WebAuthn spec.
