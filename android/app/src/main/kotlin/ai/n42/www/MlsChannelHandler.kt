package ai.n42.www

import android.content.Context
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer
import java.nio.charset.StandardCharsets

internal class MlsChannelHandler(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        private const val CHANNEL_NAME = "n42.chat/mls"
        private const val OK = 0

        fun register(flutterEngine: FlutterEngine, context: Context) {
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL_NAME,
            ).setMethodCallHandler(MlsChannelHandler(context.applicationContext))
        }
    }

    private val lock = Any()
    private var engineHandle: Long = 0

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "isBound" -> result.success(ensureEngine() != 0L)
                "generateKeyPackage" -> {
                    val bytes = MlsNativeBridge.nativeGenerateKeyPackage(requiredEngine())
                        ?: run {
                            result.mlsError("generateKeyPackage failed")
                            return
                        }
                    result.success(bytes)
                }
                "createGroup" -> {
                    val groupId = requiredStringArg(call, "groupId")
                    val status = MlsNativeBridge.nativeCreateGroup(
                        requiredEngine(),
                        groupId.toUtf8Bytes(),
                    )
                    if (status == OK) {
                        result.success(ByteArray(0))
                    } else {
                        result.mlsStatusError("createGroup", status)
                    }
                }
                "addMembers", "addMember" -> handleAddMembers(call, result)
                "removeMembers", "removeMember" -> handleRemoveMembers(call, result)
                "processCommit" -> {
                    val groupId = requiredStringArg(call, "groupId")
                    val commit = requiredBytesArg(call, "commit")
                    val status = MlsNativeBridge.nativeProcessCommit(
                        requiredEngine(),
                        groupId.toUtf8Bytes(),
                        commit,
                    )
                    if (status == OK) {
                        result.success(null)
                    } else {
                        result.mlsStatusError("processCommit", status)
                    }
                }
                "processWelcome" -> {
                    val welcome = requiredBytesArg(call, "welcome")
                    val groupIdBytes = MlsNativeBridge.nativeProcessWelcome(
                        requiredEngine(),
                        welcome,
                    ) ?: run {
                        result.mlsError("processWelcome failed")
                        return
                    }
                    result.success(
                        mapOf(
                            "groupId" to String(groupIdBytes, StandardCharsets.UTF_8),
                            "state" to ByteArray(0),
                        ),
                    )
                }
                "encrypt" -> {
                    val groupId = requiredStringArg(call, "groupId")
                    val plaintext = requiredBytesArg(call, "plaintext")
                    val bytes = MlsNativeBridge.nativeEncrypt(
                        requiredEngine(),
                        groupId.toUtf8Bytes(),
                        plaintext,
                    ) ?: run {
                        result.mlsError("encrypt failed")
                        return
                    }
                    result.success(bytes)
                }
                "decrypt" -> {
                    val groupId = requiredStringArg(call, "groupId")
                    val ciphertext = requiredBytesArg(call, "ciphertext")
                    val bytes = MlsNativeBridge.nativeDecrypt(
                        requiredEngine(),
                        groupId.toUtf8Bytes(),
                        ciphertext,
                    ) ?: run {
                        result.mlsError("decrypt failed")
                        return
                    }
                    result.success(bytes)
                }
                "selfUpdate" -> {
                    val groupId = requiredStringArg(call, "groupId")
                    val bytes = MlsNativeBridge.nativeSelfUpdate(
                        requiredEngine(),
                        groupId.toUtf8Bytes(),
                    ) ?: run {
                        result.mlsError("selfUpdate failed")
                        return
                    }
                    result.success(bytes)
                }
                else -> result.notImplemented()
            }
        } catch (e: IllegalArgumentException) {
            result.error("INVALID_ARGS", e.message, null)
        } catch (e: IllegalStateException) {
            result.error("MLS_UNAVAILABLE", e.message, null)
        }
    }

    private fun handleAddMembers(call: MethodCall, result: MethodChannel.Result) {
        val groupId = requiredStringArg(call, "groupId")
        val keyPackage = firstKeyPackage(call)
        val packed = MlsNativeBridge.nativeAddMember(
            requiredEngine(),
            groupId.toUtf8Bytes(),
            keyPackage,
        ) ?: run {
            result.mlsError("addMembers failed")
            return
        }
        val pair = unpackPair(packed) ?: run {
            result.mlsError("addMembers returned bad payload")
            return
        }
        result.success(
            mapOf(
                "commit" to pair.first,
                "welcome" to pair.second,
            ),
        )
    }

    private fun handleRemoveMembers(call: MethodCall, result: MethodChannel.Result) {
        val groupId = requiredStringArg(call, "groupId")
        val leafIndex = firstLeafIndex(call)
        val bytes = MlsNativeBridge.nativeRemoveMember(
            requiredEngine(),
            groupId.toUtf8Bytes(),
            leafIndex,
        ) ?: run {
            result.mlsError("removeMembers failed")
            return
        }
        result.success(bytes)
    }

    private fun ensureEngine(): Long {
        if (!MlsNativeBridge.isLoaded) return 0
        synchronized(lock) {
            if (engineHandle != 0L) return engineHandle
            val identity = defaultIdentity().toUtf8Bytes()
            engineHandle = MlsNativeBridge.nativeCreateEngine(identity)
            return engineHandle
        }
    }

    private fun requiredEngine(): Long {
        val handle = ensureEngine()
        if (handle == 0L) {
            throw IllegalStateException(
                MlsNativeBridge.errorMessage ?: "OpenMLS native library is unavailable",
            )
        }
        return handle
    }

    private fun defaultIdentity(): String {
        val androidId = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ANDROID_ID,
        )?.takeIf { it.isNotBlank() }
        return "android:${androidId ?: context.packageName}"
    }

    private fun requiredArgs(call: MethodCall): Map<*, *> =
        call.arguments as? Map<*, *>
            ?: throw IllegalArgumentException("${call.method} expects map arguments")

    private fun requiredStringArg(call: MethodCall, key: String): String =
        requiredArgs(call)[key] as? String
            ?: throw IllegalArgumentException("$key is required")

    private fun requiredBytesArg(call: MethodCall, key: String): ByteArray =
        requiredArgs(call)[key] as? ByteArray
            ?: throw IllegalArgumentException("$key is required")

    private fun firstKeyPackage(call: MethodCall): ByteArray {
        val args = requiredArgs(call)
        (args["keyPackage"] as? ByteArray)?.let { return it }
        val packages = args["keyPackages"] as? List<*>
            ?: throw IllegalArgumentException("keyPackages is required")
        if (packages.size != 1) {
            throw IllegalArgumentException(
                "current OpenMLS mobile ABI supports exactly one key package per addMembers call",
            )
        }
        return packages.firstOrNull() as? ByteArray
            ?: throw IllegalArgumentException("keyPackages[0] is required")
    }

    private fun firstLeafIndex(call: MethodCall): Int {
        val args = requiredArgs(call)
        args["memberId"]?.let { return parseLeafIndex(it) }
        val members = args["memberIds"] as? List<*>
            ?: throw IllegalArgumentException("memberIds is required")
        if (members.size != 1) {
            throw IllegalArgumentException(
                "current OpenMLS mobile ABI supports exactly one member removal per call",
            )
        }
        return parseLeafIndex(members.first())
    }

    private fun parseLeafIndex(value: Any?): Int {
        val parsed = when (value) {
            is Int -> value
            is Long -> value.toInt()
            is String -> value.toIntOrNull()
            else -> null
        } ?: throw IllegalArgumentException("member id must be a numeric leaf index")
        require(parsed >= 0) { "member id must be a non-negative leaf index" }
        return parsed
    }

    private fun unpackPair(packed: ByteArray): Pair<ByteArray, ByteArray>? {
        if (packed.size < 4) return null
        val commitLen = ByteBuffer.wrap(packed, 0, 4).int
        if (commitLen < 0 || 4 + commitLen > packed.size) return null
        val commit = packed.copyOfRange(4, 4 + commitLen)
        val welcome = packed.copyOfRange(4 + commitLen, packed.size)
        return commit to welcome
    }

    private fun String.toUtf8Bytes(): ByteArray = toByteArray(StandardCharsets.UTF_8)

    private fun MethodChannel.Result.mlsError(message: String) {
        error("MLS_ERROR", message, null)
    }

    private fun MethodChannel.Result.mlsStatusError(operation: String, status: Int) {
        error("MLS_ERROR", "$operation failed with status $status", status)
    }
}
