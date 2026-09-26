package mining.ai.n42.www.flutter_mining

import android.os.Process

class MobileSdkUnavailableException(cause: Throwable? = null) : IllegalStateException(
    "Mobile verification is unavailable in this Android process.", cause
) {
    val code: String = MobileSdkRuntime.UNAVAILABLE_CODE
}

/** One process-level gate for every call into the 64-bit-only MobileSdk AAR. */
class MobileSdkRuntime(
    private val is64BitProcess: () -> Boolean = { Process.is64Bit() },
    private val loadNative: () -> Unit = {
        Class.forName("com.mobileSdk.NativeBindings", true, MobileSdkRuntime::class.java.classLoader)
    },
) {
    companion object {
        const val UNAVAILABLE_CODE = "MobileSdkUnavailable"
        val default = MobileSdkRuntime()
    }

    fun ensureAvailable() {
        if (!is64BitProcess()) throw MobileSdkUnavailableException()
        try {
            loadNative()
        } catch (error: LinkageError) {
            throw MobileSdkUnavailableException(error)
        }
    }

    fun <T> call(action: () -> T): T {
        ensureAvailable()
        try {
            return action()
        } catch (error: LinkageError) {
            throw MobileSdkUnavailableException(error)
        }
    }
}
