# 2026-06-30 Live Gift / Prediction Sync T14

## Branch
- `feat/live-gift-prediction-sync`
- Verified head after rebase: `b667776b feat(live): 预测链上托管合约即插即用切换 + 零歧义 ABI 规格`
- Included upstream T14 additions:
  - `56e1ee8f` live room heartbeat / gift broadcast / prediction Matrix replay sync.
  - `6c1a6d54` gift coin economy and event-sourced tally.
  - `b667776b` optional chain-backed prediction repository switch and ABI spec.

## Automated Verification
- Re-run at `2026-06-30 23:57 EDT` after confirming no newer T14 task text or branch commits.
- PASS: `flutter test test/features/live/ --no-pub`
  - 29 tests passed.
- PASS: `flutter analyze lib/features/live --no-fatal-infos`
- PASS: `flutter build apk --debug --target-platform android-arm64 --no-pub`
  - Built `build/app/outputs/flutter-apk/app-debug.apk`.
- PASS: `flutter build ios --debug --no-codesign --no-pub`
  - Built `build/ios/iphoneos/Runner.app`.

## Device Availability
- Android: Redmi Note 15 / `38f4f08a` / Android 16 API 36.
- iPhone wireless: `00008150-000E2469149A401C` / iOS 27.0.

## Device Blockers
- Android install BLOCKED by device policy:
  - `flutter install -d 38f4f08a --debug`
  - `adb install -r -t -d build/app/outputs/flutter-apk/app-debug.apk`
  - `adb install --no-streaming -r -t -d build/app/outputs/flutter-apk/app-debug.apk`
  - All failed with `INSTALL_FAILED_USER_RESTRICTED: Install canceled by user`.
  - Re-run at `2026-06-30 23:57 EDT`: `adb install --no-streaming -r -t -d build/app/outputs/flutter-apk/app-debug.apk` still fails with the same error after pushing the APK to the device.
  - Re-run at `2026-07-01 00:04 EDT`:
    - `adb -s 38f4f08a install --no-streaming -r -t -d build/app/outputs/flutter-apk/app-debug.apk`
    - `adb -s 38f4f08a install -r -t -d build/app/outputs/flutter-apk/app-debug.apk`
    - `flutter install -d 38f4f08a --debug`
    - All still fail with `INSTALL_FAILED_USER_RESTRICTED: Install canceled by user`.
- Android settings inspection:
  - Developer options and USB debugging are enabled.
  - `USB调试（安全设置）` is enabled.
  - `USB安装` is currently `checked=false`.
  - Attempts to enable `USB安装` via ADB input did not change the setting; this appears to require a manual on-device tap/confirmation.
  - `pm list packages` showed no installed `ai.n42.www`, so the T14 build is not currently installed on Android.
  - Re-run confirmation: `pm list packages` still only shows `com.example.n42_chat_example` and `com.n42.verifier`; `ai.n42.www` is still absent.
  - Re-run confirmation at `2026-07-01 00:04 EDT`: target package is still absent from `pm list packages`; `dumpsys package ai.n42.www` returns no version data.
- iPhone launch BLOCKED:
  - `flutter run -d 00008150-000E2469149A401C --debug --no-pub` completed Xcode build and began install/launch, then failed with:
    - `Error starting debug session in Xcode: Failed to find project Runner: Error: 不能获取对象。`
    - Flutter suggested opening `ios/Runner.xcworkspace` and running from Xcode.
  - Re-run at `2026-06-30 23:57 EDT`: same failure after Xcode build and install/launch phase.

## T14 Matrix
| # | Scenario | Status | Evidence / Notes |
|---|----------|--------|------------------|
| 1 | B enters A live room and sees video | BLOCKED | Cross-device app install/launch blocked before runtime test. Video may still be independently blocked by the known LiveKit JWT endpoint issue. |
| 2 | A/B live comments sync; structured events stay out of chat | BLOCKED | Cross-device runtime unavailable. |
| 3 | B exits and live list still shows A room without member inflation | BLOCKED | Cross-device runtime unavailable. |
| 4 | A stops live; B list removes room within 90s and dead room blocks entry | BLOCKED | Cross-device runtime unavailable. |
| 5 | A kills app; heartbeat TTL auto-expires within 90s | BLOCKED | Cross-device runtime unavailable. |
| 6 | B sends rose gift; both sides show animation and toast | BLOCKED | Cross-device runtime unavailable. |
| 7 | B sends multiple gifts; animation cap/rolling hints hold | BLOCKED | Cross-device runtime unavailable. |
| 8 | A opens prediction; B sees same question/options/prices | BLOCKED | Cross-device runtime unavailable. |
| 9 | B buys outcome; prices/position/balance update | BLOCKED | Cross-device runtime unavailable. |
| 10 | A and B buy different outcomes; prices replay consistently | BLOCKED | Cross-device runtime unavailable. |
| 11 | Timed prediction closes locally at deadline | BLOCKED | Cross-device runtime unavailable. |
| 12 | A resolves winner; B redemption follows winner/loser rules | BLOCKED | Cross-device runtime unavailable. |
| 13 | A cancels prediction; B redemption returns net principal | BLOCKED | Cross-device runtime unavailable. |
| 14 | A cannot cancel after resolution | BLOCKED | Cross-device runtime unavailable. Logic-level guard is covered by existing prediction tests. |

## Next Step
- Manually enable Android Developer options -> `USB安装`, then rerun:
  - `adb -s 38f4f08a install --no-streaming -r -t -d build/app/outputs/flutter-apk/app-debug.apk`
- For iPhone, open `ios/Runner.xcworkspace` in Xcode once and run `Runner` on the wireless device to clear the Automation/project control failure, then rerun `flutter run`.
