# Credential Manager

[Credential Manager](https://developer.android.com/jetpack/androidx/releases/credentials) is a Jetpack API that supports multiple sign-in methods, such as username and password, passkeys, and federated sign-in solutions (such as Sign-in with Google) in a single API, thus simplifying the integration for developers.

Furthermore, for users, Credential Manager unifies the sign-in interface across authentication methods, making it clearer and easier for users to sign into apps, regardless of the method they choose


> Note this package is only supported for android

## Getting Started 

- Add the dependency to your pubspec.yaml file
   ```
   dependencies:
      credential_manager: <latest_version>
   ```

   --------------------------------------------**OR**------------------------------------------------
   ```
   flutter pub get credential_manager
   ```

## [Setup android](https://developer.android.com/training/sign-in/passkeys)
- Add proguard rules
if `proguard-rules.pro` is not exist in `android/app` then create new file with same name 

```
 -if class androidx.credentials.CredentialManager
-keep class androidx.credentials.playservices.** {
  *;
}

```
- Update `android\app\build.gradle` 

```
buildTypes {
        release {
            //add these lines 
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
```

## [Setup Google Sign In (optional)](./google.md)
 Checkout how to integrate google sign in without firebase.

## [Passkey Integration(optional)](./passkey.md)
Passkey step by step procedure.



## Usage in flutter
- import the package

    ```
    import 'package:credential_manager/credential_manager dart';
    ```
- Create object for `CredentialManager()` 
    ```
    CredentialManager credentialManager = CredentialManager();
    ```
- Check if target platform is supported or not

```
if(credentialManager.isSupportedPlatform){
    // if supported
}
```

- Initialize credential manager

```
if(credentialManager.isSupportedPlatform){
    // if supported
    await credentialManager.init(preferImmediatelyAvailableCredentials: true
    //optional perameter for integrate google signing
        googleClientId: googleClientId 
    );

}
```
> Note: If the call to Credential Manager was triggered by an explicit user action, credential will be available immediately after saving if `true`(by default) or user will not able to get credential as soon as possible(May throw error if fetched just after saving credentials)

> If you want to encrypted credential manager [encrypted_credential_manager](#encrypt-your-credentials)
- Save credentials in credential manager

```
await credentialManager.savePasswordCredentials(
          PasswordCredential(username: username, password: password));
```
- Save Google credentials in credential manager

```
final GoogleIdTokenCredential? gCredential= await credentialManager.saveGoogleCredential();

```
<img src="https://i.ibb.co/X2YVw1B/IMG-20240128-164412.jpg" alt="Get Google/Password Saved Credential " width="300" height="300">
<img src="https://i.ibb.co/HgYkBgM/IMG-20240128-164512.jpg" alt="Get Google/Password Saved Credential Success" width="300" height="300">







> Note: It is not necessary to be username and password,you can send any string you want to store but you will get credentials as `PasswordCredential` which has `username` and `password` properties.

- Get the saved  credentials

```
 Credentials credential =await credentialManager.getPasswordCredentials();
```
<img src="https://i.ibb.co/fCs0kqV/5.jpg" alt="Get Credential 1" width="300" height="300">
<img src="https://i.ibb.co/KNkgtdV/IMG-20240128-164347.jpg" alt="Google Save Credential 1" width="300" height="300">

## Encrypt Your credentials
To ensure the security of credentials, we will encrypt the password field using the [encrypt](https://pub.dev/packages/encrypt) library and store the encrypted information in a credential manager. This approach reduces the risk of exposing sensitive information, such as passwords.

**To encrypt value and decrypt the encrypted data, you need 128 bit-key of `secret_key` and 128 bit-key of `iv_key`.**

> you need to provide a 16 character string as a key. 

```

  final secretKey = "<Secret-key>"; // Use a secure key here for example "1234567812345678"
  final ivKey = "<16-bit-iv-key>" //for e.g: "xfpkDQJXIfb3mcnb"; 
```


- Save encrypted credentials
```
await credentialManager.saveEncryptedCredentials(
        credential: PasswordCredential(username: username, password: password),
        secretKey: secretKey,
        ivKey: ivKey
      );
```
- Get encrypted credentials and decrypted the sensitive data

```
 Credentials credential = await credentialManager
          .getEncryptedCredentials(secretKey: secretKey, ivKey: ivKey);
```




## Properties and Methods: Read here about [properties and methods](./methods.md)

## Error handling: 
More info about error handing codes and messages: [Error Handler](./errors.md)



## Upcoming
- iOS Support

## Contributing
- Fork it
- Create your feature branch (git checkout -b my-new-feature)
- Commit your changes (git commit -am 'Add some feature')
- Push to the branch (git push origin my-new-feature)
- Create new Pull Request
- If you have any questions, please open an issue.
- If you found a bug, please open an issue.
- If you have a feature request, please open an issue.
- If you want to contribute, please submit a pull request.
- If you use this package, please add a star on GitHub.
- If you use this package, please tweet about it.
- If you use this package, please mention it in a blog post.







