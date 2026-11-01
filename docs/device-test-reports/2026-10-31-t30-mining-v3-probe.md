# T30 — Android mining v3 probe

Date: 2026-10-31 (America/Toronto).
Status: **BLOCKED at APK installation; no v3 runtime acceptance claimed.**

## Baseline and isolation

- Task: `origin/codex-n42` at `712de7336`, T30, including the corrected GitHub baseline.
- Tested source/build baseline: `71650b32e0a19b0846c5917c065df79ccb69b4bd` on `feat/mining-v3-mobileverify`.
- Report/fix branch: `t30/mining-v3-fixes`; independent worktree. No changes to the shared feature branch, v1/v2 source, node, proxy, Go SDK, or AAR.
- Device: Xiaomi `25098RA98C`, Android 16 / API 36, security patch 2026-07-01, ABI `arm64-v8a`.
- Flutter 3.47.5 / Dart 3.13.4, Java 21.
- Local build-only application ID: `ai.n42.www.t30`, to test a fresh install without deleting or overwriting the existing `ai.n42.www` wallet. Production `lib/main.dart` entrypoint; debug mode; source version `2.5.3+73054`. The packaging change was reverted after the build and is not committed. A matching local Firebase client package name was used only in the ignored `google-services.json`.
- The package did not exist on the phone before installation. The phone rejected installation, and the existing wallet app was left intact.

## Network gate — PASS

Mac `GET http://192.168.0.217:21100/mobileverify/latest` returned HTTP 200 with `packet: true`; two samples advanced from block 14379219 to 14379347. Phone `GET /mobileverify/health` returned valid JSON (`registry: 7`, `pending: 0`, `alarms: 0`). Phone Wi-Fi: `N42`; IP: `192.168.0.26/24`. No USB forwarding or replacement network route was used.

Evidence: [network.json](t30-2026-10-31/network.json), [device.json](t30-2026-10-31/device.json).

## Device matrix

| # | Scenario | Result | Evidence / remaining work |
|---|---|---|---|
| 1 | Fresh install, new key, registration, verification, certificate | BLOCKED | Android rejected APK installation; no probe run or new device key. |
| 2 | Repeat in the same app lifecycle | BLOCKED | Requires installed v3 APK and case 1. |
| 3 | Kill/reopen, persistent key and device index | BLOCKED | Requires installed v3 APK and case 1. |
| 4 | Five consecutive verifications | BLOCKED | No blockNumber/txs/elapsedMs runtime samples exist. |
| 5 | Wrong chain, failure, then successful recovery | BLOCKED | Requires installed v3 APK. |
| 6 | Wrong port, failure, usable button | BLOCKED | Requires installed v3 APK. |
| 7 | Airplane mode during registration, then recovery | BLOCKED | Requires installed v3 APK. Phone networking was not changed. |
| 8 | Back navigation during execution, then reenter | BLOCKED | Requires installed v3 APK. No lifecycle runtime claim. |
| 9 | v1 startup/status and native AAR regression | BLOCKED | Requires installed APK containing the new AAR. No native regression claim. |
| 10 | ABI, APK size, cold-start behavior | BLOCKED | ABI and artifact size measured below; cold-start cannot be measured until installation succeeds. |

Summary: **0 PASS / 0 FAIL / 10 BLOCKED** for the requested device matrix. Network and automated checks are separate results.

## Installation blocker

Command:

```sh
adb -s <usb-device> install build/app/outputs/flutter-apk/app-debug.apk
```

Result (exit 1):

```text
Performing Streamed Install
adb: failed to install build/app/outputs/flutter-apk/app-debug.apk: Failure [INSTALL_FAILED_USER_RESTRICTED: Install canceled by user]
```

The OS did not provide a more specific cause. The task explicitly prohibits bypassing this restriction. The user was asked to allow USB installation and approve the normal installation prompt before a retry. No security-setting workaround, alternate installation route, uninstall, or data wipe was attempted.

Full installation output: [install.log](t30-2026-10-31/install.log).

## Artifact and automated checks

- Debug APK: **788,854,350 bytes** (752.3 MiB), a universal debug build; not a release-size measurement.
- APK SHA-256: `d538236e15f87f2ab03f6fa0759ffcf10dafd78dd41e4a6c90731d39a6bb320e`.
- `evm.aar`: 60,699,610 bytes; SHA-256 `9cf87290150b78fe5f8142cc48f04f51684b8198119a917c97b0c93def71a4c7`.
- `make setup`: PASS; pre-commit build-number hook installed, not bypassed.
- `flutter pub get`: PASS with the committed dependency constraints; no tracked lockfile changes retained.
- `flutter build apk --debug --no-pub`: PASS (178.8 s Gradle task). First build compiled native encryption dependencies for four ABIs.
- `flutter test --no-pub test/features/mining_v3/`: **14 PASS**.
- Plugin `flutter test test/mobileverify_test.dart`: **4 PASS**. Generated/migrated plugin support files were reverted; no incidental dependency changes retained.
- `flutter analyze --no-fatal-infos lib/features/mining_v3 plugins/flutter_mining/lib`: exit 0, **0 errors / 0 warnings / 4 existing info diagnostics** (`prefer_initializing_formals`).

Evidence: [artifact.json](t30-2026-10-31/artifact.json), [build-summary.log](t30-2026-10-31/build-summary.log), [unit-tests.log](t30-2026-10-31/unit-tests.log), [channel-tests.log](t30-2026-10-31/channel-tests.log), [analysis.log](t30-2026-10-31/analysis.log).

## Fixes and continuation

No product defect has been reproduced; no product source fix was made. There are no case 1/4 probe logs or failure logcat traces because the app never installed or launched. Resume with normal USB installation after the user resolves the OS restriction, then execute all ten cases on this pinned baseline. Fetch and review any concurrent feature-branch updates before changing the baseline; record a separate artifact hash and acceptance result for any newer APK.
