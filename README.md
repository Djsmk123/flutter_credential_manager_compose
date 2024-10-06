# Credential Manager
![Android](https://img.shields.io/badge/Platforms-Android-green)
![iOS](https://img.shields.io/badge/Platforms-iOS-blue)

[Credential Manager](https://developer.android.com/jetpack/androidx/releases/credentials) is a Jetpack API that supports multiple sign-in methods, such as username and password, passkeys, and federated sign-in solutions (like Sign-in with Google) in a single API, simplifying integration for developers on Android. For iOS, it uses Keychain for storing credentials.

For users, Credential Manager unifies the sign-in interface across authentication methods, making it clearer and easier to sign into apps, regardless of the chosen method.

## ![Breaking Changes](https://img.shields.io/badge/Breaking%20Changes-red)


- Removed Encrypted Credentials for Android, as it was using old API and not needed Credentials API are enough to handle all.
- `getPasswordCredentials` changed to `getCredentials` for both android and ios, as now it will return only `PasskeyCredential` on iOS and on Android it will return all the types of credentials that are saved and perameter passed into function.


   
## ![Getting Started](https://img.shields.io/badge/Getting%20Started-green)

Add the dependency to your pubspec.yaml file:

```
credential_manager: <latest_version>

```

Or run:

```
flutter pub add credential_manager
```



## Setup Android ![Android](https://img.shields.io/badge/Platforms-Android-green)

1. Add proguard rules:
   Create or update `android/app/proguard-rules.pro`:

   ```
   -if class androidx.credentials.CredentialManager
   -keep class androidx.credentials.playservices.** {
     *;
   }
   ```

2. Update `android/app/build.gradle`:

   ```gradle
   android {
     buildTypes {
       release {
         minifyEnabled true
         proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
       }
     }
   }
   ```

## Setup for iOS ![iOS](https://img.shields.io/badge/Platforms-iOS-blue)


- Add Associated Domain to XCode
- Open your project settings, select your target and go to the Signing & Capabilities tab

![iOS Associated Domain](https://blogs.halodoc.io/content/images/2024/05/Screenshot-2024-05-15-at-14.31.08-1.png)

- Configure Apple App Site Association

- Create an apple-app-site-association file and host it at `https://yourdomain.com/.well-known/apple-app-site-association`

![iOS Apple App Site Association](https://blogs.halodoc.io/content/images/2024/05/Screenshot-2024-05-15-at-14.10.19-2.png)

> Note: The apple-app-site-association file must be served over HTTPS and must be served with the correct Content-Type header set to application/json. and replace `TeamID` and `Bundle Indentifier` with your own.
- Enable Keychain Sharing in XCode using sign and capabilites tab.


> **Note:**
> Passkey is a new feature introduced by Apple in iOS 16 and later versions. It provides a more secure and convenient way to handle credentials. This plugin supports passkey operations such as saving and retrieving passkey credentials on iOS 16+ devices. Make sure your app is targeting iOS 16 or higher to utilize this feature.

## Usage in Flutter ![Flutter](https://img.shields.io/badge/Flutter-blue)

1. Import the package:

   ```dart
   import 'package:credential_manager/credential_manager.dart';
   ```

2. Create a `CredentialManager` instance:

   ```dart
   CredentialManager credentialManager = CredentialManager();
   ```

3. Check if the platform is supported:

   ```dart
   if (credentialManager.isSupportedPlatform) {
     // Supported android and ios
   }
   ```

4. Initialize the Credential Manager:

   ```dart
   await credentialManager.init(
     preferImmediatelyAvailableCredentials: true,
     googleClientId: googleClientId // Optional for Google Sign-In
   );
   ```
> **Note:**
> `googleClientId` is optional for Google Sign-In, it being used only in android not ios.

5. Save credentials: 
- For Android:
   ```dart
   await credentialManager.savePasswordCredentials(
     PasswordCredential(username: username, password: password)
   );
   ```
- For iOS:
Wrap your TextFields using `AutoFillGroup`, after action it give you option to save in keychain if not exists and.



6. Save Google credentials(Only Android):

   ```dart
   final GoogleIdTokenCredential? gCredential = await credentialManager.saveGoogleCredential();
   ```

   For Google button flow: 
   ```dart
   await credentialManager.saveGoogleCredential(useButtonFlow: true);
   ```

   <img src="https://i.ibb.co/X2YVw1B/IMG-20240128-164412.jpg" alt="Get Google/Password Saved Credential " width="300" height="300">
   <img src="https://i.ibb.co/HgYkBgM/IMG-20240128-164512.jpg" alt="Get Google/Password Saved Credential Success" width="300" height="300">

7. Get saved credentials:

   ```dart 
   Credentials credential = await credentialManager.getCredentials(
      //passkey request data, if passkey is needed to be fetched
              passKeyOption: passKeyLoginOption,
      //only for android
      fetchOptions: FetchOptionsAndroid.all(),
   );
   ```
> **Note:**
> `fetchOptions` is only for android, it is not supported in ios. if use want specify which credential to be fetched then use `fetchOptions` and set values to `true` for respective credentials, otherwise if you want to fetch all credential then don't pass this parameter.

   <img src="https://i.ibb.co/fCs0kqV/5.jpg" alt="Get Credential 1" width="300" height="300">
   <img src="https://i.ibb.co/KNkgtdV/IMG-20240128-164347.jpg" alt="Google Save Credential 1" width="300" height="300">

> **Note:**
>  In Android, you can pass perameter which type of credential you want either it could be `PasswordBasedCredential`,`GoogleIdTokenCredential` or `PasskeyCredential` but in ios it will be only `PasskeyCredential`.

8. Logout (Only Android):

   ```dart
   await credentialManager.logout();
   ```
> **Note:**
> `logout` will remove session from the credential manager.

### Google Sign-In Setup (Android Only) ![Android](https://img.shields.io/badge/Platforms-Android-green)

Follow these steps to set up Google Sign-In for your application:

1. **Access Google Cloud Console**
   - Visit the [Google Cloud Console](https://console.cloud.google.com/)

2. **Create or Select a Project**
   - Create a new project or select an existing one

3. **Configure OAuth Consent Screen**
   - In the left sidebar, navigate to "APIs & Services" > "OAuth consent screen"
   - Choose the user type (External or Internal)
   - Fill in the required information and save

4. **Create Credentials**
   - In the left sidebar, go to "APIs & Services" > "Credentials"
   - Click the "Create Credentials" button and select "OAuth client ID"

5. **Set Application Type**
   - For Android apps, choose "Android" as the Application Type

6. **Configure Android App**
   - Enter your app's package name
   - Obtain the SHA-1 certificate fingerprint:
     ```
     cd android
     ./gradlew signingReport
     ```
   - Add the SHA-1 fingerprint to the Google Cloud Console

7. **Create Web Application Credentials**
   - Go back to the Credentials page
   - Click "Create Credentials" > "OAuth client ID" again
   - Select "Web application" as the Application Type
   - You can leave "Authorized JavaScript Origins" and "Authorized redirect URIs" blank for now
   - Click "Create"

8. **Obtain Client ID**
   - After creation, copy the "Client ID" for the web application
   - You'll use this Client ID in your Flutter app's `credentialManager.init()` method

#### Implementation in Flutter

Use the obtained Client ID in your Flutter app:

``` dart
await credentialManager.init(
  preferImmediatelyAvailableCredentials: true,
  googleClientId: 'YOUR_WEB_CLIENT_ID_HERE',
);
```

>> **Note:**   
>> - Ensure you've enabled the necessary APIs (like Google Sign-In API) for your project in the Google Cloud Console
>> - For production apps, make sure to add your app's release SHA-1 fingerprint as well
>> - Keep your Client ID secure and don't expose it in public repositories

## Integrate Passkey(Android Setup): ![Android](https://img.shields.io/badge/Platforms-Android-green)
### Steps:

1. Create a Digital Asset Links JSON file (assetlinks.json):
   - Open a text editor and create a new file named `assetlinks.json`.
   - Paste the following content into the file, replacing the placeholders with your specific information:

   ```json
   [
     {
       "relation": [
         "delegate_permission/common.handle_all_urls",
         "delegate_permission/common.get_login_creds"
       ],
       "target": {
         "namespace": "android_app",
         "package_name": "com.example.android",
         "sha256_cert_fingerprints": [
           "SHA_HEX_VALUE"
         ]
       }
     }
   ] 
   ```

2. Host the Digital Asset Links JSON file:
   - Place the file at the following location on your sign-in domain:
     `https://domain[:optional_port]/.well-known/assetlinks.json`

3. Configure your host:
   - Ensure that your host permits Google to retrieve your Digital Asset Link file.
   - If you have a `robots.txt` file, it must allow the Googlebot agent to retrieve `/.well-known/assetlinks.json`.
   - Most sites can use the following configuration:

   ```
   User-agent: *
   Allow: /.well-known/
   ```

### Create Passkey 

Use the following code to save passkey credentials:

```
dart
final credentialCreationOptions = {
  "challenge": EncryptData.getEncodedChallenge(),
  "rp": {"name": "CredMan App Test", "id": "<domain.com>"},
  "user": {
    "id": EncryptData.getEncodedUserId(),
    "name": "<username>",
    "displayName": "<username>",
  },
  "excludeCredentials": [
    {"id": "ghi789", "type": "public-key"},
    {"id": "jkl012", "type": "public-key"}
  ],
};

if (Platform.isAndroid) {
  credentialCreationOptions.addAll({
    "pubKeyCredParams": [
      {"type": "public-key", "alg": -7},
      {"type": "public-key", "alg": -257}
    ],
    "timeout": 1800000,
    "attestation": "none",
    "authenticatorSelection": {
      "authenticatorAttachment": "platform",
      "residentKey": "required"
    }
  });
}

final res = await credentialManager.savePasskeyCredentials(
  request: CredentialCreationOptions.fromJson(credentialCreationOptions),
);
```


> Note: This payload should be received from backend services.

[Read more about the payload here](https://github.com/android/identity-samples/tree/main/CredentialManager)

### Fetch Generated Passkey:

1. Create a pass request object:
   ```dart
   CredentialLoginOptions? passKeyLoginOption = CredentialLoginOptions(
     challenge: "<challenge>",
     rpId: "<domain.com>",
     userVerification: "required",
     //only for ios

   );
   ```

2. Pass this object to `getCredentials` for fetching the passkey in the list of login options:
   ```dart
   Credentials credential = await credentialManager.getCredentials(
     passKeyOption: passKeyLoginOption
     //only for ios, true only when we want to show the passkey popup on keyboard otherwise false
      conditionalUI: false,
   );

   ```

3. Check if the response is successful:
   ```dart
   bool isPublicKeyBasedCredentials = credential.publicKeyCredential != null;
   ```

## Visual Examples

Passkey Creation:
- Android ![Android](https://img.shields.io/badge/Platforms-Android-green)
![flutter-pass-key-creation](https://i.ibb.co/XCLvkB3/Whats-App-Image-2024-06-02-at-21-46-17.jpg)
- iOS ![iOS](https://img.shields.io/badge/Platforms-iOS-blue)

Passkey Fetching:
- Android
![flutter-pass-key-fetching](https://i.ibb.co/fCs0kqV/5.jpg)
- iOS
![flutter-pass-key-fetching](https://i.ibb.co/KNkgtdV/IMG-20240128-164347.jpg)



## Upcoming Features

- iOS Support for Apple Sign-In ![iOS](https://img.shields.io/badge/Platforms-iOS-blue)
- web Support ![web](https://img.shields.io/badge/Platforms-web-blue)

## Contributing

Contributions are welcome! Please see the [Contributing Guidelines](CONTRIBUTING.md) for more details.

If you find this package useful, please:
- Star it on GitHub
- Tweet about it
- Mention it in your blog posts

For bug reports, feature requests, or questions, please open an issue on GitHub.


