import 'dart:convert';

import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';

import 'messages.g.dart';

/// Conversions between the public, hand-written models in
/// `credential_manager_platform_interface` and the Pigeon-generated `*Message`
/// classes used at the Android host-API boundary.
extension CredentialLoginOptionsRequestJson on CredentialLoginOptions {
  /// Encodes this passkey login request as the opaque JSON string the native
  /// CredentialManager passkey APIs expect.
  String toRequestJson() => jsonEncode(toJson());
}

extension CredentialCreationOptionsRequestJson on CredentialCreationOptions {
  /// Encodes this passkey creation request as the opaque JSON string the
  /// native CredentialManager passkey APIs expect.
  String toRequestJson() => jsonEncode(toJson());
}

extension GoogleIdTokenCredentialMessageMapper on GoogleIdTokenCredentialMessage {
  /// Converts the Pigeon message returned by the host API into the public
  /// [GoogleIdTokenCredential] model.
  GoogleIdTokenCredential toGoogleIdTokenCredential() {
    return GoogleIdTokenCredential(
      email: id,
      idToken: idToken,
      displayName: displayName,
      givenName: givenName,
      familyName: familyName,
      phoneNumber: phoneNumber,
      profilePictureUri: profilePictureUri != null ? Uri.parse(profilePictureUri!) : null,
    );
  }
}

extension CredentialResultMessageMapper on CredentialResultMessage {
  /// Converts the typed envelope returned by [CredentialManagerHostApi.getCredentials]
  /// into the public [Credentials] model, replacing the old
  /// `CredentialResponseParser`'s manual `Map` switch with a switch over the
  /// typed [CredentialResultType] enum.
  Credentials toCredentials() {
    switch (type) {
      case CredentialResultType.passwordCredential:
        return Credentials(
          passwordCredential: PasswordCredential(
            username: passwordCredential?.username,
            password: passwordCredential?.password,
          ),
        );
      case CredentialResultType.googleIdTokenCredential:
        final credential = googleIdTokenCredential;
        if (credential == null) {
          throw CredentialException(
            code: 204,
            message: 'Login failed',
            details: 'Expected a Google ID token credential but got none',
          );
        }
        return Credentials(googleIdTokenCredential: credential.toGoogleIdTokenCredential());
      case CredentialResultType.publicKeyCredential:
        final json = publicKeyCredentialJson;
        if (json == null) {
          throw CredentialException(
            code: 204,
            message: 'Login failed',
            details: 'Expected a public key credential but got none',
          );
        }
        return Credentials(publicKeyCredential: PublicKeyCredential.fromJson(jsonDecode(json)));
    }
  }
}
