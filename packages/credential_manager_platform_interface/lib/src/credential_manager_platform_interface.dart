import 'package:credential_manager/credential_manager.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A platform-agnostic interface for managing credentials.
abstract class CredentialManagerPlatform extends PlatformInterface {
  /// Constructs a [CredentialManagerPlatform].
  CredentialManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static CredentialManagerPlatform? _instance;

  /// The default instance of [CredentialManagerPlatform] to use.
  ///
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CredentialManagerPlatform] when
  /// they register themselves.
  static CredentialManagerPlatform get instance {
    if (_instance == null) {
      throw AssertionError(
        'CredentialManagerPlatform.instance has not been initialized. '
        'Platform-specific implementations should set this with their own '
        'platform-specific class that extends CredentialManagerPlatform when '
        'they register themselves.',
      );
    }
    return _instance!;
  }

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CredentialManagerPlatform] when
  /// they register themselves.
  static set instance(CredentialManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initializes the credential manager with the option to prefer immediately available credentials.
  ///
  /// [preferImmediatelyAvailableCredentials] - Whether to prefer only locally-available credentials.
  /// [googleClientId] - The Google client ID to be used for Google credentials.
  ///
  /// Returns a [Future] that completes when initialization is successful.
  Future<void> init(
    bool preferImmediatelyAvailableCredentials,
    String? googleClientId,
  );

  /// Saves password credentials.
  ///
  /// [credential] - The password credentials to be saved.
  ///
  /// Returns a [Future] that completes when the credentials are successfully saved.
  Future<void> savePasswordCredentials(PasswordCredential credential);

  /// Retrieves credentials.
  ///
  /// [passKeyOption] - Options for passkey login.
  /// [fetchOptions] - Options for fetching specific types of credentials (Android only).
  ///
  /// Returns a [Future] that completes with [Credentials] representing the retrieved credentials.
  Future<Credentials> getCredentials({
    CredentialLoginOptions? passKeyOption,
    FetchOptionsAndroid? fetchOptions,
  });

  /// Retrieves the platform version information.
  ///
  /// Returns a [Future] that completes with a [String] representing the platform version.
  Future<String?> getPlatformVersion();

  /// Saves Google credentials.
  ///
  /// [useButtonFlow] - Whether to use the button flow for saving Google credentials.
  ///
  /// Returns a [Future] that completes with [GoogleIdTokenCredential] representing the saved Google credentials.
  Future<GoogleIdTokenCredential?> saveGoogleCredential(bool useButtonFlow);

  /// Saves credentials using passkey.
  ///
  /// [request] - The credentials to be saved.
  ///
  /// Returns a [Future] that completes with [PublicKeyCredential] representing the saved credentials.
  Future<PublicKeyCredential> savePasskeyCredentials({
    required CredentialCreationOptions request,
  });

  /// Logs out the user.
  ///
  /// Returns a [Future] that completes when the user is successfully logged out.
  Future<void> logout();
}

