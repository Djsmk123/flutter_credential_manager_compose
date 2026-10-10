import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut: 'android/src/main/kotlin/com/smkwinner/cred_manager/credential_manager/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.smkwinner.cred_manager.credential_manager'),
    dartPackageName: 'credential_manager_android',
  ),
)

/// Result of [CredentialManagerHostApi.init].
class InitResult {
  InitResult({required this.message, required this.isGmsAvailable});

  String message;
  bool isGmsAvailable;
}

/// Typed replacement for the boolean flags that used to be JSON-encoded into
/// a string and stuffed inside a MethodChannel args map.
class FetchOptionsMessage {
  FetchOptionsMessage({
    required this.passKey,
    required this.googleCredential,
    required this.passwordCredential,
  });

  bool passKey;
  bool googleCredential;
  bool passwordCredential;
}

class PasswordCredentialMessage {
  PasswordCredentialMessage({required this.username, required this.password});

  String username;
  String password;
}

class GoogleIdTokenCredentialMessage {
  GoogleIdTokenCredentialMessage({
    required this.id,
    required this.idToken,
    this.displayName,
    this.givenName,
    this.familyName,
    this.phoneNumber,
    this.profilePictureUri,
  });

  String id;
  String idToken;
  String? displayName;
  String? givenName;
  String? familyName;
  String? phoneNumber;
  String? profilePictureUri;
}

/// Which variant of [CredentialResultMessage] is populated.
enum CredentialResultType {
  passwordCredential,
  googleIdTokenCredential,
  publicKeyCredential,
}

/// Typed replacement for the untyped `{"type": String, "data": Map}` envelope
/// returned by `get_password_credentials` on the old MethodChannel bridge.
/// Pigeon has no sealed/union type support, so this stays one class with a
/// discriminant enum and nullable fields per variant.
class CredentialResultMessage {
  CredentialResultMessage({
    required this.type,
    this.passwordCredential,
    this.googleIdTokenCredential,
    this.publicKeyCredentialJson,
  });

  CredentialResultType type;
  PasswordCredentialMessage? passwordCredential;
  GoogleIdTokenCredentialMessage? googleIdTokenCredential;
  String? publicKeyCredentialJson;
}

/// Host (Android/Kotlin) API for the credential_manager Android implementation.
///
/// Passkey request/response payloads (`passkeyRequestJson` / the returned
/// registration or authentication JSON) are intentionally kept as opaque
/// `String`s rather than decomposed into typed classes: the native
/// CredentialManager APIs consume and produce raw WebAuthn JSON directly, so
/// decomposing it here would add risk without a behavioral benefit.
@HostApi()
abstract class CredentialManagerHostApi {
  @async
  String getPlatformVersion();

  @async
  InitResult init(bool preferImmediatelyAvailableCredentials, String? googleClientId);

  @async
  void savePasswordCredentials(String username, String password);

  @async
  CredentialResultMessage getCredentials(String? passkeyRequestJson, FetchOptionsMessage fetchOptions);

  @async
  bool prepareCredentials(String? passkeyRequestJson, FetchOptionsMessage fetchOptions);

  @async
  GoogleIdTokenCredentialMessage saveGoogleCredential(bool useButtonFlow, String? nonce);

  @async
  String savePasskeyCredential(String requestJson);

  @async
  void logout();
}
