package com.smkwinner.cred_manager.credential_manager

import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential

/**
 * Data class representing password credentials.
 * @property username The username associated with the password.
 * @property password The password string.
 */
data class PasswordCredentials(
    val username: String,
    val password: String
)

/**
 * Class representing a response from the Credential Manager.
 * @property type The type of credential contained in the response.
 * @property passwordCredentials Password credentials if [type] is [CredentialType.PasswordCredentials].
 * @property googleCredentials Google credentials if [type] is [CredentialType.GoogleCredentials].
 * @property publicKeyCredentials Public key credentials if [type] is [CredentialType.PublicKeyCredentials].
 */
class CredentialManagerResponse(
    val type: CredentialType = CredentialType.PasswordCredentials,
    val passwordCredentials: PasswordCredentials? = null,
    val googleCredentials: GoogleIdTokenCredential? = null,
    val publicKeyCredentials: String? = null
)

/**
 * Enum class representing different types of credentials.
 * @see PasswordCredentials
 * @see GoogleIdTokenCredential
 * @see String
 */
enum class CredentialType {
    PasswordCredentials,
    GoogleCredentials,
    PublicKeyCredentials
}
