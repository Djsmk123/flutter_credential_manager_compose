import 'dart:convert';

import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:flutter/services.dart';

import 'messages.g.dart';
import 'pigeon_mappers.dart';

/// Android implementation of Credential Manager using a Pigeon-generated
/// type-safe host API.
///
/// If you need to augment the native side (for example to support OEM flows or
/// proprietary credential providers) start here—each public override maps to a
/// Kotlin entry-point under `packages/credential_manager_android/android`.
/// The docs' “Extensions” section explains how to keep those edits in sync with
/// the shared platform interface.
class CredentialManagerAndroid extends CredentialManagerPlatform {
  /// Pigeon-generated host API used to communicate with the native Android platform.
  final CredentialManagerHostApi hostApi;

  /// Creates a [CredentialManagerAndroid] instance. Provide a custom [hostApi]
  /// when writing tests or wrapping this plugin inside another Android binary.
  CredentialManagerAndroid({CredentialManagerHostApi? hostApi}) : hostApi = hostApi ?? CredentialManagerHostApi();

  /// Whether Google Play Services is available on the device.
  /// Defaults to true and is updated during initialization.
  bool _isGmsAvailable = true;

  @override
  Future<String?> getPlatformVersion() => hostApi.getPlatformVersion();

  @override
  Future<void> init(bool preferImmediatelyAvailableCredentials, String? googleClientId) async {
    final res = await hostApi.init(preferImmediatelyAvailableCredentials, googleClientId);
    _isGmsAvailable = res.isGmsAvailable;
  }

  @override
  Future<void> savePasswordCredentials(PasswordCredential credential) async {
    final username = credential.username;
    final password = credential.password;
    if (username == null || password == null) {
      throw CredentialException(
        code: 302,
        message: 'Missing required fields',
        details: 'Username and password are required',
      );
    }
    try {
      await hostApi.savePasswordCredentials(username, password);
    } on PlatformException catch (e) {
      throw PlatformExceptionHandler.handlePlatformException(e, CredentialType.passwordCredentials);
    }
  }

  @override
  Future<Credentials> getCredentials({CredentialLoginOptions? passKeyOption, FetchOptionsAndroid? fetchOptions}) async {
    try {
      final res = await hostApi.getCredentials(
        passKeyOption?.toRequestJson(),
        _fetchOptionsMessage(fetchOptions),
      );
      return res.toCredentials();
    } on PlatformException catch (e) {
      // Return empty Credentials when no credentials are found (code 202)
      // This is a normal expected state, not an error
      if (e.code == '202') {
        return Credentials();
      }
      throw PlatformExceptionHandler.handlePlatformException(e, CredentialType.passwordCredentials);
    }
  }

  @override
  Future<bool> prepareCredentials({CredentialLoginOptions? passKeyOption, FetchOptionsAndroid? fetchOptions}) async {
    try {
      return await hostApi.prepareCredentials(passKeyOption?.toRequestJson(), _fetchOptionsMessage(fetchOptions));
    } on PlatformException catch (e) {
      throw PlatformExceptionHandler.handlePlatformException(e, CredentialType.passwordCredentials);
    }
  }

  FetchOptionsMessage _fetchOptionsMessage(FetchOptionsAndroid? fetchOptions) {
    final options = fetchOptions ?? FetchOptionsAndroid.all();
    return FetchOptionsMessage(
      passKey: options.passKey,
      googleCredential: options.googleCredential,
      passwordCredential: options.passwordCredential,
    );
  }

  @override
  Future<GoogleIdTokenCredential?> saveGoogleCredential(bool useButtonFlow, {String? nonce}) async {
    try {
      final res = await hostApi.saveGoogleCredential(useButtonFlow, nonce);
      return res.toGoogleIdTokenCredential();
    } on PlatformException catch (e) {
      throw PlatformExceptionHandler.handlePlatformException(e, CredentialType.googleIdTokenCredentials);
    }
  }

  @override
  Future<PublicKeyCredential> savePasskeyCredentials({required CredentialCreationOptions request}) async {
    try {
      final res = await hostApi.savePasskeyCredential(request.toRequestJson());
      return PublicKeyCredential.fromJson(jsonDecode(res));
    } on PlatformException catch (e) {
      throw PlatformExceptionHandler.handlePlatformException(e, CredentialType.publicKeyCredentials);
    }
  }

  @override
  Future<void> logout() => hostApi.logout();

  @override
  bool get isGmsAvailable {
    return _isGmsAvailable;
  }
}
