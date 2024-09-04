# Credential Manager

[Credential Manager](https://developer.android.com/jetpack/androidx/releases/credentials) is a Jetpack API that supports multiple sign-in methods, such as username and password, passkeys, and federated sign-in solutions (like Sign-in with Google) in a single API, simplifying integration for developers.

For users, Credential Manager unifies the sign-in interface across authentication methods, making it clearer and easier to sign into apps, regardless of the chosen method.

> Note: This package is currently only supported for Android.

## Getting Started 

Add the dependency to your pubspec.yaml file:

```
credential_manager: <latest_version>

```

Or run:

```
flutter pub add credential_manager
```



## Setup Android

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

## Usage in Flutter

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
     // Supported
   }
   ```

4. Initialize the Credential Manager:

   ```dart
   await credentialManager.init(
     preferImmediatelyAvailableCredentials: true,
     googleClientId: googleClientId // Optional for Google Sign-In
   );
   ```

5. Save credentials:

   ```dart
   await credentialManager.savePasswordCredentials(
     PasswordCredential(username: username, password: password)
   );
   ```

6. Save Google credentials:

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
   Credentials credential = await credentialManager.getPasswordCredentials();
   ```

   <img src="https://i.ibb.co/fCs0kqV/5.jpg" alt="Get Credential 1" width="300" height="300">
   <img src="https://i.ibb.co/KNkgtdV/IMG-20240128-164347.jpg" alt="Google Save Credential 1" width="300" height="300">

8. Logout:

   ```dart
   await credentialManager.logout();
   ```

## Encrypt Your Credentials

To enhance security, you can encrypt the password field:


## Encrypt Your Credentials

To enhance security, you can encrypt the password field:

```
dart
final secretKey = "<Secret-key>"; // 16-character string
final ivKey = "<16-bit-iv-key>";
// Save encrypted credentials
await credentialManager.saveEncryptedCredentials(
credential: PasswordCredential(username: username, password: password),
secretKey: secretKey,
ivKey: ivKey
);
// Get and decrypt credentials
Credentials credential = await credentialManager.getEncryptedCredentials(
secretKey: secretKey,
ivKey: ivKey
);
```

## Additional Setup

- [Google Sign-In Setup (optional)](./google.md)
- [Passkey Integration (optional)](./passkey.md)

## Error Handling

For detailed error codes and messages, see [Error Handler](./errors.md).

## Properties and Methods

For a complete list of properties and methods, see [Properties and Methods](./methods.md).

## Upcoming Features

- iOS Support

## Contributing

Contributions are welcome! Please see the [Contributing Guidelines](CONTRIBUTING.md) for more details.

If you find this package useful, please:
- Star it on GitHub
- Tweet about it
- Mention it in your blog posts

For bug reports, feature requests, or questions, please open an issue on GitHub.


