var CredentialManagerWeb = (function () {
  'use strict';

  // src/webauthn-json/base64url.ts
  function base64urlToBuffer(baseurl64String) {
    const padding = "==".slice(0, (4 - baseurl64String.length % 4) % 4);
    const base64String = baseurl64String.replace(/-/g, "+").replace(/_/g, "/") + padding;
    const str = atob(base64String);
    const buffer = new ArrayBuffer(str.length);
    const byteView = new Uint8Array(buffer);
    for (let i = 0; i < str.length; i++) {
      byteView[i] = str.charCodeAt(i);
    }
    return buffer;
  }
  function bufferToBase64url(buffer) {
    const byteView = new Uint8Array(buffer);
    let str = "";
    for (const charCode of byteView) {
      str += String.fromCharCode(charCode);
    }
    const base64String = btoa(str);
    const base64urlString = base64String.replace(/\+/g, "-").replace(
      /\//g,
      "_"
    ).replace(/=/g, "");
    return base64urlString;
  }

  // src/webauthn-json/convert.ts
  var copyValue = "copy";
  var convertValue = "convert";
  function convert(conversionFn, schema2, input) {
    if (schema2 === copyValue) {
      return input;
    }
    if (schema2 === convertValue) {
      return conversionFn(input);
    }
    if (schema2 instanceof Array) {
      return input.map((v) => convert(conversionFn, schema2[0], v));
    }
    if (schema2 instanceof Object) {
      const output = {};
      for (const [key, schemaField] of Object.entries(schema2)) {
        if (schemaField.derive) {
          const v = schemaField.derive(input);
          if (v !== void 0) {
            input[key] = v;
          }
        }
        if (!(key in input)) {
          if (schemaField.required) {
            throw new Error(`Missing key: ${key}`);
          }
          continue;
        }
        if (input[key] == null) {
          output[key] = null;
          continue;
        }
        output[key] = convert(
          conversionFn,
          schemaField.schema,
          input[key]
        );
      }
      return output;
    }
  }
  function derived(schema2, derive) {
    return {
      required: true,
      schema: schema2,
      derive
    };
  }
  function required(schema2) {
    return {
      required: true,
      schema: schema2
    };
  }
  function optional(schema2) {
    return {
      required: false,
      schema: schema2
    };
  }

  // src/webauthn-json/basic/schema.ts
  var publicKeyCredentialDescriptorSchema = {
    type: required(copyValue),
    id: required(convertValue),
    transports: optional(copyValue)
  };
  var simplifiedExtensionsSchema = {
    appid: optional(copyValue),
    appidExclude: optional(copyValue),
    credProps: optional(copyValue)
  };
  var simplifiedClientExtensionResultsSchema = {
    appid: optional(copyValue),
    appidExclude: optional(copyValue),
    credProps: optional(copyValue)
  };
  var credentialCreationOptions = {
    publicKey: required({
      rp: required(copyValue),
      user: required({
        id: required(convertValue),
        name: required(copyValue),
        displayName: required(copyValue)
      }),
      challenge: required(convertValue),
      pubKeyCredParams: required(copyValue),
      timeout: optional(copyValue),
      excludeCredentials: optional([publicKeyCredentialDescriptorSchema]),
      authenticatorSelection: optional(copyValue),
      attestation: optional(copyValue),
      extensions: optional(simplifiedExtensionsSchema)
    }),
    signal: optional(copyValue)
  };
  var publicKeyCredentialWithAttestation = {
    type: required(copyValue),
    id: required(copyValue),
    rawId: required(convertValue),
    authenticatorAttachment: optional(copyValue),
    response: required({
      clientDataJSON: required(convertValue),
      attestationObject: required(convertValue),
      transports: derived(
        copyValue,
        (response) => {
          var _a;
          return ((_a = response.getTransports) == null ? void 0 : _a.call(response)) || [];
        }
      )
    }),
    clientExtensionResults: derived(
      simplifiedClientExtensionResultsSchema,
      (pkc) => pkc.getClientExtensionResults()
    )
  };
  var credentialRequestOptions = {
    mediation: optional(copyValue),
    publicKey: required({
      challenge: required(convertValue),
      timeout: optional(copyValue),
      rpId: optional(copyValue),
      allowCredentials: optional([publicKeyCredentialDescriptorSchema]),
      userVerification: optional(copyValue),
      extensions: optional(simplifiedExtensionsSchema)
    }),
    signal: optional(copyValue)
  };
  var publicKeyCredentialWithAssertion = {
    type: required(copyValue),
    id: required(copyValue),
    rawId: required(convertValue),
    authenticatorAttachment: optional(copyValue),
    response: required({
      clientDataJSON: required(convertValue),
      authenticatorData: required(convertValue),
      signature: required(convertValue),
      userHandle: required(convertValue)
    }),
    clientExtensionResults: derived(
      simplifiedClientExtensionResultsSchema,
      (pkc) => pkc.getClientExtensionResults()
    )
  };

  // src/webauthn-json/basic/api.ts
  function createRequestFromJSON(requestJSON) {
    return convert(base64urlToBuffer, credentialCreationOptions, requestJSON);
  }
  function createResponseToJSON(credential) {
    return convert(
      bufferToBase64url,
      publicKeyCredentialWithAttestation,
      credential
    );
  }
  async function create(requestJSON) {
    const credential = await navigator.credentials.create(
      createRequestFromJSON(requestJSON)
    );
    return createResponseToJSON(credential);
  }
  function getRequestFromJSON(requestJSON) {
    return convert(base64urlToBuffer, credentialRequestOptions, requestJSON);
  }
  function getResponseToJSON(credential) {
    return convert(
      bufferToBase64url,
      publicKeyCredentialWithAssertion,
      credential
    );
  }
  async function get(requestJSON) {
    const credential = await navigator.credentials.get(
      getRequestFromJSON(requestJSON)
    );
    return getResponseToJSON(credential);
  }

  /**
   * CredentialManagerWeb class for WebAuthn operations
   */
  class CredentialManagerWeb {
      /**
       * Initialize the CredentialManagerWeb
       */
      static init() {
          if (!CredentialManagerWeb.instance) {
              CredentialManagerWeb.instance = new CredentialManagerWeb();
          }
      }
      /**
       * Register a new passkey credential
       * @param options - JSON string containing WebAuthn creation options
       * @returns Promise resolving to JSON string of the credential response
       */
      static async register(options) {
          try {
              const creationOptions = JSON.parse(options);
              // The @github/webauthn-json create function expects CredentialCreationOptionsJSON
              // which wraps PublicKeyCredentialCreationOptionsJSON in a publicKey property
              // AbortSignal is optional, so we omit it
              const credential = await create({
                  publicKey: creationOptions
              });
              return JSON.stringify(credential);
          }
          catch (error) {
              throw new Error(`Passkey registration failed: ${error instanceof Error ? error.message : String(error)}`);
          }
      }
      /**
       * Login/authenticate with an existing passkey credential
       * @param options - JSON string containing WebAuthn request options
       * @returns Promise resolving to JSON string of the credential response
       */
      static async login(options) {
          try {
              const requestOptions = JSON.parse(options);
              // The @github/webauthn-json get function expects CredentialRequestOptionsJSON
              // which wraps PublicKeyCredentialRequestOptionsJSON in a publicKey property
              // The library handles base64url string to ArrayBuffer conversion automatically
              const credential = await get({
                  publicKey: requestOptions
              });
              // The get function returns PublicKeyCredentialWithAssertionJSON
              // which already has base64url-encoded strings, so we can return it directly
              return JSON.stringify(credential);
          }
          catch (error) {
              throw new Error(`Passkey login failed: ${error instanceof Error ? error.message : String(error)}`);
          }
      }
      /**
       * Cancel the current authenticator operation
       */
      static cancelCurrentAuthenticatorOperation() {
          // WebAuthn doesn't provide a direct cancel method
          // This is a placeholder for any cleanup needed
      }
      /**
       * Check if user-verifying platform authenticator is available
       * @returns Promise resolving to boolean indicating availability
       */
      static async isUserVerifyingPlatformAuthenticatorAvailable() {
          try {
              if (!window.PublicKeyCredential) {
                  return false;
              }
              return await PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable();
          }
          catch {
              return false;
          }
      }
      /**
       * Check if conditional mediation is available
       * @returns Promise resolving to boolean indicating availability
       */
      static async isConditionalMediationAvailable() {
          try {
              if (!window.PublicKeyCredential) {
                  return false;
              }
              return await PublicKeyCredential.isConditionalMediationAvailable();
          }
          catch {
              return false;
          }
      }
      /**
       * Check if passkey support is available in the browser
       * @returns boolean indicating if passkeys are supported
       */
      static hasPasskeySupport() {
          return typeof window !== 'undefined' &&
              typeof window.PublicKeyCredential !== 'undefined' &&
              typeof navigator !== 'undefined' &&
              typeof navigator.credentials !== 'undefined';
      }
      /**
       * Get platform version (user agent)
       * @returns string representing the platform version
       */
      static getPlatformVersion() {
          return navigator.userAgent;
      }
      /**
       * Initialize with preferences
       * @param preferImmediatelyAvailableCredentials - Whether to prefer immediately available credentials
       * @param _googleClientId - Google client ID (optional, reserved for future use)
       * @returns Promise resolving to success message
       */
      static async initialize(preferImmediatelyAvailableCredentials, _googleClientId) {
          // Check if Credential Management API is available
          if (!navigator.credentials) {
              throw new Error('Credential Management API is not supported in this browser');
          }
          // Store initialization parameters
          CredentialManagerWeb.preferImmediatelyAvailableCredentials = preferImmediatelyAvailableCredentials;
          return 'Initialization successful';
      }
      /**
       * Save password credentials
       * @param credentialData - JSON string containing credential data
       * @returns Promise resolving to success message
       */
      static async savePasswordCredentials(credentialData) {
          try {
              if (!navigator.credentials || !navigator.credentials.create) {
                  throw new Error('Credential Management API is not supported');
              }
              const data = JSON.parse(credentialData);
              const passwordCredential = new window.PasswordCredential({
                  id: data['id'] || data['username'] || '',
                  password: data['password'] || '',
                  name: data['name'] || data['username'] || '',
              });
              await navigator.credentials.create({ password: passwordCredential });
              return 'Credentials saved';
          }
          catch (error) {
              throw new Error(`Failed to save password credentials: ${error instanceof Error ? error.message : String(error)}`);
          }
      }
      /**
       * Get password credentials
       * @returns Promise resolving to JSON string of credential data
       */
      static async getPasswordCredentials() {
          try {
              if (!navigator.credentials || !navigator.credentials.get) {
                  throw new Error('Credential Management API is not supported');
              }
              const options = {
                  publicKey: {
                      challenge: new Uint8Array(32),
                      rpId: 'localhost',
                      userVerification: 'required',
                  },
                  mediation: (CredentialManagerWeb.preferImmediatelyAvailableCredentials
                      ? 'silent'
                      : 'optional')
              };
              const credential = await navigator.credentials.get(options);
              if (credential && credential.type === 'password') {
                  const passwordCred = credential;
                  const response = {
                      'type': 'PasswordCredentials',
                      'data': {
                          'id': passwordCred.id,
                          'password': passwordCred.password,
                          'name': passwordCred.name || passwordCred.id,
                      }
                  };
                  return JSON.stringify(response);
              }
              else {
                  throw new Error('No credentials found');
              }
          }
          catch (error) {
              throw new Error(`Failed to get password credentials: ${error instanceof Error ? error.message : String(error)}`);
          }
      }
      /**
       * Save Google credential (placeholder - requires OAuth 2.0 implementation)
       * @param _useButtonFlow - Whether to use button flow (unused, placeholder)
       * @returns Promise resolving to null (not implemented)
       */
      static async saveGoogleCredential(_useButtonFlow) {
          // Google Sign-In on web typically uses OAuth 2.0 flow
          // This is a placeholder implementation
          throw new Error('Google Sign-In on web requires OAuth 2.0 implementation');
      }
      /**
       * Logout (clear credentials)
       * @returns Promise resolving to success message
       */
      static async logout() {
          // Credential Management API doesn't provide a direct logout method
          // This is a placeholder for any cleanup needed
          return 'Logout successful';
      }
  }
  CredentialManagerWeb.instance = null;
  // Static properties for storing initialization state
  CredentialManagerWeb.preferImmediatelyAvailableCredentials = false;
  // Initialize on load
  CredentialManagerWeb.init();
  // Export to global scope for Dart interop
  window.CredentialManagerWeb = CredentialManagerWeb;

  return CredentialManagerWeb;

})();
