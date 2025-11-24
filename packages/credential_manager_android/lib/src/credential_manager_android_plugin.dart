import 'package:credential_manager_android/credential_manager_android.dart';
import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:flutter/foundation.dart';

/// Android plugin registration
class CredentialManagerAndroidPlugin {
  /// Prevents instantiation. This plugin exposes only the static
  /// [registerWith] method for Flutter's plugin registrar.
  const CredentialManagerAndroidPlugin._();

  /// Registers the Android implementation
  static void registerWith() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      CredentialManagerPlatform.instance = CredentialManagerAndroid();
    }
  }
}
