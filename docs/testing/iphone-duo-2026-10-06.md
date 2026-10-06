# iPhone Duo adaptation — 2026-10-06

## Implemented

- iOS follows scene dimensions and supports portrait and landscape. Layout no longer infers an iPhone/iPad from the first platform view.
- The native Flutter view publishes active UIKit reserved regions using the iOS 27.1 SDK. The app avoids an active fold, adjusts safe areas and keyboard insets to its chosen pane, and ignores stale geometry during display transitions.
- Navigator, selected home tab, wallet input, and selected Chat conversation remain mounted across layout breakpoints. Wide scenes use side navigation and Chat columns; compact scenes keep the selected conversation.
- Legacy controls retain continuous phone-scale sizing at the 600-point breakpoint and in landscape. Wallet creation/import forms have a readable maximum width.
- Story taps use local coordinates, including when a pane moves away from the screen origin. Screen-capture detection reads the current scene's screen.
- Release builds require the iOS 27.1 SDK or newer.

The initial adaptation pinned Chat to `34018481ea33617c6c7bd22e9d52d3473accd6f9`; the 2.5.1 follow-up pins `a3da656f92889ec2f6b1bc3de24694d66dffcb4f` in `pubspec.yaml` and the generated lockfile. The changes are on `n42_chat` branch `fix/iphone-duo-layout-20261006`; the sibling checkout and cache mirror were not edited.

## Verification

Toolchain: Flutter 3.47.5 / Dart 3.13.4, Xcode 27.1 RC (`27A9275`), iOS 27.1 SDK.

| Check | Result | Local evidence |
| --- | --- | --- |
| Host adaptation, responsive layout, wallet, import, scan and Live lifecycle tests, final Chat ref | 48 passed | `/tmp/n42-duo-final-behavior.log` |
| Chat responsive/split-layout tests | 21 passed | `/tmp/n42-duo-chat-tests.log` |
| Chat Story and split-layout tests | 8 passed (2 overlap with preceding run) | `/tmp/n42-duo-chat-story-tests.log` |
| Full host test suite | 5449 passed, 3 failed | `/tmp/n42-duo-full-tests.log` |
| Full analysis, final Chat ref | Exit 0; 48 info diagnostics, no errors or warnings | `/tmp/n42-duo-final-ref-analyze.log` |
| Release script shell syntax and native geometry type check | Passed | `bash -n scripts/build_ipa.sh`; `/tmp/n42-duo-geometry-typecheck.log`; native code also compiled in both simulator builds |
| Full host simulator build | Passed, x86_64 | `/tmp/n42-duo-simulator-build.log` |
| Exact-source native layout probe, arm64 simulator | Build, install and launch passed | `/tmp/n42-duo-probe-native-build.log` |

The full suite ran with Chat commit `4b63e8338dc38f56f912d5dd55da2851d963734e`; the final dependency adds the separately tested local Story-coordinate fix and validation note. The 48 host behavior tests and full analysis were repeated after pinning the final commit.

All three wallet-storage failures reproduce on the unchanged host baseline `f29a3cf13e086af44fcc78675c83052f6fcb5743` in an isolated checkout: 13 passed, the same 3 failed (`/tmp/n42-duo-baseline-wallet-tests.log`, exit 1). They concern initial account wallet creation, restored wallet indexes, and watch-only EVM coin configuration. These unrelated behaviors were not changed during layout adaptation.

## Actual Duo simulator observations

Device: dedicated `iPhone Duo`, iOS 27.1, `4DE00B76-6FB2-4D32-9D0F-F327B9F342EF`. A probe copied the host's Dart adaptive viewport and native view classes exactly, without the host's MLKit dependency. The Dart SHA-256 was `4f21b63249377067b75b8b425649a56d7843a2536b6df7c2bdfeb5ac2387f194`; both copies matched the host at verification time.

| Pose | Observed usable viewport |
| --- | --- |
| Closed portrait | 466 × 678 |
| Open landscape | 951 × 669 |
| Partially open book pose | 456 × 669, content avoids division |
| Open portrait | 669 × 951 |
| Partially open tabletop with keyboard | 669 × 456, content above fold and keyboard |
| Closed landscape | 678 × 466 |

The state counter remained `1` through all transitions. After entering `duo` on the screen keyboard, the text remained through tabletop, closed landscape, and reopened portrait transitions. Asymmetric safe areas were observed: right 84 points in landscape and top 82 points in portrait.

Screenshots show the **probe**, not a full wallet app run:

- [Tabletop and keyboard](iphone-duo-20261006/tabletop-keyboard.png)
- [Closed landscape](iphone-duo-20261006/closed-landscape.png)
- [Reopened portrait and keyboard](iphone-duo-20261006/open-keyboard.png)

## Remaining validation boundaries

The full app cannot be installed on this arm64-only Duo simulator: existing Google MLKit/MLImage frameworks provide x86_64 simulator binaries, and the project deliberately excludes arm64 for simulator builds. Installation fails with `IXUserPresentableError` code 4. The probe verifies the native fold bridge and adaptive viewport; it does not verify the complete app or plugin interactions.

Physical Duo verification is still required for camera switching, QR recognition, live calls/video, keyboard input in the full app, and screen-capture protection. Independent simultaneous app windows and the exterior camera accessory mode were not added. Existing single-scene behavior remains in place.

No new TestFlight build containing these adaptation changes was uploaded in this task. The prior accepted 2.5.0 build predates these changes.

## Delivery

The host changes were split into sequential commits, with each pushed to `origin/master` and checked against the remote before the next batch:

- `4fb791ab7`: native scene geometry, adaptive viewport, SDK requirement and reproducible Chat dependency.
- `421a8b774`: page layout/state preservation and behavior regression tests.
- A separate documentation commit contains this record and the three simulator screenshots.

The existing pre-commit hook increments the build suffix on every commit. These delivery commits retain version `2.5.0`; they do not constitute a new TestFlight upload.

## Apple references

- [Adapt your app for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111461/)
- [Reserved regions and flexible layouts](https://developer.apple.com/videos/play/tech-talks/111463/)
- [Camera adaptation](https://developer.apple.com/videos/play/tech-talks/111465/)

## Follow-up: 2.5.1 compatibility fixes

The user confirmed that no physical iPhone Duo is available. Compatibility work continues with SDK builds, real UIKit tests on the Duo simulator, and behavior tests; this does not close physical-camera or complete-app acceptance.

Additional observed problems were fixed:

- Screen protection now checks scene capture immediately when enabled, observes `UITraitSceneCaptureState` changes on iOS 17+, and restores the previous window's content/mask before protecting a newly active window. iOS 16 retains the screen-notification fallback.
- Group-call grids limit column counts to the available pane width and permit scrolling when a short pane cannot display every participant. A resize test reaches the last of nine participants in both 320 × 678 and 669 × 456 scenes.
- One-to-one video-call previews mirror front cameras only, and refresh after a camera switch completes.

The additional Chat fixes are commit `a3da656f92889ec2f6b1bc3de24694d66dffcb4f` on the same dependency branch. The group-call and call-control suites passed 9 tests (`/tmp/n42-duo-call-tests-r3.log`); scoped analysis found no issues (`/tmp/n42-duo-call-analyze.log`).

All 3 native capture-protection tests passed on the actual Duo simulator with iOS 27.1 (`/tmp/n42-duo-protection-probe-tests-r5.log`, exit 0). The probe compiled exact copies of the host handler and host native tests; the handler SHA-256 was `35fd58a3f5daa6919f6bf172be27668bb5364ce34e0585f9c3a19f235379d726`. These tests use real UIKit trait propagation with synthetic capture-state overrides. They verify mask/window behavior, rather than an actual recording or screenshot of the complete wallet application. [Saved native test results](iphone-duo-20261006/native-capture-tests.txt).

The complete arm64 device application built successfully with `flutter build ios --release --no-codesign --dart-define-from-file=.env` (`/tmp/n42-duo-251-device-build.log`, exit 0, Xcode build 609.7 seconds). Mach-O inspection reports platform `IOS`, architecture `arm64`, SDK `27.1`, and deployment minimum `16.0`. This first build was `2.5.1+73010`, before pinning the additional Chat call fixes. It is unsigned and was not installed or uploaded.

With the final Chat dependency, the host's 48 adaptation/behavior tests passed again (`/tmp/n42-duo-251-final-host-tests.log`, exit 0), and the combined Chat layout, responsive, Story, group-call and call-control suites passed 36 tests (`/tmp/n42-duo-251-final-chat-tests.log`, exit 0). Full host analysis exited 0 with 48 informational diagnostics and no errors or warnings (`/tmp/n42-duo-251-final-host-analyze.log`). The native fix, native tests, version 2.5.1 and final Chat pin were committed and pushed as `30d90586e`.

The complete device application was rebuilt after that commit with the final Chat pin (`/tmp/n42-duo-251-final-device-build.log`, exit 0). Embedded metadata confirms `2.5.1+73011`, `arm64`, and `iphoneos27.1`; this is the build containing all follow-up fixes. It remains unsigned and has not been installed or uploaded. [Saved final validation summary](iphone-duo-20261006/final-validation.json). The documentation commit advances the development build suffix through the existing hook; the compiled artifact's identity remains 73011.

Camera discovery was reviewed in the installed `mobile_scanner 7.4.2` and `flutter_webrtc 1.6.2+hotfix.3` native sources: both request wide-angle/ultrawide camera types. This matches Apple's virtual-front-camera discovery guidance. The LiveKit camera switch clears a pinned device ID when changing front/back position. Source inspection supports the selected strategy; it does not prove physical Duo camera switching.

Google's current [iOS ML Kit release table](https://developers.google.com/ml-kit/release-notes) still lists GoogleMLKit 9.0.0 and MLImage 1.0.0-beta8, matching the installed pod graph. No verified newer binary was found to resolve the arm64 simulator limitation. The application has not removed or stubbed OCR, translation, face detection, or segmentation to conceal this limitation.
