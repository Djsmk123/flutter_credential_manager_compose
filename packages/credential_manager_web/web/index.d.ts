/**
 * CredentialManagerWeb class for WebAuthn operations
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
     * Save Google credential (placeholder - requires OAuth 2.0 implementation)
     * @param _useButtonFlow - Whether to use button flow (unused, placeholder)
     * @returns Promise resolving to null (not implemented)
     */
    static saveGoogleCredential(_useButtonFlow: boolean): Promise<string | null>;
    /**
     * Logout (clear credentials)
     * @returns Promise resolving to success message
     */
    static logout(): Promise<string>;
    private static preferImmediatelyAvailableCredentials;
}
export default CredentialManagerWeb;
