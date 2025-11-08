import 'package:flutter/foundation.dart';

class CredentialManagerPlatformManager {
  late final bool isAndroid;
  late final bool isIOS;
  late final bool isWeb;

  static final CredentialManagerPlatformManager _instance = CredentialManagerPlatformManager._internal();

  factory CredentialManagerPlatformManager() => _instance;

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