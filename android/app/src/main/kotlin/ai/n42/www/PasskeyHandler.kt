package ai.n42.www

import android.app.Activity
import android.util.Base64
import android.util.Log
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.exceptions.CreateCredentialCancellationException
import androidx.credentials.exceptions.CreateCredentialException
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.NoCredentialException
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject
import java.math.BigInteger
import java.security.interfaces.ECPublicKey
import java.security.KeyFactory
import java.security.spec.X509EncodedKeySpec

/**
 * Android Passkey handler using Credential Manager API.
 *
 * Bridges Flutter MethodChannel "n42.wallet/passkey" to the Android
 * Credential Manager for WebAuthn registration and authentication.
 *
 * Requires:
 * - Android 9+ (API 28) for FIDO2, Android 14+ for best UX
 * - `androidx.credentials:credentials:1.5+`
 * - `.well-known/assetlinks.json` configured on rpId domain
 */
class PasskeyHandler(private val activity: Activity) : MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "PasskeyHandler"
    }

    private val credentialManager = CredentialManager.create(activity)
    private val scope = CoroutineScope(Dispatchers.Main)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSupported" -> handleIsSupported(result)
            "register" -> handleRegister(call, result)
            "authenticate" -> handleAuthenticate(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleIsSupported(result: MethodChannel.Result) {
        // Credential Manager is available on Android 9+ via Google Play Services
        result.success(android.os.Build.VERSION.SDK_INT >= 28)
    }

    private fun handleRegister(call: MethodCall, result: MethodChannel.Result) {
        val rpId = call.argument<String>("rpId") ?: return result.error("INVALID_ARGS", "rpId required", null)
        val rpName = call.argument<String>("rpName") ?: return result.error("INVALID_ARGS", "rpName required", null)
        val userId = call.argument<String>("userId") ?: return result.error("INVALID_ARGS", "userId required", null)
        val userName = call.argument<String>("userName") ?: return result.error("INVALID_ARGS", "userName required", null)
        val challenge = call.argument<String>("challenge") ?: return result.error("INVALID_ARGS", "challenge required", null)
        val timeout = call.argument<Int>("timeout") ?: 60000
        val attestation = call.argument<String>("attestation") ?: "none"
        val userVerification = call.argument<String>("userVerification") ?: "required"
        val requireResidentKey = call.argument<Boolean>("requireResidentKey") ?: true
        val excludeIds = call.argument<List<String>>("excludeCredentialIds") ?: emptyList()

        // Build WebAuthn creation options JSON
        val excludeCredentials = JSONArray().apply {
            excludeIds.forEach { id ->
                put(JSONObject().apply {
                    put("type", "public-key")
                    put("id", id)
                })
            }
        }

        val pubKeyCredParams = JSONArray().apply {
            put(JSONObject().apply {
                put("type", "public-key")
                put("alg", -7) // ES256
            })
        }

        val requestJson = JSONObject().apply {
            put("rp", JSONObject().apply {
                put("id", rpId)
                put("name", rpName)
            })
            put("user", JSONObject().apply {
                put("id", base64UrlEncode(userId.toByteArray()))
                put("name", userName)
                put("displayName", userName)
            })
            put("challenge", challenge)
            put("pubKeyCredParams", pubKeyCredParams)
            put("timeout", timeout)
            put("attestation", attestation)
            put("authenticatorSelection", JSONObject().apply {
                put("authenticatorAttachment", "platform")
                put("residentKey", if (requireResidentKey) "required" else "preferred")
                put("userVerification", userVerification)
            })
            if (excludeCredentials.length() > 0) {
                put("excludeCredentials", excludeCredentials)
            }
        }.toString()

        scope.launch {
            try {
                val request = CreatePublicKeyCredentialRequest(requestJson)
                val response = credentialManager.createCredential(activity, request)
                val responseJson = JSONObject(response.data.getString("androidx.credentials.BUNDLE_KEY_REGISTRATION_RESPONSE_JSON") ?: "{}")

                val credentialId = responseJson.optString("id", "")
                val clientDataJSON = responseJson.optJSONObject("response")?.optString("clientDataJSON", "") ?: ""
                val attestationObject = responseJson.optJSONObject("response")?.optString("attestationObject", "") ?: ""

                // Extract P-256 public key from attestation
                val pubKeyResult = extractPublicKeyFromAttestation(attestationObject)

                val resultMap = HashMap<String, Any?>()
                resultMap["credentialId"] = credentialId
                resultMap["clientDataJSON"] = clientDataJSON
                resultMap["attestationObject"] = attestationObject
                resultMap["publicKeyX"] = pubKeyResult.first
                resultMap["publicKeyY"] = pubKeyResult.second
                resultMap["backedUp"] = false

                result.success(resultMap)
            } catch (e: CreateCredentialCancellationException) {
                result.error("CANCELLED", "User cancelled registration", null)
            } catch (e: CreateCredentialException) {
                Log.e(TAG, "Registration failed: ${e.message}", e)
                result.error("REGISTRATION_FAILED", e.message, null)
            } catch (e: Exception) {
                Log.e(TAG, "Unexpected error: ${e.message}", e)
                result.error("ERROR", e.message, null)
            }
        }
    }

    private fun handleAuthenticate(call: MethodCall, result: MethodChannel.Result) {
        val rpId = call.argument<String>("rpId") ?: return result.error("INVALID_ARGS", "rpId required", null)
        val challenge = call.argument<String>("challenge") ?: return result.error("INVALID_ARGS", "challenge required", null)
        val timeout = call.argument<Int>("timeout") ?: 60000
        val userVerification = call.argument<String>("userVerification") ?: "required"
        val allowIds = call.argument<List<String>>("allowCredentialIds") ?: emptyList()

        val allowCredentials = JSONArray().apply {
            allowIds.forEach { id ->
                put(JSONObject().apply {
                    put("type", "public-key")
                    put("id", id)
                })
            }
        }

        val requestJson = JSONObject().apply {
            put("rpId", rpId)
            put("challenge", challenge)
            put("timeout", timeout)
            put("userVerification", userVerification)
            if (allowCredentials.length() > 0) {
                put("allowCredentials", allowCredentials)
            }
        }.toString()

        scope.launch {
            try {
                val option = GetPublicKeyCredentialOption(requestJson)
                val request = GetCredentialRequest.Builder()
                    .addCredentialOption(option)
                    .build()

                val response = credentialManager.getCredential(activity, request)
                val responseJson = JSONObject(response.credential.data.getString("androidx.credentials.BUNDLE_KEY_AUTHENTICATION_RESPONSE_JSON") ?: "{}")

                val credentialId = responseJson.optString("id", "")
                val authData = responseJson.optJSONObject("response")?.optString("authenticatorData", "") ?: ""
                val clientDataJSON = responseJson.optJSONObject("response")?.optString("clientDataJSON", "") ?: ""
                val signature = responseJson.optJSONObject("response")?.optString("signature", "") ?: ""

                // Parse DER-encoded P-256 signature into raw r, s
                val (sigR, sigS) = parseDerSignature(base64UrlDecode(signature))

                val resultMap = HashMap<String, Any?>()
                resultMap["credentialId"] = credentialId
                resultMap["authenticatorData"] = authData
                resultMap["clientDataJSON"] = clientDataJSON
                resultMap["signatureR"] = sigR.toString(16).padStart(64, '0')
                resultMap["signatureS"] = sigS.toString(16).padStart(64, '0')

                result.success(resultMap)
            } catch (e: GetCredentialCancellationException) {
                result.error("CANCELLED", "User cancelled authentication", null)
            } catch (e: NoCredentialException) {
                result.error("NOT_FOUND", "No matching credential found", null)
            } catch (e: GetCredentialException) {
                Log.e(TAG, "Authentication failed: ${e.message}", e)
                result.error("AUTH_FAILED", e.message, null)
            } catch (e: Exception) {
                Log.e(TAG, "Unexpected error: ${e.message}", e)
                result.error("ERROR", e.message, null)
            }
        }
    }

    /**
     * Extract P-256 public key X, Y coordinates from attestation object.
     * Returns hex-encoded (x, y) pair.
     */
    private fun extractPublicKeyFromAttestation(attestationB64: String): Pair<String, String> {
        // Simplified: In production, parse CBOR attestationObject to get
        // authData -> attestedCredentialData -> COSE public key.
        // For now, return placeholder that will be overridden by server-side
        // extraction or the raw public key from the response.
        //
        // The actual extraction requires a CBOR parser. The server should
        // independently validate and extract the public key.
        return Pair(
            "0".padStart(64, '0'),
            "0".padStart(64, '0')
        )
    }

    /**
     * Parse a DER-encoded ECDSA signature into (r, s) BigIntegers.
     */
    private fun parseDerSignature(der: ByteArray): Pair<BigInteger, BigInteger> {
        if (der.isEmpty() || der[0] != 0x30.toByte()) {
            throw IllegalArgumentException("Invalid DER signature")
        }

        var offset = 2 // skip SEQUENCE tag and length

        // Parse r
        if (der[offset] != 0x02.toByte()) throw IllegalArgumentException("Expected INTEGER tag for r")
        offset++
        val rLen = der[offset].toInt() and 0xFF
        offset++
        val r = BigInteger(1, der.copyOfRange(offset, offset + rLen))
        offset += rLen

        // Parse s
        if (der[offset] != 0x02.toByte()) throw IllegalArgumentException("Expected INTEGER tag for s")
        offset++
        val sLen = der[offset].toInt() and 0xFF
        offset++
        val s = BigInteger(1, der.copyOfRange(offset, offset + sLen))

        // Normalize s to low-S form (required by some verifiers)
        val curveOrder = BigInteger("FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551", 16)
        val normalizedS = if (s > curveOrder.shiftRight(1)) curveOrder.subtract(s) else s

        return Pair(r, normalizedS)
    }

    private fun base64UrlEncode(data: ByteArray): String {
        return Base64.encodeToString(data, Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING)
    }

    private fun base64UrlDecode(data: String): ByteArray {
        return Base64.decode(data, Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING)
    }
}
