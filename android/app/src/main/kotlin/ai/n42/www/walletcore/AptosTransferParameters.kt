package ai.n42.www.walletcore

import wallet.core.jni.proto.Aptos

/** Preserve unsigned integer values across Flutter's Int/Long codec boundary. */
internal object AptosTransferParameters {
    fun uint64(value: Any?): ULong? {
        val text = when (value) {
            is String -> value
            is Byte, is Short, is Int, is Long -> value.toString()
            else -> return null
        }
        val parsed = text.toULongOrNull() ?: return null
        return parsed.takeIf { it.toString() == text }
    }

    fun address(value: Any?): String? {
        val text = value as? String ?: return null
        if (!Regex("^0x[0-9a-fA-F]{1,64}$").matches(text)) return null
        return "0x" + text.substring(2).lowercase().padStart(64, '0')
    }

    fun build(data: Map<String, Any>): Aptos.SigningInput.Builder? {
        val price = uint64(data["gasUnitPrice"]) ?: return null
        val gas = uint64(data["maxGasAmount"]) ?: return null
        val expiry = uint64(data["expirationTimestampSecs"]) ?: return null
        val amount = uint64(data["amount"]) ?: return null
        val sequence = uint64(data["SequenceNumber"]) ?: return null
        val chain = uint64(data["chainId"]) ?: return null
        if (price == 0uL || gas == 0uL || expiry == 0uL || chain !in 1uL..255uL) return null
        val sender = address(data["fromAddress"]) ?: return null
        val recipient = address(data["toAddress"]) ?: return null
        val contract = data["contractAddress"] as? String ?: return null
        val input = Aptos.SigningInput.newBuilder().setChainId(chain.toInt())
            .setSender(sender).setSequenceNumber(sequence.toLong())
            .setGasUnitPrice(price.toLong()).setMaxGasAmount(gas.toLong())
            .setExpirationTimestampSecs(expiry.toLong())
        if (contract.isEmpty()) {
            input.transfer = Aptos.TransferMessage.newBuilder()
                .setAmount(amount.toLong()).setTo(recipient).build()
        } else {
            val account = address(contract) ?: return null
            val module = data["contractModule"] as? String ?: return null
            val name = data["contractName"] as? String ?: return null
            val identifier = Regex("^[A-Za-z_][A-Za-z0-9_]*$")
            if (!identifier.matches(module) || !identifier.matches(name)) return null
            input.tokenTransferCoins = Aptos.TokenTransferCoinsMessage.newBuilder()
                .setAmount(amount.toLong()).setTo(recipient)
                .setFunction(Aptos.StructTag.newBuilder().setAccountAddress(account)
                    .setModule(module).setName(name)).build()
        }
        return input
    }
}
