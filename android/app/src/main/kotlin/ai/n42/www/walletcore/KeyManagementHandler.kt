package ai.n42.www.walletcore

import android.util.Base64 as aBase64
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import wallet.core.jni.BitcoinAddress
import wallet.core.jni.CoinType
import wallet.core.jni.Derivation
import wallet.core.jni.HDWallet
import wallet.core.jni.PrivateKey
import wallet.core.jni.PublicKey
import wallet.core.jni.Account
import wallet.core.jni.StoredKey
import ai.n42.www.Numeric

/**
 * Handles all key management, mnemonic, address generation, and keystore operations.
 */
class KeyManagementHandler {

    fun handleGenerateMnemonic(call: MethodCall, result: MethodChannel.Result) {
        val passphrase: String? = call.argument("passphrase")
        var leng: Int? = call.argument("length")
        if (leng == null) {
            leng = 128
        }
        val wallet = HDWallet(leng, passphrase)
        result.success(wallet.mnemonic())
    }

    fun handleCheckMnemonic(call: MethodCall, result: MethodChannel.Result) {
        val mnemonic: String? = call.argument("mnemonic")
        val passphrase: String? = call.argument("passphrase")
        if (mnemonic != "") {
            val wallet: HDWallet? = HDWallet(mnemonic, passphrase)
            if (wallet != null) {
                result.success(true)
            } else {
                result.error("no_wallet",
                    "Could not generate wallet, why?", null)
            }
        } else {
            result.error("arguments_null", "[mnemonic] cannot be null", null)
        }
    }

    fun handleGenerateAddress(call: MethodCall, result: MethodChannel.Result) {
        val path: String? = call.argument("path")
        val coin: String? = call.argument("coin")
        val mnemonic: String? = call.argument("mnemonic")
        val passphrase: String? = call.argument("passphrase")
        val addressType: String? = call.argument("addressType")
        val pkStr: String? = call.argument("pk")
        val isImport: String? = call.argument("isImport")
        val isTest: String? = call.argument("isTest")
        if (path != null && coin != null && mnemonic != null && pkStr != null) {

            if (mnemonic != "") {
                val wallet = HDWallet(mnemonic, passphrase)
                val address: Map<String, String?>? = generateAddress(wallet, path, coin, addressType!!, isTest!!)
                if (address == null) result.error("address_null", "failed to generate address", null) else result.success(address)
            } else if (pkStr != "") {
                val pk = if (isImport == "true") {
                    Numeric.hexStringToByteArray(pkStr)
                } else {
                    aBase64.decode(pkStr, 64)
                }
                val privateKey: PrivateKey? = getPrivateKeyFromBytes(pk)
                if (privateKey == null) {
                    result.error("privateKey", "failed to privateKey", null)
                } else {
                    val address: Map<String, String?>? = generateAddressPK(privateKey, coin, addressType!!, null, isTest!!)
                    if (address == null) result.error("address_null", "failed to generate address", null) else result.success(address)
                }
            } else {
                result.error("arguments_null", "[privateKey] cannot be null", null)
            }

        } else {
            result.error("arguments_null", "[path] and [coin] and [mnemonic] and [privateKey] cannot be null", null)
        }
    }

    fun handleValidateAddress(call: MethodCall, result: MethodChannel.Result) {
        val address: String? = call.argument("address")
        val coin: String? = call.argument("coin")
        if (address != null && coin != null) {
            val isValid: Boolean = validateAddress(coin, address)
            result.success(isValid)
        } else {
            result.error("arguments_null", "$address and $coin cannot be null", null)
        }
    }

    fun handleGetPublicKey(call: MethodCall, result: MethodChannel.Result) {
        val path: String? = call.argument("path")
        val coin: String? = call.argument("coin")
        val mnemonic: String? = call.argument("mnemonic")
        val passphrase: String? = call.argument("passphrase")
        val pkStr: String? = call.argument("pk")
        if (path != null && coin != null) {
            val wallet: HDWallet?
            if (mnemonic != "") {
                wallet = HDWallet(mnemonic, passphrase)
            } else if (pkStr != "") {
                val pk: ByteArray = aBase64.decode(pkStr, 64)
                wallet = HDWallet(pk, passphrase)
            } else {
                wallet = null
            }
            if (wallet != null) {
                val publicKey: String? = getPublicKey(wallet, coin, path)
                if (publicKey == null) result.error("address_null", "failed to generate address", null) else result.success(publicKey)
            } else {
                result.error("no_wallet",
                    "Could not generate wallet, why?", null)
            }
        } else {
            result.error("arguments_null", "[path] and [coin] and [mnemonic] cannot be null", null)
        }
    }

    fun handleGetPrivateKey(call: MethodCall, result: MethodChannel.Result) {
        val path: String? = call.argument("path")
        val coin: String? = call.argument("coin")
        val mnemonic: String? = call.argument("mnemonic")
        val passphrase: String? = call.argument("passphrase")
        if (path != null && coin != null && mnemonic != null) {
            val wallet: HDWallet? = if (mnemonic != "") {
                HDWallet(mnemonic, passphrase)
            } else {
                null
            }
            if (wallet != null) {
                val privateKey: String? = getPrivateKeyString(wallet, coin, path)
                if (privateKey == null) result.error("address_null", "failed to generate address", null) else result.success(privateKey)
            } else {
                result.error("no_wallet",
                    "Could not generate wallet, why?", null)
            }
        } else {
            result.error("arguments_null", "[path] and [coin] and [mnemonic] cannot be null", null)
        }
    }

    fun handleGetPrivateKeyAndPublicKey(call: MethodCall, result: MethodChannel.Result) {
        val path: String? = call.argument("path")
        val coin: String? = call.argument("coin")
        val mnemonic: String? = call.argument("mnemonic")
        val pkStr: String? = call.argument("privateKey")
        val passphrase: String? = call.argument("passphrase")
        if (path != null && coin != null) {
            val wallet: HDWallet?
            if (mnemonic != "") {
                wallet = HDWallet(mnemonic, passphrase)
                val privateKey: String? = getPrivateKeyString(wallet, coin, path)
                val publicKey: String? = getPublicKey(wallet, coin, path)
                if (privateKey == null) result.error("address_null", "failed to generate address", null) else {
                    val rValue: Map<String, String?> = mapOf("publicKey" to publicKey, "privateKey" to privateKey)
                    result.success(JSONObject(rValue).toString())
                }
            } else if (pkStr != "") {
                val pk: ByteArray = aBase64.decode(pkStr, 64)
                wallet = HDWallet(pk, passphrase)
                val privateKey: String? = getPrivateKeyString(wallet, coin, path)
                val publicKey: String? = getPublicKey(wallet, coin, path)
                val rValue: Map<String, String?> = mapOf("publicKey" to publicKey, "privateKey" to privateKey)
                result.success(JSONObject(rValue).toString())
            } else {
                result.error("no_wallet",
                    "Could not generate wallet, why?", null)
            }
        } else {
            result.error("arguments_null", "[path] and [coin] and [mnemonic] cannot be null", null)
        }
    }

    fun handleGetKeyStore(call: MethodCall, result: MethodChannel.Result) {
        val path: String? = call.argument("path")
        val coin: String? = call.argument("coin")
        val mnemonic: String? = call.argument("mnemonic")
        val passphrase: String? = call.argument("passphrase")
        val addressType: String? = call.argument("addressType")
        val pkStr: String? = call.argument("pk")
        if (path != null && coin != null && passphrase != null && addressType != null) {

            val wallet: HDWallet?
            if (mnemonic == "") {
                val pk: ByteArray = aBase64.decode(pkStr, 64)
                wallet = HDWallet(pk, "")
            } else {
                wallet = HDWallet(mnemonic, "")
            }
            val keystore: String = getKeyStore(wallet, path, coin, passphrase, addressType)
            if (keystore == "") result.error("KeyStore_error", "failed to get KeyStore", null) else result.success(keystore)
        } else {
            result.error("arguments_null", "[path] and [coin] and [mnemonic] and [passphrase] cannot be null", null)
        }
    }

    fun handleGetWalletInfoWithKeyStore(call: MethodCall, result: MethodChannel.Result) {
        val keyStore: String? = call.argument("keyStore")
        val coin: String? = call.argument("coin")
        val passphrase: String? = call.argument("passphrase")
        if (keyStore != null && coin != null && passphrase != null) {
            val keystore: Map<String, Any?> = getWalletInfoWithKeyStore(keyStore, passphrase, coin)
            result.success(keystore)
        } else {
            result.error("arguments_null", "[keyStore] and [coin] and [passphrase] cannot be null", null)
        }
    }

    // ── Internal helper methods ──────────────────────────────────────────

    fun getPrivateKeyFromBytes(pk: ByteArray): PrivateKey? {
        return try {
            PrivateKey(pk)
        } catch (err: Exception) {
            null
        }
    }

    private fun getKeyStore(wallet: HDWallet, path: String, coin: String, passphrase: String, addressType: String): String {
        val coinType: CoinType = getCoinTypeWithCoinString(coin)
        val pk: PrivateKey = wallet.getKey(coinType, path)
        val address = when (coin) {
            "BTC" -> {
                val privateKey = wallet.getKey(CoinType.BITCOIN, path)
                val publicKey = privateKey.getPublicKeySecp256k1(true)
                if (addressType == "legacy") {
                    val address = BitcoinAddress(publicKey, CoinType.BITCOIN.p2pkhPrefix())
                    address.description()
                } else {
                    CoinType.BITCOIN.deriveAddress(privateKey)
                }
            }
            "LTC" -> {
                val privateKey = wallet.getKey(CoinType.LITECOIN, path)
                val publicKey = privateKey.getPublicKeySecp256k1(true)
                if (addressType == "legacy") {
                    val address = BitcoinAddress(publicKey, CoinType.LITECOIN.p2pkhPrefix())
                    address.description()
                } else {
                    CoinType.LITECOIN.deriveAddress(privateKey)
                }
            }
            else -> ""
        }
        val key = StoredKey.importPrivateKey(pk.data(), coinType.name, passphrase.encodeToByteArray(), coinType)
        if (address != "") {
            val account: Account = key.account(0)
            key.removeAccountForCoin(key.account(0).coin())
            key.addAccount(address, account.coin(), path, account.publicKey(), account.extendedPublicKey())
        }
        val json: String = key.exportJSON().decodeToString()
        return json
    }

    private fun getWalletInfoWithKeyStore(keyStore: String, passphrase: String, coinType: String): Map<String, Any?> {
        val ksArray: ByteArray = keyStore.encodeToByteArray()
        val pwArray: ByteArray = passphrase.toByteArray()
        val storedKey = StoredKey.importJSON(ksArray)
        val coint: CoinType = storedKey.account(0).coin()
        val privateKey: PrivateKey = storedKey.privateKey(coint, pwArray)
        val path: String = storedKey.account(0).derivationPath()
        var addressType = "legacy"
        val chainType = getChainTypeWithCoinString(coinType)
        var isBitcoin = false
        if (chainType == "Bitcoin") {
            isBitcoin = true
        }
        if (isBitcoin) {
            val list84: List<String> = path.split("84")
            if (list84.size > 1) {
                addressType = "segwit"
            }
        }
        val addressMap: Map<String, String?>? = generateAddressPK(privateKey, coinType, addressType, coint, "false")

        val rMap: Map<String, Any?> = mapOf("address" to addressMap, "privateKey" to aBase64.encodeToString(privateKey.data(), 64), "addressType" to addressType)
        return rMap
    }

    private fun generateAddress(wallet: HDWallet, path: String, coin: String, addressType: String, isTest: String): Map<String, String?>? {
        val coinType: CoinType = getCoinTypeWithCoinString(coin)
        val privateKey = wallet.getKey(coinType, path)
        return generateAddressPK(privateKey, coin, addressType, coinType, isTest)
    }

    fun generateAddressPK(privateKey: PrivateKey, coin: String, addressType: String, coinType: CoinType?, isTest: String): Map<String, String?>? {
        val chainType: String = getChainTypeWithCoinString(coin)
        var cType: CoinType? = coinType
        if (cType == null) {
            cType = getCoinTypeWithCoinString(coin)
        }
        if (cType == null) {
            return null
        }
        if (chainType == "Bitcoin") {
            val publicKey = privateKey.getPublicKeySecp256k1(true)
            val address = BitcoinAddress(publicKey, cType.p2shPrefix())
            if (coin == "BCH" || coin == "DOGE" || coin == "DASH") {
                return mapOf("legacy" to address.description())
            } else {
                val btcAddr: String = if (isTest == "true") {
                    cType.deriveAddressFromPublicKeyAndDerivation(publicKey, Derivation.BITCOINTESTNET)
                } else {
                    cType.deriveAddress(privateKey)
                }
                return mapOf("legacy" to address.description(), "segwit" to btcAddr)
            }
        } else {
            return mapOf("legacy" to cType.deriveAddress(privateKey))
        }
    }

    private fun validateAddress(coin: String, address: String): Boolean {
        val coinType: CoinType = getCoinTypeWithCoinString(coin)
        return coinType.validate(address)
    }

    fun getPublicKey(wallet: HDWallet, coin: String, path: String): String? {
        val chainType: String = getChainTypeWithCoinString(coin)
        if (chainType == "") {
            return null
        }
        val coinType: CoinType = getCoinTypeWithCoinString(coin)
        val privateKey = wallet.getKey(coinType, path)
        val publicKey: PublicKey? = when (chainType) {
            "Bitcoin" -> {
                privateKey.getPublicKeySecp256k1(true)
            }
            "Ethereum" -> {
                privateKey.getPublicKeySecp256k1(true)
            }
            "Tron" -> {
                privateKey.getPublicKeySecp256k1(true)
            }
            "Tezos" -> {
                privateKey.publicKeyEd25519
            }
            "Solana" -> {
                privateKey.publicKeyEd25519
            }
            "Ripple" -> {
                privateKey.getPublicKeySecp256k1(true)
            }
            "Cosmos" -> {
                privateKey.getPublicKeySecp256k1(true)
            }
            "Filecoin" -> {
                privateKey.getPublicKeySecp256k1(true)
            }
            "Stellar" -> {
                privateKey.publicKeyEd25519
            }
            "VeChain" -> {
                privateKey.getPublicKeySecp256k1(true)
            }
            "Near" -> {
                privateKey.publicKeyEd25519
            }
            "Zilliqa" -> {
                privateKey.getPublicKeySecp256k1(true)
            }
            "Theta" -> {
                privateKey.getPublicKeySecp256k1(true)
            }
            "Cardano" -> {
                privateKey.publicKeyEd25519Cardano
            }
            "MultiversX" -> {
                privateKey.publicKeyEd25519
            }
            else -> null
        }
        return if (publicKey == null) {
            null
        } else {
            aBase64.encodeToString(publicKey.data(), aBase64.NO_WRAP)
        }
    }

    fun getPrivateKeyString(wallet: HDWallet, coin: String, path: String): String? {
        val coinType: CoinType = getCoinTypeWithCoinString(coin)
        val privateKey = wallet.getKey(coinType, path)
        return aBase64.encodeToString(privateKey.data(), aBase64.NO_WRAP)
    }

    // ── Coin type / chain type mapping (shared utilities) ────────────────

    fun getCoinTypeWithCoinString(coin: String): CoinType {
        return when (coin) {
            "BTC" -> CoinType.BITCOIN
            "LTC" -> CoinType.LITECOIN
            "DOGE" -> CoinType.DOGECOIN
            "DASH" -> CoinType.DASH
            "VIA" -> CoinType.VIACOIN
            "DGB" -> CoinType.DIGIBYTE
            "MONA" -> CoinType.MONACOIN
            "FIRO" -> CoinType.FIRO
            "BCH" -> CoinType.BITCOINCASH
            "BTG" -> CoinType.BITCOINGOLD
            "RVN" -> CoinType.RAVENCOIN
            "QTUM" -> CoinType.QTUM
            "XEC" -> CoinType.BITCOIN
            "ETH" -> CoinType.ETHEREUM
            "ETC" -> CoinType.ETHEREUMCLASSIC
            "HT" -> CoinType.ECOCHAIN
            "XDAI" -> CoinType.XDAI
            "N" -> CoinType.ETHEREUM
            "MATIC" -> CoinType.POLYGON
            "AVAX" -> CoinType.AVALANCHECCHAIN
            "CELO" -> CoinType.ETHEREUM
            "BNB" -> CoinType.ETHEREUM
            "FTM" -> CoinType.FANTOM
            "POA" -> CoinType.POANETWORK
            "CLO" -> CoinType.CALLISTO
            "VIC" -> CoinType.VICTION
            "TT" -> CoinType.THUNDERCORE
            "GO" -> CoinType.GOCHAIN
            "WAN" -> CoinType.WANCHAIN
            "OKT" -> CoinType.ETHEREUM
            "MTR" -> CoinType.ETHEREUM
            "KLAY" -> CoinType.ETHEREUM
            "GLMR" -> CoinType.ETHEREUM
            "MOVR" -> CoinType.ETHEREUM
            "EVMOS" -> CoinType.ETHEREUM
            "BOBA" -> CoinType.ETHEREUM
            "KCS" -> CoinType.ETHEREUM
            "KAVA" -> CoinType.ETHEREUM
            "CRO" -> CoinType.ETHEREUM
            "OP" -> CoinType.ETHEREUM
            "ARB" -> CoinType.ETHEREUM
            "AURORA" -> CoinType.ETHEREUM
            "METIS" -> CoinType.ETHEREUM
            "XTZ" -> CoinType.TEZOS
            "TRX" -> CoinType.TRON
            "SOL" -> CoinType.SOLANA
            "ALGO" -> CoinType.ALGORAND
            "XRP" -> CoinType.XRP
            "ATOM" -> CoinType.COSMOS
            "ZETA" -> CoinType.ETHEREUM
            "BASE" -> CoinType.BASE
            "FIL" -> CoinType.FILECOIN
            "DOT" -> CoinType.POLKADOT
            "ACA" -> CoinType.ACALA
            "KSM" -> CoinType.KUSAMA
            "APT" -> CoinType.APTOS
            "SUI" -> CoinType.SUI
            "TON" -> CoinType.TON
            "S" -> CoinType.ETHEREUM
            "XLM" -> CoinType.STELLAR
            "VET" -> CoinType.VECHAIN
            "ONE" -> CoinType.HARMONY
            "IOTX" -> CoinType.IOTEX
            "NEAR" -> CoinType.NEAR
            "ZIL" -> CoinType.ZILLIQA
            "THETA" -> CoinType.THETA
            "ADA" -> CoinType.CARDANO
            "EGLD" -> CoinType.MULTIVERSX
            else -> CoinType.ETHEREUM
        }
    }

    fun getChainTypeWithCoinString(coin: String): String {
        return when (coin) {
            "BTC" -> "Bitcoin"
            "LTC" -> "Bitcoin"
            "DOGE" -> "Bitcoin"
            "DASH" -> "Bitcoin"
            "VIA" -> "Bitcoin"
            "DGB" -> "Bitcoin"
            "MONA" -> "Bitcoin"
            "FIRO" -> "Bitcoin"
            "BCH" -> "Bitcoin"
            "BTG" -> "Bitcoin"
            "RVN" -> "Bitcoin"
            "QTUM" -> "Bitcoin"
            "XEC" -> "Bitcoin"
            "ETH" -> "Ethereum"
            "ETC" -> "Ethereum"
            "HT" -> "Ethereum"
            "XDAI" -> "Ethereum"
            "N" -> "Ethereum"
            "MATIC" -> "Ethereum"
            "AVAX" -> "Ethereum"
            "CELO" -> "Ethereum"
            "BNB" -> "Ethereum"
            "FTM" -> "Ethereum"
            "POA" -> "Ethereum"
            "CLO" -> "Ethereum"
            "TOMO" -> "Ethereum"
            "TT" -> "Ethereum"
            "GO" -> "Ethereum"
            "WAN" -> "Ethereum"
            "OKT" -> "Ethereum"
            "MTR" -> "Ethereum"
            "KLAY" -> "Ethereum"
            "GLMR" -> "Ethereum"
            "MOVR" -> "Ethereum"
            "EVMOS" -> "Ethereum"
            "BOBA" -> "Ethereum"
            "KCS" -> "Ethereum"
            "KAVA" -> "Ethereum"
            "CRO" -> "Ethereum"
            "OP" -> "Ethereum"
            "ARB" -> "Ethereum"
            "AURORA" -> "Ethereum"
            "METIS" -> "Ethereum"
            "XTZ" -> "Tezos"
            "TRX" -> "Tron"
            "SOL" -> "Solana"
            "ALGO" -> "Algorand"
            "XRP" -> "Ripple"
            "ATOM" -> "Cosmos"
            "ZETA" -> "Ethereum"
            "BASE" -> "Ethereum"
            "FIL" -> "Filecoin"
            "DOT" -> "Polkadot"
            "ACA" -> "Acala"
            "KSM" -> "Kusama"
            "APT" -> "Aptos"
            "SUI" -> "Sui"
            "TON" -> "Ton"
            "S" -> "Ethereum"
            "XLM" -> "Stellar"
            "VET" -> "VeChain"
            "ONE" -> "Ethereum"
            "IOTX" -> "Ethereum"
            "NEAR" -> "Near"
            "ZIL" -> "Zilliqa"
            "THETA" -> "Theta"
            "ADA" -> "Cardano"
            "EGLD" -> "MultiversX"
            else -> "Ethereum"
        }
    }
}
