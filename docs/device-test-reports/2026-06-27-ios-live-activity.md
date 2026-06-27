# 2026-06-27 iOS Chat Call Live Activity

## Scope

- Task: T5, iOS chat call Live Activity target wiring and device validation.
- Baseline: `master` native implementation introduced at `2a680c92`; final local base fast-forwarded to `74f64aed`.
- Host: macOS 26.5.1 (25F80), Flutter 3.41.4 stable, Dart 3.11.1.
- Device seen by Flutter/Xcode: iPhone `00008150-000E2469149A401C`, iOS 27.0 `24A5370h`, wireless.

## Changes Made

- Added `ios/Runner/N42ChatCallAttributes.swift` to both Runner and N42Extension source phases.
- Added `ios/N42/N42ChatCallLiveActivity.swift` to the N42Extension source phase only.
- Changed iOS CocoaPods linkage to `use_frameworks! :linkage => :static`.
  This was required because the current dependency graph includes `flutter_gemma`, whose MediaPipe/TensorFlowLite XCFramework dependencies are statically linked and fail under dynamic `use_frameworks!`.
- Regenerated `ios/Podfile.lock` via `pod install`.

## Build Verification

| Check | Result | Notes |
|---|---|---|
| `cd ios && pod install` | PASS | Initial run failed on statically linked MediaPipe/TensorFlowLite binaries; passed after static framework linkage. |
| `xcodebuild -workspace ios/Runner.xcworkspace -scheme N42Extension -configuration Debug -sdk iphoneos26.5 -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build` | PASS | Confirms widget target sees `N42ChatCallAttributes` and `N42ChatCallLiveActivity`. |
| `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphoneos26.5 -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build -quiet` | PASS | Link warnings only; no build failure. |
| `flutter run -d 00008150-000E2469149A401C --debug --no-pub --device-timeout=60` | PARTIAL | Xcode build completed in 138.0s and signing team `CFRXH38L48` was selected. Launch failed: `Failed to find project Runner: Error: 不能获取对象。` |

## Device Matrix

| # | Scenario | Result | Notes |
|---|---|---|---|
| 1 | Start or answer a chat voice/video call | BLOCKED | App could not be launched by `flutter run` after the device build completed. |
| 2 | Lock screen during call | BLOCKED | Requires successful app launch and an active chat call. |
| 3 | End call | BLOCKED | Requires successful app launch and an active chat call. |
| 4 | Chat call Live Activity while mining Live Activity is active | BLOCKED | Requires successful app launch and both runtime flows. |
| 5 | Disable Live Activities in Settings, then call | BLOCKED | Requires successful app launch and settings flow. |

## Status

T5.1 target wiring is complete and build-verified for both Runner and N42Extension.
T5.2 runtime/device call verification remains blocked by the local Flutter/Xcode launch failure after successful iPhone build.
