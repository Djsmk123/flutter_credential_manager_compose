package com.smkwinner.cred_manager.credential_manager

import android.app.Activity
import android.content.Context
import android.util.Log
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
import org.json.JSONObject


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
                        "get_password_credentials" -> handleGetPasswordCredentials(call,result)
                        "save_google_credential" -> handleSaveGoogleCredential(call, result)
                        "save_public_key_credential" -> handleSavePublicKeyCredential(call, result)
                        "logout" -> handleLogout(result)
                        else -> result.notImplemented()
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

    private suspend fun handleGetPasswordCredentials(call: MethodCall, result: Result) {
        val requestJson: String? = call.argument("passKeyOption")
        val fetchOptionsJson: String? = call.argument("fetchOptions")
        val fetchOptions: FetchOptions? = fetchOptionsJson?.let {
            val jsonObject = JSONObject(it)
            FetchOptions(
                passKeyOption = jsonObject.optBoolean("passKey", true),
                googleCredential = jsonObject.optBoolean("googleCredential", true),
                passwordCredential = jsonObject.optBoolean("passwordCredential", true)
            )
        }
        //throw error if fetchOptions is null
        if (fetchOptions == null) {
            result.error("604", "FetchOptions is null", "FetchOptions is required")
            return
        }
        
        val (exception: CredentialManagerExceptions?, credentials: CredentialManagerResponse?) =
            utils.getPasswordCredentials(context = currentContext, requestJson = requestJson,fetchOptions=fetchOptions)

        if (exception != null) {
            result.error(exception.code.toString(), exception.message, exception.details)
        } else {
            val resultMap = when (credentials?.type) {
                CredentialType.PasswordCredentials -> {
                    mapOf(
                        "type" to "PasswordCredentials",
                        "data" to mapOf(
                            "username" to credentials.passwordCredentials?.username,
                            "password" to credentials.passwordCredentials?.password
                        )
                    )
                }
                CredentialType.GoogleCredentials -> {
                    mapOf(
                        "type" to "GoogleIdTokenCredentials",
                        "data" to mapOf(
                            "id" to credentials.googleCredentials?.id,
                            "idToken" to credentials.googleCredentials?.idToken,
                            "displayName" to credentials.googleCredentials?.displayName,
                            "givenName" to credentials.googleCredentials?.givenName,
                            "familyName" to credentials.googleCredentials?.familyName,
                            "phoneNumber" to credentials.googleCredentials?.phoneNumber,
                            "profilePictureUri" to credentials.googleCredentials?.profilePictureUri.toString()
                        )
                    )
                }
                CredentialType.PublicKeyCredentials -> {
                    mapOf(
                        "type" to "PublicKeyCredentials",
                        "data" to credentials.publicKeyCredentials
                    )
                }
                else -> {
                    result.error("UnknownType", "Unknown credential type received", null)
                    return
                }
            }

            result.success(resultMap)
        }
    }


    private suspend fun handleSaveGoogleCredential(call: MethodCall, result: Result) {
        val useButtonFlow: Boolean = call.argument("useButtonFlow") ?: false

        val (exception: CredentialManagerExceptions?, credential: GoogleIdTokenCredential?) =
            utils.saveGoogleCredentials(useButtonFlow = useButtonFlow,context = currentContext)

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
    private suspend fun handleSavePublicKeyCredential(call: MethodCall, result: Result) {
        val requestJson: String? = call.argument("requestJson")
        if (requestJson == null) {
            result.error("604", "Create PublicKey Credential Dom Exception", "Request is required")
        } else {
            val (exception: CredentialManagerExceptions?, message: String) = utils.savePasskeyCredentials(context=currentContext,requestJson=requestJson.toString())

            if (exception != null) {
                Log.d("Error in savepasskey" ,"${exception.code}, ${exception.details}, ${exception.message}")
                result.error(exception.code.toString(), exception.message, exception.details)
            } else {
                result.success(message)
            }
        }
    }
    private suspend fun handleLogout(result: Result) {
        val (exception: CredentialManagerExceptions?, message: String) = utils.logout()
        if (exception != null) {
            result.error(exception.code.toString(), exception.message, exception.details)
        } else {
            result.success(message)
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
