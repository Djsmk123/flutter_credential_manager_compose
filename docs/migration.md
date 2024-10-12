# Migration Guide V1 to V2


- Removed Encrypted Credentials for Android, as it was using old API and not needed Credentials API are enough to handle all.
- `getPasswordCredentials` changed to `getCredentials` for both android and ios, as now it will return only `PasskeyCredential` on iOS and on Android it will return all the types of credentials that are saved and perameter passed into function.    
