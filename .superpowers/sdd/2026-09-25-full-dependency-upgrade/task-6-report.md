# Task 6 — Apple dependency upgrade report

## Scope and environment

Completed in the isolated dependency-upgrade worktree on 2026-09-25 with Flutter 3.44.8, Dart 3.12.2, Xcode 27.0, and CocoaPods 1.17.0. The Podfile deployment targets remain iOS 16.0 and macOS 10.15. SQLCipher linker hooks, four Google ML Kit text script subspecs, and the local audioplayers iOS 27 and WebView `NSNull` patches remain in place. No external Chat checkout or cache mirror was changed.

The source checkout's ignored `ios/Runner/GoogleService-Info.plist` was copied to the same ignored worktree path with mode 0600. No plist contents were logged or staged. macOS has no local Firebase plist.

## Resolved graph

| Component | Previous | Final | Reason |
| --- | --- | --- | --- |
| iOS Firebase | 12.15.0 | 12.19.0 | FlutterFire `firebase_core` 4.15.0 native pin |
| macOS Firebase | 12.9.0 | 12.19.0 | Same FlutterFire graph; within macOS 10.15 CocoaPods lane |
| TrustWalletCore | 4.7.0 | 4.8.4 | Latest stable compatible iOS pod; matches Android 4.8.4 |
| Web3Auth | 11.1.0 | 12.0.1 | `web3auth_flutter` 7.0.0 podspec requires `~> 12.0.1` |
| WebRTC-SDK, macOS | 144.7559.01 | 150.7871.01 | Matches iOS/plugin requirement |
| SQLCipher | 4.10.0 | 4.10.0 | Current native plugin requirement and verified iOS link |
| GoogleSignIn | 9.2.0 | 9.2.0 | Flutter plugin requires `~> 9.0`; 10.0 needs macOS 12 |
| GoogleMLKit text script pods | 9.0.0 | 9.0.0 | Current published stable version |

`pod update --no-repo-update` resolved all other compatible pod updates in both locks. Some newest registry versions are blocked by plugin constraints, including iOS MediaPipeTasksGenAI 0.10.24 (exact plugin pin), TensorFlowLite nightly artifacts, and GoogleSignIn 9.x. `pod outdated` succeeded separately for both platforms and showed the candidates. The first iOS `pod update --repo-update` hit CocoaPods CDN `HTTP2 framing layer` error; a retry against the successfully refreshed local specs cache installed the graph.

The iOS Xcode project contained one Firebase Swift package reference with a 10.27.0 minimum but no `XCSwiftPackageProductDependency` in any target. Its workspace and nested project `Package.resolved` files disagreed on Firebase 10.28.1 versus 10.28.0. That unused reference and both obsolete lock files were removed. Workspace `xcodebuild -resolvePackageDependencies` now reports `resolved source packages:` empty with exit 0, matching the manifest. FlutterFire's Firebase 12.19.0 remains in CocoaPods.

The upgraded Flutter graph no longer resolves `qr_code_scanner_plus` as an iOS pod. Runner's three configurations retained hardcoded framework search, header search, and link entries for it. The clean iOS build exposed `Framework 'qr_code_scanner_plus' not found`; these nine stale entries were removed. Comparison of Runner's hardcoded framework flags with the current Pods release xcconfig found no other removed pod framework names. `flutter clean` cleared preceding module definition errors for the new Swift-backed `firebase_core` and `pdfx` plugin classes; no generated registrant or cache source was edited.

## Commands and evidence

Every numbered command has a separate gzip log in `docs/testing/dependency-upgrade-final-2026-09-25/apple/`; logs include their final `EXIT_CODE`. Initial failures were retained.

| Log | Command | Exit | Result |
| --- | --- | ---: | --- |
| 01 | `flutter pub get` | 0 | Flutter graph resolves |
| 02 | `(cd ios && pod outdated)` | 0 | iOS metadata/local podspec available |
| 03 | `(cd macos && pod outdated)` | 0 | macOS metadata/local podspec available |
| 04 | `(cd ios && pod update --repo-update)` | 1 | CocoaPods CDN HTTP/2 framing error |
| 05 | `(cd ios && pod update --no-repo-update)` | 0 | 69 Podfile dependencies, 138 pods |
| 06 | `(cd macos && pod update --no-repo-update)` | 0 | 44 Podfile dependencies, 68 pods |
| 07 | `xcodebuild -resolvePackageDependencies -workspace ios/Runner.xcworkspace -scheme Runner` | 0 | Zero Swift packages; manifests match |
| 08 | `flutter build ios --no-codesign --release` | 1 | Swift module definition errors in generated registrant |
| 09 | `xcodebuild -project macos/Runner.xcodeproj -scheme Runner -configuration Release CODE_SIGNING_ALLOWED=NO build` | 65 | Xcode 27 rejects macOS 10.15; Flutter file lists absent |
| 10 | `flutter clean` | 0 | Cleared stale Xcode/Flutter build state |
| 11 | `flutter build ios --no-codesign --release` | 1 | Stale QR scanner framework link exposed |
| 12 | `flutter build ios --no-codesign --release` | 0 | `build/ios/iphoneos/Runner.app` built |
| 13 | `xcrun nm -gU` on Runner | 0 | `_sqlite3_key` is a defined `T` symbol |
| 14 | `xcrun nm -m` and `strings -a` on Runner | 0 | Local `_sqlcipher_exportFunc` / `_sqlcipher_export_init`; `sqlcipher_export` and `cipher_version` strings |
| 15 | `(cd ios && pod install --deployment --no-repo-update)` | 0 | iOS lock reproducible |
| 16 | `(cd macos && pod install --deployment --no-repo-update)` | 0 | macOS lock reproducible |

The generated iOS Pods-Runner Release xcconfig has no system sqlite3 or ordinary SQLCipher framework link flag; the Runner project retains `-Wl,-u,_sqlite3_key` and `-framework SQLCipher`. The built binary's `_sqlite3_key` is defined, which is the decisive static check against silently using Apple's unencrypted sqlite3. This is a no-sign compile and link check, not a device encryption runtime test.

## Remaining limit

Xcode 27 reports that its supported macOS deployment range is 12.0–27.0.x, so it cannot build the repository's macOS 10.15 target. The same direct project command also reports missing generated Flutter input/output file lists. Pod resolution and deployment mode installation succeed, but no macOS compile or runtime result is claimed. Raising the deployment target or changing the required Xcode version is outside this task's authorized constraints.
