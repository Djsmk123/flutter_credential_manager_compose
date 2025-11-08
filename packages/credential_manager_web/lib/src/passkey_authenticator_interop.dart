/// JavaScript interop bindings for PasskeyAuthenticator
/// 
/// This file provides Dart bindings to the PasskeyAuthenticator JavaScript class
/// which handles WebAuthn operations for passkey authentication.
@JS()
library bundle;

import 'dart:js_interop';

/// Initialize the PasskeyAuthenticator
@JS('CredentialManagerWeb.init')
external void init();

/// Register a new passkey credential
/// 
/// [options] - JSON string containing WebAuthn creation options
/// Returns a Promise resolving to JSON string of the credential response
@JS('CredentialManagerWeb.register')
external JSPromise<JSString> authenticatorRegister(JSString options);

/// Login/authenticate with an existing passkey credential
/// 
/// [options] - JSON string containing WebAuthn request options
/// Returns a Promise resolving to JSON string of the credential response
@JS('CredentialManagerWeb.login')
external JSPromise<JSString> authenticatorLogin(JSString options);

/// Cancel the current authenticator operation
@JS('CredentialManagerWeb.cancelCurrentAuthenticatorOperation')
external JSVoid authenticatorCancel();

/// Check if user-verifying platform authenticator is available
/// 
/// Returns a Promise resolving to boolean indicating availability
@JS('CredentialManagerWeb.isUserVerifyingPlatformAuthenticatorAvailable')
external JSPromise<JSBoolean?> isUserVerifyingPlatformAuthenticatorAvailable();

/// Check if conditional mediation is available
/// 
/// Returns a Promise resolving to boolean indicating availability
@JS('CredentialManagerWeb.isConditionalMediationAvailable')
external JSPromise<JSBoolean?> isConditionalMediationAvailable();

/// Check if passkey support is available in the browser
/// 
/// Returns boolean indicating if passkeys are supported
@JS('CredentialManagerWeb.hasPasskeySupport')
external JSBoolean hasPasskeySupport();

/// Get platform version (user agent)
/// 
/// Returns string representing the platform version
@JS('CredentialManagerWeb.getPlatformVersion')
external JSString getPlatformVersion();

/// Initialize with preferences
/// 
/// [preferImmediatelyAvailableCredentials] - Whether to prefer immediately available credentials
/// [googleClientId] - Google client ID (optional)
/// Returns a Promise resolving to success message
@JS('CredentialManagerWeb.initialize')
external JSPromise<JSString> initialize(
  JSBoolean preferImmediatelyAvailableCredentials,
  JSString? googleClientId,
);

/// Save password credentials
/// 
/// [credentialData] - JSON string containing credential data
/// Returns a Promise resolving to success message
@JS('CredentialManagerWeb.savePasswordCredentials')
external JSPromise<JSString> savePasswordCredentials(JSString credentialData);

/// Get password credentials
/// 
/// Returns a Promise resolving to JSON string of credential data
@JS('CredentialManagerWeb.getPasswordCredentials')
external JSPromise<JSString> getPasswordCredentials();

/// Save Google credential (placeholder - requires OAuth 2.0 implementation)
/// 
/// [useButtonFlow] - Whether to use button flow
/// Returns a Promise resolving to null (not implemented)
@JS('CredentialManagerWeb.saveGoogleCredential')
external JSPromise<JSString?> saveGoogleCredential(JSBoolean useButtonFlow);

/// Logout (clear credentials)
/// 
/// Returns a Promise resolving to success message
@JS('CredentialManagerWeb.logout')
external JSPromise<JSString> logout();

