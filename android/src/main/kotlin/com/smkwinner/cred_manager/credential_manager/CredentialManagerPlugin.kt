package com.smkwinner.cred_manager.credential_manager

import android.app.Activity
import android.content.Context
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
  private lateinit var activity: Activity

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "credential_manager")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if(call.method=="getPlatformVersion"){
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }
    if(call.method=="init")
    {
      val preferImmediatelyAvailableCredentials: Boolean =
        call.argument("prefer_immediately_available_credentials") ?: true
      val (exception: CredentialManagerExceptions?, message: String) =
        utils.initialize(preferImmediatelyAvailableCredentials, activity)

      if (exception != null) {
        result.error(exception.code.toString(), exception.details, exception.message)
      } else {
        result.success(message)
      }
    }
    else{
      mainScope.launch {
        withContext(Dispatchers.Main){
          when (call.method) {

            "save_password_credentials" -> {
              val username: String? = call.argument("username")
              val password: String? = call.argument("password")
              if (username == null)
              {
                result.error("302", "username is required", "not found all required fields")
              }else if (password == null)
                result.error("302", "password is required", "not found all required fields")
              else{
                val (exception: CredentialManagerExceptions?, message: String) =
                  utils.savePasswordCredentials(username = username.toString(), password = password.toString(), activity = activity)
                if (exception != null) {
                  result.error(exception.code.toString(), exception.details, exception.message)
                } else {
                  result.success(message)
                }
              }
            }
            "get_password_credentials" -> {
              val (exception: CredentialManagerExceptions?, credentials: PasswordCredentials?) = utils.getPasswordCredentials(activity = activity)
              if (exception != null) {
                result.error(exception.code.toString(), exception.details, exception.message)
              } else {
                result.success(mapOf(
                  "username" to credentials?.username,
                  "password" to credentials?.password
                ))
              }
            }
          }
        }

      }
    }

  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(p0: ActivityPluginBinding) {
    activity = p0.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }
}
