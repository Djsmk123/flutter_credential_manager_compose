//
//  PasskeyService.swift
//  Pods
//
//  Created by Mobin on 05/10/24.
//
import AuthenticationServices   
import Flutter

@available(iOS 16.0, *) 
class PasskeyService: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    var inFlightController: Cancellable?
    let lock = NSLock()
     // Provide the presentation anchor for the authorization controller
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    func registerPasskeyCredentials(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let requestJson = args["requestJson"] as? String else {
            result(FlutterError(code: CustomErrors.invalidArguments.description, message: "Missing required fields", details: nil))
            return
        }

        guard let requestJsonData = requestJson.data(using: .utf8) else {
            result(FlutterError(code: CustomErrors.invalidJson.description, message: "Invalid JSON string", details: nil))
            return
        }

        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: requestJsonData, options: []) as? [String: Any] else {
                result(FlutterError(code: CustomErrors.invalidJsonStructure.description, message: "Invalid JSON structure", details: nil))
                return
            }

            guard let registerRequest = RegisterRequest.fromJson(jsonObject) else {
                result(FlutterError(code: CustomErrors.invalidRegisterRequest.description, message: "Invalid RegisterRequest JSON", details: nil))
                return
            }

            let rpId = registerRequest.relyingParty
            let userId = registerRequest.user.id
            let userName = registerRequest.user.name
            let challengeString = registerRequest.challenge

            guard let challengeData = Data(base64Encoded: challengeString) ?? challengeString.data(using: .utf8)?.base64EncodedData(),
                  let userIDData = Data(base64Encoded: userId) ?? userId.data(using: .utf8)?.base64EncodedData() else {
                result(FlutterError(code: CustomErrors.invalidData.description, message: "Invalid challenge or user ID", details: nil))
                return
            }

            let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId.id)
            let registrationRequest = publicKeyCredentialProvider.createCredentialRegistrationRequest(
                challenge: challengeData,
                name: userName,
                userID: userIDData
            )

            if #available(iOS 17.4, *) {
                registrationRequest.excludedCredentials = parseCredentials(credentialIDs: registerRequest.excludeCredentialIDs)
            }

            let con = RegisterController { res in
                self.lock.unlock()
                switch res {
                case .success(let response):
                    if let jsonData = try? JSONSerialization.data(withJSONObject: response.toJson(), options: []),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        result(jsonString)
                    } else {
                        result(FlutterError(code: CustomErrors.jsonConversionError.description, message: "Failed to convert response to JSON string", details: nil))
                    }
                case .failure(let error):
                    if let asError = error as? ASAuthorizationError {
                        result(FlutterError(from: asError))
                    } else if let nsError = error as NSError? {
                        result(FlutterError(fromNSError: nsError))
                    } else {
                        result(FlutterError(code: CustomErrors.unknown.description, message: error.localizedDescription, details: nil))
                    }
                }
            }
            con.run(request: registrationRequest)
            inFlightController = con

        } catch {
            result(FlutterError(code: CustomErrors.jsonParsingError.description, message: error.localizedDescription, details: nil))
        }
    }

    func getPasskeyCredentials(call: FlutterMethodCall, result: @escaping FlutterResult,
       preferImmediatelyAvailableCredentials: Bool = false  
    
    ) {
        guard let args = call.arguments as? [String: Any],
              let passKeyOption = args["passKeyOption"] as? [String: Any] else {
            result(FlutterError(code: CustomErrors.invalidArguments.description, message: "Missing required fields", details: nil))
            return
        }   
        let passkeyLoginRequest: PasskeyLoginRequest? = PasskeyLoginRequest.fromJson(passKeyOption)
        guard let passkeyLoginRequest = passkeyLoginRequest else {
            result(FlutterError(code: CustomErrors.invalidPasskeyOption.description, message: "Failed to parse passKeyOption", details: nil))
            return
        }

        let challengeString = passkeyLoginRequest.challenge
        let rpId = passkeyLoginRequest.rpId
        let conditionalUI = passkeyLoginRequest.conditionalUI

        guard let challengeData = Data(base64Encoded: challengeString) ?? challengeString.data(using: .utf8)?.base64EncodedData() else {
            result(FlutterError(code: CustomErrors.invalidChallenge.description, message: "Invalid challenge", details: nil))
            return
        }

        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let request = platformProvider.createCredentialAssertionRequest(challenge: challengeData)

        let con = AuthenticateController { res in
            self.lock.unlock()
            switch res {
            case .success(let response):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: response.toJson(), options: [])
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        result(["type": "PublicKeyCredentials", "data": jsonString])
                    } else {
                        result(FlutterError(code: CustomErrors.jsonConversionError.description, message: "Failed to convert response to JSON string", details: nil))
                    }
                } catch {
                    result(FlutterError(code: CustomErrors.jsonParsingError.description, message: error.localizedDescription, details: nil))
                }
            case .failure(let error):
                result(FlutterError(code: CustomErrors.unknown.description, message: error.localizedDescription, details: nil))
            }
        }
        con.run(request: request, conditionalUI: conditionalUI, preferImmediatelyAvailableCredentials: preferImmediatelyAvailableCredentials)
        inFlightController = con
    }

    // Parse credentials from base64 URL strings
    private func parseCredentials(credentialIDs: [String]) -> [ASAuthorizationPlatformPublicKeyCredentialDescriptor] {
        return credentialIDs.compactMap {
            if let credentialId = Data.fromBase64Url($0) {
                return ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: credentialId)
            } else {
                return nil
            }
        }
    }

}
