package com.n42.android_native_smoke

import com.hiennv.flutter_callkit_incoming.getDataActiveCalls
import com.hiennv.flutter_callkit_incoming.removeAllCalls
import com.google.mediapipe.tasks.genai.llminference.jni.proto.LlmOptionsProto
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.math.BigInteger
import java.net.InetSocketAddress
import java.net.URI
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicReference
import org.bouncycastle.jce.provider.BouncyCastleProvider
import org.java_websocket.WebSocket
import org.java_websocket.client.WebSocketClient
import org.java_websocket.handshake.ClientHandshake
import org.java_websocket.handshake.ServerHandshake
import org.java_websocket.server.WebSocketServer
import org.torusresearch.torusutils.helpers.KeyUtils
import org.web3j.crypto.Bip32ECKeyPair
import org.web3j.crypto.ECKeyPair
import org.web3j.crypto.Hash
import org.web3j.crypto.Keys
import org.web3j.crypto.MnemonicUtils
import org.web3j.crypto.Sign
import org.web3j.utils.Numeric

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.n42.android_native_smoke/vectors")
            .setMethodCallHandler { call, result ->
                if (call.method != "verify" && call.method != "compatibility") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    if (call.method == "verify") {
                        verifyNativeVectors()
                        result.success(true)
                    } else {
                        result.success(torusCompatibilityVectors())
                    }
                } catch (error: Throwable) {
                    result.error("NATIVE_VECTOR", error.toString(), null)
                }
            }
    }

    private fun torusCompatibilityVectors(): Map<String, String> {
        val keys = listOf(
            BigInteger.ONE,
            BigInteger("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef", 16),
        )
        val results = mutableMapOf<String, String>()
        keys.forEachIndexed { index, key ->
            val rawPrivate = Numeric.toHexStringNoPrefixZeroPadded(key, 64)
            val publicKey = KeyUtils.privateToPublic(key)
            val fromPublic = KeyUtils.generateAddressFromPubKey(
                publicKey.substring(2, 66), publicKey.substring(66),
            )
            results["$index:fromPublic"] = fromPublic
            results["$index:fromPrivate"] = KeyUtils.generateAddressFromPrivKey(rawPrivate)
        }
        return results
    }

    private fun verifyNativeVectors() {
        check(BouncyCastleProvider().info.contains("v1.86")) { "Bouncy Castle provider version: ${BouncyCastleProvider().info}" }
        val key = ECKeyPair.create(BigInteger.ONE)
        val expectedAddress = "7e5f4552091a69125d5dfcb7b8c2659029395bdf"
        check(Keys.getAddress(key).lowercase() == expectedAddress) { "Web3j address" }
        check(Numeric.toHexString(Hash.sha3("abc".toByteArray())) ==
            "0x4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45") { "Web3j Keccak" }

        val message = "offline Web3Auth boundary".toByteArray()
        val signature = Sign.signPrefixedMessage(message, key)
        check(Sign.signedPrefixedMessageToKey(message, signature) == key.publicKey) { "Web3j signature recovery" }
        val torusPublicKey = KeyUtils.privateToPublic(BigInteger.ONE)
        check(torusPublicKey.length == 130 && torusPublicKey.startsWith("04")) {
            "Torus uncompressed public key"
        }
        val torusAddress = KeyUtils.generateAddressFromPubKey(
            torusPublicKey.substring(2, 66), torusPublicKey.substring(66),
        )
        check(torusAddress.removePrefix("0x").lowercase() == expectedAddress) {
            "Torus address: $torusAddress"
        }

        val mnemonic = MnemonicUtils.generateMnemonic(ByteArray(16))
        check(mnemonic == List(11) { "abandon" }.plus("about").joinToString(" ")) { "BIP39 mnemonic" }
        val seed = MnemonicUtils.generateSeed(mnemonic, "TREZOR")
        check(Numeric.toHexStringNoPrefix(seed) ==
            "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e5349553" +
            "1f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04") {
            "BIP39 seed"
        }

        // BIP32 official vector 1: seed 000102...0f, child m/0H. The private
        // key is decoded from the published xprv; the Ethereum address is the
        // independent secp256k1/Keccak result for that key.
        val bip32Seed = Numeric.hexStringToByteArray("000102030405060708090a0b0c0d0e0f")
        val master = Bip32ECKeyPair.generateKeyPair(bip32Seed)
        val derived = Bip32ECKeyPair.deriveKeyPair(
            master, intArrayOf(Bip32ECKeyPair.HARDENED_BIT),
        )
        check(Numeric.toHexStringNoPrefixZeroPadded(derived.privateKey, 64) ==
            "edb2e14f9ee77d26dd93b4ecede8d16ed408ce149b6cd80b0715a2d911a0afea") {
            "BIP32 m/0H private key"
        }
        check(Keys.getAddress(derived).lowercase() ==
            "bf6e48966d0dcf553b53e7b56cb2e0e72dca9e19") {
            "BIP32 m/0H Ethereum address"
        }

        // MediaPipe's 0.10.35 generated lite message runs against the selected
        // protobuf-javalite 4.36.2 runtime, including wire serialization.
        val llmConfig = LlmOptionsProto.LlmSessionConfig.newBuilder()
            .setTopk(7).setTemperature(0.5f).build()
        val parsedConfig = LlmOptionsProto.LlmSessionConfig.parseFrom(llmConfig.toByteArray())
        check(parsedConfig.topk == 7 && parsedConfig.temperature == 0.5f) {
            "MediaPipe protobuf lite roundtrip"
        }

        verifyWebSocketLoopback()

        // The CallKit plugin persists this ArrayList<Data> JSON shape across updates.
        val preferences = getSharedPreferences("flutter_callkit_incoming", MODE_PRIVATE)
        check(preferences.edit().putString("ACTIVE_CALLS",
            """[{"args":{},"id":"historical-call","nameCaller":"Fixture","handle":"123","type":0,"duration":30000}]"""
        ).commit()) { "CallKit persisted fixture" }
        try {
            val active = getDataActiveCalls(this)
            check(active.size == 1 && active[0].id == "historical-call") { "CallKit persisted JSON parse" }
        } finally {
            removeAllCalls(this)
        }
    }

    private fun verifyWebSocketLoopback() {
        val started = CountDownLatch(1)
        val echoed = CountDownLatch(1)
        val error = AtomicReference<String?>(null)
        val server = object : WebSocketServer(InetSocketAddress("127.0.0.1", 0)) {
            override fun onStart() { started.countDown() }
            override fun onOpen(connection: WebSocket, handshake: ClientHandshake) {}
            override fun onClose(connection: WebSocket, code: Int, reason: String, remote: Boolean) {}
            override fun onMessage(connection: WebSocket, message: String) {
                connection.send("echo:$message")
            }
            override fun onError(connection: WebSocket?, exception: Exception) {
                error.set(exception.toString())
                started.countDown()
                echoed.countDown()
            }
        }
        server.start()
        var client: WebSocketClient? = null
        try {
            check(started.await(5, TimeUnit.SECONDS)) { "WebSocket server start timeout" }
            check(error.get() == null) { "WebSocket server: ${error.get()}" }
            client = object : WebSocketClient(URI("ws://127.0.0.1:${server.port}")) {
                override fun onOpen(handshake: ServerHandshake) {}
                override fun onMessage(message: String) {
                    if (message == "echo:native-graph") echoed.countDown()
                }
                override fun onClose(code: Int, reason: String, remote: Boolean) {}
                override fun onError(exception: Exception) {
                    error.set(exception.toString())
                    echoed.countDown()
                }
            }
            check(client.connectBlocking(5, TimeUnit.SECONDS)) { "WebSocket handshake timeout" }
            client.send("native-graph")
            check(echoed.await(5, TimeUnit.SECONDS)) { "WebSocket echo timeout" }
            check(error.get() == null) { "WebSocket client: ${error.get()}" }
        } finally {
            client?.close()
            server.stop(1000)
        }
    }
}
