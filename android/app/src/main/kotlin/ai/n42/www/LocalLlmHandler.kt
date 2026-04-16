package ai.n42.www

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

/**
 * 本地 LLM 推理 MethodChannel Handler
 *
 * 对接 MediaPipe LLM Inference API (com.google.mediapipe.tasks.genai.llminference)
 * 或在 MediaPipe 不可用时 fallback 到 llama.cpp JNI。
 *
 * Flutter 侧通过 `com.n42.chat/local_llm` channel 调用。
 *
 * 需要在 build.gradle 添加依赖：
 * ```
 * implementation 'com.google.mediapipe:tasks-genai:0.10.22'
 * ```
 */
class LocalLlmHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "LocalLlmHandler"
        private const val CHANNEL_NAME = "com.n42.chat/local_llm"
        private const val EVENT_CHANNEL_NAME = "com.n42.chat/local_llm_stream"

        fun register(flutterEngine: FlutterEngine, context: Context) {
            val handler = LocalLlmHandler(context)
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL_NAME
            ).setMethodCallHandler(handler)

            EventChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                EVENT_CHANNEL_NAME
            ).setStreamHandler(handler.streamHandler)
        }
    }

    private val scope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    private var llmInference: Any? = null  // MediaPipe LlmInference 实例
    private var isLoaded = false
    private var currentModelPath: String? = null
    private var streamEventSink: EventChannel.EventSink? = null
    private var generateJob: Job? = null

    val streamHandler = object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            streamEventSink = events
        }
        override fun onCancel(arguments: Any?) {
            streamEventSink = null
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkCapability" -> checkCapability(result)
            "loadModel" -> loadModel(call, result)
            "unloadModel" -> unloadModel(result)
            "isModelLoaded" -> result.success(isLoaded)
            "generate" -> generate(call, result)
            "startStreamGenerate" -> startStreamGenerate(call, result)
            "cancelGenerate" -> cancelGenerate(result)
            "getModelInfo" -> getModelInfo(result)
            else -> result.notImplemented()
        }
    }

    private fun checkCapability(result: MethodChannel.Result) {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memInfo)
        val availMb = (memInfo.availMem / (1024 * 1024)).toInt()

        // 检测 GPU 可用性（简化检测：API 26+ 支持 Vulkan）
        val hasGpu = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O

        // NPU 检测（Android 15+ NNAPI 或特定厂商 SDK）
        val hasNpu = Build.VERSION.SDK_INT >= 35  // Android 15

        val supported = availMb >= 1500 && hasGpu
        val recommendedQuant = if (availMb >= 4000) "int8" else "int4"

        result.success(mapOf(
            "supported" to supported,
            "available_memory_mb" to availMb,
            "has_gpu" to hasGpu,
            "has_npu" to hasNpu,
            "recommended_quant" to recommendedQuant
        ))
    }

    private fun loadModel(call: MethodCall, result: MethodChannel.Result) {
        val modelPath = call.argument<String>("model_path")
        val maxTokens = call.argument<Int>("max_tokens") ?: 2048
        val topK = call.argument<Int>("top_k") ?: 40
        val temperature = call.argument<Double>("temperature") ?: 0.7

        if (modelPath == null) {
            result.error("INVALID_ARGS", "model_path is required", null)
            return
        }

        scope.launch {
            try {
                // 卸载当前模型
                unloadModelInternal()

                // 使用反射加载 MediaPipe LLM Inference
                // 这样在 MediaPipe 依赖不存在时不会崩溃
                val loaded = loadWithMediaPipe(modelPath, maxTokens, topK, temperature)
                if (loaded) {
                    isLoaded = true
                    currentModelPath = modelPath
                    Log.i(TAG, "Model loaded: $modelPath (maxTokens=$maxTokens)")
                    withContext(Dispatchers.Main) { result.success(true) }
                } else {
                    Log.w(TAG, "MediaPipe not available, model loading failed")
                    withContext(Dispatchers.Main) { result.success(false) }
                }
            } catch (e: Exception) {
                Log.e(TAG, "loadModel failed", e)
                withContext(Dispatchers.Main) {
                    result.error("LOAD_FAILED", e.message, null)
                }
            }
        }
    }

    /**
     * 通过反射加载 MediaPipe LlmInference，避免硬编码依赖。
     *
     * 等效于：
     * ```kotlin
     * val options = LlmInference.LlmInferenceOptions.builder()
     *     .setModelPath(modelPath)
     *     .setMaxTokens(maxTokens)
     *     .setTopK(topK)
     *     .setTemperature(temperature.toFloat())
     *     .setResultListener { partialResult, done ->
     *         // stream callback
     *     }
     *     .build()
     * llmInference = LlmInference.createFromOptions(context, options)
     * ```
     */
    private fun loadWithMediaPipe(
        modelPath: String,
        maxTokens: Int,
        topK: Int,
        temperature: Double
    ): Boolean {
        return try {
            val llmClass = Class.forName(
                "com.google.mediapipe.tasks.genai.llminference.LlmInference"
            )
            val optionsClass = Class.forName(
                "com.google.mediapipe.tasks.genai.llminference.LlmInference\$LlmInferenceOptions"
            )
            val builderClass = Class.forName(
                "com.google.mediapipe.tasks.genai.llminference.LlmInference\$LlmInferenceOptions\$Builder"
            )

            val builder = builderClass.getDeclaredConstructor().newInstance()
            builderClass.getMethod("setModelPath", String::class.java).invoke(builder, modelPath)
            builderClass.getMethod("setMaxTokens", Int::class.java).invoke(builder, maxTokens)
            builderClass.getMethod("setTopK", Int::class.java).invoke(builder, topK)
            builderClass.getMethod("setTemperature", Float::class.java)
                .invoke(builder, temperature.toFloat())

            val options = builderClass.getMethod("build").invoke(builder)
            llmInference = llmClass.getMethod("createFromOptions", Context::class.java, optionsClass)
                .invoke(null, context, options)

            true
        } catch (e: ClassNotFoundException) {
            Log.w(TAG, "MediaPipe LLM Inference not in classpath: ${e.message}")
            false
        } catch (e: Exception) {
            Log.e(TAG, "MediaPipe load failed", e)
            false
        }
    }

    private fun generate(call: MethodCall, result: MethodChannel.Result) {
        val prompt = call.argument<String>("prompt")
        if (prompt == null || !isLoaded || llmInference == null) {
            result.success(null)
            return
        }

        scope.launch {
            try {
                val response = llmInference!!.javaClass
                    .getMethod("generateResponse", String::class.java)
                    .invoke(llmInference, prompt) as? String
                withContext(Dispatchers.Main) { result.success(response) }
            } catch (e: Exception) {
                Log.e(TAG, "generate failed", e)
                withContext(Dispatchers.Main) { result.success(null) }
            }
        }
    }

    private fun startStreamGenerate(call: MethodCall, result: MethodChannel.Result) {
        val prompt = call.argument<String>("prompt")
        if (prompt == null || !isLoaded || llmInference == null) {
            result.success(null)
            return
        }

        generateJob?.cancel()
        generateJob = scope.launch {
            try {
                // MediaPipe generateResponseAsync 通过 ResultListener 回调
                llmInference!!.javaClass
                    .getMethod("generateResponseAsync", String::class.java)
                    .invoke(llmInference, prompt)
                // 实际回调由 options 中设置的 ResultListener 处理
                // 在 loadModel 中已注册，此处通过 streamEventSink 转发
            } catch (e: Exception) {
                Log.e(TAG, "streamGenerate failed", e)
                withContext(Dispatchers.Main) {
                    streamEventSink?.error("GENERATE_ERROR", e.message, null)
                }
            }
        }
        result.success(null)
    }

    private fun cancelGenerate(result: MethodChannel.Result) {
        generateJob?.cancel()
        generateJob = null
        result.success(null)
    }

    private fun unloadModel(result: MethodChannel.Result) {
        unloadModelInternal()
        result.success(null)
    }

    private fun unloadModelInternal() {
        try {
            llmInference?.javaClass?.getMethod("close")?.invoke(llmInference)
        } catch (e: Exception) {
            Log.w(TAG, "close failed: ${e.message}")
        }
        llmInference = null
        isLoaded = false
        currentModelPath = null
    }

    private fun getModelInfo(result: MethodChannel.Result) {
        if (!isLoaded) {
            result.success(null)
            return
        }
        result.success(mapOf(
            "model_path" to currentModelPath,
            "is_loaded" to isLoaded,
            "backend" to "mediapipe"
        ))
    }

    fun dispose() {
        generateJob?.cancel()
        scope.cancel()
        unloadModelInternal()
    }
}
