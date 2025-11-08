import Foundation;
struct RegisterResponse {
  /// The ID
  var id: String;
  /// The raw ID
  var rawId: String;
  /// The client data JSON
  var clientDataJSON: String;
  /// The attestation object
  var attestationObject: String;

  static func fromList(_ list: [Any?]) -> RegisterResponse? {
    let id = list[0] as! String;
    let rawId = list[1] as! String;
    let clientDataJSON = list[2] as! String;
    let attestationObject = list[3] as! String;

    return RegisterResponse(
      id: id,
      rawId: rawId,
      clientDataJSON: clientDataJSON,
      attestationObject: attestationObject
    );
  };
  
  func toList() -> [Any?] {
    return [
      id,
      rawId,
      clientDataJSON,
      attestationObject,
    ];
  };

  static func fromJson(_ json: [String: Any]) -> RegisterResponse? {
    guard let id = json["id"] as? String,
          let rawId = json["rawId"] as? String,
          let clientDataJSON = json["clientDataJSON"] as? String,
          let attestationObject = json["attestationObject"] as? String else {
      return nil;
    };

    return RegisterResponse(
      id: id,
      rawId: rawId,
      clientDataJSON: clientDataJSON,
      attestationObject: attestationObject
    );
  };

  func toJson() -> [String: Any] {
    return [
      "id": id,
      "rawId": rawId,
      "response":[
          "clientDataJSON": clientDataJSON,
        "attestationObject": attestationObject,
      ]
    ];
  };
};
