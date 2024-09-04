# Integrate Passkey

## Prerequisites
- An Android app with a unique package name.
- A website (sign-in domain) that your app interacts with for authentication.

## Steps:

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

## Create Passkey 

Use the following code to save passkey credentials:

```
dart
final res = await credentialManager.savePasskeyCredentials(
  request: CredentialCreationOptions(
    challenge: EncryptData.getEncodedChallenge(),
    rp: RelyingParty(
      name: "CredMan App Test",
      id: "<domain.com>"
    ),
    user: User(
      id: EncryptData.getEncodedUserId(),
      name: "<username>",
      displayName: "<username>"
    ),
    pubKeyCredParams: [
      PublicKeyCredentialParameters(type: "public-key", alg: -7),
      PublicKeyCredentialParameters(type: "public-key", alg: -257)
    ],
    timeout: 1800000,
    attestation: "none",
    excludeCredentials: [
      ExcludeCredential(id: "ghi789", type: "public-key"),
      ExcludeCredential(id: "jkl012", type: "public-key")
    ],
    authenticatorSelection: AuthenticatorSelectionCriteria(
      authenticatorAttachment: "platform",
      residentKey: "required"
    )
  )
);
```


> Note: This payload should be received from backend services.

[Read more about the payload here](https://github.com/android/identity-samples/tree/main/CredentialManager)

## Fetch Generated Passkey:

1. Create a pass request object:
   ```dart
   CredentialLoginOptions? passKeyLoginOption = CredentialLoginOptions(
     challenge: "<challenge>",
     rpId: "<domain.com>",
     userVerification: "required",
   );
   ```

2. Pass this object to `getEncryptedCredentials` or `getPasswordCredentials` for fetching the passkey in the list of login options:
   ```dart
   Credentials credential = await credentialManager.getEncryptedCredentials(
     secretKey: secretKey,
     ivKey: ivKey,
     passKeyOption: passKeyLoginOption
   );
   ```

3. Check if the response is successful:
   ```dart
   bool isPublicKeyBasedCredentials = credential.publicKeyCredential != null;
   ```

## Visual Examples

Passkey Creation:

![flutter-pass-key-creation](https://i.ibb.co/XCLvkB3/Whats-App-Image-2024-06-02-at-21-46-17.jpg)

Passkey Success:

![flutter-pass-key-success](https://i.ibb.co/0JKNDff/Whats-App-Image-2024-06-02-at-21-46-17-1.jpg)