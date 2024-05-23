package com.smkwinner.cred_manager.credential_manager

import android.app.Activity
import android.content.Context
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext


/** CredentialManagerPlugin */
class CredentialManagerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var utils: CredentialManagerUtils = CredentialManagerUtils()
    private val mainScope = CoroutineScope(Dispatchers.Main)
    private lateinit var context: Context
    private var activity: Activity? = null

    // Use currentContext property to get the current context (activity or application context)
    private val currentContext get() = activity ?: context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "credential_manager")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                // Handle getPlatformVersion method
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "init" -> handleInitMethod(call, result)
            else -> handleCredentialMethods(call, result)
        }
    }
    private fun handleCredentialMethods(call: MethodCall, result: Result) {
        mainScope.launch {
            withContext(Dispatchers.Main) {
                try {
                    // Handling other credential-related methods
                    when (call.method) {
                        "save_password_credentials" -> handleSavePasswordCredentials(call, result)
                        "get_password_credentials" -> handleGetPasswordCredentials(result)
                        "save_google_credential" -> handleSaveGoogleCredential(result)
                    }
                } catch (e: Exception) {
                    result.error("204", "Login failed", e.localizedMessage)
                }
            }
        }
    }
    private fun handleInitMethod(call: MethodCall, result: Result) {
        val preferImmediatelyAvailableCredentials: Boolean =
            call.argument("prefer_immediately_available_credentials") ?: true
        val googleClientId: String? = call.argument("google_client_id")

        val (exception: CredentialManagerExceptions?, message: String) =
            utils.initialize(preferImmediatelyAvailableCredentials, googleClientId, currentContext)

        if (exception != null) {
            result.error(exception.code.toString(), exception.message, exception.details)
        } else {
            result.success(message)
        }
    }
    private suspend fun handleSavePasswordCredentials(call: MethodCall, result: Result) {
        val username: String? = call.argument("username")
        val password: String? = call.argument("password")

        if (username == null || password == null) {
            result.error("302", "Missing required fields", "Username and password are required")
        } else {
            val (exception: CredentialManagerExceptions?, message: String) =
                utils.savePasswordCredentials(username = username, password = password, context = currentContext)

            if (exception != null) {
                result.error(exception.code.toString(), exception.message, exception.details)
            } else {
                result.success(message)
            }
        }
    }

    private suspend fun handleGetPasswordCredentials(result: Result) {
        val (exception: CredentialManagerExceptions?, credentials: Pair<PasswordCredentials?, GoogleIdTokenCredential?>?) =
            utils.getPasswordCredentials(context = currentContext)

        if (exception != null) {
            result.error(exception.code.toString(), exception.message, exception.details)
        } else {
            val resultMap = if (credentials.first != null) {
                mapOf("type" to "PasswordCredentials","data" to mapOf("username" to credentials.first?.username, "password" to credentials.first?.password))
            } else {
                mapOf("type" to "GoogleCredentials","data" to  mapOf(
                    "id" to credentials.second?.id,
                    "idToken" to credentials.second?.idToken,
                    "displayName" to credentials.second?.displayName,
                    "givenName" to credentials.second?.givenName,
                    "familyName" to credentials.second?.familyName,
                    "phoneNumber" to credentials.second?.phoneNumber,
                    "profilePictureUri" to credentials.second?.profilePictureUri.toString()
                ))
            }

            result.success(resultMap)
        }
    }

    private suspend fun handleSaveGoogleCredential(result: Result) {
        val (exception: CredentialManagerExceptions?, credential: GoogleIdTokenCredential?) =
            utils.saveGoogleCredentials(context = currentContext)

        if (exception != null) {
            result.error(exception.code.toString(), exception.message, exception.details)
        } else {
            val credentialMap = mapOf(
                "id" to credential?.id,
                "idToken" to credential?.idToken,
                "displayName" to credential?.displayName,
                "givenName" to credential?.givenName,
                "familyName" to credential?.familyName,
                "phoneNumber" to credential?.phoneNumber,
                "profilePictureUri" to credential?.profilePictureUri.toString()
            )


            result.success(credentialMap)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(p0: ActivityPluginBinding) {
        activity = p0.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {
        activity = p0.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
