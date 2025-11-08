import 'package:credential_manager/credential_manager.dart';

// Import platform-specific plugin registration classes
import 'package:credential_manager_android/credential_manager_android.dart'
    as android_plugin;
import 'package:credential_manager_ios/credential_manager_ios.dart'
    as ios_plugin;

/// A class that provides a high-level interface for interacting with the Credential Manager.
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
}
