/// Represents options for credential login.
class CredentialLoginOptions {
  /// A challenge that the authenticator must complete.
  final String challenge;

  /// The relying party identifier.
  final String rpId;

  /// Specifies whether user verification is required or preferred.
  final String userVerification;

  /// The time, in milliseconds, allowed for the user to complete the operation.
  /// Defaults to 30 minutes (1800000 milliseconds).
  final int timeout;
  //only available on ios
  final bool conditionalUI;

  /// Constructs a new [CredentialLoginOptions] instance.
  ///
  /// [challenge] is the challenge that the authenticator must complete.
  /// [rpId] is the relying party identifier.
  /// [userVerification] specifies whether user verification is required or preferred.
  /// [timeout] is the time, in milliseconds, allowed for the user to complete the operation.
  /// Defaults to 30 minutes (1800000 milliseconds).
  CredentialLoginOptions({
    required this.challenge,
    required this.rpId,
    required this.userVerification,
    this.timeout = 1800000,
    this.conditionalUI = false,
  });

  /// Constructs a [CredentialLoginOptions] instance from a JSON object.
  ///
  /// The JSON object must contain the following keys:
  /// - "challenge": A challenge that the authenticator must complete.
  /// - "rpId": The relying party identifier.
  /// - "userVerification": Specifies whether user verification is required or preferred.
  /// - "timeout": (Optional) The time, in milliseconds, allowed for the user to complete the operation.
  ///   Defaults to 30 minutes (1800000 milliseconds).
  factory CredentialLoginOptions.fromJson(Map<String, dynamic> json) {
    return CredentialLoginOptions(
      challenge: json['challenge'],
      rpId: json['rpId'],
      userVerification: json['userVerification'],
      timeout: json['timeout'] ?? 1800000,
      conditionalUI: json['conditionalUI'] ?? false,
    );
  }

  /// Converts this [CredentialLoginOptions] instance to a JSON object.
  ///
  /// Returns a JSON object containing the following keys:
  /// - "challenge": A challenge that the authenticator must complete.
  /// - "rpId": The relying party identifier.
  /// - "userVerification": Specifies whether user verification is required or preferred.
  /// - "timeout": The time, in milliseconds, allowed for the user to complete the operation.
  Map<String, dynamic> toJson() {
    return {
      'challenge': challenge,
      'rpId': rpId,
      'userVerification': userVerification,
      'timeout': timeout,
      'conditionalUI': conditionalUI,
    };
  }
}
