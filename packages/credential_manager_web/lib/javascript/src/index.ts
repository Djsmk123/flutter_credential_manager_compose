import { create, get } from '@github/webauthn-json';

/**
 * CredentialManagerWeb class for WebAuthn operations
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
          rpId: 'localhost',
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
   * Save Google credential (placeholder - requires OAuth 2.0 implementation)
   * @param _useButtonFlow - Whether to use button flow (unused, placeholder)
   * @returns Promise resolving to null (not implemented)
   */
  static async saveGoogleCredential(_useButtonFlow: boolean): Promise<string | null> {
    // Google Sign-In on web typically uses OAuth 2.0 flow
    // This is a placeholder implementation
    throw new Error('Google Sign-In on web requires OAuth 2.0 implementation');
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
}

// Initialize on load
CredentialManagerWeb.init();

// Export to global scope for Dart interop
(window as any).CredentialManagerWeb = CredentialManagerWeb;

export default CredentialManagerWeb;

