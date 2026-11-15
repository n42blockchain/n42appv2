package ai.n42.www.walletcore

import wallet.core.jni.proto.Sui

internal object SuiTransferParameters {
    fun uint64(value: Any?): ULong? {
        val text = when (value) {
            is String -> value
            is Byte, is Short, is Int, is Long -> value.toString()
            else -> return null
        }
        val parsed = text.toULongOrNull() ?: return null
        return if (parsed.toString() == text) parsed else null
    }

    fun address(value: Any?): String? {
        val text = value as? String ?: return null
        if (!Regex("^0x[0-9a-fA-F]{1,64}$").matches(text)) return null
        return "0x" + text.substring(2).lowercase().padStart(64, '0')
    }

    fun build(data: Map<String, Any>): Sui.SigningInput.Builder? {
        val price = uint64(data["referenceGasPrice"]) ?: return null
        val budget = uint64(data["gasBudget"]) ?: return null
        val amount = uint64(data["amount"]) ?: return null
        if (price == 0uL || budget == 0uL || amount == 0uL) return null
        val recipient = address(data["toAddress"]) ?: return null
        val coins = data["utxo"] as? List<*> ?: return null
        // SIP-58: optional withdrawal from the address balance, and a validity
        // window when gas is paid from that balance instead of a coin.
        val withdraw = if (data.containsKey("addressBalanceAmount")) {
            uint64(data["addressBalanceAmount"])?.takeIf { it > 0uL } ?: return null
        } else 0uL
        val window = if (data.containsKey("validDuring")) {
            validDuring(data["validDuring"]) ?: return null
        } else null
        if (withdraw.toBigInteger() + budget.toBigInteger() > ULong.MAX_VALUE.toBigInteger()) return null
        if (coins.isEmpty() && (window == null || withdraw != amount)) return null
        val ids = mutableSetOf<String>()
        val pay = Sui.PaySui.newBuilder().addAmounts(amount.toLong()).addRecipients(recipient)
        for (item in coins) {
            val coin = item as? Map<*, *> ?: return null
            val id = address(coin["objectId"]) ?: return null
            if (!ids.add(id)) return null
            val version = uint64(coin["version"]) ?: return null
            val digest = coin["objectDigest"] as? String ?: return null
            if (digest.isEmpty()) return null
            pay.addInputCoins(Sui.ObjectRef.newBuilder().setObjectId(id)
                .setVersion(version.toLong()).setObjectDigest(digest))
        }
        if (withdraw > 0uL) pay.setAddressBalanceAmount(withdraw.toLong())
        val input = Sui.SigningInput.newBuilder().setPaySui(pay)
            .setGasBudget(budget.toLong()).setReferenceGasPrice(price.toLong())
        if (window != null) input.setValidDuring(window)
        return input
    }

    private fun ULong.toBigInteger(): java.math.BigInteger = java.math.BigInteger(toString())

    /** Current epoch (or current and next), Base58 chain identifier, uint32 nonce. */
    fun validDuring(value: Any?): Sui.ValidDuring? {
        val window = value as? Map<*, *> ?: return null
        val min = uint64(window["minEpoch"]) ?: return null
        val max = uint64(window["maxEpoch"]) ?: return null
        if (max < min || max - min > 1uL) return null
        val chain = window["chain"] as? String ?: return null
        if (!Regex("^[1-9A-HJ-NP-Za-km-z]{32,44}$").matches(chain)) return null
        val nonce = uint64(window["nonce"]) ?: return null
        if (nonce > UInt.MAX_VALUE.toULong()) return null
        return Sui.ValidDuring.newBuilder().setMinEpoch(min.toLong()).setMaxEpoch(max.toLong())
            .setChain(chain).setNonce(nonce.toInt()).build()
    }
}
