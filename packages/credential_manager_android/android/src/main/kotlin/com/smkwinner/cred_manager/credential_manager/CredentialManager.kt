package com.smkwinner.cred_manager.credential_manager

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.util.Log
import androidx.credentials.*
import androidx.credentials.exceptions.CreateCredentialCancellationException
import androidx.credentials.exceptions.CreateCredentialException
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.NoCredentialException
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
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
                context = context,

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
    suspend fun getPasswordCredentials(
        context: Context,
        requestJson: String?,
        fetchOptions: FetchOptions
    ): Pair<CredentialManagerExceptions?, CredentialManagerResponse?> {
        return try {
            // Check if all fetch options are disabled
            if (!isAnyOptionEnabled(fetchOptions)) {
                return Pair(
                    CredentialManagerExceptions(
                        code = 206,
                        message = "Credential fetch options are not enabled",
                        details = "Enable at least one credential fetch option (passkey, Google, or password)."
                    ), null
                )
            }
            val googleClientId = if (this::serverClientID.isInitialized) serverClientID else ""
            // Validate serverClientID if Google sign-in is enabled
            if (fetchOptions.googleCredential && googleClientId.isEmpty()) {
                return Pair(
                    CredentialManagerExceptions(
                        code = 503,
                        message = "Google client not initialized",
                        details = "Ensure Google credentials are provided."
                    ), null
                )
            }

            // Validate requestJson for Passkey or Google Sign-In
            if (fetchOptions.passKeyOption && requestJson == null) {
                return Pair(
                    CredentialManagerExceptions(
                        code = 208,
                        message = "RequestJson is required",
                        details = "Provide requestJson for passkey."
                    ), null
                )
            }

            // Build the credential request based on enabled options
            val getCredRequest = GetCredentialRequest.Builder().apply {
                if (fetchOptions.passwordCredential) {
                    addCredentialOption(GetPasswordOption())
                }
                if (fetchOptions.passKeyOption && requestJson != null) {
                    addCredentialOption(GetPublicKeyCredentialOption(requestJson))
                }
                if (fetchOptions.googleCredential) {
                    addCredentialOption(
                        GetGoogleIdOption.Builder()
                            .setFilterByAuthorizedAccounts(false)
                            .setNonce(System.currentTimeMillis().toString())
                            .setServerClientId(serverClientID)
                            .build()
                    )
                }
            }.build()

            // Fetch credentials using the credentialManager
            val credentialResponse = credentialManager.getCredential(
                request = getCredRequest,
                context = context
            )

            val response = when (val credential = credentialResponse.credential) {
                is PasswordCredential -> {
                    val cred = PasswordCredentials(username = credential.id, password = credential.password)
                    CredentialManagerResponse(
                        type = CredentialType.PasswordCredentials,
                        passwordCredentials = cred
                    )
                }
                is CustomCredential -> {
                    if (credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL) {
                        try {
                            val googleIdTokenCredential = GoogleIdTokenCredential.createFrom(credential.data)
                            CredentialManagerResponse(
                                type = CredentialType.GoogleCredentials,
                                googleCredentials = googleIdTokenCredential
                            )
                        } catch (e: GoogleIdTokenParsingException) {
                            return Pair(
                                CredentialManagerExceptions(
                                    code = 501,
                                    message = "Received an invalid google id token response",
                                    details = e.localizedMessage,
                                ), null
                            )
                        }
                    } else {
                        return Pair(
                            CredentialManagerExceptions(
                                code = 202,
                                message = "No credentials found",
                                details = null
                            ), null
                        )
                    }
                }
                is PublicKeyCredential -> {
                    CredentialManagerResponse(
                        type = CredentialType.PublicKeyCredentials,
                        publicKeyCredentials = credential.authenticationResponseJson
                    )
                }
                else -> {
                    return Pair(
                        CredentialManagerExceptions(
                            code = 202,
                            message = "No credentials found",
                            details = null
                        ), null
                    )
                }
            }
            Pair(null, response)
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
                    code = 202,
                    message = "No credentials found",
                    details = e.localizedMessage
                ), null
            )
        } catch (e: GetCredentialException) {
            // Detect situation where no google account is available on device/emulator
            val msg = e.localizedMessage ?: ""
            if (msg.contains("no credentials available", ignoreCase = true) || msg.contains("no accounts", ignoreCase = true) || msg.contains("no google", ignoreCase = true)) {
                try {
                    val intent = Intent(Settings.ACTION_ADD_ACCOUNT)
                    intent.putExtra("accountTypes", arrayOf("com.google"))
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(intent)
                } catch (ex: Exception) {
                    Log.d("CredentialManager", "Failed to open add account settings: ${ex.localizedMessage}")
                }
                return Pair(
                    CredentialManagerExceptions(
                        code = 207,
                        message = "No Google account present; launched account settings",
                        details = e.localizedMessage
                    ), null
                )
            }
            Pair(
                CredentialManagerExceptions(
                    code = 204,
                    message = "Login failed ${e.localizedMessage}",
                    details = e.stackTraceToString(),
                ), null
            )
        } catch (e: Exception) {
            Pair(
                CredentialManagerExceptions(
                    code = 204,
                    message = "Login failed ${e.localizedMessage}",
                    details = e.stackTraceToString(),
                ), null
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
    suspend fun saveGoogleCredentials(useButtonFlow: Boolean, context: Context): Pair<CredentialManagerExceptions?, GoogleIdTokenCredential?> {
        if (!this::serverClientID.isInitialized) {
            return Pair(
                CredentialManagerExceptions(
                    code = 503,
                    message = "Google client is not initialized yet",
                    details = "Check if Google credentials is provided"
                ), null
            )
        }

        val googleCredentialOption = if (useButtonFlow) {
            GetSignInWithGoogleOption.Builder(serverClientID)
                .setNonce(System.currentTimeMillis().toString())
                .build()
        } else {
            GetGoogleIdOption.Builder()
                .setFilterByAuthorizedAccounts(false)
                .setNonce(System.currentTimeMillis().toString())
                .setServerClientId(serverClientID)
                .build()
        }

        val request: GetCredentialRequest = GetCredentialRequest.Builder()
            .addCredentialOption(googleCredentialOption)
            .build()

        Log.d("CredentialManager", "$request")
        val result = try {
            credentialManager.getCredential(
                request = request,
                context = context,
            )
        } catch (e: GetCredentialException) {
            val msg = e.localizedMessage ?: ""
            if (msg.contains("no credentials available", ignoreCase = true) || msg.contains("no accounts", ignoreCase = true) || msg.contains("no google", ignoreCase = true)) {
                try {
                    val intent = Intent(Settings.ACTION_ADD_ACCOUNT)
                    intent.putExtra("accountTypes", arrayOf("com.google"))
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(intent)
                } catch (ex: Exception) {
                    Log.d("CredentialManager", "Failed to open add account settings: ${ex.localizedMessage}")
                }
                return Pair(
                    CredentialManagerExceptions(
                        code = 207,
                        message = "No Google account present; launched account settings",
                        details = e.localizedMessage
                    ), null
                )
            }
            return Pair(
                CredentialManagerExceptions(
                    code = 204,
                    message = "Login failed ${e.localizedMessage}",
                    details = e.stackTraceToString(),
                ), null
            )
        }

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

    suspend fun savePasskeyCredentials(context: Context, requestJson: String): Pair<CredentialManagerExceptions?, String> {
        return try {
            Log.v("CredentialTest", "RequestJson $requestJson")

            //check for if android is  android 9
            if(android.os.Build.VERSION.SDK_INT <= android.os.Build.VERSION_CODES.Q){
                return Pair(
                    CredentialManagerExceptions(
                        code = 603,
                        message = "Passkey is not supported on this device",
                        details = "Android version is less than 10"
                    ), ""
                )
            }

            val createPublicKeyCredentialRequest = CreatePublicKeyCredentialRequest(
                requestJson = requestJson
            )

            val result = credentialManager.createCredential(
                request = createPublicKeyCredentialRequest,
                context = context
            ) as CreatePublicKeyCredentialResponse

            Log.v("CredentialTest", "Passkey credentials successfully added $result")
            Pair(null, result.registrationResponseJson)

        } catch (e: CreateCredentialCancellationException) {
            Log.d("CredentialTest", "Exception $e")
            Pair(
                CredentialManagerExceptions(
                    code = 601,
                    message = "Save credentials operation was cancelled",
                    details = e.localizedMessage
                ), ""
            )
        } catch (e: CreateCredentialException) {
            Log.d("CredentialTest", "Exception $e")
            Pair(
                CredentialManagerExceptions(
                    code = 602,
                    message = "Failed to create passkey credentials",
                    details = e.localizedMessage
                ), ""
            )
        } catch (e: Exception) {
            Log.d("CredentialTest", "Exception $e")
            Pair(
                CredentialManagerExceptions(
                    code = 603,
                    message = "Failed to fetch passkey",
                    details = e.localizedMessage
                ), ""
            )
        }
    }

    /**
     * Logout the user.
     *
     * @return A Pair containing either null and a success message or CredentialManagerExceptions and an empty string.
     */
    suspend fun logout(): Pair<CredentialManagerExceptions?, String> {
        return try {
            credentialManager.clearCredentialState(
                ClearCredentialStateRequest()
            )
            Pair(null, "Logout successful")
        } catch (e: Exception) {
            Pair(
                CredentialManagerExceptions(
                    code = 701,
                    message = "Logout failed",
                    details = e.localizedMessage
                ), ""
            )
        }
    }
    /**
     * Checks if at least one credential option is enabled.
     *
     * @return Boolean indicating if any option is enabled.
     */
    private fun isAnyOptionEnabled(
        fetchOptions: FetchOptions
    ): Boolean {
        return fetchOptions.googleCredential || fetchOptions.passwordCredential || fetchOptions.passKeyOption
    }





}
