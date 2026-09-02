/// Represents a credential that is allowed to satisfy an assertion request.
///
/// Mirrors the WebAuthn `PublicKeyCredentialDescriptor` entries carried in
/// `publicKey.allowCredentials`. When the list is non-empty the authenticator
/// must only offer credentials whose [id] appears in it.
class AllowCredential {
  /// The Base64URL-encoded identifier of the allowed credential.
  ///
  /// Kept Base64URL as received: the Android `requestJson` requires Base64URL
  /// per the WebAuthn spec, and the iOS side decodes it with `Data.fromBase64Url`.
  final String id;

  /// The type of the allowed credential. Always `public-key` for passkeys.
  final String type;

  /// The transports the credential is reachable over, e.g. `internal`, `hybrid`.
  final List<String> transports;

  /// Constructs a new [AllowCredential] instance.
  ///
  /// [id] is the Base64URL-encoded identifier of the allowed credential.
  /// [type] is the type of the allowed credential.
  /// [transports] are the transports the credential is reachable over.
  AllowCredential({
    required this.id,
    this.type = 'public-key',
    this.transports = const [],
  });

  /// Constructs an [AllowCredential] instance from a JSON object.
  ///
  /// The JSON object must contain the following keys:
  /// - "id": The Base64URL-encoded identifier of the allowed credential.
  /// - "type": (Optional) The type of the allowed credential. Defaults to `public-key`.
  /// - "transports": (Optional) The transports the credential is reachable over.
  factory AllowCredential.fromJson(Map<String, dynamic> json) {
    return AllowCredential(
      id: json['id'],
      type: json['type'] ?? 'public-key',
      transports: (json['transports'] as List?)?.cast<String>() ?? const [],
    );
  }

  /// Converts this [AllowCredential] instance to a JSON object.
  ///
  /// The "transports" key is omitted when empty so the resulting
  /// `requestJson` stays minimal.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      if (transports.isNotEmpty) 'transports': transports,
    };
  }
}

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

  /// iOS-only flag that triggers the system's conditional UI on the keyboard.
  final bool conditionalUI;

  /// The credentials that are allowed to satisfy this assertion request.
  ///
  /// When non-empty, only credentials whose id appears in this list may be
  /// used to sign in. An empty list imposes no restriction, which matches the
  /// WebAuthn default of offering every credential registered for the rpId.
  final List<AllowCredential> allowCredentials;

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
    this.allowCredentials = const [],
  });

  /// Constructs a [CredentialLoginOptions] instance from a JSON object.
  ///
  /// The JSON object must contain the following keys:
  /// - "challenge": A challenge that the authenticator must complete.
  /// - "rpId": The relying party identifier.
  /// - "userVerification": Specifies whether user verification is required or preferred.
  /// - "timeout": (Optional) The time, in milliseconds, allowed for the user to complete the operation.
  ///   Defaults to 30 minutes (1800000 milliseconds).
  /// - "allowCredentials": (Optional) The credentials allowed to satisfy the request.
  factory CredentialLoginOptions.fromJson(Map<String, dynamic> json) {
    return CredentialLoginOptions(
      challenge: json['challenge'],
      rpId: json['rpId'],
      userVerification: json['userVerification'],
      timeout: json['timeout'] ?? 1800000,
      conditionalUI: json['conditionalUI'] ?? false,
      allowCredentials: (json['allowCredentials'] as List?)
              ?.map((i) => AllowCredential.fromJson(i))
              .toList() ??
          const [],
    );
  }

  /// Converts this [CredentialLoginOptions] instance to a JSON object.
  ///
  /// Returns a JSON object containing the following keys:
  /// - "challenge": A challenge that the authenticator must complete.
  /// - "rpId": The relying party identifier.
  /// - "userVerification": Specifies whether user verification is required or preferred.
  /// - "timeout": The time, in milliseconds, allowed for the user to complete the operation.
  /// - "allowCredentials": Only present when non-empty, so an unrestricted
  ///   request serialises exactly as it did before this field existed.
  Map<String, dynamic> toJson() {
    return {
      'challenge': challenge,
      'rpId': rpId,
      'userVerification': userVerification,
      'timeout': timeout,
      'conditionalUI': conditionalUI,
      if (allowCredentials.isNotEmpty)
        'allowCredentials': allowCredentials.map((i) => i.toJson()).toList(),
    };
  }
}
