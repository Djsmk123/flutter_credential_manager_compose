import 'dart:convert';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';

/// A utility class for parsing iOS passkey attestation objects.
class AttestationParser {
  /// Parses an iOS passkey attestation object to extract the authenticator data and public key.
  ///
  /// This method decodes the base64url-encoded attestation object that is returned
  /// during iOS passkey registration. The attestation object contains CBOR-encoded
  /// data including the authenticator data (authData) which contains the public key.
  ///
  /// The method performs the following steps:
  /// 1. Decodes the base64url attestation string to bytes
  /// 2. Decodes the CBOR data structure
  /// 3. Extracts the authData bytes
  /// 4. Validates the authData structure and flags
  /// 5. Extracts the public key from the authData
  ///
  /// Parameters:
  /// - [attestationObject]: The base64url encoded attestation object from iOS passkey registration
  ///
  /// Returns:
  /// A tuple containing:
  /// - The authenticator data as a base64url encoded string without padding
  /// - The public key as a base64url encoded string without padding
  ///
  /// Throws:
  /// - [Exception] if the attestation object cannot be decoded
  /// - [Exception] if the authData is invalid or too short
  /// - [Exception] if no public key is present in the attestation data
  /// - [Exception] if the credential ID length is invalid
  /// - [Exception] if the public key index is out of bounds
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
