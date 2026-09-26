# Maintained flutter_secure_storage 11.2.0

Upstream archive: https://pub.dev/api/archives/flutter_secure_storage-11.2.0.tar.gz

SHA256: `d4e1fb6b2cb524868929e78dc0282fa000554b22060fb53789dc481c9fc95bb8`.
`UPSTREAM_SHA256.json` records the original selected archive files before changes.
Published Dart runtime, Android runtime, BSD-3-Clause LICENSE, manifest and upstream
Dart tests are retained. Examples, upstream Android tests and development builds
are omitted. Apple implementations remain the upstream federated Darwin package;
this archive contains no Apple privacy manifest. No upstream runtime privacy
metadata or SDK notices were removed.

## N42 patch

- Remove the monorepo-only `resolution: workspace` from pubspec for a Git subpath
  dependency. Dependency versions and the public Dart API are otherwise upstream.
- Flutter 3.47's analyzer setup adds platform/build directory exclusions.
- `FlutterSecureStoragePlugin` routes native operations through one process-wide
  asynchronous queue, uses the three managed migration mappings, waits for durable
  mutations, and lets in-flight work finish after an engine detaches.
- `FlutterSecureStorage` skips upstream namespace-key recovery for the managed
  destinations. Such recovery can initialize or replace keys in the legacy source.
- `N42StorageMigration` probes before initializing upstream ciphers, isolates each
  destination, imports and verifies every string, flushes keys/config/data, reopens
  with a fresh cipher and verifies the full map, then commits a separate completion
  record. Completed destinations require existing data/config/wrapped-key/Keystore
  artifacts. Reset-on-error is disabled; completion survives delete/deleteAll.
- `NativeOperationQueue` serializes migration and CRUD across Flutter engines and
  isolates in one Android process. It advances once on terminal completion.
- `LegacyPreferencesReader` extracts the existing-key unwrap/decrypt paths and
  format constants from the published 10.3.4 RSA18/RSAOAEP and AES18/GCM ciphers;
  constructors, key generation, key deletion and migration writers are not copied.
  It also reads v9's in-data algorithm markers. Unsupported or conflicting source
  data fails closed. There is no newly designed encryption format.
- `LegacyEncryptedPreferences` derives string decoding from published 10.3.4's
  AndroidX `crypto/EncryptedSharedPreferences.java`. It uses Tink's existing
  `SharedPrefKeysetReader` and existing Keystore AEAD, never a keyset/master-key
  builder. The original AndroidX copyright and Apache-2.0 header are retained;
  the full license is in `THIRD_PARTY_LICENSES/AndroidX-Apache-2.0.txt`.

Legacy reference archive: https://pub.dev/api/archives/flutter_secure_storage-10.3.4.tar.gz

SHA256: `fe638107c5f69119156ada2db5a57734385fac3f64430bd7252a00d3ead2ca4b`.
Both archives were downloaded and hash-verified before derivation. The fixture's
v9.2.4 and v10.3.4 cached runtime bytes were also compared to their official archives
without editing the cache (zero differences).

See `../../docs/testing/dependency-completion-2026-09-25/secure-storage.md` for the
mapping, tests, remaining integration gates, and immutable publication order.
