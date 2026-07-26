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
     * @param _googleClientId - Google client ID (optional, reserved for future use)
     * @returns Promise resolving to success message
     */
    static initialize(preferImmediatelyAvailableCredentials: boolean, _googleClientId: string | null): Promise<string>;
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
    /**
     * Save Google credential using FedCM (Federated Credential Management API)
     * @param useButtonFlow - Whether to use button flow (active mode) or passive mode
     * @param nonce - Optional caller-supplied nonce for replay protection. If omitted,
     *   a securely-generated random nonce is used instead.
     * @returns Promise resolving to JSON string of Google credential data
     */
    static saveGoogleCredential(useButtonFlow: boolean, nonce?: string | null): Promise<string | null>;
    /**
     * Exchange FedCM token for Google ID token
     * @param fedcmToken - Token received from FedCM (should be an ID token JWT)
     * @param _identityProvider - Identity provider information (unused, reserved for future)
     * @param _clientId - Google client ID (unused, reserved for future)
     * @returns Promise resolving to ID token response
     */
    private static _exchangeFedCMTokenForIdToken;
    /**
     * Logout (clear credentials)
     * @returns Promise resolving to success message
     */
    static logout(): Promise<string>;
    private static preferImmediatelyAvailableCredentials;
    private static _googleClientId;
}
export default CredentialManagerWeb;
