import Flutter
import UIKit
import Security
import AuthenticationServices
protocol Cancellable {
    func cancel()
}

public class CredentialManagerPlugin: NSObject, FlutterPlugin{
    var preferImmediatelyAvailableCredentials: Bool = false

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
    private func savePassKeyCredentials(call: FlutterMethodCall, result: @escaping FlutterResult){
        if #available(iOS 16.0, *) {
            let passkeyService: PasskeyService = PasskeyService()
            passkeyService.registerPasskeyCredentials(call: call, result: result)
        } else {
            result(FlutterError(code: String(describing: CustomErrors.unsupportedPlatform), message: "Passkey is not supported on this platform", details: nil))
        }
    }
    private func getPasskeyCredentials(call: FlutterMethodCall, result: @escaping FlutterResult){
        if #available(iOS 16.0, *) {
            let passkeyService: PasskeyService = PasskeyService()
            passkeyService.getPasskeyCredentials(call: call, result: result, preferImmediatelyAvailableCredentials: preferImmediatelyAvailableCredentials)
        } else {
            result(FlutterError(code: String(describing: CustomErrors.unsupportedPlatform), message: "Passkey is not supported on this platform", details: nil))
        }
    }
    

    private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let preferImmediatelyAvailableCredentials = args["prefer_immediately_available_credentials"] as? Bool else {
            result(FlutterError(code: String(describing: CustomErrors.invalidArguments), message: "Missing required fields", details: nil))
            return
        }

        self.preferImmediatelyAvailableCredentials = preferImmediatelyAvailableCredentials
        result("Initialization successful")
    }
}
