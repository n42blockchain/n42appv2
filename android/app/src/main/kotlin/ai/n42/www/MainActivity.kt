package ai.n42.www

import android.content.Intent
import android.provider.CalendarContract
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private fun stringResource(name: String): String? {
        val id = resources.getIdentifier(name, "string", packageName)
        if (id == 0) return null
        return normalizeValue(getString(id))
    }

    private fun normalizeValue(value: String?): String? {
        val trimmed = value?.trim().orEmpty()
        if (trimmed.isEmpty() || trimmed == "null") return null
        if (trimmed.startsWith("\$(") && trimmed.endsWith(")")) return null
        return trimmed
    }

    private fun socialAuthConfig(): Map<String, String?> {
        val googleServerClientId =
            stringResource("n42_chat_google_server_client_id")
                ?: stringResource("default_web_client_id")
        return mapOf(
            "googleClientId" to stringResource("n42_chat_google_client_id"),
            "googleServerClientId" to googleServerClientId,
            "twitterApiKey" to stringResource("n42_chat_twitter_api_key"),
            "twitterApiSecret" to stringResource("n42_chat_twitter_api_secret"),
            "twitterRedirectUri" to (
                stringResource("n42_chat_twitter_redirect_uri") ?: "n42://auth/twitter"
            ),
            "weChatAppId" to stringResource("n42_chat_wechat_app_id"),
            "weChatUniversalLink" to stringResource("n42_chat_wechat_universal_link"),
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(TrustdartPlugin())
        flutterEngine.plugins.add(RingtonePlugin())

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ai.n42.www/window_flags")
            .setMethodCallHandler { call, result ->
                if (call.method == "setFlagSecure") {
                    val enable = call.arguments as? Boolean ?: false
                    if (enable) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ai.n42.www/app_config")
            .setMethodCallHandler { call, result ->
                if (call.method == "getSocialAuthConfig") {
                    result.success(socialAuthConfig())
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "n42.chat/calendar")
            .setMethodCallHandler { call, result ->
                if (call.method != "addEvent") { result.notImplemented(); return@setMethodCallHandler }
                val args = call.arguments as? Map<*, *>
                val title = args?.get("title") as? String
                val start = (args?.get("starts_at") as? Number)?.toLong()
                if (title == null || start == null) {
                    result.error("invalid_event", "Invalid calendar event", null)
                    return@setMethodCallHandler
                }
                val intent = Intent(Intent.ACTION_INSERT).setData(CalendarContract.Events.CONTENT_URI)
                    .putExtra(CalendarContract.Events.TITLE, title)
                    .putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, start)
                    .putExtra(CalendarContract.EXTRA_EVENT_END_TIME, (args?.get("ends_at") as? Number)?.toLong() ?: start + 3600000)
                    .putExtra(CalendarContract.Events.EVENT_LOCATION, args?.get("location") as? String)
                    .putExtra(CalendarContract.Events.DESCRIPTION, args?.get("description") as? String)
                try { startActivity(intent); result.success(true) }
                catch (_: android.content.ActivityNotFoundException) {
                    result.error("unavailable", "No calendar app is installed", null)
                }
            }

        // Passkey (WebAuthn) channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "n42.wallet/passkey")
            .setMethodCallHandler(PasskeyHandler(this))

        // 本地 LLM 推理 (MediaPipe Gemma)
        LocalLlmHandler.register(flutterEngine, this)

        // OpenMLS native bridge for n42_chat.
        MlsChannelHandler.register(flutterEngine, this)

        // Chat virtual background publisher frame injection.
        VirtualBackgroundHandler.register(flutterEngine)
    }
}
