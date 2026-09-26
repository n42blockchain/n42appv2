package com.it_nomads.fluttersecurestorage;

import static org.junit.Assert.*;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.SharedPreferences;
import android.system.Os;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.io.File;
import java.lang.reflect.Proxy;
import java.nio.file.Files;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.*;
import org.junit.Test;
import org.junit.runner.RunWith;

/** Uses real app-private files and Keystore. Fault controls exist only in the test APK. */
@RunWith(AndroidJUnit4.class)
public class MigrationPersistenceTest {
    private final Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
    private static final String TARGET = "n42_secure_v11_wallet";
    private Map<String, Object> options() {
        Map<String, Object> options = new HashMap<>();
        options.put("storageNamespace", TARGET);
        options.put("preferencesKeyPrefix", "n42_");
        options.put("resetOnError", "true");
        return options;
    }
    private FlutterEngine engine() {
        FlutterEngine[] engine = new FlutterEngine[1];
        InstrumentationRegistry.getInstrumentation().runOnMainSync(() -> engine[0] = new FlutterEngine(context));
        return engine[0];
    }
    private Object[] call(FlutterEngine engine, String method) throws Exception {
        Map<String, Object> args = new HashMap<>();
        args.put("options", options()); args.put("key", "credential"); args.put("value", "must-not-replace");
        Object[] result = new Object[2];
        CountDownLatch done = new CountDownLatch(1);
        ((FlutterSecureStoragePlugin) engine.getPlugins().get(FlutterSecureStoragePlugin.class))
            .onMethodCall(new MethodCall(method, args), new MethodChannel.Result() {
                public void success(Object value) { result[0] = value; done.countDown(); }
                public void error(String code, String message, Object details) { result[1] = message; done.countDown(); }
                public void notImplemented() { result[1] = "not implemented"; done.countDown(); }
            });
        assertTrue(done.await(30, TimeUnit.SECONDS));
        return result;
    }
    private void destroy(FlutterEngine engine) {
        InstrumentationRegistry.getInstrumentation().runOnMainSync(engine::destroy);
    }
    private Map<String, String> snapshot() throws Exception {
        Map<String, String> snapshot = new TreeMap<>();
        File[] files = new File(context.getApplicationInfo().dataDir, "shared_prefs").listFiles();
        if (files != null) for (File file : files) {
            if (file.isFile()) {
                try {
                    snapshot.put(file.getName(), Base64.getEncoder().encodeToString(
                        MessageDigest.getInstance("SHA-256").digest(Files.readAllBytes(file.toPath()))));
                } catch (java.nio.file.AccessDeniedException denied) {
                    android.system.StructStat stat = Os.stat(file.getPath());
                    snapshot.put(file.getName(), "unreadable:" + stat.st_mode + ":" + stat.st_size);
                }
            }
        }
        KeyStore keys = KeyStore.getInstance("AndroidKeyStore"); keys.load(null);
        for (String alias : Collections.list(keys.aliases())) snapshot.put("alias:" + alias,
            keys.getCertificate(alias) == null ? "present" : Base64.getEncoder().encodeToString(keys.getCertificate(alias).getEncoded()));
        return snapshot;
    }
    @Test public void strictDiskStage() throws Exception {
        String stage = InstrumentationRegistry.getArguments().getString("fault", "deny");
        Map<String, String> before = snapshot();
        FlutterEngine engine = engine();
        try {
            if (stage.equals("deny")) {
                for (String method : new String[]{"read", "readAll", "containsKey", "write", "delete", "deleteAll"}) {
                    Object[] result = call(engine, method);
                    assertNotNull(method + " must reject ambiguous disk state", result[1]);
                    assertEquals("disk bytes / aliases changed after " + method, before, snapshot());
                }
            } else {
                Object[] result = call(engine, "read");
                assertNull(result[1]);
                assertEquals(stage.equals("deleted") ? null : "N42_PUBLIC_FAKE_CREDENTIAL_2026_0", result[0]);
            }
        } finally { destroy(engine); }
    }
    @Test public void failedCompletionCannotAuthorizeOtherEngines() throws Exception {
        File directory = new File(context.getApplicationInfo().dataDir, "shared_prefs");
        AtomicBoolean injected = new AtomicBoolean();
        Context failing = new ContextWrapper(context) {
            @Override public SharedPreferences getSharedPreferences(String name, int mode) {
                SharedPreferences real = super.getSharedPreferences(name, mode);
                if (!name.equals(N42StorageMigration.JOURNAL)) return real;
                return (SharedPreferences) Proxy.newProxyInstance(SharedPreferences.class.getClassLoader(),
                    new Class<?>[]{SharedPreferences.class}, (proxy, method, args) -> {
                        if (!method.getName().equals("edit")) return method.invoke(real, args);
                        SharedPreferences.Editor editor = real.edit();
                        AtomicBoolean completion = new AtomicBoolean();
                        return Proxy.newProxyInstance(SharedPreferences.Editor.class.getClassLoader(),
                            new Class<?>[]{SharedPreferences.Editor.class}, (ep, em, ea) -> {
                                if (em.getName().equals("putBoolean") && TARGET.equals(ea[0]) && Boolean.TRUE.equals(ea[1]))
                                    completion.set(true);
                                if (em.getName().equals("commit") && completion.get()) {
                                    Os.chmod(directory.getPath(), 0500);
                                    injected.set(true);
                                }
                                Object value = em.invoke(editor, ea);
                                return value == editor ? ep : value;
                            });
                    });
            }
        };
        CountDownLatch done = new CountDownLatch(1);
        AtomicReference<Exception> failure = new AtomicReference<>();
        FlutterEngine other = engine();
        try {
            NativeOperationQueue.INSTANCE.submit(release -> N42StorageMigration.initialize(failing,
                new FlutterSecureStorage(failing), N42StorageMigration.resolve(options()), new SecurePreferencesCallback<Void>() {
                    public void onSuccess(Void unused) { done.countDown(); release.run(); }
                    public void onError(Exception error) { failure.set(error); done.countDown(); release.run(); }
                }));
            assertTrue(done.await(30, TimeUnit.SECONDS));
            assertTrue("real completion filesystem fault was not reached", injected.get());
            assertNotNull("completion must report failed persistence", failure.get());
            assertTrue("fixture must reproduce Android's cached true despite failed commit",
                context.getSharedPreferences(N42StorageMigration.JOURNAL, 0).getBoolean(TARGET, false));
            Map<String, String> failedSnapshot = snapshot();
            for (String method : new String[]{"read", "write", "delete", "deleteAll"}) {
                assertNotNull("other engine bypassed failed completion: " + method, call(other, method)[1]);
                assertEquals("blocked operation changed files or aliases", failedSnapshot, snapshot());
            }
            Os.chmod(directory.getPath(), 0700);
            assertNull(call(other, "read")[1]);
            assertEquals("N42_PUBLIC_FAKE_CREDENTIAL_2026_0", call(other, "read")[0]);
            assertNull(call(other, "delete")[1]);
            assertNull(call(other, "read")[0]);
        } finally { Os.chmod(directory.getPath(), 0700); destroy(other); }
    }
}
