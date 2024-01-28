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

## Setup Google Sign In (optional)
- [Google Cloud Console Set Up](https://console.cloud.google.com/)
-  Go to Google Could Console
- Create a project if you haven’t yet. 
- Find the search bar (top center) and type “Credentials” and select Credentials under “Product & Pages”. 
- Find the “Create Credentials” button and click it!
- Click on “OAuth client ID” from the pop-up window. 
- We have to select an “Application Type”.
- Add package ID and Get debug SHA-1 and release SHA-1
   - `cd android`
   - `./gradlew signInReport`
- Copy `WebClient(auto created by google)`

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
        ivKey: ivKey,
      );
```
- Get encrypted credentials and decrypted the sensitive data

```
 Credentials credential = await credentialManager
          .getEncryptedCredentials(secretKey: secretKey, ivKey: ivKey);
```




## Properties and Methods

| Method                                                                                | Type                | Description                                                                                                                                                                                                                                                                                                                                                                                                                |
|---------------------------------------------------------------------------------------|---------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| isSupportedPlatform                                                                   | boolean             | Check if targeted platform supported or not(Only Android supported)                                                                                                                                                                                                                                                                                                                                                        |  
| init(bool preferImmediatelyAvailableCredentials,googleClientId)                       | Future(void)        | To initialize credential Manager,preferImmediatelyAvailableCredentials,If the call to Credential Manager was triggered by an explicit user action, credential will be available immediately after saving if `true`(by default) or user will not able to get credential as soon as possible(May throw error if fetched just after saving credentials)<br/> googleClientId(optional) required when google sign-in is enabled |
| savePasswordCredentials(PasswordCredential credential)                                | Future(void)        | To save credentials in credential Manager                                                                                                                                                                                                                                                                                                                                                                                  |
| saveEncryptedCredentials(PasswordCredential credential,String secretKey,String ivKey) | Future(void)        | To save credentials in credential Manager with encryption                                                                                                                                                                                                                                                                                                                                                                  |
| getPasswordCredentials()                                                              | Future(Credential)  | return `Credential` object which has either `GoogleIdTokenCredential` or `PasswordCredential` at time, other would have null value.                                                                                                                                                                                                                                                                                        |
| getEncryptedCredentials(String secretKey,String ivKey)                                | Future(Credential ) | which has either `GoogleIdTokenCredential` or `PasswordCredential` at time, other would have null value. if  `PasswordCredential` is not null then password will be return as decrypted values.                                                                                                                                                                                                                            |

## About `PasswordCredential()`

| Field                                                    | Type                                            | Description                         |
|----------------------------------------------------------|-------------------------------------------------|-------------------------------------|
| username                                                 | String?                                         | User's username for authentication. |
| password                                                 | String?                                         | User's password for authentication. |
| **Constructor:**                                         |
| PasswordCredential({String? username, String? password}) | Creates a new instance of `PasswordCredential`. |
|                                                          |
| **Properties:**                                          |
| String? get username => _username;                       | Retrieves the username.                         |
| set username(String? username) => _username = username;  | Sets the username.                              |
| String? get password => _password;                       | Retrieves the password.                         |
| set password(String? password) => _password = password;  | Sets the password.                              |
|                                                          |
| **JSON Serialization/Deserialization:**                  |
| PasswordCredential.fromJson(Map<String, dynamic> json)   | Creates an instance from a JSON map.            |
| Map<String, dynamic> toJson()                            | Converts the instance to a JSON map.            |

## About `GoogleIdTokenCredential()`

| Field             | Type    | Description                         |
|-------------------|---------|-------------------------------------|
| id                | String  | Identifier for the Google account.  |
| idToken           | String  | Google ID token for authentication. |
| displayName       | String? | Display name of the user.           |
| familyName        | String? | Family name of the user.            |
| givenName         | String? | Given name of the user.             |
| phoneNumber       | String? | Phone number of the user.           |
| profilePictureUri | Uri?    | URI for the user's profile picture. |

## About `Credentials()`

| Field                       | Type                          | Description                                                     |
|-----------------------------|-------------------------------|-----------------------------------------------------------------|
| passwordCredential          | PasswordCredential?           | Password credentials for authentication. Null if not available. |
| googleIdTokenCredential     | GoogleIdTokenCredential?      | Google ID token credentials. Null if not available.             |

NOTE: at a time only one of them will be not null.





## Error Handling 
if any exception occurs it throws `CredentialException` which has field  `int code` and `String message`.
| Code | Message                    | Description                                         |
|------|----------------------------|-----------------------------------------------------|
| 101  | Initialization failure     | The initialization process encountered an error.   |
| 102  | Plugin exception           | An exception occurred within the plugin.             |
| 103  | Not implemented            | The functionality is not implemented.               |
|      |                            |                                                     |
| 201  | Login cancelled            | The login process was cancelled by the user.        |
| 202  | No credentials found       | No valid credentials were found for authentication.|
| 203  | Mismatched credentials     | The provided credentials do not match the expected format.|
| 204  | Login failed               | The login attempt was unsuccessful.                 |
|      |                            |                                                     |
| 301  | Save Credentials cancelled  | The process of saving credentials was cancelled by the user.|
| 302  | Create Credentials failed   | Failed to create new credentials.                   |
| 401  | Encryption failed   | Failed to encrypt value.                   |
| 402  | Decryption failed   | Failed to decrypt value.                   |
| 501  | Received an invalid google id token response | Bad response received from  Custom Credentials |
| 502  | Invalid request | Invalid request has been made while saving google credentials |
| 503  | Google client is not initialized yet | Google Web token Id is invalid or not missing |
| 504  | Credentials operation failed | Operation failed,something went wrong |




## Upcoming
- iOS Support
- Passkey extension for flawless integration with web

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







