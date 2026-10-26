package com.santiagomarc.margin

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Device facts for the in-app bug report (lib/diagnostics/device_info.dart).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "margin/device")
            .setMethodCallHandler { call, result ->
                if (call.method != "info") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val activityManager =
                    getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                val memory = ActivityManager.MemoryInfo()
                activityManager.getMemoryInfo(memory)
                result.success(
                    mapOf(
                        "manufacturer" to Build.MANUFACTURER,
                        "model" to Build.MODEL,
                        "android" to Build.VERSION.RELEASE,
                        "sdk" to Build.VERSION.SDK_INT,
                        "totalRamMb" to (memory.totalMem / (1024 * 1024)).toInt(),
                        "memoryClassMb" to activityManager.memoryClass,
                        "lowRamDevice" to activityManager.isLowRamDevice,
                    ),
                )
            }
    }
}
