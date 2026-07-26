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
| C2 valid imported private key generates address | PASS | Final iPhone profile probe exported a native ETH private key from mnemonic, re-imported that pk through the pk branch, and matched the mnemonic-derived address. |
| C3 invalid private key returns error instead of crash | PASS | Final iPhone profile probe verified invalid hex through `generateAddress` and invalid base64 through `signMessage`; both returned `invalid_pk`, and the app stayed alive. |
| C4 full signing chain | PARTIAL | Local no-gas ETH `signMessage` with a native exported private key passed on iPhone. Real EVM/BTC/TON/SOL broadcasts, AA path, and mining start still require assets/device state and remain blocked as in T20/T21/T22. |
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

## C3/C4 supplement

Timestamp: 2026-07-07 18:19 EDT.

- Current worktree `fix/competitor-report-audit` still had forced unwraps in `ios/WalletCorePlugin.swift`, so C3 would crash rather than return `invalid_pk`.
- Fixed the six requested private-key branches: `generateAddress`, `signTransaction`, `signTransaction_btc_p2wsh`, `signTransaction_byteArray`, `signMessage`, and `getTransactionMaxValue`.
- Also guarded the three adjacent entropy wallet branches called out in the task note: `getPublicKey`, `getKeyStore`, and `getPrivateKeyAndPublicKey`.
- Rebuilt iOS successfully with `flutter build ios --debug --no-codesign --no-pub`.
- Added a temporary probe target, not committed, with:
  - C2 valid ETH imported private key address check: expected `0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1`.
  - C3 invalid hex private key through `generateAddress`: expects `PlatformException.code == invalid_pk`.
  - C3 invalid base64 private key through `signMessage`: expects `PlatformException.code == invalid_pk`.
  - C4 local ETH `signMessage` with valid private key: expects a non-empty hex signature.
- `flutter analyze --no-fatal-infos lib/t24_ios_pk_guard_probe.dart` passed.
- `flutter run -d 00008150-000E2469149A401C -t lib/t24_ios_pk_guard_probe.dart --no-pub` completed Xcode build and reached install/launch, but Xcode debug attach failed with `Failed to find project Runner`.
- Direct launch with `xcrun devicectl device process launch --device 1046FC66-1844-5F30-88D0-7140EBF4A41C --terminate-existing --console --timeout 25 ai.n42.www` was rejected because the iPhone was locked.
- Simulator fallback still fails because Xcode only exposes the Runner scheme simulator placeholder, not the booted simulator destination.
- Simulator build-only fallback also failed after 160.7s at link time with `Framework 'TensorFlowLiteSelectTfOps' not found`.
- After the probe attempt, ran the main entrypoint again with `flutter run -d 00008150-000E2469149A401C --no-pub`; Xcode attach still failed, but `devicectl device info apps` reports `N42Wallet`, bundle `ai.n42.www`, version `2.4.3`, build `2026062602`.

Supplement status:

| Item | Status after supplement | Detail |
|---|---:|---|
| C3 invalid private key | PASS | Native guard now returns `FlutterError(code: invalid_pk)` for invalid private-key parse failures. iPhone profile probe confirmed both invalid hex and invalid base64 branches. |
| C4 full signing chain | PARTIAL / ASSET BLOCKED | iPhone profile probe confirmed local no-gas ETH `signMessage` succeeds with a native exported private key. Real EVM/BTC/TON/SOL broadcasts, AA path, and mining start still require assets/device state and remain blocked as in T20/T21/T22. |

## Final iPhone rerun

Timestamp: 2026-07-07 18:51 EDT.

- Confirmed the Xcode target references `ios/Runner/WalletCorePlugin.swift`; the actual target file now has the same `invalid_pk` guard helpers and no remaining pk/entropy forced unwrap parse sites.
- Rebuilt a signed profile probe with `flutter build ios --profile -t lib/t24_ios_pk_guard_probe.dart --no-pub`.
- Installed it explicitly with `xcrun devicectl device install app --device 1046FC66-1844-5F30-88D0-7140EBF4A41C build/ios/iphoneos/Runner.app`.
- Launched it with `xcrun devicectl device process launch --device 1046FC66-1844-5F30-88D0-7140EBF4A41C --terminate-existing --console --timeout 30 ai.n42.www`.
- User-provided iPhone photo showed:
  `T24_RESULT:C2_REIMPORT_EXPORTED_PK_ADDRESS:PASS;C3_GENERATE_ADDRESS_INVALID_HEX:PASS;C3_SIGN_MESSAGE_INVALID_BASE64:PASS;C4_ETH_SIGN_MESSAGE_VALID_PK:PASS`.
- After verification, removed the temporary probe, rebuilt the normal app entrypoint with `flutter build ios --profile --no-pub`, and reinstalled `build/ios/iphoneos/Runner.app` with `devicectl device install app`.

## Merge readiness

- Do not merge raw `origin/refactor/ios-walletcore-signing@5b84de09` without reviewing the branch noise and dependency drift.
- Commit `51363436` compiles after local dependency/config cleanup and does not show WalletCore Swift compile errors.
- Before merge, decide whether `Photo` permission is intended future API or should be removed/wired, and refresh/pin the iOS dependency state so a clean checkout builds without manual pod repair.
