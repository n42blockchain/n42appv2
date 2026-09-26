package ai.n42.www

import kotlin.test.Test
import kotlin.test.assertEquals

class VerificationConnectionCallbacksTest {
    private fun drain(pending: ArrayDeque<() -> Unit>) {
        while (pending.isNotEmpty()) pending.removeFirst()()
    }

    @Test
    fun normalDisconnectThenUnavailableCancelsQueuedReconnectAndStopsService() {
        val pending = ArrayDeque<() -> Unit>()
        var reconnectQueued = false
        var stopped = 0
        val callbacks = VerificationConnectionCallbacks(
            postToMain = { pending.addLast(it) },
            isCurrent = { true },
            onDisconnected = { reconnectQueued = true },
            onUnavailable = { reconnectQueued = false; stopped++ },
        )

        callbacks.disconnected()
        drain(pending)
        assertEquals(true, reconnectQueued)
        callbacks.unavailable()
        callbacks.disconnected()
        drain(pending)

        assertEquals(false, reconnectQueued)
        assertEquals(1, stopped)
    }

    @Test
    fun queuedNormalDisconnectIsSuppressedWhenUnavailableArrivesBeforeDispatch() {
        val pending = ArrayDeque<() -> Unit>()
        var reconnects = 0
        var stopped = 0
        val callbacks = VerificationConnectionCallbacks(
            postToMain = { pending.addLast(it) },
            isCurrent = { true },
            onDisconnected = { reconnects++ },
            onUnavailable = { stopped++ },
        )

        callbacks.disconnected()
        callbacks.unavailable()
        drain(pending)

        assertEquals(0, reconnects)
        assertEquals(1, stopped)
    }

    @Test
    fun unavailableThenNormalDisconnectDoesNotReconnect() {
        val pending = ArrayDeque<() -> Unit>()
        var reconnectQueued = false
        var stopped = 0
        val callbacks = VerificationConnectionCallbacks(
            postToMain = { pending.addLast(it) },
            isCurrent = { true },
            onDisconnected = { reconnectQueued = true },
            onUnavailable = { reconnectQueued = false; stopped++ },
        )

        callbacks.unavailable()
        callbacks.disconnected()
        callbacks.unavailable()
        drain(pending)

        assertEquals(false, reconnectQueued)
        assertEquals(1, stopped)
    }

    @Test
    fun staleConnectionCannotStopOrReconnectCurrentService() {
        val pending = ArrayDeque<() -> Unit>()
        var current = true
        var reconnects = 0
        var stops = 0
        val callbacks = VerificationConnectionCallbacks(
            postToMain = { pending.addLast(it) },
            isCurrent = { current },
            onDisconnected = { reconnects++ },
            onUnavailable = { stops++ },
        )

        current = false
        callbacks.disconnected()
        callbacks.unavailable()
        drain(pending)

        assertEquals(0, reconnects)
        assertEquals(0, stops)
    }

    @Test
    fun ordinaryDisconnectStillReconnects() {
        val pending = ArrayDeque<() -> Unit>()
        var reconnects = 0
        val callbacks = VerificationConnectionCallbacks(
            postToMain = { pending.addLast(it) },
            isCurrent = { true },
            onDisconnected = { reconnects++ },
            onUnavailable = { error("unavailable callback must not run") },
        )

        callbacks.disconnected()
        drain(pending)

        assertEquals(1, reconnects)
    }
}
