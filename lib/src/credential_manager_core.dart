import 'package:credential_manager/credential_manager.dart';

/// A class that provides a high-level interface for interacting with the Credential Manager.
class CredentialManager {
  /// Gets the platform version.
  ///
  /// Returns a [Future] that completes with a [String] representing the platform version.
  Future<String?> getPlatformVersion() {
    return CredentialManagerPlatform.instance.getPlatformVersion();
  }

  /// Initializes the Credential Manager.
  ///
  /// [preferImmediatelyAvailableCredentials] - Whether to prefer only locally-available credentials.
  ///
  /// Returns a [Future] that completes when initialization is successful.
  Future<void> init({
    required bool preferImmediatelyAvailableCredentials,
    String? googleClientId,
  }) async {
    return CredentialManagerPlatform.instance
        .init(preferImmediatelyAvailableCredentials, googleClientId);
  }

  /// Saves plain text password credentials.
  ///
  /// [credential] - The password credentials to be saved.
  ///
  /// Returns a [Future] that completes when the credentials are successfully saved.
  Future<void> savePasswordCredentials(PasswordCredential credential) async {
    return CredentialManagerPlatform.instance
        .savePasswordCredentials(credential);
  }

  /// Save credentials using passkey
  ///
  /// [CredentialCreationOptions] - The credentials to be saved.
  /// Returns a [Future] that completes when the credentials are successfully saved.
  Future<PublicKeyCredential> savePasskeyCredentials(
      {required CredentialCreationOptions request}) async {
    return CredentialManagerPlatform.instance
        .savePasskeyCredentials(request: request);
  }

  /// Gets plain text password credentials.
  ///
  /// Returns a [Future] that completes with [PasswordCredential] representing the retrieved credentials.
  Future<Credentials> getPasswordCredentials(
      {CredentialLoginOptions? passKeyOption}) async {
    return CredentialManagerPlatform.instance
        .getPasswordCredentials(passKeyOption: passKeyOption);
  }

  /// Saves encrypted password credentials.
  ///
  /// [credential] - The password credentials to be saved.
  /// [secretKey] - The secret key used for encryption.
  ///
  /// Returns a [Future] that completes when the encrypted credentials are successfully saved.
  Future<void> saveEncryptedCredentials({
    required PasswordCredential credential,
    required String secretKey,
    required String ivKey,
  }) {
    return CredentialManagerPlatform.instance.saveEncryptedCredentials(
        credential: credential, secretKey: secretKey, ivKey: ivKey);
  }

  /// Gets encrypted password credentials.
  ///
  /// [secretKey] - The secret key used for decryption.
  ///
  /// Returns a [Future] that completes with [PasswordCredential] representing the decrypted credentials.
  Future<Credentials> getEncryptedCredentials(
      {required String secretKey,
      required String ivKey,
      CredentialLoginOptions? passKeyOption}) {
    return CredentialManagerPlatform.instance.getEncryptedCredentials(
      secretKey: secretKey,
      ivKey: ivKey,
      passKeyOption: passKeyOption,
    );
  }

  /// Returns a [Future] that completes when the credentials are successfully saved.
  Future<GoogleIdTokenCredential?> saveGoogleCredential(
      {bool useButtonFlow = false}) async {
    return CredentialManagerPlatform.instance
        .saveGoogleCredential(useButtonFlow);
  }

  //Logout
  Future<void> logout() async {
    return CredentialManagerPlatform.instance.logout();
  }

  /// Checks if the Credential Manager is supported on the current platform.
  bool get isSupportedPlatform => Platform.isAndroid;
}
