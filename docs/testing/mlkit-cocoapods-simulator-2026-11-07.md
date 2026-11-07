# MLKit CocoaPods simulator compatibility — isolated validation

Branch: fix/mlkit-pods-simulator-20261107. Based on wallet bd80eb1ad and unchanged Chat pin ad7ce8c41d2ad747db966ba1d8ff015f7d9230ef. This supersedes the attempted SwiftPM route for simulator compatibility; that separate experimental branch is not integrated.

Retains original Dart plugins and all five OCR scripts, Firebase, CocoaPods and GTMSessionFetcher 3.5.0. Fifteen local podspecs retain the original Google pod versions/dependency constraints and point to checksum-pinned XCFrameworks repackaged by d-date/google-mlkit-swiftpm 9.0.2. Upstream synthesizes the arm64 simulator slice by Mach-O platform rewriting; this is not an official Google arm64 simulator release. Binary provenance is recorded in the adjacent JSON. Original pod licensing/metadata remains in each specification.

Ten required models are downloaded by scripts/prepare_mlkit_resources.py using fixed release asset SHA-256 values and safe archive paths. Models remain ignored local artifacts. Pod installation verifies they exist and adds each bundle to the main Runner resources phase. Old pod resource declarations are removed because these XCFramework archives omit the model bundles. Existing Objective-C linkage and SQLCipher/Falcon force-link settings remain intact.

First build reached linking but failed because the isolated worktree lacked the ignored GoogleService-Info.plist. Reused the existing local file without printing or committing it. Retry `flutter build ios --simulator --debug --no-pub`: exit 0, Xcode 96.7 seconds. Artifact Runner.app/Runner contains arm64 and x86_64. All fifteen installed XCFramework manifests declare arm64 simulator support. Pod install took 35.2 seconds with no version resolution conflict.

Installed successfully on isolated iPhone Duo / iOS 27.1, UDID 33DFE233-5879-4F3D-AF79-BDFC43035F02; simctl install exit 0. Launch exit 0, PID 38598, process observed alive; screenshot shows first-use terms and iOS notification authorization. No terms or notification approval was submitted. Earlier simulator bootstatus reported a system migration failure, but subsequent installation/launch succeeded; no existing simulator was erased.

Evidence: /tmp/n42-mlkit-pods-build-20261107.log (first failed build), /tmp/n42-mlkit-pods-build-final-20261107.log (successful retry), /tmp/n42-mlkit-pods-launch-20261107.png (display 1). Screenshot is local only. Compilation and initial launch do not prove OCR accuracy/model loading, face blur, segmentation, offline translation, login, physical device signing or release acceptance.

Before merge: execute native model/runtime smoke for all preserved capabilities, verify device build and relevant host regressions, and check resource contents in the built app. Keep experimental changes out of TestFlight until those gates pass.
