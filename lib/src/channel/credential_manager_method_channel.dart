import 'dart:convert';

import 'package:credential_manager/credential_manager.dart';
import 'package:flutter/services.dart';

class MethodChannelCredentialManager extends CredentialManagerPlatform {
  final methodChannel = const MethodChannel('credential_manager');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> init(
    bool preferImmediatelyAvailableCredentials,
    String? googleClientId,
  ) async {
    final res = await methodChannel.invokeMethod<String>("init", {
      'prefer_immediately_available_credentials':
          preferImmediatelyAvailableCredentials,
      'google_client_id': googleClientId,
    });

    if (res != null && res == "Initialization successful") {
      return;
    }

    throw CredentialException(
        code: 101, message: "Initialization failure", details: null);
  }

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
      throw (handlePlatformException(e, false));
    }
  }

  @override
  Future<Credentials> getPasswordCredentials() async {
    bool isGoogleCredentials = false;
    try {
      final res = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'get_password_credentials',
      );

      if (res != null) {
        var data = jsonDecode(jsonEncode(res));
        if (data['type'] == 'PasswordCredentials') {
          return Credentials(
              passwordCredential: PasswordCredential.fromJson(data['data']));
        } else {
          isGoogleCredentials = true;
          return Credentials(
              googleIdTokenCredential:
                  GoogleIdTokenCredential.fromJson(data['data']));
        }
      }

      throw CredentialException(
          code: 204, message: "Login failed", details: null);
    } on PlatformException catch (e) {
      throw (handlePlatformException(e, isGoogleCredentials));
    }
  }

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

  @override
  Future<Credentials> getEncryptedCredentials({
    required String secretKey,
    required String ivKey,
  }) async {
    try {
      Credentials? credential = await getPasswordCredentials();
      if (credential.passwordCredential != null) {
        var password = EncryptData.decode(
            credential.passwordCredential!.password.toString(),
            secretKey,
            ivKey);
        var passwordCredential = credential.passwordCredential;
        passwordCredential!.password = password;
        credential =
            credential.copyWith(passwordCredential: passwordCredential);
      }

      return credential;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<GoogleIdTokenCredential?> saveGoogleCredential() async {
    try {
      final res = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'save_google_credential',
      );
      if (res == null) {
        throw CredentialException(
          code: 505,
          message: "Google credential decode error",
          details: "Null response received",
        );
      }
      return GoogleIdTokenCredential.fromJson(jsonDecode(jsonEncode(res)));
    } on PlatformException catch (e) {
      throw (handlePlatformException(e, true));
    }
  }

  CredentialException handlePlatformException(
      PlatformException e, bool isGoogleCredentials) {
    switch (e.code) {
      case "301":
        return CredentialException(
            code: 301,
            message: isGoogleCredentials
                ? "Save Google Credentials cancelled"
                : "Save Credentials cancelled",
            details: e.details);
      case "201":
        return CredentialException(
            code: 201,
            message: isGoogleCredentials
                ? "Login with Google cancelled"
                : "Login cancelled",
            details: e.details);
      case "202":
        // Android returns a 202 for two separate cases:
        // 1) [28433] Cannot find a matching credential
        // 2) [28436] Caller has been temporarily blocked due to too many
        // canceled sign-in prompts.
        if (e.details?.toString().contains('[28436]') == true) {
          return CredentialException(
            code: 205,
            message: "Temporarily blocked",
            details: e.details,
          );
        } else {
          return CredentialException(
              code: 202,
              message: isGoogleCredentials
                  ? "No Google credentials found"
                  : "No credentials found",
              details: e.details);
        }
      case "203":
        return CredentialException(
            code: 203,
            message: isGoogleCredentials
                ? "Mismatched Google credentials"
                : "Mismatched credentials",
            details: e.details);
      default:
        return CredentialException(
            code: isGoogleCredentials ? 504 : 204,
            message: e.message ?? "Credentials operation failed",
            details: e.details);
    }
  }
}
