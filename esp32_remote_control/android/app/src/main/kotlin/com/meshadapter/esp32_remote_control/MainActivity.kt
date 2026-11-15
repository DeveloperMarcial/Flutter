package com.meshadapter.esp32_remote_control

import android.content.Intent
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val TAG = "ESP32RemoteControl"
    private val CHANNEL = "com.meshadapter.esp32_remote_control/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "shareFile") {
                val filePath = call.argument<String>("filePath")
                val title = call.argument<String>("title") ?: "Share Trace Log"
                val subject = call.argument<String>("subject") ?: "ESP32 BLE Mesh Trace Log"
                if (filePath == null) {
                    result.error("INVALID_PATH", "File path cannot be null", null)
                    return@setMethodCallHandler
                }
                val file = File(filePath)
                if (!file.exists()) {
                    result.error("FILE_NOT_FOUND", "File does not exist: $filePath", null)
                    return@setMethodCallHandler
                }
                val bodyText = call.argument<String>("text")
                    ?: call.argument<String>("body")
                    ?: "Trace log captured from ESP32 BLE Mesh Remote Control: ${file.name}"
                try {
                    val authority = "${applicationContext.packageName}.fileprovider"
                    val uri = FileProvider.getUriForFile(this, authority, file)
                    val sendIntent = Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_STREAM, uri)
                        putExtra(Intent.EXTRA_SUBJECT, subject)
                        putExtra(Intent.EXTRA_TEXT, bodyText)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    val chooser = Intent.createChooser(sendIntent, title)
                    chooser.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    startActivity(chooser)
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "File sharing failed", e)
                    result.error("SHARE_FAILED", e.localizedMessage, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
