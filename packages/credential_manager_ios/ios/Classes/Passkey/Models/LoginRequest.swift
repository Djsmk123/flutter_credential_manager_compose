//
//  LoginRequest.swift
//  Pods
//
//  Created by Mobin on 05/10/24.
//

struct PasskeyLoginRequest {
    let challenge: String
    let rpId: String
    let userVerification: String
    let conditionalUI: Bool

    static func fromJson(_ json: [String: Any]) -> PasskeyLoginRequest {
        return PasskeyLoginRequest(
            challenge: json["challenge"] as? String ?? "",
            rpId: json["rpId"] as? String ?? "",
            userVerification: json["userVerification"] as? String ?? "",
            conditionalUI: json["conditionalUI"] as? Bool ?? false
        )
    }

    func toJson() -> [String: Any] {
        return [
            "challenge": challenge,
            "rpId": rpId,
            "userVerification": userVerification,
            "conditionalUI": conditionalUI
        ]
    }
}

