import 'package:credential_manager_ios/credential_manager_ios.dart';
import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:flutter/foundation.dart';

/// iOS plugin registration
class CredentialManagerIosPlugin {
  /// Registers the iOS implementation
  static void registerWith() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      CredentialManagerPlatform.instance = CredentialManagerIos();
    }
  }
}

