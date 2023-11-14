package com.smkwinner.cred_manager.credential_manager

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class PasswordCredentials(
    @SerialName("username") val username: String,
    @SerialName("password") val password: String
)