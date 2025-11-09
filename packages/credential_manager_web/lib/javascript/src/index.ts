import { create, get } from '@github/webauthn-json';

/**
 * Type definitions for FedCM (Federated Credential Management)
 * Based on: https://developer.chrome.com/docs/identity/fedcm/overview
 */
interface IdentityProvider {
  configURL: string;
  clientId: string;
  nonce?: string;
}

interface IdentityCredentialRequestOptions {
  providers: IdentityProvider[];
}

interface IdentityCredential extends Credential {
  token: string;
  identityProvider: IdentityProvider;
}

// Extend CredentialRequestOptions to include identity property for FedCM
interface FedCMCredentialRequestOptions extends CredentialRequestOptions {
  identity?: IdentityCredentialRequestOptions;
}

/**
 * CredentialManagerWeb class for WebAuthn and FedCM operations
 */
class CredentialManagerWeb {
  private static instance: CredentialManagerWeb | null = null;

  /**
   * Initialize the CredentialManagerWeb
   */
  static init(): void {
    if (!CredentialManagerWeb.instance) {
      CredentialManagerWeb.instance = new CredentialManagerWeb();
    }
  }

  /**
   * Register a new passkey credential
   * @param options - JSON string containing WebAuthn creation options
   * @returns Promise resolving to JSON string of the credential response
   */
  static async register(options: string): Promise<string> {
    try {
      const creationOptions = JSON.parse(options);
      
      // The @github/webauthn-json create function expects CredentialCreationOptionsJSON
      // which wraps PublicKeyCredentialCreationOptionsJSON in a publicKey property
      // AbortSignal is optional, so we omit it
      const credential = await create({
        publicKey: creationOptions
      });
      return JSON.stringify(credential);
    } catch (error) {
      throw new Error(`Passkey registration failed: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * Login/authenticate with an existing passkey credential
   * @param options - JSON string containing WebAuthn request options
   * @returns Promise resolving to JSON string of the credential response
   */
  static async login(options: string): Promise<string> {
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
    } catch (error) {
      throw new Error(`Passkey login failed: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * Get credentials (unified method for passkeys and Google Sign-In via FedCM)
   * Similar to Android's unified Credential Manager
   * @param options - JSON string containing fetch options and passkey options
   * @returns Promise resolving to JSON string of credential response
   */
  static async getCredentials(options: string): Promise<string> {
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
      const errors: string[] = [];

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
        } catch (error) {
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
        } catch (error) {
          errors.push(`Google Sign-In: ${error instanceof Error ? error.message : String(error)}`);
        }
      }

      // If all attempts failed, throw an error
      throw new Error(`Failed to get credentials. Errors: ${errors.join('; ')}`);
    } catch (error) {
      throw new Error(`Failed to get credentials: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * Cancel the current authenticator operation
   */
  static cancelCurrentAuthenticatorOperation(): void {
    // WebAuthn doesn't provide a direct cancel method
    // This is a placeholder for any cleanup needed
  }

  /**
   * Check if user-verifying platform authenticator is available
   * @returns Promise resolving to boolean indicating availability
   */
  static async isUserVerifyingPlatformAuthenticatorAvailable(): Promise<boolean> {
    try {
      if (!window.PublicKeyCredential) {
        return false;
      }
      return await PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable();
    } catch {
      return false;
    }
  }

  /**
   * Check if conditional mediation is available
   * @returns Promise resolving to boolean indicating availability
   */
  static async isConditionalMediationAvailable(): Promise<boolean> {
    try {
      if (!window.PublicKeyCredential) {
        return false;
      }
      return await PublicKeyCredential.isConditionalMediationAvailable();
    } catch {
      return false;
    }
  }

  /**
   * Check if passkey support is available in the browser
   * @returns boolean indicating if passkeys are supported
   */
  static hasPasskeySupport(): boolean {
    return typeof window !== 'undefined' && 
           typeof window.PublicKeyCredential !== 'undefined' &&
           typeof navigator !== 'undefined' &&
           typeof navigator.credentials !== 'undefined';
  }

  /**
   * Get platform version (user agent)
   * @returns string representing the platform version
   */
  static getPlatformVersion(): string {
    return navigator.userAgent;
  }

  /**
   * Initialize with preferences
   * @param preferImmediatelyAvailableCredentials - Whether to prefer immediately available credentials
   * @param _googleClientId - Google client ID (optional, reserved for future use)
   * @returns Promise resolving to success message
   */
  static async initialize(
    preferImmediatelyAvailableCredentials: boolean,
    _googleClientId: string | null
  ): Promise<string> {
    // Check if Credential Management API is available
    if (!navigator.credentials) {
      throw new Error('Credential Management API is not supported in this browser');
    }

    // Store initialization parameters
    CredentialManagerWeb.preferImmediatelyAvailableCredentials = preferImmediatelyAvailableCredentials;
    CredentialManagerWeb._googleClientId = _googleClientId;
    return 'Initialization successful';
  }

  /**
   * Save password credentials
   * @param credentialData - JSON string containing credential data
   * @returns Promise resolving to success message
   */
  static async savePasswordCredentials(credentialData: string): Promise<string> {
    try {
      if (!navigator.credentials || !navigator.credentials.create) {
        throw new Error('Credential Management API is not supported');
      }

      const data = JSON.parse(credentialData);
      const passwordCredential = new (window as any).PasswordCredential({
        id: data['id'] || data['username'] || '',
        password: data['password'] || '',
        name: data['name'] || data['username'] || '',
      });

      await navigator.credentials.create({ password: passwordCredential } as any);
      return 'Credentials saved';
    } catch (error) {
      throw new Error(`Failed to save password credentials: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * Get password credentials
   * @returns Promise resolving to JSON string of credential data
   */
  static async getPasswordCredentials(): Promise<string> {
    try {
      if (!navigator.credentials || !navigator.credentials.get) {
        throw new Error('Credential Management API is not supported');
      }

      const options: CredentialRequestOptions = {
        publicKey: {
          challenge: new Uint8Array(32),
          rpId: CredentialManagerWeb._googleClientId || 'localhost',
          userVerification: 'required', 
        },
        mediation: (CredentialManagerWeb.preferImmediatelyAvailableCredentials 
          ? 'silent' 
          : 'optional') as CredentialMediationRequirement
      };

      const credential = await navigator.credentials.get(options);

      if (credential && credential.type === 'password') {
        const passwordCred = credential as any;
        const response = {
          'type': 'PasswordCredentials',
          'data': {
            'id': passwordCred.id,
            'password': passwordCred.password,
            'name': passwordCred.name || passwordCred.id,
          }
        };
        return JSON.stringify(response);
      } else {
        throw new Error('No credentials found');
      }
    } catch (error) {
      throw new Error(`Failed to get password credentials: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * Save Google credential using FedCM (Federated Credential Management API)
   * @param useButtonFlow - Whether to use button flow (active mode) or passive mode
   * @returns Promise resolving to JSON string of Google credential data
   */
  static async saveGoogleCredential(useButtonFlow: boolean): Promise<string | null> {
    try {
      // Check if FedCM is supported
      if (!navigator.credentials || !navigator.credentials.get) {
        throw new Error('Credential Management API is not supported');
      }

      // Check if Google Client ID is configured
      if (!CredentialManagerWeb._googleClientId) {
        throw new Error('Google Client ID is not configured. Please provide googleClientId in init()');
      }

      // FedCM configuration for Google
      // Reference: https://developer.chrome.com/docs/identity/fedcm/overview
      // Google's FedCM implementation uses the configURL approach
      // The configURL points to Google's FedCM configuration endpoint
      const identityProvider: IdentityProvider = {
        configURL: 'https://accounts.google.com/gsi/fedcm/config.json',
        clientId: CredentialManagerWeb._googleClientId,
      };

      // Configure FedCM options
      const credentialRequestOptions: FedCMCredentialRequestOptions = {
        identity: {
          providers: [identityProvider],
        },
        // Active mode requires user interaction (button click)
        // Passive mode shows automatically
        mediation: useButtonFlow ? 'required' : 'optional',
      };

      // Request credential using FedCM
      let credential: Credential | null;
      try {
        credential = await navigator.credentials.get(credentialRequestOptions);
      } catch (fedcmError: any) {
        // FedCM specific error handling
        const errorMessage = fedcmError?.message || String(fedcmError);
        
        // Provide more helpful error messages
        if (errorMessage.includes('network') || errorMessage.includes('retrieving')) {
          throw new Error(`FedCM network error: ${errorMessage}. Please check:\n1. Google Client ID is correctly configured in Google Cloud Console\n2. JavaScript origins include your domain (e.g., http://localhost:port)\n3. OAuth consent screen is properly configured\n4. Browser allows third-party sign-in (chrome://settings/content/federatedIdentityApi)`);
        }
        if (errorMessage.includes('user') || errorMessage.includes('cancel')) {
          throw new Error('User canceled or no account available');
        }
        throw new Error(`FedCM error: ${errorMessage}`);
      }

      if (!credential || credential.type !== 'identity') {
        throw new Error('No Google credential returned from FedCM');
      }

      // Cast to IdentityCredential
      const identityCred = credential as IdentityCredential;

      // Extract token from the credential
      // FedCM returns the ID token directly as a JWT
      const token = identityCred.token;

      if (!token) {
        throw new Error('No token received from FedCM. The identity provider may not have returned a token.');
      }

      // Exchange the FedCM token for Google ID token
      // This requires calling Google's token endpoint
      const idTokenResponse = await this._exchangeFedCMTokenForIdToken(
        token,
        identityCred.identityProvider,
        CredentialManagerWeb._googleClientId!
      );

      // Build response matching GoogleIdTokenCredential structure
      const response = {
        id: idTokenResponse.email || idTokenResponse.sub,
        idToken: idTokenResponse.id_token,
        displayName: idTokenResponse.name,
        givenName: idTokenResponse.given_name,
        familyName: idTokenResponse.family_name,
        phoneNumber: idTokenResponse.phone_number,
        profilePictureUri: idTokenResponse.picture,
      };

      return JSON.stringify(response);
    } catch (error) {
      throw new Error(`Failed to save Google credential: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * Exchange FedCM token for Google ID token
   * @param fedcmToken - Token received from FedCM (should be an ID token JWT)
   * @param _identityProvider - Identity provider information (unused, reserved for future)
   * @param _clientId - Google client ID (unused, reserved for future)
   * @returns Promise resolving to ID token response
   */
  private static async _exchangeFedCMTokenForIdToken(
    fedcmToken: string,
    _identityProvider: any,
    _clientId: string
  ): Promise<any> {
    try {
      // Google's FedCM implementation returns the ID token directly as a JWT
      // We need to decode it to extract user information
      
      // Parse JWT token
      const parts = fedcmToken.split('.');
      if (parts.length !== 3) {
        throw new Error('Invalid JWT token format received from FedCM');
      }
      
      // Decode the JWT payload (base64url decode)
      let payload: any;
      try {
        // Base64url decode: replace - with +, _ with /, and add padding if needed
        let base64 = parts[1].replace(/-/g, '+').replace(/_/g, '/');
        // Add padding if needed
        while (base64.length % 4) {
          base64 += '=';
        }
        const decodedPayload = atob(base64);
        payload = JSON.parse(decodedPayload);
      } catch (decodeError) {
        throw new Error(`Failed to decode JWT payload: ${decodeError instanceof Error ? decodeError.message : String(decodeError)}`);
      }
      
      // Extract user information from JWT claims
      return {
        id_token: fedcmToken,
        email: payload.email || payload['email'],
        sub: payload.sub || payload['sub'],
        name: payload.name || payload['name'],
        given_name: payload.given_name || payload['given_name'],
        family_name: payload.family_name || payload['family_name'],
        picture: payload.picture || payload['picture'],
        phone_number: payload.phone_number || payload['phone_number'],
      };
    } catch (error) {
      throw new Error(`Token processing failed: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * Logout (clear credentials)
   * @returns Promise resolving to success message
   */
  static async logout(): Promise<string> {
    // Credential Management API doesn't provide a direct logout method
    // This is a placeholder for any cleanup needed
    return 'Logout successful';
  }

  // Static properties for storing initialization state
  private static preferImmediatelyAvailableCredentials: boolean = false;
  //google client id
  private static _googleClientId: string | null = null;
}

// Initialize on load
CredentialManagerWeb.init();

// Export to global scope for Dart interop
(window as any).CredentialManagerWeb = CredentialManagerWeb;

export default CredentialManagerWeb;

