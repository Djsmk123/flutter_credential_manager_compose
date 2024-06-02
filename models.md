## About `Credentials()`
| Field                   | Type                        | Description                                                    |
|-------------------------|-----------------------------|----------------------------------------------------------------|
| passwordCredential      | PasswordCredential?         | Password credentials for authentication. Null if not available. |
| googleIdTokenCredential | GoogleIdTokenCredential?    | Google ID token credentials. Null if not available.            |
| publicKeyCredential    | PublicKeyCredential?        | Public key credentials for authentication. Null if not available. |

NOTE: at a time only one of them will be not null.

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

## About `PublicKeyCredentialParameters`

| Field | Type   | Description                        |
|-------|--------|------------------------------------|
| type  | String | The type of the public key credential. |
| alg   | int    | The cryptographic algorithm.       |

## About `ExcludeCredential`

| Field | Type   | Description                              |
|-------|--------|------------------------------------------|
| id    | String | The identifier of the excluded credential. |
| type  | String | The type of the excluded credential.       |

## About `AuthenticatorSelectionCriteria`

| Field                   | Type    | Description                                                          |
|-------------------------|---------|----------------------------------------------------------------------|
| authenticatorAttachment | String? | The preferred authenticator attachment modality.                     |
| requireResidentKey      | bool?   | Indicates whether the authenticator should create a resident credential. |
| residentKey             | String? | A preferred resident key.                                            |
| userVerification        | String? | Specifies whether user verification is required or preferred.        |

## About `Rp`

| Field | Type   | Description                         |
|-------|--------|-------------------------------------|
| name  | String | The name of the relying party.      |
| id    | String | The identifier of the relying party.|

## About `User`

| Field       | Type   | Description             |
|-------------|--------|-------------------------|
| id          | String | The user identifier.    |
| name        | String | The username.           |
| displayName | String | The display name.       |

## About `CredentialCreationOptions`

| Field                  | Type                                      | Description                                                    |
|------------------------|-------------------------------------------|----------------------------------------------------------------|
| challenge              | String                                    | The challenge.                                                 |
| rp                     | Rp                                        | The relying party (RP).                                        |
| user                   | User                                      | The user.                                                      |
| pubKeyCredParams       | List<PublicKeyCredentialParameters>       | The public key credential parameters.                          |
| timeout                | int                                       | The timeout.                                                   |
| attestation            | String                                    | The attestation.                                               |
| excludeCredentials     | List<ExcludeCredential>                   | The excluded credentials.                                       |
| authenticatorSelection | AuthenticatorSelectionCriteria            | The authenticator selection criteria.                          |

### Note

- `PublicKeyCredentialParameters` includes parameters such as type and cryptographic algorithm.
- `ExcludeCredential` details excluded credentials by their identifier and type.
- `AuthenticatorSelectionCriteria` defines criteria for selecting an authenticator, including preferences for attachment, resident keys, and user verification.
- `Rp` specifies the relying party with a name and identifier.
- `User` defines a user with an identifier, username, and display name.
- `CredentialCreationOptions` encapsulates all options needed to create a credential, including the challenge, relying party details, user details, public key credential parameters, timeout, attestation preference, excluded credentials, and authenticator selection criteria.

## About `CredentialLoginOptions`

| Field            | Type   | Description                                                                                     |
|------------------|--------|-------------------------------------------------------------------------------------------------|
| challenge        | String | A challenge that the authenticator must complete.                                               |
| rpId             | String | The relying party identifier.                                                                   |
| userVerification | String | Specifies whether user verification is required or preferred.                                   |
| timeout          | int    | The time, in milliseconds, allowed for the user to complete the operation. Defaults to 30 minutes (1800000 milliseconds). |

### Note

- `challenge`: A challenge that the authenticator must complete.
- `rpId`: The relying party identifier.
- `userVerification`: Specifies whether user verification is required or preferred.
- `timeout`: The time, in milliseconds, allowed for the user to complete the operation. Defaults to 30 minutes (1800000 milliseconds).
