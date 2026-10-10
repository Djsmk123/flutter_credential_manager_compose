import Flutter
import UIKit
import Security
import AuthenticationServices
protocol Cancellable {
    func cancel()
}

public class CredentialManagerPlugin: NSObject, FlutterPlugin, CredentialManagerHostApi {
    var preferImmediatelyAvailableCredentials: Bool = false
    // Keeps every in-flight PasskeyService alive until its own completion fires. Without
    // this, the local `PasskeyService` in savePasskeyCredential/getPasskeyCredential below is
    // the only strong reference to it; it deallocates as soon as that method returns, and since
    // ASAuthorizationController's delegate/presentationContextProvider are weak, the completion
    // callback (success or failure) is silently dropped and the Dart `Future` hangs forever. A
    // plain array (not a single var) is required: a second passkey call overlapping the first
    // must not release the first service out from under its still-in-flight authorization.
    private var inFlightPasskeyServices: [AnyObject] = []

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = CredentialManagerPlugin()
        CredentialManagerHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    }

    @MainActor
    func getPlatformVersion() async throws -> String {
        return "iOS " + UIDevice.current.systemVersion
    }

    @MainActor
    func initialize(preferImmediatelyAvailableCredentials: Bool, googleClientId: String?) async throws {
        self.preferImmediatelyAvailableCredentials = preferImmediatelyAvailableCredentials
    }

    @MainActor
    func savePasskeyCredential(requestJson: String) async throws -> String {
        guard #available(iOS 16.0, *) else { throw Self.unsupportedPlatformError }
        return try await withCheckedThrowingContinuation { continuation in
            let passkeyService = PasskeyService()
            inFlightPasskeyServices.append(passkeyService)
            passkeyService.registerPasskeyCredentials(requestJson: requestJson) { [weak self] res in
                self?.inFlightPasskeyServices.removeAll { $0 === passkeyService }
                continuation.resume(with: res)
            }
        }
    }

    @MainActor
    func getPasskeyCredential(passkeyRequestJson: String) async throws -> String {
        guard #available(iOS 16.0, *) else { throw Self.unsupportedPlatformError }
        return try await withCheckedThrowingContinuation { continuation in
            let passkeyService = PasskeyService()
            inFlightPasskeyServices.append(passkeyService)
            passkeyService.getPasskeyCredentials(
                passkeyRequestJson: passkeyRequestJson,
                completion: { [weak self] res in
                    self?.inFlightPasskeyServices.removeAll { $0 === passkeyService }
                    continuation.resume(with: res)
                },
                preferImmediatelyAvailableCredentials: preferImmediatelyAvailableCredentials
            )
        }
    }

    // Pigeon dispatches host calls on the main actor; AuthenticationServices requires it too.
    // iOS keeps no credential session of its own, so there is nothing to clear.
    func logout() async throws {}

    private static var unsupportedPlatformError: FlutterError {
        // Built with the plain initializer: the `CustomErrors` convenience init is iOS 16+ only.
        FlutterError(
            code: String(describing: CustomErrors.unsupportedPlatform),
            message: "Passkey is not supported on this platform",
            details: nil
        )
    }
}
