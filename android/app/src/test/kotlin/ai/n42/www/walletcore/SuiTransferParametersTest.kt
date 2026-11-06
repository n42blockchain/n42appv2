package ai.n42.www.walletcore

import org.junit.Assert.*
import org.junit.Test

class SuiTransferParametersTest {
    private fun coin(id: String = "0x3") = mapOf<String, Any>(
        "objectId" to id, "version" to "18446744073709551615", "objectDigest" to "11111111111111111111111111111111")
    private fun transfer() = mutableMapOf<String, Any>(
        "amount" to "9007199254740993", "gasBudget" to "2000000",
        "referenceGasPrice" to "1000", "toAddress" to "0x2", "utxo" to listOf(coin()))

    @Test fun preservesExactAmountsAndUnsignedVersionBits() {
        val input = SuiTransferParameters.build(transfer())!!.build()
        assertEquals(9007199254740993L, input.paySui.getAmounts(0))
        assertEquals(-1L, input.paySui.getInputCoins(0).version)
        assertEquals(2000000L, input.gasBudget)
        assertEquals(1000L, input.referenceGasPrice)
        assertEquals("0x" + "0".repeat(63) + "2", input.paySui.getRecipients(0))
    }
    @Test fun rejectsInvalidUnsignedFields() {
        for (field in listOf("amount", "gasBudget", "referenceGasPrice")) {
            for (bad in listOf("0", "-1", "01", "18446744073709551616", 1.5, true)) {
                assertNull(SuiTransferParameters.build(transfer().also { it[field] = bad }))
            }
        }
        assertEquals(ULong.MAX_VALUE, SuiTransferParameters.uint64("18446744073709551615"))
    }
    @Test fun requiresUniqueCompleteCoinReferences() {
        for (coins in listOf(emptyList(), listOf(coin(), coin("0x03")), listOf(mapOf("objectId" to "0x3")))) {
            assertNull(SuiTransferParameters.build(transfer().also { it["utxo"] = coins }))
        }
        assertNull(SuiTransferParameters.build(transfer().also { it["toAddress"] = "bad" }))
    }
}
