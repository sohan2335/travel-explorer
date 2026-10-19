package com.example.travel_explorer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val preferences = getSharedPreferences("travel_explorer", MODE_PRIVATE)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "travel_explorer/storage")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "read" -> {
                        val key = call.arguments as? String
                        if (key == null) result.error("INVALID_KEY", "Storage key is missing", null)
                        else result.success(preferences.getString(key, null))
                    }
                    "write" -> {
                        val key = call.argument<String>("key")
                        val value = call.argument<String>("value")
                        if (key == null || value == null) result.error("INVALID_VALUE", "Storage value is missing", null)
                        else if (preferences.edit().putString(key, value).commit()) result.success(null)
                        else result.error("WRITE_FAILED", "Could not save on device", null)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "travel_explorer/links")
            .setMethodCallHandler { call, result ->
                if (call.method != "openUrl") {
                    result.notImplemented()
                } else {
                    val url = call.arguments as? String
                    if (url == null || Uri.parse(url).scheme != "https") {
                        result.error("INVALID_URL", "An HTTPS link is required", null)
                    } else {
                        try {
                            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                            result.success(null)
                        } catch (exception: Exception) {
                            result.error("OPEN_FAILED", exception.message, null)
                        }
                    }
                }
            }
    }
}
