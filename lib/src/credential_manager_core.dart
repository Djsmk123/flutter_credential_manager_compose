import 'dart:io' show Platform;

import 'package:credential_manager/src/Models/password_credentials.dart';
import 'package:credential_manager/src/channel/credential_manager_platform_interface.dart';

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
  }) async {
    return CredentialManagerPlatform.instance
        .init(preferImmediatelyAvailableCredentials);
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

  /// Gets plain text password credentials.
  ///
  /// Returns a [Future] that completes with [PasswordCredential] representing the retrieved credentials.
  Future<PasswordCredential> getPasswordCredentials() async {
    return CredentialManagerPlatform.instance.getPasswordCredentials();
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
  Future<PasswordCredential> getEncryptedCredentials({
    required String secretKey,
    required String ivKey,
  }) {
    return CredentialManagerPlatform.instance
        .getEncryptedCredentials(secretKey: secretKey, ivKey: ivKey);
  }

  /// Checks if the Credential Manager is supported on the current platform.
  bool get isSupportedPlatform => Platform.isAndroid;
}
