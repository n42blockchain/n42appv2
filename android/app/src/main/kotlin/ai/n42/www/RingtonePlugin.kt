package ai.n42.www

import android.content.Context
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * 铃声管理插件
 *
 * 提供系统铃声的获取和播放功能
 */
class RingtonePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var currentRingtone: Ringtone? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "n42_chat/ringtone")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        stopCurrentRingtone()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getAvailableRingtones" -> getAvailableRingtones(result)
            "playRingtone" -> {
                val uri = call.argument<String>("uri")
                if (uri != null) {
                    playRingtone(uri, result)
                } else {
                    result.error("INVALID_ARGUMENT", "URI is required", null)
                }
            }
            "stopRingtone" -> {
                stopCurrentRingtone()
                result.success(null)
            }
            "getDefaultRingtoneUri" -> getDefaultRingtoneUri(result)
            else -> result.notImplemented()
        }
    }

    /**
     * 获取系统可用的铃声列表
     */
    private fun getAvailableRingtones(result: Result) {
        try {
            val ringtones = mutableListOf<Map<String, Any?>>()

            // 获取默认铃声 URI
            val defaultUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            val defaultUriString = defaultUri?.toString() ?: ""

            // 使用 RingtoneManager 获取铃声列表
            val ringtoneManager = RingtoneManager(context)
            ringtoneManager.setType(RingtoneManager.TYPE_RINGTONE)

            val cursor = ringtoneManager.cursor

            while (cursor.moveToNext()) {
                try {
                    val id = cursor.getString(RingtoneManager.ID_COLUMN_INDEX)
                    val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                    val uri = ringtoneManager.getRingtoneUri(cursor.position)?.toString() ?: continue

                    val isDefault = uri == defaultUriString

                    ringtones.add(mapOf(
                        "id" to id,
                        "title" to title,
                        "uri" to uri,
                        "isDefault" to isDefault
                    ))
                } catch (e: Exception) {
                    // 跳过无法读取的铃声
                    continue
                }
            }

            // 如果列表为空，至少添加默认铃声
            if (ringtones.isEmpty() && defaultUri != null) {
                val defaultRingtone = RingtoneManager.getRingtone(context, defaultUri)
                val title = defaultRingtone?.getTitle(context) ?: "Default"
                ringtones.add(mapOf(
                    "id" to "default",
                    "title" to title,
                    "uri" to defaultUriString,
                    "isDefault" to true
                ))
            }

            result.success(ringtones)
        } catch (e: Exception) {
            result.error("GET_RINGTONES_ERROR", e.message, null)
        }
    }

    /**
     * 播放铃声
     */
    private fun playRingtone(uriString: String, result: Result) {
        try {
            // 先停止当前播放
            stopCurrentRingtone()

            val uri = if (uriString == "default") {
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            } else {
                Uri.parse(uriString)
            }

            if (uri == null) {
                result.error("INVALID_URI", "Could not parse ringtone URI", null)
                return
            }

            currentRingtone = RingtoneManager.getRingtone(context, uri)

            if (currentRingtone == null) {
                result.error("RINGTONE_NOT_FOUND", "Could not get ringtone for URI: $uriString", null)
                return
            }

            // 设置音量属性（Android 5.0+）
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                currentRingtone?.audioAttributes = android.media.AudioAttributes.Builder()
                    .setUsage(android.media.AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                    .setContentType(android.media.AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            }

            currentRingtone?.play()
            result.success(true)
        } catch (e: Exception) {
            result.error("PLAY_ERROR", e.message, null)
        }
    }

    /**
     * 停止当前播放的铃声
     */
    private fun stopCurrentRingtone() {
        try {
            if (currentRingtone?.isPlaying == true) {
                currentRingtone?.stop()
            }
            currentRingtone = null
        } catch (e: Exception) {
            // 忽略停止时的错误
        }
    }

    /**
     * 获取默认铃声 URI
     */
    private fun getDefaultRingtoneUri(result: Result) {
        try {
            val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            result.success(uri?.toString())
        } catch (e: Exception) {
            result.error("GET_DEFAULT_ERROR", e.message, null)
        }
    }
}
