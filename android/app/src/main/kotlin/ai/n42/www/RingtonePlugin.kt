package ai.n42.www

import android.app.Activity
import android.content.Context
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * 铃声管理插件
 *
 * 提供系统铃声的获取和播放功能
 */
class RingtonePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private var activity: Activity? = null
    private var currentRingtone: Ringtone? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "n42_chat/ringtone")
        channel.setMethodCallHandler(this)
        applicationContext = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        stopCurrentRingtone()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
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
     * 获取可用的 Context（优先使用 Activity）
     */
    private fun getContext(): Context {
        return activity ?: applicationContext
    }

    /**
     * 获取系统可用的铃声列表
     */
    private fun getAvailableRingtones(result: Result) {
        try {
            val ringtones = mutableListOf<Map<String, Any?>>()
            val addedUris = mutableSetOf<String>()
            val ctx = getContext()

            android.util.Log.d("RingtonePlugin", "Getting ringtones with context: ${ctx.javaClass.simpleName}")
            android.util.Log.d("RingtonePlugin", "Activity available: ${activity != null}")

            // 获取默认通知铃声 URI
            val defaultNotificationUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val defaultRingtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            android.util.Log.d("RingtonePlugin", "Default notification URI: $defaultNotificationUri")
            android.util.Log.d("RingtonePlugin", "Default ringtone URI: $defaultRingtoneUri")

            // 获取通知铃声
            try {
                val manager = RingtoneManager(ctx)
                manager.setType(RingtoneManager.TYPE_NOTIFICATION)
                val cursor = manager.cursor
                val count = cursor.count
                android.util.Log.d("RingtonePlugin", "Notification ringtones cursor count: $count")

                if (count > 0) {
                    cursor.moveToFirst()
                    do {
                        try {
                            val position = cursor.position
                            val id = cursor.getString(RingtoneManager.ID_COLUMN_INDEX) ?: position.toString()
                            val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX) ?: "Unknown"
                            val uri = manager.getRingtoneUri(position)?.toString()

                            if (uri != null && !addedUris.contains(uri)) {
                                addedUris.add(uri)
                                val isDefault = uri == defaultNotificationUri?.toString()
                                ringtones.add(mapOf(
                                    "id" to id,
                                    "title" to title,
                                    "uri" to uri,
                                    "isDefault" to isDefault
                                ))
                                android.util.Log.d("RingtonePlugin", "Added notification: $title -> $uri")
                            }
                        } catch (e: Exception) {
                            android.util.Log.e("RingtonePlugin", "Error reading notification item: ${e.message}")
                        }
                    } while (cursor.moveToNext())
                }
            } catch (e: Exception) {
                android.util.Log.e("RingtonePlugin", "Error getting notification ringtones: ${e.message}")
                e.printStackTrace()
            }

            // 获取来电铃声
            try {
                val manager = RingtoneManager(ctx)
                manager.setType(RingtoneManager.TYPE_RINGTONE)
                val cursor = manager.cursor
                val count = cursor.count
                android.util.Log.d("RingtonePlugin", "Ringtone cursor count: $count")

                if (count > 0) {
                    cursor.moveToFirst()
                    do {
                        try {
                            val position = cursor.position
                            val id = cursor.getString(RingtoneManager.ID_COLUMN_INDEX) ?: position.toString()
                            val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX) ?: "Unknown"
                            val uri = manager.getRingtoneUri(position)?.toString()

                            if (uri != null && !addedUris.contains(uri)) {
                                addedUris.add(uri)
                                val isDefault = uri == defaultRingtoneUri?.toString()
                                ringtones.add(mapOf(
                                    "id" to id,
                                    "title" to title,
                                    "uri" to uri,
                                    "isDefault" to isDefault
                                ))
                                android.util.Log.d("RingtonePlugin", "Added ringtone: $title -> $uri")
                            }
                        } catch (e: Exception) {
                            android.util.Log.e("RingtonePlugin", "Error reading ringtone item: ${e.message}")
                        }
                    } while (cursor.moveToNext())
                }
            } catch (e: Exception) {
                android.util.Log.e("RingtonePlugin", "Error getting ringtones: ${e.message}")
                e.printStackTrace()
            }

            // 获取闹钟铃声
            try {
                val manager = RingtoneManager(ctx)
                manager.setType(RingtoneManager.TYPE_ALARM)
                val cursor = manager.cursor
                val count = cursor.count
                android.util.Log.d("RingtonePlugin", "Alarm ringtones cursor count: $count")

                if (count > 0) {
                    cursor.moveToFirst()
                    do {
                        try {
                            val position = cursor.position
                            val id = cursor.getString(RingtoneManager.ID_COLUMN_INDEX) ?: position.toString()
                            val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX) ?: "Unknown"
                            val uri = manager.getRingtoneUri(position)?.toString()

                            if (uri != null && !addedUris.contains(uri)) {
                                addedUris.add(uri)
                                ringtones.add(mapOf(
                                    "id" to id,
                                    "title" to title,
                                    "uri" to uri,
                                    "isDefault" to false
                                ))
                                android.util.Log.d("RingtonePlugin", "Added alarm: $title -> $uri")
                            }
                        } catch (e: Exception) {
                            android.util.Log.e("RingtonePlugin", "Error reading alarm item: ${e.message}")
                        }
                    } while (cursor.moveToNext())
                }
            } catch (e: Exception) {
                android.util.Log.e("RingtonePlugin", "Error getting alarm ringtones: ${e.message}")
            }

            // 如果列表仍为空，添加默认铃声
            if (ringtones.isEmpty()) {
                android.util.Log.w("RingtonePlugin", "Ringtone list is empty, adding defaults")

                // 添加默认通知铃声
                if (defaultNotificationUri != null) {
                    try {
                        val ringtone = RingtoneManager.getRingtone(ctx, defaultNotificationUri)
                        val title = ringtone?.getTitle(ctx) ?: "Default Notification"
                        ringtones.add(mapOf(
                            "id" to "default_notification",
                            "title" to title,
                            "uri" to defaultNotificationUri.toString(),
                            "isDefault" to true
                        ))
                        android.util.Log.d("RingtonePlugin", "Added default notification: $title")
                    } catch (e: Exception) {
                        android.util.Log.e("RingtonePlugin", "Error adding default notification: ${e.message}")
                    }
                }

                // 添加默认来电铃声
                if (defaultRingtoneUri != null) {
                    try {
                        val ringtone = RingtoneManager.getRingtone(ctx, defaultRingtoneUri)
                        val title = ringtone?.getTitle(ctx) ?: "Default Ringtone"
                        if (!addedUris.contains(defaultRingtoneUri.toString())) {
                            ringtones.add(mapOf(
                                "id" to "default_ringtone",
                                "title" to title,
                                "uri" to defaultRingtoneUri.toString(),
                                "isDefault" to false
                            ))
                            android.util.Log.d("RingtonePlugin", "Added default ringtone: $title")
                        }
                    } catch (e: Exception) {
                        android.util.Log.e("RingtonePlugin", "Error adding default ringtone: ${e.message}")
                    }
                }
            }

            android.util.Log.d("RingtonePlugin", "Total ringtones found: ${ringtones.size}")
            result.success(ringtones)
        } catch (e: Exception) {
            android.util.Log.e("RingtonePlugin", "Error in getAvailableRingtones: ${e.message}")
            e.printStackTrace()
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
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            } else {
                Uri.parse(uriString)
            }

            if (uri == null) {
                result.error("INVALID_URI", "Could not parse ringtone URI", null)
                return
            }

            currentRingtone = RingtoneManager.getRingtone(getContext(), uri)

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
            val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            result.success(uri?.toString())
        } catch (e: Exception) {
            result.error("GET_DEFAULT_ERROR", e.message, null)
        }
    }
}
