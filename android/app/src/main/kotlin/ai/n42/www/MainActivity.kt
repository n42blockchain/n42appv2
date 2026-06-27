package ai.n42.www

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

        // Passkey (WebAuthn) channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "n42.wallet/passkey")
            .setMethodCallHandler(PasskeyHandler(this))

        // 本地 LLM 推理 (MediaPipe Gemma)
        LocalLlmHandler.register(flutterEngine, this)

        // Chat virtual background publisher frame injection.
        VirtualBackgroundHandler.register(flutterEngine)
    }
}
