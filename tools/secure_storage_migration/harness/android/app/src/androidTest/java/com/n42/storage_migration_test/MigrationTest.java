package com.n42.storage_migration_test;

import static org.junit.Assert.*;

import android.content.Context;
import android.os.Bundle;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import com.it_nomads.fluttersecurestorage.FlutterSecureStoragePlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.io.File;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.util.*;
import java.util.concurrent.*;
import org.json.JSONObject;
import org.junit.Test;
import org.junit.runner.RunWith;

/** Runs against unmodified published v9/v10 writers and the maintained v11 reader. */
@RunWith(AndroidJUnit4.class)
public class MigrationTest {
    private final Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
    private static final String FAKE = "N42_PUBLIC_FAKE_CREDENTIAL_2026_";
    // Published reown_core 1.5.1: CORE_STORAGE_PREFIX + VERSION_KEYCHAIN + '//' + CONTEXT_KEYCHAIN.
    private static final String REOWN_KEY = "wc@2:core:0.3//keychain";
    private static final String REOWN_JSON = "{\"public-test-topic\":\"N42_PUBLIC_FAKE_CREDENTIAL_2026_reown\"}";
    private static final String[] PREFIXES = {"n42_", "sp_", ""};
    private static final String[] DESTINATIONS = {
        "n42_secure_v11_wallet", "n42_secure_v11_preferences", "n42_secure_v11_default"};

    private FlutterSecureStoragePlugin plugin() {
        FlutterSecureStoragePlugin p = new FlutterSecureStoragePlugin();
        p.initInstance(new BinaryMessenger() {
            public void send(String c, ByteBuffer m) {}
            public void send(String c, ByteBuffer m, BinaryReply r) {}
            public void setMessageHandler(String c, BinaryMessageHandler h) {}
        }, context);
        return p;
    }

    private Map<String, Object> options(int index, boolean legacy, String cipher) {
        Map<String, Object> o = new HashMap<>();
        // New callers deliberately pass upstream Dart's destructive default;
        // managed native storage must override it even on failure paths.
        o.put("resetOnError", legacy ? "false" : "true");
        if (index < 2) {
            o.put("preferencesKeyPrefix", PREFIXES[index]);
            o.put(legacy ? "sharedPreferencesName" : "storageNamespace",
                    legacy ? "n42_secure_prefs" : DESTINATIONS[index]);
        }
        if (legacy) {
            o.put("encryptedSharedPreferences", String.valueOf(cipher.equals("esp")));
            o.put("migrateOnAlgorithmChange", String.valueOf(!cipher.equals("esp")));
        }
        return o;
    }

    private Object call(FlutterSecureStoragePlugin p, String method, Map<String, Object> options,
                        String key, String value) throws Exception {
        Map<String, Object> args = new HashMap<>();
        args.put("options", options); args.put("key", key); args.put("value", value);
        CountDownLatch done = new CountDownLatch(1);
        Object[] result = new Object[2];
        p.onMethodCall(new MethodCall(method, args), new MethodChannel.Result() {
            public void success(Object v) { result[0] = v; done.countDown(); }
            public void error(String c, String m, Object d) { result[1] = c + ": " + m; done.countDown(); }
            public void notImplemented() { result[1] = "not implemented"; done.countDown(); }
        });
        assertTrue("native operation timed out", done.await(30, TimeUnit.SECONDS));
        if (result[1] != null) throw new IllegalStateException(result[1].toString());
        return result[0];
    }

    @Test public void fixture() throws Exception {
        assertEquals("com.n42.storage_migration_test", context.getPackageName());
        Bundle args = InstrumentationRegistry.getArguments();
        String stage = args.getString("stage", "verify");
        String cipher = args.getString("cipher", "esp");
        if (stage.equals("fresh")) {
            resetDedicatedFixture();
            flushPreferences();
            writeSnapshot();
            for (int i = 0; i < 3; i++) {
                call(plugin(), "write", options(i, false, cipher), "credential", FAKE + i);
                assertEquals(FAKE + i, call(plugin(), "read", options(i, false, cipher), "credential", null));
            }
            assertSourceUnchanged();
            assertNoPlaintext();
            return;
        }
        if (stage.equals("seed")) {
            resetDedicatedFixture();
            for (int i = 0; i < 3; i++) {
                call(plugin(), "write", options(i, true, cipher), "credential", FAKE + i);
            }
            call(plugin(), "write", options(2, true, cipher), REOWN_KEY, REOWN_JSON);
            call(plugin(), "write", options(2, true, cipher), "n42_chat_archive_db_key", FAKE + "chat");
            flushPreferences();
            writeSnapshot();
            return;
        }
        if (stage.equals("verify")) {
            for (int i = 0; i < 3; i++) {
                assertEquals("legacy namespace " + i, FAKE + i,
                    call(plugin(), "read", options(i, false, cipher), "credential", null));
            }
            assertEquals(REOWN_JSON, call(plugin(), "read", options(2, false, cipher), REOWN_KEY, null));
            assertEquals(FAKE + "chat", call(plugin(), "read", options(2, false, cipher), "n42_chat_archive_db_key", null));
            assertSourceUnchanged();
            assertNoPlaintext();
            return;
        }
        if (stage.equals("delete")) {
            call(plugin(), "delete", options(0, false, cipher), "credential", null);
            call(plugin(), "deleteAll", options(1, false, cipher), null, null);
            return;
        }
        if (stage.equals("crud")) {
            for (int i = 0; i < 3; i++) {
                FlutterSecureStoragePlugin p = plugin();
                Map<String, Object> o = options(i, false, cipher);
                call(p, "write", o, "crud-probe", FAKE + "new-" + i);
                assertEquals(FAKE + "new-" + i, call(plugin(), "read", o, "crud-probe", null));
                assertEquals(true, call(p, "containsKey", o, "crud-probe", null));
                Map<?, ?> all = (Map<?, ?>) call(p, "readAll", o, null, null);
                assertEquals(FAKE + i, all.get("credential"));
                assertEquals(FAKE + "new-" + i, all.get("crud-probe"));
                call(p, "delete", o, "crud-probe", null);
                assertEquals(false, call(p, "containsKey", o, "crud-probe", null));
            }
            assertSourceUnchanged();
            assertNoPlaintext();
            return;
        }
        if (stage.equals("verifyDeleted")) {
            for (int i = 0; i < 2; i++) {
                assertNull(call(plugin(), "read", options(i, false, cipher), "credential", null));
            }
            assertEquals(FAKE + 2, call(plugin(), "read", options(2, false, cipher), "credential", null));
            assertSourceUnchanged();
            return;
        }
        if (stage.equals("corruptRetry")) {
            android.content.SharedPreferences source = context.getSharedPreferences("n42_secure_prefs", 0);
            assertTrue(source.edit().putString("corrupted-entry", "corrupted-ciphertext").commit());
            writeSnapshot();
            for (String method : new String[]{"read", "write", "delete", "deleteAll"}) {
                try {
                    call(plugin(), method, options(0, false, cipher), "credential", FAKE + "must-not-write");
                    fail("corrupt source must fail closed");
                } catch (IllegalStateException expected) { }
                assertSourceUnchanged();
                assertFalse(context.getSharedPreferences("n42_secure_v11_migration", 0)
                    .getBoolean(DESTINATIONS[0], false));
            }
            assertTrue(source.edit().remove("corrupted-entry").commit());
            writeSnapshot();
            assertEquals(FAKE + 0, call(plugin(), "read", options(0, false, cipher), "credential", null));
            assertSourceUnchanged();
            return;
        }
        if (stage.equals("missingLegacyKey")) {
            KeyStore keys = KeyStore.getInstance("AndroidKeyStore"); keys.load(null);
            String alias = cipher.equals("esp") ? "_androidx_security_master_key_"
                : context.getPackageName() + ".FlutterSecureStoragePluginKey" + (cipher.equals("gcm") ? "OAEP" : "");
            assertTrue(keys.containsAlias(alias));
            keys.deleteEntry(alias);
            writeSnapshot();
            for (String method : new String[]{"read", "write", "delete", "deleteAll"}) {
                try {
                    call(plugin(), method, options(0, false, cipher), "credential", FAKE + "must-not-write");
                    fail("missing source key must fail closed");
                } catch (IllegalStateException expected) { }
                assertFalse("legacy key must not be recreated", keys.containsAlias(alias));
                assertSourceUnchanged();
                assertFalse(context.getSharedPreferences("n42_secure_v11_migration", 0)
                    .getBoolean(DESTINATIONS[0], false));
            }
            return;
        }
        fail("unknown fixture stage");
    }

    private void resetDedicatedFixture() throws Exception {
        File[] files = new File(context.getApplicationInfo().dataDir, "shared_prefs").listFiles();
        if (files != null) for (File file : files) {
            if (file.getName().endsWith(".xml")) context.deleteSharedPreferences(file.getName().replace(".xml", ""));
        }
        KeyStore ks = KeyStore.getInstance("AndroidKeyStore"); ks.load(null);
        for (String alias : Collections.list(ks.aliases())) ks.deleteEntry(alias);
    }

    private void flushPreferences() {
        // A new file may not exist yet while upstream apply() is queued. Flush the
        // known cache entries before enumerating files or ending instrumentation.
        for (String name : new String[]{"n42_secure_prefs", "FlutterSecureStorage", "FlutterSecureKeyStorage",
                "FlutterSecureStorageConfiguration", "FlutterSecureStorageConfiguration:n42_secure_prefs",
                "FlutterSecureStorageConfiguration:FlutterSecureStorage"}) {
            assertTrue(context.getSharedPreferences(name, 0).edit().commit());
        }
        File[] files = new File(context.getApplicationInfo().dataDir, "shared_prefs").listFiles();
        if (files != null) for (File file : files) {
            if (file.getName().endsWith(".xml"))
                assertTrue(context.getSharedPreferences(file.getName().replace(".xml", ""), 0).edit().commit());
        }
    }

    private Map<String, String> snapshot() throws Exception {
        Map<String, String> snapshot = new TreeMap<>();
        File[] files = new File(context.getApplicationInfo().dataDir, "shared_prefs").listFiles();
        if (files != null) for (File file : files) {
            if (!file.getName().contains("v11") && file.getName().endsWith(".xml"))
                snapshot.put("file:" + file.getName(), hash(Files.readAllBytes(file.toPath())));
        }
        KeyStore ks = KeyStore.getInstance("AndroidKeyStore"); ks.load(null);
        for (String alias : Collections.list(ks.aliases())) {
            if (!alias.contains("v11")) snapshot.put("alias:" + alias,
                ks.getCertificate(alias) == null ? "present" : hash(ks.getCertificate(alias).getEncoded()));
        }
        return snapshot;
    }

    private String hash(byte[] bytes) throws Exception {
        return android.util.Base64.encodeToString(MessageDigest.getInstance("SHA-256").digest(bytes), 2);
    }

    private void writeSnapshot() throws Exception {
        Files.write(new File(context.getFilesDir(), "fixture-snapshot.json").toPath(),
            new JSONObject(snapshot()).toString().getBytes(StandardCharsets.UTF_8));
    }

    private void assertSourceUnchanged() throws Exception {
        JSONObject expected = new JSONObject(new String(Files.readAllBytes(
            new File(context.getFilesDir(), "fixture-snapshot.json").toPath()), StandardCharsets.UTF_8));
        Map<String, String> actual = snapshot();
        for (Iterator<String> keys = expected.keys(); keys.hasNext();) {
            String key = keys.next(); assertEquals("source changed: " + key, expected.getString(key), actual.get(key));
        }
    }

    private void assertNoPlaintext() throws Exception {
        File[] files = new File(context.getApplicationInfo().dataDir, "shared_prefs").listFiles();
        if (files != null) for (File file : files) {
            assertFalse("plaintext in " + file.getName(),
                new String(Files.readAllBytes(file.toPath()), StandardCharsets.UTF_8).contains(FAKE));
        }
    }
}
