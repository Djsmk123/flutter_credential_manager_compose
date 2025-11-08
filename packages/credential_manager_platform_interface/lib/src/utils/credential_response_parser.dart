import 'dart:convert';

import '../exceptions/exceptions.dart';
import '../models/credentials.dart';
import '../models/google_user_model.dart';
import '../models/passkey/pass_key_response_model_sucess.dart';
import '../models/password_credentials.dart';

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
          message: 'Login failed',
          details: 'Expected Credential Type not found in native platform',
        );
    }
  }
}

