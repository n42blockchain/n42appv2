# MLKit CocoaPods simulator compatibility — isolated validation

Branch: fix/mlkit-pods-simulator-20261107. Based on wallet bd80eb1ad and unchanged Chat pin ad7ce8c41d2ad747db966ba1d8ff015f7d9230ef. This supersedes the attempted SwiftPM route for simulator compatibility; that separate experimental branch is not integrated.

Retains original Dart plugins and all five OCR scripts, Firebase, CocoaPods and GTMSessionFetcher 3.5.0. Fifteen local podspecs retain the original Google pod versions/dependency constraints and point to checksum-pinned XCFrameworks repackaged by d-date/google-mlkit-swiftpm 9.0.2. Upstream synthesizes the arm64 simulator slice by Mach-O platform rewriting; this is not an official Google arm64 simulator release. Binary provenance is recorded in the adjacent JSON. Original pod licensing/metadata remains in each specification.

Ten required models are downloaded by scripts/prepare_mlkit_resources.py using fixed release asset SHA-256 values and safe archive paths. Models remain ignored local artifacts. Pod installation verifies they exist and adds each bundle to the main Runner resources phase. Old pod resource declarations are removed because these XCFramework archives omit the model bundles. Existing Objective-C linkage and SQLCipher/Falcon force-link settings remain intact.

First build reached linking but failed because the isolated worktree lacked the ignored GoogleService-Info.plist. Reused the existing local file without printing or committing it. Retry `flutter build ios --simulator --debug --no-pub`: exit 0, Xcode 96.7 seconds. Artifact Runner.app/Runner contains arm64 and x86_64. All fifteen installed XCFramework manifests declare arm64 simulator support. Pod install took 35.2 seconds with no version resolution conflict.

Installed successfully on isolated iPhone Duo / iOS 27.1, UDID 33DFE233-5879-4F3D-AF79-BDFC43035F02; simctl install exit 0. Launch exit 0, PID 38598, process observed alive; screenshot shows first-use terms and iOS notification authorization. No terms or notification approval was submitted. Earlier simulator bootstatus reported a system migration failure, but subsequent installation/launch succeeded; no existing simulator was erased.

Evidence: /tmp/n42-mlkit-pods-build-20261107.log (first failed build), /tmp/n42-mlkit-pods-build-final-20261107.log (successful retry), /tmp/n42-mlkit-pods-launch-20261107.png (display 1). Screenshot is local only. Compilation and initial launch do not prove OCR accuracy/model loading, face blur, segmentation, offline translation, login, physical device signing or release acceptance.

Before merge: execute native model/runtime smoke for all preserved capabilities, verify device build and relevant host regressions, and check resource contents in the built app. Keep experimental changes out of TestFlight until those gates pass.

## Native model runtime follow-up

Added integration_test/mlkit_native_smoke_test.dart using a generated 640x256 text image; no user files, accounts or chat text. All five script recognizers successfully process the same Latin fixture; this establishes per-script model load/execution, not non-Latin accuracy. Face detection returns no faces for the non-face fixture. Segmentation returns a complete finite mask in [0,1]. With N42_MLKIT_DOWNLOAD_MODEL=true, a fresh installation downloads Spanish, translates the fixed phrase to a result containing hola and runs cleanup.

The initial native run passed seven cases but crashed during translation download. Reproduced SIGSEGV/EXC_BAD_ACCESS in the modeldownloading queue. LLDB identified SSZipArchive at its ZIP metadata path, with competing minizip implementations in the linked application. The SSZipArchive pod now force-includes a namespace header for its 70 minizip-ng compatibility functions. nm confirms n42_sszip_unzGetCurrentFileInfo; other libraries retain their original symbols. No ZIP validation is bypassed.

After symbol isolation the download extracted successfully but its completion stayed pending. MLKit headers specify the remote model in notification userInfo, while commons 0.13.0 filtered notification.object by the request model. A local MIT-licensed commons fork now observes without object restriction and filters by userInfo remote model name and model class, preserving per-model success/failure matching and observer cleanup. Dart and Android implementations are unchanged. Both pubspec override files must select the fork. Earlier attempts mistakenly still used upstream because pubspec_overrides.yaml took precedence; those attempts are not patch acceptance evidence. Verified .dart_tool resolution and CocoaPods symlink before final runs.

Final-source command: flutter test --no-pub integration_test/mlkit_native_smoke_test.dart -d 33DFE233-5879-4F3D-AF79-BDFC43035F02 --dart-define=N42_MLKIT_DOWNLOAD_MODEL=true. Fresh test install: eight passed, zero skipped, exit 0. All download/check/translation/cleanup waits are bounded. dart analyze on the integration file and local commons Dart sources reports no issues. No temporary native diagnostic logging remains.

This closes the inspected native model loading, model-download ZIP crash and success-callback smoke gaps on the isolated iOS 27.1 simulator. Still open: negative model notifications/concurrent downloads, non-Latin accuracy, real faces/background/video quality, offline/privacy and performance conditions, device build/signing and true account/business acceptance. This remains an isolated branch and has not been uploaded to TestFlight.

### Retained local evidence

- `/tmp/n42-mlkit-native-smoke-20261107.log`: SHA-256 `dd4ceca860c7957c28b2d552b552c99078f4c03fe8f4340c4383e8b829390577`.
- `/tmp/n42-mlkit-translation-stack-20261107.log`: SHA-256 `4817c6524c87e8cd8098762905e893ffc3818119c15bf9a4f6bad65bc86cb984`.
- `/tmp/n42-mlkit-native-verified-20261107.log`: SHA-256 `bd0d1828c3adc17d48c317a69446c9603d131c8fdd8d7037176295019ed1a62f`.
- `/tmp/n42-mlkit-native-final-source-20261107.log`: SHA-256 `9386086c655411763670f4b20ab08ef0da0ae22f0a3b8335cd7cbf1c61777863`.
