//
//  LoginWithPasskey.swift
//  Pods
//
//  Created by Mobin on 05/10/24.
//

import AuthenticationServices
import LocalAuthentication
import Flutter
import Foundation

@available(iOS 16.0, *)
class AuthenticateController: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, Cancellable {
    public var completion: ((Result<AuthenticateResponse, Error>) -> Void)?
    private var innerCancel: (() -> Void)?;
    
    init(completion: @escaping ((Result<AuthenticateResponse, Error>) -> Void)) {
        self.completion = completion;
    }
    
    func run(request: ASAuthorizationPlatformPublicKeyCredentialAssertionRequest, conditionalUI: Bool, preferImmediatelyAvailableCredentials: Bool) {
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        if (conditionalUI) {
            authorizationController.performAutoFillAssistedRequests()
        } else {
            authorizationController.performRequests(options: .preferImmediatelyAvailableCredentials)
        }

        func cancel() {
            authorizationController.cancel();
        }
        
        self.innerCancel = cancel
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let r as ASAuthorizationPublicKeyCredentialAssertion:
            let response = AuthenticateResponse(
                id: r.credentialID.toBase64URL(),
                rawId: r.credentialID.toBase64URL(),
                clientDataJSON: r.rawClientDataJSON.toBase64URL(),
                authenticatorData: r.rawAuthenticatorData.toBase64URL(),
                signature: r.signature.toBase64URL(),
                userHandle: r.userID.toBase64URL()
            )

            completion?(.success(response))
            break
        default:
            completion?(.failure(FlutterError(code: CustomErrors.unexpectedAuthorizationResponse)))
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let err = error as? ASAuthorizationError {
            completion?(.failure(FlutterError(from: err)))
        } else if let nsError = error as NSError? {
            completion?(.failure(FlutterError(fromNSError: nsError)))
        } else {
            completion?(.failure(FlutterError(code: CustomErrors.unknown)))
        }
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
        innerCancel?()
    }
}
