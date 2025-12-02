package mining.ai.n42.www.flutter_mining

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import evmsdk.Evmsdk
import org.json.JSONObject
import com.mobileSdk.Api

/** FlutterMiningPlugin */
class FlutterMiningPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_mining")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when(call.method){
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "emit" -> {
                val paramsJson:String? = call.arguments as String?
                //执行sdk的通用方法
                val responseStringJson = Evmsdk.emit(paramsJson)
                if(responseStringJson != null){
                    result.success(responseStringJson)
                }else{
                    result.error("Evm","evm response no data",null)
                }
            }
            //获取公私钥对
            "generateBls12381Keypair" -> {
                try {
                    val keyPair = Api.generateBls12381Keypair()
                    result.success(keyPair)
                }catch (e: Exception) {
                    result.error("DepositError", e.message, null)
                }
            }
// 生成存款交易（未签名）
            "createDepositUnsignedTx" -> {
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

// 生成退出交易（未签名）
            "createExitUnsignedTx" -> {
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
            //生成退款交易费用
            "createGetExitFeeUnsignedTx" -> {
                try {
                    val tx = Api.createGetExitFeeUnsignedTx()
                    result.success(tx)
                }catch (e: Exception) {
                    result.error("DepositError", e.message, null)
                }
            }

// 启动异步客户端（与区块链节点交互）
            "runClient" -> {
                val args = call.arguments as Map<String, Any>
                val wsUrl = args["wsUrl"] as String
                val validatorPrivateKey = args["validatorPrivateKey"] as String

                try {
                    Api.runClient(wsUrl, validatorPrivateKey)
                        .thenRun {
                            channel.invokeMethod("onClientDone", null) // 通知 Flutter
                        }
                        .exceptionally { ex ->
                            channel.invokeMethod("onClientError", ex.message)
                            null
                        }
                    result.success("Client started")
                } catch (e: Exception) {
                    result.error("ClientError", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
