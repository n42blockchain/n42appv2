# SQLCipher Stage3 source review

Reviewed `0224b3ae14ed286d475efdfbdeec58a278f76d22..dcedef8dc2f60bfdc2aacd389d7d6f3e81b3b055` against the implementation brief. Scope is the four committed files: isolated Dart fixture, fixture repository selector, APK-path channel hook, and normal version bump.

## Verdict

- **Spec compliance: PASS for this source checkpoint.**
- **Code quality: PASS.** No actionable defect found in this bounded increment.
- Runtime, runner/verifier, installed native identity and durable evidence acceptance remain pending. No device, build or test reruns were performed for this review.

## Source checks

- `tools/android_native_smoke/harness/integration_test/sqlcipher_migration_test.dart:49`: the seed requires FFI SQLCipher 4.10 and creates two distinct encrypted old databases. Official and maintained verification phases use their own previously existing file; they cannot silently recreate a missing seed. The plaintext export source is shared but export does not modify it.
- The verification body at line 86 requires FFI 4.19 and exercises Java encrypted read/insert/update/delete, close/reopen and exact saved rows. Wrong/null Java keys are rejected, then a correct key still reads the expected row count. FFI wrong/null keys are likewise followed by a successful keyed read of the exact rows. Thus an unavailable or corrupted database alone cannot satisfy the overall test.
- The export section uses `sqlcipher_export`, then reopens the resulting file with the key through both FFI and Java. The separate Matrix database is initialized through plain sqflite and checked for the plaintext SQLite header. Inputs are fixed synthetic keys and data; no account or validator calls are introduced.
- `printRuntimeReceipt` records installed APK path/hash, PID/nonce, mapping rows and database hashes only after the phase assertions. Its broad initial mapping-presence check is a collection hook, not final proof that the selected SQLCipher ELF was mapped. The next runner/verifier must require test success and independently bind exact APK member/ELF mapping and pre/post device state, as already queued.
- `harness/android/build.gradle.kts:4` selects the maintained repository only for the explicit maintained-phase environment switch and only the exact SQLCipher 4.19 coordinate. The repository path resolves to the task-owned app Maven directory. `MainActivity.kt` adds only the fixture APK-path query; existing native vector handlers are unchanged.

## Retained evidence and bounds

The retained Dart analyzer output reports no issues; `fixture-kotlin-compile1.log` records successful Kotlin compilation (59 tasks, 13 executed). `fixture-candidate-artifact1.log` identifies app runtime maintained 4.19 SHA `4c3a1ab35258f98c13f34775621c730fbe1e2d39c0207be110f98bf07d99c25c` while the published fixture plugin compiles against official 4.10. The report correctly distinguishes that fixture arrangement from the separately accepted production host/vendored-plugin Stage2 selection. Compilation is not runtime evidence.

The pending-runtime paragraph anticipates compatibility controls, but it is not an accepted mode decision: the controller requires strict attempts first, retained failures if any, and only a separately bounded seed fallback if necessary. Maintained-candidate acceptance requires strict 16 KB execution. The upcoming actual runner/evidence review owns these checks. No current old-library crash, migration success, full-app or release acceptance is claimed.
