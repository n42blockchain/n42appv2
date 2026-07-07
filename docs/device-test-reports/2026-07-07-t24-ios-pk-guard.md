# T24 iOS private-key guard rerun - 2026-07-07

## Scope

- Validation worktree: `/tmp/n42appv2-t24`
- Requested baseline: `origin/refactor/ios-walletcore-signing@51363436`
- Tested commit: `51363436` (`fix(ios): 合并 dev513 WalletCorePlugin 全链签名重构`)
- Current remote head observed: `origin/refactor/ios-walletcore-signing@5b84de09`
- Physical iPhone device id: `00008150-000E2469149A401C`
- CoreDevice id: `1046FC66-1844-5F30-88D0-7140EBF4A41C`

## Results

| Item | Result | Detail |
|---|---:|---|
| C1 iOS compile | PASS | `flutter build ios --debug --no-codesign --no-pub` succeeded and produced `build/ios/iphoneos/Runner.app`. |
| C2 valid imported private key generates address | BLOCKED | A temporary iOS probe was built and installed, but device launch was rejected because the iPhone was locked. The probe calls `trustdart.generateAddress` with private key `4f3e...f5d7` and expects `0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1`. |
| C3 invalid private key returns error instead of crash | BLOCKED | Same probe includes invalid key `@@bad@@` and expects `PlatformException.code == invalid_pk`; launch was blocked before runtime verification. |
| C4 full signing chain | BLOCKED | No signing assets/test fixture were available in this rerun. |
| C5 Camera/Photo native permission cases | PASS with follow-up | `case "Camera"` is wired from `scan_page.dart` through `Trustdart.getPermissions("Camera")`. `case "Photo"` exists in `WalletCorePlugin.swift`, but no Dart caller was found; it is currently native-only/reserved or dead code. |

## Build blockers found and handled in validation worktree

- CocoaPods lock was stale against resolved plugin pods. The T24 worktree needed a targeted pod update for Firebase, Firebase Messaging/Crashlytics, Google measurement/data transport, and FaceSDK pods before Swift compilation could proceed.
- Fresh dependency resolution selected `dio 5.10.0`, which adds a `DioExceptionType` member not covered by the existing switch. The main worktree now has a conservative default branch in `BaseHttp._handleDioError`, verified by analyzer.
- The T24 worktree needed a local `ios/Runner/GoogleService-Info.plist` copy to satisfy the Xcode build phase. This file remains local-only and was not committed.

## Device attempts

- Physical install succeeded:
  `xcrun devicectl device install app --device 1046FC66-1844-5F30-88D0-7140EBF4A41C build/ios/iphoneos/Runner.app`
- Physical launch failed twice with the same CoreDevice result:
  `Unable to launch ai.n42.www because the device was not, or could not be, unlocked`.
- Simulator route was also blocked:
  `flutter build ios --simulator --debug -t lib/t24_ios_pk_guard_probe.dart --no-pub` failed at link time with `Framework 'TensorFlowLiteSelectTfOps' not found`.
- After the blocked probe attempts, the physical iPhone was restored through the main app entrypoint with `flutter run -d 00008150-000E2469149A401C --no-pub`; launch/debug still failed in Xcode, but `devicectl device info apps` now reports `N42Wallet`, bundle `ai.n42.www`, version `2.4.3`, build `2026062602`.

## Merge readiness

- Do not merge raw `origin/refactor/ios-walletcore-signing@5b84de09` without reviewing the branch noise and dependency drift.
- Commit `51363436` compiles after local dependency/config cleanup and does not show WalletCore Swift compile errors.
- Before merge, decide whether `Photo` permission is intended future API or should be removed/wired, and refresh/pin the iOS dependency state so a clean checkout builds without manual pod repair.
