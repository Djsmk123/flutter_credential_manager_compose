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
declare class CredentialManagerWeb {
    private static instance;
    /**
     * Initialize the CredentialManagerWeb
     */
    static init(): void;
    /**
     * Register a new passkey credential
     * @param options - JSON string containing WebAuthn creation options
     * @returns Promise resolving to JSON string of the credential response
     */
    static register(options: string): Promise<string>;
    /**
     * Login/authenticate with an existing passkey credential
     * @param options - JSON string containing WebAuthn request options
     * @returns Promise resolving to JSON string of the credential response
     */
    static login(options: string): Promise<string>;
    /**
     * Get credentials (unified method for passkeys and Google Sign-In via FedCM)
     * Similar to Android's unified Credential Manager
     * @param options - JSON string containing fetch options and passkey options
     * @returns Promise resolving to JSON string of credential response
     */
    static getCredentials(options: string): Promise<string>;
    /**
     * Cancel the current authenticator operation
     */
    static cancelCurrentAuthenticatorOperation(): void;
    /**
     * Check if user-verifying platform authenticator is available
     * @returns Promise resolving to boolean indicating availability
     */
    static isUserVerifyingPlatformAuthenticatorAvailable(): Promise<boolean>;
    /**
     * Check if conditional mediation is available
     * @returns Promise resolving to boolean indicating availability
     */
    static isConditionalMediationAvailable(): Promise<boolean>;
    /**
     * Check if passkey support is available in the browser
     * @returns boolean indicating if passkeys are supported
     */
    static hasPasskeySupport(): boolean;
    /**
     * Get platform version (user agent)
     * @returns string representing the platform version
     */
    static getPlatformVersion(): string;
    /**
     * Initialize with preferences
     * @param preferImmediatelyAvailableCredentials - Whether to prefer immediately available credentials
     * @param googleClientId - Google Web OAuth client ID used for Google Identity Services
     *   initialization (required for saveGoogleCredential; pass null if Google Sign-In isn't used)
     * @returns Promise resolving to success message
     */
    static initialize(preferImmediatelyAvailableCredentials: boolean, googleClientId: string | null): Promise<string>;
    /**
     * Save password credentials
     * @param credentialData - JSON string containing credential data
     * @returns Promise resolving to success message
     */
    static savePasswordCredentials(credentialData: string): Promise<string>;
    /**
     * Get password credentials
     * @returns Promise resolving to JSON string of credential data
     */
    static getPasswordCredentials(): Promise<string>;
    /**
     * Generate a cryptographically random nonce, used when the caller does not
     * supply one. Mirrors Android generating a fresh nonce for its
     * GetGoogleIdOption/GetSignInWithGoogleOption builders.
     */
    private static _generateSecureNonce;
    private static _gisScriptPromise;
    private static _gisButtonContainer;
    /**
     * Lazily loads the Google Identity Services client library.
     * @returns Promise that resolves once `window.google.accounts.id` is available
     */
    private static _loadGoogleIdentityServices;
    /**
     * Returns the (created-once) off-screen container used to render GIS's
     * button for the button-flow path, clearing any previously rendered button.
     */
    private static _getGisButtonContainer;
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
    static saveGoogleCredential(useButtonFlow: boolean, nonce?: string | null): Promise<string | null>;
    /**
     * Decodes a Google ID token (JWT) into the GoogleIdTokenCredential JSON shape.
     * @param idToken - The ID token JWT returned by Google Identity Services
     */
    private static _decodeGoogleIdToken;
    /**
     * Logout (clear credentials)
     * @returns Promise resolving to success message
     */
    static logout(): Promise<string>;
    private static preferImmediatelyAvailableCredentials;
    private static _googleClientId;
}
export default CredentialManagerWeb;
