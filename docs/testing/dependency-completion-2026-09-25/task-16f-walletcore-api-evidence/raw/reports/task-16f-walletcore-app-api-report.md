# Wallet Core Bitcoin V2 Android API correction — source/build checkpoint

This checkpoint is **source/build only**. The new adapter fixture has not run on a device. The old Wallet Core two-APK fixture and evidence archive remain unchanged. No P2WSH spending capability is claimed.

## Production scope

- `TransactionSignerHandler` retains its existing P2WSH input, script, output, fee, network and `maxAmountOutput` construction. It now calls the feature-local Java adapter with the **original** serialized `Bitcoin.SigningInput`, captured compressed key and original DER signer. The adapter checks outer and nested V2 errors, result presence, nonempty sighashes, supported signing method, key identity and final nonempty nested `encoded`, then returns only raw transaction bytes. A failure reaches the existing MethodChannel as `btc_p2wsh_signing_failed`.
- `BitcoinV2SigningAdapter.java` SHA-256: `aaff324d1ab949204c8613c57fae5eed860abc97d04e6b8351d56d39cd2e3ce9`. No Dart method semantics or business route changed; the new Dart test checks existing `PlatformException` to `SIGNING_FAILED` propagation.
- The fixed-tag Rust `tw_utxo/src/signature.rs` `FromRawOrDerBytes` accepts both raw and DER ECDSA signatures. The production DER lambda remains unchanged. The separate device fixture checks DER and tagged raw controls against the same golden output.

## RED/GREEN and bounded compilation

- Initial exact Java adapter test compile was RED, missing the production adapter class: `task-16f-walletcore-build/app-api-test/adapter-red.log`.
- JDK 17 `javac --release 8` against selected Wallet Core classes/proto and actual app `protobuf-javalite:4.36.2`, then JUnit 4.13.2: **6/6 PASS**. Logs: `task-16f-walletcore-build/app-api-test/adapter-compile-green-final.log`, `adapter-unit-green-final.log`.
- Kotlin compiler 2.4.10 compiled the exact production adapter call block against the maintained AAR and Javalite 4.36.2: `task-16f-walletcore-build/app-api-test/adapter-kotlin-snippet-compile.log`. This is a focused syntax/API check, not a full app compile.
- Focused Flutter WalletSigner test: **6/6 PASS**, `task-16f-walletcore-build/app-api-wallet-signer-test.log`.
- `:app:testReleaseUnitTest --dry-run` failed because that exact app task does not exist; `task-16f-walletcore-build/app-api-unit-dry-run.log` retains the failure. `:app:compileReleaseKotlin -x :app:compileFlutterBuildRelease --dry-run` succeeded but listed **934 tasks**, so no broad compile was run. `task-16f-walletcore-build/app-api-kotlin-bounded-dry-run.log`. Local `android/local.properties` was restored byte-for-byte after each probe.

## Separate exact-adapter JNI fixture

- Tracked source: `tools/android_native_smoke/walletcore_api_fixture/`; no `INTERNET` permission. The build stages the single-read, hash-pinned production adapter source into the Java source set, together with the maintained AAR, official proto JAR and app-selected Javalite 4.36.2. Tool and source pins are in `scripts/build_walletcore_api_fixture.py`; the fixed artifact identity is `fixture-build-epoch.json`.
- Earlier build1 exposed a builder `Path` type error before any output; corrected. Builds 1 and 2 were diagnostic because source guards evolved. Controlled final build3 exited 0, 42 Gradle tasks, at `task-16f-walletcore-api-fixture/build3/`. Its APK SHA-256 is `f3f627565b70b42787f15bce7cf1c8024a6c4696b916a289e196a96d6526b855`, 19,801,272 bytes. APK ARM64 JNI SHA-256 is `f2ad3625ae3e691369baaf3bede441f9b56500e5a2655b33baa0ca2866fa3a3d`, identical to the maintained AAR member. ZIP member data offset is 2,048,000 (16 KB aligned); native LOAD/RELRO static alignment passes. Exact command/environment/source/input hashes and build log are `build3/build-result.json`, `preflight.json`, `gradle.log`.
- The fixture uses only synthetic fixed keys and no account, network or broadcast API. `taggedP2pkh` invokes the **production adapter** through the maintained JNI and checks the tag's exact encoded transaction and independently computed txid; `unsupportedP2wsh` sends the original app-shaped synthetic input and requires the explicit `Error_not_supported` message. These are pending actual device results.
- `python3 -m unittest tools/android_native_smoke/test_walletcore_api_builder.py -v` and the `python3 -O` variant: **4/4 PASS each**. They reject altered adapter, fixture source and candidate AAR before creating output, and assert no `INTERNET` permission. The final source-pinned build3 (not earlier diagnostic builds) is the APK for the upcoming reviewed device run.

## Remaining stage

Independent source/build review, then exact APK on dedicated emulator-5560 strict offline 16 KB and emulator-5562 offline SDK 26/4 KB. Each requires separate SDK/page/offline checks, installed APK/native/PID/maps and exact golden/error results. Device evidence will be recorded separately; API 26 is not a strict 16 KB run. Full app compilation and production transaction signing remain outside this bounded checkpoint.

## Separate device gate source checkpoint

After the source/build commit `1bd34e8e6849aebc925310475acdf448ade41e8f` was independently reviewed and published, the separate `run_walletcore_api_fixture.py` / `verify_walletcore_api_fixture.py` gate was added for another review before any device run. It pins the committed build epoch SHA-256 `ccc3aaf38b5e82c762fd861c5e3f8781ea2ed5b72571a4843a43e6582dcd1a39`, build3 APK/native bytes, reviewed Git HEAD source, adb/aapt/zipalign/apksigner bytes, exact serials, installed APK and classloader path, in-process APK hash, fresh nonce/PID and executable APK-backed native maps. The API 26 policy separately requires SDK 26, ARM64 and `/proc/1/smaps` 4 KB pages; it does not use the strict 16 KB linker gate. Strict 5560 separately requires 16 KB pages plus `fatal` linker mode and disabled package compatibility. Both require airplane mode, Wi-Fi off, no IP route and no active default network before and after. The standalone APK contains no `INTERNET` permission.

No-device gate checks: `python3 -m unittest tools/android_native_smoke/test_walletcore_api_runtime_gate.py -v` and the `python3 -O` variant each passed **5/5**. Controls cover exact APK/epoch and both page-specific map calculations, altered APK, cross-policy page/strict state, stale nonce/PID records, and a synthetic receipt whose correct golden/error/map passes before altered map or missing unsupported error fails. This synthetic receipt test is a verifier regression, **not device evidence**. The runner remains held pending its independent source review.
