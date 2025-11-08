import 'dart:convert';

import 'package:credential_manager/credential_manager.dart';

/// Utility class for parsing credential responses from platform channels.
class CredentialResponseParser {
  /// Parses a credential response map and returns the appropriate [Credentials] object.
  static Credentials parseCredentialResponse(Map<Object?, Object?> response) {
    final data = jsonDecode(jsonEncode(response));
    
    switch (data['type']) {
      case 'PasswordCredentials':
        return Credentials(
          passwordCredential: PasswordCredential.fromJson(data['data']),
        );
      case 'PublicKeyCredentials':
        return Credentials(
          publicKeyCredential:
              PublicKeyCredential.fromJson(jsonDecode(data['data'])),
        );
      case 'GoogleIdTokenCredentials':
        return Credentials(
          googleIdTokenCredential:
              GoogleIdTokenCredential.fromJson(data['data']),
        );
      default:
        throw CredentialException(
          code: 204,
          message: "Login failed",
          details: "Expected Credential Type not found in native platform",
        );
    }
  }
}

