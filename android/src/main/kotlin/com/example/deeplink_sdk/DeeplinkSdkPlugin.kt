package com.example.deeplink_sdk

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.NewIntentListener

/** DeeplinkSdkPlugin */
class DeeplinkSdkPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler,
    ActivityAware, NewIntentListener {
    
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private var initialLink: String? = null
    private var latestLink: String? = null
    private var activityBinding: ActivityPluginBinding? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "deeplink_sdk")
        methodChannel.setMethodCallHandler(this)
        
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "deeplink_sdk/events")
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getInitialLink" -> {
                result.success(initialLink)
            }
            "getLatestLink" -> {
                result.success(latestLink)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        latestLink?.let { link ->
            eventSink?.success(link)
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addOnNewIntentListener(this)
        
        // Handle initial intent
        handleIntent(binding.activity.intent)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.removeOnNewIntentListener(this)
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeOnNewIntentListener(this)
        activityBinding = null
    }

    override fun onNewIntent(intent: Intent): Boolean {
        handleIntent(intent)
        return false
    }

    private fun handleIntent(intent: Intent?) {
        intent?.let {
            val action = it.action
            val data = it.data
            
            // Handle different types of deep links
            when (action) {
                Intent.ACTION_VIEW -> {
                    data?.let { uri ->
                        handleDeepLink(uri.toString())
                    }
                }
                Intent.ACTION_MAIN -> {
                    // Check if launched from a deep link
                    if (it.categories?.contains(Intent.CATEGORY_BROWSABLE) == true) {
                        data?.let { uri ->
                            handleDeepLink(uri.toString())
                        }
                    }
                }
            }
            
            // Handle App Links (Android 6.0+)
            handleAppLinks(it)
        }
    }

    private fun handleAppLinks(intent: Intent) {
        val appLinkAction = intent.action
        val appLinkData: Uri? = intent.data
        
        if (Intent.ACTION_VIEW == appLinkAction && appLinkData != null) {
            handleDeepLink(appLinkData.toString())
        }
    }

    private fun handleDeepLink(link: String) {
        if (initialLink == null) {
            initialLink = link
        }
        latestLink = link
        
        eventSink?.success(link)
    }
}
