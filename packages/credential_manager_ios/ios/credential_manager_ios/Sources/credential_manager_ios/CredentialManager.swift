import Flutter
import UIKit
import Security
import AuthenticationServices
protocol Cancellable {
    func cancel()
}

public class CredentialManagerPlugin: NSObject, FlutterPlugin {
    var preferImmediatelyAvailableCredentials: Bool = false
    // Keeps every in-flight PasskeyService alive until its own FlutterResult fires. Without
    // this, the local `PasskeyService` in savePassKeyCredentials/getPasskeyCredentials below is
    // the only strong reference to it; it deallocates as soon as that method returns, and since
    // ASAuthorizationController's delegate/presentationContextProvider are weak, the completion
    // callback (success or failure) is silently dropped and the Dart Future hangs forever. A
    // plain array (not a single var) is required: a second passkey call overlapping the first
    // must not release the first service out from under its still-in-flight authorization.
    private var inFlightPasskeyServices: [AnyObject] = []

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "credential_manager", binaryMessenger: registrar.messenger())
        let instance = CredentialManagerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "init":
            initialize(call: call, result: result)
        case "save_public_key_credential":
            savePassKeyCredentials(call: call, result: result)
        case "get_passkey_credentials":
            getPasskeyCredentials(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    private func savePassKeyCredentials(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 16.0, *) {
            let passkeyService = PasskeyService()
            inFlightPasskeyServices.append(passkeyService)
            passkeyService.registerPasskeyCredentials(call: call) { [weak self] res in
                self?.inFlightPasskeyServices.removeAll { $0 === passkeyService }
                result(res)
            }
        } else {
            result(FlutterError(
                code: String(describing: CustomErrors.unsupportedPlatform),
                message: "Passkey is not supported on this platform",
                details: nil
            ))
        }
    }
    private func getPasskeyCredentials(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 16.0, *) {
            let passkeyService = PasskeyService()
            inFlightPasskeyServices.append(passkeyService)
            passkeyService.getPasskeyCredentials(
                call: call,
                result: { [weak self] res in
                    self?.inFlightPasskeyServices.removeAll { $0 === passkeyService }
                    result(res)
                },
                preferImmediatelyAvailableCredentials: preferImmediatelyAvailableCredentials
            )
        } else {
            result(FlutterError(
                code: String(describing: CustomErrors.unsupportedPlatform),
                message: "Passkey is not supported on this platform",
                details: nil
            ))
        }
    }

    private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let preferImmediatelyAvailableCredentials =
                args["prefer_immediately_available_credentials"] as? Bool else {
            result(FlutterError(
                code: String(describing: CustomErrors.invalidArguments),
                message: "Missing required fields",
                details: nil
            ))
            return
        }

        self.preferImmediatelyAvailableCredentials = preferImmediatelyAvailableCredentials
        result("Initialization successful")
    }
}
