import 'package:credential_manager/src/Models/google_user_model.dart';
import 'package:credential_manager/src/Models/password_credentials.dart';

class Credentials {
  final PasswordCredential? passwordCredential;
  final GoogleIdTokenCredential? googleIdTokenCredential;
  Credentials({this.passwordCredential, this.googleIdTokenCredential});
  Credentials copyWith(
      {PasswordCredential? passwordCredential,
      GoogleIdTokenCredential? googleIdTokenCredential}) {
    return Credentials(
        passwordCredential: passwordCredential ?? this.passwordCredential,
        googleIdTokenCredential:
            googleIdTokenCredential ?? this.googleIdTokenCredential);
  }
}
