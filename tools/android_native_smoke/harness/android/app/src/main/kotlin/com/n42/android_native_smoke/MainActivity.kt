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
import com.mobileSdk.Api
import ai.n42.tls.MobileSdkTlsVerifier
import org.rustls.platformverifier.CertificateVerifierTests
import org.json.JSONArray
import org.json.JSONObject
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.n42.android_native_smoke/vectors")
            .setMethodCallHandler { call, result ->
                if (call.method !in listOf("verify", "compatibility", "mobileSdkLoad", "mobileSdkVectors", "mobileSdkTlsInit", "mobileSdkTlsCerts", "mobileSdkBlsPair", "goEvmVectors")) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    when (call.method) {
                        "verify" -> {
                            verifyNativeVectors()
                            result.success(true)
                        }
                        "compatibility" -> result.success(torusCompatibilityVectors())
                        "mobileSdkLoad" -> {
                            Class.forName("com.mobileSdk.NativeBindings", true, classLoader)
                            result.success(true)
                        }
                        "mobileSdkTlsInit" -> {
                            Class.forName("com.mobileSdk.NativeBindings", true, classLoader)
                            val verifier = MobileSdkTlsVerifier()
                            result.success(verifier.initialize(applicationContext) &&
                                verifier.initialize(applicationContext))
                        }
                        "mobileSdkTlsCerts" -> {
                            Class.forName("com.mobileSdk.NativeBindings", true, classLoader)
                            check(MobileSdkTlsVerifier().initialize(applicationContext))
                            result.success(mapOf(
                                "untrusted" to CertificateVerifierTests.verifyMockRootUsage(applicationContext),
                                "mockChain" to CertificateVerifierTests.mockTests(applicationContext),
                            ))
                        }
                        "mobileSdkVectors" -> result.success(mobileSdkVectors())
                        "goEvmVectors" -> result.success(goEvmVectors())
                        "mobileSdkBlsPair" -> {
                            Class.forName("com.mobileSdk.NativeBindings", true, classLoader)
                            val pair = JSONArray(Api.generateBls12381Keypair())
                            result.success(BlsOracle.verifyPair(pair.getString(0), pair.getString(1)))
                        }
                    }
                } catch (error: Throwable) {
                    result.error("NATIVE_VECTOR", error.toString(), null)
                }
            }
    }

    private fun goEvmVectors(): Map<String, String> {
        // Reflection defers loading the unknown old Go AAR until the fixture
        // runner has verified the disposable emulator is offline.
        val emit = Class.forName("evmsdk.Evmsdk", true, classLoader)
            .getMethod("emit", String::class.java)
        fun request(type: String, value: JSONObject? = null): String {
            val json = JSONObject().put("type", type)
            if (value != null) json.put("val", value)
            return json.toString()
        }
        fun call(json: String): String {
            val response = emit.invoke(null, json) as String
            JSONObject(response)
            return response
        }

        val low = "00".repeat(31) + "01"
        val high = "ff".repeat(32)
        val message = "8ac7230489e80000" // 10 * 10^18 wei, even hex
        val results = linkedMapOf<String, String>()
        val setting = JSONObject()
            .put("app_base_path", filesDir.absolutePath)
            .put("account", "N42-fixture")
            .put("priv_key", "01".repeat(32))
            .put("server_uri", "ws://127.0.0.1:9")
            .put("log_level", "")
        results["setting"] = call(request("setting", setting))
        results["state"] = call(request("state"))
        results["stop"] = call(request("stop"))
        results["repeatStop"] = call(request("stop"))
        results["partialSetting"] = call(request("setting", JSONObject().put("server_uri", "ws://127.0.0.1:10")))
        for ((label, key) in listOf("low" to low, "high" to high)) {
            results["${label}Pubkey"] = call(request("blspubk", JSONObject().put("priv_key", key)))
            results["${label}Signature"] = call(request("blssign", JSONObject().put("priv_key", key).put("msg", message)))
        }
        results["invalidJson"] = call("{\"type\":")
        results["invalidKeyLength"] = call(request("blspubk", JSONObject().put("priv_key", "00")))
        results["invalidKeyHex"] = call(request("blspubk", JSONObject().put("priv_key", "zz")))
        results["invalidMessageHex"] = call(request("blssign", JSONObject().put("priv_key", low).put("msg", "zz")))
        return results
    }

    private fun mobileSdkVectors(): Map<String, String> {
        val deposit = Api.createDepositUnsignedTx(
            "0x5FbDB2315678afecb367f032d93F642f64180aa3",
            "0x6be6c38a5986be6c7094e92017af0d15da0af6857362e2ba0c2103c3eb893eec",
            "0xa0Ee7A142d267C1f36714E4a8F75612F20a79720",
            "0x1bc16d674ec800000",
        )
        val exit = Api.createExitUnsignedTx(
            "0x8a2470d8ccb2e43b3b5295cfee71508f8808e166e5f152d5af9fe022d95e300dc7c5814f2c9eb71e2da8412beb61c53a",
            "0x1",
        )
        val feeCall = Api.createGetExitFeeUnsignedTx()
        val pair = JSONArray(Api.generateBls12381Keypair())
        check(pair.length() == 2 && pair.getString(0).length == 64 && pair.getString(1).length == 96)
        JSONObject(deposit)
        JSONObject(exit)
        JSONObject(feeCall)
        fun digest(value: String): String = MessageDigest.getInstance("SHA-256")
            .digest(value.toByteArray(Charsets.UTF_8))
            .joinToString("") { "%02x".format(it) }
        return mapOf(
            "deposit" to deposit,
            "exit" to exit,
            "feeCall" to feeCall,
            "depositSha256" to digest(deposit),
            "exitSha256" to digest(exit),
            "feeCallSha256" to digest(feeCall),
        )
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
