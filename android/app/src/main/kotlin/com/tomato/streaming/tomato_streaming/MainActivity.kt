package com.tomato.streaming.tomato_streaming

import android.app.PictureInPictureParams
import android.os.Build
import android.util.Rational
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pipEnabled = false
    private var pipChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pipChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tomato.streaming/pip")
        pipChannel!!
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setEnabled" -> {
                        pipEnabled = call.argument<Boolean>("enabled") ?: false
                        result.success(null)
                    }
                    "enter" -> {
                        enterPlayerPip()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (pipEnabled) enterPlayerPip()
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: android.content.res.Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        pipChannel?.invokeMethod(
            "pipChanged",
            mapOf("inPip" to isInPictureInPictureMode)
        )
    }

    private fun enterPlayerPip() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && !isInPictureInPictureMode) {
            enterPictureInPictureMode(
                PictureInPictureParams.Builder()
                    .setAspectRatio(Rational(16, 9))
                    .build()
            )
        }
    }
}
