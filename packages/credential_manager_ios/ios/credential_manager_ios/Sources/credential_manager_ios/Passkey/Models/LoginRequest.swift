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
    /// Base64URL-encoded credential IDs the assertion is restricted to.
    /// Empty means unrestricted, i.e. the WebAuthn default behaviour.
    let allowCredentialIDs: [String]

    static func fromJson(_ json: [String: Any]) -> PasskeyLoginRequest {
        // Extracting allow credential IDs properly
        let allowCredentials = json["allowCredentials"] as? [[String: Any]] ?? []
        let allowCredentialIDs: [String] = allowCredentials.compactMap { credential in
            return credential["id"] as? String
        }

        return PasskeyLoginRequest(
            challenge: json["challenge"] as? String ?? "",
            rpId: json["rpId"] as? String ?? "",
            userVerification: json["userVerification"] as? String ?? "",
            conditionalUI: json["conditionalUI"] as? Bool ?? false,
            allowCredentialIDs: allowCredentialIDs
        )
    }

    func toJson() -> [String: Any] {
        return [
            "challenge": challenge,
            "rpId": rpId,
            "userVerification": userVerification,
            "conditionalUI": conditionalUI,
            "allowCredentials": allowCredentialIDs.map { ["id": $0] }
        ]
    }
}
