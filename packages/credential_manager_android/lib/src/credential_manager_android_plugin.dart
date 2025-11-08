import 'package:credential_manager_android/credential_manager_android.dart';
import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:flutter/foundation.dart';

/// Android plugin registration
class CredentialManagerAndroidPlugin {
  /// Registers the Android implementation
  static void registerWith() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      CredentialManagerPlatform.instance = CredentialManagerAndroid();
    }
  }
}
