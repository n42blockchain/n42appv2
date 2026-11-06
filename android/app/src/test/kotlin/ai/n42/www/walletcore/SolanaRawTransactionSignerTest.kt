package ai.n42.www.walletcore

import org.junit.Assert.*
import org.junit.Test
import wallet.core.jni.proto.Solana

class SolanaRawTransactionSignerTest {
    private val signer = SolanaRawTransactionSigner
    private fun wire() = byteArrayOf(2) + ByteArray(128) + byteArrayOf(2, 0, 1, 3, 9)
    private fun raw(v0: Boolean, required: Int = 2, readonly: Int = 0,
                    program: Int = 2, account: Int = 1, keys: List<String> = listOf("a", "b", "program")): Solana.RawMessage {
        val header = Solana.RawMessage.MessageHeader.newBuilder()
            .setNumRequiredSignatures(required).setNumReadonlySignedAccounts(readonly)
            .setNumReadonlyUnsignedAccounts(1).build()
        val instruction = Solana.RawMessage.Instruction.newBuilder()
            .setProgramId(program).addAccounts(account).build()
        val builder = Solana.RawMessage.newBuilder()
        if (v0) builder.v0 = Solana.RawMessage.MessageV0.newBuilder()
            .setHeader(header).addAllAccountKeys(keys).addInstructions(instruction)
            .addAddressTableLookups(Solana.RawMessage.MessageAddressTableLookup.newBuilder()
                .addWritableIndexes(0)).build()
        else builder.legacy = Solana.RawMessage.MessageLegacy.newBuilder()
            .setHeader(header).addAllAccountKeys(keys).addInstructions(instruction).build()
        return builder.build()
    }

    @Test fun rejectsTruncatedAndNonCanonicalEnvelopes() {
        for (size in 0..129) assertNull(signer.envelope(wire().copyOf(size)))
        assertNull(signer.envelope(byteArrayOf(0) + ByteArray(100)))
        assertNull(signer.envelope(byteArrayOf(0x82.toByte(), 0) + wire().drop(1)))
        assertNull(signer.envelope(byteArrayOf(0xff.toByte(), 0xff.toByte(), 4) + ByteArray(100)))
        assertEquals(SolanaRawTransactionSigner.Envelope(2, 1, 129), signer.envelope(wire()))
    }

    @Test fun selectsOnlyOneRequiredSignerForLegacyAndV0() {
        val envelope = signer.envelope(wire())!!
        for (v0 in listOf(false, true)) {
            assertEquals(0, signer.signerSlot(raw(v0), envelope, "a"))
            assertEquals(1, signer.signerSlot(raw(v0), envelope, "b"))
            assertNull(signer.signerSlot(raw(v0), envelope, "program"))
            assertNull(signer.signerSlot(raw(v0), envelope, "other"))
            assertNull(signer.signerSlot(raw(v0, keys = listOf("a", "a", "program")), envelope, "a"))
        }
    }

    @Test fun rejectsInvalidHeadersAndInstructionIndexes() {
        val envelope = signer.envelope(wire())!!
        for (v0 in listOf(false, true)) {
            for (raw in listOf(raw(v0, required = 3), raw(v0, readonly = 2),
                    raw(v0, program = -1), raw(v0, program = 3), raw(v0, account = -1),
                    raw(v0, account = 255))) assertNull(signer.signerSlot(raw, envelope, "a"))
        }
        assertNull(signer.signerSlot(Solana.RawMessage.getDefaultInstance(), envelope, "a"))
        assertNull(signer.signerSlot(raw(false, account = 3), envelope, "a"))
        assertEquals(0, signer.signerSlot(raw(true, account = 3), envelope, "a"))
    }

    @Test fun outputCanChangeOnlyOwnSignature() {
        val input = wire()
        for (slot in 0..1) {
            val output = input.copyOf()
            output[1 + slot * 64] = 7
            assertTrue(signer.preservesMessageAndCosignatures(input, output, slot))
            output[1 + (1 - slot) * 64] = 9
            assertFalse(signer.preservesMessageAndCosignatures(input, output, slot))
        }
        val changed = input.copyOf().also { it[it.lastIndex] = 8 }
        assertFalse(signer.preservesMessageAndCosignatures(input, changed, 0))
        assertFalse(signer.preservesMessageAndCosignatures(input, input + byteArrayOf(0), 0))
        assertFalse(signer.preservesMessageAndCosignatures(input, byteArrayOf(), 0))
        assertFalse(signer.preservesMessageAndCosignatures(input, input, 2))
    }
}
