package com.smkwinner.cred_manager.credential_manager

import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.credentials.ClearCredentialStateRequest
import androidx.credentials.CreatePasswordRequest
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CreatePublicKeyCredentialResponse
import androidx.credentials.CredentialManager
import androidx.credentials.CustomCredential
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetPasswordOption
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.PasswordCredential
import androidx.credentials.PrepareGetCredentialResponse
import androidx.credentials.PublicKeyCredential
import androidx.credentials.exceptions.CreateCredentialCancellationException
import androidx.credentials.exceptions.CreateCredentialException
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.NoCredentialException
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.android.libraries.identity.googleid.GoogleIdTokenParsingException
import java.security.SecureRandom

@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
private data class PreparedCredentialRequest(
    val requestJson: String?,
    val fetchOptions: FetchOptions,
    val handle: PrepareGetCredentialResponse.PendingGetCredentialHandle
)

class CredentialManagerUtils {
    /**
     * Generates a cryptographically random nonce for Google Sign-In requests
     * when the caller does not supply one.
     */
    private fun generateSecureNonce(): String {
        val bytes = ByteArray(NONCE_BYTE_LENGTH)
        SecureRandom().nextBytes(bytes)
        return bytes.joinToString("") { "%02x".format(it) }
    }

    private lateinit var credentialManager: CredentialManager
    private var preferImmediatelyAvailableCredentials: Boolean = true
    private lateinit var serverClientID: String
    private var isGmsAvailable: Boolean = false
    private var preparedCredentialRequest: PreparedCredentialRequest? = null

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
            // Check if Google Play Services is available
            val googleApiAvailability = GoogleApiAvailability.getInstance()
            val resultCode = googleApiAvailability.isGooglePlayServicesAvailable(context)
            isGmsAvailable = (resultCode == ConnectionResult.SUCCESS)

            if (!isGmsAvailable) {
                val errorMessage = googleApiAvailability.getErrorString(resultCode)
                Log.d("CredentialManager", "Google Play Services not available: $errorMessage")
            }

            credentialManager = CredentialManager.create(context = context)
            this.preferImmediatelyAvailableCredentials = preferImmediatelyAvailableCredentials
            preparedCredentialRequest = null
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
                ),
                ""
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
                ),
                ""
            )
        } catch (e: CreateCredentialException) {
            Pair(
                CredentialManagerExceptions(
                    code = 302,
                    message = "Create credentials failed",
                    details = e.localizedMessage
                ),
                ""
            )
        } catch (e: Exception) {
            Pair(
                CredentialManagerExceptions(
                    code = 302,
                    message = "Create credentials failed, ${e.message}",
                    details = e.localizedMessage
                ),
                ""
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
            validateCredentialRequest(requestJson, fetchOptions)?.let { return Pair(it, null) }

            val getCredRequest = buildGetCredentialRequest(requestJson, fetchOptions)
            val preparedRequest = preparedCredentialRequest?.takeIf {
                it.requestJson == requestJson && it.fetchOptions == fetchOptions
            }
            preparedCredentialRequest = null

            // Fetch credentials using the credentialManager
            val credentialResponse = if (
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE &&
                preparedRequest != null
            ) {
                try {
                    credentialManager.getCredential(
                        context = context,
                        pendingGetCredentialHandle = preparedRequest.handle
                    )
                } catch (e: GetCredentialCancellationException) {
                    throw e
                } catch (e: GetCredentialException) {
                    Log.d("CredentialManager", "Prepared request failed; retrying without prefetched data", e)
                    credentialManager.getCredential(
                        request = getCredRequest,
                        context = context
                    )
                }
            } else {
                credentialManager.getCredential(
                    request = getCredRequest,
                    context = context
                )
            }

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
                                ),
                                null
                            )
                        }
                    } else {
                        return Pair(
                            CredentialManagerExceptions(
                                code = 202,
                                message = "No credentials found",
                                details = null
                            ),
                            null
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
                        ),
                        null
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
                ),
                null
            )
        } catch (e: NoCredentialException) {
            Pair(
                CredentialManagerExceptions(
                    code = 202,
                    message = "No credentials found",
                    details = e.localizedMessage
                ),
                null
            )
        } catch (e: GetCredentialException) {
            // Detect situation where no google account is available on device/emulator
            val msg = e.localizedMessage ?: ""
            val noAccountAvailable = msg.contains("no credentials available", ignoreCase = true) ||
                msg.contains("no accounts", ignoreCase = true) ||
                msg.contains("no google", ignoreCase = true)
            if (noAccountAvailable) {
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
                    ),
                    null
                )
            }
            Pair(
                CredentialManagerExceptions(
                    code = 204,
                    message = "Login failed ${e.localizedMessage}",
                    details = e.stackTraceToString(),
                ),
                null
            )
        } catch (e: Exception) {
            Pair(
                CredentialManagerExceptions(
                    code = 204,
                    message = "Login failed ${e.localizedMessage}",
                    details = e.stackTraceToString(),
                ),
                null
            )
        }
    }

    /**
     * Prepares a credential request for a lower-latency selector on Android 14 and newer.
     * The next [getPasswordCredentials] call with matching options consumes the prepared request.
     */
    suspend fun prepareCredentials(
        requestJson: String?,
        fetchOptions: FetchOptions
    ): Pair<CredentialManagerExceptions?, Boolean> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            preparedCredentialRequest = null
            return Pair(null, false)
        }
        validateCredentialRequest(requestJson, fetchOptions)?.let { return Pair(it, false) }

        return prepareCredentialsForAndroid14(requestJson, fetchOptions)
    }

    @RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    private suspend fun prepareCredentialsForAndroid14(
        requestJson: String?,
        fetchOptions: FetchOptions
    ): Pair<CredentialManagerExceptions?, Boolean> {
        preparedCredentialRequest = null
        return try {
            val response = credentialManager.prepareGetCredential(buildGetCredentialRequest(requestJson, fetchOptions))
            val handle = response.pendingGetCredentialHandle ?: return Pair(null, false)
            preparedCredentialRequest = PreparedCredentialRequest(
                requestJson = requestJson,
                fetchOptions = fetchOptions,
                handle = handle
            )
            Pair(null, true)
        } catch (e: NoCredentialException) {
            preparedCredentialRequest = null
            Log.d("CredentialManager", "No credentials available during preparation", e)
            Pair(null, false)
        } catch (e: GetCredentialException) {
            preparedCredentialRequest = null
            Pair(
                CredentialManagerExceptions(
                    code = 204,
                    message = "Credential preparation failed ${e.localizedMessage}",
                    details = e.stackTraceToString()
                ),
                false
            )
        }
    }

    private fun validateCredentialRequest(
        requestJson: String?,
        fetchOptions: FetchOptions
    ): CredentialManagerExceptions? {
        if (!isAnyOptionEnabled(fetchOptions)) {
            return CredentialManagerExceptions(
                code = 206,
                message = "Credential fetch options are not enabled",
                details = "Enable at least one credential fetch option (passkey, Google, or password)."
            )
        }

        val googleClientId = if (this::serverClientID.isInitialized) serverClientID else ""
        if (fetchOptions.googleCredential && googleClientId.isEmpty()) {
            return CredentialManagerExceptions(
                code = 503,
                message = "Google client not initialized",
                details = "Ensure Google credentials are provided."
            )
        }
        if (fetchOptions.googleCredential && !isGmsAvailable) {
            return CredentialManagerExceptions(
                code = 209,
                message = "Google Play Services not available",
                details = "Google Sign-In requires Google Play Services"
            )
        }
        if (fetchOptions.passKeyOption && requestJson == null) {
            return CredentialManagerExceptions(
                code = 208,
                message = "RequestJson is required",
                details = "Provide requestJson for passkey."
            )
        }
        return null
    }

    private fun buildGetCredentialRequest(
        requestJson: String?,
        fetchOptions: FetchOptions
    ): GetCredentialRequest = GetCredentialRequest.Builder().apply {
        setPreferImmediatelyAvailableCredentials(preferImmediatelyAvailableCredentials)
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
                    // This unified path cannot surface a nonce for backend verification.
                    .setServerClientId(serverClientID)
                    .build()
            )
        }
    }.build()

    /**
     * Save Google credentials.
     *
     * @param context The Android context.
     * @return A Pair containing either null and deserialized GoogleIdTokenCredential
     * or CredentialManagerExceptions and null if an error occurs.
     */
    suspend fun saveGoogleCredentials(
        useButtonFlow: Boolean,
        nonce: String? = null,
        context: Context
    ): Pair<CredentialManagerExceptions?, GoogleIdTokenCredential?> {
        // Check if Google Play Services is available
        if (!isGmsAvailable) {
            return Pair(
                CredentialManagerExceptions(
                    code = 209,
                    message = "Google Play Services not available",
                    details = "Google Sign-In requires Google Play Services"
                ),
                null
            )
        }

        if (!this::serverClientID.isInitialized) {
            return Pair(
                CredentialManagerExceptions(
                    code = 503,
                    message = "Google client is not initialized yet",
                    details = "Check if Google credentials is provided"
                ),
                null
            )
        }

        val effectiveNonce = nonce ?: generateSecureNonce()
        val googleCredentialOption = if (useButtonFlow) {
            GetSignInWithGoogleOption.Builder(serverClientID)
                .setNonce(effectiveNonce)
                .build()
        } else {
            GetGoogleIdOption.Builder()
                .setFilterByAuthorizedAccounts(false)
                .setNonce(effectiveNonce)
                .setServerClientId(serverClientID)
                .build()
        }

        val request: GetCredentialRequest = GetCredentialRequest.Builder()
            .setPreferImmediatelyAvailableCredentials(preferImmediatelyAvailableCredentials)
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
            val noAccountAvailable = msg.contains("no credentials available", ignoreCase = true) ||
                msg.contains("no accounts", ignoreCase = true) ||
                msg.contains("no google", ignoreCase = true)
            if (noAccountAvailable) {
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
                    ),
                    null
                )
            }
            return Pair(
                CredentialManagerExceptions(
                    code = 204,
                    message = "Login failed ${e.localizedMessage}",
                    details = e.stackTraceToString(),
                ),
                null
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
                            ),
                            null
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
            ),
            null
        )
    }

    suspend fun savePasskeyCredentials(
        context: Context,
        requestJson: String
    ): Pair<CredentialManagerExceptions?, String> {
        return try {
            Log.v("CredentialTest", "RequestJson $requestJson")

            // check for if android is  android 9
            if (android.os.Build.VERSION.SDK_INT <= android.os.Build.VERSION_CODES.Q) {
                return Pair(
                    CredentialManagerExceptions(
                        code = 603,
                        message = "Passkey is not supported on this device",
                        details = "Android version is less than 10"
                    ),
                    ""
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
                ),
                ""
            )
        } catch (e: CreateCredentialException) {
            Log.d("CredentialTest", "Exception $e")
            Pair(
                CredentialManagerExceptions(
                    code = 602,
                    message = "Failed to create passkey credentials",
                    details = e.localizedMessage
                ),
                ""
            )
        } catch (e: Exception) {
            Log.d("CredentialTest", "Exception $e")
            Pair(
                CredentialManagerExceptions(
                    code = 603,
                    message = "Failed to fetch passkey",
                    details = e.localizedMessage
                ),
                ""
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
                ),
                ""
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

    /**
     * Returns whether Google Play Services is available on the device.
     *
     * @return Boolean indicating GMS availability.
     */
    fun getIsGmsAvailable(): Boolean {
        return isGmsAvailable
    }

    companion object {
        private const val NONCE_BYTE_LENGTH = 32
    }
}
