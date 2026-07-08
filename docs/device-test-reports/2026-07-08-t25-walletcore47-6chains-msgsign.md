# T25 wallet-core 4.7.0 + 6-chain iOS compile + message signing/public key - 2026-07-08

Branch/base: `master@7a239de0`.

Device target: iPhone 17 Pro Max (`1046FC66-1844-5F30-88D0-7140EBF4A41C`).

## Summary

| Item | Result | Detail |
|---|---:|---|
| A1 `TrustWalletCore` 4.7.0 pod install | PASS | `pod update ... --no-repo-update` and then `pod install --no-repo-update` completed. `ios/Podfile.lock` now resolves `TrustWalletCore 4.7.0`. |
| A2 iOS compile including 6-chain Swift | PASS | `flutter build ios --debug --no-codesign --no-pub` succeeded after fixing target wiring and Swift 4.7.0 API compile errors. Built `build/ios/iphoneos/Runner.app`. |
| B1 EVM message signing | PASS | iPhone profile probe recovered the `personal_sign` signer address and matched the generated ETH account. |
| B2 non-EVM message signing | PASS | iPhone profile probe verified TRX/SOL/APT/SUI native `trustdart.signMessage` all return non-empty signatures. |
| B3 public key display/native retrieval | PASS | iPhone profile probe verified ETH/TRX/SOL/APT/SUI native `trustdart.getPublicKey` all return non-empty values. UI code path also calls this same native method from the single-coin manage page. |
| B4 6 new-chain transaction signing/broadcast | BLOCKED | Requires XLM/VET/NEAR/THETA/ADA/EGLD assets and broadcast fixtures. Not attempted in this no-gas compile pass. |

## What was fixed

1. Xcode target wiring was wrong for T25: the project compiled root `ios/WalletCorePlugin*.swift` files, while the current rewritten implementation and 6-chain additions live in `ios/Runner/WalletCorePlugin*.swift`.
   - Updated `ios/Runner.xcodeproj/project.pbxproj` file references to compile `Runner/WalletCorePlugin.swift`, `Runner/WalletCorePlugin+KeyManagement.swift`, and `Runner/WalletCorePlugin+Signing.swift`.
   - This makes A2 meaningful: the 6 new signing functions in `Runner/WalletCorePlugin+Signing.swift` are now actually compiled.
2. `TrustWalletCore 4.7.0` Swift API returns optional `PrivateKey?` for `wallet.getKey(...)`.
   - Added guarded key resolution in `WalletCorePlugin+KeyManagement.swift`.
   - Added `resolveSigningPrivateKey(...)` in `WalletCorePlugin+Signing.swift` and used it across mnemonic-derived signing branches.
3. Replaced `Result<..., FlutterError>` in `WalletCorePlugin.swift` with a local `KeyResolution` enum because `FlutterError` does not conform to Swift `Error`.
4. While making the file compile against the actual Runner source, fixed two compile-adjacent signing defects in the same touched paths:
   - ZIL signing now derives `CoinType.zilliqa` instead of `CoinType.ton`.
   - SUI signing uses `pk.data` and `SuiSigningOutput` instead of a stale Aptos output/private-key reference.
5. The first unlocked iPhone probe exposed two native edge-case gaps:
   - `getPublicKey` was missing explicit Aptos and Sui branches, so APT/SUI public key retrieval returned empty.
   - TRX `signMessage` attempted secp256k1 signing on a raw non-32-byte payload. The iOS path now hashes non-32-byte TRX message payloads with SHA-256 before signing, while preserving already-digested 32-byte inputs.

## Commands run

- `flutter pub get`
- `pod update TrustWalletCore Firebase Firebase/CoreOnly Firebase/Crashlytics Firebase/Messaging FirebaseAnalytics FirebaseAnalytics/Default FirebaseCore FirebaseCoreExtension FirebaseCoreInternal FirebaseCrashlytics FirebaseInstallations FirebaseMessaging FirebaseSessions GoogleAppMeasurement GoogleAppMeasurement/Core GoogleAppMeasurement/Default GoogleAppMeasurement/IdentitySupport GoogleDataTransport GoogleUtilities nanopb PromisesObjC FaceSDK --no-repo-update`
- `pod install --no-repo-update`
- `flutter build ios --debug --no-codesign --no-pub`
- `flutter build ios --profile -t lib/t25_ios_probe.dart --no-pub`
- `xcrun devicectl device install app --device 1046FC66-1844-5F30-88D0-7140EBF4A41C build/ios/iphoneos/Runner.app`
- `xcrun devicectl device process launch --device 1046FC66-1844-5F30-88D0-7140EBF4A41C --terminate-existing --console --timeout 30 ai.n42.www`
- `flutter analyze --no-fatal-infos`
- Removed the temporary probe and rebuilt the normal app entrypoint with `flutter build ios --profile --no-pub`.

## iPhone probe results

After unlocking the iPhone, the first probe result was:

`T25_RESULT:B1_EVM_PERSONAL_SIGN:PASS;B3_PUBLIC_KEY:ETH:PASS,TRX:PASS,SOL:PASS,APT:EMPTY,SUI:EMPTY;B2_NON_EVM_SIGN:TRX:EMPTY,SOL:PASS,APT:PASS,SUI:PASS`

After fixing the Aptos/Sui public-key branches and TRX digest handling, the retry result was:

`T25_RESULT:B1_EVM_PERSONAL_SIGN:PASS;B3_PUBLIC_KEY:ETH:PASS,TRX:PASS,SOL:PASS,APT:PASS,SUI:PASS;B2_NON_EVM_SIGN:TRX:PASS,SOL:PASS,APT:PASS,SUI:PASS`

The temporary probe was removed after this check and the normal app entrypoint was rebuilt.

## Notes

- First `pod install` failed because `Podfile.lock` had stale Firebase 12.12.0/FaceSDK 7.2.3696 entries while the current Flutter plugins require Firebase 12.9.0/FaceSDK 7.2.3526. The targeted pod update reconciled the lock and updated `TrustWalletCore` to 4.7.0.
- CocoaPods still prints existing xcconfig warnings (`EXCLUDED_ARCHS`, `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES`), but installation completes.
