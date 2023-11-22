import 'dart:convert';

import 'package:credential_manager/src/Models/password_credentials.dart';
import 'package:credential_manager/src/exceptions/exceptions.dart';
import 'package:credential_manager/src/utils/encryption.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'credential_manager_platform_interface.dart';

/// An implementation of [CredentialManagerPlatform] that uses method channels.
class MethodChannelCredentialManager extends CredentialManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('credential_manager');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// Initializes the Credential Manager.
  ///
  /// [preferImmediatelyAvailableCredentials] - Whether to prefer only locally-available credentials.
  ///
  /// Throws [CredentialException] if initialization fails.
  @override
  Future<void> init(bool preferImmediatelyAvailableCredentials) async {
    final res = await methodChannel.invokeMethod<String>("init", {
      'prefer_immediately_available_credentials':
          preferImmediatelyAvailableCredentials,
    });

    if (res != null && res == "Initialization successful") {
      return;
    }

    throw CredentialException(
        code: 101, message: "Initialization failure", details: null);
  }

  /// Saves password credentials as plain text.
  ///
  /// [credential] - The password credentials to be saved.
  ///
  /// Throws [CredentialException] if the credential creation fails.
  @override
  Future<void> savePasswordCredentials(PasswordCredential credential) async {
    try {
      final res = await methodChannel.invokeMethod<String>(
        'save_password_credentials',
        credential.toJson(),
      );

      if (res != null && res == "Credentials saved") {
        return;
      }

      throw CredentialException(
          code: 302, message: "Create Credentials failed", details: null);
    } on PlatformException catch (e) {
      switch (e.code) {
        case "301":
          throw CredentialException(
              code: 301,
              message: "Save Credentials cancelled",
              details: e.details);
        default:
          throw CredentialException(
              code: 302,
              message: e.message ?? "Credentials save failed",
              details: e.details);
      }
    }
  }

  /// Gets plain text credentials.
  ///
  /// Throws [CredentialException] if the login fails.
  @override
  Future<PasswordCredential> getPasswordCredentials() async {
    try {
      final res = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'get_password_credentials',
      );

      if (res != null) {
        PasswordCredential credentials =
            PasswordCredential.fromJson(jsonDecode(jsonEncode(res)));
        return credentials;
      }

      throw CredentialException(
          code: 204, message: "Login failed", details: null);
    } on PlatformException catch (e) {
      switch (e.code) {
        case "201":
          throw CredentialException(
              code: 201, message: "Login cancelled", details: e.details);
        case "202":
          throw CredentialException(
              code: 202, message: "No credentials found", details: e.details);
        case "203":
          throw CredentialException(
              code: 203, message: "Mismatched credentials", details: e.details);
        default:
          throw CredentialException(
              code: 204,
              message: e.message ?? "${e.details}",
              details: e.details);
      }
    }
  }

  /// Saves encrypted credentials.
  ///
  /// [credential] - The password credentials to be saved.
  /// [secretKey] - The secret key used for encryption.
  ///
  /// Throws [CredentialException] if the credential creation fails.
  @override
  Future<void> saveEncryptedCredentials({
    required PasswordCredential credential,
    required String secretKey,
    required String ivKey,
  }) async {
    credential.password =
        EncryptData.encode(credential.password!.toString(), secretKey, ivKey);
    return savePasswordCredentials(credential);
  }

  /// Gets encrypted credentials.
  ///
  /// [secretKey] - The secret key used for decryption.
  ///
  /// Throws [CredentialException] if the login fails.
  @override
  Future<PasswordCredential> getEncryptedCredentials({
    required String secretKey,
    required String ivKey,
  }) async {
    try {
      PasswordCredential? credential = await getPasswordCredentials();
      credential.password =
          EncryptData.decode(credential.password.toString(), secretKey, ivKey);
      return credential;
    } catch (e) {
      rethrow;
    }
  }
}
