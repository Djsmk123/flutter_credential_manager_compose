# Frequently Asked Questions

### What is Credential Manager?
Credential Manager is a Jetpack API that supports multiple sign-in methods, such as username and password, passkeys, and federated sign-in solutions (such as Sign-in with Google) in a single API, thus simplifying the integration for developers. It unifies the sign-in interface across authentication methods, making it clearer and easier for users to sign into apps, regardless of the method they choose.

### What is Keychain?
Keychain is a secure storage system for sensitive information, such as passwords, certificates, and encryption keys. It provides a centralized place to store and manage this information, ensuring that it is protected from unauthorized access.

### What is ASAuthorizationController?
ASAuthorizationController is a class provided by Apple for handling authentication requests and responses. It supports passkeys in iOS 16 and above.

### How do I clone the repository?
You can clone the repository using the following command:

```bash
git clone https://github.com/Djsmk123/flutter_credential_manager_compose
``` 


### How do I initialize Credential Manager?
To initialize Credential Manager, create an instance of the `CredentialManager` object and check if the platform is supported by calling the `isSupportedPlatform` property. Then, initialize the manager with the required parameters.

### How do I save password-based credentials on Android?
To save password-based credentials on Android, use the `savePasswordCredential` method of the `CredentialManager` object. Wrap the call in a try-catch block to handle any potential errors.


### How do handle errors?
You can handle errors by catching the `CredentialException` in a try-catch block.


### How do I logout?
To logout, call the `logout` method of the `CredentialManager` object. This will clear the saved credentials from the session.


### How to contribute?
We welcome contributions to improve the functionality and documentation of this package. Please see our [contributing guide](./contributing.md) for guidelines on how to submit improvements and bug fixes.

### License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.


### Contact
For questions or feedback, please contact the project maintainer:
- Website: https://smkwinner.vercel.app
