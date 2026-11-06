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
        if (coins.isEmpty()) return null
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
        return Sui.SigningInput.newBuilder().setPaySui(pay)
            .setGasBudget(budget.toLong()).setReferenceGasPrice(price.toLong())
    }
}
