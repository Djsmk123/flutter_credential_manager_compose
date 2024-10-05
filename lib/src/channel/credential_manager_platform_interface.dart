import 'package:credential_manager/credential_manager.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A platform-agnostic interface for managing credentials.
abstract class CredentialManagerPlatform extends PlatformInterface {
  /// Constructs a [CredentialManagerPlatform].
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

  /// Initializes the credential manager with the option to prefer immediately available credentials.
  Future<void> init(
    bool preferImmediatelyAvailableCredentials,
    String? googleClientId,
  ) {
    return _instance.init(
        preferImmediatelyAvailableCredentials, googleClientId);
  }

  /// Saves password credentials.
  Future<void> savePasswordCredentials(PasswordCredential credential) async {
    return _instance.savePasswordCredentials(credential);
  }

  /// Retrieves password credentials.
  Future<Credentials> getCredentials(
      {CredentialLoginOptions? passKeyOption}) async {
    return _instance.getCredentials(passKeyOption: passKeyOption);
  }

  /// Retrieves the platform version information.
  Future<String?> getPlatformVersion() {
    return _instance.getPlatformVersion();
  }

  Future<GoogleIdTokenCredential?> saveGoogleCredential(
      bool useButtonFlow) async {
    return _instance.saveGoogleCredential(useButtonFlow);
  }

  Future<PublicKeyCredential> savePasskeyCredentials(
      {required CredentialCreationOptions request}) async {
    return _instance.savePasskeyCredentials(request: request);
  }

  //Logout
  Future<void> logout() async {
    return _instance.logout();
  }
}
