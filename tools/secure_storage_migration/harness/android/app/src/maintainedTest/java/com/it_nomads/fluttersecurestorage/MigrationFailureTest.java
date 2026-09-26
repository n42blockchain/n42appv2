package com.it_nomads.fluttersecurestorage;

import static org.junit.Assert.*;
import android.content.Context;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;
import java.io.File;
import java.nio.file.Files;
import java.security.KeyStore;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicReference;
import java.util.concurrent.atomic.AtomicInteger;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import org.junit.Test;
import org.junit.runner.RunWith;

/** Fault injection stays in the instrumentation APK. Production has no fault hooks. */
@RunWith(AndroidJUnit4.class)
public class MigrationFailureTest {
    private final Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
    private static final String TARGET = "n42_secure_v11_wallet";
    private FlutterSecureStorageConfig config() {
        Map<String, Object> options = new HashMap<>();
        options.put("storageNamespace", TARGET);
        options.put("preferencesKeyPrefix", "n42_");
        return N42StorageMigration.resolve(options);
    }

    private Exception migrate(FlutterSecureStorage storage) throws Exception {
        CountDownLatch done = new CountDownLatch(1);
        AtomicReference<Exception> failure = new AtomicReference<>();
        NativeOperationQueue.INSTANCE.submit(release -> N42StorageMigration.initialize(context, storage, config(),
            new SecurePreferencesCallback<Void>() {
                public void onSuccess(Void ignored) { done.countDown(); release.run(); }
                public void onError(Exception error) { failure.set(error); done.countDown(); release.run(); }
            }));
        assertTrue(done.await(30, TimeUnit.SECONDS));
        return failure.get();
    }

    private void assertIncomplete() {
        assertFalse(context.getSharedPreferences(N42StorageMigration.JOURNAL, 0).getBoolean(TARGET, false));
        assertFalse(context.getSharedPreferences(N42StorageMigration.JOURNAL, 0)
            .getBoolean("n42_secure_v11_preferences", false));
    }

    @Test public void fault() throws Exception {
        String stage = InstrumentationRegistry.getArguments().getString("fault", "verification");
        if (stage.equals("verification")) {
            assertIncomplete();
            File sourceFile = new File(context.getApplicationInfo().dataDir, "shared_prefs/n42_secure_prefs.xml");
            byte[] originalSourceBytes = Files.readAllBytes(sourceFile.toPath());
            Map<String, ?> before = context.getSharedPreferences("n42_secure_prefs", 0).getAll();
            Exception error = migrate(new FlutterSecureStorage(context) {
                @Override public void read(String key, SecurePreferencesCallback<String> callback) {
                    callback.onSuccess("incorrect verification value");
                }
            });
            assertNotNull(error);
            assertIncomplete();
            assertEquals(before, context.getSharedPreferences("n42_secure_prefs", 0).getAll());
            assertArrayEquals(originalSourceBytes, Files.readAllBytes(sourceFile.toPath()));
            // A partial destination contains ciphertext, but cannot bypass the source probe.
            assertTrue(context.getSharedPreferences("n42_secure_prefs", 0).edit()
                .putString("corrupted-entry", "corrupted-ciphertext").commit());
            byte[] deliberatelyCorruptedBytes = Files.readAllBytes(sourceFile.toPath());
            assertNotNull(migrate(new FlutterSecureStorage(context)));
            assertArrayEquals(deliberatelyCorruptedBytes, Files.readAllBytes(sourceFile.toPath()));
            assertIncomplete();
            assertTrue(context.getSharedPreferences("n42_secure_prefs", 0).edit()
                .remove("corrupted-entry").commit());
            // Restore byte order changed by our deliberate editor injection, not by migration.
            Files.write(sourceFile.toPath(), originalSourceBytes);
            assertNull(migrate(new FlutterSecureStorage(context)));
            assertTrue(context.getSharedPreferences(N42StorageMigration.JOURNAL, 0).getBoolean(TARGET, false));
            assertFalse(context.getSharedPreferences(N42StorageMigration.JOURNAL, 0)
                .getBoolean("n42_secure_v11_preferences", false));
            return;
        }
        if (stage.equals("interrupt")) {
            assertIncomplete();
            migrate(new FlutterSecureStorage(context) {
                @Override public void write(String key, String value, SecurePreferencesCallback<Void> callback) {
                    super.write(key, value, new SecurePreferencesCallback<Void>() {
                        public void onSuccess(Void ignored) {
                            try {
                                N42StorageMigration.flush(context, config());
                                Files.write(new File(context.getFilesDir(), "interrupt-ready").toPath(), new byte[]{1});
                                // Harness kills this dedicated process here. No completion is delivered.
                            } catch (Exception error) { callback.onError(error); }
                        }
                        public void onError(Exception error) { callback.onError(error); }
                    });
                }
            });
            fail("interruption stage must be killed by the harness");
        }
        if (stage.equals("completedKeyMissing")) {
            assertNull(migrate(new FlutterSecureStorage(context)));
            KeyStore keys = KeyStore.getInstance("AndroidKeyStore"); keys.load(null);
            String alias = context.getPackageName() + ".FlutterSecureStoragePluginKeyOAEP." + TARGET;
            assertTrue(keys.containsAlias(alias));
            keys.deleteEntry(alias);
            assertNotNull(migrate(new FlutterSecureStorage(context)));
            assertFalse("completed destination key must not be regenerated", keys.containsAlias(alias));
            return;
        }
        fail("unknown fault stage");
    }

    @Test public void queueWaitsForTerminalCallbackExactlyOnce() {
        NativeOperationQueue queue = new NativeOperationQueue(Runnable::run);
        List<Integer> order = new ArrayList<>();
        AtomicReference<Runnable> first = new AtomicReference<>();
        AtomicReference<Runnable> second = new AtomicReference<>();
        queue.submit(done -> { order.add(1); first.set(done); });
        queue.submit(done -> { order.add(2); second.set(done); });
        queue.submit(done -> { order.add(3); done.run(); });
        assertEquals(Arrays.asList(1), order);
        first.get().run();
        first.get().run();
        assertEquals(Arrays.asList(1, 2), order);
        second.get().run();
        assertEquals(Arrays.asList(1, 2, 3), order);
    }

    @Test public void twoEnginesAndDetachKeepQueueAlive() throws Exception {
        FlutterEngine[] engines = new FlutterEngine[2];
        InstrumentationRegistry.getInstrumentation().runOnMainSync(() -> {
            engines[0] = new FlutterEngine(context);
            engines[1] = new FlutterEngine(context);
        });
        FlutterSecureStoragePlugin first = (FlutterSecureStoragePlugin)
            engines[0].getPlugins().get(FlutterSecureStoragePlugin.class);
        FlutterSecureStoragePlugin second = (FlutterSecureStoragePlugin)
            engines[1].getPlugins().get(FlutterSecureStoragePlugin.class);
        assertNotNull(first); assertNotNull(second);
        Map<String, Object> options = new HashMap<>();
        options.put("storageNamespace", TARGET); options.put("preferencesKeyPrefix", "n42_");
        Map<String, Object> arguments = new HashMap<>();
        arguments.put("options", options); arguments.put("key", "credential");
        CountDownLatch done = new CountDownLatch(21);
        AtomicInteger successes = new AtomicInteger();
        AtomicInteger errors = new AtomicInteger();
        MethodChannel.Result result = new MethodChannel.Result() {
            public void success(Object value) {
                if ("N42_PUBLIC_FAKE_CREDENTIAL_2026_0".equals(value)) successes.incrementAndGet();
                done.countDown();
            }
            public void error(String code, String message, Object detail) { errors.incrementAndGet(); done.countDown(); }
            public void notImplemented() { errors.incrementAndGet(); done.countDown(); }
        };
        // Queue a guaranteed failure, followed by 20 reads across two real engines.
        first.onMethodCall(new MethodCall("read", null), result);
        for (int i = 0; i < 20; i++) {
            (i % 2 == 0 ? first : second).onMethodCall(new MethodCall("read", arguments), result);
        }
        InstrumentationRegistry.getInstrumentation().runOnMainSync(engines[0]::destroy);
        assertTrue("queue stalled after error/detach", done.await(30, TimeUnit.SECONDS));
        assertEquals(20, successes.get());
        assertEquals(1, errors.get());
        InstrumentationRegistry.getInstrumentation().runOnMainSync(engines[1]::destroy);
    }
}
