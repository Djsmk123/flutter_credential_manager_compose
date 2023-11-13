import 'dart:io' show Platform;

import 'package:credential_manager/src/Models/password_credentials.dart';

import 'credential_manager_platform_interface.dart';

class CredentialManager {
  Future<String?> getPlatformVersion() {
    return CredentialManagerPlatform.instance.getPlatformVersion();
  }

  Future<void> init(
      {required bool preferImmediatelyAvailableCredentials}) async {
    return await CredentialManagerPlatform.instance
        .init(preferImmediatelyAvailableCredentials);
  }

  Future<void> savePasswordCredentials(PasswordCredential credential) async {
    return CredentialManagerPlatform.instance
        .savePasswordCredentials(credential);
  }

  Future<PasswordCredential> getPasswordCredentials() async {
    return CredentialManagerPlatform.instance.getPasswordCredentials();
  }

  bool get isSupportedPlatform => Platform.isAndroid;
}
