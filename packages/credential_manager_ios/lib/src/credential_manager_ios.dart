import 'dart:convert';

import 'package:credential_manager_ios/src/utils/parser.dart';
import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:flutter/services.dart';

/// iOS implementation of Credential Manager using method channels.
///
/// This class mirrors the Swift code under `packages/credential_manager_ios/`.
/// If you extend the native plugin (e.g., to add Keychain flows or passkey
/// metadata) consult the docs' “Extensions” section so your Dart and Swift
/// changes ship together.
class CredentialManagerIos extends CredentialManagerPlatform {
  /// Method channel used to communicate with the native iOS platform.
  final MethodChannel methodChannel;

  /// Creates a [CredentialManagerIos] instance.
  ///
  /// You can optionally provide a custom [channel] (useful for testing or when
  /// embedding the plugin inside another binary). When omitted the default
  /// `credential_manager` channel is used.
  CredentialManagerIos({MethodChannel? channel}) : methodChannel = channel ?? const MethodChannel('credential_manager');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> init(
    bool preferImmediatelyAvailableCredentials,
    String? googleClientId,
  ) async {
    final res = await methodChannel.invokeMethod<String>(
      "init",
      {
        'prefer_immediately_available_credentials': preferImmediatelyAvailableCredentials,
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

  @override
  Future<void> savePasswordCredentials(PasswordCredential credential) async {
    // There is no native Swift handler for this method (only passkeys and init are wired up on
    // iOS today), so fail explicitly rather than silently reporting success without saving.
    throw CredentialException(
      code: 103,
      message: "Not implemented",
      details: "savePasswordCredentials is not supported on iOS",
    );
  }

  @override
  Future<Credentials> getCredentials({
    CredentialLoginOptions? passKeyOption,
    FetchOptionsAndroid? fetchOptions,
  }) async {
    CredentialType credentialType = CredentialType.passwordCredentials;
    try {
      String methodName = "get_password_credentials";
      var methodParams = {};

      if (passKeyOption != null) {
        methodName = "get_passkey_credentials";
        methodParams = {"passKeyOption": passKeyOption.toJson()};
      }

      final res = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        methodName,
        methodParams,
      );

      if (res != null) {
        return CredentialResponseParser.parseCredentialResponse(res);
      }

      throw CredentialException(
        code: 204,
        message: "Login failed",
        details: "Expected a response from the native platform but got null",
      );
    } on PlatformException catch (e) {
      throw PlatformExceptionHandler.handlePlatformException(e, credentialType);
    }
  }

  @override
  Future<GoogleIdTokenCredential?> saveGoogleCredential(bool useButtonFlow, {String? nonce}) async {
    // There is no native Swift handler for "save_google_credential" (CredentialManagerPlugin.handle
    // only dispatches passkey/init methods), so calling through would surface an unhandled
    // MissingPluginException. Fail explicitly instead.
    throw CredentialException(
      code: 103,
      message: "Not implemented",
      details: "saveGoogleCredential is not supported on iOS",
    );
  }

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
        // Parse iOS attestation object
        final authData = AttestationParser.parseAttestationObject(credential.response!.attestationObject!);
        return credential.copyWith(
          response: credential.response?.copyWith(
            publicKey: authData.$2,
            authenticatorData: authData.$1,
          ),
        );
      }

      throw CredentialException(
        code: 302,
        message: "Create Credentials failed",
        details: null,
      );
    } on PlatformException catch (e) {
      throw PlatformExceptionHandler.handlePlatformException(
        e,
        CredentialType.publicKeyCredentials,
      );
    }
  }

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
