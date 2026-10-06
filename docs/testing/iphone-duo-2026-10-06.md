# iPhone Duo adaptation — 2026-10-06

## Implemented

- iOS follows scene dimensions and supports portrait and landscape. Layout no longer infers an iPhone/iPad from the first platform view.
- The native Flutter view publishes active UIKit reserved regions using the iOS 27.1 SDK. The app avoids an active fold, adjusts safe areas and keyboard insets to its chosen pane, and ignores stale geometry during display transitions.
- Navigator, selected home tab, wallet input, and selected Chat conversation remain mounted across layout breakpoints. Wide scenes use side navigation and Chat columns; compact scenes keep the selected conversation.
- Legacy controls retain continuous phone-scale sizing at the 600-point breakpoint and in landscape. Wallet creation/import forms have a readable maximum width.
- Story taps use local coordinates, including when a pane moves away from the screen origin. Screen-capture detection reads the current scene's screen.
- Release builds require the iOS 27.1 SDK or newer.

Chat is pinned in `pubspec.yaml` and the generated lockfile to `34018481ea33617c6c7bd22e9d52d3473accd6f9`. The changes are on `n42_chat` branch `fix/iphone-duo-layout-20261006`; the sibling checkout and cache mirror were not edited.

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
