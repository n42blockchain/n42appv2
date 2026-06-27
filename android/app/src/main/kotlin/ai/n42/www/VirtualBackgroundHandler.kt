package ai.n42.www

import android.util.Log
import com.cloudwebrtc.webrtc.FlutterWebRTCPlugin
import com.cloudwebrtc.webrtc.video.LocalVideoTrack
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class VirtualBackgroundHandler private constructor() :
    MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "VirtualBgHandler"
        private const val CHANNEL = "n42.chat/virtual_background"
        private const val MODE_NONE = "none"

        fun register(flutterEngine: FlutterEngine) {
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler(VirtualBackgroundHandler())
        }
    }

    private val processor = N42VirtualBackgroundProcessor()
    private var attachedTrackId: String? = null
    private var attachedTrack: LocalVideoTrack? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setBackgroundConfig" -> {
                val handled = setBackgroundConfig(call.arguments as? Map<*, *>)
                result.success(handled)
            }
            "clearBackground" -> {
                clearBackground()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun setBackgroundConfig(args: Map<*, *>?): Boolean {
        if (args == null) return false
        val mode = args["mode"] as? String ?: MODE_NONE
        val trackId = args["trackId"] as? String
        val blurRadius = (args["blurRadius"] as? Number)?.toFloat() ?: 0.5f
        val solidColor = args["solidColor"] as? String
        val backgroundImageBytes = args["backgroundImageBytes"] as? ByteArray

        processor.updateConfig(
            mode = mode,
            blurRadius = blurRadius,
            solidColor = solidColor,
            backgroundImageBytes = backgroundImageBytes,
        )

        if (mode == MODE_NONE) {
            clearBackground()
            return true
        }

        if (trackId.isNullOrBlank()) {
            Log.w(TAG, "setBackgroundConfig missing trackId")
            return false
        }

        if (attachedTrackId == trackId && attachedTrack != null) {
            return true
        }

        detachCurrent()
        val localTrack = FlutterWebRTCPlugin.sharedSingleton?.getLocalTrack(trackId)
        if (localTrack !is LocalVideoTrack) {
            Log.w(TAG, "No LocalVideoTrack for trackId=$trackId")
            return false
        }

        localTrack.addProcessor(processor)
        attachedTrackId = trackId
        attachedTrack = localTrack
        Log.i(TAG, "Attached virtual background processor to trackId=$trackId")
        return true
    }

    private fun clearBackground() {
        processor.clear()
        detachCurrent()
    }

    private fun detachCurrent() {
        attachedTrack?.removeProcessor(processor)
        if (attachedTrackId != null) {
            Log.i(TAG, "Detached virtual background processor from trackId=$attachedTrackId")
        }
        attachedTrack = null
        attachedTrackId = null
    }
}
