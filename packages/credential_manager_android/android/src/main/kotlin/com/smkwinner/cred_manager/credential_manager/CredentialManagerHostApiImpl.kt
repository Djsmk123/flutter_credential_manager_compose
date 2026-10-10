package com.smkwinner.cred_manager.credential_manager

import android.content.Context

/**
 * Implements the Pigeon-generated [CredentialManagerHostApi] on top of [CredentialManagerUtils].
 *
 * Every method mirrors what `CredentialManagerPlugin`'s old `onMethodCall` dispatch did by hand:
 * a [CredentialManagerExceptions] result is thrown as a [FlutterError] (surfaces to Dart as
 * `PlatformException(code, message, details)`, preserving the existing numeric-code contract),
 * otherwise the success value is returned directly.
 */
class CredentialManagerHostApiImpl(
    private val utils: CredentialManagerUtils,
    private val currentContext: () -> Context
) : CredentialManagerHostApi {

    override suspend fun getPlatformVersion(): String = "Android ${android.os.Build.VERSION.RELEASE}"

    override suspend fun init(preferImmediatelyAvailableCredentials: Boolean, googleClientId: String?): InitResult {
        val (exception, message) =
            utils.initialize(preferImmediatelyAvailableCredentials, googleClientId, currentContext())
        if (exception != null) {
            throw FlutterError(exception.code.toString(), exception.message, exception.details)
        }
        return InitResult(message = message, isGmsAvailable = utils.getIsGmsAvailable())
    }

    override suspend fun savePasswordCredentials(username: String, password: String) {
        val (exception, message) =
            utils.savePasswordCredentials(username = username, password = password, context = currentContext())
        if (exception != null) {
            throw FlutterError(exception.code.toString(), exception.message, exception.details)
        }
        check(message == "Credentials saved") {
            "Unexpected success message from savePasswordCredentials: $message"
        }
    }

    override suspend fun getCredentials(
        passkeyRequestJson: String?,
        fetchOptions: FetchOptionsMessage
    ): CredentialResultMessage {
        val (exception, credentials) = utils.getPasswordCredentials(
            context = currentContext(),
            requestJson = passkeyRequestJson,
            fetchOptions = fetchOptions.toFetchOptions()
        )
        if (exception != null) {
            throw FlutterError(exception.code.toString(), exception.message, exception.details)
        }
        return credentials.toCredentialResultMessage()
    }

    override suspend fun prepareCredentials(passkeyRequestJson: String?, fetchOptions: FetchOptionsMessage): Boolean {
        val (exception, prepared) = utils.prepareCredentials(
            requestJson = passkeyRequestJson,
            fetchOptions = fetchOptions.toFetchOptions()
        )
        if (exception != null) {
            throw FlutterError(exception.code.toString(), exception.message, exception.details)
        }
        return prepared
    }

    override suspend fun saveGoogleCredential(useButtonFlow: Boolean, nonce: String?): GoogleIdTokenCredentialMessage {
        val (exception, credential) =
            utils.saveGoogleCredentials(useButtonFlow = useButtonFlow, nonce = nonce, context = currentContext())
        if (exception != null) {
            throw FlutterError(exception.code.toString(), exception.message, exception.details)
        }
        checkNotNull(credential) { "saveGoogleCredentials returned no credential and no exception" }
        return GoogleIdTokenCredentialMessage(
            id = credential.id,
            idToken = credential.idToken,
            displayName = credential.displayName,
            givenName = credential.givenName,
            familyName = credential.familyName,
            phoneNumber = credential.phoneNumber,
            profilePictureUri = credential.profilePictureUri?.toString()
        )
    }

    override suspend fun savePasskeyCredential(requestJson: String): String {
        val (exception, message) = utils.savePasskeyCredentials(context = currentContext(), requestJson = requestJson)
        if (exception != null) {
            throw FlutterError(exception.code.toString(), exception.message, exception.details)
        }
        return message
    }

    override suspend fun logout() {
        val (exception, _) = utils.logout()
        if (exception != null) {
            throw FlutterError(exception.code.toString(), exception.message, exception.details)
        }
    }
}

private fun FetchOptionsMessage.toFetchOptions(): FetchOptions = FetchOptions(
    passKeyOption = passKey,
    googleCredential = googleCredential,
    passwordCredential = passwordCredential
)

private fun CredentialManagerResponse?.toCredentialResultMessage(): CredentialResultMessage {
    return when (this?.type) {
        CredentialType.PasswordCredentials -> CredentialResultMessage(
            type = CredentialResultType.PASSWORD_CREDENTIAL,
            passwordCredential = PasswordCredentialMessage(
                username = passwordCredentials?.username.orEmpty(),
                password = passwordCredentials?.password.orEmpty()
            )
        )
        CredentialType.GoogleCredentials -> CredentialResultMessage(
            type = CredentialResultType.GOOGLE_ID_TOKEN_CREDENTIAL,
            googleIdTokenCredential = GoogleIdTokenCredentialMessage(
                id = googleCredentials?.id.orEmpty(),
                idToken = googleCredentials?.idToken.orEmpty(),
                displayName = googleCredentials?.displayName,
                givenName = googleCredentials?.givenName,
                familyName = googleCredentials?.familyName,
                phoneNumber = googleCredentials?.phoneNumber,
                profilePictureUri = googleCredentials?.profilePictureUri?.toString()
            )
        )
        CredentialType.PublicKeyCredentials -> CredentialResultMessage(
            type = CredentialResultType.PUBLIC_KEY_CREDENTIAL,
            publicKeyCredentialJson = publicKeyCredentials
        )
        else -> throw FlutterError("UnknownType", "Unknown credential type received", null)
    }
}
