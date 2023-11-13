import 'dart:convert';

import 'package:credential_manager/src/Models/password_credentials.dart';
import 'package:credential_manager/src/exceptions/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'credential_manager_platform_interface.dart';

/// An implementation of [CredentialManagerPlatform] that uses method channels.
class MethodChannelCredentialManager extends CredentialManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('credential_manager');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /*

Note: If the call to Credential Manager was triggered by an explicit user action, set preferImmediatelyAvailableCredentials to false. If Credential Manager was opportunistically called, set preferImmediatelyAvailableCredentials to true.

The preferImmediatelyAvailableCredentials option defines whether you prefer to only use locally-available credentials to fulfill the request, instead of credentials from security keys or hybrid key flows. This value is false by default.

If you set preferImmediatelyAvailableCredentials to true and there are no immediately available credentials, Credential Manager won't show any UI and the request will fail immediately, returning NoCredentialException for get requests and CreateCredentialNoCreateOptionException for create requests. This is recommended when calling the Credential Manager API opportunistically, such as when first opening the app.
*/

  @override
  Future<void> init(bool preferImmediatelyAvailableCredentials) async {
    final res = await methodChannel.invokeMethod<String>("init", {
      'prefer_immediately_available_credentials':
          preferImmediatelyAvailableCredentials
    });
    if (res != null && res == "Initialized success") {
      return;
    }
    throw CredentialException(code: 101, message: "initialization failure");
  }

  @override
  Future<void> savePasswordCredentials(PasswordCredential credential) async {
    try {
      final res = await methodChannel.invokeMethod<String>(
        'save_password_credentials',
        credential.toJson(),
      );
      if (res != null && res == "password saved") {
        return;
      }
      throw CredentialException(
          code: 302, message: "Create Credentials failed");
    } on PlatformException catch (e) {
      switch (e.code) {
        case "301":
          throw CredentialException(
              code: 301, message: "Save Credentials cancelled");
        default:
          throw CredentialException(
              code: 302, message: e.message ?? "Credentials save failed");
      }
    }
  }

  @override
  Future<PasswordCredential> getPasswordCredentials() async {
    try {
      final res = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'get_password_credentials',
      );
      if (res != null) {
        PasswordCredential credentials =
            PasswordCredential.fromJson(jsonDecode(jsonEncode(res)));
        return credentials;
      }
      throw CredentialException(code: 204, message: "Login failed");
    } on PlatformException catch (e) {
      switch (e.code) {
        case "201":
          throw CredentialException(code: 201, message: "Login cancelled");
        case "202":
          throw CredentialException(code: 202, message: "No credentials found");
        case "203":
          throw CredentialException(
              code: 203, message: "Mismatched credentials");
        default:
          throw CredentialException(
              code: 204, message: e.message ?? "${e.details}");
      }
    }
  }
}
