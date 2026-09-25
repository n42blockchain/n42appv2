# Full Repository Dependency Upgrade Execution Plan

## Goal

Upgrade every in-scope production dependency to a current stable release where it is compatible with the repository's pinned toolchains, complete required major migrations, repair the 24 reported Flutter analyzer baseline errors, and leave reproducible dependency locks with test evidence for every ecosystem.

## Architecture

- Capture the clean baseline before changing manifests, then make dependency changes in isolated ecosystem phases so regressions can be attributed.
- Resolve the app's `n42_chat` dependency from the declared Git SHA after removing only its tracked path override. Treat `packages/n42_chat` as a cache mirror, not as the production source or a validation target.
- Keep cryptographic and wallet behavior behind existing interfaces; add deterministic vectors where the Chrome extension currently lacks automated tests.
- For an upgrade that cannot be safely completed inside the pinned toolchain or available credentials, retain the current stable version and report the precise blocker rather than substituting an unverified package.

## Tech Stack

Flutter/Dart, CocoaPods, Swift Package Manager, Gradle/AGP/Kotlin, Go modules, Cargo, npm/TypeScript/Vitest, repository CI scripts.

## Spec

- `docs/superpowers/specs/2026-09-25-full-dependency-upgrade-design.md`

## Global Constraints

- Update production dependency graphs in the root Flutter app, active local/path packages, Android, iOS/macOS, all four Go modules, Rust MLS, and the Chrome extension. Update manifests and lockfiles together.
- Use stable releases only, allow major upgrades and necessary migrations, and keep Flutter/Dart, Go, Rust, Node, and Java at the versions already pinned by the project/CI.
- Remove only the `n42_chat` path override from `pubspec_overrides.yaml`; preserve the declared Git SHA in `pubspec.yaml` and verify that `pubspec.lock` records that exact Git source. Do not edit or push the external Chat repository. Do not validate production behavior against the `packages/n42_chat` cache mirror.
- Keep and audit the active `audioplayers_darwin` and `webview_flutter_wkwebview` path overrides; test the path packages CI actually resolves. Include `plugins/flutter_mining` and `packages/n42_jmt_verify` in package-level verification.
- Preserve existing wallet cryptography, address derivation, signing, encrypted storage, authentication, Chat, and native plugin behavior. No unrelated product changes.
- Keep `blake3_dart` at its exact pinned version unless source and publisher review justifies a safe change. Repair its package resolution/API integration without silently widening its constraint.
- Do not fabricate Firebase, signing, repository, or private Maven credentials. Report builds blocked by missing local configuration as blocked.
- Capture the reported analyzer baseline before changing code. Fix every analyzer error in the fresh baseline and finish with zero repository-wide analyzer errors; do not treat baseline errors as acceptable residuals.
- Check production call sites against the resolved `n42_chat` Git source. Never use the local `packages/n42_chat` mirror as the API authority for the production dependency.
- Keep the existing 70% coverage threshold unchanged. The captured 49.13% coverage result is a known baseline gap that the user has deferred to a later task; report the final result, but do not expand this dependency-upgrade scope with broad coverage work.
- Leave any dependency pinned only with a recorded compatibility/security reason, exact affected package, and required follow-up. Do not add CI jobs unless a dependency migration makes them necessary.
- Use short English Conventional Commit subjects if commits are later requested. This execution plan does not authorize pushing or publishing.

## Review Focus

1. `n42_chat` resolves from the declared Git SHA after the override is removed; no lockfile or dependency report silently points at the local mirror.
2. Major-version migrations preserve wallet signing/derivation vectors, encrypted storage, auth, Chat, and plugin behavior.
3. The 24 baseline analyzer errors are fixed at their root causes, and no analyzer errors remain after all migrations.
4. Android/iOS dependency upgrades remain compatible with Java 21, deployment targets, TrustWallet private artifacts, SQLCipher linking, Firebase configuration, and simulator architecture constraints.
5. Every lockfile is reproducible, contains no prerelease or unintended downgrade, and matches the checked-in manifest; failed registry/audit/build checks are accurately recorded.

## Task 1 — Capture baseline and dependency inventory

### Files

- Add `docs/testing/dependency-upgrade-baseline-2026-09-25/` with toolchain versions, per-ecosystem dependency snapshots, full command logs, analyzer error inventory, and environment blockers. Do not change manifests or application code in this task.

### Steps

1. Record `git status --short`, branch/base SHA, `flutter --version`, `dart --version`, `go version`, `rustc --version`, `cargo --version`, `node --version`, `npm --version`, `java -version`, `gradle --version`, `pod --version`, and `xcodebuild -version`.
2. Capture Flutter direct/transitive status and active package source resolution:
   - `flutter pub outdated --json`
   - `flutter pub deps --json`
   - `git ls-files pubspec.yaml pubspec.lock pubspec_overrides.yaml`
   - Record the current `n42_chat` lock source and Git SHA before removing the override.
3. Capture static-analysis and test baseline without edits:
   - `flutter analyze --no-fatal-infos`
   - `flutter test --coverage --concurrency=4`
   - `python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70`
   - Save each exit status and complete output. List every fresh analyzer error by file, line, code, and root cause; compare it with the historical count of 24.
4. Capture native baseline: run `./gradlew :app:dependencies` from `android/` after the Flutter build materializes its ignored wrapper, `flutter build apk --debug`, `pod outdated` from both `ios/` and `macos/`, and `xcodebuild -resolvePackageDependencies -workspace ios/Runner.xcworkspace -scheme Runner`. Run `flutter build ios --no-codesign --release`; for macOS use `xcodebuild -project macos/Runner.xcodeproj -scheme Runner -configuration Release CODE_SIGNING_ALLOWED=NO build` after CocoaPods integration is available. Save credential, CDN, missing-podspec, or architecture blockers without fabricating local configuration.
5. In each of `backend/livekit-jwt`, `backend/loyalty`, `backend/social-auth`, and `backend/swap`, capture `go list -m -u all`, `go test ./...`, and `go vet ./...`.
6. In `rust/n42_mls`, capture `cargo tree`, `cargo fmt --check`, `cargo test --all-targets`, `cargo check --all-targets`, and `cargo clippy --all-targets -- -D warnings`.
7. In `chrome-extension`, capture `npm ci`, `npm outdated --json`, `npm audit --omit=dev`, `npm run lint`, `npm run type-check`, and `npm run build`. Note that no extension test script exists at baseline.

### Acceptance

- Baseline report distinguishes existing failures from upgrade regressions and records toolchain versions exactly.
- The report contains a direct/transitive dependency snapshot for all in-scope ecosystems and the failed CocoaPods inspection details already known from inventory.
- No dependency or source changes are made until this baseline is saved.

## Task 2 — Align the Chat dependency with its declared Git source

### Files

- `pubspec_overrides.yaml`
- `pubspec.lock`

### Steps

1. Remove only `n42_chat: path: packages/n42_chat` from `dependency_overrides`; leave the `audioplayers_darwin`, `webview_flutter_wkwebview`, and existing version overrides intact.
2. Run `flutter pub get` using the pinned Flutter/Dart toolchain.
3. Inspect `flutter pub deps --json` and `pubspec.lock`. Verify `n42_chat` is a Git dependency at the exact SHA declared by `pubspec.yaml`, and verify the two approved local path packages remain path dependencies.
4. Re-run `flutter pub outdated --json` and save the post-source-change inventory separately from the pre-change snapshot.
5. Run the root Chat-facing compile/test subset identified in the baseline. Treat failures caused by API differences between the Git pin and the former mirror as real migrations to be handled in Task 4; do not restore the path override to make tests pass.

### Acceptance

- A fresh `flutter pub get` resolves `n42_chat` from the declared Git SHA; `pubspec.lock` records that SHA and source `git`.
- No production check uses the local Chat mirror, and no external Chat repository is modified.

## Task 3 — Fix the Flutter analyzer baseline errors

### Files to inspect/change as justified by the captured analyzer output

- `packages/n42_jmt_verify/pubspec.yaml`
- `packages/n42_jmt_verify/lib/src/blake3_hash.dart`
- `lib/features/wallet/n42_wallet_bridge.dart` and its focused wallet bridge tests if the current Git Chat API incompatibility is confirmed.
- `.github/workflows/ci.yml`
- Any additional file explicitly reported by the fresh baseline analyzer output.

The Chat notification implementation is inspected from the Git-resolved package cache only; never edit that cache or `packages/n42_chat`, which is a mirror.

### Steps

1. Reconcile the analyzer's exact output with the saved Task 1 error inventory. Group duplicate diagnostics by their actual root cause; do not assume the historic count or historic diagnosis is still current.
2. If the error is in Chat's Firebase Messaging permission mapping, check the declared Git pin and compatible upstream revisions for a stable fix. Update the root Git SHA only when the revision is compatible and contains the required fix; otherwise do not patch the cache or mirror. If the current Git source has no compatible fixed revision, report this explicitly as the constraint preventing full completion.
3. The app wallet bridge currently calls `PaymentRequestUri.sameAssetId` and `isPositiveAmountForDecimals`; inspect whether those APIs exist in the resolved Git SHA. If absent, keep the behavior in app-owned helpers (with focused tests) or migrate the call sites to an equivalent public Git API; do not restore the mirror override or edit the Git cache/mirror.
4. Resolve the standalone package in its own context with `cd packages/n42_jmt_verify && dart pub get`; run its existing BLAKE3/JMT vector suite with `dart test` and inspect why the root recursive analyzer lacked its package config. Do not widen or upgrade the exact `blake3_dart: 1.0.0` constraint unless source/publisher review supports that separately.
5. Update the existing `analyze` and `test` jobs in `.github/workflows/ci.yml` to run the standalone package's `dart pub get`/`dart test` before repository-wide analysis and tests. This adds steps to current jobs, not new jobs, so clean CI checkouts reproduce package resolution and do not regain the analyzer errors.
6. Run the package checks (`cd packages/n42_jmt_verify && dart analyze && dart test`), relevant wallet bridge tests, then `flutter analyze --no-fatal-infos` across the full repository.

### Acceptance

- Every error in the fresh baseline is resolved at its root; full-repository analysis reports zero errors. If a Chat Git dependency source blocks this, stop claiming completion and provide the exact upstream SHA/API blocker for a user decision.
- Production wallet bridge checks compile against the declared Git source without depending on helper APIs that exist only in the local mirror.
- BLAKE3 vectors and existing JMT proof verification remain correct; notification status behavior remains explicit for every current enum state.
- `blake3_dart` is not silently upgraded or widened.

## Task 4 — Upgrade Flutter and active local package graphs

### Files

- `pubspec.yaml`, `pubspec.lock`, `pubspec_overrides.yaml`
- `plugins/flutter_mining/pubspec.yaml`, `plugins/flutter_mining/pubspec.lock`, `plugins/flutter_mining/example/pubspec.yaml`, `plugins/flutter_mining/example/pubspec.lock`
- `packages/n42_jmt_verify/pubspec.yaml`
- `packages/audioplayers_darwin/pubspec.yaml`
- `packages/webview_flutter_wkwebview/pubspec.yaml`, `packages/webview_flutter_wkwebview/example/pubspec.yaml`
- `.github/workflows/ci.yml` (existing test job only if required to split app and Chat package tests)
- Root Chat test aggregators that import `packages/n42_chat/test/`: `test/features/chat/chat_account_switch_regression_test.dart`, `chat_contact_picker_polish_test.dart`, `chat_contact_selection_a11y_test.dart`, `chat_contacts_groups_regression_test.dart`, `chat_favorites_email_regression_test.dart`, `chat_feedback_2687_regression_test.dart`, `chat_feedback_2696_regression_test.dart`, `chat_local_history_regression_test.dart`, `chat_room_admission_regression_test.dart`, `chat_search_regression_test.dart`, `chat_storage_expression_regression_test.dart`, `chat_testflight_feedback_regression_test.dart`, and `chat_ux_regression_test.dart`.
- Generated outputs only when produced by the repository's existing generator commands.

### Steps

1. Use the Task 2 inventory to enumerate every direct/dev dependency and current stable version. For each retained cap or pin, record the upstream constraint and the exact caller/API that requires it.
2. Upgrade root direct/dev constraints to the latest stable versions compatible with Flutter 3.44.8/Dart 3.12.2, allowing major versions. Migrate source call sites and tests for changed APIs; do not bulk-rewrite lockfiles by hand.
3. Upgrade the `flutter_mining` package and example manifests/locks independently using the same pinned Flutter toolchain; keep ABI/native AAR assumptions explicit and do not change runtime toolchains.
4. Upgrade `n42_jmt_verify`, `audioplayers_darwin`, and `webview_flutter_wkwebview` manifests and their actual plugin sources as compatible. Keep `blake3_dart` exactly pinned under Task 3's security constraint.
5. Regenerate generated code only with `flutter pub run intl_utils:generate` or `flutter pub run build_runner build --delete-conflicting-outputs` when a changed dependency requires it. Never hand-edit generated outputs.
6. Run the affected package suites:
   - `flutter test test/` for app-owned tests, with the Chat test aggregation separated from the cache mirror.
   - `flutter test plugins/flutter_mining/test/`
   - `flutter test plugins/flutter_mining/example/test/`
   - `cd packages/n42_jmt_verify && dart pub get && dart test`
   - `flutter test packages/webview_flutter_wkwebview/test/`
   - `flutter analyze --no-fatal-infos`
7. The 13 listed root Chat test aggregators import test files from the local Chat mirror; they do not test the resolved Git package. Remove those mirror-backed aggregators from the root app test suite and run the Chat package's own tests from a disposable checkout/export at the exact Git `resolved-ref`. Update the existing CI test job to run both suites without editing the pub cache or `packages/n42_chat` mirror; if the exact Git SHA's own tests are blocked, record the precise blocker.
8. Review `pubspec.lock` source/version changes and inspect all dependency overrides after resolution.

### Acceptance

- All active Flutter manifests and lockfiles resolve from a clean install on the pinned toolchain.
- Root, mining, JMT, and WebView tests pass; no unapproved change makes the Chat mirror a production dependency.
- Analyzer still reports zero errors; dependency caps left in place have specific evidence recorded in the final report.

## Task 5 — Upgrade Android Gradle and Maven dependencies

### Files

- `android/settings.gradle.kts`
- `android/build.gradle.kts`
- `android/gradle/wrapper/gradle-wrapper.properties`
- `android/app/build.gradle.kts`
- `plugins/flutter_mining/android/build.gradle`
- `plugins/flutter_mining/android/settings.gradle`
- `plugins/flutter_mining/android/evm-module/build.gradle`
- `plugins/flutter_mining/android/mobile-sdk-module/build.gradle`
- `plugins/flutter_mining/example/android/build.gradle.kts`
- `plugins/flutter_mining/example/android/settings.gradle.kts`

### Steps

1. Use the ignored Gradle wrapper materialized by the baseline Flutter build (do not track or hand-edit ignored wrapper files) and record resolved Gradle/Maven graphs with `./gradlew :app:dependencies` and the mining plugin's Gradle dependency report before edits.
2. Upgrade the Gradle wrapper, AGP, Kotlin Gradle plugin, Google Services plugin, and direct Maven artifacts in the app/mining project to latest stable versions compatible with Java 21 and compile/target SDK 36. Preserve required TrustWallet credentials/repository filtering and document any private artifact whose newest version cannot be inspected.
3. Migrate Gradle/Kotlin DSL or plugin API changes in the files above; keep Java 21 and the Android SDK/toolchain targets fixed.
4. Resolve and build with `flutter build apk --debug`; run Android unit/plugin tests available in the repo, including `plugins/flutter_mining/android` tests. Capture the resolved graph after the changes.

### Acceptance

- Gradle resolves from a clean cache/checkout using the pinned Java 21 toolchain; no repository credential is committed.
- App debug APK and the mining Android library build successfully when required private Maven credentials are available.
- No dependency migration regresses Android permission, storage, scanner, wallet-core, or mining plugin behavior.

## Task 6 — Upgrade Apple CocoaPods and SwiftPM dependency graphs

### Files

- `ios/Podfile`, `ios/Podfile.lock`
- `macos/Podfile`, `macos/Podfile.lock`
- `ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved`
- `ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`
- `packages/audioplayers_darwin/darwin/audioplayers_darwin/Package.swift`
- `packages/webview_flutter_wkwebview/darwin/webview_flutter_wkwebview/Package.swift`

### Steps

1. Retry CocoaPods metadata resolution after the baseline capture. Run `pod outdated` separately in `ios/` and `macos/`; record whether the earlier CDN HTTP/2 error and missing local Flutter podspec are resolved.
2. Upgrade direct pinned pods (including TrustWalletCore and Google MLKit subspecs) and all lockfile-resolved pods to latest stable compatible releases. Keep the iOS/macOS deployment targets and SQLCipher linking behavior unchanged unless a required migration has a dedicated regression test.
3. Resolve Swift packages with `xcodebuild -resolvePackageDependencies` for the Runner workspace and inspect both checked-in `Package.resolved` files for matching stable revisions.
4. Build with `flutter build ios --no-codesign --release` and `xcodebuild -project macos/Runner.xcodeproj -scheme Runner -configuration Release CODE_SIGNING_ALLOWED=NO build` when the local Xcode/SDK and project configuration permit. Record missing Firebase/signing files, pod metadata, or unsupported simulator slices as blockers with exact command output.

### Acceptance

- Pod and SwiftPM resolution is reproducible and all checked-in lock/resolution files match manifests.
- iOS and macOS no-code-sign builds pass when configuration is available; no missing secret/config is fabricated.
- SQLCipher, MLKit, TrustWalletCore, WebRTC, and plugin integration retain their existing linking/runtime requirements.

## Task 7 — Upgrade and verify each Go module

### Files

- `backend/livekit-jwt/go.mod`, `backend/livekit-jwt/go.sum`
- `backend/loyalty/go.mod`, `backend/loyalty/go.sum`
- `backend/social-auth/go.mod`, `backend/social-auth/go.sum`
- `backend/swap/go.mod`, `backend/swap/go.sum`

### Steps

1. In each module, use the captured `go list -m -u all` output to update direct and transitive dependencies to current stable releases compatible with the existing Go 1.26 toolchain; migrate v2+ module paths and source APIs when required.
2. Run `go mod tidy` in each module and verify the `go` directive/toolchain remains unchanged.
3. Run from each module directory:

   ```sh
   go test ./...
   go vet ./...
   go list -m -u all
   ```

4. Review each `go.mod`/`go.sum` diff for unused modules, prereleases, or unrelated removals.

### Acceptance

- All four modules pass test and vet on the pinned Go version.
- Every updated module resolves reproducibly; any dependency held back for compatibility has a named caller and reason.

## Task 8 — Upgrade the Rust MLS crate

### Files

- `rust/n42_mls/Cargo.toml`
- `rust/n42_mls/Cargo.lock`
- Rust call sites and tests under `rust/n42_mls/src/` only when required by an API migration.

### Steps

1. Upgrade `openmls`, `openmls_rust_crypto`, `openmls_basic_credential`, `openmls_traits`, `tls_codec`, and target-specific `jni` to latest stable releases compatible with the pinned Rust 1.97.1 toolchain.
2. Migrate API changes in the MLS engine/FFI/JNI boundary while preserving RFC 9420 behavior and the C/Android ABI.
3. Run `cargo update`, normalize the existing and changed Rust sources with `cargo fmt --all`, then run `cargo fmt --check`, `cargo test --all-targets`, `cargo check --all-targets`, and `cargo clippy --all-targets -- -D warnings` from `rust/n42_mls/`.
4. Review `cargo tree` and the complete lockfile diff for duplicate crypto versions, prereleases, and unintended removals.

### Acceptance

- The crate passes all four Rust checks with the pinned toolchain and produces the existing FFI crate types.
- MLS behavior, FFI symbols, and Android JNI integration remain compatible; blocked cross-target checks are listed separately.

## Task 9 — Upgrade Chrome extension dependencies and add crypto vectors

### Files

- `chrome-extension/package.json`
- `chrome-extension/package-lock.json`
- `chrome-extension/eslint.config.js`
- `chrome-extension/src/background/keyring.test.ts`
- `chrome-extension/src/background/keyring.ts` only for required dependency API migrations
- `chrome-extension/vitest.config.ts` and `chrome-extension/src/test/setup.ts` if needed for Chrome API/WebCrypto mocks

### Steps

1. Upgrade all production and development dependencies in `package.json` to current stable releases, including React/ReactDOM, Noble, Scure, viem, Zustand, Vite, TypeScript, and Chrome/React type packages. Add the missing `eslint`, `typescript-eslint`, and `eslint-plugin-react-hooks` development tools, create a flat ESLint config for TypeScript/TSX, and update the lint script to the installed ESLint CLI. Validate with Node 20, the existing CI Node pin; do not upgrade the Node toolchain. Migrate React 19 and crypto API changes where required.
2. Add Vitest as a dev dependency and a `test` script; write deterministic keyring vectors using the standard `test test test test test test test test test test test junk` mnemonic. Verify derived address `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`, account index derivation, personal-message/raw-hash signing shape, lock behavior, and wrong-password unlock rejection with mocked `chrome.storage.local`.
3. Run `npm install` to write the package lock, then `npm ci` from a clean install.
4. Run `npm test`, `npm run lint`, `npm run type-check`, `npm run build`, and `npm audit --omit=dev --audit-level=moderate`.
5. Review the production dependency audit findings individually; upgrade or migrate affected packages, or record an exact unfixable upstream blocker.

### Acceptance

- The extension installs reproducibly from `package-lock.json`; tests, lint, types, and production build pass.
- Deterministic wallet derivation/signing vectors remain unchanged after Noble/Scure major migrations.
- No unresolved high/critical production dependency advisory remains; any non-fixable advisory is documented with package/version/advisory and impact.

## Task 10 — Full repository acceptance and results report

### Files

- Add `docs/testing/dependency-upgrade-results-2026-09-25.md` with exact manifests changed, stable versions, migrations, test/build/audit commands and results, blockers, and retained pins.
- Include all baseline and final command logs under `docs/testing/dependency-upgrade-baseline-2026-09-25/` and `docs/testing/dependency-upgrade-final-2026-09-25/`.

### Steps

1. From the app root, run `flutter pub get`, `flutter analyze --no-fatal-infos`, `dart format --output=none --set-exit-if-changed lib/ test/`, `flutter test --coverage --concurrency=4`, and `python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70`.
2. Run the root and active package test suites from Task 4, all four Go test/vet pairs, all Rust checks, and all Chrome extension checks from Tasks 7–9.
3. Run the Android debug APK and available iOS/macOS no-code-sign builds again against the final lockfiles.
4. Run fresh-install resolution checks (`flutter pub get`, `npm ci`, each `go mod tidy` followed by a clean diff check, and `cargo check --locked`). Verify exact Chat Git SHA and all checked-in lockfiles.
5. Inspect the full diff and lockfiles for prereleases, accidental downgrades, untracked generated files, changed toolchain pins, secrets, or unrelated source changes. Record a clean `git diff --check` result.

### Acceptance

- Full-repository Flutter analysis has zero errors.
- Run and report the existing coverage gate without changing its 70% threshold. The user explicitly deferred raising the 49.13% baseline during this dependency-upgrade task, so this known coverage gap is excluded from this task's pass criteria and must remain visible in the results report.
- All in-scope tests, static checks, and builds pass, or have an exact environment/upstream blocker recorded. The explicitly deferred coverage gap remains separately reported; no other known baseline failure is ignored or relabeled as an accepted blocker.
- All dependency graphs install reproducibly with the pinned toolchains; no prereleases, secret files, or unreviewed package-source changes are present.
- The final report clearly separates passed checks, baseline fixes, upgrade regressions resolved, and blocked checks.

## Self-review

- Every in-scope ecosystem has a dedicated manifest/lockfile list and explicit verification commands.
- The Chat source correction is sequenced before version upgrades and is verified against the Git SHA, not the mirror.
- The user's added zero-error analyzer requirement is a separate planned task with focused root-cause tests and a final full analysis gate.
- The existing 70% coverage gate remains unchanged; its 49.13% baseline failure is explicitly deferred per the user's instruction and is reported separately from dependency-upgrade acceptance.
- High-risk review items map to concrete checks: source resolution (Task 2), crypto vectors (Task 9), analyzer zero (Tasks 3 and 10), platform linking/builds (Tasks 5–6), and lockfile/audit review (Tasks 1 and 10).
- No implementation or dependency file is changed by this plan-writing step.
