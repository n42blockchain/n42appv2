package com.it_nomads.fluttersecurestorage;

import java.util.ArrayDeque;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.function.Consumer;

/** One asynchronous operation at a time across every FlutterEngine in this process. */
final class NativeOperationQueue {
    static final NativeOperationQueue INSTANCE = new NativeOperationQueue(
        Executors.newSingleThreadExecutor(r -> new Thread(r, "n42.secure-storage")));
    private final Executor executor;
    private final ArrayDeque<Consumer<Runnable>> pending = new ArrayDeque<>();
    private boolean running;

    NativeOperationQueue(Executor executor) { this.executor = executor; }

    synchronized void submit(Consumer<Runnable> operation) {
        pending.add(operation);
        if (!running) startNext();
    }

    void continueOperation(Runnable continuation) { executor.execute(continuation); }

    private synchronized void startNext() {
        Consumer<Runnable> operation = pending.poll();
        running = operation != null;
        if (operation == null) return;
        executor.execute(() -> {
            AtomicBoolean finished = new AtomicBoolean();
            operation.accept(() -> {
                if (finished.compareAndSet(false, true)) startNext();
            });
        });
    }
}
