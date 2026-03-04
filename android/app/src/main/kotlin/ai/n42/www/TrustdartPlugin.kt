package ai.n42.www

import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import androidx.core.content.ContextCompat.startActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.EventChannel
import ai.n42.www.walletcore.KeyManagementHandler
import ai.n42.www.walletcore.TransactionSignerHandler
import ai.n42.www.walletcore.MiningHandler

class TrustdartPlugin: FlutterPlugin, MethodCallHandler {

    init {
        System.loadLibrary("TrustWalletCore")
    }

    private lateinit var channel: MethodChannel
    private lateinit var channel2: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context

    // ── Handlers ─────────────────────────────────────────────────────────
    private val keyHandler = KeyManagementHandler()
    private val txHandler = TransactionSignerHandler(keyHandler)
    private lateinit var miningHandler: MiningHandler

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "trustdart")
        channel.setMethodCallHandler { call, result ->
            handleCoreCall(call, result)
        }
        channel2 = MethodChannel(flutterPluginBinding.binaryMessenger, "trustdart_mining")
        channel2.setMethodCallHandler { call, result ->
            handleCoreCall2(call, result)
        }
        context = flutterPluginBinding.applicationContext

        miningHandler = MiningHandler { channel }

        eventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "trustdart_ws_events"
        )
        eventChannel.setStreamHandler(WebSocketEventChannelHandler)
    }

    fun handleCoreCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // ── Key management ───────────────────────────────────────────
            "generateMnemonic"          -> keyHandler.handleGenerateMnemonic(call, result)
            "checkMnemonic"             -> keyHandler.handleCheckMnemonic(call, result)
            "generateAddress"           -> keyHandler.handleGenerateAddress(call, result)
            "validateAddress"           -> keyHandler.handleValidateAddress(call, result)
            "getPublicKey"              -> keyHandler.handleGetPublicKey(call, result)
            "getPrivateKey"             -> keyHandler.handleGetPrivateKey(call, result)
            "getPrivateKeyAndPublicKey" -> keyHandler.handleGetPrivateKeyAndPublicKey(call, result)
            "getKeyStore"               -> keyHandler.handleGetKeyStore(call, result)
            "getWalletInfoWithKeyStore" -> keyHandler.handleGetWalletInfoWithKeyStore(call, result)

            // ── Transaction signing ──────────────────────────────────────
            "signTransaction"              -> txHandler.handleSignTransaction(call, result)
            "signTransaction_g"            -> txHandler.handleSignTransactionG(call, result)
            "signTransaction_btc_p2wsh"    -> txHandler.handleSignTransactionBtcP2wsh(call, result)
            "signTransaction_byteArray"    -> txHandler.handleSignTransactionByteArray(call, result)
            "signMessage"                  -> txHandler.handleSignMessage(call, result)
            "getTransactionMaxValue"       -> txHandler.handleGetTransactionMaxValue(call, result)
            "EvmEmit"                      -> txHandler.handleEvmEmit(call, result)
            "getPubKeySOL"                 -> txHandler.handleGetPubKeySOL(call, result)

            // ── Mining ───────────────────────────────────────────────────
            "MiningGenerateBls12381Keypair"    -> miningHandler.handleGenerateBls12381Keypair(call, result)
            "MiningCreateDepositUnsignedTx"    -> miningHandler.handleCreateDepositUnsignedTx(call, result)
            "MiningCreateExitUnsignedTx"       -> miningHandler.handleCreateExitUnsignedTx(call, result)
            "MiningCreateGetExitFeeUnsignedTx" -> miningHandler.handleCreateGetExitFeeUnsignedTx(call, result)
            "MiningRunClient"                  -> miningHandler.handleRunClient(call, result)
            "MiningStopClient"                 -> miningHandler.handleStopClient(call, result)

            // ── Audio (LiveActivity) ─────────────────────────────────────
            "LiveActivityStart" -> {
                val rString: String = playAudio()
                result.success(rString)
            }
            "LiveActivityEnd" -> {
                val rString: String = playAudioEnd()
                result.success(rString)
            }

            else -> result.notImplemented()
        }
    }

    fun handleCoreCall2(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connectWebSocket" -> {
                val args = call.arguments as? Map<*, *>
                if (args == null) {
                    result.error("arguments_error", "arguments is null", null)
                    return
                }

                val wsUrl = args["wsUrl"] as? String
                val pubkey = args["validatorPubkey"] as? String
                val privateKey = args["validatorPrivateKey"] as? String

                if (wsUrl.isNullOrBlank() ||
                    pubkey.isNullOrBlank() ||
                    privateKey.isNullOrBlank()
                ) {
                    result.error(
                        "arguments_null",
                        "wsUrl / validatorPubkey / validatorPrivateKey cannot be null",
                        null
                    )
                    return
                }

                val intent = Intent(context, WebSocketService::class.java).apply {
                    putExtra("wsUrl", wsUrl)
                    putExtra("validatorPubkey", pubkey)
                    putExtra("validatorPrivateKey", privateKey)
                }

                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(intent)
                    } else {
                        context.startService(intent)
                    }
                    result.success("WebSocketService started / updated")
                } catch (e: Exception) {
                    result.error("service_start_failed", e.message, null)
                }
            }

            "disconnectWebSocket" -> {
                try {
                    val intent = Intent(context, WebSocketService::class.java)
                    context.stopService(intent)
                    result.success("WebSocketService stopped")
                } catch (e: Exception) {
                    result.error("service_stop_failed", e.message, null)
                }
            }

            else -> result.notImplemented()
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // Legacy entry point — delegates to handleCoreCall which covers all methods
        handleCoreCall(call, result)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        channel2.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    // ── Audio helpers (kept in plugin — context-dependent) ───────────────

    private var mp: MediaPlayer? = null

    private fun playAudio(): String {
        mp = MediaPlayer.create(context, R.raw.silent)

        mp?.isLooping = true
        mp?.start()
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_HOME)
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(context, intent, Bundle.EMPTY)

        return "true"
    }

    private fun playAudioEnd(): String {
        if (mp != null) {
            mp?.stop()
            return "true"
        } else {
            return "false"
        }
    }
}

object WebSocketEventChannelHandler : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun send(message: String) {
        eventSink?.success(message)
    }

    fun sendError(code: String, message: String, details: Any? = null) {
        eventSink?.error(code, message, details)
    }
}
