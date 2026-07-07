package ai.n42.www

import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.util.Base64 as aBase64
import androidx.core.content.ContextCompat.startActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.EventChannel
import ai.n42.www.walletcore.KeyManagementHandler
import ai.n42.www.walletcore.TransactionSignerHandler
import ai.n42.www.walletcore.MiningHandler
import wallet.core.jni.HDWallet
import wallet.core.jni.CoinType
import wallet.core.jni.TONWallet
import wallet.core.jni.Curve
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.security.MessageDigest
import org.json.JSONObject

class TrustdartPlugin: FlutterPlugin, MethodCallHandler {

    init {
        System.loadLibrary("TrustWalletCore")
    }

    companion object {
        private val TON_APP_CONTEXT_HASH: ByteArray by lazy {
            MessageDigest.getInstance("SHA-256").digest("ton-connect".toByteArray(Charsets.UTF_8))
        }
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

    private fun handleCoreCall(call: MethodCall, result: MethodChannel.Result) {
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

            "getTonWalletStateInit" -> {
                val mnemonic: String? = call.argument("mnemonic")
                val path: String? = call.argument("path")
                if (mnemonic.isNullOrEmpty() || path.isNullOrEmpty()) {
                    result.success(null)
                } else {
                    try {
                        val wallet = HDWallet(mnemonic, "")
                        val privateKey = wallet.getKey(CoinType.TON, path)
                        val pubKey = privateKey.publicKeyEd25519
                        val stateInitBase64 = TONWallet.buildV4R2StateInit(pubKey, 0, 698983191)
                        val derivedAddr = CoinType.TON.deriveAddress(privateKey)
                        if (stateInitBase64.isNullOrEmpty()) {
                            result.success(null)
                        } else {
                            result.success("ADDR:$derivedAddr|$stateInitBase64")
                        }
                    } catch (e: Exception) {
                        result.error("ton_state_init_error", e.message, null)
                    }
                }
            }

            "signTonProof" -> {
                val mnemonic: String? = call.argument("mnemonic")
                val path: String? = call.argument("path")
                val domain: String? = call.argument("domain")
                val timestamp: Long = (call.argument<Any>("timestamp") as? Number)?.toLong()
                    ?: (System.currentTimeMillis() / 1000L)
                val payload: String? = call.argument("payload")
                val tonAddress: String? = call.argument("address")
                if (mnemonic.isNullOrEmpty() || path.isNullOrEmpty()) {
                    result.success(null)
                } else {
                    try {
                        val wallet = HDWallet(mnemonic, "")
                        val privateKey = wallet.getKey(CoinType.TON, path)
                        val address = if (!tonAddress.isNullOrEmpty()) tonAddress
                                      else CoinType.TON.deriveAddress(privateKey)
                        val addrDecoded = decodeTonAddress(address)
                        val workchain = addrDecoded?.first ?: 0
                        val addrHash = addrDecoded?.second ?: ByteArray(32)
                        val domainStr = domain ?: ""
                        val payloadStr = payload ?: ""
                        val domainBytes = domainStr.toByteArray(Charsets.UTF_8)
                        val payloadBytes = payloadStr.toByteArray(Charsets.UTF_8)
                        // Build message per TonConnect ton_proof spec
                        val baos = ByteArrayOutputStream()
                        baos.write("ton-proof-item-v2/".toByteArray(Charsets.UTF_8))
                        baos.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(workchain).array())
                        baos.write(addrHash)
                        baos.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(domainBytes.size).array())
                        baos.write(domainBytes)
                        baos.write(ByteBuffer.allocate(8).order(ByteOrder.LITTLE_ENDIAN).putLong(timestamp).array())
                        baos.write(payloadBytes)
                        val message = baos.toByteArray()
                        val messageHash = MessageDigest.getInstance("SHA-256").digest(message)
                        // bufToSign = 0xffff ++ sha256("ton-connect") ++ sha256(message)
                        val bufToSign = ByteArray(66)
                        bufToSign[0] = 0xff.toByte()
                        bufToSign[1] = 0xff.toByte()
                        System.arraycopy(TON_APP_CONTEXT_HASH, 0, bufToSign, 2, 32)
                        System.arraycopy(messageHash, 0, bufToSign, 34, 32)
                        val signature = privateKey.sign(bufToSign, Curve.ED25519)
                        val signatureBase64 = aBase64.encodeToString(signature, aBase64.NO_WRAP)
                        val proofResult = JSONObject().apply {
                            put("timestamp", timestamp)
                            put("domain", JSONObject().apply {
                                put("lengthBytes", domainBytes.size)
                                put("value", domainStr)
                            })
                            put("payload", payloadStr)
                            put("signature", signatureBase64)
                        }
                        result.success(proofResult.toString())
                    } catch (e: Exception) {
                        result.error("ton_proof_error", e.message, null)
                    }
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun decodeTonAddress(address: String): Pair<Int, ByteArray>? {
        return try {
            val standardB64 = address.replace('-', '+').replace('_', '/')
            val decoded = aBase64.decode(standardB64, aBase64.DEFAULT)
            if (decoded.size != 36) return null
            val workchain = decoded[1].toInt()
            val hash = decoded.copyOfRange(2, 34)
            Pair(workchain, hash)
        } catch (e: Exception) {
            null
        }
    }

    private fun handleCoreCall2(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connectWebSocket" -> {
                val args = call.arguments as? Map<String, *>
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
        mp?.release()
        mp = MediaPlayer.create(context, R.raw.silent).apply {
            isLooping = true
            start()
        }
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(context, intent, Bundle.EMPTY)
        return "true"
    }

    private fun playAudioEnd(): String {
        return if (mp != null) {
            mp?.stop()
            mp?.release()
            mp = null
            "true"
        } else {
            "false"
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
