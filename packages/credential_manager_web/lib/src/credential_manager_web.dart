import 'dart:convert';
import 'dart:js_interop';

import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:credential_manager_web/src/passkey_authenticator_interop.dart'
    as passkey_interop;

/// Web implementation of Credential Manager using JavaScript interop.
class CredentialManagerWeb extends CredentialManagerPlatform {

  @override
  Future<String?> getPlatformVersion() async {
    final jsVersion = passkey_interop.getPlatformVersion();
    return jsVersion.toDart;
  }

  @override
  Future<void> init(
    bool preferImmediatelyAvailableCredentials,
    String? googleClientId,
  ) async {
    try {
      // Check if JavaScript is available
      try {
        passkey_interop.init();
      } catch (e) {
        throw CredentialException(
          code: 101,
          message: 'Initialization failure: JavaScript not loaded',
          details: 'CredentialManagerWeb JavaScript bundle not found. Make sure passkey_authenticator.js is loaded in index.html',
        );
      }
      
      // Initialize with preferences
      final jsPromise = passkey_interop.initialize(
        preferImmediatelyAvailableCredentials.toJS,
        googleClientId?.toJS,
      );
      final jsResult = await jsPromise.toDart;
      final resultString = jsResult.toDart;

      if (resultString == 'Initialization successful') {
        return;
      }

      throw CredentialException(
        code: 101,
        message: 'Initialization failure',
        details: 'Unexpected response: $resultString',
      );
    } catch (e) {
      if (e is CredentialException) {
        rethrow;
      }
      throw CredentialException(
        code: 101,
        message: 'Initialization failure',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> savePasswordCredentials(PasswordCredential credential) async {
    try {
      final credentialJson = jsonEncode(credential.toJson());
      final jsPromise = passkey_interop.savePasswordCredentials(credentialJson.toJS);
      final jsResult = await jsPromise.toDart;
      final resultString = jsResult.toDart;

      if (resultString == 'Credentials saved') {
        return;
      }

      throw CredentialException(
        code: 302,
        message: 'Create Credentials failed',
        details: resultString,
      );
    } catch (e) {
      if (e is CredentialException) {
        rethrow;
      }
      throw CredentialException(
        code: 302,
        message: 'Create Credentials failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<Credentials> getCredentials({
    CredentialLoginOptions? passKeyOption,
    FetchOptionsAndroid? fetchOptions,
  }) async {
    try {
      if (passKeyOption != null) {
        // Use JavaScript interop for passkey authentication
        final optionsJson = jsonEncode(passKeyOption.toJson());
        
        // Call the JavaScript interop function
        final jsPromise = passkey_interop.authenticatorLogin(optionsJson.toJS);
        final jsResult = await jsPromise.toDart;
        
        // Convert JSString to Dart String
        final resultString = jsResult.toDart;
        
        // Parse the JSON response
        final credentialData = jsonDecode(resultString) as Map<String, dynamic>;
        
        // Wrap in the expected format for CredentialResponseParser
        final response = {
          'type': 'PublicKeyCredentials',
          'data': jsonEncode(credentialData),
        };
        
        return CredentialResponseParser.parseCredentialResponse(response);
      } else {
        // Use JavaScript interop for password credentials
        final jsPromise = passkey_interop.getPasswordCredentials();
        final jsResult = await jsPromise.toDart;
        final resultString = jsResult.toDart;

        // Parse the JSON response
        final responseData = jsonDecode(resultString) as Map<String, dynamic>;
        
        return CredentialResponseParser.parseCredentialResponse(responseData);
      }
    } catch (e) {
      if (e is CredentialException) {
        rethrow;
      }
      throw CredentialException(
        code: 204,
        message: 'Login failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<GoogleIdTokenCredential?> saveGoogleCredential(
      bool useButtonFlow) async {
    try {
      final jsPromise = passkey_interop.saveGoogleCredential(useButtonFlow.toJS);
      final jsResult = await jsPromise.toDart;
      
      // Google Sign-In on web requires OAuth 2.0 implementation
      // This will throw an error from JavaScript
      if (jsResult == null) {
        throw CredentialException(
          code: 505,
          message: 'Google credential decode error',
          details: 'Google Sign-In on web requires OAuth 2.0 implementation',
        );
      }
      
      final resultString = jsResult.toDart;
      final credentialData = jsonDecode(resultString) as Map<String, dynamic>;
      return GoogleIdTokenCredential.fromJson(credentialData);
    } catch (e) {
      if (e is CredentialException) {
        rethrow;
      }
      throw CredentialException(
        code: 505,
        message: 'Google credential decode error',
        details: e.toString(),
      );
    }
  }

  @override
  Future<PublicKeyCredential> savePasskeyCredentials({
    required CredentialCreationOptions request,
  }) async {
    try {
      // Convert request to JSON string for JavaScript interop
      final requestJson = jsonEncode(request.toJson());
      
      // Call the JavaScript interop function
      final jsPromise = passkey_interop.authenticatorRegister(requestJson.toJS);
      final jsResult = await jsPromise.toDart;
      
      // Convert JSString to Dart String
      final resultString = jsResult.toDart;
      
      // Parse the JSON response
      final credentialData = jsonDecode(resultString) as Map<String, dynamic>;
      final credential = PublicKeyCredential.fromJson(credentialData);
      
      return credential;
    } catch (e) {
      if (e is CredentialException) {
        rethrow;
      }
      throw CredentialException(
        code: 302,
        message: 'Create Credentials failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      final jsPromise = passkey_interop.logout();
      final jsResult = await jsPromise.toDart;
      final resultString = jsResult.toDart;

      if (resultString == 'Logout successful') {
        return;
      }

      throw CredentialException(
        code: 504,
        message: 'Logout failed',
        details: resultString,
      );
    } catch (e) {
      if (e is CredentialException) {
        rethrow;
      }
      throw CredentialException(
        code: 504,
        message: 'Logout failed',
        details: e.toString(),
      );
    }
  }
}

