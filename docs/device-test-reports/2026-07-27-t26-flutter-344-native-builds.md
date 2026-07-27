# T26 Flutter 3.44.8 native build and dependency validation - 2026-07-27

## Scope

- Source under test: `codex/flutter-3.44.8-validation@44be3ee2`
- Validation host: macOS, America/Toronto
- Flutter: `3.44.8` (`058e0af2c2`)
- Dart: `3.12.2`
- Xcode: `26.6 (17F113)`
- Android Java: OpenJDK `21.0.10`
- App version: `2.4.8 (2026072602)`
- Physical iPhone: `1046FC66-1844-5F30-88D0-7140EBF4A41C`

This report distinguishes build/static evidence from physical-device evidence.
`PASS` is not used for a device case that was not actually executed.

## Results

| Item | Result | Evidence |
|---|---:|---|
| A1 Android WalletCore 4.7.0 authentication | PASS | `flutter build apk --release` passed dependency resolution with no HTTP 401. A separate Gradle `dependencyInsight` resolved both `com.trustwallet:wallet-core:4.7.0` and `wallet-core-proto:4.7.0`, ending with `BUILD SUCCESSFUL`. The Mac credential is valid; the expired Windows PAT is not a blocker on this host. |
| A2 Android Flutter 3.44.8 release build | PASS | `flutter build apk --release` completed `assembleRelease` in 299.4 seconds and produced a signed 735,285,533-byte APK. |
| A3 iOS Flutter 3.44.8 App Store IPA build | PASS | `./scripts/build_ipa.sh --no-bump` completed archive, framework repair, and second App Store export. The archive was 507.0 MB and the final IPA was 124,416,863 bytes. |
| A4 Runner/extension version consistency | PASS | The final IPA was unpacked and inspected. `Runner.app` and `N42Extension.appex` both report `CFBundleShortVersionString=2.4.8` and `CFBundleVersion=2026072602`. Deep strict code-sign verification passed. |
| B1 wallet/chat drag destination | NOT RUN / STATIC PASS | Flutter 3.44.8 source adjusts `newIndex` before invoking `onReorderItem`; both call sites and `reorderChain` omit the old manual decrement. The second iPhone run entered the test body, but failed during startup before either drag surface was exercised. |
| B2 face unlock after Regula removal | NOT RUN / BUILD PASS | Release artifacts build with `local_auth`; the IPA contains `local_auth_darwin_privacy.bundle`. No `com.regula`, `FaceSDK`, or `flutter_face_api` reference remains in app/native dependency sources. The second run failed before a real Face ID prompt. |
| B3 BTC send/receive after `bitcoin_base` removal | NOT RUN / BUILD PASS | Android and iOS release builds compile the WalletCore/trustdart BTC path, and no `bitcoin_base` dependency remains. The second run failed before BTC Send/Receive; no transaction was broadcast. |
| B4 scanner and file picker regression | NOT RUN / BUILD PASS | `qr_code_scanner_plus` and file picker native integration compile into both release builds. The IPA contains `file_picker_ios_privacy.bundle`; all eight Dart call sites use static `FilePicker.pickFiles`. The second run failed before repeated scanner entry/exit or picker open/cancel. |
| B5 19-chain Cosmos live balances | DEVICE FAIL / UNIT PASS | Registry tests discover exactly 19 configured Cosmos chains and route each to its own REST service and native denom. On the iPhone, startup wallet logs reported native address-generation failure for INJ, OSMO, TIA, DYDX, and NTRN, so those chains could not proceed to a valid live balance read. |

The iPhone initially appeared as `unavailable`, then recovered after restarting
the local CoreDevice services. Device pairing, unlock state, Release
installation, and Release launch passed. macOS Local Network privacy initially
denied the wireless Flutter VM-service connection. After the permission was
enabled and USB connected, a second run entered the test body; its separate
failure and the remaining B-item status are recorded below.

## Commands and build evidence

### A1 WalletCore dependency resolution

The standalone Gradle command must use the same Java 21 selected by Flutter.
The shell default was Java 25.0.1 and failed before project evaluation, so that
attempt is not evidence about WalletCore authentication.

```sh
cd android
JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  ./gradlew :app:dependencyInsight \
  --dependency com.trustwallet:wallet-core \
  --configuration releaseRuntimeClasspath
```

Relevant result:

```text
com.trustwallet:wallet-core:4.7.0
\--- releaseRuntimeClasspath

com.trustwallet:wallet-core-proto:4.7.0
\--- com.trustwallet:wallet-core:4.7.0

BUILD SUCCESSFUL in 17s
```

This command and the full APK build both accessed the authenticated GitHub
Packages dependency without a 401. No PAT value is recorded in this report.

### A2 Android release APK

```sh
flutter build apk --release
```

Result:

```text
Running Gradle task 'assembleRelease'... 299.4s
Built build/app/outputs/flutter-apk/app-release.apk (735.3MB)
```

Artifact verification:

```text
package: ai.n42.www
versionName: 2.4.8
versionCode: 2026072602
APK Signature Scheme v2: true
signers: 1
SHA-256:
ce79a3a86ad76f37e56b5a90e7a81824e638d949a1d9e5344a414fe45bfe5017
size: 735285533 bytes
```

Flutter printed forward-looking compatibility warnings for Gradle 8.13.0,
AGP 8.9.1, and Kotlin 2.1.0. They did not fail this build and are not the
WalletCore 401.

### A3 iOS App Store IPA

```sh
./scripts/build_ipa.sh --no-bump
```

Result:

```text
Xcode archive done. 257.1s
Built build/ios/archive/Runner.xcarchive (507.0MB)
Built IPA to build/ios/ipa (124.8MB)
Exported Runner to: build/ios/ipa
App Store Version: 2.4.8  Build: 2026072602
```

`scripts/build_ipa.sh` has `set -e` and no longer contains `|| true` around
`flutter build ipa`. A failed Flutter archive now terminates the script before
framework repair/export; this is intentional.

Final IPA:

```text
path: build/ios/ipa/N42Wallet.ipa
SHA-256:
80bdec1da0a4562714f33ca16d286c35d9942861e4d50b5e877913adae9bf4fc
size: 124416863 bytes
Runner executable: Mach-O 64-bit arm64
N42Extension executable: Mach-O 64-bit arm64
codesign --verify --deep --strict: PASS
```

### A4 bundle versions

Values read directly from the exported IPA:

```text
Payload/Runner.app/Info.plist:
  CFBundleShortVersionString = 2.4.8
  CFBundleVersion = 2026072602

Payload/Runner.app/PlugIns/N42Extension.appex/Info.plist:
  CFBundleShortVersionString = 2.4.8
  CFBundleVersion = 2026072602
```

## PBX build-version conclusion

Do **not** simply delete all `FLUTTER_BUILD_NAME` and
`FLUTTER_BUILD_NUMBER` assignments yet.

- Runner Debug/Release/Profile configurations have a base xcconfig.
  `Debug.xcconfig` and `Release.xcconfig` include `Generated.xcconfig`, and
  `xcodebuild -showBuildSettings` resolves the generated Flutter version.
- N42Extension's three build configurations currently have no
  `baseConfigurationReference`. Its Info.plist uses the Flutter variables, so
  deleting the PBX assignments without first wiring an xcconfig into the
  extension would leave those values undefined.
- The current Archive proves that the synchronized PBX values work; it does not
  prove that the extension can consume `Generated.xcconfig` after deleting
  them.

A later cleanup can add a dedicated extension xcconfig (including Flutter's
generated values) and then remove the duplicated PBX assignments. That change
must be followed by another Archive and the same IPA-level A4 inspection.

## Physical iPhone retry

Retry window: 2026-07-27 04:27-04:47 EDT.

1. `xcrun devicectl list devices` initially showed the paired iPhone as
   `unavailable`, although the user had unlocked it.
2. Restarting the current user's `CoreDeviceService` and
   `CoreDeviceDDIUpdaterService` restored the local-network tunnel. Flutter then
   discovered physical device `00008150-000E2469149A401C`, iOS 27.0.
3. `devicectl device info lockState` reported `passcodeRequired: false` and
   `unlockedSinceBoot: true`.
4. A fresh current-source `flutter build ios --release` passed. The resulting
   development-signed `Runner.app` installed and launched successfully.
   `devicectl` reported N42Wallet `2.4.8 (2026072602)`, and both Runner and
   N42Extension processes were alive.
5. Direct `flutter test ... -d <UDID>` stopped before running tests because
   wireless iOS requires a published VM-service port.
6. The documented wireless route was then used:

   ```sh
   flutter drive --no-pub \
     --driver=test_driver/integration_test.dart \
     --target=integration_test/device_full_flow_test.dart \
     -d 00008150-000E2469149A401C \
     --publish-port
   ```

   Xcode built the Debug test app in 205.6 seconds and installed/launched it.
   Flutter then failed before executing the test body:

   ```text
   Flutter could not access the local network.
   SocketException: Send failed (OS Error: No route to host, errno = 65),
   address = 0.0.0.0, port = 5353
   ```

   The required host-side permission is macOS **System Settings → Privacy &
   Security → Local Network** for the terminal/Codex process. Unlocking the
   iPhone does not grant this Mac permission.
7. After the failed Driver attempt, a clean Release was rebuilt, reinstalled,
   and launched. No Debug/test-define build was left on the phone.

## Physical iPhone retry after Local Network permission and USB

Retry window: 2026-07-27 04:52-04:58 EDT.

The iPhone was connected over a wired CoreDevice tunnel and was unlocked:

```text
transport: wired
passcodeRequired: false
unlockedSinceBoot: true
```

This command built, installed, attached to, and entered the real test body:

```sh
flutter test integration_test/device_full_flow_test.dart \
  -d 00008150-000E2469149A401C --no-pub
```

The Local Network warning was no longer fatal. The runner printed both
`DEVICE_STEP home: navigate primary tabs` and
`DEVICE_STEP market: tabs and search input`, proving that device attachment and
test execution worked.

The test nevertheless failed at startup because application initialization
replaced `FlutterError.onError` while `VoiceService` eagerly constructed an
`audioplayers` `AudioPlayer`. Flutter's test binding reported:

```text
A test overrode FlutterError.onError but either failed to return it to its
original state, or had uncaught errors that it could not handle.

AudioPlayer._create
VoiceService.new
configureChatDependencies
```

Final result after stopping the already-failed run:

```text
01:23 +0 -1: Some tests failed.
DEVICE-01 ... [E]
(tearDownAll) - did not complete [E]
```

This is no longer a Mac permission, USB, pairing, or unlock blocker. It is a
test-harness/application-initialization failure. DEVICE-01 never reached its
wallet action or drawer stages, so it provides no physical PASS evidence for
B1-B4.

During the same run, wallet initialization logged failed native address
generation for INJ, OSMO, TIA, DYDX, and NTRN. B5 is therefore recorded as a
device failure for those chains, not as an automation-only block.

After the failed test, `flutter build ios --release --no-pub` completed in
216.3 seconds. The resulting current-source Release app was installed and
launched over the wired tunnel; device inspection confirmed N42Wallet
`2.4.8 (2026072602)`. No Debug test build was left installed.

## Device follow-up

After fixing the DEVICE-01 `FlutterError.onError`/audio initialization failure:

1. B1: drag the first chain downward by two rows and back; repeat in Chat Quick
   Replies. Record the before/after labels to prove there is no one-row offset.
2. B2: toggle wallet Face ID and complete one successful native prompt.
3. B3: open BTC Receive and BTC Send, verify the address/fee form, and stop
   before broadcast unless a funded disposable wallet is approved.
4. B4: enter and exit the scanner at least three times, then open and cancel a
   file picker from one migrated call site.
5. B5: refresh configured Cosmos-family balances and record per-chain success
   without logging full wallet addresses.
