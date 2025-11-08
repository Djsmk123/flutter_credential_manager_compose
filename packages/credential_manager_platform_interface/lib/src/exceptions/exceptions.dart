/// Exception class representing errors related to credential operations.
///
/// ```dart
///   code   message
///    101   Initialization failure
///    102   Plugin exception
///    103   Not implemented
///
///    201   Login cancelled
///    202   No credentials found
///    203   Mismatched credentials
///    204   Login failed
///    205   Temporarily blocked (due to too many canceled sign-in prompts)
///
///    301   Save Credentials cancelled
///    302   Create Credentials failed
///
///    401   Encryption failed
///    402   Decryption failed
///
///    501   Received an invalid google id token response
///    502   Invalid request
///    503   Google client is not initialized yet
///    504   Credentials operation failed
///    505   Google credential decode error
///
///    601   User can cancel passkey operation
///    602   Passkey creation failed
///    603   Passkey failed to fetch
/// ```
class CredentialException implements Exception {
  /// A numeric code identifying the specific error.
  final int code;

  /// A human-readable message describing the error.
  final String message;

  /// Additional details or context about the error.
  final dynamic details;

  /// Creates a [CredentialException] instance with the specified [code], [message], and [details].
  CredentialException({
    required this.code,
    required this.message,
    required this.details,
  });
}
