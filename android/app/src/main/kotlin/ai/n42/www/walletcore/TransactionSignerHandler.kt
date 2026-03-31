package ai.n42.www.walletcore

import android.util.Base64 as aBase64
import com.google.protobuf.ByteString
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import wallet.core.java.AnySigner
import wallet.core.jni.BitcoinAddress
import wallet.core.jni.BitcoinScript
import wallet.core.jni.BitcoinSigHashType
import wallet.core.jni.CoinType
import wallet.core.jni.DataVector
import wallet.core.jni.HDWallet
import wallet.core.jni.PrivateKey
import wallet.core.jni.SolanaAddress
import wallet.core.jni.TransactionCompiler
import wallet.core.jni.proto.Algorand
import wallet.core.jni.proto.Aptos
import wallet.core.jni.proto.Bitcoin
import wallet.core.jni.proto.BitcoinV2
import wallet.core.jni.proto.Cosmos
import wallet.core.jni.proto.Ethereum
import wallet.core.jni.proto.Filecoin
import wallet.core.jni.proto.Polkadot
import wallet.core.jni.proto.Ripple
import wallet.core.jni.proto.Solana
import wallet.core.jni.proto.Stellar
import wallet.core.jni.proto.Sui
import wallet.core.jni.proto.Tezos
import wallet.core.jni.proto.TheOpenNetwork
import wallet.core.jni.proto.Tron
import wallet.core.jni.proto.Utxo
import wallet.core.jni.proto.VeChain
import wallet.core.jni.proto.NEAR
import wallet.core.jni.proto.Zilliqa
import wallet.core.jni.proto.Theta
import wallet.core.jni.proto.Cardano
import wallet.core.jni.proto.MultiversX
import ai.n42.www.Numeric
import evmsdk.Evmsdk
import java.math.BigInteger

/**
 * Handles all transaction signing and message signing operations.
 */
class TransactionSignerHandler(private val keyHandler: KeyManagementHandler) {

    fun handleSignTransaction(call: MethodCall, result: MethodChannel.Result) {
        val coin: String? = call.argument("coin")
        val path: String? = call.argument("path")
        val mnemonic: String? = call.argument("mnemonic")
        val passphrase: String? = call.argument("passphrase")
        val txData: Map<String, Any>? = call.argument("txData")
        val pkStr: String? = call.argument("pk")
        if (txData != null && path != null && coin != null && mnemonic != null && pkStr != null) {
            if (mnemonic != "") {
                val wallet = HDWallet(mnemonic, passphrase)
                val txHash: String? = signTransaction(wallet, coin, path, txData, null)
                if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
            } else if (pkStr != "") {
                val pk: ByteArray = aBase64.decode(pkStr, 64)

                val privateKey: PrivateKey? = keyHandler.getPrivateKeyFromBytes(pk)
                if (privateKey == null) {
                    result.error("privateKey", "failed to privateKey", null)
                } else {
                    val txHash: String? = signTransaction(null, coin, path, txData, privateKey)
                    if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
                }

            } else {
                result.error("no_wallet",
                    "Could not generate wallet, why?", null)
            }
        } else {
            result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
        }
    }

    fun handleSignTransactionG(call: MethodCall, result: MethodChannel.Result) {
        val coin: String? = call.argument("coin")
        val path: String? = call.argument("path")
        val mnemonic: String? = call.argument("mnemonic")
        val passphrase: String? = call.argument("passphrase")
        val txData: Map<String, Any>? = call.argument("txData")
        val pkStr: String? = call.argument("pk")
        if (txData != null && path != null && coin != null && mnemonic != null && pkStr != null) {
            if (mnemonic != "") {
                val wallet = HDWallet(mnemonic, passphrase)
                val coinType: CoinType = keyHandler.getCoinTypeWithCoinString(coin)
                val txHash: String? = signEthereumTransactionWithData(wallet, path, txData, coinType, null)
                if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
            } else if (pkStr != "") {
                val pk: ByteArray = aBase64.decode(pkStr, 64)

                val privateKey: PrivateKey? = keyHandler.getPrivateKeyFromBytes(pk)
                if (privateKey == null) {
                    result.error("privateKey", "failed to privateKey", null)
                } else {
                    val coinType: CoinType = keyHandler.getCoinTypeWithCoinString(coin)
                    val txHash: String? = signEthereumTransactionWithData(null, path, txData, coinType, privateKey)
                    if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
                }

            } else {
                result.error("no_wallet",
                    "Could not generate wallet, why?", null)
            }
        } else {
            result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
        }
    }

    fun handleSignTransactionBtcP2wsh(call: MethodCall, result: MethodChannel.Result) {
        val coin: String? = call.argument("coin")
        val path: String? = call.argument("path")
        val mnemonic: String? = call.argument("mnemonic")
        val passphrase: String? = call.argument("passphrase")
        val txData: Map<String, Any>? = call.argument("txData")
        val pkStr: String? = call.argument("pk")
        if (txData != null && path != null && coin != null && mnemonic != null && pkStr != null) {
            if (mnemonic != "") {
                val wallet = HDWallet(mnemonic, passphrase)
                val txHash: String = signBitcoinTransactionP2wsh(wallet, path, txData, null)
                result.success(txHash)
            } else if (pkStr != "") {
                val pk: ByteArray = aBase64.decode(pkStr, 64)

                val privateKey = PrivateKey(pk)
                val txHash: String = signBitcoinTransactionP2wsh(null, path, txData, privateKey)
                result.success(txHash)

            } else {
                result.error("no_wallet",
                    "Could not generate wallet, why?", null)
            }
        } else {
            result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
        }
    }

    fun handleSignTransactionByteArray(call: MethodCall, result: MethodChannel.Result) {
        val coin: String? = call.argument("coin")
        val path: String? = call.argument("path")
        val mnemonic: String? = call.argument("mnemonic")
        val passphrase: String? = call.argument("passphrase")
        val txData: Map<String, Any>? = call.argument("txData")
        val pkStr: String? = call.argument("pk")
        if (txData != null && path != null && coin != null && mnemonic != null && pkStr != null) {

            if (mnemonic != "") {
                val wallet = HDWallet(mnemonic, passphrase)
                val txHash: String? = signTransactionByteArray(wallet, coin, path, txData, null)
                if (txHash == null) {
                    result.error("txhash_null", "failed to buid and sign transaction", null)
                } else {
                    result.success(txHash)
                }
            } else if (pkStr != "") {
                val pk: ByteArray = aBase64.decode(pkStr, 64)
                val privateKey = PrivateKey(pk)
                val txHash: String? = signTransactionByteArray(null, coin, path, txData, privateKey)
                if (txHash == null)
                    result.error("txhash_null", "failed to buid and sign transaction", null)
                else result.success(txHash)

            } else {
                result.error("no_wallet",
                    "Could not generate wallet, why?", null)
            }
        } else {
            result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
        }
    }

    fun handleSignMessage(call: MethodCall, result: MethodChannel.Result) {
        val coin: String? = call.argument("coin")
        val path: String? = call.argument("path")
        val mnemonic: String? = call.argument("mnemonic")
        val passphrase: String? = call.argument("passphrase")
        val txData: String? = call.argument("txData")
        val pkStr: String? = call.argument("pk")
        if (txData != null && path != null && coin != null && mnemonic != null && pkStr != null) {

            if (mnemonic != "") {
                val wallet = HDWallet(mnemonic, passphrase)
                val txHash: String? = signMessage(wallet, coin, path, txData, null)
                if (txHash == null) result.error("txhash_null", "failed to buid and sign message", null) else result.success(txHash)
            } else if (pkStr != "") {
                val pk: ByteArray = aBase64.decode(pkStr, 64)
                val privateKey = PrivateKey(pk)
                val txHash: String? = signMessage(null, coin, path, txData, privateKey)
                if (txHash == null) result.error("txhash_null", "failed to buid and sign messagee", null) else result.success(txHash)

            } else {
                result.error("no_wallet",
                    "Could not generate wallet, why?", null)
            }
        } else {
            result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
        }
    }

    fun handleGetTransactionMaxValue(call: MethodCall, result: MethodChannel.Result) {
        val coin: String? = call.argument("coin")
        val path: String? = call.argument("path")
        val mnemonic: String? = call.argument("mnemonic")
        val passphrase: String? = call.argument("passphrase")
        val txData: Map<String, Any>? = call.argument("txData")
        val pkStr: String? = call.argument("pk")
        if (txData != null && path != null && coin != null && mnemonic != null && pkStr != null) {

            if (mnemonic != "") {
                val wallet = HDWallet(mnemonic, passphrase)
                val txHash: String? = signTransactionMaxValue(wallet, coin, path, txData, null)
                if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
            } else if (pkStr != "") {
                val pk: ByteArray = aBase64.decode(pkStr, 64)

                val privateKey = PrivateKey(pk)
                val txHash: String? = signTransactionMaxValue(null, coin, path, txData, privateKey)
                if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)

            } else {
                result.error("no_wallet",
                    "Could not generate wallet, why?", null)
            }
        } else {
            result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
        }
    }

    fun handleEvmEmit(call: MethodCall, result: MethodChannel.Result) {
        try {
            val params = call.arguments<Map<String, Any>>()
            if (params == null) {
                result.error("Evm", "params is null", null)
                return
            }
            val paramsJson = JSONObject(params).toString()
            val responseStringJson = Evmsdk.emit(paramsJson)
            if (responseStringJson != null) {
                result.success(responseStringJson)
            } else {
                result.error("Evm", "evm response no data", null)
            }
        } catch (e: Exception) {
            result.error("Evm", e.message, null)
        }
    }

    fun handleGetPubKeySOL(call: MethodCall, result: MethodChannel.Result) {
        val mintAddress: String? = call.argument("mintAddress")
        val address: String? = call.argument("address")
        val pubKey: String = SolanaAddress(address).defaultTokenAddress(mintAddress)
        result.success(pubKey)
    }

    // ── Internal signing implementations ─────────────────────────────────

    private fun signTransactionMaxValue(wallet: HDWallet?, coin: String, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val chainType: String = keyHandler.getChainTypeWithCoinString(coin)
        if (chainType == "") {
            return null
        }
        val coinType: CoinType = keyHandler.getCoinTypeWithCoinString(coin)
        return when (chainType) {
            "Bitcoin" -> {
                signBitcoinTransactionMaxValue(wallet, path, txData, coinType, pk)
            }
            else -> null
        }
    }

    private fun signTransaction(wallet: HDWallet?, coin: String, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val chainType: String = keyHandler.getChainTypeWithCoinString(coin)
        if (chainType == "") {
            return null
        }
        val coinType: CoinType = keyHandler.getCoinTypeWithCoinString(coin)
        return when (chainType) {
            "Bitcoin" -> {
                signBitcoinTransaction(wallet, path, txData, coinType, pk)
            }
            "Ethereum" -> {
                signEthereumTransactionErc721(wallet, path, txData, coinType, pk)
            }
            "Tron" -> {
                signTronTransaction(wallet, path, txData, pk)
            }
            "Tezos" -> {
                signTezosTransaction(wallet, path, txData, pk)
            }
            "Solana" -> {
                signSolanaTransaction(wallet, path, txData, pk)
            }
            "Ripple" -> {
                signXRPTransaction(wallet, path, txData, pk)
            }
            "Cosmos" -> {
                signCosmosTransaction(wallet, path, txData, pk)
            }
            "Filecoin" -> {
                signFilecoinTransaction(wallet, path, txData, pk)
            }
            "Polkadot" -> {
                signPOLKADOTTransaction(wallet, path, txData, coinType, pk)
            }
            "Acala" -> {
                signPOLKADOTTransaction(wallet, path, txData, coinType, pk)
            }
            "Kusama" -> {
                signPOLKADOTTransaction(wallet, path, txData, coinType, pk)
            }
            "Aptos" -> {
                signAptosTransaction(wallet, path, txData, pk)
            }
            "Sui" -> {
                signSuiTransaction(wallet, path, txData, pk)
            }
            "Ton" -> {
                signTonTransaction(wallet, path, txData, pk)
            }
            "Stellar" -> {
                signStellarTransaction(wallet, path, txData, pk)
            }
            "VeChain" -> {
                signVeChainTransaction(wallet, path, txData, pk)
            }
            "Near" -> {
                signNearTransaction(wallet, path, txData, pk)
            }
            "Zilliqa" -> {
                signZilliqaTransaction(wallet, path, txData, pk)
            }
            "Theta" -> {
                signThetaTransaction(wallet, path, txData, pk)
            }
            "Cardano" -> {
                signCardanoTransaction(wallet, path, txData, pk)
            }
            "MultiversX" -> {
                signMultiversXTransaction(wallet, path, txData, pk)
            }
            else -> null
        }
    }

    private fun signTransactionByteArray(wallet: HDWallet?, coin: String, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        return when (coin) {
            "ALGO" -> {
                signAlgorandTransaction(wallet, path, txData, pk)
            }
            else -> null
        }
    }

    private fun signMessage(wallet: HDWallet?, coin: String, path: String, txData: String, pk: PrivateKey?): String? {
        val chainType: String = keyHandler.getChainTypeWithCoinString(coin)
        if (chainType == "") {
            return null
        }
        val coinType: CoinType = keyHandler.getCoinTypeWithCoinString(coin)
        val privateKey = pk ?: wallet!!.getKey(coinType, path)
        if (coinType == CoinType.TRON) {

            val ba: ByteArray = privateKey.sign(txData.toByteArray(), coinType.curve())
            return Numeric.toHexString(ba)
        }
        val ba: ByteArray = privateKey.sign(Numeric.hexStringToByteArray(txData), coinType.curve())
        return Numeric.toHexString(ba)
    }

    private fun signCosmosTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val privateKey = pk ?: wallet!!.getKey(CoinType.COSMOS, path)
        val token: Map<String, Any>? = txData["token"] as Map<String, Any>?
        val feeMap: Map<String, Any> = txData["fee"] as Map<String, Any>
        val amount: Map<String, Any> = txData["amount"] as Map<String, Any>

        val chainId: String = txData["chainId"] as String
        val fromAddress: String = CoinType.COSMOS.deriveAddress(privateKey)
        val toAddress: String = txData["toAddress"] as String
        val accountNumber: Long = when (val v = txData["accountNumber"]) {
            is Number -> v.toLong()
            else -> v.toString().toLong()
        }
        val sequence: Long = when (val v = txData["sequence"]) {
            is Number -> v.toLong()
            else -> v.toString().toLong()
        }
        val memo: String = txData["memo"] as String

        val fee = Cosmos.Fee.newBuilder()
            .setGas((feeMap["gas"] as String).toLong())
            .addAmounts(
                Cosmos.Amount.newBuilder()
                    .setAmount(feeMap["amount"] as String)
                    .setDenom(feeMap["denom"] as String)
            )

        val input = Cosmos.SigningInput.newBuilder()
            .setMode(Cosmos.BroadcastMode.BLOCK)
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .setChainId(chainId)
            .setFee(fee)
            .setAccountNumber(accountNumber)
            .setSequence(sequence)
            .setMemo(memo)

        if (token == null) {
            input.addMessages(
                Cosmos.Message.newBuilder()
                    .setSendCoinsMessage(Cosmos.Message.Send.newBuilder()
                        .setFromAddress(fromAddress)
                        .setToAddress(toAddress)
                        .addAmounts(
                            Cosmos.Amount.newBuilder()
                                .setAmount(amount["amount"] as String)
                                .setDenom(amount["denom"] as String)
                        )
                    )
            )
        } else {
            Cosmos.Message.newBuilder()
                .setTransferTokensMessage(Cosmos.Message.Transfer.newBuilder()
                    .setReceiver(token["receiver"] as String)
                    .setSourceChannel(token["sourceChannel"] as String)
                    .setSourcePort(token["sourcePort"] as String)
                    .setSender(fromAddress)
                    .setToken(
                        Cosmos.Amount.newBuilder()
                            .setAmount(amount["amount"] as String)
                            .setDenom(amount["denom"] as String)
                    )
                    .setTimeoutHeight(
                        Cosmos.Height.newBuilder()
                            .setRevisionHeight((token["revisionHeight"] as String).toLong())
                            .setRevisionNumber((token["revisionNumber"] as String).toLong())
                    )
                )
        }
        val result = AnySigner.sign(input.build(), CoinType.COSMOS, Cosmos.SigningOutput.parser())
        return result.json
    }

    private fun signTronTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val cmd = txData["cmd"] as String
        val privateKey = pk ?: wallet!!.getKey(CoinType.TRON, path)
        val txHash: String?
        val number: Number = txData["number"] as Number
        val blockTime: Number = txData["blockTime"] as Number
        val timestamp: Number = txData["timestamp"] as Number
        val version: Int = txData["version"] as Int
        when (cmd) {
            "TRC20" -> {
                val feeLimit: Number = txData["feeLimit"] as Number
                val trc20Contract = Tron.TransferTRC20Contract.newBuilder()
                    .setOwnerAddress(txData["ownerAddress"] as String)
                    .setContractAddress(txData["contractAddress"] as String)
                    .setToAddress(txData["toAddress"] as String)
                    .setAmount(ByteString.copyFrom(Numeric.hexStringToByteArray((txData["amount"] as String))))

                val blockHeader = Tron.BlockHeader.newBuilder()
                    .setTimestamp(blockTime.toLong())
                    .setTxTrieRoot(ByteString.copyFrom(Numeric.hexStringToByteArray((txData["txTrieRoot"] as String))))
                    .setParentHash(ByteString.copyFrom(Numeric.hexStringToByteArray((txData["parentHash"] as String))))
                    .setNumber(number.toLong())
                    .setWitnessAddress(ByteString.copyFrom(Numeric.hexStringToByteArray((txData["witnessAddress"] as String))))
                    .setVersion(version)
                    .build()

                val transaction = Tron.Transaction.newBuilder()
                    .setTimestamp(timestamp.toLong())
                    .setTransferTrc20Contract(trc20Contract)
                    .setBlockHeader(blockHeader)
                    .setFeeLimit(feeLimit.toLong())
                    .build()

                val signingInput = Tron.SigningInput.newBuilder()
                    .setTransaction(transaction)
                    .setPrivateKey(ByteString.copyFrom(privateKey.data()))

                val output = AnySigner.sign(signingInput.build(), CoinType.TRON, Tron.SigningOutput.parser())
                txHash = output.json
            }
            "TRC10" -> {
                val amountNum: Number = txData["amount"] as Number
                val trc10Contract = Tron.TransferAssetContract.newBuilder()
                    .setOwnerAddress(txData["ownerAddress"] as String)
                    .setAssetName(txData["assetName"] as String)
                    .setToAddress(txData["toAddress"] as String)
                    .setAmount(amountNum.toLong())

                val blockHeader = Tron.BlockHeader.newBuilder()
                    .setTimestamp(blockTime.toLong())
                    .setTxTrieRoot(ByteString.copyFrom(Numeric.hexStringToByteArray((txData["txTrieRoot"] as String))))
                    .setParentHash(ByteString.copyFrom(Numeric.hexStringToByteArray((txData["parentHash"] as String))))
                    .setNumber(number.toLong())
                    .setWitnessAddress(ByteString.copyFrom(Numeric.hexStringToByteArray((txData["witnessAddress"] as String))))
                    .setVersion(version)
                    .build()

                val transaction = Tron.Transaction.newBuilder()
                    .setTimestamp(timestamp.toLong())
                    .setTransferAsset(trc10Contract)
                    .setBlockHeader(blockHeader)
                    .build()

                val signingInput = Tron.SigningInput.newBuilder()
                    .setTransaction(transaction)
                    .setPrivateKey(ByteString.copyFrom(privateKey.data()))

                val output = AnySigner.sign(signingInput.build(), CoinType.TRON, Tron.SigningOutput.parser())
                txHash = output.json
            }
            "TRX" -> {
                val amountNum: Number = txData["amount"] as Number
                val transfer = Tron.TransferContract.newBuilder()
                    .setOwnerAddress(txData["ownerAddress"] as String)
                    .setToAddress(txData["toAddress"] as String)
                    .setAmount(amountNum.toLong())

                val blockHeader = Tron.BlockHeader.newBuilder()
                    .setTimestamp(blockTime.toLong())
                    .setTxTrieRoot(ByteString.copyFrom(Numeric.hexStringToByteArray((txData["txTrieRoot"] as String))))
                    .setParentHash(ByteString.copyFrom(Numeric.hexStringToByteArray((txData["parentHash"] as String))))
                    .setNumber(number.toLong())
                    .setWitnessAddress(ByteString.copyFrom(Numeric.hexStringToByteArray((txData["witnessAddress"] as String))))
                    .setVersion(version)
                    .build()

                val transaction = Tron.Transaction.newBuilder()
                    .setTimestamp(timestamp.toLong())
                    .setTransfer(transfer)
                    .setBlockHeader(blockHeader)
                    .build()

                val signingInput = Tron.SigningInput.newBuilder()
                    .setTransaction(transaction)
                    .setPrivateKey(ByteString.copyFrom(privateKey.data()))

                val output = AnySigner.sign(signingInput.build(), CoinType.TRON, Tron.SigningOutput.parser())
                txHash = output.json
            }
            "FREEZE" -> {
                val frozenDuration: Number = txData["frozenDuration"] as Number
                val frozenBalance: Number = txData["frozenBalance"] as Number
                val freezeContract = Tron.FreezeBalanceContract.newBuilder()
                    .setOwnerAddress(txData["ownerAddress"] as String)
                    .setResource(txData["resource"] as String)
                    .setFrozenDuration(frozenDuration.toLong())
                    .setFrozenBalance(frozenBalance.toLong())

                val blockHeader = Tron.BlockHeader.newBuilder()
                    .setTimestamp(blockTime.toLong())
                    .setTxTrieRoot(ByteString.copyFrom(Numeric.hexStringToByteArray((txData["txTrieRoot"] as String))))
                    .setParentHash(ByteString.copyFrom(Numeric.hexStringToByteArray((txData["parentHash"] as String))))
                    .setNumber(number.toLong())
                    .setWitnessAddress(ByteString.copyFrom(Numeric.hexStringToByteArray((txData["witnessAddress"] as String))))
                    .setVersion(version)
                    .build()

                val transaction = Tron.Transaction.newBuilder()
                    .setTimestamp(timestamp.toLong())
                    .setFreezeBalance(freezeContract)
                    .setBlockHeader(blockHeader)
                    .build()

                val signingInput = Tron.SigningInput.newBuilder()
                    .setTransaction(transaction)
                    .setPrivateKey(ByteString.copyFrom(privateKey.data()))

                val output = AnySigner.sign(signingInput.build(), CoinType.TRON, Tron.SigningOutput.parser())
                txHash = output.json
            }
            "CONTRACT" -> {
                txHash = null
            }
            else -> txHash = null
        }
        return txHash
    }

    private fun signTezosTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String {
        val privateKey = pk ?: wallet!!.getKey(CoinType.TEZOS, path)
        val publickKey: ByteString = ByteString.copyFrom(privateKey.publicKeyEd25519.data())
        val branchStr: String = txData["branch"] as String
        val fee: Long = (txData["fee"] as Number).toLong()
        val gasLimit: Long = (txData["gasLimit"] as Number).toLong()
        val amount: Long = (txData["amount"] as Number).toLong()
        val toAddress: String = txData["toAddress"] as String
        val counter: Long = (txData["counter"] as Number).toLong()
        val storageLimit: Long = (txData["storageLimit"] as Number).toLong()
        val reveal: Boolean = txData["reveal"] as Boolean
        val contractAddres: String = txData["contractAddres"] as String
        val fromAddress = CoinType.TEZOS.deriveAddress(privateKey)

        val tOperation = Tezos.Operation.newBuilder()
            .setKind(Tezos.Operation.OperationKind.TRANSACTION).setFee(fee)
            .setSource(fromAddress)
            .setGasLimit(gasLimit)
            .setStorageLimit(storageLimit)

        if (contractAddres == "") {
            tOperation.setTransactionOperationData(
                Tezos.TransactionOperationData.newBuilder()
                    .setAmount(amount)
                    .setDestination(toAddress)
            )
        } else {
            tOperation.setTransactionOperationData(
                Tezos.TransactionOperationData.newBuilder()
                    .setAmount(0)
                    .setDestination(contractAddres)
                    .setParameters(
                        Tezos.OperationParameters.newBuilder()
                            .setFa12Parameters(
                                Tezos.FA12Parameters.newBuilder()
                                    .setValue(amount.toString())
                                    .setEntrypoint("transfer")
                                    .setFrom(fromAddress)
                                    .setTo(toAddress)
                            )
                    )
            )
        }

        val input = Tezos.SigningInput.newBuilder()
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
        if (!reveal) {
            tOperation.setCounter(counter + 1)
            input.setOperationList(
                Tezos.OperationList.newBuilder()
                    .setBranch(branchStr)
                    .addOperations(Tezos.Operation.newBuilder()
                        .setKind(Tezos.Operation.OperationKind.REVEAL).setFee(fee)
                        .setSource(fromAddress)
                        .setGasLimit(gasLimit)
                        .setStorageLimit(storageLimit)
                        .setCounter(counter)
                        .setRevealOperationData(
                            Tezos.RevealOperationData.newBuilder()
                                .setPublicKey(publickKey)
                        )
                    )
                    .addOperations(tOperation)

            )

        } else {
            tOperation.setCounter(counter)
            input.setOperationList(
                Tezos.OperationList.newBuilder()
                    .setBranch(branchStr)
                    .addOperations(tOperation)
            )
        }

        val result = AnySigner.sign(input.build(), CoinType.TEZOS, Tezos.SigningOutput.parser())
        return Numeric.toHexString(result.encoded.toByteArray())
    }

    private fun signXRPTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val privateKey = pk ?: wallet!!.getKey(CoinType.XRP, path)
        val amount: Long = (txData["amount"] as String).toLong()
        val sequence: Int = txData["sequence"] as Int
        val ledgerIndex: Int = txData["ledgerIndex"] as Int
        val account: String = CoinType.XRP.deriveAddress(privateKey)
        val destination: String = txData["toAddress"] as String
        val fee: Long = (txData["fee"] as String).toLong()
        val txType: String = txData["txType"] as String
        val issuer: String = txData["issuer"] as String
        val currency: String = txData["currency"] as String
        val input: Ripple.SigningInput.Builder = Ripple.SigningInput.newBuilder()
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .setFee(fee)
            .setSequence(sequence)
            .setLastLedgerSequence(ledgerIndex + 20)
            .setAccount(account)
        when (txType) {
            "Trustline" -> {
                input.setOpTrustSet(
                    Ripple.OperationTrustSet.newBuilder()
                        .setLimitAmount(
                            Ripple.CurrencyAmount.newBuilder()
                                .setValue(amount.toString())
                                .setCurrency(currency)
                                .setIssuer(issuer)
                        )
                )
                    .setFlags(131072)
            }
            "XRPL" -> {
                input.setOpPayment(
                    Ripple.OperationPayment.newBuilder()
                        .setCurrencyAmount(
                            Ripple.CurrencyAmount.newBuilder()
                                .setValue(amount.toString())
                                .setCurrency(currency)
                                .setIssuer(issuer)
                        )
                        .setDestination(destination)
                )
            }
            else -> {
                input.setOpPayment(
                    Ripple.OperationPayment.newBuilder()
                        .setAmount(amount)
                        .setDestination(destination).build()
                )
            }
        }
        val output = AnySigner.sign(input.build(), CoinType.XRP, Ripple.SigningOutput.parser())
        return Numeric.toHexString(output.encoded.toByteArray())
    }

    private fun signEthereumTransactionErc721(wallet: HDWallet?, path: String, txData: Map<String, Any>, coinType: CoinType, pk: PrivateKey?): String {
        val privateKey = pk ?: wallet!!.getKey(coinType, path)
        val chainId: String = txData["chainId"] as String
        val gasLimit: String = txData["gasLimit"] as String
        val gasPrice: String = txData["gasPrice"] as String
        val gasPrice2: String = txData["gasPrice2"] as String
        val nonce: String = txData["nonce"] as String
        val toAddress: String = txData["toAddress"] as String
        val amount: String = txData["amount"] as String
        val erc721Or1155: String = txData["erc721Or1155"] as String
        val messageData: String = txData["msgData"] as String
        val is1559: String = txData["is1559"] as String

        val chainIdBS: ByteString = ByteString.copyFrom(BigInteger(chainId, 16).toByteArray())
        val gasLimitBS: ByteString = ByteString.copyFrom(BigInteger(gasLimit, 16).toByteArray())
        val gasPriceBS: ByteString = ByteString.copyFrom(BigInteger(gasPrice, 16).toByteArray())
        val gasPrice2BS: ByteString = ByteString.copyFrom(BigInteger(gasPrice2, 16).toByteArray())
        val nonceBS: ByteString = ByteString.copyFrom(BigInteger(nonce, 16).toByteArray())
        val amountBS: ByteString = ByteString.copyFrom(BigInteger(amount, 16).toByteArray())
        val messageDataBS: ByteString = ByteString.copyFrom(messageData.toByteArray())
        val privateKeyBS: ByteString = ByteString.copyFrom(privateKey.data())
        val input = Ethereum.SigningInput.newBuilder()
            .setChainId(chainIdBS)
            .setGasLimit(gasLimitBS)
            .setNonce(nonceBS)
            .setPrivateKey(privateKeyBS)
        if (is1559 == "true") {
            input.setMaxFeePerGas(gasPriceBS)
            input.setMaxInclusionFeePerGas(gasPrice2BS)
            input.setTxMode(Ethereum.TransactionMode.Enveloped)
        } else {
            input.setGasPrice(gasPriceBS)
            input.setTxMode(Ethereum.TransactionMode.Legacy)
        }
        val contract: String = txData["contract"] as String
        if (contract == "") {
            input.setToAddress(toAddress)
            input.setTransaction(Ethereum.Transaction.newBuilder()
                .setTransfer(Ethereum.Transaction.Transfer.newBuilder()
                    .setAmount(amountBS)
                    .setData(messageDataBS)
                )
            )
        } else if (erc721Or1155 == "721") {
            val tokenIdBS: ByteString = ByteString.copyFrom(BigInteger((txData["tokenId"] as String), 16).toByteArray())
            val fromAddress = coinType.deriveAddress(privateKey)
            input.setToAddress(contract)
            input.setTransaction(
                Ethereum.Transaction.newBuilder()
                    .setErc721Transfer(
                        Ethereum.Transaction.ERC721Transfer.newBuilder()
                            .setFrom(fromAddress)
                            .setTo(toAddress)
                            .setTokenId(tokenIdBS)
                    )
            )
        } else if (erc721Or1155 == "1155") {
            val tokenIdBS: ByteString = ByteString.copyFrom(BigInteger((txData["tokenId"] as String), 16).toByteArray())
            val trValueBS: ByteString = ByteString.copyFrom(BigInteger((txData["trValue"] as String), 16).toByteArray())
            val fromAddress = coinType.deriveAddress(privateKey)
            input.setToAddress(contract)
            input.setTransaction(
                Ethereum.Transaction.newBuilder()
                    .setErc1155Transfer(
                        Ethereum.Transaction.ERC1155Transfer.newBuilder()
                            .setFrom(fromAddress)
                            .setTo(toAddress)
                            .setTokenId(tokenIdBS)
                            .setValue(trValueBS)
                    )
            )
        } else if (erc721Or1155 == "approve") {
            input.setToAddress(contract)
            input.setTransaction(
                Ethereum.Transaction.newBuilder().setErc20Approve(
                    Ethereum.Transaction.ERC20Approve.newBuilder()
                        .setAmount(amountBS)
                        .setSpender(toAddress)
                )
            )
        } else {
            input.setToAddress(contract)
            input.setTransaction(
                Ethereum.Transaction.newBuilder().setErc20Transfer(
                    Ethereum.Transaction.ERC20Transfer.newBuilder()
                        .setAmount(amountBS)
                        .setTo(toAddress)
                )
            )
        }

        val result = AnySigner.sign(input.build(), coinType, Ethereum.SigningOutput.parser())
        return Numeric.toHexString(result.encoded.toByteArray())
    }

    private fun signEthereumTransactionWithData(wallet: HDWallet?, path: String, txData: Map<String, Any>, coinType: CoinType, pk: PrivateKey?): String {
        val privateKey = pk ?: wallet!!.getKey(coinType, path)
        val chainId: String = txData["chainId"] as String
        val gasLimit: String = txData["gasLimit"] as String
        val gasPrice: String = txData["gasPrice"] as String
        val gasPrice2: String = txData["gasPrice2"] as String
        val nonce: String = txData["nonce"] as String
        val toAddress: String = txData["toAddress"] as String
        val amount: String = txData["amount"] as String
        val messageData: String = txData["msgData"] as String
        val contract: String = txData["contract"] as String

        val chainIdBS: ByteString = ByteString.copyFrom(BigInteger(chainId, 16).toByteArray())
        val gasLimitBS: ByteString = ByteString.copyFrom(BigInteger(gasLimit, 16).toByteArray())
        val gasPriceBS: ByteString = ByteString.copyFrom(BigInteger(gasPrice, 16).toByteArray())
        val gasPrice2BS: ByteString = ByteString.copyFrom(BigInteger(gasPrice2, 16).toByteArray())
        val nonceBS: ByteString = ByteString.copyFrom(BigInteger(nonce, 16).toByteArray())
        val amountBS: ByteString = ByteString.copyFrom(BigInteger(amount, 16).toByteArray())
        val messageDataBS: ByteString = ByteString.copyFrom(messageData.toByteArray())
        val privateKeyBS: ByteString = ByteString.copyFrom(privateKey.data())
        val input = Ethereum.SigningInput.newBuilder()
            .setTxMode(Ethereum.TransactionMode.Enveloped)
            .setChainId(chainIdBS)
            .setGasLimit(gasLimitBS)
            .setGasPrice(gasPriceBS)
            .setMaxFeePerGas(gasPriceBS)
            .setMaxInclusionFeePerGas(gasPrice2BS)
            .setNonce(nonceBS)
            .setPrivateKey(privateKeyBS)
        input.setToAddress(contract)
        input.setTransaction(
            Ethereum.Transaction.newBuilder().setContractGeneric(
                Ethereum.Transaction.ContractGeneric.newBuilder()
                    .setData(messageDataBS)
                    .setAmount(amountBS)
            )
        )

        val result = AnySigner.sign(input.build(), coinType, Ethereum.SigningOutput.parser())
        return Numeric.toHexString(result.encoded.toByteArray())
    }

    private fun signSolanaTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val privateKey = pk ?: wallet!!.getKey(CoinType.SOLANA, path)
        val type: String = txData["type"] as String
        val encodeType: String = txData["encodeType"] as String
        if (type == "createTokenAccount") {
            val createTokenAccount: Map<String, String> = txData["createTokenAccount"] as Map<String, String>
            val mainAddress: String = createTokenAccount["mainAddress"] as String
            val tokenAddress: String = createTokenAccount["tokenAddress"] as String
            val tokenMintAddress: String = createTokenAccount["tokenMintAddress"] as String
            val input = Solana.SigningInput.newBuilder()
                .setCreateTokenAccountTransaction(
                    Solana.CreateTokenAccount.newBuilder()
                        .setMainAddress(mainAddress)
                        .setTokenAddress(tokenAddress)
                        .setTokenMintAddress(tokenMintAddress)
                )
                .setPrivateKey(ByteString.copyFrom(privateKey.data()))
                .setRecentBlockhash(txData["recentBlockhash"] as String)
            val result = AnySigner.sign(input.build(), CoinType.SOLANA, Solana.SigningOutput.parser())
            if (encodeType == "base64") {
                val signedTransaction = result.encoded.toByteArray()
                val base64EncodedTransaction = aBase64.encodeToString(signedTransaction, aBase64.NO_WRAP)
                return base64EncodedTransaction
            } else {
                return result.encoded
            }
        } else if (type == "token") {
            val transferTransaction: Map<String, String> = txData["tokenTransferTransaction"] as Map<String, String>
            val amount: String = transferTransaction["amount"] as String
            val tokenMintAddress: String = transferTransaction["tokenMintAddress"] as String
            val senderTokenAddress: String = SolanaAddress(transferTransaction["senderTokenAddress"] as String).defaultTokenAddress(tokenMintAddress)
            val recipient: String = SolanaAddress(transferTransaction["recipientMainAddress"] as String).defaultTokenAddress(tokenMintAddress)
            val decimals: String = transferTransaction["decimals"] as String
            val input = Solana.SigningInput.newBuilder()
                .setPrivateKey(ByteString.copyFrom(privateKey.data()))
                .setRecentBlockhash(txData["recentBlockhash"] as String)
                .setTokenTransferTransaction(
                    Solana.TokenTransfer.newBuilder()
                        .setRecipientTokenAddress(recipient)
                        .setAmount(amount.toLong())
                        .setTokenMintAddress(tokenMintAddress)
                        .setSenderTokenAddress(senderTokenAddress)
                        .setDecimals(decimals.toInt())
                )
            val result = AnySigner.sign(input.build(), CoinType.SOLANA, Solana.SigningOutput.parser())
            if (encodeType == "base64") {
                val signedTransaction = result.encoded.toByteArray()
                val base64EncodedTransaction = aBase64.encodeToString(signedTransaction, aBase64.NO_WRAP)
                return base64EncodedTransaction
            } else {
                return result.encoded
            }
        } else if (type == "tokenCreate") {
            val transferTransaction: Map<String, String> = txData["tokenTransferTransaction"] as Map<String, String>
            var recipientTokenAddress: String = transferTransaction["recipientTokenAddress"] as String
            val recipientMainAddress: String = transferTransaction["recipientMainAddress"] as String
            val amount: String = transferTransaction["amount"] as String
            val tokenMintAddress: String = transferTransaction["tokenMintAddress"] as String
            val senderTokenAddress: String = SolanaAddress(transferTransaction["senderTokenAddress"] as String).defaultTokenAddress(tokenMintAddress)
            val decimals: String = transferTransaction["decimals"] as String

            val input = Solana.SigningInput.newBuilder()
                .setPrivateKey(ByteString.copyFrom(privateKey.data()))
                .setRecentBlockhash(txData["recentBlockhash"] as String)

            if (recipientTokenAddress == "") {
                recipientTokenAddress = SolanaAddress(recipientMainAddress).defaultTokenAddress(tokenMintAddress)
                input.setCreateAndTransferTokenTransaction(
                    Solana.CreateAndTransferToken.newBuilder()
                        .setSenderTokenAddress(senderTokenAddress)
                        .setTokenMintAddress(tokenMintAddress)
                        .setRecipientMainAddress(recipientMainAddress)
                        .setRecipientTokenAddress(recipientTokenAddress)
                        .setDecimals(decimals.toInt())
                        .setAmount(amount.toLong()))
            } else {
                input.setTokenTransferTransaction(
                    Solana.TokenTransfer.newBuilder()
                        .setRecipientTokenAddress(recipientTokenAddress)
                        .setAmount(amount.toLong())
                        .setTokenMintAddress(tokenMintAddress)
                        .setSenderTokenAddress(senderTokenAddress)
                        .setDecimals(decimals.toInt())
                )
            }
            val result = AnySigner.sign(input.build(), CoinType.SOLANA, Solana.SigningOutput.parser())
            if (encodeType == "base64") {
                val signedTransaction = result.encoded.toByteArray()
                val base64EncodedTransaction = aBase64.encodeToString(signedTransaction, aBase64.NO_WRAP)
                return base64EncodedTransaction
            } else {
                return result.encoded
            }
        } else {
            val transferTransaction: Map<String, String> = txData["transferTransaction"] as Map<String, String>
            val recipient: String = transferTransaction["recipient"] as String
            val value: String = transferTransaction["value"] as String
            val input = Solana.SigningInput.newBuilder()
                .setPrivateKey(ByteString.copyFrom(privateKey.data()))
                .setRecentBlockhash(txData["recentBlockhash"] as String)
                .setTransferTransaction(
                    Solana.Transfer.newBuilder().setRecipient(recipient).setValue(value.toLong()).build()
                )
            val result = AnySigner.sign(input.build(), CoinType.SOLANA, Solana.SigningOutput.parser())
            if (encodeType == "base64") {
                val signedTransaction = result.encoded.toByteArray()
                val base64EncodedTransaction = aBase64.encodeToString(signedTransaction, aBase64.NO_WRAP)
                return base64EncodedTransaction
            } else {
                return result.encoded
            }
        }
    }

    private fun signBitcoinTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, coinType: CoinType, pk: PrivateKey?): String {
        val privateKey = pk ?: wallet!!.getKey(coinType, path)
        val utxos: List<Map<String, Any>> = txData["utxo"] as List<Map<String, Any>>

        val amount: Long = (txData["amount"] as Number).toLong()
        val useMaxAmount: Boolean = txData["max"] as Boolean
        var input = Bitcoin.SigningInput.newBuilder()
            .setByteFee((txData["byteFee"] as Number).toLong())
            .setChangeAddress(txData["changeAddress"] as String)
            .setToAddress(txData["toAddress"] as String)
            .setCoinType(coinType.value())
            .setHashType(BitcoinScript.hashTypeForCoin(coinType))
            .addPrivateKey(ByteString.copyFrom(privateKey.data()))
        if (useMaxAmount) {
            input.setUseMaxAmount(true)
        } else {
            input.setAmount(amount)
        }
        for (utx in utxos) {
            val txHash = Numeric.hexStringToByteArray(utx["txid"] as String)
            txHash.reverse()
            val outPoint = Bitcoin.OutPoint.newBuilder()
                .setHash(ByteString.copyFrom(txHash))
                .setIndex(utx["vout"] as Int)
                .setSequence(Long.MAX_VALUE.toInt())
                .build()

            val txScript = Numeric.hexStringToByteArray(utx["script"] as String)
            val utxo = Bitcoin.UnspentTransaction.newBuilder()
                .setAmount((utx["value"] as String).toLong())
                .setOutPoint(outPoint)
                .setScript(ByteString.copyFrom(txScript))
                .build()
            input.addUtxo(utxo)
        }
        val output = AnySigner.sign(input.build(), coinType, Bitcoin.SigningOutput.parser())
        return Numeric.toHexString(output.encoded.toByteArray())
    }

    private fun signBitcoinTransactionP2wsh(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String {
        val privateKey = pk ?: wallet!!.getKey(CoinType.BITCOIN, path)

        val utxos: List<Map<String, Any>> = txData["utxo"] as List<Map<String, Any>>
        val amount: Long = (txData["amount"] as Number).toLong()
        val useMaxAmount: Boolean = txData["max"] as Boolean
        val transactionV2 = BitcoinV2.TransactionBuilder.newBuilder()
            .setLockTime((utxos[0]["lockTime"] as Number).toInt())
            .setFeePerVb((txData["byteFee"] as Number).toLong())
            .setVersion(
                BitcoinV2.TransactionVersion.V2
            )
            .setInputSelector(BitcoinV2.InputSelector.forNumber(BitcoinV2.InputSelector.UseAll_VALUE))
            .setFixedDustThreshold(546.toLong())
        for (utx in utxos) {
            val txHash = Numeric.hexStringToByteArray(utx["txid"] as String)
            txHash.reverse()
            val txScript = Numeric.hexStringToByteArray(utx["script"] as String)
            val witnessScript = Numeric.hexStringToByteArray(utx["witnessValue"] as String)
            val inputV2 = BitcoinV2.Input.newBuilder()
                .setOutPoint(
                    Utxo.OutPoint.newBuilder()
                        .setHash(ByteString.copyFrom(txHash))
                        .setVout(utx["vout"] as Int)
                        .build()
                )
                .setSequence(BitcoinV2.Input.Sequence.newBuilder().setSequence(Int.MAX_VALUE))
                .setValue((utx["value"] as String).toLong())
                .setSighashType(BitcoinSigHashType.ALL.value())
                .setScriptData(ByteString.copyFrom(witnessScript)).build()
            transactionV2.addInputs(inputV2)
        }
        val outputV2 = BitcoinV2.Output.newBuilder()
            .setToAddress(txData["toAddress"] as String)
            .setValue(amount).build()
        transactionV2.setMaxAmountOutput(outputV2)
        val signingInput = BitcoinV2.SigningInput.newBuilder()
            .setBuilder(transactionV2)
            .setChainInfo(
                BitcoinV2.ChainInfo.newBuilder()
                    .setP2PkhPrefix(111)
                    .setP2ShPrefix(196)
                    .setHrp("tb")
            )
        val legacySigningInput = Bitcoin.SigningInput.newBuilder()
            .setSigningV2(signingInput)
        val preImageHashes = TransactionCompiler.preImageHashes(CoinType.BITCOIN, legacySigningInput.build().toByteArray())
        val preSigningOutput: Bitcoin.PreSigningOutput = Bitcoin.PreSigningOutput.parseFrom(preImageHashes)
        val signatureVec = DataVector()
        val pubkeyVec = DataVector()
        for (h in preSigningOutput.hashPublicKeysList) {
            val preImageHash = h.dataHash.toByteArray()
            val signature = privateKey.signAsDER(preImageHash)

            val publicKey = privateKey.getPublicKeySecp256k1(true)

            signatureVec.add(signature)
            pubkeyVec.add(publicKey.data())
        }
        val finalTx = TransactionCompiler.compileWithSignatures(
            CoinType.BITCOIN,
            preImageHashes,
            signatureVec,
            pubkeyVec
        )
        return Numeric.toHexString(finalTx)
    }

    private fun signBitcoinTransactionMaxValue(wallet: HDWallet?, path: String, txData: Map<String, Any>, coinType: CoinType, pk: PrivateKey?): String {
        val privateKey = pk ?: wallet!!.getKey(coinType, path)
        val utxos: List<Map<String, Any>> = txData["utxo"] as List<Map<String, Any>>
        val useMaxAmount: Boolean = txData["max"] as Boolean
        val amount: Long = (txData["amount"] as Number).toLong()

        val input = Bitcoin.SigningInput.newBuilder()
            .setByteFee((txData["byteFee"] as Number).toLong())
            .setChangeAddress(txData["changeAddress"] as String)
            .setToAddress(txData["toAddress"] as String)
            .setCoinType(coinType.value())
            .setHashType(BitcoinScript.hashTypeForCoin(coinType))
            .addPrivateKey(ByteString.copyFrom(privateKey.data()))
        if (useMaxAmount) {
            input.setUseMaxAmount(true)
        } else {
            input.setAmount(amount)
        }
        for (utx in utxos) {
            val txHash = Numeric.hexStringToByteArray(utx["txid"] as String)
            txHash.reverse()
            val outPoint = Bitcoin.OutPoint.newBuilder()
                .setHash(ByteString.copyFrom(txHash))
                .setIndex(utx["vout"] as Int)
                .setSequence(Long.MAX_VALUE.toInt())
                .build()
            val txScript = Numeric.hexStringToByteArray(utx["script"] as String)
            val utxo = Bitcoin.UnspentTransaction.newBuilder()
                .setAmount((utx["value"] as String).toLong())
                .setOutPoint(outPoint)
                .setScript(ByteString.copyFrom(txScript))
                .build()
            input.addUtxo(utxo)
        }
        val plan = AnySigner.plan(input.build(), coinType, Bitcoin.TransactionPlan.parser())
        val output = AnySigner.sign(input.setPlan(plan).build(), coinType, Bitcoin.SigningOutput.parser())
        val size = output.encoded.toByteArray().size
        return size.toString()
    }

    private fun signFilecoinTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val privateKey = pk ?: wallet!!.getKey(CoinType.FILECOIN, path)
        val gasLimit: String = txData["gasLimit"] as String
        val gasFeeCap: String = txData["gasFeeCap"] as String
        val gasPremium: String = txData["gasPremium"] as String
        val nonce: String = txData["nonce"] as String
        val toAddress: String = txData["toAddress"] as String
        val amount: String = txData["amount"] as String
        val input = Filecoin.SigningInput.newBuilder()
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .setTo(toAddress)
            .setNonce(nonce.toLong())
            .setValue(ByteString.copyFrom(BigInteger((amount), 16).toByteArray()))
            .setGasLimit(gasLimit.toLong())
            .setGasFeeCap(ByteString.copyFrom(BigInteger((gasFeeCap), 16).toByteArray()))
            .setGasPremium(ByteString.copyFrom(BigInteger(gasPremium, 16).toByteArray()))

        val result = AnySigner.sign(input.build(), CoinType.FILECOIN, Filecoin.SigningOutput.parser())
        return result.json

    }

    private fun signAlgorandTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String {
        val privateKey = pk ?: wallet!!.getKey(CoinType.ALGORAND, path)
        val type: String = txData["type"] as String
        val amount: Long = (txData["amount"] as String).toLong()
        val genesisHash: ByteArray? = aBase64.decode(txData["genesisHash"] as String, 16)
        val fee: Long = (txData["fee"] as Int).toLong()
        val round: Long = (txData["round"] as Int).toLong()
        val toAddress: String = txData["toAddress"] as String
        val input = Algorand.SigningInput.newBuilder()
            .setGenesisId(txData["genesisId"] as String)
            .setGenesisHash(ByteString.copyFrom(genesisHash))
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .setFirstRound(round)
            .setLastRound(round + fee)
            .setFee(fee)

        when (type) {
            "Asset" -> {
                val assetId: Long = (txData["assetId"] as String).toLong()
                input.setAssetTransfer(Algorand.AssetTransfer.newBuilder()
                    .setAmount(amount)
                    .setAssetId(assetId)
                    .setToAddress(toAddress)
                )
            }
            "Add" -> {
                val assetId: Long = (txData["assetId"] as String).toLong()
                input.setAssetOptIn(
                    Algorand.AssetOptIn.newBuilder().setAssetId(assetId)
                )
            }
            else -> {
                input.setTransfer(Algorand.Transfer.newBuilder()
                    .setAmount(amount)
                    .setToAddress(toAddress))

            }
        }

        val result = AnySigner.sign(input.build(), CoinType.ALGORAND, Algorand.SigningOutput.parser())
        val rValue: Map<String, Any> = mapOf("result" to true, "signHash" to Numeric.toHexString(result.encoded.toByteArray()))
        return JSONObject(rValue).toString()
    }

    private fun signPOLKADOTTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, coinType: CoinType, pk: PrivateKey?): String {
        val privateKey = pk ?: wallet!!.getKey(coinType, path)
        val amount: String = txData["amount"] as String
        val genesisHash: ByteArray = Numeric.hexStringToByteArray(txData["genesisHash"] as String)
        val blockHash: ByteArray = Numeric.hexStringToByteArray(txData["blockHash"] as String)
        val nonce: Long = (txData["nonce"] as Int).toLong()
        val specVersion: Int = txData["specVersion"] as Int
        val transactionVersion: Int = txData["transactionVersion"] as Int
        val toAddress: String = txData["toAddress"] as String
        val blockNumber: Long = (txData["blockNumber"] as Int).toLong()
        val input = Polkadot.SigningInput.newBuilder()
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .setGenesisHash(ByteString.copyFrom(genesisHash))
            .setBlockHash(ByteString.copyFrom(blockHash))
            .setNonce(nonce)
            .setSpecVersion(specVersion)
            .setTransactionVersion(transactionVersion)
            .setNetwork(coinType.ss58Prefix())
            .setMultiAddress(true)
            .setEra(
                Polkadot.Era.newBuilder()
                    .setBlockNumber(blockNumber)
                    .setPeriod(64).build()
            )
            .setBalanceCall(
                Polkadot.Balance.newBuilder()
                    .setTransfer(
                        Polkadot.Balance.Transfer.newBuilder()
                            .setValue(ByteString.copyFrom(Numeric.hexStringToByteArray(amount)))
                            .setToAddress(toAddress)
                    ).build()
            ).build()
        val output = AnySigner.sign(input, coinType, Polkadot.SigningOutput.parser())
        return Numeric.toHexString(output.encoded.toByteArray())
    }

    private fun signAptosTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String {
        val privateKey = pk ?: wallet!!.getKey(CoinType.APTOS, path)

        val gasUnitPrice: Long = txData["gasUnitPrice"] as Long
        val maxGasAmount: Long = txData["maxGasAmount"] as Long
        val expirationTimestampSecs: Long = txData["expirationTimestampSecs"] as Long
        val toAddress: String = txData["toAddress"] as String
        val senderAddress: String = txData["fromAddress"] as String
        val amount: Long = txData["amount"] as Long
        val chainId: Int = txData["chainId"] as Int
        val sequenceNumber: Long = txData["SequenceNumber"] as Long
        val contractAddress: String = txData["contractAddress"] as String
        val contractModule: String = txData["contractModule"] as String
        val contractName: String = txData["contractName"] as String

        val input = Aptos.SigningInput.newBuilder()
            .setChainId(chainId)
            .setSender(senderAddress)
            .setSequenceNumber(sequenceNumber)
            .setGasUnitPrice(gasUnitPrice)
            .setMaxGasAmount(maxGasAmount)
            .setExpirationTimestampSecs(expirationTimestampSecs)
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
        if (contractAddress == "") {
            val transfer = Aptos.TransferMessage.newBuilder()
                .setAmount(amount)
                .setTo(toAddress).build()
            input.transfer = transfer
        } else {
            val structTag = Aptos.StructTag.newBuilder()
                .setAccountAddress(contractAddress)
                .setModule(contractModule)
                .setName(contractName)
                .build()
            val transfer = Aptos.TokenTransferCoinsMessage.newBuilder()
                .setAmount(amount)
                .setTo(toAddress)
                .setFunction(structTag)
                .build()
            input.tokenTransferCoins = transfer
        }

        val output = AnySigner.sign(input.build(), CoinType.APTOS, Aptos.SigningOutput.parser())
        return Numeric.toHexString(output.encoded.toByteArray())
    }

    private fun signSuiTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String {
        val privateKey = pk ?: wallet!!.getKey(CoinType.SUI, path)

        val referenceGasPrice: Long = (txData["referenceGasPrice"] as Number).toLong()
        val gasBudget: Long = (txData["gasBudget"] as Number).toLong()
        val toAddress: String = txData["toAddress"] as String
        val amount: Long = (txData["amount"] as Number).toLong()
        val utxos: List<Map<String, Any>> = txData["utxo"] as List<Map<String, Any>>

        val paySui = Sui.PaySui.newBuilder()
            .addRecipients(toAddress)
            .addAmounts(amount)
        for (utx in utxos) {
            paySui.addInputCoins(
                Sui.ObjectRef.newBuilder()
                    .setObjectId(utx["objectId"] as String)
                    .setVersion((utx["version"] as String).toLong())
                    .setObjectDigest(utx["objectDigest"] as String)
            )
        }

        val signingInput = Sui.SigningInput.newBuilder()
            .setPaySui(paySui)
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .setGasBudget(gasBudget)
            .setReferenceGasPrice(referenceGasPrice)
            .build()

        val output = AnySigner.sign(signingInput, CoinType.SUI, Sui.SigningOutput.parser())
        return output.unsignedTx
    }

    private fun signTonTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val privateKey = pk ?: wallet!!.getKey(CoinType.TON, path)

        val expireAt: Int = txData["expireAt"] as Int
        val sequenceNumber: Int = txData["sequenceNumber"] as Int
        val toAddress: String = txData["toAddress"] as String
        val fromAddress: String = txData["fromAddress"] as String
        val amount: ByteArray = Numeric.hexStringToByteArray(txData["amount"] as String)
        val contractAddress: String = txData["contractAddress"] as String
        val maxGasAmount: ByteArray = Numeric.hexStringToByteArray(txData["maxGasAmount"] as String)
        if (contractAddress == "") {
            val transfer = TheOpenNetwork.Transfer.newBuilder()
                .setDest(toAddress)
                .setAmount(ByteString.copyFrom(amount))
                .setMode(TheOpenNetwork.SendMode.PAY_FEES_SEPARATELY_VALUE or TheOpenNetwork.SendMode.IGNORE_ACTION_PHASE_ERRORS_VALUE)
                .setBounceable(true)
                .setComment("")
                .build()

            val input = TheOpenNetwork.SigningInput.newBuilder()
                .setPrivateKey(ByteString.copyFrom(privateKey.data()))
                .addMessages(transfer)
                .setSequenceNumber(sequenceNumber)
                .setExpireAt(expireAt)
                .setWalletVersion(TheOpenNetwork.WalletVersion.WALLET_V4_R2)
                .build()

            val output = AnySigner.sign(input, CoinType.TON, TheOpenNetwork.SigningOutput.parser())
            return aBase64.encodeToString(output.encoded.toByteArray(), aBase64.NO_WRAP)
        } else {
            val jettonTransfer = TheOpenNetwork.JettonTransfer.newBuilder()
                .setJettonAmount(ByteString.copyFrom(amount))
                .setToOwner(toAddress)
                .setResponseAddress(fromAddress)
                .setForwardAmount(ByteString.copyFrom(maxGasAmount))
                .build()

            val transfer = TheOpenNetwork.Transfer.newBuilder()
                .setDest(contractAddress)
                .setAmount(ByteString.copyFrom(amount))
                .setMode(TheOpenNetwork.SendMode.PAY_FEES_SEPARATELY_VALUE or TheOpenNetwork.SendMode.IGNORE_ACTION_PHASE_ERRORS_VALUE)
                .setComment("")
                .setBounceable(true)
                .setJettonTransfer(jettonTransfer)
                .build()

            val input = TheOpenNetwork.SigningInput.newBuilder()
                .setPrivateKey(ByteString.copyFrom(privateKey.data()))
                .addMessages(transfer)
                .setSequenceNumber(sequenceNumber)
                .setExpireAt(expireAt)
                .setWalletVersion(TheOpenNetwork.WalletVersion.WALLET_V4_R2)
                .build()

            val output = AnySigner.sign(input, CoinType.TON, TheOpenNetwork.SigningOutput.parser())
            return aBase64.encodeToString(output.encoded.toByteArray(), aBase64.NO_WRAP)
        }
    }

    private fun signStellarTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val privateKey = pk ?: wallet!!.getKey(CoinType.STELLAR, path)

        val toAddress: String = txData["toAddress"] as String
        val amount: Long = (txData["amount"] as String).toLong()
        val fee: Int = (txData["fee"] as String).toInt()
        val sequence: Long = (txData["sequence"] as String).toLong()
        val memo: String? = txData["memo"] as String?
        val passphrase: String = txData["passphrase"] as String? ?: "Public Global Stellar Network ; September 2015"

        val opPayment = Stellar.OperationPayment.newBuilder()
            .setDestination(toAddress)
            .setAmount(amount)
            .build()

        val inputBuilder = Stellar.SigningInput.newBuilder()
            .setPassphrase(passphrase)
            .setFee(fee)
            .setSequence(sequence)
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .setOpPayment(opPayment)

        if (!memo.isNullOrEmpty()) {
            inputBuilder.setMemoText(Stellar.MemoText.newBuilder().setText(memo).build())
        }

        val output = AnySigner.sign(inputBuilder.build(), CoinType.STELLAR, Stellar.SigningOutput.parser())
        return output.signature
    }

    private fun signVeChainTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val privateKey = pk ?: wallet!!.getKey(CoinType.VECHAIN, path)

        val toAddress: String = txData["toAddress"] as String
        val amount: ByteArray = Numeric.hexStringToByteArray(txData["amount"] as String)
        val chainTag: Int = (txData["chainTag"] as String).toInt()
        val blockRef: Long = (txData["blockRef"] as String).toLong()
        val expiration: Int = (txData["expiration"] as String).toInt()
        val gas: Long = (txData["gas"] as String).toLong()
        val nonce: Long = (txData["nonce"] as String).toLong()
        val data: String = txData["data"] as String? ?: ""

        val clause = VeChain.Clause.newBuilder()
            .setTo(toAddress)
            .setValue(ByteString.copyFrom(amount))
            .setData(ByteString.copyFrom(Numeric.hexStringToByteArray(data)))
            .build()

        val input = VeChain.SigningInput.newBuilder()
            .setChainTag(chainTag)
            .setBlockRef(blockRef)
            .setExpiration(expiration)
            .addClauses(clause)
            .setGas(gas)
            .setNonce(nonce)
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .build()

        val output = AnySigner.sign(input, CoinType.VECHAIN, VeChain.SigningOutput.parser())
        return Numeric.toHexString(output.encoded.toByteArray())
    }

    private fun signNearTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val privateKey = pk ?: wallet!!.getKey(CoinType.NEAR, path)

        val signerId: String = txData["signerId"] as String
        val receiverId: String = txData["receiverId"] as String
        val nonce: Long = (txData["nonce"] as String).toLong()
        val blockHash: String = txData["blockHash"] as String
        val amount: String = txData["amount"] as String

        val transfer = NEAR.Transfer.newBuilder()
            .setDeposit(ByteString.copyFrom(Numeric.hexStringToByteArray(amount)))
            .build()

        val action = NEAR.Action.newBuilder()
            .setTransfer(transfer)
            .build()

        val input = NEAR.SigningInput.newBuilder()
            .setSignerId(signerId)
            .setReceiverId(receiverId)
            .setNonce(nonce)
            .setBlockHash(ByteString.copyFrom(Numeric.hexStringToByteArray(blockHash)))
            .addActions(action)
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .build()

        val output = AnySigner.sign(input, CoinType.NEAR, NEAR.SigningOutput.parser())
        return aBase64.encodeToString(output.signedTransaction.toByteArray(), aBase64.NO_WRAP)
    }

    private fun signZilliqaTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val privateKey = pk ?: wallet!!.getKey(CoinType.ZILLIQA, path)

        val toAddress: String = txData["toAddress"] as String
        val amount: ByteArray = Numeric.hexStringToByteArray(txData["amount"] as String)
        val gasPrice: ByteArray = Numeric.hexStringToByteArray(txData["gasPrice"] as String)
        val gasLimit: Long = (txData["gasLimit"] as String).toLong()
        val nonce: Long = (txData["nonce"] as Int).toLong()
        val version: Int = txData["version"] as Int
        val code: String = txData["code"] as String? ?: ""
        val data: String = txData["data"] as String? ?: ""

        val transaction = Zilliqa.Transaction.newBuilder()
            .setTransfer(
                Zilliqa.Transaction.Transfer.newBuilder()
                    .setAmount(ByteString.copyFrom(amount))
            )
            .build()

        val input = Zilliqa.SigningInput.newBuilder()
            .setVersion(version)
            .setNonce(nonce)
            .setTo(toAddress)
            .setGasPrice(ByteString.copyFrom(gasPrice))
            .setGasLimit(gasLimit)
            .setTransaction(transaction)
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .build()

        val output = AnySigner.sign(input, CoinType.ZILLIQA, Zilliqa.SigningOutput.parser())
        return output.json
    }

    private fun signThetaTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val privateKey = pk ?: wallet!!.getKey(CoinType.THETA, path)

        val toAddress: String = txData["toAddress"] as String
        val thetaAmount: ByteArray = Numeric.hexStringToByteArray(txData["thetaAmount"] as String? ?: "0x0")
        val tfuelAmount: ByteArray = Numeric.hexStringToByteArray(txData["tfuelAmount"] as String)
        val sequence: Long = (txData["sequence"] as String).toLong()
        val fee: ByteArray = Numeric.hexStringToByteArray(txData["fee"] as String)

        val input = Theta.SigningInput.newBuilder()
            .setToAddress(toAddress)
            .setThetaAmount(ByteString.copyFrom(thetaAmount))
            .setTfuelAmount(ByteString.copyFrom(tfuelAmount))
            .setSequence(sequence)
            .setFee(ByteString.copyFrom(fee))
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .build()

        val output = AnySigner.sign(input, CoinType.THETA, Theta.SigningOutput.parser())
        return Numeric.toHexString(output.encoded.toByteArray())
    }

    private fun signCardanoTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val privateKey = pk ?: wallet!!.getKey(CoinType.CARDANO, path)

        val toAddress: String = txData["toAddress"] as String
        val amount: Long = (txData["amount"] as String).toLong()
        val ttl: Long = (txData["ttl"] as String).toLong()
        val utxos: List<Map<String, Any>> = txData["utxos"] as List<Map<String, Any>>

        val inputBuilder = Cardano.SigningInput.newBuilder()
            .setTtl(ttl)

        inputBuilder.addPrivateKey(ByteString.copyFrom(privateKey.data()))

        for (utxo in utxos) {
            val txHash: String = utxo["txHash"] as String
            val outputIndex: Long = (utxo["outputIndex"] as Number).toLong()
            val utxoAmount: Long = (utxo["amount"] as String).toLong()
            val utxoAddress: String = utxo["address"] as String

            inputBuilder.addUtxos(
                Cardano.TxInput.newBuilder()
                    .setOutPoint(
                        Cardano.OutPoint.newBuilder()
                            .setTxHash(ByteString.copyFrom(Numeric.hexStringToByteArray(txHash)))
                            .setOutputIndex(outputIndex)
                    )
                    .setAddress(utxoAddress)
                    .setAmount(utxoAmount)
            )
        }

        val transferMsg = Cardano.Transfer.newBuilder()
            .setToAddress(toAddress)
            .setChangeAddress(CoinType.CARDANO.deriveAddress(privateKey))
            .setAmount(amount)
            .setUseMaxAmount(false)
            .build()

        inputBuilder.setTransferMessage(transferMsg)

        val output = AnySigner.sign(inputBuilder.build(), CoinType.CARDANO, Cardano.SigningOutput.parser())

        if (output.errorMessage.isNotEmpty()) {
            return null
        }

        return Numeric.toHexString(output.encoded.toByteArray())
    }

    private fun signMultiversXTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>, pk: PrivateKey?): String? {
        val privateKey = pk ?: wallet!!.getKey(CoinType.MULTIVERSX, path)

        val toAddress: String = txData["toAddress"] as String
        val amount: String = txData["amount"] as String
        val nonce: Long = (txData["nonce"] as String).toLong()
        val gasPrice: Long = (txData["gasPrice"] as String).toLong()
        val gasLimit: Long = (txData["gasLimit"] as String).toLong()
        val data: String = txData["data"] as String? ?: ""
        val chainId: String = txData["chainId"] as String? ?: "1"
        val version: Int = (txData["version"] as String? ?: "1").toInt()

        val sender = CoinType.MULTIVERSX.deriveAddress(privateKey)

        val genericAction = MultiversX.GenericAction.newBuilder()
            .setAccounts(
                MultiversX.Accounts.newBuilder()
                    .setSenderNonce(nonce)
                    .setSender(sender)
                    .setReceiver(toAddress)
            )
            .setValue(amount)
            .setData(data)
            .setVersion(version)

        val input = MultiversX.SigningInput.newBuilder()
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .setGasPrice(gasPrice)
            .setGasLimit(gasLimit)
            .setChainId(chainId)
            .setGenericAction(genericAction)
            .build()

        val output = AnySigner.sign(input, CoinType.MULTIVERSX, MultiversX.SigningOutput.parser())
        return output.encoded
    }
}
