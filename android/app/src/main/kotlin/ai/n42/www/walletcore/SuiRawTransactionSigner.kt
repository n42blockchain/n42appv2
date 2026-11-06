package ai.n42.www.walletcore

import com.google.protobuf.ByteString
import java.util.Base64
import wallet.core.java.AnySigner
import wallet.core.jni.CoinType
import wallet.core.jni.PrivateKey
import wallet.core.jni.proto.Sui

/** Signs the original transaction bytes with WalletCore's Sui transaction intent. */
internal object SuiRawTransactionSigner {
    fun decode(encoded: String?): ByteArray? {
        if (encoded.isNullOrEmpty()) return null
        return try {
            val raw = Base64.getDecoder().decode(encoded)
            if (raw.isEmpty() || Base64.getEncoder().encodeToString(raw) != encoded) null else raw
        } catch (_: IllegalArgumentException) { null }
    }

    fun validOutput(encoded: String, output: Sui.SigningOutput, publicKey: ByteArray): Boolean {
        val signature = decode(output.signature) ?: return false
        return output.errorValue == 0 && output.unsignedTx == encoded &&
            signature.size == 97 && signature[0] == 0.toByte() && publicKey.size == 32 &&
            signature.copyOfRange(65, 97).contentEquals(publicKey)
    }

    fun sign(encoded: String?, key: PrivateKey): String? {
        decode(encoded) ?: return null
        val input = Sui.SigningInput.newBuilder()
            .setPrivateKey(ByteString.copyFrom(key.data()))
            .setSignDirectMessage(Sui.SignDirect.newBuilder().setUnsignedTxMsg(encoded))
            .build()
        val output = AnySigner.sign(input, CoinType.SUI, Sui.SigningOutput.parser())
        return if (validOutput(encoded!!, output, key.getPublicKeyEd25519().data())) output.signature else null
    }
}
