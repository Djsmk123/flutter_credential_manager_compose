package com.smkwinner.cred_manager.credential_manager

import android.content.Context
import android.util.Log
import androidx.credentials.CreatePasswordRequest
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetPasswordOption
import androidx.credentials.PasswordCredential
import androidx.credentials.exceptions.*
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json



class CredentialManagerUtils {

    private lateinit var credentialManager: CredentialManager
    private var preferImmediatelyAvailableCredentials: Boolean = true

    /**
     * Initialize the CredentialManagerUtils.
     *
     * @param preferImmediatelyAvailableCredentials Set to true if immediately available credentials are preferred.
     * @param c The Android context.
     * @return A Pair containing either null and a success message or CredentialManagerExceptions and an empty string.
     */
    fun initialize(preferImmediatelyAvailableCredentials: Boolean, c: Context): Pair<CredentialManagerExceptions?, String> {
        return try {
            credentialManager = CredentialManager.create(context = c)
            this.preferImmediatelyAvailableCredentials = preferImmediatelyAvailableCredentials
            Pair(null, "Initialization successful")
        } catch (e: Exception) {
            val message = e.localizedMessage
            Pair(CredentialManagerExceptions(code = 101, message = "Initialization failure", details = message), "")
        }
    }

    /**
     * Save password credentials.
     *
     * @param username The username to be saved.
     * @param password The password to be saved.
     * @param activity The Android context.
     * @return A Pair containing either null and a success message or CredentialManagerExceptions and an empty string.
     */
    suspend fun savePasswordCredentials(username: String, password: String, activity: Context): Pair<CredentialManagerExceptions?, String> {
        return try {
            credentialManager.createCredential(
                request = CreatePasswordRequest(
                    id = username,
                    password = password,
                    preferImmediatelyAvailableCredentials = preferImmediatelyAvailableCredentials
                ),
                context = activity
            )
            Log.v("CredentialTest", "Credentials successfully added")
            Pair(null, "Credentials saved")
        } catch (e: CreateCredentialCancellationException) {
            Pair(
                CredentialManagerExceptions(
                    code = 301,
                    message = "Save credentials canceled",
                    details = e.localizedMessage
                ), ""
            )
        } catch (e: CreateCredentialException) {
            Pair(
                CredentialManagerExceptions(
                    code = 301,
                    message = "Create credentials failed",
                    details = e.localizedMessage
                ), ""
            )
        } catch (e: Exception) {
            Pair(
                CredentialManagerExceptions(
                    code = 301,
                    message = "Create credentials failed, ${e.message}",
                    details = e.localizedMessage
                ), ""
            )
        }
    }

    /**
     * Get password credentials.
     *
     * @param activity The Android context.
     * @return A Pair containing either null and deserialized password credentials
     * or CredentialManagerExceptions and null if no credentials are found or an error occurs.
     */
    suspend fun getPasswordCredentials(activity: Context): Pair<CredentialManagerExceptions?, PasswordCredentials?> {
        return try {
            val getCredRequest = GetCredentialRequest(listOf(GetPasswordOption()))
            val credentialResponse = credentialManager.getCredential(
                request = getCredRequest,
                context = activity
            )

            val pair = when (val response = credentialResponse.credential) {
                is PasswordCredential -> {
                    // Map the credentials to a data class
                    val data = mapOf(
                        "username" to response.id,
                        "password" to response.password
                    )
                    // Deserialize the data into PasswordCredentials
                    val deserializedUserCredentials =
                        Json.decodeFromString<PasswordCredentials>(data.toString())
                    Pair(null, deserializedUserCredentials)
                }
                !is PasswordCredential -> {
                    Pair(
                        CredentialManagerExceptions(
                            code = 203,
                            message = "Mismatched credentials",
                            details = null
                        ), null
                    )
                }
                else -> {
                    Pair(
                        CredentialManagerExceptions(
                            code = 202,
                            message = "No credentials found",
                            details = null
                        ), null
                    )
                }
            }
            pair
        } catch (e: GetCredentialCancellationException) {
            Pair(
                CredentialManagerExceptions(
                    code = 201,
                    message = "Login canceled",
                    details = e.localizedMessage
                ), null
            )
        } catch (e: NoCredentialException) {
            Pair(
                CredentialManagerExceptions(
                    code = 204,
                    message = "No credentials found",
                    details = e.localizedMessage
                ), null
            )
        } catch (e: GetCredentialException) {
            Pair(
                CredentialManagerExceptions(
                    code = 203,
                    message = "Login failed",
                    details = e.localizedMessage
                ), null
            )
        } catch (e: Exception) {
            Pair(
                CredentialManagerExceptions(
                    code = 203,
                    message = "Login failed",
                    details = e.localizedMessage
                ), null
            )
        }
    }
}
