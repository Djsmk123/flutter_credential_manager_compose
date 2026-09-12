import 'package:flutter/foundation.dart';

/// Detects which platform the app is currently running on.
///
/// A single instance is computed once (via [instance]) and reused, since
/// [defaultTargetPlatform] doesn't change during the lifetime of an app.
class CredentialManagerPlatformManager {
  /// Whether the app is currently running on Android.
  late final bool isAndroid;

  /// Whether the app is currently running on iOS.
  late final bool isIOS;

  /// Whether the app is currently running on the web.
  late final bool isWeb;

  static final CredentialManagerPlatformManager _instance = CredentialManagerPlatformManager._internal();

  /// Returns the shared [CredentialManagerPlatformManager] instance.
  factory CredentialManagerPlatformManager() => _instance;

  /// The shared [CredentialManagerPlatformManager] instance.
  static CredentialManagerPlatformManager get instance => _instance;

  CredentialManagerPlatformManager._internal() {
    if (kIsWeb) {
      isAndroid = false;
      isIOS = false;
      isWeb = true;
    } else {
      isAndroid = defaultTargetPlatform == TargetPlatform.android;
      isIOS = defaultTargetPlatform == TargetPlatform.iOS;
      isWeb = false;
    }
  }
}
