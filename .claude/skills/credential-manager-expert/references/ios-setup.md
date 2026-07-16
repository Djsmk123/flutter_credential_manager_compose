# iOS Native Setup

Ground truth from `docSite/src/pages/ConfigurationPage.tsx`. iOS uses **Keychain** for passkeys and
**AutoFill** (backed by Keychain) for password credentials — there's no separate SDK to install
beyond this plugin; the work is entitlements + hosting a verification file.

## 1. Swift Package Manager vs CocoaPods

Since `credential_manager_ios` v3.0.0, the package ships **both** a `Package.swift` (SPM) and the
original `credential_manager_ios.podspec` (CocoaPods) from the same `Sources/` directory — you don't
need to choose per-plugin, Flutter picks based on your app's setup. No breaking changes to the Dart
API either way.

Why this matters: Flutter defaults to SPM from 3.24+, and CocoaPods' trunk registry goes read-only
December 2, 2026 — after that, new plugin *versions* can only be published via SPM. Migrating ahead
of time is recommended but not urgent for existing CocoaPods setups.

**Enabling SPM** (if not already your Flutter channel's default):
```bash
flutter config --enable-swift-package-manager
```
Then just `flutter pub get` && `flutter run`/`flutter build ios` — Flutter auto-detects the
`Package.swift` and integrates it as a Swift Package. If your `ios/Podfile` still has other
CocoaPods-only dependencies, Flutter keeps using CocoaPods for those while resolving SPM-compatible
plugins (like this one) through SPM — you don't have to migrate the whole project at once.

**Migrating an existing CocoaPods-only project to SPM fully** (only once every plugin you depend on
supports SPM):
```bash
cd ios
pod deintegrate
```
Then delete `Podfile`/`Podfile.lock` if you have no remaining CocoaPods-only deps, and re-run
`flutter build ios` to regenerate the Xcode project against SPM.

See Flutter's official [Swift Package Manager for app developers](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers) guide for the general (non-plugin-specific) parts of this migration.

## 2. Enabling Password AutoFill

1. Open the project in Xcode.
2. App target → **Signing & Capabilities** tab.
3. Click "+" → add **Associated Domains** capability.
4. Add both prefixes for your domain:
   - `applinks:yourdomain.com`
   - `webcredentials:yourdomain.com`

   Both are needed — `webcredentials:` is what actually authorizes AutoFill/Keychain to associate
   credentials with your domain; `applinks:` is separate (universal links) but commonly needed
   alongside it if you also deep-link from that domain.

5. Host an `apple-app-site-association` file (no file extension, served as
   `application/json` or `application/pkcs7-mime`, no redirects) at your domain root:

```json
{
  "applinks": {
    "apps": [],
    "details": [{
      "appIDs": ["<team_id>.com.yourappname"]
    }]
  },
  "webcredentials": {
    "apps": [
      "<team_id>.com.yourappname"
    ]
  }
}
```

   Must be reachable at `https://yourdomain.com/.well-known/apple-app-site-association` (no
   `.well-known` fallback needed at root, but `.well-known` is the modern/preferred location — serve
   it at both if unsure). `<team_id>` is your Apple Developer Team ID; `com.yourappname` is your
   app's bundle identifier — concatenated as `TEAMID.bundle.id`, no separator.

6. Validate:
```bash
curl -X GET https://yourdomain.com/.well-known/apple-app-site-association
```
   Or use the [Branch AASA Validator](https://branch.io/resources/aasa-validator/). Common failure:
   serving it with a redirect or wrong content-type — Apple's fetcher won't follow redirects for
   this file.

7. In the Flutter widget tree, wrap username/password fields in `AutofillGroup` with the right
   `autofillHints` so iOS knows what to save/suggest:

```dart
AutofillGroup(
  child: Column(
    children: [
      TextFormField(
        autofillHints: const [AutofillHints.username],
        decoration: const InputDecoration(labelText: 'Username'),
      ),
      TextFormField(
        autofillHints: const [AutofillHints.password],
        decoration: const InputDecoration(labelText: 'Password'),
        obscureText: true,
      ),
    ],
  ),
);
```
   After validating the form and completing the sign-in action, iOS's native AutoFill save-password
   prompt appears automatically — there's no explicit Dart call needed to trigger the iOS save UI
   (contrast with Android, where you explicitly call `savePasswordCredentials`). On retrieval, the
   Keychain access prompt appears on the keyboard as soon as the user focuses the field.

## 3. Keychain Sharing (needed for passkeys, and for sharing credentials across apps in the same team)

1. Add the **Keychain Sharing** capability in Signing & Capabilities.
2. Enter a keychain group name — this needs to match across every app/extension in your team that
   should share access to the same stored credentials.

## 4. Passkeys on iOS — platform requirements

Passkeys require **iOS 16+**. Unlike Android, there's no extra native config beyond what's already
required for AutoFill (the Associated Domains + `apple-app-site-association` setup above) — the
`webcredentials` entry in that JSON file is what iOS uses for passkey RP-ID verification too, not
just password AutoFill. If AutoFill already works, passkeys typically need zero additional native
setup, just the correct `CredentialCreationOptions`/`CredentialLoginOptions` on the Dart side (see
`api-reference.md`).

`CredentialLoginOptions.conditionalUI: true` is iOS-specific — set it when you want the passkey
hint to appear as a suggestion above the keyboard (WebAuthn "conditional mediation") rather than a
full modal prompt.
