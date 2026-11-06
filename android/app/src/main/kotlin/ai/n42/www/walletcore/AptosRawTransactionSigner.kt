package ai.n42.www.walletcore

import wallet.core.jni.Curve
import wallet.core.jni.Hash
import wallet.core.jni.PrivateKey

/** Complete BCS validation is performed by the host before this signing boundary. */
internal object AptosRawTransactionSigner {
    fun validEnvelope(raw: ByteArray, chain: Int, authenticationKey: ByteArray): Boolean =
        raw.size in 67..65536 && chain in 1..2 &&
            (raw.last().toInt() and 255) == chain && authenticationKey.size == 32 &&
            raw.copyOfRange(0, 32).contentEquals(authenticationKey)

    fun sign(raw: ByteArray, chain: Int, key: PrivateKey): ByteArray? {
        val original = raw.copyOf()
        val publicKey = key.getPublicKeyEd25519()
        val publicBytes = publicKey.data()
        if (publicBytes.size != 32 || !validEnvelope(original, chain,
                Hash.sha3256(publicBytes + byteArrayOf(0)))) return null
        val message = Hash.sha3256("APTOS::RawTransaction".toByteArray(Charsets.UTF_8)) + original
        val signature = key.sign(message, Curve.ED25519)
        if (signature.size != 64 || !publicKey.verify(signature, message)) return null
        return original + byteArrayOf(0, 32) + publicBytes + byteArrayOf(64) + signature
    }
}
