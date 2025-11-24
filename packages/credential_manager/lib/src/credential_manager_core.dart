import 'package:credential_manager/credential_manager.dart';

// Import platform-specific plugin registration classes
import 'package:credential_manager_android/credential_manager_android.dart'
    as android_plugin;
import 'package:credential_manager_ios/credential_manager_ios.dart'
    as ios_plugin;

/// A class that provides a high-level interface for interacting with the
/// Credential Manager.
///
/// The methods are intentionally thin wrappers around
/// [CredentialManagerPlatform] so that you can extend or swap pieces out when
/// writing custom plugins. For details on extending the Dart and native layers,
/// see the “Extensions” section in the docs:
/// https://djsmk123.github.io/flutter_credential_manager_compose/#/
class CredentialManager {
  // /// Ensures the platform implementation is registered
  // static void _ensureInitialized() {
  //   if (!_initialized) {
  //     if (Platform.isAndroid) {
  //       android_plugin.CredentialManagerAndroidPlugin.registerWith();
  //     } else if (Platform.isIOS) {
  //       ios_plugin.CredentialManagerIosPlugin.registerWith();
  //     }
  //     _initialized = true;
  //   }
  // }
  /// Creates a [CredentialManager] and ensures the appropriate platform
  /// implementation is registered. If you ship a forked Android/iOS package,
  /// update the imports above or register your plugin before instantiating this
  /// class (see docs linked in the class comment).
  CredentialManager() {
    if (Platform.isAndroid) {
      android_plugin.CredentialManagerAndroidPlugin.registerWith();
    } else if (Platform.isIOS) {
      ios_plugin.CredentialManagerIosPlugin.registerWith();
    }
  }

  /// Gets the platform version.
  ///
  /// Returns a [Future] that completes with a [String] representing the platform version.
  Future<String?> getPlatformVersion() {
    return CredentialManagerPlatform.instance.getPlatformVersion();
  }

  /// Initializes the Credential Manager.
  ///
  /// [preferImmediatelyAvailableCredentials] - Whether to prefer only locally-available credentials.
  /// [googleClientId] - The Google client ID to be used for Google credentials.
  ///
  /// Returns a [Future] that completes when initialization is successful.
  Future<void> init({
    required bool preferImmediatelyAvailableCredentials,
    String? googleClientId,
  }) async {
    return CredentialManagerPlatform.instance
        .init(preferImmediatelyAvailableCredentials, googleClientId);
  }

  /// Saves plain text password credentials.
  ///
  /// [credential] - The password credentials to be saved.
  ///
  /// Returns a [Future] that completes when the credentials are successfully saved.
  Future<void> savePasswordCredentials(PasswordCredential credential) async {
    return CredentialManagerPlatform.instance
        .savePasswordCredentials(credential);
  }

  /// Saves credentials using passkey.
  ///
  /// [request] - The credentials to be saved.
  ///
  /// Returns a [Future] that completes with [PublicKeyCredential] representing the saved credentials.
  Future<PublicKeyCredential> savePasskeyCredentials(
      {required CredentialCreationOptions request}) async {
    return CredentialManagerPlatform.instance
        .savePasskeyCredentials(request: request);
  }

  /// Gets credentials.
  ///
  /// [passKeyOption] - Options for passkey login.
  /// [fetchOptions] - Options for fetching specific types of credentials.
  ///
  /// Returns a [Future] that completes with [Credentials] representing the retrieved credentials.
  /// Returns an empty [Credentials] object if no credentials are found.
  Future<Credentials> getCredentials(
      {CredentialLoginOptions? passKeyOption,
      FetchOptionsAndroid? fetchOptions}) async {
    return CredentialManagerPlatform.instance.getCredentials(
        passKeyOption: passKeyOption, fetchOptions: fetchOptions);
  }

  /// Saves Google credentials.
  ///
  /// [useButtonFlow] - Whether to use the button flow for saving Google credentials.
  ///
  /// Returns a [Future] that completes with [GoogleIdTokenCredential] representing the saved Google credentials.
  Future<GoogleIdTokenCredential?> saveGoogleCredential(
      {bool useButtonFlow = false}) async {
    return CredentialManagerPlatform.instance
        .saveGoogleCredential(useButtonFlow);
  }

  /// Logs out the user.
  ///
  /// Returns a [Future] that completes when the user is successfully logged out.
  Future<void> logout() async {
    return CredentialManagerPlatform.instance.logout();
  }

  /// Checks if the Credential Manager is supported on the current platform.
  ///
  /// Returns `true` if the platform is supported, otherwise `false`.
  bool get isSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  /// Checks if Google Play Services is available on the device.
  ///
  /// This is an Android-specific feature. On iOS, this will return `true`.
  /// Use this to check GMS availability before attempting Google Sign-In operations.
  /// This value is set during initialization.
  ///
  /// Returns a [bool] indicating GMS availability.
  bool get isGmsAvailable => CredentialManagerPlatform.instance.isGmsAvailable;
}
