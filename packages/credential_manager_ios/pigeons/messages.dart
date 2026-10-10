import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut: 'ios/credential_manager_ios/Sources/credential_manager_ios/Messages.g.swift',
    dartPackageName: 'credential_manager_ios',
  ),
)

/// Host (iOS/Swift) API for the credential_manager iOS implementation.
///
/// Passkey request/response payloads are intentionally kept as opaque WebAuthn
/// JSON `String`s rather than decomposed into typed classes: the Swift side
/// already owns the WebAuthn <-> AuthenticationServices translation
/// (`RegisterRequest`, `PasskeyLoginRequest`, ...), so decomposing it here
/// would add risk without a behavioral benefit.
///
/// Failures are reported as `PlatformException`s whose `code` is one of the
/// `CustomErrors` descriptions (e.g. `cancelled`, `domain-not-associated`).
@HostApi()
abstract class CredentialManagerHostApi {
  @async
  String getPlatformVersion();

  @async
  void initialize(bool preferImmediatelyAvailableCredentials, String? googleClientId);

  /// Registers a passkey; returns the registration response as WebAuthn JSON.
  @async
  String savePasskeyCredential(String requestJson);

  /// Authenticates with a passkey; returns the assertion response as WebAuthn JSON.
  @async
  String getPasskeyCredential(String passkeyRequestJson);

  @async
  void logout();
}
