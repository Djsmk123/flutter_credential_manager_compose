import 'dart:convert';

import 'package:credential_manager/credential_manager.dart';
import 'package:credential_manager/src/utils/parser.dart';
import 'package:flutter/services.dart';

/// Enum representing the different types of credentials.
enum CredentialType {
  passwordCredentials,
  publicKeyCredentials,
  googleIdTokenCredentials
}

/// A class that handles credential management using method channels.
class MethodChannelCredentialManager extends CredentialManagerPlatform {
  /// Method channel used to communicate with the native platform.
  final methodChannel = const MethodChannel('credential_manager');

  /// Fetches the platform version.
  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// Initializes the credential manager with optional preferences.
  @override
  Future<void> init(
    bool preferImmediatelyAvailableCredentials,
    String? googleClientId,
  ) async {
    final res = await methodChannel.invokeMethod<String>(
      "init",
      {
        'prefer_immediately_available_credentials':
            preferImmediatelyAvailableCredentials,
        'google_client_id': googleClientId,
      },
    );

    if (res != null && res == "Initialization successful") {
      return;
    }

    throw CredentialException(
      code: 101,
      message: "Initialization failure",
      details: null,
    );
  }

  /// Saves password credentials to the native platform.
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
        code: 302,
        message: "Create Credentials failed",
        details: null,
      );
    } on PlatformException catch (e) {
      throw handlePlatformException(e, CredentialType.passwordCredentials);
    }
  }

  /// Retrieves credentials from the native platform.
  @override
  Future<Credentials> getCredentials({
    CredentialLoginOptions? passKeyOption,
    FetchOptionsAndroid? fetchOptions,
  }) async {
    CredentialType credentialType = CredentialType.passwordCredentials;
    try {
      String methodName = "get_password_credentials";
      var methodParams = {};
      bool isIos = Platform.isIOS;

      if (passKeyOption != null) {
        methodParams = isIos
            ? {"passKeyOption": passKeyOption.toJson()}
            : {"passKeyOption": jsonEncode(passKeyOption.toJson())};
      }

      if (isIos) {
        methodName = "get_passkey_credentials";
      } else if (Platform.isAndroid) {
        fetchOptions ??= FetchOptionsAndroid.all();
        methodParams
            .addAll({"fetchOptions": jsonEncode(fetchOptions.toJson())});
      }

      final res = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        methodName,
        methodParams,
      );

      if (res != null) {
        var data = jsonDecode(jsonEncode(res));
        switch (data['type']) {
          case 'PasswordCredentials':
            return Credentials(
                passwordCredential: PasswordCredential.fromJson(data['data']));
          case 'PublicKeyCredentials':
            return Credentials(
                publicKeyCredential:
                    PublicKeyCredential.fromJson(jsonDecode(data['data'])));
          case 'GoogleIdTokenCredentials':
            return Credentials(
                googleIdTokenCredential:
                    GoogleIdTokenCredential.fromJson(data['data']));
          default:
            throw CredentialException(
              code: 204,
              message: "Login failed ",
              details: "Expected Credential Type not found in native platform",
            );
        }
      }

      throw CredentialException(
        code: 204,
        message: "Login failed",
        details: "Expected a response from the native platform but got null",
      );
    } on PlatformException catch (e) {
      throw handlePlatformException(e, credentialType);
    }
  }

  /// Saves Google ID token credential.
  @override
  Future<GoogleIdTokenCredential?> saveGoogleCredential(
      bool useButtonFlow) async {
    try {
      final res = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'save_google_credential',
        {"useButtonFlow": useButtonFlow},
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
      throw handlePlatformException(e, CredentialType.googleIdTokenCredentials);
    }
  }

  /// Handles PlatformException and returns appropriate CredentialException based on error codes.
  ///
  /// This function maps error codes from the PlatformException to human-readable messages and returns
  /// a CredentialException. It covers various scenarios such as initialization failures, login issues,
  /// credential saving errors, encryption/decryption failures, and more.
  ///
  /// [e] - The PlatformException thrown.
  /// [type] - The type of credential being used.
  ///
  /// Returns a CredentialException with an appropriate error code and message.
  CredentialException handlePlatformException(
      PlatformException e, CredentialType type) {
    switch (e.code) {
      case "101":
        return CredentialException(
          code: 101,
          message: "Initialization failure",
          details: e.details,
        );
      case "102":
        return CredentialException(
          code: 102,
          message: "Plugin exception",
          details: e.details,
        );
      case "103":
        return CredentialException(
          code: 103,
          message: "Not implemented",
          details: e.details,
        );
      case "201":
        return CredentialException(
          code: 201,
          message: type == CredentialType.googleIdTokenCredentials
              ? "Login with Google cancelled"
              : "Login cancelled",
          details: e.details,
        );
      case "202":
        if (e.details?.toString().contains('[28436]') == true) {
          return CredentialException(
            code: 205,
            message: "Temporarily blocked",
            details: e.details,
          );
        } else {
          return CredentialException(
            code: 202,
            message: type == CredentialType.googleIdTokenCredentials
                ? "No Google credentials found"
                : "No credentials found",
            details: e.details,
          );
        }
      case "203":
        return CredentialException(
          code: 203,
          message: type == CredentialType.googleIdTokenCredentials
              ? "Mismatched Google credentials"
              : "Mismatched credentials",
          details: e.details,
        );
      case "204":
        return CredentialException(
          code: 204,
          message: "Login failed",
          details: e.details,
        );
      case "301":
        return CredentialException(
          code: 301,
          message: type == CredentialType.googleIdTokenCredentials
              ? "Save Google Credentials cancelled"
              : "Save Credentials cancelled",
          details: e.details,
        );
      case "302":
        return CredentialException(
          code: 302,
          message: "Create Credentials failed",
          details: e.details,
        );
      case "401":
        return CredentialException(
          code: 401,
          message: "Encryption failed",
          details: e.details,
        );
      case "402":
        return CredentialException(
          code: 402,
          message: "Decryption failed",
          details: e.details,
        );
      case "501":
        return CredentialException(
          code: 501,
          message: "Received an invalid Google ID token response",
          details: e.details,
        );
      case "502":
        return CredentialException(
          code: 502,
          message: "Invalid request",
          details: e.details,
        );
      case "503":
        return CredentialException(
          code: 503,
          message: "Google client is not initialized yet",
          details: e.details,
        );
      case "504":
        return CredentialException(
          code: 504,
          message: "Credentials operation failed",
          details: e.details,
        );
      case "505":
        return CredentialException(
          code: 505,
          message: "Google credential decode error",
          details: e.details,
        );
      case "601":
        return CredentialException(
          code: 601,
          message: "User cancelled passkey operation",
          details: e.details,
        );
      case "602":
        return CredentialException(
          code: 602,
          message: "Passkey creation failed",
          details: e.details,
        );
      case "603":
        return CredentialException(
          code: 603,
          message: "Passkey failed to fetch",
          details: e.details,
        );
      default:
        return CredentialException(
          code: 504,
          message: e.message ?? "Credentials operation failed",
          details: e.details,
        );
    }
  }

  /// Saves passkey credentials to the native platform.
  @override
  Future<PublicKeyCredential> savePasskeyCredentials({
    required CredentialCreationOptions request,
  }) async {
    try {
      final res = await methodChannel.invokeMethod<String>(
        'save_public_key_credential',
        {"requestJson": jsonEncode(request.toJson())},
      );

      if (res != null) {
        var data = res.toString();
        final credential = PublicKeyCredential.fromJson(jsonDecode(data));
        if (Platform.isIOS) {
          final authData = AttestationParser.parseAttestationObject(
              credential.response!.attestationObject!);
          return credential.copyWith(
            response: credential.response?.copyWith(
              publicKey: authData.$2,
              authenticatorData: authData.$1,
            ),
          );
        }
        return credential;
      }

      throw CredentialException(
        code: 302,
        message: "Create Credentials failed",
        details: null,
      );
    } on PlatformException catch (e) {
      throw handlePlatformException(e, CredentialType.publicKeyCredentials);
    }
  }

  /// Logs out the user.
  @override
  Future<void> logout() async {
    final res = await methodChannel.invokeMethod<String>('logout');
    if (res != null && res == "Logout successful") {
      return;
    }
    throw CredentialException(
      code: 504,
      message: "Logout failed",
      details: null,
    );
  }
}
