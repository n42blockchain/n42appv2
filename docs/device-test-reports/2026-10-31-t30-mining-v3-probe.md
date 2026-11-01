# T30 — Android mining v3 device report

Date: 2026-10-31, America/Toronto.

**Execution complete. Functional matrix: 9 PASS / 1 FAIL / 0 BLOCKED. Acceptance remains open:** the prescribed `mainnet` negative case succeeds instead of producing a receipt-root mismatch. A separate SDK finding exposes the public v1 test private-key input in logcat. Neither SDK finding was changed in the Android client. V1 PASS below means native compatibility; successful mining with an authorized account was not exercised.

## Device and exact build provenance

- Xiaomi `25098RA98C`, Android 16 / API 36, security patch 2026-07-01; physical ABI `arm64-v8a`.
- Wi-Fi `N42`, phone IP `192.168.0.26/24`; node proxy `http://192.168.0.217:21100`.
- Flutter 3.47.5 / Dart 3.13.4 / Java 21. Production app entrypoint: `lib/main.dart`.
- Latest task baseline at test time: feature branch `ad2620889`. It was merged into the isolated `t30/mining-v3-fixes` branch in `e85201655`, preserving the other developer's commits. The feature branch was never pushed or modified by this work.
- Fixed main-app APK: source **`bea818f0e4bd58acadafbe3aeddb2a23be49d3dd`**, version **`2.5.3+73058`**, isolated package `ai.n42.www.t30`.
- Native bridge/fresh-registration harness: source **`4264ec77c5dbfba4981499cd2af4a6fbf0d0508f`**, version **`2.5.3+73059`**, package `ai.n42.www.t30native`, entrypoint `integration_test/t30_native_regression_app.dart`. It uses a public SDK test vector for v1 and the unmodified production `MobileVerifyDebugPage` for case 7. Its production probe/page source hashes and AAR hash match the fixed main app.
- Both local application-ID changes and matching ignored Firebase client package names were build-only configuration. The tracked Gradle file was restored. Our recorded ADB operations did not uninstall, overwrite, clear, or use `ai.n42.www`. The final original-package state changed through a launcher-initiated removal; see the postcondition correction below.
- Main-app device identity: public-key prefix `8658fb164323731d`, committed device **8**. Auxiliary package identity: prefix `9168f76fa0fdfca0`, device **9**, deliberately separate so case 7 could enter an uncommitted-registration wait without deleting the identity tested in cases 1–3.

Artifact records: [main APK](t30-2026-10-31/artifact-fix.json), [harness APK](t30-2026-10-31/artifact-harness.json), [device](t30-2026-10-31/device.json). Earlier build attempts remain in `artifact.json` / `artifact-latest.json`; their results are not substituted for the fixed-APK matrix below.

## Network and installation

Mac `/mobileverify/latest` returned HTTP 200 with advancing block numbers and `packet: true`; phone `/mobileverify/health` returned valid JSON. No replacement proxy, USB forwarding of the node, node change, or server configuration change was used.

The first installation was rejected with `INSTALL_FAILED_USER_RESTRICTED`. After the user enabled USB installation, the normal Xiaomi **Continue installation** prompt was accepted. All test APKs subsequently installed normally. No device security policy was bypassed. The isolated QA app was reinstalled for the fixed fresh-install case; no ADB uninstall in this task targeted the original package; see the final-state correction below.

Evidence: [network.json](t30-2026-10-31/network.json), [fixed install](t30-2026-10-31/install-fix.log), [harness install](t30-2026-10-31/install-harness.log). Original failed-install output remains in [install.log](t30-2026-10-31/install.log).

## Ten-case matrix

| # | Scenario | Result | Actual result and limits |
|---|---|---|---|
| 1 | Fresh install: key, registration, verification, certificate | PASS | Created a new key; registration first `committed false`, then device 8. Block 14380114, 15 txs, SDK `elapsedMs=29`, matching-root certificate with 1 signer. Observed total about 44 s. |
| 2 | Repeat in the same app process | PASS | No key creation; same public-key prefix and device 8. Block 14380135, 27 txs, 10 ms; 1 signer. |
| 3 | Kill process, reopen, repeat | PASS | Used `am force-stop`, then a cold relaunch, with no data clear. PID 22336 → 23455. Same prefix/device 8, no new key; block 14380226, 13 txs, 8 ms; 1 signer. This tests a full process restart rather than only an activity recreation. |
| 4 | Five consecutive verifications | PASS | 5/5 matching-root certificates, each with 1 signer. Per-block values and full logs below. |
| 5 | Chain `mainnet` should fail, then restore correct chain | **FAIL** | The requested negative input instead returned PASS for block 14380408, 14 txs, 14 ms, 1 signer. An earlier baseline sample also passed with 21 txs. Correct-chain recovery passed on block 14380425. SDK defect versus invalid negative-test premise remains for the SDK/task owner to resolve. |
| 6 | Wrong port `:21101` | PASS | Expected FAIL in about 3 s: `connect: connection refused`; app stayed alive and Verify button was enabled again. URL was restored to `:21100`; subsequent positive runs passed. |
| 7 | Airplane mode during uncommitted registration; recover | PASS | Auxiliary package ran the exact production probe source. After `registered: index 0, committed false`, enabled airplane mode and disabled Wi-Fi so Android could not retain a working Wi-Fi route. Expected `network is unreachable`, no crash, Verify button enabled. Restored airplane mode 0 and Wi-Fi N42; same key then committed as device 9 and passed block 14380688, 9 txs, 42 ms, 1 signer. |
| 8 | Back during execution, reenter | PASS | Exited immediately after starting, reopened the probe, and verified again. Block 14380515, 2 txs, 7 ms, 1 signer. No matching after-dispose error, fatal native exception, or UnsatisfiedLinkError was found in the captured logcat. |
| 9 | V1 regression through rebuilt AAR | PASS — native compatibility | Settings V1 selection and mining tab reached the existing No data state without a crash. Physical-device native calls exercised setting/start/state/blssign/blspubk plus stop. Native JSON and expected 48-byte public key / 96-byte signature shapes passed. Start returned the expected backend authorization rejection for the deliberately unfunded/public fixture address: `-32000 unauthed address: 0x000…000`; state stayed stopped. Successful authorized v1 mining/rewards and a matched old-AAR device comparison were not verified. SDK sensitive logging found here is listed separately below. |
| 10 | ABI, APK size, cold startup | PASS — measurements | Device arm64-v8a; fixed main APK 712,276,584 bytes (679.3 MiB). APK metadata lists arm64-v8a, armeabi-v7a, x86_64, despite the android-arm64 build target flag; only the physical arm64 path was runtime-tested. Android `am start -W` reported 7184 ms for fresh cold launch and 5970 ms after force-stop. These measure activity display, not all business-data readiness. No matched pre-AAR startup control exists, so no comparative speed claim is made. |

Raw case evidence: [case 1](t30-2026-10-31/runtime/case1-fix.json), [case 2](t30-2026-10-31/runtime/case2-fix.json), [case 3](t30-2026-10-31/runtime/case3-fix.json), [restart record](t30-2026-10-31/runtime/case3-restart.json), [case 5](t30-2026-10-31/runtime/case5-wrong-chain.json), [case 6](t30-2026-10-31/runtime/case6-wrong-port.json), [case 7 interruption](t30-2026-10-31/runtime/case7-flight.json), [case 7 recovery](t30-2026-10-31/runtime/case7-recovery.json), [Wi-Fi recovery](t30-2026-10-31/runtime/case7-network-restored.json), [case 8](t30-2026-10-31/runtime/case8-fix.json), [v1 native responses](t30-2026-10-31/runtime/case9-native.json), [v1 logcat](t30-2026-10-31/runtime/case9-native.log), [cold start](t30-2026-10-31/runtime/cold-start-fix.txt). Matching PNG screenshots and before/result UI XML are adjacent to the case JSON files.

## Fixed client defect: registration polling exhausted the node quota

On the unmodified updated baseline, the fresh probe created a key and received uncommitted registration, then failed with:

```text
PlatformException(MobileVerify, mobileverify client: server 429: registration rate limit, null, null)
```

The probe used its 2 s polling interval for repeated POST registrations. The node source limits registrations to 10 per minute per IP, counting even repeat registrations. The probe could exhaust this quota before an epoch committed the key. The client fix in **`bea818f0e`** adds a separate default **10 s registration interval**, keeping head/certificate reads at 2 s. No server quota, Go implementation, or AAR was changed.

A regression simulating a full 60 s epoch and the 10/minute limit failed on the old implementation with `Bad state: server 429: registration rate limit`; it passes with the fix. The fixed fresh-install device case above then passed without 429. Evidence: [original failure](t30-2026-10-31/runtime/baseline-case1-429.json), [original screenshot](t30-2026-10-31/runtime/baseline-case1-429.png), [13 passing v3 tests](t30-2026-10-31/unit-tests-fix.log).

## SDK/task-owner findings — not changed in this branch

### Prescribed chain-negative result not reproduced

Fixed-APK input was exactly `mainnet`. Block 14380408 / `0x9fab276417b9cffbf47672640e773e47ada4510df8ef177536de50d322ddd5c8` verified successfully, root `0x26a4060665e92e481889466d4f45561612aef608dc0d12cc2c8b4db49ef3b572`, and produced a matching-root certificate with 1 signer. The earlier updated-baseline sample was block 14379999 / `0x6d1f66900e5e92f3e188b569e488ff0940d6062d2423656e714c58aa46dc28c5`, 21 txs, 7 ms, also PASS.

These observations do not establish that receipts were checked incorrectly: `mainnet` is an N42 chain configuration in the inspected source. The SDK/task owner must supply or approve a deterministic incompatible chain/block fixture before closing the prescribed negative case. No client-side forced FAIL was added.

Supplemental diagnostic: the actual Ethereum selector `eth-mainnet` was also tried in the auxiliary package. Block 14380868 / `0x9ab56badcafb67955ddfb684666a5238baa8334d218de3eaf9968b353af54108` failed safely with `verify_v2: block start ... stream_replay: missing bytecode for code hash f57acd40259872606d76197ef052f3d35588dadf919ee1f0e3cb9b62d3f4b02c`; the button recovered. This confirms rejection of that incompatible configuration, but it is not the prescribed `mainnet` input or receipt-root mismatch and does not close case 5. [Raw supplemental result](t30-2026-10-31/runtime/supplemental-ethereum-chain.json).

### V1 private-key input emitted to logcat

During the public-fixture native regression, the SDK emitted this real GoLog line:

```text
10-31 21:42:40.617  1728 20176 I GoLog : emit: setting map[account:0x0000000000000000000000000000000000000000 app_base_path:/data/user/0/ai.n42.www.t30native/app_flutter log_level: priv_key:<PUBLIC_TEST_PRIVATE_KEY_REDACTED> server_uri:wss://ws.n42.world]
```

Only the public fixture from the Go SDK's `TestEmitBlsSignDispatch` was used. No user wallet key was loaded by the harness. The sensitive value is masked in this evidence. The inspected SDK `cmd/evmsdk/common.go` logs `eq.Val` before dispatching the setting call; omission/redaction of private input belongs in the Go SDK, which is outside T30's client-fix permission. Whether a release build also emits this line was not tested, and this report does not claim the new AAR introduced the behavior.

Requires SDK-owner fix, a rebuilt AAR, and repetition of the native regression with zero private-key-input matches in a fresh, process-scoped log capture. Evidence: [redacted raw GoLog](t30-2026-10-31/runtime/sdk-sensitive-logging-redacted.log).

## Five-run values

| Run | Block | Txs | SDK elapsedMs | Certificate signers |
|---|---:|---:|---:|---:|
| 1 | 14380252 | 26 | 11 | 1 |
| 2 | 14380261 | 8 | 8 | 1 |
| 3 | 14380269 | 10 | 12 | 1 |
| 4 | 14380279 | 16 | 12 | 1 |
| 5 | 14380288 | 13 | 11 | 1 |

SDK elapsedMs values are reported as received; UI/certificate waiting is excluded. These small samples are not a sustained high-load benchmark. Observed wall time uses UI polling and is approximate.

## Full production-probe UI logs: case 1

```text
created a device key
session open at http://192.168.0.217:21100 (mainnet_qmdb_staggered), pubkey 8658fb164323731d…
registered: index 0, committed false
committed as device 8
head 14380114 0x757b51ce132be563e54e160b3b5acd2a70a6d5bb76c31ef79d26942f4743518b
verified block 14380114: 15 txs, root 0x10d3902d7b50b63d6712d9018f4fea439966713f90b3c5fff4a263974ed7e97a, 29 ms, accepted as device 8
certificate: 1 signers over our root
PASS: 1 signers
```

## Full production-probe UI logs: case 4

Run 1:

```text
session open at http://192.168.0.217:21100 (mainnet_qmdb_staggered), pubkey 8658fb164323731d…
registered: index 8, committed true
committed as device 8
head 14380252 0x2932cbdc30912a8679019cbbf5f0e3cc6b699071d4e2ce9a1b2678fca63a5aee
verified block 14380252: 26 txs, root 0xaf2dcd92e04c5caff45911b59ea09670cc5ee68a4c45195ee239ea57bff72ff0, 11 ms, accepted as device 8
certificate: 1 signers over our root
PASS: 1 signers
```

Run 2:

```text
session open at http://192.168.0.217:21100 (mainnet_qmdb_staggered), pubkey 8658fb164323731d…
registered: index 8, committed true
committed as device 8
head 14380261 0xc3abdaebc8e72525ff291ea15bd5b271fb0110c542c679434d00ee2350cbd208
verified block 14380261: 8 txs, root 0xbf9b43ef71405f9624a9108391e592b9370b3c9ab99d6f5ba51d696f098f9035, 8 ms, accepted as device 8
certificate: 1 signers over our root
PASS: 1 signers
```

Run 3:

```text
session open at http://192.168.0.217:21100 (mainnet_qmdb_staggered), pubkey 8658fb164323731d…
registered: index 8, committed true
committed as device 8
head 14380269 0x0be4d120f329147ac0ec01c920944908a463a62edf7bbf0fdcff98ee5ef6d799
verified block 14380269: 10 txs, root 0x9986ba5e5089cb44e2da70e1144f31c83370eda2233e84011cc67fff26851ce0, 12 ms, accepted as device 8
certificate: 1 signers over our root
PASS: 1 signers
```

Run 4:

```text
session open at http://192.168.0.217:21100 (mainnet_qmdb_staggered), pubkey 8658fb164323731d…
registered: index 8, committed true
committed as device 8
head 14380279 0x976f539e7952ae08ddc1ce2bbf45e37960e119d84225c8b737d5bf2705ba9c64
verified block 14380279: 16 txs, root 0x5a924e2433e9aef5adbf03f7230ed67d576a3c216cf4b8a21b0e4843f739e109, 12 ms, accepted as device 8
certificate: 1 signers over our root
PASS: 1 signers
```

Run 5:

```text
session open at http://192.168.0.217:21100 (mainnet_qmdb_staggered), pubkey 8658fb164323731d…
registered: index 8, committed true
committed as device 8
head 14380288 0x4cf0d8341e4712c42980af531213bb1e89150102a6d487db36beeb59177ce795
verified block 14380288: 13 txs, root 0xb5a6c39606fe76e0b90e10d80a0118fbe4c89bbc93e6af20893f9b12f1935b5d, 11 ms, accepted as device 8
certificate: 1 signers over our root
PASS: 1 signers
```

## Validation, reproduction, and boundaries

- `make setup`: installed the normal build-number hook. Every commit in this work used the hook; none used `--no-verify`, and the earlier taskbook history was not rewritten.
- `flutter pub get`: passed. No incidental dependency/lockfile changes were retained.
- Fixed main build: `flutter build apk --debug --no-pub --target-platform android-arm64` — passed. Build-only isolated package/Firebase configuration as described above.
- `flutter test --no-pub test/features/mining_v3/` — **13 PASS**, including the rate-limit regression.
- Plugin `flutter test test/mobileverify_test.dart` — **6 PASS** on the updated feature baseline; no plugin source changed in the client fix.
- `flutter analyze --no-pub --no-fatal-infos lib/features/mining_v3 plugins/flutter_mining/lib` — exit 0, no errors or warnings, 4 existing `prefer_initializing_formals` info diagnostics.
- Device harness analysis — no issues. Opt-in build command: `flutter build apk --debug --no-pub --target-platform android-arm64 -t integration_test/t30_native_regression_app.dart --dart-define=T30_NATIVE_SMOKE=true`, using a separate local application ID/Firebase package. Its v1 result explicitly covers native compatibility, not funded/authorized mining.
- Final AAR: 60,758,473 bytes, SHA-256 `06ad099064330caf72abc4325ef613fecaea11f6178bd5450d2d9a44dc12833d`. The client fix and harness did not change the AAR.
- Caught probe PlatformExceptions are rendered by the production page in its UI; it does not mirror them to logcat. Their full text is retained in JSON/XML/screenshots. The captured logcat had no matching after-dispose/fatal/UnsatisfiedLinkError entries; [scan record](t30-2026-10-31/runtime/exceptions-scan.json); the [Android ANR event scan](t30-2026-10-31/runtime/anr-events-scan.json) also found no matching test-package events. The SDK sensitive-log finding above has a real timestamped logcat entry.
- Optional continuous-miner/10-minute background/10-minute lock-screen checks were not run. No phase-3 background or lock-screen acceptance is claimed.

Evidence: [fixed analysis](t30-2026-10-31/analysis-fix.log), [updated plugin tests](t30-2026-10-31/channel-tests-latest.log), [main build](t30-2026-10-31/build-fix-summary.log), [harness build](t30-2026-10-31/build-harness-summary.log), [harness analysis](t30-2026-10-31/analysis-harness.log).

Commits: `e85201655` preserves and merges the updated feature baseline; `bea818f0e` fixes registration polling and adds its regression; `4264ec77c` adds the opt-in native device harness. Earlier `a93f66b32` / `29dc77642` recorded the initial installation blocker and logs. Report-only hook version bumps after these builds are not represented as new device-tested APKs.

Final device state: airplane mode 0, Wi-Fi N42 connected; auxiliary `ai.n42.www.t30native` removed after evidence capture. Fixed `ai.n42.www.t30` remains installed and stopped, preserving its device-8 key. The original package was present in initial preflight (`2.5.1` / `2026072777`), but is absent from the final installed-package query. Android PackageManager records its removal at device log time `10-31 21:04:15.038`, initiated by `com.miui.home` (caller UID/PID `10135/11510`). This establishes the launcher route, not the identity of the operator. Our recorded uninstall targets were only the QA packages. The earlier report claim that the original package remained installed was incorrect and is corrected here; no restoration or data-clear action was attempted on that package. [Original-package events](t30-2026-10-31/runtime/original-package-event-scan.json). [Postcondition record](t30-2026-10-31/runtime/postconditions.json).
