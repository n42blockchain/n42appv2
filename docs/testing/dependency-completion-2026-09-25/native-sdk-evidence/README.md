# Task16B Android MobileSdk evidence archive

This bounded archive backs [the Android SDK summary](../native-sdk-android-2026-09-26.md). `manifest.json` records SHA-256 and byte count for every archived file and relevant fixture source, plus the five actual strict 16 KB debug harness runs. Recheck it from the app root with `python3 tools/android_native_smoke/verify_mobile_sdk_evidence.py`. The checker reads logs and files; it does not load any SDK.

## What was run

`native-runtime.log`, `tls-runtime.log`, `bls-runtime.log`, `legacy-runtime.log`, and `maintained-runtime.log` are new runs made with one runner SHA-256 `e3a757bc6de135d6f7b222195994707744990f640d82228ed938d81d8fac4b81` on `emulator-5560`. Each records the selected AAR hash, pinned Flutter, test/Kotlin/Gradle source hashes, the debug APK hash, the arm64 library hash in that APK, and device properties both before and after the test: `PAGE_SIZE=16384`, linker app compatibility `fatal`, package compatibility disabled `true`. Android Gradle Plugin strips the AAR `.so` for the APK. The runner uses the pinned NDK 28.2 `llvm-strip --strip-unneeded` and requires the stripped AAR member to equal the APK member byte for byte; the raw AAR-to-APK hashes are not expected to match. The BLS run makes the same check for its test-only oracle library. `tls-runtime.log` also records the supplier verifier logcat decisions: 19 mock cases and one default untrusted-root rejection.

These are **debug harness APKs**, each rebuilt for one test mode. They are not the final app release APK. `task/task-16b-release-apk-final.log`, `task/task-16b-release-aab-final.log`, and `task/task-16b-release-*-native-audit.json` record the separate final release construction and static checks. The final APK SHA-256 is `9da4974f11427749786996d1f40e26c99e402db8a4640c9e5c5499848171ecc0`; AAB SHA-256 is `0fe3da0660c5b35011516bcb49a5e041855304f5e2f4293de238fd23c540b9c4`. Both used temporary local debug signing. The full audits each fail **37/55** other packaged libraries. The changed SDK libraries pass 4/4. Static audit failure is not an observed loader crash.

`native-runtime-invalid-prestrip.log` is retained as a failed evidence method: an earlier runner printed PASS after a false bare `[[ ]]` under this host's `/bin/bash 3.2.57` and incorrectly compared raw rather than stripped members. `native-runtime-relative-input-red.log` records a subsequent test setup failure from passing a relative AAR path into the harness; the runner now normalizes that path. Neither log is counted as a successful run. `vector-comparison.log` uses the new legacy/maintained device logs. `vector-comparison-negative.log` rejects a deliberately changed gas value in `maintained-runtime-mutated-gas.log`, which is test data, not an actual SDK result.

## Reproduce the focused device runs

Use an isolated disposable arm64 Android API 37 emulator configured as above. From the app root, set these absolute tool paths to the pinned local installations; do not point the runner at a production account or validator:

```sh
export N42_SMOKE_ADB_BIN=/Users/jieliu/.codex/toolchains/android-sdk-37/platform-tools/adb
export N42_SMOKE_FLUTTER_BIN=/Users/jieliu/.codex/toolchains/flutter-3.47.5/flutter/bin/flutter
export N42_SMOKE_LLVM_STRIP_BIN=/Users/jieliu/.codex/toolchains/android-sdk-37/ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-strip
export N42_SMOKE_DEVICE_SERIAL=emulator-5560
export ANDROID_SDK_ROOT=/Users/jieliu/.codex/toolchains/android-sdk-37
export ANDROID_HOME="$ANDROID_SDK_ROOT"
tools/android_native_smoke/run_mobile_sdk_fixture.sh native android/app/libs/mobile-sdk-android.aar
```

For the remaining modes, call the same runner serially:

```sh
export N42_SMOKE_TLS_VERIFIER_SOURCE=/absolute/checkout/rustls-platform-verifier-v0.5.3
tools/android_native_smoke/run_mobile_sdk_fixture.sh tls /absolute/task/mobile-sdk-tls-fixture.aar
export N42_SMOKE_BLS_ORACLE_JNILIBS=/absolute/task/bls-oracle-jni
tools/android_native_smoke/run_mobile_sdk_fixture.sh bls android/app/libs/mobile-sdk-android.aar
git show 73a44a8f182ff60a2db708ddfd15fa2a9cb61120:plugins/flutter_mining/android/libs/mobile-sdk-release.aar > /absolute/task/legacy-packaged-mobile-sdk.aar
tools/android_native_smoke/run_mobile_sdk_fixture.sh legacy /absolute/task/legacy-packaged-mobile-sdk.aar
tools/android_native_smoke/run_mobile_sdk_fixture.sh maintained android/app/libs/mobile-sdk-android.aar
python3 tools/android_native_smoke/compare_mobile_sdk_vectors.py \
  docs/testing/dependency-completion-2026-09-25/native-sdk-evidence/legacy-runtime.log \
  docs/testing/dependency-completion-2026-09-25/native-sdk-evidence/maintained-runtime.log
```

The old packaged AAR must hash `784783d758533826a768bc0697525d9b28caa857a3f4819707877fb790d6b254`. The selected maintained AAR hashes `ec2dce904f925ca044089164e6b7e7821ded77788c214676a18ed357f27e87a5`. The TLS fixture AAR for the recorded run hashes `bc8b8962df31a35fe67c37104de1202dd2451f7b5b31a77908252b929f8e7ac4`; a fresh rebuild has a newly recorded hash supplied with `N42_SMOKE_EXPECTED_TLS_AAR_SHA256`. The BLS oracle JNI binary for the recorded run hashes `1fb890c469294e71be965684cddc9168ffd2f19d7946607cd26d95c9d2c08a6d`; a fresh rebuild may use `N42_SMOKE_EXPECTED_BLS_ORACLE_SHA256` only after recording the new input identity. The pinned supplier verifier checkout must have `HEAD=670de1a872b68c2a0a31a6c491e04bc95d5de5e8`.

The [TLS fixture recipe](../../../../tools/android_native_smoke/tls_fixture_v0_5_3/README.md) carries its separate lock, patch, exact 17 public DER/OCSP files, source and build steps. Its optional `ffi-testing` and mock roots do not enter the selected production AAR. The [BLS oracle recipe](../../../../tools/android_native_smoke/bls_oracle/README.md) pins its source and lock and rebuilds only the test oracle. The [production SDK recipe](../../../../tools/android_native_smoke/mobile_sdk_v0_2_2/README.md) records source tags, production patches/lock, toolchain and correspondence. `rust/tls-fixture-recipe-prepare.log` and `rust/tls-fixture-source-verify.log` record a separate fixture-source replay; `rust/recipe-proof.log` and `rust/recipe-explicit-guards-test.log` record production recipe replay and negative controls. The exact original libclang binary used for the selected SDK build was not captured; a fresh build must record its own libclang identity and result hashes.

## Index and limits

- `task/` retains focused Kotlin/guard/audit test transcripts, final release and earlier failed build transcripts, final APK/AAB audits and the detailed Task16B, TLS and BLS reports. `release-apksigner.log` records a locally valid v2 signature, not store signing.
- `rust/` retains the source/lock failure and repair logs, selected build and ELF audit, Android normal-plus-build graph, whole-lock advisory JSON, candidate iOS graph metadata, old/new raw synthetic vectors and comparator controls, BLS host/build/audit logs, and TLS fixture preparation/failures. The Android selected graph intersects the recorded advisories with zero vulnerability/unsound records; seven unmaintained warnings and a yanked `core2` remain. The whole workspace lock has nine vulnerability records. This does not establish an advisory result for opaque binaries or the current packaged iOS SDK.
- `rust/official-v0.2.2-native-audit.json` is a separate current-script static check of the unchanged supplier AAR: 2 of its 4 native libraries fail the combined LOAD/GNU_RELRO rule. This is not a runtime result and does not replace the selected maintained AAR's 4/4 passing audit.
- The supplier block verification API has no valid `UnverifiedBlock` golden fixture in this archive. BLS checks the generated pair relationship and a test-only signature, not block verification. Production WSS `runClient` and live TLS handshakes were not invoked. Full-app 16 KB release acceptance, Apple SDK rebuild and store signing remain separate work.

The public certificate files, synthetic unsigned transactions and test-only oracle do not contain wallet or validator keys. No full build caches, credentials or release signing assets are archived.
