import { create, get } from '@github/webauthn-json';

/**
 * Minimal ambient typings for the Google Identity Services (GIS) client
 * library (https://accounts.google.com/gsi/client), loaded lazily.
 * Reference: https://developers.google.com/identity/gsi/web/reference/js-reference
 */
interface GsiCredentialResponse {
  credential: string;
  select_by?: string;
}

interface GsiInitializeConfig {
  client_id: string;
  callback: (response: GsiCredentialResponse) => void;
  nonce?: string;
  auto_select?: boolean;
  // Route the handshake through the browser's native FedCM UI (the same
  // mechanism Android's Credential Manager relies on) instead of GIS's
  // legacy iframe-based prompt.
  use_fedcm_for_prompt?: boolean;
  use_fedcm_for_button?: boolean;
  itp_support?: boolean;
}

interface GsiPromptMomentNotification {
  isNotDisplayed: () => boolean;
  getNotDisplayedReason: () => string;
  isSkippedMoment: () => boolean;
  getSkippedReason: () => string;
}

interface GsiAccountsId {
  initialize: (config: GsiInitializeConfig) => void;
  prompt: (callback?: (notification: GsiPromptMomentNotification) => void) => void;
  renderButton: (parent: HTMLElement, options: Record<string, unknown>) => void;
  cancel: () => void;
}

declare global {
  interface Window {
    google?: {
      accounts: {
        id: GsiAccountsId;
      };
    };
  }
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
   * Generate a cryptographically random nonce, used when the caller does not
   * supply one. Mirrors Android generating a fresh nonce for its
   * GetGoogleIdOption/GetSignInWithGoogleOption builders.
   */
  private static _generateSecureNonce(): string {
    const bytes = new Uint8Array(32);
    crypto.getRandomValues(bytes);
    return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
  }

  // Cached promise for the lazily-loaded GIS <script> tag.
  private static _gisScriptPromise: Promise<void> | null = null;

  // Off-screen container GIS renders its real "Sign in with Google" button
  // into. Google only drives the flow from a genuine click on its own
  // button, so button flow renders here and forwards the app's click to it.
  private static _gisButtonContainer: HTMLElement | null = null;

  /**
   * Lazily loads the Google Identity Services client library.
   * @returns Promise that resolves once `window.google.accounts.id` is available
   */
  private static _loadGoogleIdentityServices(): Promise<void> {
    if (typeof window === 'undefined' || typeof document === 'undefined') {
      return Promise.reject(new Error('Google Identity Services requires a browser environment'));
    }
    if (window.google?.accounts?.id) {
      return Promise.resolve();
    }
    if (!CredentialManagerWeb._gisScriptPromise) {
      CredentialManagerWeb._gisScriptPromise = new Promise<void>((resolve, reject) => {
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
  private static _getGisButtonContainer(): HTMLElement {
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
  static async saveGoogleCredential(useButtonFlow: boolean, nonce?: string | null): Promise<string | null> {
    if (!CredentialManagerWeb._googleClientId) {
      throw new Error('Google Client ID is not configured. Please provide googleClientId in init()');
    }

    try {
      await CredentialManagerWeb._loadGoogleIdentityServices();
    } catch (error) {
      throw new Error(
        `Failed to load Google Identity Services: ${error instanceof Error ? error.message : String(error)}`
      );
    }

    const google = window.google;
    if (!google?.accounts?.id) {
      throw new Error('Google Identity Services failed to initialize');
    }

    const clientId = CredentialManagerWeb._googleClientId;
    const effectiveNonce = nonce || CredentialManagerWeb._generateSecureNonce();

    return new Promise<string | null>((resolve, reject) => {
      let settled = false;

      google.accounts.id.initialize({
        client_id: clientId,
        nonce: effectiveNonce,
        auto_select: false,
        use_fedcm_for_prompt: true,
        use_fedcm_for_button: true,
        itp_support: true,
        callback: (response: GsiCredentialResponse) => {
          if (settled) return;
          settled = true;
          try {
            resolve(JSON.stringify(CredentialManagerWeb._decodeGoogleIdToken(response.credential)));
          } catch (error) {
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
        const clickable = container.querySelector<HTMLElement>('div[role="button"]');
        if (!clickable) {
          settled = true;
          reject(new Error('Failed to render Google Sign-In button'));
          return;
        }
        clickable.click();
      } else {
        google.accounts.id.prompt((notification: GsiPromptMomentNotification) => {
          if (settled) return;
          if (notification.isNotDisplayed() || notification.isSkippedMoment()) {
            settled = true;
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
  private static _decodeGoogleIdToken(idToken: string): Record<string, unknown> {
    const parts = idToken.split('.');
    if (parts.length !== 3) {
      throw new Error('Invalid JWT format received from Google Identity Services');
    }

    let payload: any;
    try {
      let base64 = parts[1].replace(/-/g, '+').replace(/_/g, '/');
      while (base64.length % 4) {
        base64 += '=';
      }
      payload = JSON.parse(atob(base64));
    } catch (error) {
      throw new Error(`Failed to decode Google ID token payload: ${error instanceof Error ? error.message : String(error)}`);
    }

    return {
      id: payload.email ?? payload.sub,
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

