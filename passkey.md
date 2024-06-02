# Integrate Passkey

## Prerequisites
- An Android app with a unique package name.
- A website (sign-in domain) that your app interacts with for authentication.

## Steps:

- Create a Digital Asset Links JSON file (assetlinks.json):
  - Open a text editor and create a new file named assetlinks.json.
  - Paste the following content into the file, replacing the placeholders with your specific information:

```
[
  {
    "relation" : [
      "delegate_permission/common.handle_all_urls",
      "delegate_permission/common.get_login_creds"
    ],
    "target" : {
      "namespace" : "android_app",
      "package_name" : "com.example.android",
      "sha256_cert_fingerprints" : [
        SHA_HEX_VALUE
      ]
    }
  }
] 
```

- Host the Digital Assets Link JSON file at the following location on the sign-in domain:

`https://domain[:optional_port]/.well-known/assetlinks.json`

- Ensure that your host permits Google to retrieve your Digital Asset Link file. If you have a robots.txt file, it must allow the Googlebot agent to retrieve /.well-known/assetlinks.json. Most sites can allow any automated agent to retrieve files in the /.well-known/ path so that other services can access the metadata in those files:

```
User-agent: *
Allow: /.well-known/
```

## Create Passkey 


```
 // Save encrypted credentials and show a snackbar on success
      final res = await credentialManager.savePasskeyCredentials(
          request: CredentialCreationOptions.fromJson({
        "challenge": EncryptData.getEncodedChallenge(),
        "rp": {
          "name": "CredMan App Test",
          "id": <domain.com>
        },
        "user": {
          "id": EncryptData.getEncodedUserId(),
          "name": <username>,
          "displayName": <username>,
        },
        "pubKeyCredParams": [
          {"type": "public-key", "alg": -7},
          {"type": "public-key", "alg": -257}
        ],
        "timeout": 1800000,
        "attestation": "none",
        "excludeCredentials": [
          {"id": "ghi789", "type": "public-key"},
          {"id": "jkl012", "type": "public-key"}
        ],
        "authenticatorSelection": {
          "authenticatorAttachment": "platform",
          "residentKey": "required"
        }
      }));
```

> Note: This payload should receive from backend services

[Read more about payload here](https://github.com/android/identity-samples/tree/main/CredentialManager)


## Fetch generated Passkey:
- Create pass request object
```
CredentialLoginOptions? passKeyLoginOption = CredentialLoginOptions(
    challenge: "<>"
    rpId: "<domain.com>"
    userVerification: "required",
  );
```
- pass this object to `getEncryptedCredentials` or `getPasswordCredentials` for fetching pass key in list of login options.


```
 Credentials credential = await credentialManager.getEncryptedCredentials(
          secretKey: secretKey,
          ivKey: ivKey,
          passKeyOption: passKeyLoginOption);
```

- Check if getting response is success or failure:
```
bool isPublicKeyBasedCredentials = credential.publicKeyCredential != null;
 ```
![flutter-pass-key-creation](https://i.ibb.co/XCLvkB3/Whats-App-Image-2024-06-02-at-21-46-17.jpg)

![flutter-pass-key-success](https://i.ibb.co/0JKNDff/Whats-App-Image-2024-06-02-at-21-46-17-1.jpg)


