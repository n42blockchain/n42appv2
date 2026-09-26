/*
 * Copyright 2019 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.it_nomads.fluttersecurestorage;

import android.content.Context;
import android.util.Base64;
import com.google.crypto.tink.Aead;
import com.google.crypto.tink.DeterministicAead;
import com.google.crypto.tink.KeysetHandle;
import com.google.crypto.tink.RegistryConfiguration;
import com.google.crypto.tink.aead.AeadConfig;
import com.google.crypto.tink.daead.DeterministicAeadConfig;
import com.google.crypto.tink.integration.android.AndroidKeystoreKmsClient;
import com.google.crypto.tink.BinaryKeysetReader;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.KeyStore;
import java.util.Map;
import java.util.TreeMap;

/** Read-only extraction of v10.3.4's AndroidX ESP string decoding; see N42_PROVENANCE.md. */
final class LegacyEncryptedPreferences {
    static final String KEY_KEYSET = "__androidx_security_crypto_encrypted_prefs_key_keyset__";
    static final String VALUE_KEYSET = "__androidx_security_crypto_encrypted_prefs_value_keyset__";
    private static final String MASTER_ALIAS = "_androidx_security_master_key_";

    static boolean isKeyset(String key) {
        return key.equals(KEY_KEYSET) || key.equals(VALUE_KEYSET);
    }

    private static byte[] decodeKeyset(String encoded) throws Exception {
        if (encoded == null || encoded.isEmpty() || encoded.length() % 2 != 0)
            throw new SecurityException("Invalid legacy keyset encoding");
        byte[] bytes = new byte[encoded.length() / 2];
        for (int i = 0; i < bytes.length; i++) {
            int high = Character.digit(encoded.charAt(2 * i), 16);
            int low = Character.digit(encoded.charAt(2 * i + 1), 16);
            if (high < 0 || low < 0) throw new SecurityException("Invalid legacy keyset hex");
            bytes[i] = (byte) ((high << 4) | low);
        }
        return bytes;
    }

    static Map<String, String> read(Context context, String file, String prefix,
                                    Map<String, ?> encryptedEntries, StrictPreferencesSnapshot prefs) throws Exception {
        Map<String, String> values = new TreeMap<>();
        if (encryptedEntries.isEmpty()) return values;
        if (!prefs.values.containsKey(KEY_KEYSET) || !prefs.values.containsKey(VALUE_KEYSET))
            throw new SecurityException("Legacy ESP keyset is missing");
        KeyStore keys = KeyStore.getInstance("AndroidKeyStore");
        keys.load(null);
        if (!keys.containsAlias(MASTER_ALIAS))
            throw new SecurityException("Legacy ESP master key is missing");
        DeterministicAeadConfig.register();
        AeadConfig.register();
        // Unlike AndroidKeysetManager.Builder, these APIs never generate/persist a keyset.
        Aead master = new AndroidKeystoreKmsClient().getAead("android-keystore://" + MASTER_ALIAS);
        DeterministicAead keyAead = KeysetHandle.read(
            BinaryKeysetReader.withBytes(decodeKeyset(prefs.string(KEY_KEYSET, null))), master)
            .getPrimitive(RegistryConfiguration.get(), DeterministicAead.class);
        Aead valueAead = KeysetHandle.read(
            BinaryKeysetReader.withBytes(decodeKeyset(prefs.string(VALUE_KEYSET, null))), master)
            .getPrimitive(RegistryConfiguration.get(), Aead.class);
        for (Map.Entry<String, ?> entry : encryptedEntries.entrySet()) {
            String encryptedKey = entry.getKey();
            String key = new String(keyAead.decryptDeterministically(
                Base64.decode(encryptedKey, Base64.DEFAULT), file.getBytes(StandardCharsets.UTF_8)),
                StandardCharsets.UTF_8);
            if (!key.startsWith(prefix)) continue;
            if (!(entry.getValue() instanceof String))
                throw new SecurityException("Legacy ESP value is not encoded as a string");
            byte[] clear = valueAead.decrypt(Base64.decode((String) entry.getValue(), Base64.DEFAULT),
                encryptedKey.getBytes(StandardCharsets.UTF_8));
            try {
                ByteBuffer buffer = ByteBuffer.wrap(clear);
                if (buffer.remaining() < 8 || buffer.getInt() != 0)
                    throw new SecurityException("Legacy secure-storage value is not an ESP string");
                int length = buffer.getInt();
                if (length < 0 || length != buffer.remaining())
                    throw new SecurityException("Legacy ESP string length is invalid");
                String value = StandardCharsets.UTF_8.decode(buffer).toString();
                if (value.equals("__NULL__"))
                    throw new SecurityException("Legacy secure-storage string is null");
                values.put(key.substring(prefix.length()), value);
            } finally {
                java.util.Arrays.fill(clear, (byte) 0);
            }
        }
        return values;
    }
}
