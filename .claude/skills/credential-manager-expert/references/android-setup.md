# Android Native Setup

Ground truth from `docSite/src/pages/ConfigurationPage.tsx` and `UsagePage.tsx`, cross-checked
against the plugin's actual Android requirements. These are exact file contents/paths, not
paraphrases — copy them rather than reconstructing from memory of "how Credential Manager usually
works," since small mistakes here (wrong relation string, wrong file path) cause silent failures.

## 1. Proguard rules

Needed because release builds with R8/Proguard strip the Credential Manager / Play Services
integration classes unless told not to. Create or update `android/app/proguard-rules.pro`:

```
-if class androidx.credentials.CredentialManager
-keep class androidx.credentials.playservices.** {
  *;
}
```

And enable minification with those rules in `android/app/build.gradle`:

```kotlin
android {
  buildTypes {
    release {
      minifyEnabled true
      proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
  }
}
```

## 2. Digital Asset Links (`assetlinks.json`)

Required for **both** passkeys and Google-backed password autofill suggestions on Android — it's
how Android verifies your app is allowed to act on behalf of your web domain. Without this, the
Credential Manager UI won't offer to save/autofill for your app.

Create `assetlinks.json`:

```json
[
  {
    "relation": [
      "delegate_permission/common.handle_all_urls",
      "delegate_permission/common.get_login_creds"
    ],
    "target": {
      "namespace": "android_app",
      "package_name": "your.package.name",
      "sha256_cert_fingerprints": [
        "YOUR_APP_SIGNATURE_SHA256_HASH"
      ]
    }
  }
]
```

Both `relation` entries matter: `handle_all_urls` is the standard App Links verification, but
`get_login_creds` is the one that specifically authorizes credential save/autofill — don't drop it
even if you already have App Links set up for other reasons.

Host it at: `https://yourdomain.com/.well-known/assetlinks.json`

If you have a `robots.txt`, make sure it doesn't block Google's crawler from fetching that path:

```
User-agent: *
Allow: /.well-known/
```

### Getting the SHA-256 (or SHA-1, for OAuth) fingerprint

```bash
cd android && ./gradlew signingReport
```

or

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Remember debug and release keystores have *different* fingerprints — you need the release one
registered for production, and typically both registered while developing (debug for local testing,
release for the actual release build/Play Store signing).

## 3. Google Sign-In / OAuth client setup

Google Sign-In on this plugin (`saveGoogleCredential`, or `getCredentials(fetchOptions:
FetchOptionsAndroid(googleCredential: true))`) needs an OAuth client configured in Google Cloud
Console — and specifically needs a **Web application** OAuth client ID (not the Android one) passed
as `googleClientId` to `CredentialManager.init`. This trips people up: you still register an Android
OAuth client (tied to your SHA-1 + package name, so Google trusts the calling app), but the ID you
actually pass into the Dart code is the *Web* client's ID.

Steps:
1. Go to [Google Cloud Console](https://console.cloud.google.com/), create/select a project.
2. APIs & Services → OAuth consent screen → configure it (choose External or Internal user type).
3. APIs & Services → Credentials → Create Credentials → OAuth client ID.
4. Application type **Android**: enter your package name and the SHA-1 fingerprint (see above).
   This authorizes the calling app but you don't use this client ID directly in code.
5. Create a **second** OAuth client ID, application type **Web application**. Authorized JS
   origins/redirect URIs can be left blank for this plugin's use case.
6. Copy the **Web** client's Client ID and pass it to `init`:

```dart
await credentialManager.init(
  preferImmediatelyAvailableCredentials: true,
  googleClientId: '<the-web-application-client-id>',
);
```

## 4. Passkeys on Android — platform requirements

Passkeys require **Android 14+**. Digital Asset Links setup (step 2 above) is a hard prerequisite —
without it, passkey creation/retrieval will fail even with correct Dart code. There is no separate
Android manifest permission needed beyond what Credential Manager / Play Services already requires
via the dependency.

When building `CredentialCreationOptions` for Android, the `authenticatorSelection.residentKey`
field needs to be `"required"` — Android's implementation expects a discoverable/resident credential
for its passkey flow. See `api-reference.md` for the full JSON shape.
