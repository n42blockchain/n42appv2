# Secure storage 11 migration acceptance — Task 13B

Date: 2026-09-26. Base app commit: `e28c0fbcf`.
Scope: maintained packages and independent Android upgrade fixture. Host/Chat
manifest integration and release builds are Task14; store compliance is Task16.

## Result

The dedicated Android API 36 arm64 emulator passed **40 native stage invocations**
(including fixture seeding), plus recovery from one deliberately terminated import
process. Real published v9.2.4 ESP and RSA/CBC data and published v10.3.4 RSA-OAEP/GCM
data remain readable after a direct APK upgrade to the maintained v11.2.0 plugin.
Review fix round 1 also passed **42 focused persistence/corruption stages** and
reran the original 40-stage native suite with interruption recovery.
The upstream secure-storage Dart suite passed **92/92**; Facebook desktop API/CRUD
compatibility passed **2/2**. Both package analyzers report no issues.

This does not claim a final host build or a real Facebook OAuth/macOS Keychain
session. Production consumers have not been repinned in this task.

## Native mapping and protocol

| Historical data file | Configured prefix | Actual on-disk key prefix | Isolated destination |
| --- | --- | --- | --- |
| n42_secure_prefs | n42_ | n42__ | n42_secure_v11_wallet |
| n42_secure_prefs | sp_ | sp__ | n42_secure_v11_preferences |
| FlutterSecureStorage | upstream default | default plus appended underscore | n42_secure_v11_default |

The native plugin transparently maps default AndroidOptions used by Chat, auth,
Reown and other dependencies. Task14 must set the two host namespaces explicitly:

```dart
AndroidOptions(
  storageNamespace: 'n42_secure_v11_wallet', // preferences: n42_secure_v11_preferences
  preferencesKeyPrefix: 'n42_', // preferences: sp_
  resetOnError: false,
)
```

Keep iOS accountName values `n42wallet` / `n42wallet_prefs` and
`first_unlock_this_device` unchanged. Dart/platform runtime comes from upstream11;
no Apple-specific implementation or privacy metadata is changed here. New Android
values use upstream encryption; logical preference keys remain visible inside the
app-private preferences file. Correct the old host comments claiming key encryption
and automatic v9-to-v11 migration when performing Task14 integration.

A process-wide asynchronous queue gates migration **and CRUD** before upstream
initialization, including calls from another Flutter engine. It stays alive across
engine detachment and advances once on a terminal callback. Unknown legacy scopes
and unsupported managed cipher/biometric options fail closed. Named unmanaged
namespaces retain upstream behavior.

The adapter reads existing ESP keysets/Keystore aliases and RSA-wrapped legacy
application keys without creating or replacing them. Missing keys, invalid input,
unsupported ciphers and conflicting ESP/raw values return errors. Both prefixes in
the shared file migrate independently; no file-wide completion shortcut is used.

Only after the source is readable and an in-progress journal record is durably
committed does the adapter initialize a separate v11 data
file, wrapped-key file, config and Keystore namespace. It writes and reads back each
value, durably flushes destination data/config/keys, reopens with a fresh upstream
cipher and compares the entire imported map, then commits that destination's
completion record. Only destinations with a valid in-progress journal state can
be rebuilt after interruption. Missing state with existing destination files or
aliases fails closed. Original encrypted files and aliases remain untouched.

Completion lives separately in `n42_secure_v11_migration` and survives both delete
and deleteAll. Retained original ciphertext is never reimported after completion.
Completed destinations also require their existing data, config, wrapped-key and
Keystore artifacts; a missing destination key fails before upstream can regenerate
it. Every operation reads the journal from strict disk XML, never a cached boolean.
Journal writes rebuild the validated disk map, force a new revision nonce, require
`commit()==true`, and verify exact disk readback. Failed persistence remains blocked
across engines in the process until verification and persistence succeed.

Legacy source/config/wrapped keys and ESP keysets are read directly from validated
XML snapshots. Malformed, truncated or unreadable XML is an error. Any `.bak` is
preserved and rejected before Android can rename/delete it. Managed destination
data/config/wrapped keys and journal are also validated before initialization or
CRUD. Repair must supply known-good bytes; no automatic empty-store fallback or
backup repair occurs. This addresses [AOSP SharedPreferences loading and commit
semantics](https://raw.githubusercontent.com/aosp-mirror/platform_frameworks_base/master/core/java/android/app/SharedPreferencesImpl.java).
`resetOnError=false` is enforced natively even when a caller sends true.

The upstream `checkUpgradeStatus` diagnostic inspects the resolved destination; it
is not an end-to-end legacy import health check. Actual access always runs the gate.

## Native evidence

The fixture uses only `com.n42.storage_migration_test` on `emulator-5554`. All APKs
have the same signing certificate (recorded in `apk-provenance.json`). Each upgrade
uses `adb -s emulator-5554 install -r`; there is no uninstall or intermediate v10
between a v9 seed and its v11 reader. Fixture seeding uses the actual unmodified
published plugin and real Android Keystore, not a Dart mock. Cached v9/v10 runtime
bytes were compared with the official archives with zero differences.

Each of ESP, CBC and GCM exercises:

- All three namespaces, process restart, exact Reown JSON at
  `wc@2:core:0.3//keychain` (published reown_core 1.5.1 constants), and a Chat-style key.
- Twenty queued reads through **two real FlutterEngine instances during initial
  migration**, a queued error, and destruction of one engine while work is pending.
- Exactly-once queue advancement, write/read/readAll/containsKey/delete, and
  delete/deleteAll followed by a new process with no resurrection.
- Missing source keys with read/write/delete/deleteAll all failing closed; no
  replacement legacy aliases and no completion marker are created.
- SHA256 comparison of original encrypted XML, original alias/certificate presence,
  and no public credential sentinel in SharedPreferences plaintext.

Additional ESP cases inject a corrupt source and repair it before retry, a failed
value verification followed by retry, and a missing completed-destination key.
The failure test proves both original and deliberately corrupted bytes remain
unchanged during their respective failed migration calls. It repairs the in-memory
preferences and restores original encrypted byte order **before** retry, then the
next verification/restart compares against that original snapshot. A separate
focused final rerun includes the explicit corrupted-byte assertion.

For interruption, a test-only subclass signals after the first encrypted write is
durable and withholds completion. The script force-stops only this fixture app.
`kill-during-import.log` records the expected process crash; the next two process
runs recover and read all values. Test fault injection is confined to the
instrumentation APK, with no production test channel or fault switch.

The fixture's merged manifest has no `android:process` or `isolatedProcess` flags.
Final host merged-manifest confirmation is still required in Task14: this queue
supports multiple engines/isolates in one process, not independent Android
processes. Successful SharedPreferences commit/readback is the persistence boundary;
the adapter cannot certify OEM filesystem or hardware behavior after power loss.
A real directory-permission failure is tested specifically at completion commit.
OS power loss, physical/OEM devices, actual disk-full/fsync failures,
biometric prompts, whole-app backup rollback, and real desktop OAuth/Keychain were
not exercised. The scoped managed stores use non-biometric RSA/OAEP, as their
historical app configurations do.

## Review fix round 1 evidence

Base for the review fixes: `d12983a9b7cef94a15f6da8d6f040c85ae7da663`.

- Real completion persistence failure: the instrumentation context changes only
  this fixture's preferences-directory permissions immediately before the actual
  Android editor commit. The commit errors after updating memory to completion=true.
  Another real FlutterEngine cannot read/write/delete/deleteAll; denied operations
  leave disk bytes and aliases unchanged. Restored permissions permit retry, read
  and delete; a fresh process confirms no resurrection.
- Fresh-process malformed and truncated XML cases cover source data, source config
  and wrapped keys, completion journal after credential deletion, and completed
  destination data/config/wrapped keys. Every read/readAll/containsKey/write/delete/
  deleteAll returns an error without changing file bytes or aliases. Original bytes
  are restored **before** a new-process retry.
- Missing journal after deletion fails closed; restoring its known-good bytes
  retains deletion. Source, journal and destination `.bak` files remain byte-exact
  on denied access. Unreadable source/journal files error and recover after restoring
  permissions; the original bytes are then compared.
- New behavior RED logs: `review-red-completion-esp-completion.log` and
  `review-red-source-esp-malformed.log`. Final GREEN: `review-persistence-suite.log`,
  `persistence-results.json`, `review-native-suite.log`, `native-results.json`,
  `review-secure-dart-test.log`. `iteration-notes.md` records parser iteration failure.

## Reproduction and artifacts

```sh
python3 tools/secure_storage_migration/run_suite.py
python3 tools/secure_storage_migration/run_persistence_suite.py
python3 tools/secure_storage_migration/upstream_diff.py
```

The harness uses isolated Flutter3.47.5/JDK21, Android API/compile/target36, AGP8.13.2,
Gradle8.14.4 and Kotlin2.4.20 to support the real old writer. Inherited AGP/Gradle
future-support warnings, Java8 source warnings from v9, NDK version warnings from
transitive JNI, and deprecated Tink reader API warnings are retained in build logs;
all three APK/instrumentation builds completed. These do not certify the Task14
SDK37 host toolchain.

Local raw evidence is under `tools/secure_storage_migration/logs/`. The tracked
compressed bundle is [secure-storage-logs.tar.gz](secure-storage-logs.tar.gz).
Bundle SHA256: `3f9a503c5bfb2776ffcce0f21c7cdcece5760e791a9232c88180f67d19883a55`.
Key entries: `final-native-suite.log`, `native-results.json`, `apk-provenance.json`,
`upgrade-*-*-engines.log`, `upgrade-*-*-verify-initial.log`,
`upgrade-*-*-verify-restart.log`, `missing-*-*-missingLegacyKey.log`,
`verification-esp-verificationRetry.log`, `esp-verification-final.log`,
`esp-verify-final.log`, `esp-verify-final-restart.log`, `kill-during-import.log`,
`interrupt-esp-verify-after-interruption.log`, and the two package test/analyze logs.
The bundle separately retains the real unpatched11 ESP RED, destination-key
regeneration RED, and the test-injection XML-ordering failure.

Review the small changes against pristine official runtime:
[secure-storage patch](flutter_secure_storage-n42.patch.gz) and
[Facebook desktop patch](facebook_auth_desktop-n42.patch.gz).
The patches use lossless gzip compression to preserve unified-diff context.
Use `gzip -dc <file>.patch.gz` to inspect them. They include the documented cosmetic
trailing-whitespace cleanup of imported Java, Swift and pubspec files.
Each package includes a LICENSE, N42_PROVENANCE.md and UPSTREAM_SHA256.json.
The AndroidX-derived ESP reader keeps its original Apache-2.0 copyright/header
and full license. Facebook's published macOS Swift file and podspec are retained;
that upstream archive has no PrivacyInfo.xcprivacy, so no declaration was invented.

## Integration order

1. Independently review these maintained sources and native evidence.
2. Publish the reviewed app source commit A containing both packages.
3. Point Chat/host at immutable Git ref A and package subpaths. Root overrides may
   select these reviewed sources for hosted transitive consumers; do not use a
   production path override or an untested version-only override.
4. Task14 updates host namespace options, exact Chat SHA and the final dependency
   graph, checks all platform builds and preserves iOS keychain attributes.
5. Task16 performs the final Google Play/App Store release/privacy acceptance.

No push, root dependency migration, Chat change, physical-device operation, or
production-app installation is part of this task. Coverage expansion remains
explicitly deferred by the controller.

## Official source checksums

| Package | Version | Archive SHA256 |
| --- | --- | --- |
| flutter_secure_storage | 9.2.4 fixture | 9cad52d75ebc511adfae3d447d5d13da15a55a92c9410e50f67335b6d21d16ea |
| flutter_secure_storage | 10.3.4 fixture/reference | fe638107c5f69119156ada2db5a57734385fac3f64430bd7252a00d3ead2ca4b |
| flutter_secure_storage | 11.2.0 maintained base | d4e1fb6b2cb524868929e78dc0282fa000554b22060fb53789dc481c9fc95bb8 |
| facebook_auth_desktop | 2.1.3 maintained base | 9fcde1146914e9f46497d2b6053ea5865828b576a258be4e0193635f52176712 |
