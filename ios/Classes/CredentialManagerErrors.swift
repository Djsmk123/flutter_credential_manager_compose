//
//  PasskeyError.swift
//  Pods
//
//  Created by Mobin on 05/10/24.
//

import Foundation
import Flutter
import AuthenticationServices

@available(iOS 16.0, *)
extension FlutterError: @retroactive Error {
    convenience init(from error: ASAuthorizationError) {
        var code = ""
        switch (error.code) {
        case ASAuthorizationError.unknown:
            code = String(describing: CustomErrors.unknown)
            break
        case ASAuthorizationError.canceled:
            if (error.localizedDescription.contains("No credentials available for login.")) {
                code = String(describing: CustomErrors.noCredentialsAvailable)
            } else {
                code = String(describing: CustomErrors.cancelled)
            }
            break
        case ASAuthorizationError.invalidResponse:
            code = String(describing: CustomErrors.invalidResponse)
            break
        case ASAuthorizationError.notHandled:
            code = String(describing: CustomErrors.notHandled)
            break
        case ASAuthorizationError.failed:
            if (error.localizedDescription.contains("is not associated with domain")) {
                code = String(describing: CustomErrors.domainNotAssociated)
            } else {
                code = String(describing: CustomErrors.failed)
            }
            break
        default:
            code = String(describing: CustomErrors.unknown)
            break
        }

        self.init(code: code, message: error.localizedDescription, details: "")
    }
    
    convenience init(fromNSError error: NSError) {
        var code = ""
        if (error.domain == "WKErrorDomain" && error.code == 8) {
            code = String(describing: CustomErrors.excludeCredentialsMatch)
        } else {
            code = "ios-unhandled-" + error.domain
        }
 
        self.init(code: code, message: error.localizedDescription, details: "")
    }

    convenience init(code: CustomErrors, message: String = "") {
        self.init(code: String(describing: code), message: message, details: "")
    }
}

enum CustomErrors: Error {
    case decodingChallenge
    case unexpectedAuthorizationResponse
    case unknown
    case parsingError
    case invalidArguments
    case invalidJson
    case invalidJsonStructure
    case invalidRegisterRequest
    case invalidData
    case jsonConversionError
    case jsonParsingError
    case invalidPasskeyOption
    case invalidChallenge
    case noCredentialsAvailable
    case cancelled
    case invalidResponse
    case notHandled
    case domainNotAssociated
    case failed
    case excludeCredentialsMatch
    case unsupportedPlatform
}
extension CustomErrors: CustomStringConvertible {
    var description: String {
        switch self {
        case .decodingChallenge:
            return "decoding-challenge"
        case .unexpectedAuthorizationResponse:
            return "unexpected-authorization-response"
        case .unknown:
            return "unknown"
        case .parsingError:
            return "parsing-error"
        case .invalidArguments:
            return "invalid-arguments"
        case .invalidJson:
            return "invalid-json"
        case .invalidJsonStructure:
            return "invalid-json-structure"
        case .invalidRegisterRequest:
            return "invalid-register-request"
        case .invalidData:
            return "invalid-data"
        case .jsonConversionError:
            return "json-conversion-error"
        case .jsonParsingError:
            return "json-parsing-error"
        case .invalidPasskeyOption:
            return "invalid-passkey-option"
        case .invalidChallenge:
            return "invalid-challenge"
        case .noCredentialsAvailable:
            return "no-credentials-available"
        case .cancelled:
            return "cancelled"
        case .invalidResponse:
            return "invalid-response"
        case .notHandled:
            return "not-handled"
        case .domainNotAssociated:
            return "domain-not-associated"
        case .failed:
            return "failed"
        case .excludeCredentialsMatch:
            return "exclude-credentials-match"
        case .unsupportedPlatform:
            return "unsupported-platform"
        }
    }

    
}
