package com.smkwinner.cred_manager.credential_manager

import android.content.Context
import android.util.Log
import androidx.credentials.*
import androidx.credentials.exceptions.CreateCredentialCancellationException
import androidx.credentials.exceptions.CreateCredentialException
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.NoCredentialException
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.android.libraries.identity.googleid.GoogleIdTokenParsingException

class CredentialManagerUtils {

    private lateinit var credentialManager: CredentialManager
    private var preferImmediatelyAvailableCredentials: Boolean = true
    private lateinit var serverClientID: String

    /**
     * Initialize the CredentialManagerUtils.
     *
     * @param preferImmediatelyAvailableCredentials Set to true if immediately available credentials are preferred.
     * @param gClientId The Google Client ID.
     * @param context The Android context.
     * @return A Pair containing either null and a success message or CredentialManagerExceptions and an empty string.
     */
    fun initialize(
        preferImmediatelyAvailableCredentials: Boolean,
        gClientId: String?,
        context: Context,
    ): Pair<CredentialManagerExceptions?, String> {
        return try {
            credentialManager = CredentialManager.create(context = context)
            this.preferImmediatelyAvailableCredentials = preferImmediatelyAvailableCredentials
            if (gClientId != null) {
                serverClientID = gClientId
            }
            Pair(null, "Initialization successful")
        } catch (e: Exception) {
            Log.d("CredentialManager", "${e.message}")
            val message = e.localizedMessage
            Pair(
                CredentialManagerExceptions(
                    code = 101,
                    message = "Initialization failure",
                    details = message
                ), ""
            )
        }
    }

    /**
     * Save password credentials.
     *
     * @param username The username to be saved.
     * @param password The password to be saved.
     * @param context The Android context.
     * @return A Pair containing either null and a success message or CredentialManagerExceptions and an empty string.
     */
    suspend fun savePasswordCredentials(
        username: String,
        password: String,
        context: Context
    ): Pair<CredentialManagerExceptions?, String> {
        return try {
            credentialManager.createCredential(
                request = CreatePasswordRequest(
                    id = username,
                    password = password,
                    preferImmediatelyAvailableCredentials = preferImmediatelyAvailableCredentials
                ),
                context = context
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
                    code = 302,
                    message = "Create credentials failed",
                    details = e.localizedMessage
                ), ""
            )
        } catch (e: Exception) {
            Pair(
                CredentialManagerExceptions(
                    code = 302,
                    message = "Create credentials failed, ${e.message}",
                    details = e.localizedMessage
                ), ""
            )
        }
    }

    /**
     * Get password credentials.
     *
     * @param context The Android context.
     * @return A Pair containing either null and deserialized password credentials
     * or CredentialManagerExceptions and null if no credentials are found or an error occurs.
     */
    suspend fun getPasswordCredentials(context: Context): Pair<CredentialManagerExceptions?, Pair<PasswordCredentials?, GoogleIdTokenCredential?>> {
        return try {
            var getCredRequest = GetCredentialRequest(listOf(GetPasswordOption()))
            if (this::serverClientID.isInitialized) {
                val googleIdOption: GetGoogleIdOption = GetGoogleIdOption.Builder()
                    .setFilterByAuthorizedAccounts(false)
                    .setNonce(System.currentTimeMillis().toString())
                    .setServerClientId(serverClientID)
                    .build()
                getCredRequest = GetCredentialRequest.Builder()
                    .addCredentialOption(googleIdOption).addCredentialOption(GetPasswordOption())
                    .build()
            }

            val credentialResponse = credentialManager.getCredential(
                request = getCredRequest,
                context = context
            )

            val pair = when (val response = credentialResponse.credential) {
                is PasswordCredential -> {
                    // Deserialize the data into PasswordCredentials
                    val cred = PasswordCredentials(username = response.id, password = response.password)
                    Pair(null, Pair(cred, null))
                }
                is CustomCredential -> {
                    if (response.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL) {
                        try {
                            // Use googleIdTokenCredential and extract id to validate and
                            // authenticate on your server.
                            val googleIdTokenCredential = GoogleIdTokenCredential
                                .createFrom(response.data)
                            Pair(null, Pair(null, googleIdTokenCredential))

                        } catch (e: GoogleIdTokenParsingException) {
                            return Pair(
                                CredentialManagerExceptions(
                                    code = 501,
                                    message = "Received an invalid google id token response",
                                    details = e.localizedMessage,
                                ), Pair(null, null)
                            )
                        }
                    } else {
                        Pair(
                            CredentialManagerExceptions(
                                code = 202,
                                message = "No credentials found",
                                details = null
                            ), Pair(null, null)
                        )
                    }
                }
                else -> {
                    Pair(
                        CredentialManagerExceptions(
                            code = 202,
                            message = "No credentials found",
                            details = null
                        ), Pair(null, null)
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
                ), Pair(null, null)
            )
        } catch (e: NoCredentialException) {
            Pair(
                CredentialManagerExceptions(
                    code = 202,
                    message = "No credentials found",
                    details = e.localizedMessage
                ), Pair(null, null)
            )
        } catch (e: GetCredentialException) {
            Pair(
                CredentialManagerExceptions(
                    code = 204,
                    message = "Login failed",
                    details = e.localizedMessage
                ), Pair(null, null)
            )
        } catch (e: Exception) {
            Pair(
                CredentialManagerExceptions(
                    code = 204,
                    message = "Login failed",
                    details = e.localizedMessage
                ), Pair(null, null)
            )
        }
    }

    /**
     * Save Google credentials.
     *
     * @param context The Android context.
     * @return A Pair containing either null and deserialized GoogleIdTokenCredential
     * or CredentialManagerExceptions and null if an error occurs.
     */
    suspend fun saveGoogleCredentials(context: Context): Pair<CredentialManagerExceptions?, GoogleIdTokenCredential?> {
        if (!this::serverClientID.isInitialized) {
            return Pair(
                CredentialManagerExceptions(
                    code = 503,
                    message = "Google client is not initialized yet",
                    details = "Check if Google credentials is provided"
                ), null
            )
        }

        val googleIdOption: GetGoogleIdOption = GetGoogleIdOption.Builder()
            .setFilterByAuthorizedAccounts(false)
            .setNonce(System.currentTimeMillis().toString())
            .setServerClientId(serverClientID)
            .build()

        val request: GetCredentialRequest = GetCredentialRequest.Builder()
            .addCredentialOption(googleIdOption)
            .build()

        Log.d("CredentialManager", "$request")
        val result = credentialManager.getCredential(
            request = request,
            context = context,
        )

        when (val credential = result.credential) {
            is CustomCredential -> {
                if (credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL) {
                    return try {
                        // Use googleIdTokenCredential and extract id to validate and
                        // authenticate on your server.
                        val googleIdTokenCredential = GoogleIdTokenCredential
                            .createFrom(credential.data)
                        Pair(null, googleIdTokenCredential)
                    } catch (e: GoogleIdTokenParsingException) {
                        Pair(
                            CredentialManagerExceptions(
                                code = 501,
                                message = "Received an invalid google id token response",
                                details = e.localizedMessage,
                            ), null
                        )
                    }
                }
            }
        }
        return Pair(
            CredentialManagerExceptions(
                code = 502,
                message = "Invalid request",
                details = null
            ), null
        )
    }
}
