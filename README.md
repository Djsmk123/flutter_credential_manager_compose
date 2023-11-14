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
            signingConfig signingConfigs.debug
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
```
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

- initialize credential manager

```
if(credentialManager.isSupportedPlatform){
    // if supported
    await credentialManager.init(preferImmediatelyAvailableCredentials: true);

}
```
> Note: If the call to Credential Manager was triggered by an explicit user action, credential will be available immediately after saving if `true`(by default) or user will not able to get credential as soon as possible(May throw error if fetched just after saving credentials)

- Save credentials in credential manager

```
await credentialManager.savePasswordCredentials(
          PasswordCredential(username: username, password: password));
```
<img src="https://i.ibb.co/CtK7ffZ/1.jpg" alt="Save Credential 1" width="80" height="150">

<img src="https://i.ibb.co/qyGGv37/2.jpg" alt="Save Credential 2" width="80" height="150">

<img src="https://i.ibb.co/vZmbsXL/3.jpg" alt="Save Credential 3" width="80" height="150">

<img src="https://i.ibb.co/NsTFTVB/4.jpg" alt="Save Credential 4" width="80" height="150">




> Note: It is not nesscessary to be username and password,you can send any string you want to store but you will get credentials as `PasswordCredential` which has `username` and `password` properties.

- Get the saved  credentials

```
 PasswordCredential credential =await credentialManager.getPasswordCredentials();
```
![Get Credential 1](https://i.ibb.co/fCs0kqV/5.jpg)
![Get Credential 2](https://i.ibb.co/3ChSstH/6.jpg)


## Properties and Methods

| Method              | Type                      | Description                                 |
|-----------------------|---------------------------|---------------------------------------------|
| isSupportedPlatform            | boolean     | Check if targeted platform supported or not(Only Android supported) |  
| init(bool preferImmediatelyAvailableCredentials)         | Future(void)                  | To initialize credential Manager,preferImmediatelyAvailableCredentials,If the call to Credential Manager was triggered by an explicit user action, credential will be available immediately after saving if `true`(by default) or user will not able to get credential as soon as possible(May throw error if fetched just after saving credentials) |
| savePasswordCredentials(String username,String password)         | Future(void)                  | To save credentials in credential Manager|
| getPasswordCredentials()         | Future(PasswordCredential)                  | return `PasswordCredential` object which has username,password fields |

## About `PasswordCredential()`

| Field    | Type    | Description                               |
|----------|---------|-------------------------------------------|
| username | String? | User's username for authentication.       |
| password | String? | User's password for authentication.       |
|----------|---------|-------------------------------------------|
| **Constructor:**                                  |
| PasswordCredential({String? username, String? password}) | Creates a new instance of `PasswordCredential`. |
|                                                   |
| **Properties:**                                   |
| String? get username => _username;                | Retrieves the username.                        |
| set username(String? username) => _username = username; | Sets the username.                             |
| String? get password => _password;                | Retrieves the password.                        |
| set password(String? password) => _password = password; | Sets the password.                             |
|                                                   |
| **JSON Serialization/Deserialization:**           |
| PasswordCredential.fromJson(Map<String, dynamic> json) | Creates an instance from a JSON map.           |
| Map<String, dynamic> toJson()                      | Converts the instance to a JSON map.           |


## Error Handling 
if any exception occure it throws `CredentialException` which has field  `int code` and `String message`.
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


## Upcoming

- Encryption of PasswordCredential
- iOS Support
- Passkey extenstion for flowless integration with web

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







