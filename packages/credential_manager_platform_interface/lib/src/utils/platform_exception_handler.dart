import 'package:flutter/services.dart';
import '../exceptions/exceptions.dart';
import 'credential_type.dart';

/// Utility class for handling platform exceptions and converting them to [CredentialException].
class PlatformExceptionHandler {
  /// Handles [PlatformException] and returns appropriate [CredentialException] based on error codes.
  static CredentialException handlePlatformException(
    PlatformException e,
    CredentialType type,
  ) {
    switch (e.code) {
      case '101':
        return CredentialException(
          code: 101,
          message: 'Initialization failure',
          details: e.details,
        );
      case '102':
        return CredentialException(
          code: 102,
          message: 'Plugin exception',
          details: e.details,
        );
      case '103':
        return CredentialException(
          code: 103,
          message: 'Not implemented',
          details: e.details,
        );
      case '201':
        return CredentialException(
          code: 201,
          message: type == CredentialType.googleIdTokenCredentials
              ? 'Login with Google cancelled'
              : 'Login cancelled',
          details: e.details,
        );
      case '202':
        // iOS-specific: Check for temporarily blocked error
        if (e.details?.toString().contains('[28436]') == true) {
          return CredentialException(
            code: 205,
            message: 'Temporarily blocked',
            details: e.details,
          );
        } else {
          return CredentialException(
            code: 202,
            message: type == CredentialType.googleIdTokenCredentials
                ? 'No Google credentials found'
                : 'No credentials found',
            details: e.details,
          );
        }
      case '203':
        return CredentialException(
          code: 203,
          message: type == CredentialType.googleIdTokenCredentials
              ? 'Mismatched Google credentials'
              : 'Mismatched credentials',
          details: e.details,
        );
      case '204':
        return CredentialException(
          code: 204,
          message: 'Login failed',
          details: e.details,
        );
      case '301':
        return CredentialException(
          code: 301,
          message: type == CredentialType.googleIdTokenCredentials
              ? 'Save Google Credentials cancelled'
              : 'Save Credentials cancelled',
          details: e.details,
        );
      case '302':
        return CredentialException(
          code: 302,
          message: 'Create Credentials failed',
          details: e.details,
        );
      case '401':
        return CredentialException(
          code: 401,
          message: 'Encryption failed',
          details: e.details,
        );
      case '402':
        return CredentialException(
          code: 402,
          message: 'Decryption failed',
          details: e.details,
        );
      case '501':
        return CredentialException(
          code: 501,
          message: 'Received an invalid Google ID token response',
          details: e.details,
        );
      case '502':
        return CredentialException(
          code: 502,
          message: 'Invalid request',
          details: e.details,
        );
      case '503':
        return CredentialException(
          code: 503,
          message: 'Google client is not initialized yet',
          details: e.details,
        );
      case '504':
        return CredentialException(
          code: 504,
          message: 'Credentials operation failed',
          details: e.details,
        );
      case '505':
        return CredentialException(
          code: 505,
          message: 'Google credential decode error',
          details: e.details,
        );
      case '601':
        return CredentialException(
          code: 601,
          message: 'User cancelled passkey operation',
          details: e.details,
        );
      case '602':
        return CredentialException(
          code: 602,
          message: 'Passkey creation failed',
          details: e.details,
        );
      case '603':
        return CredentialException(
          code: 603,
          message: 'Passkey failed to fetch',
          details: e.details,
        );
      default:
        return CredentialException(
          code: 504,
          message: e.message ?? 'Credentials operation failed',
          details: e.details,
        );
    }
  }
}

