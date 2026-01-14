package ai.n42.www

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.mobileSdk.Api
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.atomic.AtomicBoolean

/**
 * WebSocketListener 实现，用于订阅验证请求并提交验证结果。
 * 消息会通过 WebSocketEventChannelHandler 发送到 Flutter。
 *
 * @param validatorPubkey 验证者公钥
 * @param validatorPrivateKey 验证者私钥
 * @param onDisconnected WebSocket 断开连接回调
 */
class MyWebSocketListener(
    private val validatorPubkey: String,
    private val validatorPrivateKey: String,
    private val onDisconnected: () -> Unit
) : WebSocketListener() {

    private val mainHandler = Handler(Looper.getMainLooper())
    private val disconnectedOnce = AtomicBoolean(false)
    private var tCount = 1

    override fun onOpen(webSocket: WebSocket, response: Response) {
        Log.i("WebSocket", "Connected")
        sendToFlutter("WebSocket connected")

        // 构建订阅验证请求的 JSON
        val subscribeJson = JSONObject().apply {
            put("jsonrpc", "2.0")
            put("method", "consensusBeaconExt_subscribeToVerificationRequest")
            put("id", tCount++)
            put("params", JSONArray().put(validatorPubkey))
        }

        webSocket.send(subscribeJson.toString())
    }

    override fun onMessage(webSocket: WebSocket, text: String) {
        Log.i("WebSocket", "Received: $text")
        sendToFlutter(text)

        val json = try {
            JSONObject(text)
        } catch (e: Exception) {
            Log.e("WebSocket", "Invalid JSON", e)
            return
        }

        // 只处理订阅验证请求
        if (json.optString("method") != "subscribeToVerificationRequest") return

        val result = try {
            json.getJSONObject("params").getJSONObject("result")
        } catch (e: Exception) {
            Log.e("WebSocket", "Missing result in params", e)
            return
        }

        // 在子线程中生成验证结果并提交
        Thread {
            try {
                val verifyResultStr =
                    Api.genBlockVerifyResult(result.toString(), validatorPrivateKey).join()
                val verifyResult = JSONObject(verifyResultStr)

                val submit = JSONObject().apply {
                    put("id", tCount++)
                    put("jsonrpc", "2.0")
                    put("method", "consensusBeaconExt_submitVerification")
                    put(
                        "params",
                        JSONArray().apply {
                            put(verifyResult.getString("pubkey"))
                            put(verifyResult.getString("signature"))
                            put(verifyResult.getJSONObject("attestation_data"))
                            put(verifyResult.getString("block_hash"))
                        }
                    )
                }

                val ok = webSocket.send(submit.toString())
                Log.i("WebSocket", "submitVerification sent: $ok")
            } catch (e: Exception) {
                Log.e("WebSocket", "verify failed", e)
            }
        }.start()
    }

    override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
        Log.e("WebSocket", "onFailure", t)
        sendToFlutter("onFailure")
        notifyDisconnectedOnce()
    }

    override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
        Log.i("WebSocket", "onClosed: $reason")
        sendToFlutter("onClosed")
        notifyDisconnectedOnce()
    }

    // ================= helpers =================

    private fun sendToFlutter(message: String) {
        mainHandler.post {
            WebSocketEventChannelHandler.send(message)
        }
    }

    private fun notifyDisconnectedOnce() {
        if (disconnectedOnce.compareAndSet(false, true)) {
            mainHandler.post { onDisconnected() }
        }
    }
}
