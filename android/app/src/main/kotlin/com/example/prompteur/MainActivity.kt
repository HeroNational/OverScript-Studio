package com.example.prompteur

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.PictureInPictureParams
import android.util.Rational
import android.os.Build

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.overscript.studio/pip"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "togglePiP") {
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val params = PictureInPictureParams.Builder()
                            .setAspectRatio(Rational(16, 9))
                            .build()
                        enterPictureInPictureMode(params)
                    } else {
                        @Suppress("DEPRECATION")
                        enterPictureInPictureMode()
                    }
                    result.success(null)
                } catch (e: Exception) {
                    result.error("PIP_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
