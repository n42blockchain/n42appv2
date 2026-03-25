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
                        // Use TrustWallet Core native method to build v4R2 stateInit directly
                        // Returns base64-encoded BOC (standard TON format with correct cell ordering)
                        val stateInitBase64 = TONWallet.buildV4R2StateInit(pubKey, 0, 698983191)
                        val derivedAddr = CoinType.TON.deriveAddress(privateKey)
                        if (stateInitBase64.isNullOrEmpty()) {
                            result.success(null)
                        } else {
                            result.success("ADDR:$derivedAddr|$stateInitBase64")
                        }
                    } catch (e: Exception) {
                        result.success(null)
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
                        val md = MessageDigest.getInstance("SHA-256")
                        val messageHash = md.digest(message)
                        val appContextHash = md.digest("ton-connect".toByteArray(Charsets.UTF_8))
                        // bufToSign = 0xffff ++ sha256("ton-connect") ++ sha256(message)
                        val bufToSign = ByteArray(66)
                        bufToSign[0] = 0xff.toByte()
                        bufToSign[1] = 0xff.toByte()
                        System.arraycopy(appContextHash, 0, bufToSign, 2, 32)
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
                        result.success(null)
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
            val workchain = decoded[1].toInt().let { if (it > 127) it - 256 else it }
            val hash = decoded.copyOfRange(2, 34)
            Pair(workchain, hash)
        } catch (e: Exception) {
            null
        }
    }

    private fun extractStateInitFromBoc(boc: ByteArray): ByteArray? {
        if (boc.size < 10) return null
        if (boc[0] != 0xB5.toByte() || boc[1] != 0xEE.toByte() ||
            boc[2] != 0x9C.toByte() || boc[3] != 0x72.toByte()) return null

        var pos = 4
        fun byte(): Int = boc[pos++].toInt() and 0xFF
        fun uint(n: Int): Int { var r = 0; repeat(n) { r = (r shl 8) or byte() }; return r }

        val flagsByte = byte()
        val hasIdx = (flagsByte shr 7) and 1 == 1
        val refSize = flagsByte and 0x07
        val offBytes = byte()

        val cellCount = uint(refSize)
        uint(refSize) // root_count
        uint(refSize) // absent_count
        uint(offBytes) // tot_cells_size
        uint(refSize) // root_index

        if (hasIdx) pos += cellCount * offBytes

        val cellD1 = IntArray(cellCount)
        val cellD2 = IntArray(cellCount)
        val cellData = Array(cellCount) { ByteArray(0) }
        val cellRefs = Array(cellCount) { IntArray(0) }

        for (i in 0 until cellCount) {
            val d1 = byte()
            val d2 = byte()
            val refsCount = d1 and 0x07
            val dataLen = (d2 ushr 1) + (d2 and 1)
            cellD1[i] = d1
            cellD2[i] = d2
            cellData[i] = boc.copyOfRange(pos, pos + dataLen); pos += dataLen
            cellRefs[i] = IntArray(refsCount) { uint(refSize) }
        }

        // Find stateInit cell: d1=0x02 (2 refs), d2=0x01 (5 bits), data=[0x34]
        var stateInitIdx = -1
        for (i in 0 until cellCount) {
            if (cellD1[i] == 0x02 && cellD2[i] == 0x01 &&
                cellData[i].size == 1 && cellData[i][0] == 0x34.toByte()) {
                stateInitIdx = i
                break
            }
        }
        if (stateInitIdx < 0) return null

        // BFS collect all cells in the stateInit subtree
        val orderedIndices = mutableListOf<Int>()
        val visited = mutableSetOf<Int>()
        val queue = ArrayDeque<Int>()
        queue.add(stateInitIdx)
        visited.add(stateInitIdx)
        while (queue.isNotEmpty()) {
            val idx = queue.removeFirst()
            orderedIndices.add(idx)
            for (ref in cellRefs[idx]) {
                if (visited.add(ref)) queue.add(ref)
            }
        }

        val oldToNew = HashMap<Int, Int>()
        for ((newIdx, oldIdx) in orderedIndices.withIndex()) oldToNew[oldIdx] = newIdx

        // Total cell data size with refSize=1
        var totSize = 0
        for (oldIdx in orderedIndices) {
            val refsCount = cellD1[oldIdx] and 0x07
            totSize += 2 + cellData[oldIdx].size + refsCount
        }

        val out = java.io.ByteArrayOutputStream()
        out.write(byteArrayOf(0xB5.toByte(), 0xEE.toByte(), 0x9C.toByte(), 0x72.toByte()))
        out.write(0x01) // flags: size=1
        out.write(0x02) // off_bytes=2
        out.write(orderedIndices.size) // cell_count
        out.write(0x01) // root_count
        out.write(0x00) // absent_count
        out.write((totSize shr 8) and 0xFF)
        out.write(totSize and 0xFF)
        out.write(0x00) // root_index=0

        for (oldIdx in orderedIndices) {
            out.write(cellD1[oldIdx])
            out.write(cellD2[oldIdx])
            out.write(cellData[oldIdx])
            for (ref in cellRefs[oldIdx]) out.write(oldToNew[ref]!!)
        }

        return out.toByteArray()
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
