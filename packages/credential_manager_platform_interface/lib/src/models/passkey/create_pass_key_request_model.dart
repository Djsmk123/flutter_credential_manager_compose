/// Represents parameters for a public key credential.
class PublicKeyCredentialParameters {
  /// The type of the public key credential.
  final String type;

  /// The cryptographic algorithm.
  final int alg;

  /// Constructs a new [PublicKeyCredentialParameters] instance.
  ///
  /// [type] is the type of the public key credential.
  /// [alg] is the cryptographic algorithm.
  PublicKeyCredentialParameters({
    required this.type,
    required this.alg,
  });

  /// Constructs a [PublicKeyCredentialParameters] instance from a JSON object.
  ///
  /// The JSON object must contain the following keys:
  /// - "type": The type of the public key credential.
  /// - "alg": The cryptographic algorithm.
  factory PublicKeyCredentialParameters.fromJson(Map<String, dynamic> json) {
    return PublicKeyCredentialParameters(
      type: json['type'],
      alg: json['alg'],
    );
  }

  /// Converts this [PublicKeyCredentialParameters] instance to a JSON object.
  ///
  /// Returns a JSON object containing the following keys:
  /// - "type": The type of the public key credential.
  /// - "alg": The cryptographic algorithm.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'alg': alg,
    };
  }
}

/// Represents excluded credentials for a public key credential creation operation.
class ExcludeCredential {
  /// The identifier of the excluded credential.
  final String id;

  /// The type of the excluded credential.
  final String type;

  /// Constructs a new [ExcludeCredential] instance.
  ///
  /// [id] is the identifier of the excluded credential.
  /// [type] is the type of the excluded credential.
  ExcludeCredential({
    required this.id,
    required this.type,
  });

  /// Constructs a [ExcludeCredential] instance from a JSON object.
  ///
  /// The JSON object must contain the following keys:
  /// - "id": The identifier of the excluded credential.
  /// - "type": The type of the excluded credential.
  factory ExcludeCredential.fromJson(Map<String, dynamic> json) {
    return ExcludeCredential(
      id: json['id'],
      type: json['type'],
    );
  }

  /// Converts this [ExcludeCredential] instance to a JSON object.
  ///
  /// Returns a JSON object containing the following keys:
  /// - "id": The identifier of the excluded credential.
  /// - "type": The type of the excluded credential.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
    };
  }
}

/// Represents criteria for selecting an authenticator during a public key credential creation operation.
class AuthenticatorSelectionCriteria {
  /// The preferred authenticator attachment modality.
  final String? authenticatorAttachment;

  /// Indicates whether the authenticator should create a resident credential.
  final bool? requireResidentKey;

  /// A preferred resident key.
  final String? residentKey;

  /// Specifies whether user verification is required or preferred.
  final String? userVerification;

  /// Constructs a new [AuthenticatorSelectionCriteria] instance.
  ///
  /// [authenticatorAttachment] is the preferred authenticator attachment modality.
  /// [requireResidentKey] indicates whether the authenticator should create a resident credential.
  /// [residentKey] is a preferred resident key.
  /// [userVerification] specifies whether user verification is required or preferred.
  AuthenticatorSelectionCriteria({
    this.authenticatorAttachment,
    this.requireResidentKey,
    this.residentKey,
    this.userVerification,
  });

  /// Constructs a [AuthenticatorSelectionCriteria] instance from a JSON object.
  ///
  /// The JSON object may contain the following keys:
  /// - "authenticatorAttachment": The preferred authenticator attachment modality.
  /// - "requireResidentKey": Indicates whether the authenticator should create a resident credential.
  /// - "residentKey": A preferred resident key.
  /// - "userVerification": Specifies whether user verification is required or preferred.
  factory AuthenticatorSelectionCriteria.fromJson(Map<String, dynamic> json) {
    return AuthenticatorSelectionCriteria(
      authenticatorAttachment: json['authenticatorAttachment'],
      requireResidentKey: json['requireResidentKey'],
      residentKey: json['residentKey'],
      userVerification: json['userVerification'],
    );
  }

  /// Converts this [AuthenticatorSelectionCriteria] instance to a JSON object.
  ///
  /// Returns a JSON object containing the following keys:
  /// - "authenticatorAttachment": The preferred authenticator attachment modality.
  /// - "requireResidentKey": Indicates whether the authenticator should create a resident credential.
  /// - "residentKey": A preferred resident key.
  /// - "userVerification": Specifies whether user verification is required or preferred.
  Map<String, dynamic> toJson() {
    return {
      'authenticatorAttachment': authenticatorAttachment,
      'requireResidentKey': requireResidentKey,
      'residentKey': residentKey,
      'userVerification': userVerification,
    };
  }
}

/// Represents a relying party (RP) for a public key credential creation operation.
class Rp {
  /// The name of the relying party.
  final String name;

  /// The identifier of the relying party.
  final String id;

  /// Constructs a new [Rp] instance.
  ///
  /// [name] is the name of the relying party.
  /// [id] is the identifier of the relying party.
  Rp({
    required this.name,
    required this.id,
  });

  /// Constructs a [Rp] instance from a JSON object.
  ///
  /// The JSON object must contain the following keys:
  /// - "name": The name of the relying party.
  /// - "id": The identifier of the relying party.
  factory Rp.fromJson(Map<String, dynamic> json) {
    return Rp(
      name: json['name'],
      id: json['id'],
    );
  }

  /// Converts this [Rp] instance to a JSON object.
  ///
  /// Returns a JSON object containing the following keys:
  /// - "name": The name of the relying party.
  /// - "id": The identifier of the relying party.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }
}

/// Represents a user for a public key credential creation operation.
class User {
  /// The user identifier.
  final String id;

  /// The username.
  final String name;

  /// The display name.
  final String displayName;

  /// Constructs a new [User] instance.
  ///
  /// [id] is the user identifier.
  /// [name] is the username.
  /// [displayName] is the display name.
  User({
    required this.id,
    required this.name,
    required this.displayName,
  });

  /// Constructs a [User] instance from a JSON object.
  ///
  /// The JSON object must contain the following keys:
  /// - "id": The user identifier.
  /// - "name": The username.
  /// - "displayName": The display name.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      displayName: json['displayName'],
    );
  }

  /// Converts this [User] instance to a JSON object.
  ///
  /// Returns a JSON object containing the following keys:
  /// - "id": The user identifier.
  /// - "name": The username.
  /// - "displayName": The display name.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
    };
  }
}

/// Represents options for creating a credential.
class CredentialCreationOptions {
  /// The challenge.
  final String challenge;

  /// The relying party (RP).
  final Rp rp;

  /// The user.
  final User user;

  /// The public key credential parameters.
  final List<PublicKeyCredentialParameters> pubKeyCredParams;

  /// The timeout.
  final int timeout;

  /// The attestation.
  final String attestation;

  /// The excluded credentials.
  final List<ExcludeCredential> excludeCredentials;

  /// The authenticator selection criteria.
  final AuthenticatorSelectionCriteria authenticatorSelection;

  /// Constructs a new [CredentialCreationOptions] instance.
  ///
  /// [challenge] is the challenge.
  /// [rp] is the relying party (RP).
  /// [user] is the user.
  /// [pubKeyCredParams] are the public key credential parameters.
  /// [timeout] is the timeout.
  /// [attestation] is the attestation.
  /// [excludeCredentials] are the excluded credentials.
  /// [authenticatorSelection] is the authenticator selection criteria.
  CredentialCreationOptions({
    required this.challenge,
    required this.rp,
    required this.user,
    required this.pubKeyCredParams,
    this.timeout = 1800000,
    this.attestation = 'none',
    required this.excludeCredentials,
    required this.authenticatorSelection,
  });

  /// Constructs a [CredentialCreationOptions] instance from a JSON object.
  ///
  /// The JSON object must contain the following keys:
  /// - "challenge": The challenge.
  /// - "rp": The relying party (RP).
  /// - "user": The user.
  /// - "pubKeyCredParams": The public key credential parameters.
  /// - "timeout": The timeout (optional).
  /// - "attestation": The attestation (optional).
  /// - "excludeCredentials": The excluded credentials.
  /// - "authenticatorSelection": The authenticator selection criteria.
  factory CredentialCreationOptions.fromJson(Map<String, dynamic> json) {
    return CredentialCreationOptions(
      challenge: json['challenge'],
      rp: Rp.fromJson(json['rp']),
      user: User.fromJson(json['user']),
      pubKeyCredParams: json['pubKeyCredParams'] != null
          ? (json['pubKeyCredParams'] as List)
              .map((i) => PublicKeyCredentialParameters.fromJson(i))
              .toList()
          : [],
      timeout: json['timeout'] ?? 1800000,
      attestation: json['attestation'] ?? 'none',
      excludeCredentials: json['excludeCredentials'] != null
          ? (json['excludeCredentials'] as List)
              .map((i) => ExcludeCredential.fromJson(i))
              .toList()
          : [],
      authenticatorSelection: json['authenticatorSelection'] != null
          ? AuthenticatorSelectionCriteria.fromJson(
              json['authenticatorSelection'])
          : AuthenticatorSelectionCriteria(),
    );
  }

  /// Converts this [CredentialCreationOptions] instance to a JSON object.
  ///
  /// Returns a JSON object containing the following keys:
  /// - "challenge": The challenge.
  /// - "rp": The relying party (RP).
  /// - "user": The user.
  /// - "pubKeyCredParams": The public key credential parameters.
  /// - "timeout": The timeout.
  /// - "attestation": The attestation.
  /// - "excludeCredentials": The excluded credentials.
  /// - "authenticatorSelection": The authenticator selection criteria.
  Map<String, dynamic> toJson() {
    return {
      'challenge': challenge,
      'rp': rp.toJson(),
      'user': user.toJson(),
      'pubKeyCredParams': pubKeyCredParams.map((i) => i.toJson()).toList(),
      'timeout': timeout,
      'attestation': attestation,
      'excludeCredentials': excludeCredentials.map((i) => i.toJson()).toList(),
      'authenticatorSelection': authenticatorSelection.toJson(),
    };
  }
}
