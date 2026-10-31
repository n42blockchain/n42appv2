package mining.ai.n42.www.flutter_mining

import android.os.Handler
import android.os.Looper
import evmsdk.Evmsdk
import evmsdk.MobileVerifySession
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Mining v3: the N42 mobile verification loop on the "n42/mobileverify"
 * channel, backed by evmsdk.MobileVerifySession from the same evm.aar
 * that serves v1's Evmsdk.emit, so the app links one Go runtime.
 *
 * The session's calls block (HTTP and block re-execution), so they run
 * in order on one background thread and answer on the main thread.
 * "close" runs at once: it aborts the call in flight.
 */
class MobileVerifyHandler : MethodChannel.MethodCallHandler {
    private val worker: ExecutorService = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    @Volatile
    private var session: MobileVerifySession? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "close" -> {
                session?.close()
                session = null
                result.success(null)
            }
            in BLOCKING -> worker.execute {
                val outcome = runCatching { dispatch(call) }
                main.post {
                    outcome.fold(
                        onSuccess = { result.success(it) },
                        onFailure = { result.error("MobileVerify", it.message, null) },
                    )
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun dispatch(call: MethodCall): Any? = when (call.method) {
        "generateKey" -> Evmsdk.generateMobileBLSKey().privHex
        "publicKey" -> Evmsdk.mobileBLSPublicKey(call.require("privHex"))
        "open" -> {
            session?.close()
            val opened = Evmsdk.newMobileVerifySession(
                call.require("baseUrl"),
                call.require("privHex"),
                call.require("chain"),
            )
            session = opened
            opened.pubkeyHex()
        }
        "register" -> current().register()
        "latest" -> current().latest()
        "verifyBlock" -> current().verifyBlock(call.require("blockHash"))
        "cert" -> current().cert(call.require("blockHash"))
        "health" -> current().health()
        else -> throw IllegalStateException("unhandled ${call.method}")
    }

    private fun current(): MobileVerifySession =
        session ?: throw IllegalStateException("no mobileverify session; call open first")

    private fun MethodCall.require(key: String): String =
        argument<String>(key) ?: throw IllegalArgumentException("missing argument $key")

    fun dispose() {
        session?.close()
        session = null
        worker.shutdown()
    }

    private companion object {
        val BLOCKING = setOf(
            "generateKey", "publicKey", "open", "register",
            "latest", "verifyBlock", "cert", "health",
        )
    }
}
