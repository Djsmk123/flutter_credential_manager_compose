//
//  RegisterController.swift
//  Pods
//
//  Created by Mobin on 05/10/24.
//

import AuthenticationServices
import LocalAuthentication
import Flutter
import Foundation

@available(iOS 16.0, *)
class RegisterController: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, Cancellable {
    private var completion: ((Result<RegisterResponse, Error>) -> Void)?
    private var cancelAuthorization: (() -> Void)?;

    init(completion: @escaping ((Result<RegisterResponse, Error>) -> Void)) {
        self.completion = completion;
    }
    
    func run(request: ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest) {
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])

        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        func cancel() {
            authorizationController.cancel();
        }
        
        self.cancelAuthorization = cancel
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentialRegistration as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            let response = RegisterResponse(
                id: credentialRegistration.credentialID.toBase64URL(),
                rawId: credentialRegistration.credentialID.toBase64URL(),
                clientDataJSON: credentialRegistration.rawClientDataJSON.toBase64URL(),
                attestationObject: credentialRegistration.rawAttestationObject!.toBase64URL()
                
            )
            completion?(.success(response))
            break
        default:
            let message = "Expected instance of ASAuthorizationPlatformPublicKeyCredentialRegistration but got: " + authorization.credential.description
            completion?(.failure(FlutterError(code: CustomErrors.unexpectedAuthorizationResponse, message: message)))

        }

    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError customError: Error) {
        if let err = customError as? ASAuthorizationError {
            completion?(.failure(FlutterError(from: err)))
            return
        }
        
        let nsErr = customError as NSError
        completion?(.failure(FlutterError(fromNSError: nsErr)))
        return
    }


    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let delegate = UIApplication.shared.delegate else {
            fatalError("Unable to find UIApplication delegate for presentationAnchor")
        }
        
        if let flutterDelegate = delegate as? FlutterAppDelegate, let window = flutterDelegate.window {
            return window
        }
        
        // Try to get window from the app delegate using key-value coding
        if let appDelegate = delegate as? NSObject, let window = appDelegate.value(forKey: "window") as? UIWindow {
            return window
        }
        
        // Fallback: try to get the first window from the scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window
        }
        
        fatalError("Unable to find a valid UIWindow for presentationAnchor")
    }

    
    func cancel() {
        cancelAuthorization?();
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
