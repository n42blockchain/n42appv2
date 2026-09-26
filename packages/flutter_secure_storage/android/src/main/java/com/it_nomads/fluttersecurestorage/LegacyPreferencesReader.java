// Derived from flutter_secure_storage 10.3.4's RSA18/RSAOAEP and AES18/GCM readers.
// BSD-3-Clause: see LICENSE and N42_PROVENANCE.md. No key creation or source editing.
package com.it_nomads.fluttersecurestorage;

import android.content.Context;
import android.util.Base64;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.spec.AlgorithmParameterSpec;
import java.security.spec.MGF1ParameterSpec;
import java.util.Arrays;
import java.util.Map;
import java.util.TreeMap;
import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.OAEPParameterSpec;
import javax.crypto.spec.PSource;

final class LegacyPreferencesReader {
    static final String DEFAULT_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIHNlY3VyZSBzdG9yYWdlCg";
    private static final String CBC_KEY = "VGhpcyBpcyB0aGUga2V5IGZvciBhIHNlY3VyZSBzdG9yYWdlIEFFUyBLZXkK";
    private static final String GCM_KEY = "AES" + CBC_KEY;
    private static final String V9_GCM_KEY = "VGhpcyBpcyB0aGUga2V5IGZvcihBIHNlY3XyZZBzdG9yYWdlIEFFUyBLZXkK";

    static Map<String, String> read(Context context, String file, String prefix) throws Exception {
        StrictPreferencesSnapshot data = StrictPreferencesSnapshot.read(context, file);
        StrictPreferencesSnapshot namespaced = StrictPreferencesSnapshot.read(context, "FlutterSecureStorageConfiguration:" + file);
        StrictPreferencesSnapshot global = StrictPreferencesSnapshot.read(context, "FlutterSecureStorageConfiguration");
        StrictPreferencesSnapshot wrapped = StrictPreferencesSnapshot.read(context, "FlutterSecureKeyStorage");
        Map<String, ?> all = data.values;
        Map<String, Object> esp = new TreeMap<>();
        Map<String, String> raw = new TreeMap<>();
        String onDiskPrefix = prefix + "_";
        for (Map.Entry<String, ?> e : all.entrySet()) {
            String key = e.getKey();
            if (LegacyEncryptedPreferences.isKeyset(key) || key.equals("FlutterSecureSAlgorithmKey")
                    || key.equals("FlutterSecureSAlgorithmStorage")) continue;
            if (key.startsWith(onDiskPrefix)) {
                if (!(e.getValue() instanceof String)) throw new SecurityException("Legacy value is not a string");
                raw.put(key.substring(onDiskPrefix.length()), (String) e.getValue());
            } else if (!key.startsWith("n42__") && !key.startsWith("sp__")
                    && !key.startsWith(DEFAULT_PREFIX + "_")) {
                esp.put(key, e.getValue());
            }
        }
        Map<String, String> result = LegacyEncryptedPreferences.read(context, file, onDiskPrefix, esp, data);
        if (raw.isEmpty()) return result;
        String keyAlgorithm = namespaced.string("FlutterSecureSAlgorithmKey",
            global.string("FlutterSecureSAlgorithmKey", data.string("FlutterSecureSAlgorithmKey", null)));
        String storageAlgorithm = namespaced.string("FlutterSecureSAlgorithmStorage",
            global.string("FlutterSecureSAlgorithmStorage", data.string("FlutterSecureSAlgorithmStorage", null)));
        if (keyAlgorithm == null) keyAlgorithm = "RSA_ECB_PKCS1Padding";
        if (storageAlgorithm == null) storageAlgorithm = "AES_CBC_PKCS7Padding";
        boolean oaep = keyAlgorithm.equals("RSA_ECB_OAEPwithSHA_256andMGF1Padding");
        boolean gcm = storageAlgorithm.equals("AES_GCM_NoPadding");
        if ((!oaep && !keyAlgorithm.equals("RSA_ECB_PKCS1Padding"))
                || (!gcm && !storageAlgorithm.equals("AES_CBC_PKCS7Padding")))
            throw new SecurityException("Unsupported legacy cipher; source preserved");
        String alias = context.getPackageName() + ".FlutterSecureStoragePluginKey" + (oaep ? "OAEP" : "");
        KeyStore keys = KeyStore.getInstance("AndroidKeyStore"); keys.load(null);
        Key privateKey = keys.getKey(alias, null);
        if (!(privateKey instanceof PrivateKey)) throw new SecurityException("Legacy RSA key is missing");
        String encodedKey = wrapped.string(gcm ? GCM_KEY : CBC_KEY, null);
        if (gcm && encodedKey == null) encodedKey = wrapped.string(V9_GCM_KEY, null);
        if (encodedKey == null) throw new SecurityException("Legacy wrapped key is missing");
        Cipher rsa = Cipher.getInstance(oaep ? "RSA/ECB/OAEPPadding" : "RSA/ECB/PKCS1Padding",
            "AndroidKeyStoreBCWorkaround");
        AlgorithmParameterSpec rsaParameters = oaep
            ? new OAEPParameterSpec("SHA-256", "MGF1", MGF1ParameterSpec.SHA1, PSource.PSpecified.DEFAULT) : null;
        rsa.init(Cipher.UNWRAP_MODE, privateKey, rsaParameters);
        Key aes = rsa.unwrap(Base64.decode(encodedKey, Base64.DEFAULT), "AES", Cipher.SECRET_KEY);
        if (aes.getEncoded() == null || aes.getEncoded().length != 16)
            throw new SecurityException("Invalid legacy application key");
        Cipher cipher = Cipher.getInstance(gcm ? "AES/GCM/NoPadding" : "AES/CBC/PKCS7Padding");
        int ivLength = gcm ? 12 : 16;
        for (Map.Entry<String, String> e : raw.entrySet()) {
            byte[] encrypted = Base64.decode(e.getValue(), Base64.DEFAULT);
            if (encrypted.length <= ivLength) throw new SecurityException("Truncated legacy ciphertext");
            byte[] iv = Arrays.copyOf(encrypted, ivLength);
            AlgorithmParameterSpec parameters = gcm ? new GCMParameterSpec(128, iv) : new IvParameterSpec(iv);
            cipher.init(Cipher.DECRYPT_MODE, aes, parameters);
            byte[] clear = cipher.doFinal(encrypted, ivLength, encrypted.length - ivLength);
            try {
                String value = StandardCharsets.UTF_8.newDecoder().decode(java.nio.ByteBuffer.wrap(clear)).toString();
                if (result.containsKey(e.getKey()) && !result.get(e.getKey()).equals(value))
                    throw new SecurityException("Conflicting legacy ESP and cipher values; source preserved");
                result.put(e.getKey(), value);
            } finally {
                Arrays.fill(clear, (byte) 0);
            }
        }
        return result;
    }
}
