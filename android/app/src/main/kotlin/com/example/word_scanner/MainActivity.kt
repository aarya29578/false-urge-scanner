package com.example.word_scanner

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "word_scanner/protection"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOverlayPermission" -> {
                    result.success(Settings.canDrawOverlays(this))
                }
                "openOverlaySettings" -> {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:${packageName}")
                    )
                    startActivity(intent)
                    result.success(true)
                }
                "enableProtectionMode" -> {
                    val hasPermission = Settings.canDrawOverlays(this)
                    if (!hasPermission) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    ProtectionService.start(this)
                    result.success(true)
                }
                "disableProtectionMode" -> {
                    ProtectionService.stop(this)
                    result.success(true)
                }
                "triggerTestAlert" -> {
                    val hasPermission = Settings.canDrawOverlays(this)
                    if (!hasPermission) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    val indicatorList = call.argument<List<String>>("indicators") ?: listOf(
                        "Example indicator detected",
                        "Example warning signal",
                        "Verification required"
                    )
                    val metadata = mapOf(
                        "title" to (call.argument<String>("title") ?: "Protection Alert"),
                        "summary" to (call.argument<String>("summary") ?: "Potentially suspicious\ncontent detected"),
                        "confidence" to (call.argument<Int>("confidence") ?: 78),
                        "indicators" to indicatorList
                    )
                    ProtectionService.triggerTestAlert(this, metadata)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}

