import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

/// A utility class for encrypting and decrypting data using the AES algorithm.
class EncryptData {
  static String getEncodedUserId() {
    final random = Random.secure();
    final bytes = Uint8List(64);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static String getEncodedChallenge() {
    final random = Random.secure();
    final bytes = Uint8List(32);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
