package ai.n42.www.walletcore

import com.google.protobuf.ByteString
import java.util.Base64
import wallet.core.java.AnySigner
import wallet.core.jni.CoinType
import wallet.core.jni.PrivateKey
import wallet.core.jni.TransactionDecoder
import wallet.core.jni.proto.Solana

/** Signs the original message without refreshing its blockhash or rebuilding a transfer. */
internal object SolanaRawTransactionSigner {
    data class Envelope(val count: Int, val prefix: Int, val offset: Int)

    fun envelope(data: ByteArray): Envelope? {
        var count = 0
        for (index in 0..2) {
            if (index >= data.size) return null
            val byte = data[index].toInt() and 255
            if (index == 2 && byte > 3) return null
            count = count or ((byte and 127) shl (index * 7))
            if (byte and 128 == 0) {
                if (count !in 1..255 || (index > 0 && byte == 0)) return null
                val prefix = index + 1
                val offset = prefix + count * 64
                return if (offset < data.size) Envelope(count, prefix, offset) else null
            }
        }
        return null
    }

    fun signerSlot(raw: Solana.RawMessage, envelope: Envelope, address: String): Int? {
        val header: Solana.RawMessage.MessageHeader
        val keys: List<String>
        val instructions: List<Solana.RawMessage.Instruction>
        val loaded: Long
        when (raw.messageCase) {
            Solana.RawMessage.MessageCase.LEGACY -> {
                header = raw.legacy.header
                keys = raw.legacy.accountKeysList
                instructions = raw.legacy.instructionsList
                loaded = 0
            }
            Solana.RawMessage.MessageCase.V0 -> {
                header = raw.v0.header
                keys = raw.v0.accountKeysList
                instructions = raw.v0.instructionsList
                loaded = raw.v0.addressTableLookupsList.sumOf {
                    it.writableIndexesCount.toLong() + it.readonlyIndexesCount
                }
            }
            else -> return null
        }
        val required = header.numRequiredSignatures
        val total = keys.size.toLong() + loaded
        if (required != envelope.count || required !in 1..keys.size || total > 256 ||
            header.numReadonlySignedAccounts !in 0 until required ||
            header.numReadonlyUnsignedAccounts !in 0..(keys.size - required) ||
            instructions.any { instruction ->
                instruction.programId !in keys.indices ||
                    instruction.accountsList.any { it < 0 || it.toLong() >= total }
            }) return null
        val slots = keys.take(required).indices.filter { keys[it] == address }
        return slots.singleOrNull()
    }

    fun preservesMessageAndCosignatures(original: ByteArray, output: ByteArray, slot: Int): Boolean {
        val before = envelope(original) ?: return false
        val after = envelope(output) ?: return false
        if (before != after || slot !in 0 until before.count ||
            !original.copyOfRange(before.offset, original.size)
                .contentEquals(output.copyOfRange(after.offset, output.size))) return false
        for (index in 0 until before.count) {
            if (index == slot) continue
            val start = before.prefix + index * 64
            if (!original.copyOfRange(start, start + 64)
                    .contentEquals(output.copyOfRange(start, start + 64))) return false
        }
        return true
    }

    fun sign(encoded: String, privateKey: PrivateKey): String? {
        if (encoded.length > 90_000) return null
        return try {
            val original = Base64.getDecoder().decode(encoded)
            if (original.size > 65_536) return null
            val envelope = envelope(original) ?: return null
            val decoded = Solana.DecodingTransactionOutput.parseFrom(
                TransactionDecoder.decode(CoinType.SOLANA, original))
            if (decoded.errorValue != 0 || !decoded.hasTransaction()) return null
            val raw = decoded.transaction
            val slot = signerSlot(raw, envelope, CoinType.SOLANA.deriveAddress(privateKey)) ?: return null
            val input = Solana.SigningInput.newBuilder()
                .setPrivateKey(ByteString.copyFrom(privateKey.data()))
                .setRawMessage(raw)
                .setTxEncoding(Solana.Encoding.Base64)
                .build()
            val signed = AnySigner.sign(input, CoinType.SOLANA, Solana.SigningOutput.parser())
            if (signed.errorValue != 0) return null
            val output = Base64.getDecoder().decode(signed.encoded)
            if (!preservesMessageAndCosignatures(original, output, slot)) return null
            val start = envelope.prefix + slot * 64
            if (!privateKey.getPublicKeyEd25519().verify(
                    output.copyOfRange(start, start + 64),
                    original.copyOfRange(envelope.offset, original.size))) return null
            Base64.getEncoder().encodeToString(output)
        } catch (_: Exception) {
            null
        }
    }
}
