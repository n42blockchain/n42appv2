# Android secure-storage upgrade acceptance

Only `emulator-5554`, application ID `com.n42.storage_migration_test`, and public
fake credentials are used. The suite never uninstalls between a legacy writer and
the maintained reader. Fixture reset code checks its application ID before
clearing its own files and Keystore aliases. It never accesses production apps,
the physical phone, or a global adb/emulator shutdown command.

Run from the app worktree:

```sh
python3 tools/secure_storage_migration/run_suite.py
```

Prerequisites on the recorded macOS environment:

- Flutter 3.47.5 at `~/.codex/toolchains/flutter-3.47.5/flutter`.
- Android SDK with platform/build-tools 36 at `~/Library/Android/sdk`.
- JDK 21 at `/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home`.
- Running arm64 emulator at `emulator-5554` (tested Android API 36).

The harness deliberately uses AGP 8.13.2 / Gradle 8.14.4 / Kotlin 2.4.20 and
compile/target 36 to run the actual published v9 package as well as v11.
It is independent of the Task14 host SDK 37 migration. Flutter creates ignored
Gradle launcher/local configuration files during `flutter build apk`; it does not
require committing a local SDK path, signing key, generated registrant, or build.

`run_fixture.py build 9.2.4`, `build 10.3.4`, and `build maintained` resolve each
real package separately and build app/instrumentation APKs. `run_suite.py` installs
the old app, seeds encrypted data, and directly uses `adb install -r` for the new
app with the same application ID/signing certificate. The only local dependency
path is in this test harness; production consumers must use reviewed immutable
Git package references.

Tests cover ESP, RSA/CBC, RSA-OAEP/GCM; all three mappings; exact Reown JSON and a
Chat-style key; real engine concurrency and detach during initial migration;
CRUD; source bytes and aliases; restart and deletion; missing keys; corrupt input;
failed read-back and retry; new installations; and a real process termination
after encrypted destination write but before completion. Test fault subclasses
live only in `src/maintainedTest`, compiled into the instrumentation APK.

The failed-verification test saves source bytes in memory, proves the first
failure leaves them unchanged, deliberately corrupts the source, proves the next
failure leaves those corrupted bytes unchanged, repairs the SharedPreferences
cache and restores the original encrypted bytes **before** retry, then checks
retry/restart against that original snapshot. It never restores after a migration
call to hide a source write.

Raw logs and APKs are ignored under `logs/` and `apks/`. `native-results.json`
records final stage results. The checked-in report includes a compressed log
bundle. A crash result in `kill-during-import.log` is the expected interruption;
the following verification must pass. Retained RED logs remain separately named.

Recreate losslessly compressed `.patch.gz` review patches against the two official
package archives (the generator verifies archive hashes and gzip round trips):

```sh
python3 tools/secure_storage_migration/upstream_diff.py
```

Inspect a patch with `gzip -dc <file>.patch.gz`. Validate it against the maintained
files by piping the decompressed bytes to `git apply --reverse --check` from the
repository root. Unified-diff context whitespace is preserved inside gzip.

Review persistence regressions (after building maintained APKs):

```sh
python3 tools/secure_storage_migration/run_persistence_suite.py
```

This suite reproduces a real completion commit permission failure and checks other
FlutterEngine access, repair, deletion and restart. Fresh processes exercise XML
corruption/truncation, missing journal state, unreadable files and `.bak` ambiguity;
all denied operations preserve file bytes and aliases. Repairs occur before retry.
