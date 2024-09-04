# Error Handling

When an exception occurs, a `CredentialException` is thrown. This exception contains two main fields:
- `int code`: A numeric identifier for the error
- `String message`: A descriptive message about the error

## Error Codes and Descriptions

| Code | Message | Description |
|------|---------|-------------|
| 101 | Initialization failure | The initialization process encountered an error. |
| 102 | Plugin exception | An exception occurred within the plugin. |
| 103 | Not implemented | The requested functionality is not implemented. |
| 201 | Login cancelled | The login process was cancelled by the user. |
| 202 | No credentials found | No valid credentials were found for authentication. |
| 203 | Mismatched credentials | The provided credentials do not match the expected format. |
| 204 | Login failed | The login attempt was unsuccessful. |
| 205 | Temporarily blocked | The user is temporarily blocked due to too many canceled sign-in prompts. |
| 301 | Save Credentials cancelled | The process of saving credentials was cancelled by the user. |
| 302 | Create Credentials failed | Failed to create new credentials. |
| 401 | Encryption failed | Failed to encrypt the value. |
| 402 | Decryption failed | Failed to decrypt the value. |
| 501 | Invalid Google ID token response | Received an invalid response from Custom Credentials. |
| 502 | Invalid request | An invalid request was made while saving Google credentials. |
| 503 | Google client not initialized | The Google Web token ID is invalid or missing. |
| 504 | Credentials operation failed | The operation failed due to an unspecified error. |
| 505 | Google credential decode error | Error occurred while decoding the Google credential. |
| 601 | Passkey operation cancelled | The user cancelled the passkey operation. |
| 602 | Passkey creation failed | Failed to create a new passkey. |
| 603 | Passkey fetch failed | Failed to fetch the passkey with the provided parameters. |
| 701 | Logout failed | An error occurred while calling `clearCredentialState()` on Android. |

## Handling Exceptions

When using the Credential Manager, it's recommended to wrap operations in a try-catch block to handle potential exceptions:

```
dart
try {
  // Credential Manager operation
  await credentialManager.someOperation();
} on CredentialException catch (e) {
  print('CredentialException: [${e.code}] ${e.message}');
  // Handle the specific credential error
} catch (e) {
  print('Unexpected error: $e');
  // Handle other unexpected errors
}
```


This structure allows you to handle specific `CredentialException` errors based on their code or message, and also catch any other unexpected errors that might occur.