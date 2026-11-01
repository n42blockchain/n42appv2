# Mining version settings — Android profile device check

Date: 2026-11-01, America/Toronto. Branch: `feat/mining-v3-ui`.

Android settings now offer **V1 / V2 / V3** in both debug and non-debug builds. The former `kDebugMode` / `MINING_V3` release gate hid V3 in normal builds. Availability now follows the supported native platform. The V3 description is localized in English and Traditional Chinese; other locales use the generated English fallback.

The V3 foreground-service bridge is implemented on Android. iOS continues to offer V1/V2; this change does not supply an iOS V3 bridge.

## Exact test build

- Source: `f21e24f6fb8949efb0ae4b5a94aca434d5e8871a`.
- APK: **2.5.3+73068**, **profile** mode, `lib/main.dart`, `android-arm64`, isolated package **ai.n42.www.t30**. No `MINING_V3` define was supplied.
- Command: `flutter build apk --profile --no-pub --target-platform android-arm64` with Flutter 3.47.5 / Dart 3.13.4.
- Device: Xiaomi 25098RA98C, Android 16/API 36, USB 38f4f08a. Existing QA data and device identity 8 were retained by an in-place update.
- Build-only package/Firebase client changes were restored. This is a profile test APK, not a production release upload.
- [APK source, size and SHA-256](mining-version-switch-2026-11-01/artifact.json), [successful install](mining-version-switch-2026-11-01/install.txt). Initial USB attempts were rejected; a subsequent normal retry succeeded.

## Automated checks

**48 tests passed:** `flutter test --no-pub test/core/providers/mining_engine_kind_test.dart test/features/home/setting/mining_version_setting_test.dart test/features/mining_v3`. [Output](mining-version-switch-2026-11-01/flutter-tests.txt).

Coverage includes all three selections, stored-version loading, legacy boolean migration, unsupported-platform fallback, 320 px width, 1x/2x text, English/Traditional Chinese labels, and the existing V3 activity/engine/dashboard cases. Settings widgets use a controlled preference store; provider tests separately exercise SharedPreferences persistence.

Targeted analysis of the enum, notifier, settings page and new test reported **No issues found**. [Output](mining-version-switch-2026-11-01/flutter-analyze.txt).

## Separate physical-device checks

| Check | Result | Observed behavior |
|---|---|---|
| Non-debug settings entry | PASS | Profile APK showed all three version buttons. The debug-only probe entry was absent. [V3 selection](mining-version-switch-2026-11-01/settings-v3.png). |
| Select V1 | PASS | Label changed to Classic Mining (V1); Verification opened the existing V1 No data state for this QA account. [Setting](mining-version-switch-2026-11-01/settings-v1.png), [page](mining-version-switch-2026-11-01/page-v1.png). |
| Select V2 | PASS | Label changed to Mining (V2); Verification opened the V2 dashboard in its unstaked/disabled state. [Setting](mining-version-switch-2026-11-01/settings-v2.png), [page](mining-version-switch-2026-11-01/page-v2.png). |
| Select and start V3 | PASS | Opened the redesigned V3 page and verified actual blocks using device 8 and the saved node. At 11 s the UI showed 7 verified blocks and a running foreground service. [Running V3](mining-version-switch-2026-11-01/v3-active.png). |
| Switch away from running V3 | PASS | Selected V2 in global settings. The V3 foreground miner service stopped before the later app restart. [Native service check](mining-version-switch-2026-11-01/handover.json). |
| Preserve choice across cold start | PASS | Selected V3, force-stopped only the QA package, and relaunched. Settings still showed V3 selected, all three buttons and no debug probe. [Restarted settings](mining-version-switch-2026-11-01/settings-restarted.png), [UI hierarchy](mining-version-switch-2026-11-01/settings-restarted.xml). |

Final state: QA package remains installed, V3 selected, miner service stopped. The pointer-location setting temporarily changed for screenshots was restored. [Postcondition](mining-version-switch-2026-11-01/postcondition.json). The phone's existing clock overlay remains visible in captures.

V1/V2 checks establish selection and page routing. Successful V1 mining and V2 staking were not exercised. Large text and Traditional Chinese were checked in widget tests; physical checks used English and normal text size. The separate T30 protocol findings and reward-payment acceptance remain outside this change.

The subsequent report-only commit increments the pubspec build number through the normal hook. The tested APK provenance remains 73068 above.
