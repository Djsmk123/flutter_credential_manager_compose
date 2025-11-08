import 'dart:convert';

import 'package:cbor/cbor.dart';
import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:flutter/services.dart';

/// iOS implementation of Credential Manager using method channels.
class CredentialManagerIos extends CredentialManagerPlatform {
  /// Method channel used to communicate with the native iOS platform.
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
      throw PlatformExceptionHandler.handlePlatformException(
        e,
        CredentialType.passwordCredentials,
      );
    }
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
      throw PlatformExceptionHandler.handlePlatformException(
        e,
        CredentialType.googleIdTokenCredentials,
      );
    }
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
        final authData = AttestationParser.parseAttestationObject(
            credential.response!.attestationObject!);
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

/// A utility class for parsing iOS passkey attestation objects.
class AttestationParser {
  /// Parses an iOS passkey attestation object to extract the authenticator data and public key.
  static (String authData, String publicKey) parseAttestationObject(
      String attestationObject) {
    try {
      // Ensure base64url padding before decoding
      String paddedAttestation = attestationObject;
      while (paddedAttestation.length % 4 != 0) {
        paddedAttestation += '=';
      }

      // Convert base64url to bytes
      final attestationBuffer = base64Url.decode(paddedAttestation);

      // Decode CBOR
      final decoded = cbor.decode(attestationBuffer);
      if (decoded is! Map) {
        throw Exception('Decoded CBOR is not a Map');
      }

      // Extract authData
      final authDataValue =
          (decoded as Map<CborValue, dynamic>)[CborValue('authData')];

      Uint8List authDataBytes;
      if (authDataValue is CborBytes) {
        authDataBytes = Uint8List.fromList(authDataValue.bytes);
      } else {
        throw Exception('authData is in an unsupported format');
      }

      // Ensure authData length is valid
      if (authDataBytes.length < 55) {
        throw Exception('authData is too short');
      }

      // Extract flags and check if public key is present
      final int flags = authDataBytes[32];
      final bool hasPublicKey = (flags & 0x40) != 0;
      if (!hasPublicKey) {
        throw Exception('No public key in attestation data');
      }

      // Get credential ID length (2 bytes) at index 53
      final int credentialIdLength =
          (authDataBytes[53] << 8) | authDataBytes[54];
      final int publicKeyStart = 55 + credentialIdLength;

      if (publicKeyStart >= authDataBytes.length) {
        throw Exception('Public key index out of bounds');
      }

      // Extract public key bytes
      final Uint8List publicKeyBytes = authDataBytes.sublist(publicKeyStart);
      //convert the public key to base64url
      final publicKeyBase64 =
          base64Url.encode(publicKeyBytes).replaceAll('=', '');
      //convert the auth data to base64url
      final authDataBase64 =
          base64Url.encode(authDataBytes).replaceAll('=', '');
      //return the auth data and public key
      return (authDataBase64, publicKeyBase64);
    } catch (error) {
      rethrow;
    }
  }
}

