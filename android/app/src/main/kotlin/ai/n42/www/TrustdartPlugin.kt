package ai.n42.www

import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.util.Base64 as aBase64
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat.startActivity
import com.google.protobuf.ByteString
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.json.JSONObject
import wallet.core.java.AnySigner
import wallet.core.jni.Account
import wallet.core.jni.TONWallet
import wallet.core.jni.BitcoinAddress
import wallet.core.jni.BitcoinScript
import wallet.core.jni.BitcoinSigHashType
import wallet.core.jni.CoinType
import wallet.core.jni.Curve
import wallet.core.jni.DataVector
import wallet.core.jni.Derivation
import wallet.core.jni.HDWallet
import wallet.core.jni.PrivateKey
import wallet.core.jni.PublicKey
import wallet.core.jni.SolanaAddress
import wallet.core.jni.StoredKey
import wallet.core.jni.TransactionCompiler
import wallet.core.jni.proto.Algorand
import wallet.core.jni.proto.Aptos
import wallet.core.jni.proto.Bitcoin
import wallet.core.jni.proto.BitcoinV2
import wallet.core.jni.proto.Cosmos
import wallet.core.jni.proto.Ethereum
import wallet.core.jni.proto.Filecoin
import wallet.core.jni.proto.Harmony
import wallet.core.jni.proto.IoTeX
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
import java.io.ByteArrayOutputStream
import java.math.BigInteger
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.security.MessageDigest
import java.util.concurrent.CompletableFuture
import evmsdk.Evmsdk
import com.mobileSdk.Api
import io.flutter.plugin.common.EventChannel

class TrustdartPlugin: FlutterPlugin, MethodCallHandler {

    /// Active runClient future — saved so we can cancel on MiningStopClient.
    @Volatile
    private var runClientFuture: CompletableFuture<Void>? = null

    init {
        System.loadLibrary("TrustWalletCore")
    }
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel : MethodChannel
    private lateinit var channel2 : MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context:Context

    override  fun onAttachedToEngine( flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "trustdart")
        //channel.setMethodCallHandler(this)
        channel.setMethodCallHandler { call, result ->
            handleCoreCall(call, result)
        }
        channel2 = MethodChannel(flutterPluginBinding.binaryMessenger, "trustdart_mining")
        //channel2.setMethodCallHandler(this)
        channel2.setMethodCallHandler { call, result ->
            handleCoreCall2(call, result)
        }
        context =flutterPluginBinding.applicationContext

        // ✅ 新增 EventChannel（专门给 WebSocket 推事件）
        eventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "trustdart_ws_events"
        )
        eventChannel.setStreamHandler(WebSocketEventChannelHandler)
    }
    fun handleCoreCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "generateMnemonic" -> {
                val passphrase: String? = call.argument("passphrase")
                var leng: Int? = call.argument("length")
                if(leng == null){
                    leng=128
                }
                val wallet = HDWallet(leng, passphrase)
                result.success(wallet.mnemonic())
            }
            "checkMnemonic" -> {
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                if (mnemonic != "") {
                    val wallet : HDWallet?= HDWallet(mnemonic, passphrase)
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
            "generateAddress" -> {
                val path: String? = call.argument("path")
                val coin: String? = call.argument("coin")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val addressType: String? = call.argument("addressType")
                val pkStr: String? = call.argument("pk")
                val isImport: String? = call.argument("isImport")
                val isTest: String? = call.argument("isTest")
                if (path != null && coin != null && mnemonic != null && pkStr!=null) {

                    if(mnemonic != "" ){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val address: Map<String, String?>? = generateAddress(wallet, path, coin, addressType!!,isTest!!)
                        if (address == null) result.error("address_null", "failed to generate address", null) else result.success(address)
                    }
                    else if(pkStr!=""){
                        val pk = if(isImport == "true"){
                            Numeric.hexStringToByteArray(pkStr)
                        }else{
                            aBase64.decode(pkStr,64)
                        }
                        val privateKey:PrivateKey?= getPrivateKey(pk)
                        if(privateKey==null){
                            result.error("privateKey", "failed to privateKey", null)
                        }else{
                            val address: Map<String, String?>? = generateAddressPK(privateKey, coin, addressType!!,null,isTest!!)
                            if (address == null) result.error("address_null", "failed to generate address", null) else result.success(address)
                        }
                    }else{
                        result.error("arguments_null", "[privateKey] cannot be null", null)
                    }


                } else {
                    result.error("arguments_null", "[path] and [coin] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "validateAddress" -> {
                val address: String? = call.argument("address")
                val coin: String? = call.argument("coin")
                if (address != null && coin != null) {
                    val isValid: Boolean = validateAddress(coin, address)
                    result.success(isValid)
                } else {
                    result.error("arguments_null", "$address and $coin cannot be null", null)
                }
            }
            "signTransaction" -> {
                val coin: String? = call.argument("coin")
                val path: String? = call.argument("path")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val txData: Map<String, Any>? = call.argument("txData")
                val pkStr: String? = call.argument("pk")
                if (txData != null && path != null && coin != null && mnemonic != null && pkStr!=null) {
                    if(mnemonic != ""){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val txHash: String? = signTransaction(wallet, coin, path, txData,null)
                        if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)

                        val privateKey:PrivateKey?= getPrivateKey(pk)
                        if(privateKey==null){
                            result.error("privateKey", "failed to privateKey", null)
                        }else{
                            val txHash: String? = signTransaction(null, coin, path, txData,privateKey)
                            if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
                        }

                    }else{
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "signTransaction_g" -> {
                val coin: String? = call.argument("coin")
                val path: String? = call.argument("path")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val txData: Map<String, Any>? = call.argument("txData")
                val pkStr: String? = call.argument("pk")
                if (txData != null && path != null && coin != null && mnemonic != null && pkStr!=null) {
                    if(mnemonic != ""){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val coinType:CoinType= getCoinTypeWithCoinString(coin)
                        val txHash: String? = signEthereumTransactionWithData(wallet, path, txData, coinType,null)
                        if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)

                        val privateKey:PrivateKey?= getPrivateKey(pk)
                        if(privateKey==null){
                            result.error("privateKey", "failed to privateKey", null)
                        }else{
                            val coinType:CoinType= getCoinTypeWithCoinString(coin)
                            val txHash: String? = signEthereumTransactionWithData(null, path, txData,coinType,privateKey)
                            if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
                        }

                    }else{
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "signTransaction_btc_p2wsh" -> {
                val coin: String? = call.argument("coin")
                val path: String? = call.argument("path")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val txData: Map<String, Any>? = call.argument("txData")
                val pkStr: String? = call.argument("pk")
                if (txData != null && path != null && coin != null && mnemonic != null && pkStr!=null) {
                    if(mnemonic != ""){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val txHash: String = signBitcoinTransactionP2wsh(wallet,path,txData,null)
                        result.success(txHash)
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)

                        val privateKey= PrivateKey(pk)
                        val txHash: String = signBitcoinTransactionP2wsh(null, path, txData,privateKey)
                        result.success(txHash)

                    }else{
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "signTransaction_byteArray" ->{
                val coin: String? = call.argument("coin")
                val path: String? = call.argument("path")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val txData: Map<String, Any>? = call.argument("txData")
                val pkStr: String? = call.argument("pk")
                if (txData != null && path != null && coin != null && mnemonic != null && pkStr!=null) {

                    if(mnemonic != ""){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val txHash: String? = signTransactionByteArray(wallet, coin, path, txData,null)
                        if (txHash == null){
                            result.error("txhash_null", "failed to buid and sign transaction", null)
                        }
                        else {
                            result.success(txHash)
                        }
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)
                        val privateKey= PrivateKey(pk)
                        val txHash: String? = signTransactionByteArray(null, coin, path, txData,privateKey)
                        if (txHash == null)
                            result.error("txhash_null", "failed to buid and sign transaction", null)
                        else result.success(txHash)

                    }else{
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "signMessage" ->{
                val coin: String? = call.argument("coin")
                val path: String? = call.argument("path")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val txData: String? = call.argument("txData")
                val pkStr: String? = call.argument("pk")
                if (txData != null && path != null && coin != null && mnemonic != null && pkStr!=null) {

                    if(mnemonic != ""){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val txHash: String? = signMessage(wallet, coin, path, txData,null)
                        if (txHash == null) result.error("txhash_null", "failed to buid and sign message", null) else result.success(txHash)
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)
                        val privateKey= PrivateKey(pk)
                        val txHash: String? = signMessage(null, coin, path, txData,privateKey)
                        if (txHash == null) result.error("txhash_null", "failed to buid and sign messagee", null) else result.success(txHash)

                    }else{
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "getPublicKey" -> {
                val path: String? = call.argument("path")
                val coin: String? = call.argument("coin")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val pkStr: String? = call.argument("pk")
                if (path != null && coin != null ) {
                    val wallet: HDWallet?
                    if(mnemonic != ""){
                        wallet = HDWallet(mnemonic, passphrase)
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)
                        wallet =HDWallet(pk, passphrase)
                    }else{
                        wallet=null
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
            "getPrivateKey" -> {
                val path: String? = call.argument("path")
                val coin: String? = call.argument("coin")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                if (path != null && coin != null && mnemonic != null) {
                    val wallet: HDWallet? = if(mnemonic != ""){
                        HDWallet(mnemonic, passphrase)
                    }else{
                        null
                    }
                    if (wallet != null) {
                        val privateKey: String? = getPrivateKey(wallet, coin, path)
                        if (privateKey == null) result.error("address_null", "failed to generate address", null) else result.success(privateKey)
                    } else {
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[path] and [coin] and [mnemonic] cannot be null", null)
                }
            }
            "getKeyStore" -> {
                val path: String? = call.argument("path")
                val coin: String? = call.argument("coin")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val addressType: String? = call.argument("addressType")
                val pkStr: String?= call.argument("pk")
                if (path != null && coin != null && passphrase != null && addressType!=null) {

                    val wallet: HDWallet?
                    if(mnemonic ==""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)
                        wallet =HDWallet(pk, "")
                    }else{
                        wallet = HDWallet(mnemonic, "")
                    }
                    val keystore: String = getKeyStore(wallet,path,coin,passphrase,addressType)
                    if (keystore == "") result.error("KeyStore_error", "failed to get KeyStore", null) else result.success(keystore)
                } else {
                    result.error("arguments_null", "[path] and [coin] and [mnemonic] and [passphrase] cannot be null", null)
                }
            }
            "getWalletInfoWithKeyStore" ->{
                val keyStore: String? = call.argument("keyStore")
                val coin: String? = call.argument("coin")
                val passphrase: String? = call.argument("passphrase")
                if (keyStore != null && coin != null && passphrase != null) {
                    val keystore: Map<String,Any?> = getWalletInfoWithKeyStore(keyStore,passphrase,coin)
                    result.success(keystore)
                } else {
                    result.error("arguments_null", "[keyStore] and [coin] and [passphrase] cannot be null", null)
                }
            }
            "getTransactionMaxValue" ->{
                //返回转账最大金额
                val coin: String? = call.argument("coin")
                val path: String? = call.argument("path")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val txData: Map<String, Any>? = call.argument("txData")
                val pkStr: String? = call.argument("pk")
                if (txData != null && path != null && coin != null && mnemonic != null && pkStr!=null) {

                    if(mnemonic != ""){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val txHash: String? = signTransactionMaxValue(wallet, coin, path, txData,null)
                        if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)

                        val privateKey = PrivateKey(pk)
                        val txHash: String? = signTransactionMaxValue(null, coin, path, txData,privateKey)
                        if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)

                    }else{
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "getPrivateKeyAndPublicKey" ->{
                val path: String? = call.argument("path")
                val coin: String? = call.argument("coin")
                val mnemonic: String? = call.argument("mnemonic")
                val pkStr: String? = call.argument("privateKey")
                val passphrase: String? = call.argument("passphrase")
                if (path != null && coin != null ) {
                    val wallet: HDWallet?
                    if (mnemonic != "") {
                        wallet = HDWallet(mnemonic, passphrase)
                        val privateKey: String? = getPrivateKey(wallet, coin, path)
                        val publicKey: String? = getPublicKey(wallet,coin,path)
                        if (privateKey == null) result.error("address_null", "failed to generate address", null) else {
                            val rValue :Map<String,String?> = mapOf("publicKey" to publicKey,"privateKey" to privateKey)
                            result.success(JSONObject(rValue).toString())
                        }
                    } else if(pkStr !=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)
                        wallet =HDWallet(pk, passphrase)
                        val privateKey: String? = getPrivateKey(wallet, coin, path)
                        val publicKey: String? = getPublicKey(wallet,coin,path)
                        val rValue :Map<String,String?> = mapOf("publicKey" to publicKey,"privateKey" to privateKey)
                        result.success(JSONObject(rValue).toString())
                    }
                    else {
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[path] and [coin] and [mnemonic] cannot be null", null)
                }
            }
            "LiveActivityStart" ->{
                val rString : String = playAudio()
                result.success(rString)
            }
            "LiveActivityEnd" ->{
                val rString : String = playAudioEnd()
                result.success(rString)
            }
            "getPubKeySOL" ->{
                //返回代币账户
                val mintAddress: String? = call.argument("mintAddress")
                val address: String? = call.argument("address")
                val pubKey : String = SolanaAddress(address).defaultTokenAddress(mintAddress)
                result.success(pubKey)
            }
            "EvmEmit" ->{
                try {
                    val params = call.arguments<Map<String, Any>>()
                    if (params == null) {
                        result.error("Evm", "params is null", null)
                        return
                    }
                    val paramsJson = JSONObject(params).toString()
                    //执行sdk的通用方法
                    val responseStringJson = Evmsdk.emit(paramsJson)
                    if(responseStringJson != null){
                        result.success(responseStringJson)
                    }else{
                        result.error("Evm","evm response no data",null)
                    }
                }catch (e: Exception) {
                    result.error("Evm", e.message, null)
                }

            }
            "MiningGenerateBls12381Keypair" ->{
                try {
                    val keyPair = Api.generateBls12381Keypair()
                    result.success(keyPair)
                }catch (e: Exception) {
                    result.error("DepositError", e.message, null)
                }
            }
            "MiningCreateDepositUnsignedTx" ->{
                val args = call.arguments as Map<String, Any>
                val depositContractAddress = args["depositContractAddress"] as String
                val validatorPrivateKey = args["validatorPrivateKey"] as String
                val withdrawalAddress = args["withdrawalAddress"] as String
                val depositValueWeiInHex = args["depositValueWeiInHex"] as String

                try {
                    val tx = Api.createDepositUnsignedTx(
                        depositContractAddress,
                        validatorPrivateKey,
                        withdrawalAddress,
                        depositValueWeiInHex
                    )
                    result.success(tx)
                } catch (e: Exception) {
                    result.error("DepositError", e.message, null)
                }
            }
            "MiningCreateExitUnsignedTx" ->{
                val args = call.arguments as Map<String, Any>
                val validatorPublicKey = args["validatorPublicKey"] as String
                val feeWeiInHex = args["feeWeiInHex"] as String

                try {
                    val exitTx = Api.createExitUnsignedTx(
                        validatorPublicKey,
                        feeWeiInHex
                    )
                    result.success(exitTx)
                } catch (e: Exception) {
                    result.error("ExitError", e.message, null)
                }
            }
            "MiningCreateGetExitFeeUnsignedTx" ->{
                try {
                    val tx = Api.createGetExitFeeUnsignedTx()
                    result.success(tx)
                }catch (e: Exception) {
                    result.error("DepositError", e.message, null)
                }
            }
            "MiningRunClient" ->{
                val args = call.arguments as Map<String, Any>
                val wsUrl = args["wsUrl"] as String
                val validatorPrivateKey = args["validatorPrivateKey"] as String

                try {
                    runClientFuture?.cancel(true)
                    val future = Api.runClient(wsUrl, validatorPrivateKey)
                    runClientFuture = future
                    future
                        .thenRun {
                            runClientFuture = null
                            channel.invokeMethod("onClientDone", null)
                        }
                        .exceptionally { ex ->
                            runClientFuture = null
                            channel.invokeMethod("onClientError", ex.message)
                            null
                        }
                    // 启动前台服务显示持续通知（挖矿运行中）
                    val serviceIntent = Intent(context, WebSocketService::class.java).apply {
                        putExtra("wsUrl", wsUrl)
                        putExtra("validatorPubkey", "")
                        putExtra("validatorPrivateKey", validatorPrivateKey)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(serviceIntent)
                    } else {
                        context.startService(serviceIntent)
                    }
                    result.success("Client started")
                } catch (e: Exception) {
                    result.error("ClientError", e.message, null)
                }
            }
            "MiningStopClient" -> {
                try {
                    runClientFuture?.cancel(true)
                    runClientFuture = null
                    // 停止前台服务通知
                    context.stopService(Intent(context, WebSocketService::class.java))
                    result.success("Client stopped")
                } catch (e: Exception) {
                    result.error("StopClientError", e.message, null)
                }
            }

            "getTonWalletStateInit" -> {
                val mnemonic: String? = call.argument("mnemonic")
                val path: String? = call.argument("path")
                if (mnemonic.isNullOrEmpty() || path.isNullOrEmpty()) {
                    result.success(null)
                } else {
                    try {
                        val wallet = HDWallet(mnemonic, "")
                        val privateKey = wallet.getKey(CoinType.TON, path)
                        val pubKey = privateKey.publicKeyEd25519
                        // Use TrustWallet Core native method to build v4R2 stateInit directly
                        // Returns base64-encoded BOC (standard TON format with correct cell ordering)
                        val stateInitBase64 = TONWallet.buildV4R2StateInit(pubKey, 0, 698983191)
                        val derivedAddr = CoinType.TON.deriveAddress(privateKey)
                        if (stateInitBase64.isNullOrEmpty()) {
                            result.success(null)
                        } else {
                            result.success("ADDR:$derivedAddr|$stateInitBase64")
                        }
                    } catch (e: Exception) {
                        result.success(null)
                    }
                }
            }

            "signTonProof" -> {
                val mnemonic: String? = call.argument("mnemonic")
                val path: String? = call.argument("path")
                val domain: String? = call.argument("domain")
                val timestamp: Long = (call.argument<Any>("timestamp") as? Number)?.toLong()
                    ?: (System.currentTimeMillis() / 1000L)
                val payload: String? = call.argument("payload")
                val tonAddress: String? = call.argument("address")
                if (mnemonic.isNullOrEmpty() || path.isNullOrEmpty()) {
                    result.success(null)
                } else {
                    try {
                        val wallet = HDWallet(mnemonic, "")
                        val privateKey = wallet.getKey(CoinType.TON, path)
                        val address = if (!tonAddress.isNullOrEmpty()) tonAddress
                                      else CoinType.TON.deriveAddress(privateKey)
                        val addrDecoded = decodeTonAddress(address)
                        val workchain = addrDecoded?.first ?: 0
                        val addrHash = addrDecoded?.second ?: ByteArray(32)
                        val domainStr = domain ?: ""
                        val payloadStr = payload ?: ""
                        val domainBytes = domainStr.toByteArray(Charsets.UTF_8)
                        val payloadBytes = payloadStr.toByteArray(Charsets.UTF_8)
                        // Build message per TonConnect ton_proof spec
                        val baos = ByteArrayOutputStream()
                        baos.write("ton-proof-item-v2/".toByteArray(Charsets.UTF_8))
                        baos.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(workchain).array())
                        baos.write(addrHash)
                        baos.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(domainBytes.size).array())
                        baos.write(domainBytes)
                        baos.write(ByteBuffer.allocate(8).order(ByteOrder.LITTLE_ENDIAN).putLong(timestamp).array())
                        baos.write(payloadBytes)
                        val message = baos.toByteArray()
                        val md = MessageDigest.getInstance("SHA-256")
                        val messageHash = md.digest(message)
                        val appContextHash = md.digest("ton-connect".toByteArray(Charsets.UTF_8))
                        // bufToSign = 0xffff ++ sha256("ton-connect") ++ sha256(message)
                        val bufToSign = ByteArray(66)
                        bufToSign[0] = 0xff.toByte()
                        bufToSign[1] = 0xff.toByte()
                        System.arraycopy(appContextHash, 0, bufToSign, 2, 32)
                        System.arraycopy(messageHash, 0, bufToSign, 34, 32)
                        val signature = privateKey.sign(bufToSign, Curve.ED25519)
                        val signatureBase64 = aBase64.encodeToString(signature, aBase64.NO_WRAP)
                        val proofResult = JSONObject().apply {
                            put("timestamp", timestamp)
                            put("domain", JSONObject().apply {
                                put("lengthBytes", domainBytes.size)
                                put("value", domainStr)
                            })
                            put("payload", payloadStr)
                            put("signature", signatureBase64)
                        }
                        result.success(proofResult.toString())
                    } catch (e: Exception) {
                        result.success(null)
                    }
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun decodeTonAddress(address: String): Pair<Int, ByteArray>? {
        return try {
            val standardB64 = address.replace('-', '+').replace('_', '/')
            val decoded = aBase64.decode(standardB64, aBase64.DEFAULT)
            if (decoded.size != 36) return null
            val workchain = decoded[1].toInt().let { if (it > 127) it - 256 else it }
            val hash = decoded.copyOfRange(2, 34)
            Pair(workchain, hash)
        } catch (e: Exception) {
            null
        }
    }

    private fun extractStateInitFromBoc(boc: ByteArray): ByteArray? {
        if (boc.size < 10) return null
        if (boc[0] != 0xB5.toByte() || boc[1] != 0xEE.toByte() ||
            boc[2] != 0x9C.toByte() || boc[3] != 0x72.toByte()) return null

        var pos = 4
        fun byte(): Int = boc[pos++].toInt() and 0xFF
        fun uint(n: Int): Int { var r = 0; repeat(n) { r = (r shl 8) or byte() }; return r }

        val flagsByte = byte()
        val hasIdx = (flagsByte shr 7) and 1 == 1
        val refSize = flagsByte and 0x07
        val offBytes = byte()

        val cellCount = uint(refSize)
        uint(refSize) // root_count
        uint(refSize) // absent_count
        uint(offBytes) // tot_cells_size
        uint(refSize) // root_index

        if (hasIdx) pos += cellCount * offBytes

        val cellD1 = IntArray(cellCount)
        val cellD2 = IntArray(cellCount)
        val cellData = Array(cellCount) { ByteArray(0) }
        val cellRefs = Array(cellCount) { IntArray(0) }

        for (i in 0 until cellCount) {
            val d1 = byte()
            val d2 = byte()
            val refsCount = d1 and 0x07
            val dataLen = (d2 ushr 1) + (d2 and 1)
            cellD1[i] = d1
            cellD2[i] = d2
            cellData[i] = boc.copyOfRange(pos, pos + dataLen); pos += dataLen
            cellRefs[i] = IntArray(refsCount) { uint(refSize) }
        }

        // Find stateInit cell: d1=0x02 (2 refs), d2=0x01 (5 bits), data=[0x34]
        var stateInitIdx = -1
        for (i in 0 until cellCount) {
            if (cellD1[i] == 0x02 && cellD2[i] == 0x01 &&
                cellData[i].size == 1 && cellData[i][0] == 0x34.toByte()) {
                stateInitIdx = i
                break
            }
        }
        if (stateInitIdx < 0) return null

        // BFS collect all cells in the stateInit subtree
        val orderedIndices = mutableListOf<Int>()
        val visited = mutableSetOf<Int>()
        val queue = ArrayDeque<Int>()
        queue.add(stateInitIdx)
        visited.add(stateInitIdx)
        while (queue.isNotEmpty()) {
            val idx = queue.removeFirst()
            orderedIndices.add(idx)
            for (ref in cellRefs[idx]) {
                if (visited.add(ref)) queue.add(ref)
            }
        }

        val oldToNew = HashMap<Int, Int>()
        for ((newIdx, oldIdx) in orderedIndices.withIndex()) oldToNew[oldIdx] = newIdx

        // Total cell data size with refSize=1
        var totSize = 0
        for (oldIdx in orderedIndices) {
            val refsCount = cellD1[oldIdx] and 0x07
            totSize += 2 + cellData[oldIdx].size + refsCount
        }

        val out = java.io.ByteArrayOutputStream()
        out.write(byteArrayOf(0xB5.toByte(), 0xEE.toByte(), 0x9C.toByte(), 0x72.toByte()))
        out.write(0x01) // flags: size=1
        out.write(0x02) // off_bytes=2
        out.write(orderedIndices.size) // cell_count
        out.write(0x01) // root_count
        out.write(0x00) // absent_count
        out.write((totSize shr 8) and 0xFF)
        out.write(totSize and 0xFF)
        out.write(0x00) // root_index=0

        for (oldIdx in orderedIndices) {
            out.write(cellD1[oldIdx])
            out.write(cellD2[oldIdx])
            out.write(cellData[oldIdx])
            for (ref in cellRefs[oldIdx]) out.write(oldToNew[ref]!!)
        }

        return out.toByteArray()
    }

    fun handleCoreCall2(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {

            /**
             * connectWebSocket
             * - 首次调用：启动 ForegroundService + 建立 WS
             * - 再次调用（切钱包）：Service 仍在 → onStartCommand → 内部自动重启 WS
             */
            "connectWebSocket" -> {
                val args = call.arguments as? Map<*, *>
                if (args == null) {
                    result.error("arguments_error", "arguments is null", null)
                    return
                }

                val wsUrl = args["wsUrl"] as? String
                val pubkey = args["validatorPubkey"] as? String
                val privateKey = args["validatorPrivateKey"] as? String

                if (wsUrl.isNullOrBlank() ||
                    pubkey.isNullOrBlank() ||
                    privateKey.isNullOrBlank()
                ) {
                    result.error(
                        "arguments_null",
                        "wsUrl / validatorPubkey / validatorPrivateKey cannot be null",
                        null
                    )
                    return
                }

                val intent = Intent(context, WebSocketService::class.java).apply {
                    putExtra("wsUrl", wsUrl)
                    putExtra("validatorPubkey", pubkey)
                    putExtra("validatorPrivateKey", privateKey)
                }

                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(intent)
                    } else {
                        context.startService(intent)
                    }
                    result.success("WebSocketService started / updated")
                } catch (e: Exception) {
                    result.error("service_start_failed", e.message, null)
                }
            }

            /**
             * disconnectWebSocket
             * - 明确是“用户主动断开”
             * - Service.onDestroy -> stopWebSocket(manual=true)
             * - 不触发自动重连
             */
            "disconnectWebSocket" -> {
                try {
                    val intent = Intent(context, WebSocketService::class.java)
                    context.stopService(intent)
                    result.success("WebSocketService stopped")
                } catch (e: Exception) {
                    result.error("service_stop_failed", e.message, null)
                }
            }

            else -> result.notImplemented()
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onMethodCall( call: MethodCall,  result: MethodChannel.Result) {
        when(call.method) {
            "generateMnemonic" -> {
                val passphrase: String? = call.argument("passphrase")
                var leng: Int? = call.argument("length")
                if(leng == null){
                    leng=128
                }
                val wallet = HDWallet(leng, passphrase)
                result.success(wallet.mnemonic())
            }
            "checkMnemonic" -> {
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                if (mnemonic != "") {
                    val wallet : HDWallet?= HDWallet(mnemonic, passphrase)
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
            "generateAddress" -> {
                val path: String? = call.argument("path")
                val coin: String? = call.argument("coin")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val addressType: String? = call.argument("addressType")
                val pkStr: String? = call.argument("pk")
                val isImport: String? = call.argument("isImport")
                val isTest: String? = call.argument("isTest")
                if (path != null && coin != null && mnemonic != null && pkStr!=null) {

                    if(mnemonic != "" ){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val address: Map<String, String?>? = generateAddress(wallet, path, coin, addressType!!,isTest!!)
                        if (address == null) result.error("address_null", "failed to generate address", null) else result.success(address)
                    }
                    else if(pkStr!=""){
                        val pk = if(isImport == "true"){
                            Numeric.hexStringToByteArray(pkStr)
                        }else{
                            aBase64.decode(pkStr,64)
                        }
                        val privateKey:PrivateKey?= getPrivateKey(pk)
                        if(privateKey==null){
                            result.error("privateKey", "failed to privateKey", null)
                        }else{
                            val address: Map<String, String?>? = generateAddressPK(privateKey, coin, addressType!!,null,isTest!!)
                            if (address == null) result.error("address_null", "failed to generate address", null) else result.success(address)
                        }
                    }else{
                        result.error("arguments_null", "[privateKey] cannot be null", null)
                    }


                } else {
                    result.error("arguments_null", "[path] and [coin] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "validateAddress" -> {
                val address: String? = call.argument("address")
                val coin: String? = call.argument("coin")
                if (address != null && coin != null) {
                    val isValid: Boolean = validateAddress(coin, address)
                    result.success(isValid)
                } else {
                    result.error("arguments_null", "$address and $coin cannot be null", null)
                }
            }
            "signTransaction" -> {
                val coin: String? = call.argument("coin")
                val path: String? = call.argument("path")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val txData: Map<String, Any>? = call.argument("txData")
                val pkStr: String? = call.argument("pk")
                if (txData != null && path != null && coin != null && mnemonic != null && pkStr!=null) {
                    if(mnemonic != ""){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val txHash: String? = signTransaction(wallet, coin, path, txData,null)
                        if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)

                        val privateKey:PrivateKey?= getPrivateKey(pk)
                        if(privateKey==null){
                            result.error("privateKey", "failed to privateKey", null)
                        }else{
                            val txHash: String? = signTransaction(null, coin, path, txData,privateKey)
                            if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
                        }

                    }else{
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "signTransaction_g" -> {
                val coin: String? = call.argument("coin")
                val path: String? = call.argument("path")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val txData: Map<String, Any>? = call.argument("txData")
                val pkStr: String? = call.argument("pk")
                if (txData != null && path != null && coin != null && mnemonic != null && pkStr!=null) {
                    if(mnemonic != ""){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val coinType:CoinType= getCoinTypeWithCoinString(coin)
                        val txHash: String? = signEthereumTransactionWithData(wallet, path, txData, coinType,null)
                        if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)

                        val privateKey:PrivateKey?= getPrivateKey(pk)
                        if(privateKey==null){
                            result.error("privateKey", "failed to privateKey", null)
                        }else{
                            val coinType:CoinType= getCoinTypeWithCoinString(coin)
                            val txHash: String? = signEthereumTransactionWithData(null, path, txData,coinType,privateKey)
                            if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
                        }

                    }else{
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "signTransaction_btc_p2wsh" -> {
                val coin: String? = call.argument("coin")
                val path: String? = call.argument("path")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val txData: Map<String, Any>? = call.argument("txData")
                val pkStr: String? = call.argument("pk")
                if (txData != null && path != null && coin != null && mnemonic != null && pkStr!=null) {
                    if(mnemonic != ""){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val txHash: String = signBitcoinTransactionP2wsh(wallet,path,txData,null)
                        result.success(txHash)
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)

                        val privateKey= PrivateKey(pk)
                        val txHash: String = signBitcoinTransactionP2wsh(null, path, txData,privateKey)
                        result.success(txHash)

                    }else{
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "signTransaction_byteArray" ->{
                val coin: String? = call.argument("coin")
                val path: String? = call.argument("path")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val txData: Map<String, Any>? = call.argument("txData")
                val pkStr: String? = call.argument("pk")
                if (txData != null && path != null && coin != null && mnemonic != null && pkStr!=null) {

                    if(mnemonic != ""){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val txHash: String? = signTransactionByteArray(wallet, coin, path, txData,null)
                        if (txHash == null){
                            result.error("txhash_null", "failed to buid and sign transaction", null)
                        }
                        else {
                            result.success(txHash)
                        }
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)
                        val privateKey= PrivateKey(pk)
                        val txHash: String? = signTransactionByteArray(null, coin, path, txData,privateKey)
                        if (txHash == null)
                            result.error("txhash_null", "failed to buid and sign transaction", null)
                        else result.success(txHash)

                    }else{
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "signMessage" ->{
                val coin: String? = call.argument("coin")
                val path: String? = call.argument("path")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val txData: String? = call.argument("txData")
                val pkStr: String? = call.argument("pk")
                if (txData != null && path != null && coin != null && mnemonic != null && pkStr!=null) {

                    if(mnemonic != ""){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val txHash: String? = signMessage(wallet, coin, path, txData,null)
                        if (txHash == null) result.error("txhash_null", "failed to buid and sign message", null) else result.success(txHash)
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)
                        val privateKey= PrivateKey(pk)
                        val txHash: String? = signMessage(null, coin, path, txData,privateKey)
                        if (txHash == null) result.error("txhash_null", "failed to buid and sign messagee", null) else result.success(txHash)

                    }else{
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "getPublicKey" -> {
                val path: String? = call.argument("path")
                val coin: String? = call.argument("coin")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val pkStr: String? = call.argument("pk")
                if (path != null && coin != null ) {
                    val wallet: HDWallet?
                    if(mnemonic != ""){
                        wallet = HDWallet(mnemonic, passphrase)
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)
                        wallet =HDWallet(pk, passphrase)
                    }else{
                        wallet=null
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
            "getPrivateKey" -> {
                val path: String? = call.argument("path")
                val coin: String? = call.argument("coin")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                if (path != null && coin != null && mnemonic != null) {
                    val wallet: HDWallet? = if(mnemonic != ""){
                        HDWallet(mnemonic, passphrase)
                    }else{
                        null
                    }
                    if (wallet != null) {
                        val privateKey: String? = getPrivateKey(wallet, coin, path)
                        if (privateKey == null) result.error("address_null", "failed to generate address", null) else result.success(privateKey)
                    } else {
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[path] and [coin] and [mnemonic] cannot be null", null)
                }
            }
            "getKeyStore" -> {
                val path: String? = call.argument("path")
                val coin: String? = call.argument("coin")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val addressType: String? = call.argument("addressType")
                val pkStr: String?= call.argument("pk")
                if (path != null && coin != null && passphrase != null && addressType!=null) {

                    val wallet: HDWallet?
                    if(mnemonic ==""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)
                        wallet =HDWallet(pk, "")
                    }else{
                        wallet = HDWallet(mnemonic, "")
                    }
                    val keystore: String = getKeyStore(wallet,path,coin,passphrase,addressType)
                    if (keystore == "") result.error("KeyStore_error", "failed to get KeyStore", null) else result.success(keystore)
                } else {
                    result.error("arguments_null", "[path] and [coin] and [mnemonic] and [passphrase] cannot be null", null)
                }
            }
            "getWalletInfoWithKeyStore" ->{
                val keyStore: String? = call.argument("keyStore")
                val coin: String? = call.argument("coin")
                val passphrase: String? = call.argument("passphrase")
                if (keyStore != null && coin != null && passphrase != null) {
                    val keystore: Map<String,Any?> = getWalletInfoWithKeyStore(keyStore,passphrase,coin)
                    result.success(keystore)
                } else {
                    result.error("arguments_null", "[keyStore] and [coin] and [passphrase] cannot be null", null)
                }
            }
            "getTransactionMaxValue" ->{
                //返回转账最大金额
                val coin: String? = call.argument("coin")
                val path: String? = call.argument("path")
                val mnemonic: String? = call.argument("mnemonic")
                val passphrase: String? = call.argument("passphrase")
                val txData: Map<String, Any>? = call.argument("txData")
                val pkStr: String? = call.argument("pk")
                if (txData != null && path != null && coin != null && mnemonic != null && pkStr!=null) {

                    if(mnemonic != ""){
                        val wallet = HDWallet(mnemonic, passphrase)
                        val txHash: String? = signTransactionMaxValue(wallet, coin, path, txData,null)
                        if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)
                    }
                    else if(pkStr!=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)

                        val privateKey = PrivateKey(pk)
                        val txHash: String? = signTransactionMaxValue(null, coin, path, txData,privateKey)
                        if (txHash == null) result.error("txhash_null", "failed to buid and sign transaction", null) else result.success(txHash)

                    }else{
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[txData], [coin] and [path] and [mnemonic] and [privateKey] cannot be null", null)
                }
            }
            "getPrivateKeyAndPublicKey" ->{
                val path: String? = call.argument("path")
                val coin: String? = call.argument("coin")
                val mnemonic: String? = call.argument("mnemonic")
                val pkStr: String? = call.argument("privateKey")
                val passphrase: String? = call.argument("passphrase")
                if (path != null && coin != null ) {
                    val wallet: HDWallet?
                    if (mnemonic != "") {
                        wallet = HDWallet(mnemonic, passphrase)
                        val privateKey: String? = getPrivateKey(wallet, coin, path)
                        val publicKey: String? = getPublicKey(wallet,coin,path)
                        if (privateKey == null) result.error("address_null", "failed to generate address", null) else {
                            val rValue :Map<String,String?> = mapOf("publicKey" to publicKey,"privateKey" to privateKey)
                            result.success(JSONObject(rValue).toString())
                        }
                    } else if(pkStr !=""){
                        val pk : ByteArray = aBase64.decode(pkStr,64)
                        wallet =HDWallet(pk, passphrase)
                        val privateKey: String? = getPrivateKey(wallet, coin, path)
                        val publicKey: String? = getPublicKey(wallet,coin,path)
                        val rValue :Map<String,String?> = mapOf("publicKey" to publicKey,"privateKey" to privateKey)
                        result.success(JSONObject(rValue).toString())
                    }
                    else {
                        result.error("no_wallet",
                            "Could not generate wallet, why?", null)
                    }
                } else {
                    result.error("arguments_null", "[path] and [coin] and [mnemonic] cannot be null", null)
                }
            }
            "LiveActivityStart" ->{
                val rString : String = playAudio()
                result.success(rString)
            }
            "LiveActivityEnd" ->{
                val rString : String = playAudioEnd()
                result.success(rString)
            }
            "getPubKeySOL" ->{
                //返回代币账户
                val mintAddress: String? = call.argument("mintAddress")
                val address: String? = call.argument("address")
                val pubKey : String = SolanaAddress(address).defaultTokenAddress(mintAddress)
                result.success(pubKey)
            }
            "EvmEmit" ->{
                try {
                    val params = call.arguments<Map<String, Any>>()
                    if (params == null) {
                        result.error("Evm", "params is null", null)
                        return
                    }
                    val paramsJson = JSONObject(params).toString()
                    //执行sdk的通用方法
                    val responseStringJson = Evmsdk.emit(paramsJson)
                    if(responseStringJson != null){
                        result.success(responseStringJson)
                    }else{
                        result.error("Evm","evm response no data",null)
                    }
                }catch (e: Exception) {
                    result.error("Evm", e.message, null)
                }

            }
            "MiningGenerateBls12381Keypair" ->{
                try {
                    val keyPair = Api.generateBls12381Keypair()
                    result.success(keyPair)
                }catch (e: Exception) {
                    result.error("DepositError", e.message, null)
                }
            }
            "MiningCreateDepositUnsignedTx" ->{
                val args = call.arguments as Map<String, Any>
                val depositContractAddress = args["depositContractAddress"] as String
                val validatorPrivateKey = args["validatorPrivateKey"] as String
                val withdrawalAddress = args["withdrawalAddress"] as String
                val depositValueWeiInHex = args["depositValueWeiInHex"] as String

                try {
                    val tx = Api.createDepositUnsignedTx(
                        depositContractAddress,
                        validatorPrivateKey,
                        withdrawalAddress,
                        depositValueWeiInHex
                    )
                    result.success(tx)
                } catch (e: Exception) {
                    result.error("DepositError", e.message, null)
                }
            }
            "MiningCreateExitUnsignedTx" ->{
                val args = call.arguments as Map<String, Any>
                val validatorPublicKey = args["validatorPublicKey"] as String
                val feeWeiInHex = args["feeWeiInHex"] as String

                try {
                    val exitTx = Api.createExitUnsignedTx(
                        validatorPublicKey,
                        feeWeiInHex
                    )
                    result.success(exitTx)
                } catch (e: Exception) {
                    result.error("ExitError", e.message, null)
                }
            }
            "MiningCreateGetExitFeeUnsignedTx" ->{
                try {
                    val tx = Api.createGetExitFeeUnsignedTx()
                    result.success(tx)
                }catch (e: Exception) {
                    result.error("DepositError", e.message, null)
                }
            }
            "MiningRunClient" ->{
                val args = call.arguments as Map<String, Any>
                val wsUrl = args["wsUrl"] as String
                val validatorPrivateKey = args["validatorPrivateKey"] as String

                try {
                    runClientFuture?.cancel(true)
                    val future = Api.runClient(wsUrl, validatorPrivateKey)
                    runClientFuture = future
                    future
                        .thenRun {
                            runClientFuture = null
                            channel.invokeMethod("onClientDone", null)
                        }
                        .exceptionally { ex ->
                            runClientFuture = null
                            channel.invokeMethod("onClientError", ex.message)
                            null
                        }
                    result.success("Client started")
                } catch (e: Exception) {
                    result.error("ClientError", e.message, null)
                }
            }
            "MiningStopClient" -> {
                try {
                    runClientFuture?.cancel(true)
                    runClientFuture = null
                    result.success("Client stopped")
                } catch (e: Exception) {
                    result.error("StopClientError", e.message, null)
                }
            }
            "connectWebSocket" -> {
                val args = call.arguments as Map<String, Any>
                val wsUrl = args["wsUrl"] as? String
                val pubkey = args["validatorPubkey"] as? String
                if (wsUrl == null || pubkey == null) {
                    result.error("arguments_null", "wsUrl and validatorPubkey cannot be null", null)
                    return
                }

                val intent = Intent(context, WebSocketService::class.java)
                intent.putExtra("wsUrl", wsUrl)
                intent.putExtra("validatorPubkey", pubkey)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
                result.success("WebSocket connecting...")
            }
            "disconnectWebSocket" -> {
                val intent = Intent(context, WebSocketService::class.java)
                context.stopService(intent)
                result.success("WebSocket disconnected")
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine( binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        channel2.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
    //创建私钥
    private fun getPrivateKey(pk: ByteArray):PrivateKey? {
        return try {
            PrivateKey(pk)
        }catch (err : Exception){
            null
        }
    }
    //返回keystore json字符串
    private fun getKeyStore(wallet: HDWallet, path: String, coin: String,passphrase:String,addressType:String): String {
        val coinType: CoinType= getCoinTypeWithCoinString(coin)
        val pk:PrivateKey=wallet.getKey(coinType,path)
        val address=when(coin) {
            "BTC" -> {
                val privateKey = wallet.getKey(CoinType.BITCOIN, path)
                val publicKey = privateKey.getPublicKeySecp256k1(true)
                if(addressType == "legacy"){
                    val address = BitcoinAddress(publicKey, CoinType.BITCOIN.p2pkhPrefix())
                    address.description()
                }else{
                    //val address = BitcoinAddress(publicKey, CoinType.BITCOIN.p2shPrefix())
                    CoinType.BITCOIN.deriveAddress(privateKey)
                }
            }
            "LTC" -> {
                val privateKey = wallet.getKey(CoinType.LITECOIN, path)
                val publicKey = privateKey.getPublicKeySecp256k1(true)
                if(addressType == "legacy"){
                    val address = BitcoinAddress(publicKey, CoinType.LITECOIN.p2pkhPrefix())
                    address.description()
                }else{
                    //val address = BitcoinAddress(publicKey, CoinType.LITECOIN.p2shPrefix())
                    CoinType.LITECOIN.deriveAddress(privateKey)
                }
            }
            else ->""
        }
        val key=StoredKey.importPrivateKey(pk.data(),coinType.name,passphrase.encodeToByteArray(),coinType)
        if(address!=""){
            val account: Account = key.account(0)
            key.removeAccountForCoin(key.account(0).coin())
            key.addAccount(address,account.coin(),path,account.publicKey(),account.extendedPublicKey())
        }
        val json:String=key.exportJSON().decodeToString()
        return json
    }
    //根据传入的keystore json 返回 address，priviateKey等信息
    private fun getWalletInfoWithKeyStore(keyStore:String,passphrase:String,coinType:String):Map<String,Any?>{
        val ksArray: ByteArray= keyStore.encodeToByteArray()
        val pwArray: ByteArray= passphrase.toByteArray()
        val storedKey=StoredKey.importJSON(ksArray)
        val coint:CoinType = storedKey.account(0).coin()
        val privateKey:PrivateKey=storedKey.privateKey(coint,pwArray)
        val path:String =storedKey.account(0).derivationPath()
        var addressType="legacy"
        val chainType=getChainTypeWithCoinString(coinType)
        var isBitcoin=false
        if (chainType == "Bitcoin"){
            isBitcoin=true
        }
        if(isBitcoin){
            val list84: List<String> =path.split("84")
            if(list84.size>1){
                addressType="segwit"
            }
        }
        val addressMap:Map<String,String?>?=generateAddressPK(privateKey,coinType,addressType,coint,"false")

        val rMap: Map<String,Any?> = mapOf("address" to addressMap,"privateKey" to aBase64.encodeToString(privateKey.data(),64),"addressType" to addressType)
        return rMap
    }
    //addressType legacy,segwit
    private fun generateAddress(wallet: HDWallet, path: String, coin: String, addressType: String,isTest:String): Map<String, String?>? {
        //val chainType:String =getChainTypeWithCoinString(coin)
        val coinType: CoinType = getCoinTypeWithCoinString(coin)
        val privateKey = wallet.getKey(coinType, path)
        return generateAddressPK(privateKey,coin,addressType,coinType,isTest)
    }
    private fun generateAddressPK(privateKey: PrivateKey, coin: String,addressType:String,coinType:CoinType?,isTest:String): Map<String, String?>? {
        val chainType:String =getChainTypeWithCoinString(coin)
        var cType:CoinType?=coinType
        if(cType == null){
            cType=getCoinTypeWithCoinString(coin)
        }
        if(cType==null){
            return null
        }
        if(chainType == "Bitcoin"){
            val publicKey = privateKey.getPublicKeySecp256k1(true)
            val address = BitcoinAddress(publicKey, cType.p2shPrefix())
            if(coin=="BCH" || coin=="DOGE" || coin=="DASH"){
                return mapOf("legacy" to address.description())
            }else{
                val btcAddr:String = if(isTest == "true"){
                    cType.deriveAddressFromPublicKeyAndDerivation(publicKey,Derivation.BITCOINTESTNET)
                }else{
                    cType.deriveAddress(privateKey)
                }
                return mapOf("legacy" to address.description(), "segwit" to btcAddr)
            }
        }
        else{
            return mapOf("legacy" to cType.deriveAddress(privateKey))
        }
    }
    private fun validateAddress(coin: String, address: String): Boolean {
        val coinType:CoinType = getCoinTypeWithCoinString(coin)
        return coinType.validate(address)
    }

    //@RequiresApi(Build.VERSION_CODES.O)
    private fun getPublicKey(wallet: HDWallet, coin: String, path: String): String? {
        val chainType:String =getChainTypeWithCoinString(coin)
        if(chainType == ""){
            return null
        }
        val coinType:CoinType= getCoinTypeWithCoinString(coin)
        val privateKey = wallet.getKey(coinType, path)
        val publicKey:PublicKey?= when(chainType){
            "Bitcoin" ->{
                privateKey.getPublicKeySecp256k1(true)
            }
            "Ethereum" ->{
                privateKey.getPublicKeySecp256k1(true)
            }
            "Tron" ->{
                privateKey.getPublicKeySecp256k1(true)
            }
            "Tezos" ->{
                privateKey.publicKeyEd25519
            }
            "Solana" ->{
                privateKey.publicKeyEd25519
            }
            "Ripple" ->{
                privateKey.getPublicKeySecp256k1(true)
            }
            "Cosmos" ->{
                privateKey.getPublicKeySecp256k1(true)
            }
            "Filecoin" ->{
                privateKey.getPublicKeySecp256k1(true)
            }
            "Stellar" ->{
                privateKey.publicKeyEd25519
            }
            "VeChain" ->{
                privateKey.getPublicKeySecp256k1(true)
            }
            "Near" ->{
                privateKey.publicKeyEd25519
            }
            "Zilliqa" ->{
                privateKey.getPublicKeySecp256k1(true)
            }
            "Theta" ->{
                privateKey.getPublicKeySecp256k1(true)
            }
            "Cardano" ->{
                privateKey.publicKeyEd25519Cardano
            }
            "MultiversX" ->{
                privateKey.publicKeyEd25519
            }
            "Ton" ->{
                privateKey.publicKeyEd25519
            }
            else -> null
        }
        return if(publicKey==null){
            null
        }else{
            aBase64.encodeToString(publicKey.data(),aBase64.NO_WRAP)
        }
    }

    //@RequiresApi(Build.VERSION_CODES.O)
    private fun getPrivateKey(wallet: HDWallet, coin: String, path: String): String? {
        val coinType:CoinType=getCoinTypeWithCoinString(coin)
        val privateKey = wallet.getKey(coinType, path)
        return aBase64.encodeToString(privateKey.data(),aBase64.NO_WRAP)
    }

    private fun signTransactionMaxValue(wallet: HDWallet?, coin: String, path: String, txData: Map<String, Any>,pk:PrivateKey?): String? {
        val chainType:String =getChainTypeWithCoinString(coin)
        if(chainType == ""){
            return null
        }
        val coinType:CoinType= getCoinTypeWithCoinString(coin)
        return when(chainType){
            "Bitcoin" ->{
                signBitcoinTransactionMaxValue(wallet, path, txData,coinType,pk)
            }
            else -> null
        }
    }

    private fun signTransaction(wallet: HDWallet?, coin: String, path: String, txData: Map<String, Any>,pk:PrivateKey?): String? {
        val chainType:String =getChainTypeWithCoinString(coin)
        if(chainType == ""){
            return null
        }
        val coinType:CoinType= getCoinTypeWithCoinString(coin)
        return when(chainType){
            "Bitcoin" ->{
                signBitcoinTransaction(wallet, path, txData,coinType,pk)
            }
            "Ethereum" ->{
                signEthereumTransactionErc721(wallet, path, txData,coinType,pk)
                //signEthereumTransaction(wallet, path, txData,coinType,pk)
            }
            "Tron" ->{
                signTronTransaction(wallet, path, txData,pk)
            }
            "Tezos" ->{
                signTezosTransaction(wallet, path, txData,pk)
            }
            "Solana" ->{
                signSolanaTransaction(wallet, path, txData,pk)
            }
            "Ripple" ->{
                signXRPTransaction(wallet,path,txData,pk)
            }
            "Cosmos" ->{
                signCosmosTransaction(wallet,path,txData,pk)
            }
            "Filecoin" ->{
                signFilecoinTransaction(wallet,path,txData,pk)
            }
            "Polkadot" ->{
                signPOLKADOTTransaction(wallet,path,txData,coinType,pk)
            }
            "Acala" ->{
                signPOLKADOTTransaction(wallet,path,txData,coinType,pk)
            }
            "Kusama" ->{
                signPOLKADOTTransaction(wallet,path,txData,coinType,pk)
            }
            "Aptos" ->{
                signAptosTransaction(wallet,path,txData,pk)
            }
            "Sui" ->{
                signSuiTransaction(wallet, path, txData, pk)
            }
            "Ton"->{
                signTonTransaction(wallet, path, txData, pk)
            }
            "Stellar"->{
                signStellarTransaction(wallet, path, txData, pk)
            }
            "VeChain"->{
                signVeChainTransaction(wallet, path, txData, pk)
            }
            "Near"->{
                signNearTransaction(wallet, path, txData, pk)
            }
            "Zilliqa"->{
                signZilliqaTransaction(wallet, path, txData, pk)
            }
            "Theta"->{
                signThetaTransaction(wallet, path, txData, pk)
            }
            "Cardano"->{
                signCardanoTransaction(wallet, path, txData, pk)
            }
            "MultiversX"->{
                signMultiversXTransaction(wallet, path, txData, pk)
            }
            else -> null
        }
    }

    private fun signTransactionByteArray(wallet: HDWallet?, coin: String, path: String, txData: Map<String, Any>,pk:PrivateKey?): String? {
        return when(coin) {
            "ALGO" -> {
                signAlgorandTransaction(wallet,path,txData,pk)
            }
            else -> null
        }
    }
    private fun signMessage(wallet: HDWallet?, coin: String, path: String, txData: String,pk:PrivateKey?): String? {
        val chainType:String =getChainTypeWithCoinString(coin)
        if(chainType == ""){
            return null
        }
        val coinType: CoinType = getCoinTypeWithCoinString(coin)
        val privateKey= pk ?: wallet!!.getKey(coinType, path)
        if(coinType==CoinType.TRON){

            val ba : ByteArray=privateKey.sign(txData.toByteArray(),coinType.curve())
            return Numeric.toHexString(ba)
        }
        if(coinType==CoinType.SOLANA){
            // WalletConnect sends message as base64; sign raw bytes and return base64 signature
            val messageBytes: ByteArray = aBase64.decode(txData, aBase64.DEFAULT)
            val sig: ByteArray = privateKey.sign(messageBytes, coinType.curve())
            return aBase64.encodeToString(sig, aBase64.NO_WRAP)
        }
        if(coinType==CoinType.APTOS || coinType==CoinType.TON || coinType==CoinType.NEAR){
            // WalletConnect sends plain text messages; sign UTF-8 bytes and return hex signature
            val sig: ByteArray = privateKey.sign(txData.toByteArray(Charsets.UTF_8), coinType.curve())
                ?: return null
            return Numeric.toHexString(sig)
        }
        if(coinType==CoinType.SUI){
            // WalletConnect sends base64-encoded message bytes
            val messageBytes: ByteArray = aBase64.decode(txData, aBase64.DEFAULT)
            val sig: ByteArray = privateKey.sign(messageBytes, coinType.curve()) ?: return null
            return aBase64.encodeToString(sig, aBase64.NO_WRAP)
        }
        val ba : ByteArray=privateKey.sign(Numeric.hexStringToByteArray(txData),coinType.curve())
        return Numeric.toHexString(ba)
    }
    private fun signCosmosTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>,pk: PrivateKey?): String? {
        val privateKey= pk ?: wallet!!.getKey(CoinType.COSMOS, path)
        val token:Map<String, Any>? = txData["token"] as Map<String, Any>?
        val feeMap:Map<String, Any> = txData["fee"] as Map<String, Any>
        val amount:Map<String, Any> = txData["amount"] as Map<String, Any>

        val chainId: String = txData["chainId"] as String
        val fromAddress : String = CoinType.COSMOS.deriveAddress(privateKey)
        val toAddress : String = txData["toAddress"] as String
        //val amount: String = txData["amount"] as String
        val accountNumber: Long = (txData["accountNumber"] as String).toLong()
        val sequence: Long = (txData["sequence"] as String).toLong()
        val memo:String = txData["memo"] as String

        val fee =Cosmos.Fee.newBuilder()
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

        if(token==null){
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
        }else{
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
        val result = AnySigner.sign(input.build(),CoinType.COSMOS,Cosmos.SigningOutput.parser())
        return result.json
        //val a=result.json.toByteArray()
        //return Numeric.toHexString(result.json.toByteArray())
    }

    private fun signTronTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>,pk:PrivateKey?): String? {
        val cmd = txData["cmd"] as String
        val privateKey= pk ?: wallet!!.getKey(CoinType.TRON, path)
        val txHash: String?
        val number: Number = txData["number"] as Number
        val blockTime: Number = txData["blockTime"] as Number
        val timestamp : Number = txData["timestamp"] as Number
        val version : Int =txData["version"] as Int
        when(cmd) {
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
                    //.setFeeLimit((txData["feeLimit"] as Int).toLong())
                    .build()

                val signingInput = Tron.SigningInput.newBuilder()
                    .setTransaction(transaction)
                    .setPrivateKey(ByteString.copyFrom(privateKey.data()))

                val output = AnySigner.sign(signingInput.build(), CoinType.TRON, Tron.SigningOutput.parser())
                txHash = output.json
            }
            "FREEZE" -> {
                val frozenDuration : Number = txData["frozenDuration"] as Number
                val frozenBalance : Number = txData["frozenBalance"] as Number
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

                //val output =AnySigner.signJSON("",privateKey.data(),CoinType.TRON.value())
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

    private fun signTezosTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>,pk: PrivateKey?): String {
        val privateKey= pk ?: wallet!!.getKey(CoinType.TEZOS, path)
        val publickKey: ByteString = ByteString.copyFrom(privateKey.publicKeyEd25519.data())
        val branchStr: String =txData["branch"] as String
        val fee: Long =(txData["fee"] as Number).toLong()
        val gasLimit: Long =(txData["gasLimit"] as Number).toLong()
        val amount: Long =(txData["amount"] as Number).toLong()
        val toAddress: String = txData["toAddress"] as String
        val counter: Long=(txData["counter"] as Number).toLong()
        val storageLimit: Long=(txData["storageLimit"] as Number).toLong()
        val reveal: Boolean = txData["reveal"] as Boolean
        val contractAddres : String = txData["contractAddres"] as String
        val fromAddress = CoinType.TEZOS.deriveAddress(privateKey)

        val tOperation  =Tezos.Operation.newBuilder()
            .setKind(Tezos.Operation.OperationKind.TRANSACTION).setFee(fee)
            .setSource(fromAddress)
            .setGasLimit(gasLimit)
            .setStorageLimit(storageLimit)
        //.setCounter(counter+1)

        if(contractAddres == ""){
            tOperation.setTransactionOperationData(
                Tezos.TransactionOperationData.newBuilder()
                    .setAmount(amount)
                    .setDestination(toAddress)
            )
        }else{
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

        val input =Tezos.SigningInput.newBuilder()
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
        if (!reveal) {
            tOperation.setCounter(counter+1)
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

        }
        else{
            tOperation.setCounter(counter)
            input.setOperationList(
                Tezos.OperationList.newBuilder()
                    .setBranch(branchStr)
                    .addOperations(tOperation)
            )
        }

        val result = AnySigner.sign(input.build(),CoinType.TEZOS,Tezos.SigningOutput.parser())
        return Numeric.toHexString(result.encoded.toByteArray())
    }

    private fun signXRPTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>,pk: PrivateKey?): String? {
        val privateKey= pk ?: wallet!!.getKey(CoinType.XRP, path)
        val amount: Long = (txData["amount"] as String).toLong()
        val sequence : Int = txData["sequence"] as Int
        val ledgerIndex : Int = txData["ledgerIndex"] as Int
        val account : String = CoinType.XRP.deriveAddress(privateKey)
        val destination : String = txData["toAddress"] as String
        val fee : Long = (txData["fee"] as String).toLong()
        val txType : String = txData["txType"] as String//Trustline,XRP,XRPL,
        val issuer : String = txData["issuer"] as String
        val currency : String = txData["currency"] as String
        val input : Ripple.SigningInput.Builder=Ripple.SigningInput.newBuilder()
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .setFee(fee)
            .setSequence(sequence)
            .setLastLedgerSequence(ledgerIndex+20)
            .setAccount(account)
        when (txType) {
            "Trustline" -> {
                //创建信任线
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
                //代币转账
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
                //主链转账
                input.setOpPayment(
                    Ripple.OperationPayment.newBuilder()
                        .setAmount(amount)
                        .setDestination(destination).build()
                )
            }
        }
        val output = AnySigner.sign(input.build(),CoinType.XRP,Ripple.SigningOutput.parser())
        return Numeric.toHexString(output.encoded.toByteArray())
    }

    private fun signEthereumTransactionErc721(wallet: HDWallet?, path: String, txData: Map<String, Any>,coinType : CoinType ,pk:PrivateKey?): String {
        val privateKey= pk ?: wallet!!.getKey(coinType, path)
        val chainId : String = txData["chainId"] as String
        val gasLimit : String = txData["gasLimit"] as String
        val gasPrice : String = txData["gasPrice"] as String
        val gasPrice2 : String = txData["gasPrice2"] as String
        val nonce : String = txData["nonce"] as String
        val toAddress : String = txData["toAddress"] as String
        val amount : String = txData["amount"] as String
        val erc721Or1155 : String = txData["erc721Or1155"] as String
        val messageData : String = txData["msgData"] as String
        val is1559 : String = txData["is1559"] as String

        val chainIdBS : ByteString = ByteString.copyFrom(BigInteger(chainId,16).toByteArray())
        val gasLimitBS : ByteString = ByteString.copyFrom(BigInteger(gasLimit,16).toByteArray())
        val gasPriceBS : ByteString = ByteString.copyFrom(BigInteger(gasPrice,16).toByteArray())
        val gasPrice2BS : ByteString = ByteString.copyFrom(BigInteger(gasPrice2,16).toByteArray())
        val nonceBS : ByteString = ByteString.copyFrom(BigInteger(nonce,16).toByteArray())
        val amountBS : ByteString = ByteString.copyFrom(BigInteger(amount,16).toByteArray())
        val messageDataBS : ByteString = ByteString.copyFrom(messageData.toByteArray())
        val privateKeyBS : ByteString = ByteString.copyFrom(privateKey.data())
        val input = Ethereum.SigningInput.newBuilder()
            //.setTxMode(Ethereum.TransactionMode.Enveloped)
            .setChainId(chainIdBS)
            .setGasLimit(gasLimitBS)
            //.setGasPrice(gasPriceBS)
            //.setMaxFeePerGas(gasPriceBS)
            //.setMaxInclusionFeePerGas(gasPrice2BS)
            .setNonce(nonceBS)
            .setPrivateKey(privateKeyBS)
        if(is1559 == "true"){
            input.setMaxFeePerGas(gasPriceBS)
            input.setMaxInclusionFeePerGas(gasPrice2BS)
            input.setTxMode(Ethereum.TransactionMode.Enveloped)
        }else{
            input.setGasPrice(gasPriceBS)
            input.setTxMode(Ethereum.TransactionMode.Legacy)
        }
        val contract : String = txData["contract"] as String
        if(contract==""){
            input.setToAddress(toAddress)
            input.setTransaction(Ethereum.Transaction.newBuilder()
                .setTransfer(Ethereum.Transaction.Transfer.newBuilder()
                    .setAmount(amountBS)
                    .setData(messageDataBS)
                )
            )
        } else if(erc721Or1155=="721"){
            val tokenIdBS : ByteString = ByteString.copyFrom(BigInteger((txData["tokenId"] as String),16).toByteArray())
            val fromAddress=coinType.deriveAddress(privateKey)
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
        } else if(erc721Or1155=="1155"){
            val tokenIdBS : ByteString = ByteString.copyFrom(BigInteger((txData["tokenId"] as String),16).toByteArray())
            val trValueBS : ByteString = ByteString.copyFrom(BigInteger((txData["trValue"] as String),16).toByteArray())
            val fromAddress=coinType.deriveAddress(privateKey)
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
        } else if(erc721Or1155=="approve"){
            input.setToAddress(contract)
            input.setTransaction(
                Ethereum.Transaction.newBuilder().setErc20Approve(
                    Ethereum.Transaction.ERC20Approve.newBuilder()
                        .setAmount(amountBS)
                        .setSpender(toAddress)
                )
            )
        }else{
            input.setToAddress(contract)
            input.setTransaction(
                Ethereum.Transaction.newBuilder().setErc20Transfer(
                    Ethereum.Transaction.ERC20Transfer.newBuilder()
                        .setAmount(amountBS)
                        .setTo(toAddress)
                )
            )
        }

        val result = AnySigner.sign(input.build(),coinType,Ethereum.SigningOutput.parser())
        return Numeric.toHexString(result.encoded.toByteArray())
    }
    private fun signEthereumTransactionWithData(wallet: HDWallet?, path: String, txData: Map<String, Any>,coinType : CoinType ,pk:PrivateKey?):String{
        val privateKey= pk ?: wallet!!.getKey(coinType, path)
        val chainId : String = txData["chainId"] as String
        val gasLimit : String = txData["gasLimit"] as String
        val gasPrice : String = txData["gasPrice"] as String
        val gasPrice2 : String = txData["gasPrice2"] as String
        val nonce : String = txData["nonce"] as String
        val toAddress : String = txData["toAddress"] as String
        val amount : String = txData["amount"] as String
        //val erc721Or1155 : String = txData["erc721Or1155"] as String
        val messageData : String = txData["msgData"] as String
        //val is1559 : String = txData["is1559"] as String
        val contract : String = txData["contract"] as String

        val chainIdBS : ByteString = ByteString.copyFrom(BigInteger(chainId,16).toByteArray())
        val gasLimitBS : ByteString = ByteString.copyFrom(BigInteger(gasLimit,16).toByteArray())
        val gasPriceBS : ByteString = ByteString.copyFrom(BigInteger(gasPrice,16).toByteArray())
        val gasPrice2BS : ByteString = ByteString.copyFrom(BigInteger(gasPrice2,16).toByteArray())
        val nonceBS : ByteString = ByteString.copyFrom(BigInteger(nonce,16).toByteArray())
        val amountBS : ByteString = ByteString.copyFrom(BigInteger(amount,16).toByteArray())
        val messageDataBS : ByteString = ByteString.copyFrom(messageData.toByteArray())
        val privateKeyBS : ByteString = ByteString.copyFrom(privateKey.data())
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


        val result = AnySigner.sign(input.build(),coinType,Ethereum.SigningOutput.parser())
        return Numeric.toHexString(result.encoded.toByteArray())
    }
    /**
     * Decode a Solana compact-u16 value from [data] starting at [offset].
     * Returns Pair(value, bytesConsumed).
     */
    private fun decodeCompactU16(data: ByteArray, offset: Int): Pair<Int, Int> {
        var value = 0
        var bytesRead = 0
        var shift = 0
        while (offset + bytesRead < data.size) {
            val byte = data[offset + bytesRead].toInt() and 0xFF
            bytesRead++
            value = value or ((byte and 0x7F) shl shift)
            if (byte and 0x80 == 0) break
            shift += 7
            if (shift >= 16) break
        }
        return Pair(value, bytesRead)
    }

    private fun signSolanaTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>,pk: PrivateKey?): String? {
        val privateKey= pk ?: wallet!!.getKey(CoinType.SOLANA, path)
        val type : String = txData["type"] as String
        val encodeType : String = txData["encodeType"] as String

        // WalletConnect raw transaction signing
        if (type == "WC_SOL") {
            val rawTxBase64: String = txData["transaction"] as String
            val rawTxBytes: ByteArray = aBase64.decode(rawTxBase64, aBase64.DEFAULT)
            // Solana tx layout: [compact-u16 numSigs][signatures: N×64 bytes][message]
            val (numSigs, headerBytes) = decodeCompactU16(rawTxBytes, 0)
            val messageOffset = headerBytes + numSigs * 64
            if (messageOffset >= rawTxBytes.size) return null
            val message = rawTxBytes.copyOfRange(messageOffset, rawTxBytes.size)
            // Sign the message with ed25519
            val signature: ByteArray = privateKey.sign(message, CoinType.SOLANA.curve()) ?: return null
            // Reconstruct signed transaction
            val signedTx = ByteArray(rawTxBytes.size)
            System.arraycopy(rawTxBytes, 0, signedTx, 0, headerBytes)             // compact-u16 header
            System.arraycopy(signature, 0, signedTx, headerBytes, minOf(64, signature.size)) // first sig
            // Remaining signature slots (if any) are already zeroed
            System.arraycopy(message, 0, signedTx, headerBytes + numSigs * 64, message.size)
            return aBase64.encodeToString(signedTx, aBase64.NO_WRAP)
        }

        //创建代币的地址
        if( type == "createTokenAccount"){
            val createTokenAccount: Map<String, String> = txData["createTokenAccount"] as Map<String, String>
            val mainAddress : String = createTokenAccount["mainAddress"] as String
            val tokenAddress : String = createTokenAccount["tokenAddress"] as String
            val tokenMintAddress : String = createTokenAccount["tokenMintAddress"] as String
            val input = Solana.SigningInput.newBuilder()
                .setCreateTokenAccountTransaction(
                    Solana.CreateTokenAccount.newBuilder()
                        .setMainAddress(mainAddress)
                        .setTokenAddress(tokenAddress)
                        .setTokenMintAddress(tokenMintAddress)
                )
                .setPrivateKey(ByteString.copyFrom(privateKey.data()))
                .setRecentBlockhash(txData["recentBlockhash"] as String)
            val result =AnySigner.sign(input.build(),CoinType.SOLANA,Solana.SigningOutput.parser())
            if(encodeType =="base64"){
                val signedTransaction = result.encoded.toByteArray()
                val base64EncodedTransaction = aBase64.encodeToString(signedTransaction,aBase64.NO_WRAP)
                return base64EncodedTransaction
            }else{
                return result.encoded
            }
        }
        //代币转账
        else if (type == "token"){
            val transferTransaction: Map<String, String> = txData["tokenTransferTransaction"] as Map<String, String>
            val amount: String = transferTransaction["amount"] as String
            val tokenMintAddress : String = transferTransaction["tokenMintAddress"] as String
            val senderTokenAddress : String = SolanaAddress(transferTransaction["senderTokenAddress"] as String).defaultTokenAddress(tokenMintAddress)
            val recipient: String = SolanaAddress(transferTransaction["recipientMainAddress"] as String).defaultTokenAddress(tokenMintAddress)
            val decimals : String = transferTransaction["decimals"] as String
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
            //val output = Solana.SigningOutput.newBuilder()
            val result =AnySigner.sign(input.build(),CoinType.SOLANA,Solana.SigningOutput.parser())
            if(encodeType =="base64"){
                val signedTransaction = result.encoded.toByteArray()
                val base64EncodedTransaction = aBase64.encodeToString(signedTransaction,aBase64.NO_WRAP)
                return base64EncodedTransaction
            }else{
                return result.encoded
            }
        }
        //代币转账+创建地址
        else if (type == "tokenCreate"){
            val transferTransaction: Map<String, String> = txData["tokenTransferTransaction"] as Map<String, String>
            var recipientTokenAddress: String = transferTransaction["recipientTokenAddress"] as String
            val recipientMainAddress: String = transferTransaction["recipientMainAddress"] as String
            val amount: String = transferTransaction["amount"] as String
            val tokenMintAddress : String = transferTransaction["tokenMintAddress"] as String
            val senderTokenAddress : String = SolanaAddress(transferTransaction["senderTokenAddress"] as String).defaultTokenAddress(tokenMintAddress)
            val decimals : String = transferTransaction["decimals"] as String

            val input = Solana.SigningInput.newBuilder()
                .setPrivateKey(ByteString.copyFrom(privateKey.data()))
                .setRecentBlockhash(txData["recentBlockhash"] as String)

            if(recipientTokenAddress==""){
                recipientTokenAddress = SolanaAddress(recipientMainAddress).defaultTokenAddress(tokenMintAddress)
                input.setCreateAndTransferTokenTransaction(
                    Solana.CreateAndTransferToken.newBuilder()
                        .setSenderTokenAddress(senderTokenAddress)//发送者账号
                        .setTokenMintAddress(tokenMintAddress)//合约地址
                        .setRecipientMainAddress(recipientMainAddress)//接收者地址
                        .setRecipientTokenAddress(recipientTokenAddress)//接收者账号
                        .setDecimals(decimals.toInt())
                        .setAmount(amount.toLong()))
            }else{
                input.setTokenTransferTransaction(
                    Solana.TokenTransfer.newBuilder()
                        .setRecipientTokenAddress(recipientTokenAddress)
                        .setAmount(amount.toLong())
                        .setTokenMintAddress(tokenMintAddress)
                        .setSenderTokenAddress(senderTokenAddress)
                        .setDecimals(decimals.toInt())
                )
            }
            val result =AnySigner.sign(input.build(),CoinType.SOLANA,Solana.SigningOutput.parser())
            if(encodeType =="base64"){
                val signedTransaction = result.encoded.toByteArray()
                val base64EncodedTransaction = aBase64.encodeToString(signedTransaction,aBase64.NO_WRAP)
                return base64EncodedTransaction
            }else{
                return result.encoded
            }
        }
        //主链币转账
        else{
            val transferTransaction: Map<String, String> = txData["transferTransaction"] as Map<String, String>
            val recipient: String = transferTransaction["recipient"] as String
            val value: String = transferTransaction["value"] as String
            val input = Solana.SigningInput.newBuilder()
                .setPrivateKey(ByteString.copyFrom(privateKey.data()))
                .setRecentBlockhash(txData["recentBlockhash"] as String)
                .setTransferTransaction(
                    Solana.Transfer.newBuilder().setRecipient(recipient).setValue(value.toLong()).build()
                )
            //val output = Solana.SigningOutput.newBuilder()
            val result =AnySigner.sign(input.build(),CoinType.SOLANA,Solana.SigningOutput.parser())
            if(encodeType =="base64"){
                val signedTransaction = result.encoded.toByteArray()
                val base64EncodedTransaction = aBase64.encodeToString(signedTransaction,aBase64.NO_WRAP)
                return base64EncodedTransaction
            }else{
                return result.encoded
            }
        }


        /*
        val privateKey = wallet.getKey(CoinType.SOLANA, path)
        val opJson =  JSONObject(txData).toString()
        val result = AnySigner.signJSON(opJson, privateKey.data(), CoinType.SOLANA.value())
        return result*/
    }

    private fun signBitcoinTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>,coinType: CoinType,pk: PrivateKey?): String {
        val privateKey= pk ?: wallet!!.getKey(coinType, path)
        val utxos: List<Map<String, Any>> = txData["utxo"] as List<Map<String, Any>>

        val amount:Long = (txData["amount"] as Number).toLong()
        val useMaxAmount: Boolean = txData["max"] as Boolean
        var input = Bitcoin.SigningInput.newBuilder()
            //.setUseMaxAmount(useMaxAmount)
            //.setAmount(amount)
            .setByteFee((txData["byteFee"] as Number).toLong())
            .setChangeAddress(txData["changeAddress"] as String)
            .setToAddress(txData["toAddress"] as String)
            .setCoinType(coinType.value())
            .setHashType(BitcoinScript.hashTypeForCoin(coinType))
            .addPrivateKey(ByteString.copyFrom(privateKey.data()))
        if (useMaxAmount){
            input.setUseMaxAmount(true)
        }else{
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
        // **使用 Trust Wallet Core 进行部分签名**
        //val plan = AnySigner.plan(input.build(), coinType, Bitcoin.TransactionPlan.parser())

        // **这里 Trust Wallet Core 只会使用已提供的私钥进行签名**
        val output = AnySigner.sign(input.build(), coinType, Bitcoin.SigningOutput.parser())

        // **返回部分签名的交易（PSBT 格式）**
        return Numeric.toHexString(output.encoded.toByteArray())
        //val output = AnySigner.sign(input.build(), coinType, Bitcoin.SigningOutput.parser())
        //return  Numeric.toHexString(output.encoded.toByteArray())
    }
    private fun signBitcoinTransactionP2wsh(wallet: HDWallet?, path: String, txData: Map<String, Any>,pk: PrivateKey?): String {
        val privateKey= pk ?: wallet!!.getKey(CoinType.BITCOIN, path)

        val utxos: List<Map<String, Any>> = txData["utxo"] as List<Map<String, Any>>
        val amount:Long = (txData["amount"] as Number).toLong()
        val useMaxAmount: Boolean = txData["max"] as Boolean
        val transactionV2 =BitcoinV2.TransactionBuilder.newBuilder()
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
            val inputV2 =BitcoinV2.Input.newBuilder()
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
        //.addOutputs(outputV2)
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
        val preImageHashes = TransactionCompiler.preImageHashes(CoinType.BITCOIN,legacySigningInput.build().toByteArray())
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
    //返回最大转账金额
    private fun signBitcoinTransactionMaxValue(wallet: HDWallet?, path: String, txData: Map<String, Any>,coinType: CoinType,pk: PrivateKey?): String {
        val privateKey= pk ?: wallet!!.getKey(coinType, path)
        val utxos: List<Map<String, Any>> = txData["utxo"] as List<Map<String, Any>>
        val useMaxAmount: Boolean = txData["max"] as Boolean
        val amount:Long = (txData["amount"] as Number).toLong()

        val input = Bitcoin.SigningInput.newBuilder()
            //.setUseMaxAmount(useMaxAmount)
            .setByteFee((txData["byteFee"] as Number).toLong())
            //.setAmount(amount)
            .setChangeAddress(txData["changeAddress"] as String)
            .setToAddress(txData["toAddress"] as String)
            .setCoinType(coinType.value())
            .setHashType(BitcoinScript.hashTypeForCoin(coinType))
            .addPrivateKey(ByteString.copyFrom(privateKey.data()))
        if (useMaxAmount){
            input.setUseMaxAmount(true)
        }else{
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
        // **使用 Trust Wallet Core 进行部分签名**
        val plan = AnySigner.plan(input.build(), coinType, Bitcoin.TransactionPlan.parser())

        // **这里 Trust Wallet Core 只会使用已提供的私钥进行签名**
        val output = AnySigner.sign(input.setPlan(plan).build(), coinType, Bitcoin.SigningOutput.parser())

        // **返回部分签名的交易（PSBT 格式）**
        //return Numeric.toHexString(output.encoded.toByteArray())
        //val output = AnySigner.sign(input.build(), coinType, Bitcoin.SigningOutput.parser())
        val size = output.encoded.toByteArray().size
        return size.toString()
    }

    private fun signFilecoinTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>,pk:PrivateKey?): String?{
        val privateKey= pk ?: wallet!!.getKey(CoinType.FILECOIN, path)
        val gasLimit : String = txData["gasLimit"] as String
        val gasFeeCap : String = txData["gasFeeCap"] as String
        val gasPremium : String = txData["gasPremium"] as String
        val nonce : String = txData["nonce"] as String
        val toAddress : String = txData["toAddress"] as String
        val amount : String = txData["amount"] as String
        val input=Filecoin.SigningInput.newBuilder()
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .setTo(toAddress)
            .setNonce(nonce.toLong())
            .setValue(ByteString.copyFrom(BigInteger((amount),16).toByteArray()))
            .setGasLimit(gasLimit.toLong())
            .setGasFeeCap(ByteString.copyFrom(BigInteger((gasFeeCap),16).toByteArray()))
            .setGasPremium(ByteString.copyFrom(BigInteger(gasPremium,16).toByteArray()))

        val result = AnySigner.sign(input.build(),CoinType.FILECOIN,Filecoin.SigningOutput.parser())
        return result.json

    }

    private fun signAlgorandTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>,pk:PrivateKey?): String {
        val privateKey = pk ?: wallet!!.getKey(CoinType.ALGORAND, path)
        val type : String =txData["type"] as String
        val amount : Long = (txData["amount"] as String).toLong()//转账金额
        val genesisHash : ByteArray? =aBase64.decode(txData["genesisHash"] as String,16)
        val fee : Long =(txData["fee"] as Int).toLong()//gas费
        val round : Long =(txData["round"] as Int).toLong()//最新块
        val toAddress : String = txData["toAddress"] as String
        val input = Algorand.SigningInput.newBuilder()
            .setGenesisId(txData["genesisId"] as String)
            .setGenesisHash(ByteString.copyFrom(genesisHash))
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .setFirstRound(round)
            .setLastRound(round+fee)
            .setFee(fee)

        when (type) {
            "Asset" -> {
                val assetId : Long =(txData["assetId"] as String).toLong()//代币id
                input.setAssetTransfer(Algorand.AssetTransfer.newBuilder()
                    .setAmount(amount)
                    .setAssetId(assetId)
                    .setToAddress(toAddress)
                )
            }
            "Add" -> {
                val assetId : Long =(txData["assetId"] as String).toLong()//代币id
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

        val result = AnySigner.sign(input.build(),CoinType.ALGORAND,Algorand.SigningOutput.parser())
        val rValue :Map<String,Any> = mapOf("result" to true,"signHash" to Numeric.toHexString(result.encoded.toByteArray()))
        return JSONObject(rValue).toString()
    }

    private fun signPOLKADOTTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any> ,coinType : CoinType,pk:PrivateKey?): String {
        val privateKey= pk ?: wallet!!.getKey(coinType, path)
        //val contract : String =txData["contract"] as String
        val amount : String = txData["amount"] as String//转账金额
        val genesisHash : ByteArray =Numeric.hexStringToByteArray(txData["genesisHash"] as String)
        val blockHash : ByteArray =Numeric.hexStringToByteArray(txData["blockHash"] as String)
        val nonce : Long =(txData["nonce"] as Int).toLong()
        val specVersion : Int =txData["specVersion"] as Int
        val transactionVersion : Int =txData["transactionVersion"] as Int
        val toAddress : String = txData["toAddress"] as String
        val blockNumber : Long = (txData["blockNumber"] as Int).toLong()
        val input =Polkadot.SigningInput.newBuilder()
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
        val output = AnySigner.sign(input,coinType,Polkadot.SigningOutput.parser())
        return Numeric.toHexString(output.encoded.toByteArray())
    }

    private fun signAptosTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>,pk:PrivateKey?): String{
        val privateKey= pk ?: wallet!!.getKey(CoinType.APTOS, path)

        val type = txData["type"] as? String ?: ""
        if (type == "WC_APT") {
            // WalletConnect: DApp sends pre-built BCS-encoded raw transaction (base64)
            // anyEncoded field expects hex string of the raw transaction bytes
            val rawTxBase64 = txData["encodedTransaction"] as? String ?: return ""
            val rawBytes = aBase64.decode(rawTxBase64, aBase64.DEFAULT)
            val input = Aptos.SigningInput.newBuilder()
                .setAnyEncoded(Numeric.toHexString(rawBytes))
                .setPrivateKey(ByteString.copyFrom(privateKey.data()))
                .build()
            val output = AnySigner.sign(input, CoinType.APTOS, Aptos.SigningOutput.parser())
            return aBase64.encodeToString(output.encoded.toByteArray(), aBase64.NO_WRAP)
        }

        val gasUnitPrice : Long = txData["gasUnitPrice"] as Long
        val maxGasAmount : Long = txData["maxGasAmount"] as Long
        val expirationTimestampSecs : Long = txData["expirationTimestampSecs"] as Long
        val toAddress : String = txData["toAddress"] as String
        val senderAddress : String = txData["fromAddress"] as String
        val amount : Long = txData["amount"] as Long
        val chainId : Int = txData["chainId"] as Int
        val sequenceNumber : Long = txData["SequenceNumber"] as Long
        val contractAddress : String = txData["contractAddress"] as String
        val contractModule : String = txData["contractModule"] as String
        val contractName : String = txData["contractName"] as String

        val input = Aptos.SigningInput.newBuilder()
            .setChainId(chainId)
            .setSender(senderAddress)
            .setSequenceNumber(sequenceNumber)
            .setGasUnitPrice(gasUnitPrice)
            .setMaxGasAmount(maxGasAmount)
            .setExpirationTimestampSecs(expirationTimestampSecs)
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
        if(contractAddress ==""){
            val transfer = Aptos.TransferMessage.newBuilder()
                .setAmount(amount)
                .setTo(toAddress).build()
            input.transfer=transfer
        }else{
            val structTag =Aptos.StructTag.newBuilder()
                .setAccountAddress(contractAddress)
                .setModule(contractModule)
                .setName(contractName)
                .build()
            val transfer = Aptos.TokenTransferCoinsMessage.newBuilder()
                .setAmount(amount)
                .setTo(toAddress)
                .setFunction(structTag)
                .build()
            input.tokenTransferCoins=transfer
            /*input.setFungibleAssetTransfer(
              Aptos.FungibleAssetTransferMessage.newBuilder()
                .setMetadataAddress(contractAddress)
                .setAmount(amount)
                .setTo(toAddress)
            )*/
        }

        val output = AnySigner.sign(input.build(), CoinType.APTOS, Aptos.SigningOutput.parser())
        return Numeric.toHexString(output.encoded.toByteArray())
    }
    private fun signSuiTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>,pk:PrivateKey?): String{
        val privateKey= pk ?: wallet!!.getKey(CoinType.SUI, path)

        val type = txData["type"] as? String ?: ""
        if (type == "WC_SUI") {
            // WalletConnect: DApp sends base64-encoded BCS transaction block (SignDirect)
            // unsignedTxMsg is a string field (base64 or raw tx string)
            val rawTxBase64 = txData["transaction"] as? String ?: return ""
            val signDirect = Sui.SignDirect.newBuilder()
                .setUnsignedTxMsg(rawTxBase64)
                .build()
            val input = Sui.SigningInput.newBuilder()
                .setSignDirectMessage(signDirect)
                .setPrivateKey(ByteString.copyFrom(privateKey.data()))
                .build()
            val output = AnySigner.sign(input, CoinType.SUI, Aptos.SigningOutput.parser())
            return aBase64.encodeToString(output.encoded.toByteArray(), aBase64.NO_WRAP)
        }

        val referenceGasPrice : Long = txData["referenceGasPrice"] as Long
        val gasBudget : Long = txData["gasBudget"] as Long
        val toAddress : String = txData["toAddress"] as String
        val amount : Long = txData["amount"] as Long
        val utxos: List<Map<String, Any>> = txData["utxo"] as List<Map<String, Any>>

        val paySui = Sui.PaySui.newBuilder()
            .addRecipients(toAddress)
            .addAmounts(amount)
        for (utx in utxos) {
            paySui.addInputCoins(
                Sui.ObjectRef.newBuilder()
                    .setObjectId(utx["objectId"] as String)
                    .setVersion(utx["version"] as Long)
                    .setObjectDigest(utx["objectDigest"] as String)
            )
        }

        val signingInput = Sui.SigningInput.newBuilder()
            .setPaySui(paySui)
            .setPrivateKey(ByteString.copyFrom(privateKey.data()))
            .setGasBudget(gasBudget)//最大gas，你愿意出多少gas price
            .setReferenceGasPrice(referenceGasPrice)//每个单位的价格
            .build()

        val output = AnySigner.sign(signingInput, CoinType.SUI, Aptos.SigningOutput.parser())
        return Numeric.toHexString(output.encoded.toByteArray())
    }
    private fun signTonTransaction(wallet: HDWallet?, path: String, txData: Map<String, Any>,pk:PrivateKey?): String?{
        val privateKey = pk ?: wallet!!.getKey(CoinType.TON, path)

        val expireAt : Int = txData["expireAt"] as Int
        val sequenceNumber : Int = txData["sequenceNumber"] as Int
        val toAddress : String = txData["toAddress"] as String
        val fromAddress : String = txData["fromAddress"] as String
        val amount : ByteArray = Numeric.hexStringToByteArray(txData["amount"] as String)
        val contractAddress : String = txData["contractAddress"] as String
        val maxGasAmount : ByteArray = Numeric.hexStringToByteArray(txData["maxGasAmount"] as String)
        if(contractAddress == ""){
            /*
          * Bounceable 的作用
      如果设置为 true（Bounceable）：
      如果目标地址是合约，但无法处理消息（比如还未部署），消息将被退回（bounce back）。
      通常用于发送到已部署的合约地址，消息失败不会丢失。
      如果设置为 false（Non-Bounceable）：
      消息发送后，不论目标是否存在，不会退回。
      适合发送给不能处理返回的外部钱包地址（如交易所地址）。*/
            val transfer = TheOpenNetwork.Transfer.newBuilder()
                .setDest(toAddress)//to Address
                .setAmount(ByteString.copyFrom(amount))//转账金额
                .setMode(TheOpenNetwork.SendMode.PAY_FEES_SEPARATELY_VALUE or TheOpenNetwork.SendMode.IGNORE_ACTION_PHASE_ERRORS_VALUE)
                .setBounceable(true)
                .setComment("")
                .build()

            val input = TheOpenNetwork.SigningInput.newBuilder()
                .setPrivateKey(ByteString.copyFrom(privateKey.data()))
                .addMessages(transfer)
                .setSequenceNumber(sequenceNumber)//钱包的当前 seqno，必须与链上钱包的 seqno 一致。
                .setExpireAt(expireAt)//交易过期时间
                .setWalletVersion(TheOpenNetwork.WalletVersion.WALLET_V4_R2)
                .build()

            val output = AnySigner.sign(input, CoinType.TON, TheOpenNetwork.SigningOutput.parser())
            return aBase64.encodeToString(output.encoded.toByteArray(),aBase64.NO_WRAP)
        }else{
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
            return aBase64.encodeToString(output.encoded.toByteArray(),aBase64.NO_WRAP)
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

        val type = txData["type"] as? String ?: ""
        if (type == "WC_NEAR") {
            // WalletConnect: DApp sends base64-encoded borsh-encoded Transaction
            val rawTxBase64 = txData["transaction"] as? String ?: return null
            val rawTxBytes = aBase64.decode(rawTxBase64, aBase64.DEFAULT)
            // NEAR signing: SHA-256 of raw borsh tx bytes
            val hash = java.security.MessageDigest.getInstance("SHA-256").digest(rawTxBytes)
            // Sign the hash with ed25519
            val signature = privateKey.sign(hash, Curve.ED25519) ?: return null
            // NEAR SignedTransaction borsh = raw_tx_bytes + [0x00 key_type] + signature (64 bytes)
            val signedTx = rawTxBytes + byteArrayOf(0x00.toByte()) + signature
            return aBase64.encodeToString(signedTx, aBase64.NO_WRAP)
        }

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
        val version:Int = txData["version"] as Int
        val code: String = txData["code"] as String? ?: ""
        val data: String = txData["data"] as String? ?: ""

        val transaction = Zilliqa.Transaction.newBuilder()
            .setTransfer(
                Zilliqa.Transaction.Transfer.newBuilder()
                    .setAmount(ByteString.copyFrom(amount))
            )
            .build()

        val input = Zilliqa.SigningInput.newBuilder()
            .setVersion(version) // Mainnet version
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

        // Add private keys
        inputBuilder.addPrivateKey(ByteString.copyFrom(privateKey.data()))

        // Add UTXOs
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

        // Create transfer message
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

    //获取CoinType 根据 coin symbol
    private fun getCoinTypeWithCoinString(coin:String):CoinType{
        return when(coin) {
            "BTC" -> {
                CoinType.BITCOIN
            }
            "LTC" -> {
                CoinType.LITECOIN
            }
            "DOGE" -> {
                CoinType.DOGECOIN
            }
            "DASH" -> {
                CoinType.DASH
            }
            "VIA" -> {
                CoinType.VIACOIN
            }
            "DGB" -> {
                CoinType.DIGIBYTE
            }
            "MONA" -> {
                CoinType.MONACOIN
            }
            "FIRO" -> {
                CoinType.FIRO
            }
            "BCH" -> {
                CoinType.BITCOINCASH
            }
            "BTG" -> {
                CoinType.BITCOINGOLD
            }
            "RVN" -> {
                CoinType.RAVENCOIN
            }
            "QTUM" -> {
                CoinType.QTUM
            }
            "XEC" -> {
                CoinType.BITCOIN
            }
            "ETH" -> {
                CoinType.ETHEREUM
            }
            "ETC" -> {
                CoinType.ETHEREUMCLASSIC
            }
            "HT" -> {
                CoinType.ECOCHAIN
            }
            "XDAI" -> {
                CoinType.XDAI
            }
            "N" -> {
                CoinType.ETHEREUM
            }
            "MATIC" -> {
                CoinType.POLYGON
            }
            "AVAX" -> {
                CoinType.AVALANCHECCHAIN
            }
            "CELO" -> {
                CoinType.ETHEREUM
            }
            "BNB" -> {
                CoinType.ETHEREUM
            }
            "FTM" -> {
                CoinType.FANTOM
            }
            "POA" -> {
                CoinType.POANETWORK
            }
            "CLO" -> {
                CoinType.CALLISTO
            }
            "VIC" -> {
                CoinType.VICTION
            }
            "TT" -> {
                CoinType.THUNDERCORE
            }
            "GO" -> {
                CoinType.GOCHAIN
            }
            "WAN" -> {
                CoinType.WANCHAIN
            }
            "OKT" -> {
                CoinType.ETHEREUM
            }
            "MTR" -> {
                CoinType.ETHEREUM
            }
            "KLAY" -> {
                CoinType.ETHEREUM
            }
            "GLMR" -> {
                CoinType.ETHEREUM
            }
            "MOVR" -> {
                CoinType.ETHEREUM
            }
            "EVMOS" -> {
                CoinType.ETHEREUM
            }
            "BOBA" -> {
                CoinType.ETHEREUM
            }
            "KCS" -> {
                CoinType.ETHEREUM
            }
            "KAVA" -> {
                CoinType.ETHEREUM
            }
            "CRO" -> {
                CoinType.ETHEREUM
            }
            "OP" -> {
                CoinType.ETHEREUM
            }
            "ARB" -> {
                CoinType.ETHEREUM
            }
            "AURORA" -> {
                CoinType.ETHEREUM
            }
            "METIS" -> {
                CoinType.ETHEREUM
            }
            "XTZ" -> {
                CoinType.TEZOS
            }
            "TRX" -> {
                CoinType.TRON
            }
            "SOL" -> {
                CoinType.SOLANA
            }
            "ALGO" -> {
                CoinType.ALGORAND
            }
            "XRP" -> {
                CoinType.XRP
            }
            "ATOM" -> {
                CoinType.COSMOS
            }
            "ZETA" -> {
                CoinType.ETHEREUM
            }
            "BASE" -> {
                CoinType.BASE
            }
            "FIL" -> {
                CoinType.FILECOIN
            }
            "DOT" -> {
                CoinType.POLKADOT
            }
            "ACA" -> {
                CoinType.ACALA
            }
            "KSM" -> {
                CoinType.KUSAMA
            }
            "APT" -> {
                CoinType.APTOS
            }
            "SUI" -> {
                CoinType.SUI
            }
            "TON" -> {
                CoinType.TON
            }
            "S" -> {
                CoinType.ETHEREUM
            }
            "XLM" -> {
                CoinType.STELLAR
            }
            "VET" -> {
                CoinType.VECHAIN
            }
            "ONE" -> {
                CoinType.HARMONY
            }
            "IOTX" -> {
                CoinType.IOTEX
            }
            "NEAR" -> {
                CoinType.NEAR
            }
            "ZIL" -> {
                CoinType.ZILLIQA
            }
            "THETA" -> {
                CoinType.THETA
            }
            "ADA" -> {
                CoinType.CARDANO
            }
            "EGLD" -> {
                CoinType.MULTIVERSX
            }
            else -> CoinType.ETHEREUM
        }
    }
    //获取chainType 根据 coin symbol
    private fun getChainTypeWithCoinString(coin:String):String{
        return when(coin) {
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

    private var mp:MediaPlayer? = null
    private fun playAudio():String{
        mp = MediaPlayer.create(context, R.raw.silent)

        mp?.isLooping=true
        mp?.start()
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_HOME)
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(context,intent,Bundle.EMPTY)

        return "true"
    }
    private fun playAudioEnd():String{
        if(mp != null){
            mp?.stop()
            return "true"
        }else{
            return "false"
        }

    }

}

object WebSocketEventChannelHandler : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun send(message: String) {
        eventSink?.success(message)
    }

    fun sendError(code: String, message: String, details: Any? = null) {
        eventSink?.error(code, message, details)
    }
}
