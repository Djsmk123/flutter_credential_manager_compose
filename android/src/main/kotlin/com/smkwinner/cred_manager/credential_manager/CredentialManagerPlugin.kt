package com.smkwinner.cred_manager.credential_manager

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

/** CredentialManagerPlugin */
class CredentialManagerPlugin : FlutterPlugin, MethodCallHandler {

  private lateinit var channel: MethodChannel
  private var utils: CredentialManagerUtils = CredentialManagerUtils()
  private val mainScope = CoroutineScope(Dispatchers.Main)
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "credential_manager")
    context = flutterPluginBinding.applicationContext
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    mainScope.launch {
      withContext(Dispatchers.Main){
        when (call.method) {
          "getPlatformVersion" -> {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
          }
          "init" -> {
            val preferImmediatelyAvailableCredentials: Boolean =
              call.argument("prefer_immediately_available_credentials") ?: true
            val (exception: CredentialManagerExceptions?, message: String) =
              utils.initialize(preferImmediatelyAvailableCredentials, context)

            if (exception != null) {
              result.error(exception.code.toString(), exception.details, exception.message)
            } else {
              result.success(message)
            }
          }
          "save_password_credentials" -> {
            val username: String? = call.argument("user_name")
            val password: String? = call.argument("password")
            if (username == null)
              result.error("302", "username is required", "not found all required fields")
            if (password == null)
              result.error("302", "password is required", "not found all required fields")
            val (exception: CredentialManagerExceptions?, message: String) =
              utils.savePasswordCredentials(username = username.toString(), password = password.toString(), activity = context)
            if (exception != null) {
              result.error(exception.code.toString(), exception.details, exception.message)
            } else {
              result.success(message)
            }
          }
          "get_password_credentials" -> {
            val (exception: CredentialManagerExceptions?, credentials: PasswordCredentials?) = utils.getPasswordCredentials(activity = context)
            if (exception != null) {
              result.error(exception.code.toString(), exception.details, exception.message)
            } else {
              val jsonString = Json.encodeToString(credentials)
              result.success(jsonString)
            }
          }
          else -> {
            result.notImplemented()
          }
        }
      }

    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
