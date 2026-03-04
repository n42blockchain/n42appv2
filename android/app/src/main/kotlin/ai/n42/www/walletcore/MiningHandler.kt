package ai.n42.www.walletcore

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.mobileSdk.Api
import java.util.concurrent.CompletableFuture

/**
 * Handles all mining-related operations: BLS keypair generation,
 * deposit/exit transactions, and validator client lifecycle.
 */
class MiningHandler(
    /**
     * Callback channel used to notify Flutter when the mining client
     * finishes or encounters an error.
     */
    private val channelProvider: () -> MethodChannel
) {

    /** Active runClient future — saved so we can cancel on MiningStopClient. */
    @Volatile
    var runClientFuture: CompletableFuture<Void>? = null

    fun handleGenerateBls12381Keypair(call: MethodCall, result: MethodChannel.Result) {
        try {
            val keyPair = Api.generateBls12381Keypair()
            result.success(keyPair)
        } catch (e: Exception) {
            result.error("DepositError", e.message, null)
        }
    }

    fun handleCreateDepositUnsignedTx(call: MethodCall, result: MethodChannel.Result) {
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

    fun handleCreateExitUnsignedTx(call: MethodCall, result: MethodChannel.Result) {
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

    fun handleCreateGetExitFeeUnsignedTx(call: MethodCall, result: MethodChannel.Result) {
        try {
            val tx = Api.createGetExitFeeUnsignedTx()
            result.success(tx)
        } catch (e: Exception) {
            result.error("DepositError", e.message, null)
        }
    }

    fun handleRunClient(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as Map<String, Any>
        val wsUrl = args["wsUrl"] as String
        val validatorPrivateKey = args["validatorPrivateKey"] as String

        try {
            runClientFuture?.cancel(true)
            val future = Api.runClient(wsUrl, validatorPrivateKey)
            runClientFuture = future
            val channel = channelProvider()
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

    fun handleStopClient(call: MethodCall, result: MethodChannel.Result) {
        try {
            runClientFuture?.cancel(true)
            runClientFuture = null
            result.success("Client stopped")
        } catch (e: Exception) {
            result.error("StopClientError", e.message, null)
        }
    }
}
