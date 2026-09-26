package mining.ai.n42.www.flutter_mining

import android.content.Context
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import org.mockito.Mockito

internal class MobileSdkRuntimeTest {
    @Test
    fun unsupportedProcessNeverLoadsOrCallsNativeCode() {
        var loads = 0
        var calls = 0
        val runtime = MobileSdkRuntime(
            is64BitProcess = { false },
            loadNative = { loads++ },
        )

        val failure = assertFailsWith<MobileSdkUnavailableException> {
            runtime.call { calls++; "unexpected" }
        }

        assertEquals(MobileSdkRuntime.UNAVAILABLE_CODE, failure.code)
        assertEquals(0, loads)
        assertEquals(0, calls)
    }

    @Test
    fun supportedProcessLoadsAndCallsOnce() {
        var loads = 0
        var calls = 0
        val runtime = MobileSdkRuntime(
            is64BitProcess = { true },
            loadNative = { loads++ },
        )

        assertEquals("ok", runtime.call { calls++; "ok" })
        assertEquals(1, loads)
        assertEquals(1, calls)
    }

    @Test
    fun failedInitializationAndRepeatedAccessReturnUnavailable() {
        var calls = 0
        val runtime = MobileSdkRuntime(
            is64BitProcess = { true },
            loadNative = { throw NoClassDefFoundError("NativeBindings") },
        )

        repeat(2) {
            assertFailsWith<MobileSdkUnavailableException> {
                runtime.call { calls++ }
            }
        }
        assertEquals(0, calls)
    }

    @Test
    fun missingNativeMethodReturnsUnavailable() {
        val runtime = MobileSdkRuntime(
            is64BitProcess = { true },
            loadNative = {},
        )

        assertFailsWith<MobileSdkUnavailableException> {
            runtime.call { throw UnsatisfiedLinkError("genBlockVerifyResult") }
        }
    }

    @Test
    fun ordinaryProgrammingFailureIsNotHidden() {
        val runtime = MobileSdkRuntime(
            is64BitProcess = { true },
            loadNative = {},
        )
        val original = IllegalStateException("caller failure")

        val failure = assertFailsWith<IllegalStateException> { runtime.call { throw original } }
        kotlin.test.assertSame(original, failure)
    }

    @Test
    fun unsupportedProcessDoesNotInitializeTlsOrRunClient() {
        var loads = 0
        var tlsInitializations = 0
        var calls = 0
        val runtime = MobileSdkRuntime(
            is64BitProcess = { false },
            loadNative = { loads++ },
            initializeTls = { tlsInitializations++; true },
        )

        assertFailsWith<MobileSdkUnavailableException> {
            runtime.callWithTls(null) { calls++ }
        }
        assertEquals(0, loads)
        assertEquals(0, tlsInitializations)
        assertEquals(0, calls)
    }

    @Test
    fun supportedRunClientInitializesTlsBeforeNativeAction() {
        val context = Mockito.mock(Context::class.java)
        val order = mutableListOf<String>()
        val runtime = MobileSdkRuntime(
            is64BitProcess = { true },
            loadNative = { order += "load" },
            initializeTls = { order += "tls"; true },
        )

        assertEquals("started", runtime.callWithTls(context) { order += "client"; "started" })
        assertEquals(listOf("load", "tls", "client"), order)
    }

    @Test
    fun failedTlsInitializationPreventsNativeAction() {
        val context = Mockito.mock(Context::class.java)
        var calls = 0
        val runtime = MobileSdkRuntime(
            is64BitProcess = { true },
            loadNative = {},
            initializeTls = { false },
        )

        assertFailsWith<MobileSdkUnavailableException> {
            runtime.callWithTls(context) { calls++ }
        }
        assertEquals(0, calls)
    }
}
