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
   * CredentialManagerWeb class for WebAuthn and FedCM operations
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
       * Get credentials (unified method for passkeys and Google Sign-In via FedCM)
       * Similar to Android's unified Credential Manager
       * @param options - JSON string containing fetch options and passkey options
       * @returns Promise resolving to JSON string of credential response
       */
      static async getCredentials(options) {
          try {
              const fetchOptions = JSON.parse(options);
              const passKeyOption = fetchOptions.passKeyOption || null;
              const fetchOptionsConfig = fetchOptions.fetchOptions || {
                  passKey: true,
                  googleCredential: true,
                  passwordCredential: false, // Not supported via FedCM
              };
              // Check if any option is enabled
              if (!fetchOptionsConfig.passKey && !fetchOptionsConfig.googleCredential) {
                  throw new Error('At least one credential type must be enabled');
              }
              // Try to get credentials in priority order: passkey > Google Sign-In
              const errors = [];
              // 1. Try passkey first if enabled
              if (fetchOptionsConfig.passKey && passKeyOption) {
                  try {
                      const passkeyCredential = await this.login(JSON.stringify(passKeyOption));
                      // passkeyCredential is already a JSON string
                      // CredentialResponseParser expects data as a JSON string for PublicKeyCredentials
                      return JSON.stringify({
                          type: 'PublicKeyCredentials',
                          data: passkeyCredential, // Keep as JSON string
                      });
                  }
                  catch (error) {
                      errors.push(`Passkey: ${error instanceof Error ? error.message : String(error)}`);
                      // Continue to try Google Sign-In
                  }
              }
              // 2. Try Google Sign-In via FedCM if enabled
              if (fetchOptionsConfig.googleCredential) {
                  try {
                      if (!CredentialManagerWeb._googleClientId) {
                          throw new Error('Google Client ID is not configured');
                      }
                      // Use passive mode for unified credential fetch
                      const googleCredential = await this.saveGoogleCredential(false);
                      if (googleCredential) {
                          // googleCredential is already a JSON string, parse it to get the data object
                          const googleData = JSON.parse(googleCredential);
                          return JSON.stringify({
                              type: 'GoogleIdTokenCredentials',
                              data: googleData,
                          });
                      }
                  }
                  catch (error) {
                      errors.push(`Google Sign-In: ${error instanceof Error ? error.message : String(error)}`);
                  }
              }
              // If all attempts failed, throw an error
              throw new Error(`Failed to get credentials. Errors: ${errors.join('; ')}`);
          }
          catch (error) {
              throw new Error(`Failed to get credentials: ${error instanceof Error ? error.message : String(error)}`);
          }
      }
      /**
       * Cancel the current authenticator operation
       */
      static cancelCurrentAuthenticatorOperation() {
          var _a, _b, _c;
          // WebAuthn doesn't provide a direct cancel method.
          // Cancel any in-flight Google Identity Services flow.
          (_c = (_b = (_a = window.google) === null || _a === void 0 ? void 0 : _a.accounts) === null || _b === void 0 ? void 0 : _b.id) === null || _c === void 0 ? void 0 : _c.cancel();
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
       * @param googleClientId - Google Web OAuth client ID used for Google Identity Services
       *   initialization (required for saveGoogleCredential; pass null if Google Sign-In isn't used)
       * @returns Promise resolving to success message
       */
      static async initialize(preferImmediatelyAvailableCredentials, googleClientId) {
          // Check if Credential Management API is available
          if (!navigator.credentials) {
              throw new Error('Credential Management API is not supported in this browser');
          }
          // Store initialization parameters
          CredentialManagerWeb.preferImmediatelyAvailableCredentials = preferImmediatelyAvailableCredentials;
          CredentialManagerWeb._googleClientId = googleClientId;
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
              // TypeScript's lib.dom.d.ts doesn't model the Credential Management API's `password`
              // option on CredentialRequestOptions, so this needs an escape hatch to `any`.
              const options = {
                  password: true,
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
       * Generate a cryptographically random nonce, used when the caller does not
       * supply one. Mirrors Android generating a fresh nonce for its
       * GetGoogleIdOption/GetSignInWithGoogleOption builders.
       */
      static _generateSecureNonce() {
          const bytes = new Uint8Array(32);
          crypto.getRandomValues(bytes);
          return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
      }
      /**
       * Lazily loads the Google Identity Services client library.
       * @returns Promise that resolves once `window.google.accounts.id` is available
       */
      static _loadGoogleIdentityServices() {
          var _a, _b;
          if (typeof window === 'undefined' || typeof document === 'undefined') {
              return Promise.reject(new Error('Google Identity Services requires a browser environment'));
          }
          if ((_b = (_a = window.google) === null || _a === void 0 ? void 0 : _a.accounts) === null || _b === void 0 ? void 0 : _b.id) {
              return Promise.resolve();
          }
          if (!CredentialManagerWeb._gisScriptPromise) {
              CredentialManagerWeb._gisScriptPromise = new Promise((resolve, reject) => {
                  const script = document.createElement('script');
                  script.src = 'https://accounts.google.com/gsi/client';
                  script.async = true;
                  script.defer = true;
                  script.onload = () => resolve();
                  script.onerror = () => reject(new Error('Failed to load Google Identity Services script'));
                  document.head.appendChild(script);
              });
          }
          return CredentialManagerWeb._gisScriptPromise;
      }
      /**
       * Returns the (created-once) off-screen container used to render GIS's
       * button for the button-flow path, clearing any previously rendered button.
       */
      static _getGisButtonContainer() {
          if (!CredentialManagerWeb._gisButtonContainer) {
              const container = document.createElement('div');
              container.style.position = 'fixed';
              container.style.top = '-9999px';
              container.style.left = '-9999px';
              container.setAttribute('aria-hidden', 'true');
              document.body.appendChild(container);
              CredentialManagerWeb._gisButtonContainer = container;
          }
          CredentialManagerWeb._gisButtonContainer.innerHTML = '';
          return CredentialManagerWeb._gisButtonContainer;
      }
      /**
       * Save Google credential using Google Identity Services (GIS), Google's
       * officially documented and supported integration - internally backed by
       * FedCM when the browser supports it.
       * Reference: https://developers.google.com/identity/sign-in/web/gsi-with-fedcm
       * @param useButtonFlow - Whether to use button flow (active mode) or passive One Tap mode
       * @param nonce - Optional caller-supplied nonce for replay protection. If omitted,
       *   a securely-generated random nonce is used instead. Mirrors the capabilities
       *   Android configures on its GetGoogleIdOption (One Tap)/GetSignInWithGoogleOption
       *   (button flow) builders, both of which set a per-request nonce.
       * @returns Promise resolving to JSON string of Google credential data
       */
      static async saveGoogleCredential(useButtonFlow, nonce) {
          var _a;
          if (!CredentialManagerWeb._googleClientId) {
              throw new Error('Google Client ID is not configured. Please provide googleClientId in init()');
          }
          try {
              await CredentialManagerWeb._loadGoogleIdentityServices();
          }
          catch (error) {
              throw new Error(`Failed to load Google Identity Services: ${error instanceof Error ? error.message : String(error)}`);
          }
          const google = window.google;
          if (!((_a = google === null || google === void 0 ? void 0 : google.accounts) === null || _a === void 0 ? void 0 : _a.id)) {
              throw new Error('Google Identity Services failed to initialize');
          }
          const clientId = CredentialManagerWeb._googleClientId;
          const effectiveNonce = nonce || CredentialManagerWeb._generateSecureNonce();
          return new Promise((resolve, reject) => {
              let settled = false;
              let timeoutId;
              google.accounts.id.initialize({
                  client_id: clientId,
                  nonce: effectiveNonce,
                  auto_select: false,
                  use_fedcm_for_prompt: true,
                  use_fedcm_for_button: true,
                  itp_support: true,
                  callback: (response) => {
                      if (settled)
                          return;
                      settled = true;
                      if (timeoutId !== undefined)
                          clearTimeout(timeoutId);
                      try {
                          resolve(JSON.stringify(CredentialManagerWeb._decodeGoogleIdToken(response.credential)));
                      }
                      catch (error) {
                          reject(error instanceof Error ? error : new Error(String(error)));
                      }
                  },
              });
              if (useButtonFlow) {
                  const container = CredentialManagerWeb._getGisButtonContainer();
                  google.accounts.id.renderButton(container, { type: 'standard' });
                  // GIS only starts the flow on a genuine click of its own rendered
                  // button. Forwarding the click here relies on the transient user
                  // activation from the app's own "Sign in with Google" button click
                  // that led to this call (the same approach the official
                  // google_sign_in_web plugin uses).
                  const clickable = container.querySelector('div[role="button"]');
                  if (!clickable) {
                      settled = true;
                      reject(new Error('Failed to render Google Sign-In button'));
                      return;
                  }
                  clickable.click();
              }
              else {
                  // Under FedCM, isNotDisplayed()/getNotDisplayedReason() are deprecated and the browser
                  // (not this callback) controls prompt visibility, so a skip/no-display doesn't always
                  // reach this notification. Fall back to a timeout so the Promise can't hang forever.
                  timeoutId = setTimeout(() => {
                      if (settled)
                          return;
                      settled = true;
                      reject(new Error('Google One Tap timed out waiting for a prompt response'));
                  }, 30000);
                  google.accounts.id.prompt((notification) => {
                      if (settled)
                          return;
                      if (notification.isNotDisplayed() || notification.isSkippedMoment()) {
                          settled = true;
                          clearTimeout(timeoutId);
                          const reason = notification.isNotDisplayed()
                              ? notification.getNotDisplayedReason()
                              : notification.getSkippedReason();
                          reject(new Error(`Google One Tap was not shown or was dismissed: ${reason}`));
                      }
                  });
              }
          });
      }
      /**
       * Decodes a Google ID token (JWT) into the GoogleIdTokenCredential JSON shape.
       * @param idToken - The ID token JWT returned by Google Identity Services
       */
      static _decodeGoogleIdToken(idToken) {
          var _a;
          const parts = idToken.split('.');
          if (parts.length !== 3) {
              throw new Error('Invalid JWT format received from Google Identity Services');
          }
          let payload;
          try {
              let base64 = parts[1].replace(/-/g, '+').replace(/_/g, '/');
              while (base64.length % 4) {
                  base64 += '=';
              }
              payload = JSON.parse(atob(base64));
          }
          catch (error) {
              throw new Error(`Failed to decode Google ID token payload: ${error instanceof Error ? error.message : String(error)}`);
          }
          return {
              id: (_a = payload.email) !== null && _a !== void 0 ? _a : payload.sub,
              idToken,
              displayName: payload.name,
              givenName: payload.given_name,
              familyName: payload.family_name,
              phoneNumber: payload.phone_number,
              profilePictureUri: payload.picture,
          };
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
  // Cached promise for the lazily-loaded GIS <script> tag.
  CredentialManagerWeb._gisScriptPromise = null;
  // Off-screen container GIS renders its real "Sign in with Google" button
  // into. Google only drives the flow from a genuine click on its own
  // button, so button flow renders here and forwards the app's click to it.
  CredentialManagerWeb._gisButtonContainer = null;
  // Static properties for storing initialization state
  CredentialManagerWeb.preferImmediatelyAvailableCredentials = false;
  //google client id
  CredentialManagerWeb._googleClientId = null;
  // Initialize on load
  CredentialManagerWeb.init();
  // Export to global scope for Dart interop
  window.CredentialManagerWeb = CredentialManagerWeb;

  return CredentialManagerWeb;

})();
