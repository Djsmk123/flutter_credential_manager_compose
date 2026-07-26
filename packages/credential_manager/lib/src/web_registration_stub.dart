/// No-op on non-web platforms. The Web plugin implementation is only
/// registered when compiling for the web target - see
/// [web_registration_web.dart], which is swapped in via a conditional import
/// in `credential_manager_core.dart`.
///
/// This indirection keeps `dart:js_interop`-only code (used by
/// `credential_manager_web`) out of Android/iOS compilation units, where that
/// library isn't resolvable.
void registerWebPlugin() {}
