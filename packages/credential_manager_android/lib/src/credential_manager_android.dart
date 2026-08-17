import 'dart:convert';

import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:flutter/services.dart';

/// Android implementation of Credential Manager using method channels.
///
/// If you need to augment the native side (for example to support OEM flows or
/// proprietary credential providers) start here—each public override maps to a
/// Kotlin entry-point under `packages/credential_manager_android/android`.
/// The docs' “Extensions” section explains how to keep those edits in sync with
/// the shared platform interface.
class CredentialManagerAndroid extends CredentialManagerPlatform {
  /// Method channel used to communicate with the native Android platform.
  final MethodChannel methodChannel;

  /// Creates a [CredentialManagerAndroid] instance. Provide a custom [channel]
  /// when writing tests or wrapping this plugin inside another Android binary;
  /// the default channel name is `credential_manager`.
  CredentialManagerAndroid({MethodChannel? channel})
      : methodChannel = channel ?? const MethodChannel('credential_manager');

  /// Whether Google Play Services is available on the device.
  /// Defaults to true and is updated during initialization.
  bool _isGmsAvailable = true;

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> init(bool preferImmediatelyAvailableCredentials, String? googleClientId) async {
    final res = await methodChannel.invokeMethod<Map<Object?, Object?>>("init", {
      'prefer_immediately_available_credentials': preferImmediatelyAvailableCredentials,
      'google_client_id': googleClientId,
    });

    if (res != null && res['message'] == "Initialization successful") {
      _isGmsAvailable = res['isGmsAvailable'] as bool? ?? true;
      return;
    }

    throw CredentialException(code: 101, message: "Initialization failure", details: null);
  }

  @override
  Future<void> savePasswordCredentials(PasswordCredential credential) async {
    try {
      final res = await methodChannel.invokeMethod<String>('save_password_credentials', credential.toJson());

      if (res != null && res == "Credentials saved") {
        return;
      }

      throw CredentialException(code: 302, message: "Create Credentials failed", details: null);
    } on PlatformException catch (e) {
      throw PlatformExceptionHandler.handlePlatformException(e, CredentialType.passwordCredentials);
    }
  }

  @override
  Future<Credentials> getCredentials({CredentialLoginOptions? passKeyOption, FetchOptionsAndroid? fetchOptions}) async {
    CredentialType credentialType = CredentialType.passwordCredentials;
    try {
      final res = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'get_password_credentials',
        _credentialRequestParameters(passKeyOption: passKeyOption, fetchOptions: fetchOptions),
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
      // Return empty Credentials when no credentials are found (code 202)
      // This is a normal expected state, not an error
      if (e.code == '202') {
        return Credentials();
      }
      throw PlatformExceptionHandler.handlePlatformException(e, credentialType);
    }
  }

  @override
  Future<bool> prepareCredentials({CredentialLoginOptions? passKeyOption, FetchOptionsAndroid? fetchOptions}) async {
    try {
      final prepared = await methodChannel.invokeMethod<bool>(
        'prepare_credentials',
        _credentialRequestParameters(passKeyOption: passKeyOption, fetchOptions: fetchOptions),
      );
      return prepared ?? false;
    } on PlatformException catch (e) {
      throw PlatformExceptionHandler.handlePlatformException(e, CredentialType.passwordCredentials);
    }
  }

  Map<String, String> _credentialRequestParameters({
    CredentialLoginOptions? passKeyOption,
    FetchOptionsAndroid? fetchOptions,
  }) {
    final parameters = <String, String>{};
    if (passKeyOption != null) {
      parameters['passKeyOption'] = jsonEncode(passKeyOption.toJson());
    }

    parameters['fetchOptions'] = jsonEncode((fetchOptions ?? FetchOptionsAndroid.all()).toJson());
    return parameters;
  }

  @override
  Future<GoogleIdTokenCredential?> saveGoogleCredential(bool useButtonFlow, {String? nonce}) async {
    try {
      final res = await methodChannel.invokeMethod<Map<Object?, Object?>>('save_google_credential', {
        "useButtonFlow": useButtonFlow,
        "nonce": nonce,
      });

      if (res == null) {
        throw CredentialException(
          code: 505,
          message: "Google credential decode error",
          details: "Null response received",
        );
      }
      return GoogleIdTokenCredential.fromJson(jsonDecode(jsonEncode(res)));
    } on PlatformException catch (e) {
      throw PlatformExceptionHandler.handlePlatformException(e, CredentialType.googleIdTokenCredentials);
    }
  }

  @override
  Future<PublicKeyCredential> savePasskeyCredentials({required CredentialCreationOptions request}) async {
    try {
      final res = await methodChannel.invokeMethod<String>('save_public_key_credential', {
        "requestJson": jsonEncode(request.toJson()),
      });

      if (res != null) {
        var data = res.toString();
        final credential = PublicKeyCredential.fromJson(jsonDecode(data));
        return credential;
      }

      throw CredentialException(code: 302, message: "Create Credentials failed", details: null);
    } on PlatformException catch (e) {
      throw PlatformExceptionHandler.handlePlatformException(e, CredentialType.publicKeyCredentials);
    }
  }

  @override
  Future<void> logout() async {
    final res = await methodChannel.invokeMethod<String>('logout');
    if (res != null && res == "Logout successful") {
      return;
    }
    throw CredentialException(code: 504, message: "Logout failed", details: null);
  }

  @override
  bool get isGmsAvailable {
    return _isGmsAvailable;
  }
}
