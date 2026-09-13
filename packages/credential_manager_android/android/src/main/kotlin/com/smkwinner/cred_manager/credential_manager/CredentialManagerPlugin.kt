package com.smkwinner.cred_manager.credential_manager

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** CredentialManagerPlugin */
class CredentialManagerPlugin : FlutterPlugin, ActivityAware {

    private var utils: CredentialManagerUtils = CredentialManagerUtils()
    private lateinit var context: Context
    private var activity: Activity? = null

    // Use currentContext property to get the current context (activity or application context)
    private val currentContext get() = activity ?: context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        CredentialManagerHostApi.setUp(
            flutterPluginBinding.binaryMessenger,
            CredentialManagerHostApiImpl(utils) { currentContext }
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        CredentialManagerHostApi.setUp(binding.binaryMessenger, null)
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
