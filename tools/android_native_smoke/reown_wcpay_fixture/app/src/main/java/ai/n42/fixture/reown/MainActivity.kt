package ai.n42.fixture.reown

import android.app.Activity
import android.os.Bundle
import android.os.Process
import android.util.Log
import dalvik.system.BaseDexClassLoader
import java.io.File
import java.security.MessageDigest
import java.util.UUID
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import org.json.JSONArray
import org.json.JSONObject
import uniffi.yttrium_wcpay.PayJsonException
import uniffi.yttrium_wcpay.WalletConnectPayJson
import uniffi.yttrium_wcpay.uniffiEnsureInitialized

class MainActivity : Activity() {
    private val tag = "N42_REOWN_FIXTURE"
    private val config = """{"baseUrl":"http://127.0.0.1:9","sdkName":"fixture","sdkVersion":"0","sdkPlatform":"android","bundleId":"fixture","appId":"synthetic-only","clientId":"fixed-fixture"}"""
    private val missingAuth = """{"baseUrl":"http://127.0.0.1:9","sdkName":"fixture","sdkVersion":"0","sdkPlatform":"android","bundleId":"fixture","apiKey":null,"appId":null,"clientId":"fixed-fixture"}"""

    override fun onCreate(state: Bundle?) {
        super.onCreate(state)
        val record = JSONObject()
        val phase = intent.getStringExtra("phase")
        try {
            require(phase in setOf("baseline", "candidate", "mismatch")) { "Invalid phase" }
            record.put("phase", phase)
            record.put("pid", Process.myPid())
            record.put("nonce", UUID.randomUUID().toString())
            val apk = File(applicationInfo.sourceDir)
            record.put("apkPath", apk.path)
            record.put("apkSha256", sha256(apk))
            record.put("libraryLookupPath", (classLoader as BaseDexClassLoader).findLibrary("uniffi_yttrium_wcpay"))
            record.put("attemptedInitialization", true)
            if (phase == "mismatch") {
                try {
                    uniffiEnsureInitialized()
                    throw IllegalStateException("Mismatched binding was accepted")
                } catch (error: Throwable) {
                    val actual = rootCause(error)
                    record.put("mismatchError", actual.toString())
                    require(actual.message?.contains("UniFFI API checksum mismatch") == true) {
                        "Unexpected mismatch failure: $actual"
                    }
                }
            } else {
                uniffiEnsureInitialized()
                runBlocking {
                    withTimeout(5_000) {
                        expectError<PayJsonException.JsonParse>(record, "constructorJsonParse") {
                            WalletConnectPayJson("{").close()
                        }
                        expectError<PayJsonException.MissingAuth>(record, "missingAuth") {
                            WalletConnectPayJson(missingAuth).close()
                        }
                        WalletConnectPayJson(config).use { client ->
                            expectError<PayJsonException.JsonParse>(record, "optionsJsonParse") {
                                client.getPaymentOptions("{")
                            }
                            expectError<PayJsonException.JsonParse>(record, "actionsJsonParse") {
                                client.getRequiredPaymentActions("{")
                            }
                            expectError<PayJsonException.JsonParse>(record, "confirmJsonParse") {
                                client.confirmPayment("{")
                            }
                        }
                    }
                }
            }
            record.put("status", "PASS")
        } catch (error: Throwable) {
            record.put("status", "FAIL")
            record.put("error", rootCause(error).toString())
        } finally {
            record.put("executableApkMaps", apkMaps(applicationInfo.sourceDir))
            val text = record.toString()
            try {
                File(filesDir, "result.json").writeText(text)
            } catch (error: Exception) {
                Log.e(tag, "Failed to write fixture result", error)
            }
            Log.i(tag, text)
            finish()
        }
    }

    private suspend inline fun <reified E : Throwable> expectError(
        record: JSONObject,
        name: String,
        crossinline action: suspend () -> Unit,
    ) {
        try {
            action()
            throw IllegalStateException("$name unexpectedly succeeded")
        } catch (error: Throwable) {
            check(error is E) { "$name returned ${error.javaClass.name} instead of ${E::class.java.name}" }
            record.put(name, error.javaClass.name)
        }
    }

    private fun rootCause(error: Throwable): Throwable {
        var current = error
        while (current.cause != null && current.cause !== current) current = current.cause!!
        return current
    }

    private fun apkMaps(apk: String): JSONArray {
        val maps = JSONArray()
        File("/proc/self/maps").forEachLine { line ->
            if (line.contains(apk) && line.contains("r-xp")) maps.put(line)
        }
        return maps
    }

    private fun sha256(file: File): String {
        val digest = MessageDigest.getInstance("SHA-256")
        file.inputStream().use { input ->
            val buffer = ByteArray(64 * 1024)
            while (true) {
                val count = input.read(buffer)
                if (count < 0) break
                digest.update(buffer, 0, count)
            }
        }
        return digest.digest().joinToString("") { "%02x".format(it) }
    }
}
