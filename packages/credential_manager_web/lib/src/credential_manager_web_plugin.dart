import 'package:credential_manager_web/credential_manager_web.dart';
import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Web plugin registration
class CredentialManagerWebPlugin {
  /// Registers the Web implementation with Flutter web plugins
  /// This is called automatically by Flutter's web plugin system
  static void registerWith(Registrar registrar) {
    // Register the platform implementation
    CredentialManagerPlatform.instance = CredentialManagerWeb();
  }

  /// Manual registration method (for compatibility with other platforms)
  /// This is called from CredentialManager constructor
  static void registerWithManual() {
    // Register the platform implementation
    CredentialManagerPlatform.instance = CredentialManagerWeb();
  }
}

