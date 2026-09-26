# Full dependency upgrade — final acceptance, 2026-09-25

## Scope and outcome

The final acceptance run starts at `26840b378` on `codex/dependency-upgrade-20260925`, after Tasks 1–9 and their independent reviews. Baseline comparison is `dee63931f`. The final-check changes are a single Dart formatting correction, removal of an unused Chrome development plugin and its vulnerable transitive graph, a narrow repair of four missing wallet localization labels, and durable evidence/documentation. The Git hook's build-number increment is expected. Nothing was pushed or published.

**This is not an all-green repository.** Root Flutter tests and analysis, local package checks, Go, Rust, and Chrome production checks pass. The exact Chat suite has one upstream test failure; the complete npm audit was repaired by removing an unused plugin; the localization audit initially reproduced a pre-upgrade failure that was authorized for a narrow repair. Coverage expansion is explicitly deferred. Native build results are recorded below.

Every final command has a numbered `.json` record with exact arguments, directory, environment overrides, duration and exit status, plus `.log.gz` output and `.exit`, under [acceptance evidence](dependency-upgrade-final-2026-09-25/acceptance/). Earlier failed attempts remain in their original ecosystem folders. Exit 0 from the orchestration helper is not a suite result: use each command's own exit marker.

## Pinned toolchains

| Tool | Final acceptance version | Evidence |
| --- | --- | --- |
| Flutter / Dart | 3.44.8 / 3.12.2 | `010` |
| Go | 1.26.5, `GOTOOLCHAIN=local` | `100` |
| Rust / Cargo | 1.97.1 / 1.97.1 | `200` |
| Node / npm | 20.20.0 / 10.8.2, explicit nvm PATH | `300` |
| Java | Homebrew OpenJDK 21.0.10 with working `jlink` | `400` |
| Xcode / CocoaPods | 27.0 (27A266a) / 1.17.0 | `010` |

The host's default Node 25 and Java 25 were not used for acceptance. The incomplete GoLand JBR 21 is not the Android build JDK. No language/SDK toolchain pin was raised. Android Gradle/AGP dependencies were upgraded as planned; Android compile/target SDK remains 36, min SDK 26, iOS floor 16.0 and macOS floor 10.15.

## Verification results

| Check | Result | Evidence IDs |
| --- | --- | --- |
| Root `flutter pub get`; final `--enforce-lockfile` | PASS | `011`, `049` |
| `flutter analyze --no-fatal-infos` | PASS: 0 errors, 0 warnings, 35 infos | `012` |
| `dart format --output=none --set-exit-if-changed lib/ test/` | PASS: 1,422 files, zero changes after the one-file correction | `001`, `013` |
| `flutter test --coverage --concurrency=4` with fd limit 4096 | PASS: 4,803 | `014` |
| Unchanged 70% coverage gate | **DEFERRED gap; command FAILED (1): 65,368 / 132,937 lines = 49.172164%** | `015`, LCOV `016` |
| Mining, mining example, Audio, WebView, WebView example, JMT resolution with enforced locks and package analysis | PASS, every command exit 0 | `020`–`036` |
| Mining / example / JMT / WebView tests | PASS: 3 / 1 / 13 / 154 | `040`–`043` |
| Web3Auth wallet migration tests | PASS: 10 | `044` |
| Exact Chat export, dependency resolution and analysis | PASS: fixed SHA verified; 0 errors, 279 infos | `045`–`047` |
| Exact Chat standalone tests | **FAILED (1): 6,736 passed, 3 skipped, 1 failed** | `048` |
| Four Go modules: `go test -count=1 ./...`, `go vet ./...`, `go mod tidy`, clean mod/sum diff | PASS, all 16 commands | `110`–`143` |
| Rust fmt, 6 tests, locked host and Android arm64 checks, clippy with `-D warnings` | PASS | `201`–`206` |
| Node 20 `npm ci`, tests, lint, type check, production build | PASS after unused-plugin removal; 5 crypto tests, 488 build modules | `325`–`329` |
| `npm audit --omit=dev --json` | PASS: zero production vulnerabilities | `330` |
| Complete `npm audit --json` | PASS: zero vulnerabilities, including development dependencies | `331` |
| Wallet localization audit after authorized baseline repair | PASS: zero missing/extra/empty/invalid-placeholder entries | `518` |
| Complete localization CI audit | **FAILED (1): 667 unaccepted English-identical Chat entries across 23 locales**; exact baseline comparison matches | `513`, `519`–`521` |
| Post-generation format / full analysis / focused localization and wallet tests | PASS: 0 format changes; 0 errors, 0 warnings, 35 infos; 56 tests | `515`–`517` |
| Python script tests | PASS: 39 | `507` |
| CI YAML, unchanged jobs and independent coverage condition | PASS | `504` |
| Full baseline diff whitespace check | PASS | `523` |

Audio and the WebView example contain no standalone Dart unit-test directory; their package analyses pass. Native runtime behavior is not established by these host tests.

The root baseline's 5,831 tests included 13 aggregators importing the Chat cache mirror. Those were removed from the root suite, which now contains app-owned tests; Chat runs independently from its actual Git source. The final root count of 4,803 and its 49.17% coverage **do not establish a coverage improvement** over the differently scoped baseline. The user deferred raising the captured 49.13% baseline; no threshold was lowered and coverage remains visible. The CI coverage step uses `always() && steps.root_tests.outcome == 'success'`, so the known Chat failure does not silently skip the 70% gate.

## Native builds and linking

The verified APK and unsigned iOS Release artifacts were built from version `2.4.8+2026072838`. Commit `5f4aa5c62` automatically advanced the manifest to `2.4.8+2026072839`; the documentation clarification commit advances it again to `2.4.8+2026072840`. Those commit-hook changes only update the build number and were not followed by another native build. The validated artifacts therefore remain build `2026072838`, not the later manifest build numbers.

| Command | Final result | Evidence |
| --- | --- | --- |
| `flutter build apk --debug` with complete Homebrew JDK 21 | PASS after localization generation, 62.67 seconds | `430`; earlier final-graph pass `401` |
| `./gradlew :flutter_mining:assembleDebug :flutter_mining:testDebugUnitTest :app:testDebugUnitTest --console=plain` | PASS; hosted mining test target succeeds, app target has no native tests | `402` |
| iOS `pod install --deployment --no-repo-update` | PASS: 69 dependencies, 138 pods | `410` |
| `flutter build ios --no-codesign --release` | PASS after localization generation, 120.87 seconds; Runner.app 357.6 MB | `431`; earlier final-graph pass `411` |
| `xcodebuild -resolvePackageDependencies -workspace ios/Runner.xcworkspace -scheme Runner` | PASS; no remaining Swift package resolutions | `412` |
| macOS `pod install --deployment --no-repo-update` | PASS: 44 dependencies, 68 pods | `420` |
| `flutter build macos --release` | **BLOCKED; actual build FAILED (1)** | `421` |
| Direct macOS `xcodebuild ... CODE_SIGNING_ALLOWED=NO build` | **BLOCKED; actual build FAILED (65)** | `422` |
| Final MLS package hashes, exports and SQLCipher link checks | PASS | `432`–`434` |

The final APK is 863,878,173 bytes, SHA-256 `a867745810b91590150c4ca908c1341aa96cd104993b6f7d60d3b24608d4b45b`. Task 8's four tracked Android inputs match Gradle's merged libraries byte-for-byte and each exports 11 JNI and 13 C symbols. The default Flutter APK packages arm64-v8a, armeabi-v7a and x86_64; each library matches Gradle's corresponding stripped output. The fourth x86 library remains rebuilt/tracked/merged but is not packaged by this Flutter command. Comparing APK hashes directly to unstripped inputs would be incorrect.

Xcode's copied device static library matches the rebuilt Task 8 XCFramework archive exactly (SHA-256 `4d9d2f3f9e310f745bc82e61ea0d2bbf28b475c3b369804df5d0fb12649f9a3f`). The final Runner binary retains all 12 operational MLS C entry points; the unused version helper is absent from its export table. It also defines `_sqlite3_key` / `_sqlite3_key_v2` and contains `_sqlcipher_exportFunc` / `_sqlcipher_export_init`. [Artifact hashes](dependency-upgrade-final-2026-09-25/acceptance/432-final-native-artifacts.json) and [symbol evidence](dependency-upgrade-final-2026-09-25/acceptance/433-ios-link-symbols.txt) validate the newly rebuilt MLS inputs, not merely Task 6's older app. These are link/package checks, not a device encryption or interoperability test.

macOS Xcode 27 reports: `The macOS deployment target 'MACOSX_DEPLOYMENT_TARGET' is set to 10.15, but the range of supported deployment target versions is 12.0 to 27.0.x.` Some pods also declare 10.12. The mandated deployment floor was not raised. Task 6's direct-project attempt additionally lacked ephemeral Flutter file lists; after this final Flutter build preparation, the direct retry reports the deployment-target failure without that earlier file-list error. Neither command is marked passed.

CocoaPods warnings remain visible: conflicting `EXCLUDED_ARCHS[sdk=iphonesimulator*]` values across ML Kit/MediaPipe/WeChat targets; custom base configurations not automatically replaced (iOS profile, macOS debug/release/profile); Runner overrides of `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES`; Firebase CocoaPods deprecation. Flutter also warns that listed plugins lack Swift Package Manager support and this will become an error in a future Flutter version. Gradle reports deprecated features incompatible with Gradle 9, and upstream Java plugins emit obsolete API/source-target warnings. These warnings did not prevent the verified Android/iOS builds; no unsupported macOS success or warning-free native claim is made.

## Exact Chat limitations

The only production Chat source is Git SHA `3cc19c12a7c9bbf2031270acca8e3922730b55a5`. The final check reads its package-config path, verifies declared/locked/checkout revisions and uses `git archive` into a disposable directory. No mirror, cache, external repository or upstream test was edited. The standalone suite uses the exported upstream package's own dependency graph; it is not a test of the excluded local mirror.

The failing case is `test/unit/datasources/matrix_contact_datasource_test.dart`: **“expired timed status clears status message without forcing online presence”**. `_MockClient.accountData` returns `Null`, which is not `Map<String, BasicEvent>`. The stack passes through `ContactPrivacyService.all` → `forUser` → `hides` → `MatrixContactDataSource.getUserStatusMessage` → `getCurrentUserStatusMessage`. This is a real upstream suite failure at the mandated source, also observed during Task 4; it is not relabeled as passing or hidden with `continue-on-error`.

The same source lacks `IWalletBridge.requestTransferExact` and the chain/network/asset identity fields on `TokenInfo`. Task 3 moved compatible helpers and extra token identity into app-owned code, restoring host analysis and wallet tests. The exact-asset QR path through the current Chat interface remains **BLOCKED by upstream API availability**; no alternate public revision was found in the recorded read-only audit.

The previous ledger attribution of `AuthorizationStatus.deniedPermanently` to platform interface 4.9.2 was incorrect. Official archive SHA-256 checks show the member first in **4.10.0**. Root `firebase_messaging 16.5.0` plus explicit `firebase_messaging_platform_interface >=4.9.3 <4.10.0` resolves the compile incompatibility without changing Chat; messaging 16.6+ requires 4.10+. See the [archive audit](dependency-upgrade-final-2026-09-25/flutter/messaging-archive-audit.json) and [full Flutter report](dependency-upgrade-final-2026-09-25/flutter/REPORT.md).

## Manifests, versions and retained compatibility bounds

The [complete manifest/lock inventory](dependency-upgrade-final-2026-09-25/acceptance/manifest-lock-inventory.md) lists 48 files, their baseline-change status and linked SHA-256 snapshot. It includes root and all six active local package manifests/locks, Android and mining Gradle files, both Apple pod graphs, four Go modules, Cargo, and Chrome manifests/lock. The cached Chat mirror is excluded. [Every Flutter direct/dev dependency and retained cap](dependency-upgrade-final-2026-09-25/flutter/direct-inventory.md) has a package/API-specific reason.

| Ecosystem | Upgraded graph / migration | Important retained bounds |
| --- | --- | --- |
| Flutter | Root and active local package locks regenerated; Riverpod 3.4.3, Firebase core 4.15.0, Web3Auth 7.0.0, Audio 6.5.0, WebView WK 3.26.1 and other stable compatible releases | Chat SHA fixed; messaging 16.5.0 / interface 4.9.3; BLAKE3 exactly 1.0.0; existing source overrides retained except Chat |
| Secure wallet storage | 10.3.4 preserves named preferences and legacy encrypted-storage migrations | 11.2.0 removes `AndroidOptions.sharedPreferencesName` / legacy RSA-AES migration APIs and requires compileSdk 37; app remains 36 |
| Patched native Flutter plugins | Audio retains iOS 27 registration guard; WebView upgraded through existing Pigeon 29.0.4 generation workflow with the `NSNull` authentication-challenge safeguard | Generated Swift was regenerated, not manually patched; [patch notes](../../packages/webview_flutter_wkwebview/CONTRIBUTING.md) describe the null crash condition and generation |
| Android | Gradle 8.14.4, AGP 8.13.2, Kotlin 2.4.20; TrustWalletCore 4.8.4; WebRTC 150.7871.01; mining bridge preserved | Gradle 9 conflicts with `video_thumbnail 0.5.6` `jcenter()`; OkHttp 5.4.0 because 5.5 requires compileSdk 37 |
| Apple | Firebase 12.19.0, TrustWalletCore 4.8.4, Web3Auth 12.0.1, SQLCipher 4.10.0; removed stale QR-scanner links and unused Firebase SPM declarations | GoogleSignIn 9.2.0: plugin `~>9.0`, v10 requires macOS 12; unchanged 10.15 floor; inherited MediaPipe/ML Kit pins |
| Go | LiveKit protocol 1.52.1, Ethereum 1.17.6, Gin 1.12.0, pq 1.12.3, sqlx 1.4.0; loyalty/swap minimum and Docker builder raised to Go 1.26 | Runtime stays 1.26.5; social-auth has no external modules; broad upstream graph updates outside actually imported modules are documented |
| Rust | OpenMLS 0.9, provider/credential/traits 0.6, tls_codec 0.5, JNI 0.22.4; 11 JNI functions migrated, tracked mobile libraries rebuilt | Exported JNI/C interfaces and ownership unchanged; provider storage remains memory-only; older-device interoperability not exercised |
| Chrome | React 19.3, Noble hashes 2.4 / secp256k1 3.2, Scure 2.4, viem 2.56.9, Vite 8.3.1, TS 6.0.3, Vitest 4.1.11; deterministic address/signature vectors | TS 7 exceeds typescript-eslint `<6.1`; Vitest 5 requires Node 22.12+; Node 20 retained |

Task 10 initially applied compatible transitive security updates through ordinary `npm audit fix`, reducing the full audit from 11 to 9 affected development nodes. Final independent review identified `vite-plugin-web-extension` as unused: the Vite config already invokes only `react()` and its own `copyExtensionAssets()`. `npm uninstall --save-dev vite-plugin-web-extension` generated the final lock and removed 186 packages, including the entire vulnerable Firefox-runner branch. A fresh Node 20 install, 5 tests, lint, type checks and build pass; **both production and full audits now report zero vulnerabilities**. No overrides or forced downgrade were needed. [The advisory investigation, override assessment, unused-source evidence and final resolution](dependency-upgrade-final-2026-09-25/acceptance/chrome-development-audit.md) retain all prior failed audit logs without implying they are the final state.

## Source, stability, lock and secret audit

- Root lock contains 426 dependencies (excluding the app), versus 424 at baseline. No root package version downgrade was found. Intentional npm removals are confined to the unused plugin graph documented above. [Graph/source audit](dependency-upgrade-final-2026-09-25/acceptance/501-graph-audit.json) verifies exact Git Chat, unchanged mirror, retained Audio/WebView/mining paths and exact BLAKE3 1.0.0. Only the Chat override was removed.
- Flutter and Cargo lock versions contain no prerelease versions. **The complete repository graph is not entirely stable-only:** inherited Android ML Kit segmentation `16.0.0-beta6`; iOS MLImage beta8, segmentation beta14, Xeno beta16; TensorFlowLite `0.0.1-nightly.20250619`; and npm Babel's `gensync 1.0.0-beta.2` remain. Every recorded prerelease already occurs at `dee63931f`; no new prerelease was introduced. Native upstream packages have no compatible stable replacements in the selected graph. Cargo's existing `wasi 0.11.1+wasi-snapshot-preview1` is build metadata, not a SemVer prerelease; Go pseudo-versions are upstream commit versions.
- Root/local enforced-lock installs, `npm ci`, all four tidy-with-clean-diff checks and Cargo `--locked` checks pass. Final Flutter/local/Cargo/Apple locks remain byte-unchanged from the reviewed Task 9 starting point (`522`); npm manifest/lock removal is intentional. Toolchain and deployment-floor constraints remain as listed above. Generated WebView output has its reproducible generator documented; Task 8's packaged native outputs have source/build evidence.
- A [focused added-diff secret scan](dependency-upgrade-final-2026-09-25/acceptance/503-secret-scan.json) found no private-key headers, AWS IDs, GitHub tokens or newly tracked signing/local/Firebase configuration files. This is not a universal secret-detection guarantee. Local build configuration and genuine pre-existing credentials remain ignored and were not printed or staged.

## Baseline fixes and remaining limits

Baseline analyzer errors were repaired through standalone JMT resolution, excluding the nonproduction Chat mirror, and app-owned wallet API compatibility. The notification compilation issue discovered during upgrades was fixed through the verified Firebase cap. WebView generation, Web3Auth API migration, mining Gradle/Kotlin configuration, stale iOS framework references and TypeScript 6 configuration were resolved in their implementation tasks and independently reviewed.

The localization audit initially found four missing wallet keys across 24 locales. The authorized narrow baseline fix adds exactly those 96 entries: total value reuses each existing `g_portfolio_total`; price/recipient/sender labels are translated without AA-specific wording, and the pseudo-locale uses the existing transform. `intl_utils` regenerated the 24 Dart message files. Wallet-only audit, full format/analysis, 39 Python tests and 56 focused localization/wallet tests pass. [All 96 labels and reuse decisions](dependency-upgrade-final-2026-09-25/acceptance/wallet-localization-repair.md) are available for review.

**The full localization gate still FAILS**, now reaching its previously short-circuited Chat check: 667 unaccepted English-identical entries across 23 locales. Final audit reads `/Users/jieliu/.pub-cache/git/n42_chat-3cc19c12a7c9bbf2031270acca8e3922730b55a5/lib/l10n/app_en.arb`, resolved through the root package config. A separate `dee63931f` archive reads that commit's tracked mirror because it has no package config; `--mode chat` also fails. [Comparison evidence](dependency-upgrade-final-2026-09-25/acceptance/521-chat-localization-baseline-comparison.json) asserts exact equality of all 667 key/value entries, not merely counts. No Chat source, mirror, localization allowlist or baseline was changed. This remains an existing failed CI gate, not an approved deferral or a passing result.

Rust JNI `with_env` catches unwinding panics that cross its closure. It **does not catch a process abort inside an `extern "C"` call**. Null/UTF-8 checks and C buffer ownership are tested; a general native-abort containment claim would be incorrect. The durable Rust report corrects the earlier wording. Device OAuth, biometric/auth flows, wallet hardware signing, physical-device MLS interoperability and runtime SQLCipher migration were not executed; host tests and link checks have that practical limit.

## Durable task reports

- [Baseline and original failures](dependency-upgrade-baseline-2026-09-25/README.md), [Task 1 report](dependency-upgrade-baseline-2026-09-25/task-1-report.md)
- [Chat source correction](dependency-upgrade-final-2026-09-25/source-and-analyzer/task-2-report.md), [analyzer/wallet/JMT migration](dependency-upgrade-final-2026-09-25/source-and-analyzer/task-3-report.md)
- [Flutter graph and API details](dependency-upgrade-final-2026-09-25/flutter/REPORT.md)
- [Android](dependency-upgrade-final-2026-09-25/android/task-5-report.md), [Apple](dependency-upgrade-final-2026-09-25/apple/task-6-report.md)
- [Go](dependency-upgrade-final-2026-09-25/go/task-7-report.md), [Rust](dependency-upgrade-final-2026-09-25/rust/task-8-report.md), [Chrome](dependency-upgrade-final-2026-09-25/chrome/task-9-report.md)

Historical task reports describe their own verification point; this final report and acceptance logs supersede their counts where subsequent changes occurred. In particular, Task 6's iOS success predates Task 8's MLS artifact rebuild, and Task 9's 11-node development audit precedes Task 10's removal of the unused parent and clean full audit.

## Final self-review

The final changes are limited to the authorized formatting/localization fixes, removal of an unused development dependency, the corrected acceptance specification, and durable reports/evidence. Generated localization files came from the normal generator; lockfiles came from package managers. Existing coverage threshold, Chat SHA, active path patches, BLAKE3 pin, toolchain versions and platform deployment floors are preserved. No CI jobs were added; no Chat source was edited; no secrets or local signing/Firebase files were staged. The final build-number-only hook change is a repository convention, not another dependency resolution change.

Acceptance is **PARTIAL with explicit FAILED/BLOCKED/DEFERRED items**: upstream Chat test and translation failures; Chat exact-asset QR API availability; macOS deployment-floor/toolchain incompatibility; and the separately approved coverage deferral. All locally actionable dependency, analysis, build and narrowly authorized baseline repairs above have been completed. No failure is converted into a pass.
