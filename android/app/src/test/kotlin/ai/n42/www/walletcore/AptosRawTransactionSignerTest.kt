package ai.n42.www.walletcore

import org.junit.Assert.*
import org.junit.Test

class AptosRawTransactionSignerTest {
    @Test fun bindsNativeEnvelopeToAccountAndNetwork() {
        val sender = ByteArray(32) { 1 }
        for (chain in 1..2) {
            val raw = sender + ByteArray(34) + byteArrayOf(chain.toByte())
            assertTrue(AptosRawTransactionSigner.validEnvelope(raw, chain, sender))
            assertFalse(AptosRawTransactionSigner.validEnvelope(raw, 3 - chain, sender))
            assertFalse(AptosRawTransactionSigner.validEnvelope(raw, chain, ByteArray(32) { 2 }))
            assertFalse(AptosRawTransactionSigner.validEnvelope(raw, chain, ByteArray(31)))
            for (size in 0..66) assertFalse(AptosRawTransactionSigner.validEnvelope(raw.copyOf(size), chain, sender))
            assertFalse(AptosRawTransactionSigner.validEnvelope(ByteArray(65537), chain, sender))
        }
    }
}
