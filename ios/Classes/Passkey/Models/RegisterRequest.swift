import Foundation

struct RegisterRequest {
    var challenge: String
    var relyingParty: RelyingParty
    var user: User
    var excludeCredentialIDs: [String]

    static func fromJson(_ json: [String: Any]) -> RegisterRequest? {
        guard let challenge = json["challenge"] as? String,
              let relyingPartyJson = json["rp"] as? [String: Any], // Accessing `rp` as a dictionary
              let relyingParty = RelyingParty.fromJson(relyingPartyJson),
              let userJson = json["user"] as? [String: Any],
              let user = User.fromJson(userJson) else {
            return nil
        }

        // Extracting exclude credential IDs properly
        let excludeCredentialIDs: [String] = (json["excludeCredentials"] as? [[String: Any]] ?? []).compactMap { credential in
            return credential["id"] as? String
        }

        return RegisterRequest(
            challenge: challenge,
            relyingParty: relyingParty,
            user: user,
            excludeCredentialIDs: excludeCredentialIDs
        )
    }

    func toJson() -> [String: Any] {
        return [
            "challenge": challenge,
            "rp": relyingParty.toJson(),
            "user": user.toJson(),
            "excludeCredentials": excludeCredentialIDs.map { ["id": $0] } // Formatting exclude credentials correctly
        ]
    }
}

struct RelyingParty {
    var id: String
    var name: String

    static func fromJson(_ json: [String: Any]) -> RelyingParty? {
        guard let id = json["id"] as? String,
              let name = json["name"] as? String else {
            return nil
        }
        return RelyingParty(id: id, name: name)
    }

    func toJson() -> [String: Any] {
        return [
            "id": id,
            "name": name
        ]
    }
}

struct User {
    var id: String
    var name: String
    var displayName: String

    static func fromJson(_ json: [String: Any]) -> User? {
        guard let id = json["id"] as? String,
              let name = json["name"] as? String,
              let displayName = json["displayName"] as? String else {
            return nil
        }
        return User(id: id, name: name, displayName: displayName)
    }

    func toJson() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "displayName": displayName
        ]
    }
}
