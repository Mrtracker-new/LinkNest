package com.rnr.linknest

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle
import android.content.Context

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.rnr.linknest/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Handle deep links from widget
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInitialUri") {
                val uri = intent?.data?.toString()
                result.success(uri)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        
        // Log the intent for debugging
        android.util.Log.d("MainActivity", "onNewIntent called with data: ${intent.data}")
        
        // Store the URI in SharedPreferences for HomeWidget plugin to read
        intent.data?.let { uri ->
            android.util.Log.d("MainActivity", "Deep link URI: $uri")
            
            val prefs = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            prefs.edit().putString("HomeWidget.clicked_uri", uri.toString()).apply()
            android.util.Log.d("MainActivity", "Stored URI in SharedPreferences")
        }
    }
}
