package com.kikimanjaro.nmea_to_network

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter.native/helper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // FlutterActivity's implementation is what runs GeneratedPluginRegistrant, so
        // overriding it without calling super leaves every plugin unregistered.
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler{
                call, result ->
            when {
                call.method.equals("changeColor") -> {
                    changeColor(call, result)
                }
            }
        }
    }

    private fun changeColor(call: MethodCall, result: MethodChannel.Result) {
        // Reply exactly once. The previous version looped forever on the platform thread,
        // which froze the UI thread and replied to the same call over and over.
        val args = call.arguments as? Map<*, *>
        val color = args?.get("color") as? String ?: "0xFF2196F3"
        result.success(color)
    }
}