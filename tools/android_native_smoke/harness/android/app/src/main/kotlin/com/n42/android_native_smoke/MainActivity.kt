package com.n42.android_native_smoke

import com.hiennv.flutter_callkit_incoming.getDataActiveCalls
import com.hiennv.flutter_callkit_incoming.removeAllCalls
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.math.BigInteger
import org.bouncycastle.jce.provider.BouncyCastleProvider
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
        check(Numeric.toHexString(seed).startsWith("0xc55257c360c07c72029aebc1b53c05ed")) { "BIP39 seed" }
        val master = Bip32ECKeyPair.generateKeyPair(seed)
        val derived = Bip32ECKeyPair.deriveKeyPair(
            master,
            intArrayOf(44 or Bip32ECKeyPair.HARDENED_BIT,
                60 or Bip32ECKeyPair.HARDENED_BIT,
                Bip32ECKeyPair.HARDENED_BIT, 0, 0),
        )
        check(derived.privateKey > BigInteger.ZERO) { "BIP32 private key" }
        check(derived.publicKey == Sign.publicKeyFromPrivate(derived.privateKey)) { "BIP32 public key" }

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
}
