## Error Handling 
if any exception occurs it throws `CredentialException` which has field  `int code` and `String message`.
| Code | Message                                                    | Description                                                    |
|------|------------------------------------------------------------|----------------------------------------------------------------|
| 101  | Initialization failure                                     | The initialization process encountered an error.               |
| 102  | Plugin exception                                           | An exception occurred within the plugin.                       |
| 103  | Not implemented                                            | The functionality is not implemented.                         |
| 201  | Login cancelled                                            | The login process was cancelled by the user.                  |
| 202  | No credentials found                                       | No valid credentials were found for authentication.           |
| 203  | Mismatched credentials                                     | The provided credentials do not match the expected format.    |
| 204  | Login failed                                               | The login attempt was unsuccessful.                           |
| 205  | Temporarily blocked (due to too many canceled sign-in prompts) | The user is temporarily blocked due to too many canceled sign-in prompts. |
| 301  | Save Credentials cancelled                                 | The process of saving credentials was cancelled by the user.  |
| 302  | Create Credentials failed                                  | Failed to create new credentials.                             |
| 401  | Encryption failed                                          | Failed to encrypt value.                                      |
| 402  | Decryption failed                                          | Failed to decrypt value.                                      |
| 501  | Received an invalid google id token response               | Bad response received from Custom Credentials.                |
| 502  | Invalid request                                            | Invalid request has been made while saving Google credentials.|
| 503  | Google client is not initialized yet                       | Google Web token Id is invalid or not missing.                |
| 504  | Credentials operation failed                               | Operation failed, something went wrong.                       |
| 505  | Google credential decode error                             | Error decoding Google credential.                             |
| 601  | User can cancel passkey operation                          | The user can cancel the passkey operation.                    |
| 602  | Passkey creation failed                                    | Failed to create passkey.                                     |
| 603  | Passkey failed to fetch with these                         | Passkey failed to fetch with these.                           |