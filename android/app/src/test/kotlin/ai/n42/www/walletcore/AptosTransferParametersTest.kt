package ai.n42.www.walletcore

import org.junit.Assert.*
import org.junit.Test

class AptosTransferParametersTest {
    private fun transfer() = mutableMapOf<String, Any>(
        "gasUnitPrice" to 100, "maxGasAmount" to 10000,
        "expirationTimestampSecs" to 2000000000, "amount" to 1,
        "SequenceNumber" to 0, "chainId" to 1,
        "fromAddress" to "0x1", "toAddress" to "0x2", "contractAddress" to "")

    @Test fun acceptsCodecIntegersAndPreservesUnsignedBits() {
        val input = AptosTransferParameters.build(transfer())!!.build()
        assertEquals(1L, input.transfer.amount)
        assertEquals(0L, input.sequenceNumber)
        assertEquals(100L, input.gasUnitPrice)
        val max = AptosTransferParameters.build(transfer().also {
            it["amount"] = "18446744073709551615"
            it["SequenceNumber"] = 9007199254740993L
        })!!.build()
        assertEquals(-1L, max.transfer.amount)
        assertEquals(9007199254740993L, max.sequenceNumber)
    }

    @Test fun rejectsLossyAndInvalidFields() {
        for (field in listOf("amount", "gasUnitPrice", "maxGasAmount", "expirationTimestampSecs", "SequenceNumber", "chainId")) {
            for (bad in listOf(-1, "18446744073709551616", "01", 1.5, true)) {
                assertNull(AptosTransferParameters.build(transfer().also { it[field] = bad }))
            }
        }
        for (chain in listOf(0, 256)) assertNull(AptosTransferParameters.build(transfer().also { it["chainId"] = chain }))
        for (field in listOf("gasUnitPrice", "maxGasAmount", "expirationTimestampSecs")) {
            assertNull(AptosTransferParameters.build(transfer().also { it[field] = 0 }))
        }
    }

    @Test fun retainsTokenTransfersAndRejectsIncompleteIdentity() {
        val token = transfer().also {
            it["contractAddress"] = "0x1"; it["contractModule"] = "coin"; it["contractName"] = "Token"
        }
        assertEquals("Token", AptosTransferParameters.build(token)!!.build().tokenTransferCoins.function.name)
        for (field in listOf("contractModule", "contractName", "fromAddress", "toAddress")) {
            assertNull(AptosTransferParameters.build(token.toMutableMap().also { it[field] = "" }))
        }
    }
}
