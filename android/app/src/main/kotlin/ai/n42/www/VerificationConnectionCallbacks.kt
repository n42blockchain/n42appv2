package ai.n42.www

import java.util.concurrent.atomic.AtomicBoolean

/** Posts connection callbacks to the service main handler. Native unavailability is terminal. */
internal class VerificationConnectionCallbacks(
    private val postToMain: (() -> Unit) -> Unit,
    private val isCurrent: () -> Boolean,
    private val onDisconnected: () -> Unit,
    private val onUnavailable: () -> Unit,
) {
    private val disconnectedOnce = AtomicBoolean(false)
    private val terminalUnavailable = AtomicBoolean(false)

    fun disconnected() {
        if (disconnectedOnce.compareAndSet(false, true)) {
            postToMain {
                if (!terminalUnavailable.get() && isCurrent()) onDisconnected()
            }
        }
    }

    fun unavailable() {
        if (terminalUnavailable.compareAndSet(false, true)) {
            postToMain {
                if (isCurrent()) onUnavailable()
            }
        }
    }
}
