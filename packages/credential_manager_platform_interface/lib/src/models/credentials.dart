import 'google_user_model.dart';
import 'passkey/pass_key_response_model_sucess.dart';
import 'password_credentials.dart';

/// Represents a set of various types of credentials.
class Credentials {
  /// The password credential.
  final PasswordCredential? passwordCredential;

  /// The Google ID token credential.
  final GoogleIdTokenCredential? googleIdTokenCredential;

  /// The public key credential.
  final PublicKeyCredential? publicKeyCredential;

  /// Constructs a new [Credentials] instance.
  ///
  /// [passwordCredential] is the password credential.
  /// [googleIdTokenCredential] is the Google ID token credential.
  /// [publicKeyCredential] is the public key credential.
  Credentials({
    this.passwordCredential,
    this.googleIdTokenCredential,
    this.publicKeyCredential,
  });

  /// Creates a copy of this [Credentials] instance with the specified fields replaced.
  ///
  /// [passwordCredential] (optional) is the new password credential.
  /// [googleIdTokenCredential] (optional) is the new Google ID token credential.
  /// [publicKeyCredential] (optional) is the new public key credential.
  Credentials copyWith({
    PasswordCredential? passwordCredential,
    GoogleIdTokenCredential? googleIdTokenCredential,
    PublicKeyCredential? publicKeyCredential,
  }) {
    return Credentials(
      passwordCredential: passwordCredential ?? this.passwordCredential,
      googleIdTokenCredential:
          googleIdTokenCredential ?? this.googleIdTokenCredential,
      publicKeyCredential: publicKeyCredential ?? this.publicKeyCredential,
    );
  }
}

