# Apple dependency upgrade — 2026-09-25

Environment: Flutter 3.44.8, Dart 3.12.2, Xcode 27.0, CocoaPods 1.17.0. iOS remains 16.0 and macOS remains 10.15.

| Dependency | iOS resolved | macOS resolved | Constraint |
| --- | --- | --- | --- |
| Firebase Apple SDK | 12.19.0 | 12.19.0 | FlutterFire 4.15.0; macOS 10.15 retains CocoaPods 12.x |
| Google ML Kit text scripts | 9.0.0 | — | Four extra iOS subspecs remain in Podfile |
| TrustWalletCore | 4.8.4 | — | Direct iOS pin, aligned with Android wallet-core 4.8.4 |
| Web3Auth | 12.0.1 | — | `web3auth_flutter` 7.0.0 requires `~> 12.0.1` |
| WebRTC-SDK | 150.7871.01 | 150.7871.01 | Plugin/native dependency graph |
| SQLCipher | 4.10.0 | 4.10.0 | Native plugin graph; iOS anchor retained |
| GoogleSignIn | 9.2.0 | 9.2.0 | Current plugin requires `~> 9.0`; 10.0 needs macOS 12 |

Both `pod install --deployment --no-repo-update` checks pass (iOS: 69 Podfile dependencies, 138 pods; macOS: 44 dependencies, 68 pods). `xcodebuild -resolvePackageDependencies` succeeds with zero packages after removing an unused Firebase 10 Swift package reference and its two inconsistent resolution files. Firebase remains supplied by CocoaPods.

`flutter build ios --no-codesign --release` passes. The final Runner binary defines `_sqlite3_key` and contains SQLCipher's local export functions plus `sqlcipher_export` and `cipher_version` strings. Earlier failed attempts are preserved: a CocoaPods CDN HTTP/2 metadata error, stale Swift module state cleared by `flutter clean`, and a stale hardcoded `qr_code_scanner_plus` framework link removed after the Flutter graph dropped that pod.

The requested macOS `xcodebuild` fails before compilation: Xcode 27 accepts deployment targets 12.0–27.0, while this project remains at 10.15. Direct project build also reports missing ephemeral Flutter input/output file lists. The 10.15 target was retained. The ignored iOS Firebase plist was copied locally from the existing checkout for the no-sign build and was not staged.

All numbered command outputs, including failures and final exit codes, are preserved as matching `.log.gz` files here. The full task report is in `.superpowers/sdd/2026-09-25-full-dependency-upgrade/task-6-report.md`.
