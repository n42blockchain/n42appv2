package ai.n42.www.walletcore

import java.util.Base64
import org.junit.Assert.*
import org.junit.Test
import wallet.core.jni.proto.Sui

class SuiRawTransactionSignerTest {
    private val signer = SuiRawTransactionSigner
    private val publicKey = ByteArray(32) { 7 }
    private val signature = byteArrayOf(0) + ByteArray(64) { 3 } + publicKey
    private fun encode(bytes: ByteArray) = Base64.getEncoder().encodeToString(bytes)
    private fun output() = Sui.SigningOutput.newBuilder()
        .setUnsignedTx("AAECAw==").setSignature(encode(signature))

    @Test fun canonicalBytesArePreserved() {
        assertArrayEquals(byteArrayOf(0, 1, 2, 3), signer.decode("AAECAw=="))
        for (invalid in listOf(null, "", "!", "Zg", "Zh==", "AAECAw==\n", " AAECAw==")) {
            assertNull(signer.decode(invalid))
        }
    }

    @Test fun validatesSuccessfulOutputAgainstTransactionAndPublicKey() {
        assertTrue(signer.validOutput("AAECAw==", output().build(), publicKey))
        assertFalse(signer.validOutput("AAECAw==", output().setErrorValue(1).build(), publicKey))
        assertFalse(signer.validOutput("AAECAw==", output().setUnsignedTx("AAECBA==").build(), publicKey))
        assertFalse(signer.validOutput("AAECAw==", output().build(), ByteArray(32) { 9 }))
        assertFalse(signer.validOutput("AAECAw==", output().build(), ByteArray(31)))
    }

    @Test fun rejectsMalformedOrWrongSchemeSignatureEnvelopes() {
        for (size in listOf(0, 64, 96, 98)) {
            assertFalse(signer.validOutput("AAECAw==", output().setSignature(encode(signature.copyOf(size))).build(), publicKey))
        }
        val wrongScheme = signature.copyOf().also { it[0] = 1 }
        assertFalse(signer.validOutput("AAECAw==", output().setSignature(encode(wrongScheme)).build(), publicKey))
        assertFalse(signer.validOutput("AAECAw==", output().setSignature("invalid").build(), publicKey))
    }
}
