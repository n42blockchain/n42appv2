package mining.ai.n42.www.flutter_mining

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

internal class FlutterMiningPluginTest {
    @Test
    fun onMethodCall_getPlatformVersion_returnsExpectedValue() {
        val plugin = FlutterMiningPlugin()

        val call = MethodCall("getPlatformVersion", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).success("Android " + android.os.Build.VERSION.RELEASE)
    }

    @Test
    fun onMethodCall_unsupportedMobileSdkReturnsStableError() {
        val plugin = FlutterMiningPlugin()
        plugin.mobileSdkRuntime = MobileSdkRuntime(
            is64BitProcess = { false },
            loadNative = { error("native loader must not run") },
        )
        val result: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        plugin.onMethodCall(MethodCall("generateBls12381Keypair", null), result)

        Mockito.verify(result).error(
            Mockito.eq(MobileSdkRuntime.UNAVAILABLE_CODE),
            Mockito.anyString(),
            Mockito.isNull(),
        )
    }
}
