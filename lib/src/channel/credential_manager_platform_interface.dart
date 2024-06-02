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

  /// Saves encrypted credentials using the provided secret key and initialization vector (IV).
  Future<void> saveEncryptedCredentials({
    required PasswordCredential credential,
    required String secretKey,
    required String ivKey,
  }) async {
    return _instance.saveEncryptedCredentials(
        credential: credential, secretKey: secretKey, ivKey: ivKey);
  }

  /// Retrieves encrypted credentials using the provided secret key and initialization vector (IV).
  Future<Credentials> getEncryptedCredentials(
      {required String secretKey,
      required String ivKey,
      CredentialLoginOptions? passKeyOption}) async {
    return _instance.getEncryptedCredentials(
        secretKey: secretKey, ivKey: ivKey, passKeyOption: passKeyOption);
  }

  /// Retrieves password credentials.
  Future<Credentials> getPasswordCredentials(
      {CredentialLoginOptions? passKeyOption}) async {
    return _instance.getPasswordCredentials(passKeyOption: passKeyOption);
  }

  /// Retrieves the platform version information.
  Future<String?> getPlatformVersion() {
    return _instance.getPlatformVersion();
  }

  Future<GoogleIdTokenCredential?> saveGoogleCredential() async {
    return _instance.saveGoogleCredential();
  }

  Future<PublicKeyCredential> savePasskeyCredentials(
      {required CredentialCreationOptions request}) async {
    return CredentialManagerPlatform.instance
        .savePasskeyCredentials(request: request);
  }
}
