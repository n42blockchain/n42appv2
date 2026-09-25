# Full dependency upgrade baseline — 2026-09-25

Captured on branch `codex/dependency-upgrade-20260925` at `dee63931f419ff4d7b038f85dfbe5cf8556a5b9b` before dependency or source upgrades. The worktree was clean before the artifact directory was created; `logs/git-status-at-start.log.gz` therefore shows this new artifact directory as untracked. Full command output is preserved byte-for-byte in gzip-compressed files under `logs/`; structured exit statuses are in `command-status*.json`. Commands that failed are baseline findings, not upgrade regressions.

## Toolchain

| Tool | Local version or state |
| --- | --- |
| Flutter | 3.44.8; Dart 3.12.2 |
| Go | 1.26.5 darwin/arm64 |
| Rust/Cargo | 1.97.1 / 1.97.1 |
| Node/npm | 25.8.1 / 11.11.0 |
| Java | Temurin 25.0.1 |
| CocoaPods | 1.17.0 |
| Xcode | 27.0 (27A266a) |
| Global Gradle | Unavailable (`gradle` not found) |

The toolchain values above are the versions actually active in this checkout. See individual version logs for complete output. CI pins Flutter 3.44.8 and Java 21; local Java 25 differs from CI.

## Dependency graph snapshot

`dependency-snapshot.json` records resolved or locked counts and direct declarations. `android-declarations.txt` records Android and mining plugin declarations and the successful JDK 21 retry log contains the resolved Gradle dependency graph.

- Flutter: 425 resolved entries (root 1, direct 97, dev 17, transitive 310); sources {'root': 1, 'hosted': 412, 'sdk': 8, 'path': 4}. `flutter pub outdated --json` returned 217 entries, including 216 with a newer latest version. Those numbers reflect the active Chat path override.
- `n42_chat`: `pubspec.yaml` declares Git ref `3cc19c12a7c9bbf2031270acca8e3922730b55a5`; the tracked `pubspec_overrides.yaml`, `pubspec.lock`, and `flutter pub deps --json` actually resolve `packages/n42_chat` as `source: path`, version `0.1.0`. The Git SHA is not the active package source in this baseline. `audioplayers_darwin` and `webview_flutter_wkwebview` are also active path overrides.
- iOS CocoaPods: 184 locked pod entries and 70 declared Podfile dependencies. macOS: 95 locked pod entries and 41 declared dependencies. Initial `pod outdated` failed before Flutter podspec install; a subsequent iOS query after the no-code-sign build's pod install succeeded and lists exact candidates in its log. The iOS Swift Package Manager resolution succeeded and listed 13 source packages.
- Android: version declarations and a resolved Gradle graph are captured. The initial `android/gradlew` was absent and global `gradle` is not installed. Flutter generated an ignored wrapper; a process-local JDK 21 override then let `:app:dependencies` pass. The initial APK build fails on invalid local `org.gradle.java.home`; the JDK 21 retry reaches Google Services processing and fails because `android/app/google-services.json` is absent.
- Go module manifest requirements (direct / indirect): `livekit-jwt` 1/63, `loyalty` 3/49, `social-auth` 0/0, `swap` 5/48. Each module update query, test, and vet has a full log. The `loyalty` update query fails while looking up an unavailable upstream repository.
- Rust MLS: 175 locked Cargo packages; direct requirements are preserved verbatim in `dependency-snapshot.json`, with the resolved tree in `logs/cargo-tree.log.gz`.
- Chrome extension: 333 locked npm packages (26 non-dev, 307 dev). Direct production and development requirements are in `dependency-snapshot.json`. There is no `test` script in the baseline package manifest.

## Static analysis and Flutter coverage

- `flutter analyze --no-fatal-infos` exits 1 with 301 total issues and **23 errors**, not the earlier reported 24. All 23 are in the standalone `packages/n42_jmt_verify` package: 3 in `lib/src/blake3_hash.dart`, 20 in `test/jmt_verify_test.dart`. The root Flutter package graph does not include `n42_jmt_verify` or `blake3_dart`, and this package has no local `.dart_tool/package_config.json`; recursive root analysis cannot resolve its imports. The undefined symbols are downstream of those missing imports. The separate package needs dependency resolution and package-scoped analysis during implementation.
- First `flutter test --coverage --concurrency=4` reached 3,882 tests, then stopped making progress after `Too many open files` under the shell soft file descriptor limit of 256. I sent SIGTERM after about 298 seconds. Flutter reported process exit 0 while shutting down, but the log has no normal completion marker and no `coverage/lcov.info`; this run is **incomplete**. Its quality gate exits 1 because the LCOV file does not exist. Three orphaned Dart test subprocesses from this interrupted run were later terminated by their original process group ID; the successful retry had already completed.
- The exact test command was rerun with only the process file descriptor soft limit raised to 4,096. It exited 0 with `+5831: All tests passed!`. The required coverage gate still exits 1: **65,259 / 132,821 lines = 49.133043720496005%**, below the 70% threshold. This is a pre-upgrade coverage deficit.

### Analyzer error inventory

| File | Line:column | Code | Diagnostic |
| --- | ---: | --- | --- |
| `packages/n42_jmt_verify/lib/src/blake3_hash.dart` | 3:8 | `uri_does_not_exist` | Target of URI doesn't exist: 'package:blake3_dart/blake3_dart.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist |
| `packages/n42_jmt_verify/lib/src/blake3_hash.dart` | 13:12 | `undefined_method` | The method 'blake3' isn't defined for the type 'Blake3Hash'. Try correcting the name to the name of an existing method, or defining a method named 'blake3' |
| `packages/n42_jmt_verify/lib/src/blake3_hash.dart` | 22:12 | `undefined_method` | The method 'blake3' isn't defined for the type 'Blake3Hash'. Try correcting the name to the name of an existing method, or defining a method named 'blake3' |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 3:8 | `uri_does_not_exist` | Target of URI doesn't exist: 'package:n42_jmt_verify/n42_jmt_verify.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 13:14 | `undefined_identifier` | Undefined name 'Blake3Hash'. Try correcting the name to one that is defined, or defining the name |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 18:21 | `undefined_identifier` | Undefined name 'Blake3Hash'. Try correcting the name to one that is defined, or defining the name |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 19:21 | `undefined_identifier` | Undefined name 'Blake3Hash'. Try correcting the name to one that is defined, or defining the name |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 25:17 | `undefined_identifier` | Undefined name 'Blake3Hash'. Try correcting the name to one that is defined, or defining the name |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 26:17 | `undefined_identifier` | Undefined name 'Blake3Hash'. Try correcting the name to one that is defined, or defining the name |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 36:14 | `undefined_identifier` | Undefined name 'Blake3Hash'. Try correcting the name to one that is defined, or defining the name |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 36:48 | `undefined_identifier` | Undefined name 'Blake3Hash'. Try correcting the name to one that is defined, or defining the name |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 42:19 | `undefined_identifier` | Undefined name 'Blake3Hash'. Try correcting the name to one that is defined, or defining the name |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 50:19 | `undefined_identifier` | Undefined name 'Blake3Hash'. Try correcting the name to one that is defined, or defining the name |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 57:14 | `undefined_identifier` | Undefined name 'Blake3Hash'. Try correcting the name to one that is defined, or defining the name |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 58:24 | `undefined_identifier` | Undefined name 'Blake3Hash'. Try correcting the name to one that is defined, or defining the name |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 73:28 | `undefined_identifier` | Undefined name 'Blake3Hash'. Try correcting the name to one that is defined, or defining the name |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 75:21 | `undefined_function` | The function 'JmtProof' isn't defined. Try importing the library that defines 'JmtProof', correcting the name to the name of an existing function, or defining a function named 'JmtProof' |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 90:21 | `undefined_function` | The function 'JmtProof' isn't defined. Try importing the library that defines 'JmtProof', correcting the name to the name of an existing function, or defining a function named 'JmtProof' |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 107:21 | `undefined_function` | The function 'JmtProof' isn't defined. Try importing the library that defines 'JmtProof', correcting the name to the name of an existing function, or defining a function named 'JmtProof' |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 121:21 | `undefined_function` | The function 'JmtProof' isn't defined. Try importing the library that defines 'JmtProof', correcting the name to the name of an existing function, or defining a function named 'JmtProof' |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 133:15 | `undefined_function` | The function 'JmtProof' isn't defined. Try importing the library that defines 'JmtProof', correcting the name to the name of an existing function, or defining a function named 'JmtProof' |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 146:21 | `undefined_function` | The function 'SparseMerkleProof' isn't defined. Try importing the library that defines 'SparseMerkleProof', correcting the name to the name of an existing function, or defining a function named 'SparseMerkleProof' |
| `packages/n42_jmt_verify/test/jmt_verify_test.dart` | 148:15 | `undefined_function` | The function 'SparseMerkleLeaf' isn't defined. Try importing the library that defines 'SparseMerkleLeaf', correcting the name to the name of an existing function, or defining a function named 'SparseMerkleLeaf' |

The machine-readable inventory is in `analyzer-errors.json`; the full analyzer output is in `logs/flutter-analyze.log.gz`.

## Native, Go, Rust, and Chrome findings

- Android: Initial `./gradlew :app:dependencies` exits 127 because `android/gradlew` did not exist at that point. Initial `flutter build apk --debug` exits 1 because `org.gradle.java.home` points to invalid `/Applications/Android Studio.app/Contents/jbr/Contents/Home`. Flutter generated ignored Gradle wrapper files. With process-local `JAVA_HOME` and `GRADLE_OPTS` set to the installed JDK 21, `:app:dependencies` exits 0 and produces the resolved graph in `logs/android-gradle-dependencies-jdk21.log.gz`. The corresponding debug APK build exits 1 at `:app:processDebugGoogleServices` because the local `google-services.json` is absent. No APK was produced.
- Apple: Initial iOS and macOS `pod outdated` both exit 1 because the Flutter or FlutterMacOS podspec has not been fetched. `xcodebuild -resolvePackageDependencies` succeeds. The no-code-sign iOS release build resolved pods and reached `Running Xcode build...`; after more than two minutes without further output it was manually stopped at 273.08 seconds. Its recorded process exit 0 is **not** a build pass. The exact generated changes to `ios/Podfile.lock` and `ios/Runner.xcodeproj/project.pbxproj` were saved in `native-build-generated-changes.patch.gz` and then restored. The post-install iOS `pod outdated` succeeds. `flutter build macos --no-codesign --release` exits 64 because this Flutter command does not support `--no-codesign`; supported `flutter build macos --release` exits 1 because CocoaPods reports its specs repository too old, with an `ffi` extension warning. No signing configuration was fabricated.
- Go: All four `go test ./...` and `go vet ./...` commands pass. `go list -m -u all` succeeds in `livekit-jwt`, `social-auth`, and `swap`; `loyalty` exits 1 because GitHub returns repository not found for `github.com/tyler-smith/go-bip39` while Go loads retractions.
- Rust: `cargo tree`, `cargo test --all-targets`, `cargo check --all-targets`, and `cargo clippy --all-targets -- -D warnings` pass. `cargo fmt --check` exits 1 on existing formatting differences in the MLS source; the complete diff is in its log.
- Chrome: `npm ci`, `npm run type-check`, and `npm run build` pass. `npm outdated --json` exits 1 for outdated packages. `npm audit --omit=dev` exits 1 with two `ws` advisories (one moderate, one high) through `viem`. `npm run lint` exits 127 because the configured `eslint` executable is not installed. No extension test script exists.

## Command ledger

Exit codes are raw process statuses. The `Result` column supersedes a raw 0 where a process was manually interrupted. Each log is complete up to the recorded end or interruption.

| Command | Working directory | Exit | Result | Seconds | Log |
| --- | --- | ---: | --- | ---: | --- |
| `./gradlew :app:dependencies` | `android` | 127 | failure | 0.0 | [android-gradle-dependencies](logs/android-gradle-dependencies.log.gz) |
| `env GRADLE_OPTS=-Dorg.gradle.java.home=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home ./gradlew :app:dependencies` | `android` | 0 | pass | 28.46 | [android-gradle-dependencies-jdk21](logs/android-gradle-dependencies-jdk21.log.gz) |
| `cargo check --all-targets` | `rust/n42_mls` | 0 | pass | 6.12 | [cargo-check-all-targets](logs/cargo-check-all-targets.log.gz) |
| `cargo clippy --all-targets -- -D warnings` | `rust/n42_mls` | 0 | pass | 0.63 | [cargo-clippy-all-targets](logs/cargo-clippy-all-targets.log.gz) |
| `cargo fmt --check` | `rust/n42_mls` | 1 | failure | 0.25 | [cargo-fmt-check](logs/cargo-fmt-check.log.gz) |
| `cargo test --all-targets` | `rust/n42_mls` | 0 | pass | 15.16 | [cargo-test-all-targets](logs/cargo-test-all-targets.log.gz) |
| `cargo tree` | `rust/n42_mls` | 0 | pass | 0.62 | [cargo-tree](logs/cargo-tree.log.gz) |
| `cargo --version` | `.` | 0 | pass | 0.08 | [cargo-version](logs/cargo-version.log.gz) |
| `npm audit --omit=dev` | `chrome-extension` | 1 | failure | 0.57 | [chrome-npm-audit-production](logs/chrome-npm-audit-production.log.gz) |
| `npm run build` | `chrome-extension` | 0 | pass | 4.07 | [chrome-npm-build](logs/chrome-npm-build.log.gz) |
| `npm ci` | `chrome-extension` | 0 | pass | 9.53 | [chrome-npm-ci](logs/chrome-npm-ci.log.gz) |
| `npm run lint` | `chrome-extension` | 127 | failure | 0.3 | [chrome-npm-lint](logs/chrome-npm-lint.log.gz) |
| `npm outdated --json` | `chrome-extension` | 1 | failure | 1.1 | [chrome-npm-outdated-json](logs/chrome-npm-outdated-json.log.gz) |
| `npm run type-check` | `chrome-extension` | 0 | pass | 1.72 | [chrome-npm-type-check](logs/chrome-npm-type-check.log.gz) |
| `dart --version` | `.` | 0 | pass | 0.14 | [dart-version](logs/dart-version.log.gz) |
| `flutter analyze --no-fatal-infos` | `.` | 1 | failure | 25.48 | [flutter-analyze](logs/flutter-analyze.log.gz) |
| `flutter build apk --debug` | `.` | 1 | failure | 2.93 | [flutter-build-apk-debug](logs/flutter-build-apk-debug.log.gz) |
| `env GRADLE_OPTS=-Dorg.gradle.java.home=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home flutter build apk --debug` | `.` | 1 | failure | 50.75 | [flutter-build-apk-debug-jdk21](logs/flutter-build-apk-debug-jdk21.log.gz) |
| `flutter build ios --no-codesign --release` | `.` | 0 | INCOMPLETE: manually interrupted | 273.08 | [flutter-build-ios-release](logs/flutter-build-ios-release.log.gz) |
| `flutter build macos --no-codesign --release` | `.` | 64 | failure | 0.2 | [flutter-build-macos-release](logs/flutter-build-macos-release.log.gz) |
| `flutter build macos --release` | `.` | 1 | failure | 7.62 | [flutter-build-macos-release-supported](logs/flutter-build-macos-release-supported.log.gz) |
| `python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70` | `.` | 1 | failure | 0.08 | [flutter-coverage-gate](logs/flutter-coverage-gate.log.gz) |
| `python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70` | `.` | 1 | failure | 0.24 | [flutter-coverage-gate-fd4096](logs/flutter-coverage-gate-fd4096.log.gz) |
| `flutter pub deps --json` | `.` | 0 | pass | 1.03 | [flutter-pub-deps-json](logs/flutter-pub-deps-json.log.gz) |
| `flutter pub outdated --json` | `.` | 0 | pass | 4.9 | [flutter-pub-outdated-json](logs/flutter-pub-outdated-json.log.gz) |
| `flutter test --coverage --concurrency=4` | `.` | 0 | INCOMPLETE: manually interrupted | 297.83 | [flutter-test-coverage](logs/flutter-test-coverage.log.gz) |
| `flutter test --coverage --concurrency=4` | `.` | 0 | pass | 317.55 | [flutter-test-coverage-fd4096](logs/flutter-test-coverage-fd4096.log.gz) |
| `flutter --version` | `.` | 0 | pass | 0.24 | [flutter-version](logs/flutter-version.log.gz) |
| `git branch --show-current` | `.` | 0 | pass | 0.02 | [git-branch](logs/git-branch.log.gz) |
| `git rev-parse HEAD` | `.` | 0 | pass | 0.02 | [git-head](logs/git-head.log.gz) |
| `git status --short` | `.` | 0 | pass | 0.08 | [git-status-at-start](logs/git-status-at-start.log.gz) |
| `git ls-files pubspec.yaml pubspec.lock pubspec_overrides.yaml` | `.` | 0 | pass | 0.02 | [git-tracked-pubspecs](logs/git-tracked-pubspecs.log.gz) |
| `go list -m -u all` | `backend/livekit-jwt` | 0 | pass | 10.2 | [go-livekit-jwt-outdated](logs/go-livekit-jwt-outdated.log.gz) |
| `go test ./...` | `backend/livekit-jwt` | 0 | pass | 11.49 | [go-livekit-jwt-test](logs/go-livekit-jwt-test.log.gz) |
| `go vet ./...` | `backend/livekit-jwt` | 0 | pass | 0.94 | [go-livekit-jwt-vet](logs/go-livekit-jwt-vet.log.gz) |
| `go list -m -u all` | `backend/loyalty` | 1 | failure | 16.93 | [go-loyalty-outdated](logs/go-loyalty-outdated.log.gz) |
| `go test ./...` | `backend/loyalty` | 0 | pass | 1.7 | [go-loyalty-test](logs/go-loyalty-test.log.gz) |
| `go vet ./...` | `backend/loyalty` | 0 | pass | 0.34 | [go-loyalty-vet](logs/go-loyalty-vet.log.gz) |
| `go list -m -u all` | `backend/social-auth` | 0 | pass | 0.01 | [go-social-auth-outdated](logs/go-social-auth-outdated.log.gz) |
| `go test ./...` | `backend/social-auth` | 0 | pass | 0.73 | [go-social-auth-test](logs/go-social-auth-test.log.gz) |
| `go vet ./...` | `backend/social-auth` | 0 | pass | 0.19 | [go-social-auth-vet](logs/go-social-auth-vet.log.gz) |
| `go list -m -u all` | `backend/swap` | 0 | pass | 10.65 | [go-swap-outdated](logs/go-swap-outdated.log.gz) |
| `go test ./...` | `backend/swap` | 0 | pass | 6.93 | [go-swap-test](logs/go-swap-test.log.gz) |
| `go vet ./...` | `backend/swap` | 0 | pass | 0.39 | [go-swap-vet](logs/go-swap-vet.log.gz) |
| `go version` | `.` | 0 | pass | 0.04 | [go-version](logs/go-version.log.gz) |
| `gradle --version` | `.` | 127 | failure | 0.0 | [gradle-version](logs/gradle-version.log.gz) |
| `pod outdated` | `ios` | 1 | failure | 0.89 | [ios-pod-outdated](logs/ios-pod-outdated.log.gz) |
| `pod outdated` | `ios` | 0 | pass | 41.74 | [ios-pod-outdated-after-install](logs/ios-pod-outdated-after-install.log.gz) |
| `xcodebuild -resolvePackageDependencies -workspace ios/Runner.xcworkspace -scheme Runner` | `.` | 0 | pass | 42.56 | [ios-spm-resolve](logs/ios-spm-resolve.log.gz) |
| `java -version` | `.` | 0 | pass | 0.13 | [java-version](logs/java-version.log.gz) |
| `pod outdated` | `macos` | 1 | failure | 0.47 | [macos-pod-outdated](logs/macos-pod-outdated.log.gz) |
| `node --version` | `.` | 0 | pass | 0.04 | [node-version](logs/node-version.log.gz) |
| `npm --version` | `.` | 0 | pass | 0.18 | [npm-version](logs/npm-version.log.gz) |
| `pod --version` | `.` | 0 | pass | 0.8 | [pod-version](logs/pod-version.log.gz) |
| `rustc --version` | `.` | 0 | pass | 0.12 | [rustc-version](logs/rustc-version.log.gz) |
| `xcodebuild -version` | `.` | 0 | pass | 0.14 | [xcodebuild-version](logs/xcodebuild-version.log.gz) |

## Environment and change control

- No dependency manifest, source file, lockfile, or Chat mirror change is retained by this task. The iOS build generated tracked changes; their patch was captured and those two files were restored. The baseline artifacts are the only files staged for this task (apart from any mandatory commit-hook version bump); an unrelated plan document is modified by another worker and must be excluded from this commit.
- No real signing files, Firebase plist, or credentials were created. The baseline logs describe environment blockers exactly. This baseline establishes failures that subsequent upgrade work must distinguish from new regressions.
