package ai.n42.www

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
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
    }
}
