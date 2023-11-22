import 'dart:convert';

import 'package:credential_manager/credential_manager.dart';
import 'package:encrypt/encrypt.dart';

/// A utility class for encrypting and decrypting data using the AES algorithm.
class EncryptData {
  /// Encrypts plain text using the AES algorithm.
  ///
  /// [plainText] - The text to be encrypted.
  /// [secretKey] - The secret key used for encryption.
  ///
  /// Returns the base64-encoded encrypted text.
  ///
  /// Throws a [CredentialException] if encryption fails.
  static String encode(String plainText, String secretKey, String ivKey) {
    try {
      final key = Key.fromUtf8(secretKey);
      final iv = IV.fromUtf8(utf8.decode((ivKey).codeUnits));
      final encrypter = Encrypter(AES(key, padding: null));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return encrypted.base64;
    } catch (e) {
      throw CredentialException(
          code: 401, message: "Encryption failed", details: e.toString());
    }
  }

  /// Decrypts a base64-encoded text using the AES algorithm.
  ///
  /// [token] - The base64-encoded text to be decrypted.
  /// [secretKey] - The secret key used for decryption.
  ///
  /// Returns the decrypted text.
  ///
  /// Throws a [CredentialException] if decryption fails.
  static String? decode(String token, String secretKey, String ivKey) {
    try {
      //final encryptedText = utf8.decode(base64Url.decode(token));
      final key = Key.fromUtf8(secretKey);
      final iv = IV.fromUtf8(utf8.decode((ivKey).codeUnits));
      final encrypter = Encrypter(AES(key, padding: null));
      final decrypted = encrypter.decrypt(Encrypted.from64(token), iv: iv);
      return decrypted;
    } catch (e) {
      throw CredentialException(
          code: 402, message: "Decryption failed", details: e.toString());
    }
  }
}
