package com.kikimanjaro.nmea_to_network

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter.native/helper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
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
        while(true){
            Thread.sleep(1000)
            result.success("Hello from Kotlin")
        }
    }
}