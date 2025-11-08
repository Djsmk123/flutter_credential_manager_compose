//
//  LoginRequest.swift
//  Pods
//
//  Created by Mobin on 05/10/24.

import Foundation

extension AuthenticateResponse {
    static func fromJson(_ json: [String: Any]) -> AuthenticateResponse? {
        guard let id = json["id"] as? String,
              let rawId = json["rawId"] as? String,
              let clientDataJSON = json["clientDataJSON"] as? String,
              let authenticatorData = json["authenticatorData"] as? String,
              let signature = json["signature"] as? String,
              let userHandle = json["userHandle"] as? String else {
            return nil
        }
        
        return AuthenticateResponse(
            id: id,
            rawId: rawId,
            clientDataJSON: clientDataJSON,
            authenticatorData: authenticatorData,
            signature: signature,
            userHandle: userHandle
        )
    }
    
    func toJson() -> [String: Any] {
        return [
            "id": id,
            "rawId": rawId,
            "response": [
                "clientDataJSON": clientDataJSON,
                "attestationObject": authenticatorData,
                "authenticatorData": authenticatorData,
                "publicKey": signature,
                "signature": signature,
                "userHandle": userHandle
            ]
        ]
    }
}
//

struct AuthenticateResponse {
  /// The ID
  var id: String
  /// The raw ID
  var rawId: String
  /// The client data JSON
  var clientDataJSON: String
  /// The authenticator data
  var authenticatorData: String
  /// Signed challenge
  var signature: String
  var userHandle: String

  static func fromList(_ list: [Any?]) -> AuthenticateResponse? {
    let id = list[0] as! String
    let rawId = list[1] as! String
    let clientDataJSON = list[2] as! String
    let authenticatorData = list[3] as! String
    let signature = list[4] as! String
    let userHandle = list[5] as! String

    return AuthenticateResponse(
      id: id,
      rawId: rawId,
      clientDataJSON: clientDataJSON,
      authenticatorData: authenticatorData,
      signature: signature,
      userHandle: userHandle
    )
  }
  func toList() -> [Any?] {
    return [
      id,
      rawId,
      clientDataJSON,
      authenticatorData,
      signature,
      userHandle,
    ]
  }
}
