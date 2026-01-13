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

class MyWebSocketListener(
    private val validatorPubkey: String,
    private val validatorPrivateKey: String,
    private val onDisconnected: () -> Unit
) : WebSocketListener() {

    private val mainHandler = Handler(Looper.getMainLooper())
    private val disconnectedOnce = AtomicBoolean(false)

    override fun onOpen(webSocket: WebSocket, response: Response) {
        Log.i("WebSocket", "Connected")

        sendToFlutter("WebSocket connected")

        val subscribeJson = JSONObject().apply {
            put("jsonrpc", "2.0")
            put("method", "consensusBeaconExt_subscribeToVerificationRequest")
            put("id", 1)
            put("params", JSONArray().put(validatorPubkey))
        }

        webSocket.send(subscribeJson.toString())
    }

    override fun onMessage(webSocket: WebSocket, text: String) {
        Log.i("WebSocket", "Received: $text")

        sendToFlutter(text)

        try {
            val json = JSONObject(text)
            if (json.optString("method") == "subscribeToVerificationRequest") {
                val result = json
                    .getJSONObject("params")
                    .getJSONObject("result")

                val verifyResultStr =
                    Api.genBlockVerifyResult(result.toString(), validatorPrivateKey).join()

                val verifyResult = JSONObject(verifyResultStr)

                val submit = JSONObject().apply {
                    put("id", 1)
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
            }
        } catch (e: Exception) {
            Log.e("WebSocket", "Message parse error", e)
        }
    }

    override fun onFailure(
        webSocket: WebSocket,
        t: Throwable,
        response: Response?
    ) {
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
