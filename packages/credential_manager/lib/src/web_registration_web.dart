import 'package:credential_manager_web/credential_manager_web.dart';

/// Registers the Web implementation. Only compiled when targeting web (where
/// `dart:js_interop` is resolvable) - see `web_registration_stub.dart` for
/// the non-web no-op counterpart.
void registerWebPlugin() {
  CredentialManagerWebPlugin.registerWithManual();
}
