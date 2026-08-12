package com.example.mobile

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.mobile/permissions"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "openAppPermissions") {
                    val intent = Intent("android.intent.action.MANAGE_APP_PERMISSIONS").apply {
                        data = Uri.parse("package:$packageName")
                    }
                    try {
                        startActivity(intent)
                        result.success(true)
                    } catch (_: Exception) {
                        val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.parse("package:$packageName")
                        }
                        startActivity(fallback)
                        result.success(false)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
