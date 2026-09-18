# iOS WebRTC / ML Kit build troubleshooting

## Project configuration

The validated build environment uses Flutter 3.44.8 (revision 058e0af2c2),
Dart 3.12.2, Xcode 27.0 (27A266a), and CocoaPods 1.17.0.
The project now sets `flutter.config.enable-swift-package-manager: false`
in `pubspec.yaml`. Previously the release machine supplied this setting in
its user-wide Flutter configuration, so another developer could resolve a
different native dependency graph from the same checkout.

The locked `flutter_webrtc` package still includes an iOS podspec. Both it
and the LiveKit native dependency use `WebRTC-SDK 144.7559.01` in
`ios/Podfile.lock`. ML Kit also resolves through CocoaPods. Do not manually
add a second WebRTC package in Xcode or remove ML Kit to repair this setup.
The existing Firebase Swift package reference is separate from Flutter
plugin integration; do not remove unrelated packages.

This setting preserves the currently validated dependency graph. A future
Flutter/SwiftPM migration needs a separate compatibility check.
See [Flutter's project-level configuration](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers#how-to-turn-off-swift-package-manager).

## Rebuild on a colleague's Mac

Start from the latest checkout and retain both `pubspec.lock` and
`ios/Podfile.lock`. Use the Flutter version above. Close Xcode, then run
from the repository root:

```sh
flutter clean
flutter pub get
(cd ios && pod install --deployment)
open ios/Runner.xcworkspace
```

Open the workspace, select Runner and a physical iPhone, and use Debug.
Do not open `Runner.xcodeproj` directly. The configured ML Kit simulator
architecture workaround is separate from a physical-device dependency
conflict; use a device first when reproducing this issue.

For a compile-only Debug check, without signing or installing:

```sh
flutter build ios --debug --no-codesign --no-pub --dart-define-from-file=.env
```

Use an authorized local `.env`; never commit or share its contents.
For signed archives and uploads follow [the TestFlight runbook](TESTFLIGHT_RUNBOOK.md).

If this checkout was previously auto-migrated to Flutter SwiftPM, disabling
the feature does not automatically remove its generated Xcode integration.
Review local changes to `ios/Runner.xcodeproj/project.pbxproj` and the Runner
scheme against Git. Follow Flutter's linked removal instructions for
`FlutterGeneratedPluginSwiftPackage` only, preserving signing and unrelated
native changes. Do not delete all Swift packages or discard the whole project.

If it still fails, capture the **first** error and about 20 surrounding lines,
Flutter/Xcode versions, and whether the destination is a device or simulator.
Strip credentials and personal paths. An identical Archive/Debug error is
not sufficient by itself to identify which native dependency failed.

## Verification

- `flutter pub get` accepts the project-level flag without changing the lockfile.
- `pod install --deployment` succeeds with 70 dependencies / 133 pods.
- Generated Flutter plugin metadata reports SwiftPM disabled for iOS/macOS
  and includes WebRTC and all five ML Kit plugins.
- iPhone Debug compile succeeds with `--no-codesign` (132.8 seconds for Xcode).
  This verifies compilation/linking, not device launch or signing.
- iPhone Release compile also succeeds with `--no-codesign` (231.7 seconds for Xcode).
  These checks do not create or upload a newly signed TestFlight archive.
- The colleague's exact failure remains unconfirmed until its first error is supplied.
