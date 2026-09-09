import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

/// Generates cryptographically-random, Base64URL-encoded identifiers for passkey requests.
class EncryptData {
  /// This class only exposes static members and is not meant to be instantiated.
  EncryptData._();

  /// Generates a random 64-byte user ID, Base64URL-encoded with padding stripped.
  static String getEncodedUserId() {
    final random = Random.secure();
    final bytes = Uint8List(64);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  /// Generates a random 32-byte challenge, Base64URL-encoded with padding stripped.
  static String getEncodedChallenge() {
    final random = Random.secure();
    final bytes = Uint8List(32);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
