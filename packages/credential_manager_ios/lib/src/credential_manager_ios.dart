import 'dart:convert';

import 'package:credential_manager_ios/src/messages.g.dart';
import 'package:credential_manager_ios/src/utils/parser.dart';
import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:flutter/services.dart';

/// iOS implementation of Credential Manager using a Pigeon-generated
/// type-safe host API.
///
/// This class mirrors the Swift code under `packages/credential_manager_ios/`.
/// If you extend the native plugin (e.g., to add Keychain flows or passkey
/// metadata) consult the docs' “Extensions” section so your Dart and Swift
/// changes ship together.
class CredentialManagerIos extends CredentialManagerPlatform {
  /// Pigeon-generated host API used to communicate with the native iOS platform.
  final CredentialManagerHostApi hostApi;

  /// Creates a [CredentialManagerIos] instance. Provide a custom [hostApi]
  /// when writing tests or wrapping this plugin inside another iOS binary.
  CredentialManagerIos({CredentialManagerHostApi? hostApi}) : hostApi = hostApi ?? CredentialManagerHostApi();

  @override
  Future<String?> getPlatformVersion() => hostApi.getPlatformVersion();

  @override
  Future<void> init(bool preferImmediatelyAvailableCredentials, String? googleClientId) async {
    try {
      await hostApi.initialize(preferImmediatelyAvailableCredentials, googleClientId);
    } on PlatformException catch (e) {
      throw CredentialException(code: 101, message: 'Initialization failure', details: e.message);
    }
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
    // Only passkey sign-in is wired up natively on iOS; there is no password credential handler,
    // so fail explicitly rather than surfacing an unhandled platform error.
    if (passKeyOption == null) {
      throw CredentialException(
        code: 103,
        message: 'Not implemented',
        details: 'getCredentials without a passkey option is not supported on iOS',
      );
    }
    try {
      final res = await hostApi.getPasskeyCredential(jsonEncode(passKeyOption.toJson()));
      return Credentials(publicKeyCredential: PublicKeyCredential.fromJson(jsonDecode(res)));
    } on PlatformException catch (e) {
      throw PlatformExceptionHandler.handlePlatformException(e, CredentialType.passwordCredentials);
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
      final res = await hostApi.savePasskeyCredential(jsonEncode(request.toJson()));
      final credential = PublicKeyCredential.fromJson(jsonDecode(res));
      // Parse iOS attestation object
      final authData = AttestationParser.parseAttestationObject(credential.response!.attestationObject!);
      return credential.copyWith(
        response: credential.response?.copyWith(
          publicKey: authData.$2,
          authenticatorData: authData.$1,
        ),
      );
    } on PlatformException catch (e) {
      throw PlatformExceptionHandler.handlePlatformException(e, CredentialType.publicKeyCredentials);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await hostApi.logout();
    } on PlatformException catch (e) {
      throw CredentialException(code: 504, message: 'Logout failed', details: e.message);
    }
  }
}
