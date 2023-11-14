class CredentialException implements Exception {
  final int code;
  final String message;
  CredentialException({
    required this.code,
    required this.message,
  });
}
// Table for error

/*
  code  message
  101   initialization failure
  102   Plugin exception
  103   Not implemented

  201   Login cancelled
  202   No credentials found
  203   Mismatched credentials
  204   Login failed

  301   Save Credentials cancelled
  302   Create Credentials failed




 */
