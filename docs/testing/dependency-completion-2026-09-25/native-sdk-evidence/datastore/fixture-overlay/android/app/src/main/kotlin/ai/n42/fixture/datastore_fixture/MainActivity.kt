package ai.n42.fixture.datastore_fixture

import androidx.datastore.core.MultiProcessDataStoreFactory
import androidx.datastore.core.Serializer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.InputStream
import java.io.OutputStream
import dalvik.system.BaseDexClassLoader
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val nativeCounterStore by lazy {
        MultiProcessDataStoreFactory.create(
            serializer = CounterSerializer,
            scope = ioScope,
            produceFile = { File(applicationContext.filesDir, "fixture-native-counter.pb") },
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ai.n42.fixture/datastore_control")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "phase" -> result.success(intent?.getStringExtra("phase"))
                    "record" -> {
                        try {
                            val record = call.arguments as? Map<*, *>
                                ?: throw IllegalArgumentException("missing fixture result")
                            val phase = record["phase"] as? String
                            if (phase != "seed" && phase != "verify") {
                                throw IllegalArgumentException("invalid fixture phase")
                            }
                            File(filesDir, "fixture-result-$phase.json")
                                .writeText(JSONObject(record).toString())
                            result.success(null)
                        } catch (error: Throwable) {
                            result.error("fixture_record", error.toString(), null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ai.n42.fixture/datastore_counter")
            .setMethodCallHandler { call, result ->
                if (call.method != "increment") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                ioScope.launch {
                    try {
                        val before = nativeCounterStore.data.first()
                        val after = nativeCounterStore.updateData { it + 1 }
                        val packageMaps = File("/proc/self/maps").useLines { lines ->
                            lines.filter { it.contains("base.apk") }.take(12).toList()
                        }
                        val lookupPath =
                            (applicationContext.classLoader as BaseDexClassLoader)
                                .findLibrary("datastore_shared_counter")
                        runOnUiThread {
                            result.success(
                                mapOf(
                                    "before" to before,
                                    "after" to after,
                                    "lookupPath" to (lookupPath ?: ""),
                                    "packageMaps" to packageMaps,
                                    "pid" to android.os.Process.myPid(),
                                )
                            )
                        }
                    } catch (error: Throwable) {
                        runOnUiThread {
                            result.error("native_counter", error.toString(), null)
                        }
                    }
                }
            }
    }

    override fun onDestroy() {
        ioScope.cancel()
        super.onDestroy()
    }
}

private object CounterSerializer : Serializer<Int> {
    override val defaultValue: Int = 0

    override suspend fun readFrom(input: InputStream): Int {
        val bytes = input.readBytes()
        return if (bytes.isEmpty()) 0 else bytes.decodeToString().toInt()
    }

    override suspend fun writeTo(t: Int, output: OutputStream) {
        output.write(t.toString().toByteArray())
    }
}
