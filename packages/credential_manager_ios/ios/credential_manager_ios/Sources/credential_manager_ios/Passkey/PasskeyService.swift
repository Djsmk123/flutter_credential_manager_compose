//
//  PasskeyService.swift
//  Pods
//
//  Created by Mobin on 05/10/24.
//
import AuthenticationServices
import Flutter

typealias PasskeyCompletion = (Result<String, Error>) -> Void

@available(iOS 16.0, *)
class PasskeyService: NSObject, ASAuthorizationControllerDelegate,
                       ASAuthorizationControllerPresentationContextProviding {
    var inFlightController: Cancellable?
    let lock = NSLock()
    // Provide the presentation anchor for the authorization controller
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }

    func registerPasskeyCredentials(requestJson: String, completion: @escaping PasskeyCompletion) {
        guard let requestJsonData = requestJson.data(using: .utf8) else {
            completion(.failure(FlutterError(code: .invalidJson, message: "Invalid JSON string")))
            return
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: requestJsonData, options: [])
            guard let jsonObject = jsonObject as? [String: Any] else {
                completion(.failure(FlutterError(code: .invalidJsonStructure, message: "Invalid JSON structure")))
                return
            }

            guard let registerRequest = RegisterRequest.fromJson(jsonObject) else {
                completion(.failure(FlutterError(
                    code: .invalidRegisterRequest, message: "Invalid RegisterRequest JSON"
                )))
                return
            }

            startRegistration(registerRequest, completion: completion)
        } catch {
            completion(.failure(FlutterError(code: .jsonParsingError, message: error.localizedDescription)))
        }
    }

    private func startRegistration(_ registerRequest: RegisterRequest, completion: @escaping PasskeyCompletion) {
        let rpId = registerRequest.relyingParty
        let userId = registerRequest.user.id
        let userName = registerRequest.user.name
        let challengeString = registerRequest.challenge

        let challengeData = Data(base64Encoded: challengeString)
            ?? challengeString.data(using: .utf8)?.base64EncodedData()
        let userIDData = Data(base64Encoded: userId) ?? userId.data(using: .utf8)?.base64EncodedData()
        guard let challengeData = challengeData, let userIDData = userIDData else {
            completion(.failure(FlutterError(code: .invalidData, message: "Invalid challenge or user ID")))
            return
        }

        let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
            relyingPartyIdentifier: rpId.id
        )
        let registrationRequest = publicKeyCredentialProvider.createCredentialRegistrationRequest(
            challenge: challengeData,
            name: userName,
            userID: userIDData
        )

        if #available(iOS 17.4, *) {
            registrationRequest.excludedCredentials = parseCredentials(
                credentialIDs: registerRequest.excludeCredentialIDs
            )
        }

        let con = RegisterController { [weak self] res in
            self?.lock.unlock()
            Self.handleRegistrationResult(res, completion: completion)
        }
        con.run(request: registrationRequest)
        inFlightController = con
    }

    private static func handleRegistrationResult(
        _ res: Result<RegisterResponse, Error>,
        completion: @escaping PasskeyCompletion
    ) {
        switch res {
        case .success(let response):
            completion(Self.jsonString(from: response.toJson()))
        case .failure(let error):
            completion(.failure(Self.flutterError(from: error)))
        }
    }

    func getPasskeyCredentials(
        passkeyRequestJson: String,
        completion: @escaping PasskeyCompletion,
        preferImmediatelyAvailableCredentials: Bool = false
    ) {
        guard let requestData = passkeyRequestJson.data(using: .utf8),
              let passKeyOption = (try? JSONSerialization.jsonObject(with: requestData)) as? [String: Any] else {
            completion(.failure(FlutterError(code: .invalidJson, message: "Invalid passkey request JSON")))
            return
        }
        let passkeyLoginRequest = PasskeyLoginRequest.fromJson(passKeyOption)

        let challengeString = passkeyLoginRequest.challenge
        let rpId = passkeyLoginRequest.rpId
        let conditionalUI = passkeyLoginRequest.conditionalUI

        let challengeData = Data(base64Encoded: challengeString)
            ?? challengeString.data(using: .utf8)?.base64EncodedData()
        guard let challengeData = challengeData else {
            completion(.failure(FlutterError(code: .invalidChallenge, message: "Invalid challenge")))
            return
        }

        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let request = platformProvider.createCredentialAssertionRequest(challenge: challengeData)

        // Restrict the credential picker to the descriptors the relying party allows.
        // Leaving `allowedCredentials` untouched when the list is empty keeps the
        // WebAuthn default of offering every credential registered for the rpId.
        // `allowedCredentials` is iOS 15+ and this type is already gated to iOS 16+,
        // so no availability check is required here.
        if !passkeyLoginRequest.allowCredentialIDs.isEmpty {
            request.allowedCredentials = parseCredentials(
                credentialIDs: passkeyLoginRequest.allowCredentialIDs
            )
        }

        let con = AuthenticateController { [weak self] res in
            self?.lock.unlock()
            Self.handleAuthenticationResult(res, completion: completion)
        }
        con.run(
            request: request,
            conditionalUI: conditionalUI,
            preferImmediatelyAvailableCredentials: preferImmediatelyAvailableCredentials
        )
        inFlightController = con
    }

    private static func handleAuthenticationResult(
        _ res: Result<AuthenticateResponse, Error>,
        completion: @escaping PasskeyCompletion
    ) {
        switch res {
        case .success(let response):
            completion(Self.jsonString(from: response.toJson()))
        case .failure(let error):
            completion(.failure(Self.flutterError(from: error)))
        }
    }

    private static func jsonString(from json: [String: Any]) -> Result<String, Error> {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return .failure(FlutterError(
                    code: .jsonConversionError, message: "Failed to convert response to JSON string"
                ))
            }
            return .success(jsonString)
        } catch {
            return .failure(FlutterError(code: .jsonParsingError, message: error.localizedDescription))
        }
    }

    private static func flutterError(from error: Error) -> FlutterError {
        if let flutterError = error as? FlutterError {
            return flutterError
        }
        if let asError = error as? ASAuthorizationError {
            return FlutterError(from: asError)
        }
        return FlutterError(fromNSError: error as NSError)
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
