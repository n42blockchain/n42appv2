package com.it_nomads.fluttersecurestorage;

import android.content.Context;
import android.content.SharedPreferences;
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/** N42's versioned, isolated import. All entry points run inside NativeOperationQueue. */
final class N42StorageMigration {
    private static final java.util.Set<String> FAILED_PERSISTENCE = new java.util.HashSet<>();
    static final String JOURNAL = "n42_secure_v11_migration";
    private static final String WALLET = "n42_secure_v11_wallet";
    private static final String PREFERENCES = "n42_secure_v11_preferences";
    private static final String DEFAULT = "n42_secure_v11_default";
    private static final String KEY_ALGORITHM = "RSA_ECB_OAEPwithSHA_256andMGF1Padding";
    private static final String STORAGE_ALGORITHM = "AES_GCM_NoPadding";

    static FlutterSecureStorageConfig resolve(Map<String, Object> options) {
        FlutterSecureStorageConfig original = new FlutterSecureStorageConfig(options);
        String file = original.getEffectiveDataPrefsName();
        String prefix = original.getSharedPreferencesKeyPrefix();
        String target = null;
        if (file.equals("n42_secure_prefs") || file.equals(WALLET) || file.equals(PREFERENCES)) {
            if (prefix.equals("n42_") && !file.equals(PREFERENCES)) target = WALLET;
            else if (prefix.equals("sp_") && !file.equals(WALLET)) target = PREFERENCES;
            else throw new IllegalArgumentException("Unrecognized prefix for managed wallet storage");
        } else if (file.equals("FlutterSecureStorage") || file.equals(DEFAULT)) {
            if (!prefix.equals(LegacyPreferencesReader.DEFAULT_PREFIX))
                throw new IllegalArgumentException("Unrecognized prefix for managed default storage");
            target = DEFAULT;
        } else if (!original.hasStorageNamespace()) {
            throw new IllegalArgumentException("Unmanaged legacy storage must use an isolated storageNamespace");
        }
        if (target == null) return original;
        if (!original.getPrefOptionKeyCipherAlgorithm().equals(KEY_ALGORITHM)
                || !original.getPrefOptionStorageCipherAlgorithm().equals(STORAGE_ALGORITHM)
                || original.getEnforceBiometrics() || original.getRequireBiometricsPerOperation())
            throw new IllegalArgumentException("Managed legacy imports require the configured RSA/OAEP and AES/GCM ciphers");
        Map<String, Object> safe = new HashMap<>(options);
        safe.remove("sharedPreferencesName");
        safe.put("storageNamespace", target);
        safe.put("resetOnError", "false");
        safe.put("migrateOnAlgorithmChange", "false");
        safe.put("migrateWithBackup", "false");
        return new FlutterSecureStorageConfig(safe);
    }

    static boolean isManaged(FlutterSecureStorageConfig config) {
        String name = config.getStorageNamespace();
        return WALLET.equals(name) || PREFERENCES.equals(name) || DEFAULT.equals(name);
    }

    static void initialize(Context context, FlutterSecureStorage storage,
                           FlutterSecureStorageConfig config, SecurePreferencesCallback<Void> callback) {
        if (!isManaged(config)) { storage.initialize(config, callback); return; }
        String target = config.getStorageNamespace();
        try {
            StrictPreferencesSnapshot journal = StrictPreferencesSnapshot.read(context, JOURNAL);
            boolean complete = journal.flag(target);
            boolean inProgress = journal.flag(target + ":inProgress");
            if (complete && inProgress) throw new IOException("Conflicting migration journal state");
            validateDestinationFiles(context, config);
            if (complete) {
                requireDestinationArtifacts(context, config);
                if (FAILED_PERSISTENCE.contains(target)) {
                    // A prior failed commit can leave cached AND disk-visible state changed.
                    // Reverify and successfully persist before granting this process access.
                    FlutterSecureStorage reopened = new FlutterSecureStorage(context);
                    reopened.initialize(config, new SecurePreferencesCallback<Void>() {
                        public void onSuccess(Void unused) {
                            reopened.readAll(new SecurePreferencesCallback<Map<String, String>>() {
                                public void onSuccess(Map<String, String> values) {
                                    try {
                                        persistJournal(context, target, true);
                                        storage.initialize(config, callback);
                                    } catch (Exception error) { callback.onError(error); }
                                }
                                public void onError(Exception error) { callback.onError(error); }
                            });
                        }
                        public void onError(Exception error) { callback.onError(error); }
                    });
                } else storage.initialize(config, callback);
                return;
            }
            if (!inProgress && hasDestinationArtifacts(context, config))
                throw new IOException("Destination exists without durable migration state; repair required");
            String source = DEFAULT.equals(target) ? "FlutterSecureStorage" : "n42_secure_prefs";
            // Read/decrypt ALL source values before upstream initialization can create any keys.
            Map<String, String> values = LegacyPreferencesReader.read(context, source,
                config.getSharedPreferencesKeyPrefix());
            persistJournal(context, target, false);
            // Only a durably recorded, unfinished destination may be reset after interruption.
            // Source files, old aliases, and sibling completion records are never modified.
            requireCommit(context.getSharedPreferences(target, 0).edit().clear());
            requireCommit(context.getSharedPreferences("FlutterSecureStorageConfiguration:" + target, 0)
                .edit().putString("FlutterSecureSAlgorithmKey", KEY_ALGORITHM)
                .putString("FlutterSecureSAlgorithmStorage", STORAGE_ALGORITHM));
            storage.initialize(config, new SecurePreferencesCallback<>() {
                public void onSuccess(Void unused) {
                    importNext(context, storage, config, values, values.entrySet().iterator(), callback);
                }
                public void onError(Exception error) { callback.onError(error); }
            });
        } catch (Exception error) {
            callback.onError(error);
        }
    }

    private static void importNext(Context context, FlutterSecureStorage storage,
                                   FlutterSecureStorageConfig config, Map<String, String> expected,
                                   Iterator<Map.Entry<String, String>> entries,
                                   SecurePreferencesCallback<Void> callback) {
        if (!entries.hasNext()) {
            try {
                flush(context, config);
                requireDestinationArtifacts(context, config);
                // Reopen with a fresh upstream cipher: verify persisted wrapped key and config,
                // rather than trusting the importer's cached in-memory application key.
                FlutterSecureStorage reopened = new FlutterSecureStorage(context);
                reopened.initialize(config, new SecurePreferencesCallback<Void>() {
                    public void onSuccess(Void unused) {
                        reopened.readAll(new SecurePreferencesCallback<Map<String, String>>() {
                            public void onSuccess(Map<String, String> actual) {
                                try {
                                    if (!expected.equals(actual))
                                        throw new SecurityException("Reopened import failed verification");
                                    persistJournal(context, config.getStorageNamespace(), true);
                                    callback.onSuccess(null);
                                } catch (Exception error) { callback.onError(error); }
                            }
                            public void onError(Exception error) { callback.onError(error); }
                        });
                    }
                    public void onError(Exception error) { callback.onError(error); }
                });
            } catch (Exception error) { callback.onError(error); }
            return;
        }
        Map.Entry<String, String> entry = entries.next();
        String key = storage.addPrefixToKey(entry.getKey());
        storage.write(key, entry.getValue(), new SecurePreferencesCallback<>() {
            public void onSuccess(Void unused) {
                storage.read(key, new SecurePreferencesCallback<>() {
                    public void onSuccess(String value) {
                        if (!entry.getValue().equals(value)) {
                            callback.onError(new SecurityException("Imported value failed verification"));
                            return;
                        }
                        // Avoid recursion for large stores and allow asynchronous cipher callbacks.
                        NativeOperationQueue.INSTANCE.continueOperation(() ->
                            importNext(context, storage, config, expected, entries, callback));
                    }
                    public void onError(Exception error) { callback.onError(error); }
                });
            }
            public void onError(Exception error) { callback.onError(error); }
        });
    }

    private static void requireDestinationArtifacts(Context context, FlutterSecureStorageConfig config) throws Exception {
        String name = config.getStorageNamespace();
        StrictPreferencesSnapshot data = StrictPreferencesSnapshot.read(context, name);
        StrictPreferencesSnapshot keyPrefs = StrictPreferencesSnapshot.read(context, config.getEffectiveKeyStoragePrefsName());
        StrictPreferencesSnapshot markers = StrictPreferencesSnapshot.read(context, "FlutterSecureStorageConfiguration:" + name);
        java.security.KeyStore keys = java.security.KeyStore.getInstance("AndroidKeyStore");
        keys.load(null);
        String alias = context.getPackageName() + ".FlutterSecureStoragePluginKeyOAEP." + name;
        if (!data.exists || !(keys.getKey(alias, null) instanceof java.security.PrivateKey)
                || keyPrefs.string("AESVGhpcyBpcyB0aGUga2V5IGZvciBhIHNlY3VyZSBzdG9yYWdlIEFFUyBLZXkK", null) == null
                || !KEY_ALGORITHM.equals(markers.string("FlutterSecureSAlgorithmKey", null))
                || !STORAGE_ALGORITHM.equals(markers.string("FlutterSecureSAlgorithmStorage", null)))
            throw new SecurityException("Managed destination artifacts are missing; source and destination preserved");
    }

    private static void validateDestinationFiles(Context context, FlutterSecureStorageConfig config) throws Exception {
        StrictPreferencesSnapshot.read(context, config.getEffectiveDataPrefsName());
        StrictPreferencesSnapshot.read(context, config.getEffectiveKeyStoragePrefsName());
        StrictPreferencesSnapshot.read(context, "FlutterSecureStorageConfiguration:" + config.getStorageNamespace());
        // Upstream config constructs this fallback even when namespaced values are present.
        StrictPreferencesSnapshot.read(context, "FlutterSecureStorageConfiguration");
    }

    private static boolean hasDestinationArtifacts(Context context, FlutterSecureStorageConfig config) throws Exception {
        java.security.KeyStore keys = java.security.KeyStore.getInstance("AndroidKeyStore"); keys.load(null);
        return StrictPreferencesSnapshot.read(context, config.getEffectiveDataPrefsName()).exists
            || StrictPreferencesSnapshot.read(context, config.getEffectiveKeyStoragePrefsName()).exists
            || StrictPreferencesSnapshot.read(context, "FlutterSecureStorageConfiguration:" + config.getStorageNamespace()).exists
            || keys.containsAlias(context.getPackageName() + ".FlutterSecureStoragePluginKeyOAEP." + config.getStorageNamespace());
    }

    private static void persistJournal(Context context, String target, boolean complete) throws Exception {
        FAILED_PERSISTENCE.add(target);
        StrictPreferencesSnapshot disk = StrictPreferencesSnapshot.read(context, JOURNAL);
        Map<String, Object> expected = new HashMap<>(disk.values);
        expected.put(target, complete);
        if (complete) expected.remove(target + ":inProgress");
        else expected.put(target + ":inProgress", true);
        // Force a changed generation even when a failed commit already updated Android's cache.
        expected.put("revision", java.util.UUID.randomUUID().toString());
        SharedPreferences.Editor editor = context.getSharedPreferences(JOURNAL, 0).edit().clear();
        for (Map.Entry<String, Object> entry : expected.entrySet()) {
            if (entry.getValue() instanceof Boolean) editor.putBoolean(entry.getKey(), (Boolean) entry.getValue());
            else if (entry.getValue() instanceof String) editor.putString(entry.getKey(), (String) entry.getValue());
            else throw new IOException("Invalid migration journal value");
        }
        requireCommit(editor);
        if (!StrictPreferencesSnapshot.read(context, JOURNAL).values.equals(expected))
            throw new IOException("Migration journal disk readback failed");
        if (complete) FAILED_PERSISTENCE.remove(target);
    }

    /** commit() waits for earlier apply() writes; durable keys/config/data precede completion. */
    static void flush(Context context, FlutterSecureStorageConfig config) throws IOException {
        if (!isManaged(config)) return;
        requireCommit(context.getSharedPreferences(config.getEffectiveKeyStoragePrefsName(), 0).edit());
        requireCommit(context.getSharedPreferences(
            "FlutterSecureStorageConfiguration:" + config.getEffectiveDataPrefsName(), 0).edit());
        requireCommit(context.getSharedPreferences(config.getEffectiveDataPrefsName(), 0).edit());
    }

    private static void requireCommit(SharedPreferences.Editor editor) throws IOException {
        if (!editor.commit()) throw new IOException("Secure-storage durable commit failed");
    }
}
