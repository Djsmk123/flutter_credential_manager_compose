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

/// Save Google credential using FedCM (Federated Credential Management API)
///
/// Uses the FedCM API for privacy-preserving Google Sign-In without third-party cookies.
/// See: https://developer.chrome.com/docs/identity/fedcm/overview
///
/// [useButtonFlow] - Whether to use button flow (active mode) or passive mode
///   - true: Active mode - requires user interaction (button click)
///   - false: Passive mode - shows automatically when user is signed in
/// [nonce] - Optional caller-supplied nonce for replay protection. If omitted,
///   a securely-generated random nonce is used instead, mirroring Android's
///   GetGoogleIdOption/GetSignInWithGoogleOption behavior.
/// Returns a Promise resolving to JSON string of Google credential data
@JS('CredentialManagerWeb.saveGoogleCredential')
external JSPromise<JSString?> saveGoogleCredential(JSBoolean useButtonFlow, [JSString? nonce]);

/// Get credentials (unified method for passkeys and Google Sign-In via FedCM)
///
/// Similar to Android's unified Credential Manager - fetches passkeys or Google Sign-In
/// based on fetchOptions configuration
///
/// [options] - JSON string containing fetch options and passkey options
/// Returns a Promise resolving to JSON string of credential response
@JS('CredentialManagerWeb.getCredentials')
external JSPromise<JSString> getCredentials(JSString options);

/// Logout (clear credentials)
///
/// Returns a Promise resolving to success message
@JS('CredentialManagerWeb.logout')
external JSPromise<JSString> logout();
