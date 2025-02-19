/// Class representing a public key credential.
class PublicKeyCredential {
  String? rawId;
  String? authenticatorAttachment;
  String? type;
  String? id;
  Response? response;
  List<String>? transports;
  ClientExtensionResults? clientExtensionResults;
  int? publicKeyAlgorithm;
  String? publicKey;

  /// Constructor for PublicKeyCredential.
  PublicKeyCredential({
    this.rawId,
    this.authenticatorAttachment,
    this.type,
    this.id,
    this.response,
    this.transports,
    this.clientExtensionResults,
    this.publicKeyAlgorithm,
    this.publicKey,
  });

  /// Construct PublicKeyCredential from JSON.
  factory PublicKeyCredential.fromJson(Map<String, dynamic> json) {
    return PublicKeyCredential(
      rawId: json['rawId'],
      authenticatorAttachment: json['authenticatorAttachment'] ?? 'platform',
      type: json['type'] ?? 'public-key',
      id: json['id'],
      response:
          json['response'] != null ? Response.fromJson(json['response']) : null,
      transports: json['transports'] != null
          ? List<String>.from(json['transports'])
          : null,
      clientExtensionResults: json['clientExtensionResults'] != null
          ? ClientExtensionResults.fromJson(json['clientExtensionResults'])
          : null,
      publicKeyAlgorithm: json['publicKeyAlgorithm'],
      publicKey: json['publicKey'],
    );
  }

  /// Convert PublicKeyCredential to JSON.
  Map<String, dynamic> toJson() {
    return {
      'rawId': rawId,
      'authenticatorAttachment': authenticatorAttachment,
      'type': type,
      'id': id,
      'response': response?.toJson(),
      'transports': transports,
      'clientExtensionResults': clientExtensionResults?.toJson(),
      'publicKeyAlgorithm': publicKeyAlgorithm,
      'publicKey': publicKey,
    };
  }

  /// CopyWith method for PublicKeyCredential.
  PublicKeyCredential copyWith({
    String? rawId,
    String? authenticatorAttachment,
    String? type,
    String? id,
    Response? response,
    List<String>? transports,
    ClientExtensionResults? clientExtensionResults,
    int? publicKeyAlgorithm,
    String? publicKey,
  }) {
    return PublicKeyCredential(
      rawId: rawId ?? this.rawId,
      authenticatorAttachment:
          authenticatorAttachment ?? this.authenticatorAttachment,
      type: type ?? this.type,
      id: id ?? this.id,
      response: response ?? this.response,
      transports: transports ?? this.transports,
      clientExtensionResults:
          clientExtensionResults ?? this.clientExtensionResults,
      publicKeyAlgorithm: publicKeyAlgorithm ?? this.publicKeyAlgorithm,
      publicKey: publicKey ?? this.publicKey,
    );
  }
}

/// Class representing a response.
class Response {
  String? clientDataJSON;
  String? attestationObject;
  String? authenticatorData;
  String? publicKey;
  List<String>? transports;
  String? signature;
  String? userHandle;

  /// Constructor for Response.
  Response({
    this.clientDataJSON,
    this.attestationObject,
    this.authenticatorData,
    this.publicKey,
    this.transports,
    this.signature,
    this.userHandle,
  });

  /// Construct Response from JSON.
  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      clientDataJSON: json['clientDataJSON'],
      attestationObject: json['attestationObject'],
      authenticatorData: json['authenticatorData'],
      publicKey: json['publicKey'],
      transports: json['transports'] != null
          ? List<String>.from(json['transports'])
          : null,
      signature: json['signature'],
      userHandle: json['userHandle'],
    );
  }

  /// Convert Response to JSON.
  Map<String, dynamic> toJson() {
    return {
      'clientDataJSON': clientDataJSON,
      'attestationObject': attestationObject,
      'authenticatorData': authenticatorData,
      'publicKey': publicKey,
      'transports': transports,
      'signature': signature,
      'userHandle': userHandle,
    };
  }

  /// CopyWith method for Response.
  Response copyWith({
    String? clientDataJSON,
    String? attestationObject,
    String? authenticatorData,
    String? publicKey,
    List<String>? transports,
    String? signature,
    String? userHandle,
  }) {
    return Response(
      clientDataJSON: clientDataJSON ?? this.clientDataJSON,
      attestationObject: attestationObject ?? this.attestationObject,
      authenticatorData: authenticatorData ?? this.authenticatorData,
      publicKey: publicKey ?? this.publicKey,
      transports: transports ?? this.transports,
      signature: signature ?? this.signature,
      userHandle: userHandle ?? this.userHandle,
    );
  }
}

/// Class representing client extension results.
class ClientExtensionResults {
  CredProps? credProps;

  /// Constructor for ClientExtensionResults.
  ClientExtensionResults({
    this.credProps,
  });

  /// Construct ClientExtensionResults from JSON.
  factory ClientExtensionResults.fromJson(Map<String, dynamic> json) {
    return ClientExtensionResults(
      credProps: json['credProps'] != null
          ? CredProps.fromJson(json['credProps'])
          : null,
    );
  }

  /// Convert ClientExtensionResults to JSON.
  Map<String, dynamic> toJson() {
    return {
      'credProps': credProps?.toJson(),
    };
  }

  /// CopyWith method for ClientExtensionResults.
  ClientExtensionResults copyWith({
    CredProps? credProps,
  }) {
    return ClientExtensionResults(
      credProps: credProps ?? this.credProps,
    );
  }
}

/// Class representing credential properties.
class CredProps {
  bool? rk;

  /// Constructor for CredProps.
  CredProps({
    this.rk,
  });

  /// Construct CredProps from JSON.
  factory CredProps.fromJson(Map<String, dynamic> json) {
    return CredProps(
      rk: json['rk'],
    );
  }

  /// Convert CredProps to JSON.
  Map<String, dynamic> toJson() {
    return {
      'rk': rk,
    };
  }

  /// CopyWith method for CredProps.
  CredProps copyWith({
    bool? rk,
  }) {
    return CredProps(
      rk: rk ?? this.rk,
    );
  }
}
