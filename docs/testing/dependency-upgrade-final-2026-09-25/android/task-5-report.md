# Task 5 — Android dependency upgrade (2026-09-25)

## Result

**Done.** `flutter build apk --debug` succeeded on Flutter 3.44.8 / Dart 3.12.2 with Android compile/target SDK 36 and Java 21. The mining Android library assembled and its one existing unit test passed from the app's Gradle project. `:app:testDebugUnitTest` completed with `NO-SOURCE` (zero native app test cases). The final app and standalone mining dependency reports resolve.

The debug APK is `build/app/outputs/flutter-apk/app-debug.apk`: 790,145,616 bytes; SHA-256 `2f6bf02cb6a617137e45f9c8d6f7d4412faba74a3bf1b318d7750ff5f84ab1d3`.

## Toolchain and direct versions

| Area | Before | Final | Reason |
| --- | --- | --- | --- |
| Gradle app / mining / example | 8.14 / 9.0 milestone 1 / 8.12 | 8.14.4 | Newest Gradle 8 patch; Gradle 9 incompatibility below |
| Android Gradle plugin | 8.11.1 (example 8.9.1) | 8.13.2 | Latest AGP 8 patch, supports API 36 and Gradle 8.13+ |
| Kotlin Gradle plugin | 2.2.20 (example 2.1.0) | 2.4.20 | Current stable, compatible with Gradle 8.14.4 and AGP 8.13.2 per JetBrains matrix |
| Foojay resolver | 0.8.0 | 1.0.0 | Current stable |
| Google Services plugin | 4.4.3 | 4.5.0 | Current stable |
| desugar_jdk_libs | 2.1.4 | 2.1.5 | Current stable |
| TrustWallet wallet-core | 4.7.0 | 4.8.4 | Newest release observed in authenticated GitHub Packages Maven metadata; app compiles |
| AndroidX appcompat | 1.6.1 | 1.8.0 | Current stable |
| Material Components | 1.9.0 | 1.14.0 | Current stable |
| OkHttp | 4.11.0 (resolved 5.2.1) | 5.4.0 | Newest tested artifact whose AAR metadata allows compile SDK 36; 5.5.0 requires 37 |
| Credentials / Play Services Auth | 1.5.0 (resolved 1.6.0) | 1.6.0 | Current stable |
| MediaPipe tasks-genai | 0.10.22 (resolved 0.10.29) | 0.10.35 | Current stable |
| WebRTC Android | 144.7559.01 (resolved 150.7871.01) | 150.7871.01 | Current stable |
| kotlinx-coroutines-android | 1.8.1 (resolved 1.11.0) | 1.11.0 | Current stable |
| ML Kit four extra text scripts | 16.0.1 | 16.0.1 | Newest published |
| ML Kit segmentation-selfie | 16.0.0-beta6 | 16.0.0-beta6 | Newest published; no stable release |

Direct app runtime resolution is in `app-upgraded-dependencies.log.gz`; baseline is in `app-baseline-dependencies.log.gz`. The independent mining graph is in `mining-baseline-dependencies.log.gz` and `mining-upgraded-dependencies.log.gz`. The direct app graph excludes the separate `coreLibraryDesugaring` configuration; its version is declared in `android/app/build.gradle.kts` and was used in the successful APK.

Sources: [AGP 8.13 release notes](https://developer.android.com/build/releases/agp-8-13-0-release-notes), [Gradle 8.14.4 release notes](https://docs.gradle.org/8.14.4/release-notes.html), [Kotlin compatibility table](https://kotlinlang.org/docs/gradle-configure-project.html), [Flutter's AGP 9 migration guidance](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin), [video_thumbnail versions](https://pub.dev/packages/video_thumbnail/versions), [OkHttp Maven artifact](https://repo.maven.apache.org/maven2/com/squareup/okhttp3/okhttp-android/5.4.0/okhttp-android-5.4.0.aar). Wallet-core 4.8.4 was read from authenticated `https://maven.pkg.github.com/trustwallet/wallet-core/com/trustwallet/wallet-core/maven-metadata.xml` without storing credentials.

## Migration and compatibility decisions

- Tried AGP 9.4.1, Gradle 9.8.0, Kotlin 2.4.20 with Flutter's documented legacy Kotlin/DSL flags. The app graph failed while evaluating `video_thumbnail` 0.5.6 because its Android `build.gradle` invokes `jcenter()` at lines 7 and 17, removed by Gradle 9. Pub.dev confirms 0.5.6 is the newest stable package. The production `n42_chat` Git checkout resolved by `.dart_tool/package_config.json` is SHA `3cc19c12a7c9bbf2031270acca8e3922730b55a5`; its `pubspec.yaml:96` declares `video_thumbnail: ^0.5.3`, and its chat/moment code imports it. This is the current Gradle/AGP cap. No pub cache or external repository source was edited.
- AGP 8.13.2 exposed native library projects pinned below the AndroidX AAR compile SDK floor: `twitter_login` 4.4.2 pins API 31 and `video_thumbnail` 0.5.6 pins API 33. The existing `gradle.beforeProject`/`afterEvaluate` library hook now raises compile SDK values below 36 to 36, preserving values above 36 for explicit diagnosis. Target and minimum SDKs remain unchanged. Both targeted `checkDebugAarMetadata` tasks succeeded, followed by the full APK.
- AGP 9 and Kotlin 2.4's deprecated `kotlinOptions.jvmTarget` assignment initially failed script compilation. The app now sets Kotlin's compiler target through `compilerOptions` and explicitly enables generated `resValues`, needed by its existing social auth resources under newer AGP.
- Removed a tracked machine-specific `org.gradle.java.home` path that did not exist on this machine. Flutter's persistent `jdk-dir` selects complete Homebrew OpenJDK 21.0.10 for `flutter build`; the successful Gradle unit command used the same `JAVA_HOME`. GoLand JBR 21.0.6 lacks `bin/jlink`, so a direct Gradle test run with that JBR failed at AGP's JdkImageTransform. This was a local JDK distribution issue, not an Android dependency failure.
- Existing mining unit source imported Mockito and `kotlin.test` but the standalone plugin build script declared neither. Added `kotlin-test-junit:2.4.20` and Mockito 5.24.0 as test dependencies. Standalone `plugins/flutter_mining/android` compilation lacks the Flutter embedding that Flutter injects when loaded by the app; the app-integrated mining library build and test are the validated path. No local AAR bridge, storage, permission, scanner, wallet handler, or product API code changed.

The first AGP 9 failure log and the first two APK failure logs were overwritten during iteration. Their failure causes above are supported by the current upstream `video_thumbnail` script and OkHttp AAR metadata, and by the retained third APK failure log for `video_thumbnail` API 33. They are **not** represented as passing runs. Subsequent command output is retained by numbered compressed files.

## Web3Auth native authentication contract check

The resolved `web3auth_flutter` is 7.0.0. Its Android Gradle script declares `com.github.Web3Auth:web3auth-android-sdk:10.0.1`, min SDK 26, and JitPack; that native SDK was included in the successful app graph and APK. Its Android manifest contributes no redirect filter. The plugin receives `Activity.onNewIntent` and passes the URI to `web3auth.setResultUrl`; the app's `MainActivity` is `singleTop` and already accepts `n42`, `n42app`, `n42wallet`, `astraapp`, and `n42id` schemes. The Dart `Web3AuthMpcProvider` passes `redirectUrl` into `Web3AuthOptions`; no construction site was found in current app code, so a runtime login redirect was not exercised. Any configured redirect URI must use an app registered scheme. The package's iOS podspec requires `Web3Auth ~> 12.0.1`; the checked-in iOS lock still records 11.1.0 pending the separate iOS upgrade task.

## Verification evidence

| Command | Result | Retained evidence |
| --- | --- | --- |
| `flutter build apk --debug` | Passed; APK hash and size above | `flutter-build-debug-attempt-4.log.gz` |
| `./gradlew :app:dependencies --configuration debugRuntimeClasspath` | Passed; final graph | `app-upgraded-dependencies.log.gz` |
| `plugins/flutter_mining/android/gradlew dependencies --configuration debugRuntimeClasspath` | Passed; final standalone graph | `mining-upgraded-dependencies.log.gz` |
| `./gradlew :twitter_login:checkDebugAarMetadata :video_thumbnail:checkDebugAarMetadata` | Passed | `legacy-plugin-aar-check.log.gz` |
| `./gradlew :flutter_mining:assembleDebug :flutter_mining:testDebugUnitTest :app:testDebugUnitTest` with complete OpenJDK 21 | Passed; mining XML: 1 test, 0 failures; app task `NO-SOURCE` | `android-unit-and-mining-attempt-3.log.gz` |
| Standalone mining `assembleDebug testDebugUnitTest` | Failed from missing Flutter embedding classpath outside a Flutter app build; root-integrated build above passed | `mining-build-test.log.gz` |

The output also retains `android-unit-and-mining-attempt-1.log.gz` (undeclared test imports) and `attempt-2.log.gz` (GoLand JBR lacking jlink), plus `flutter-build-debug-attempt-3.log.gz` (video_thumbnail API 33). Credentials and ignored Firebase JSON were copied locally for resolution and are absent from this commit.

No Android device or instrumentation run was available. The APK and Kotlin/Java compilation verify the native permission, scanner, wallet-core, and mining integration contracts at build time; those flows still need runtime coverage on a device. The debug build does not exercise release shrinking with AGP 8.13.2 and Kotlin 2.4.20.
