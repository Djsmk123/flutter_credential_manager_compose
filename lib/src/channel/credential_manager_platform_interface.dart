import 'package:credential_manager/src/Models/password_credentials.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'credential_manager_method_channel.dart';

abstract class CredentialManagerPlatform extends PlatformInterface {
  /// Constructs a CredentialManagerPlatform.
  CredentialManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static CredentialManagerPlatform _instance = MethodChannelCredentialManager();

  /// The default instance of [CredentialManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelCredentialManager].
  static CredentialManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CredentialManagerPlatform] when
  /// they register themselves.
  static set instance(CredentialManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init(bool preferImmediatelyAvailableCredentials) {
    return _instance.init(preferImmediatelyAvailableCredentials);
  }

  Future<void> savePasswordCredentials(PasswordCredential credential) async {
    return _instance.savePasswordCredentials(credential);
  }

  Future<PasswordCredential> getPasswordCredentials() async {
    return _instance.getPasswordCredentials();
  }

  Future<String?> getPlatformVersion() {
    return _instance.getPlatformVersion();
  }
}
