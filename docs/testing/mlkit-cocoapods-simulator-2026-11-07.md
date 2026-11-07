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

## Device Release compilation follow-up

Source f208ce675, version 2.5.3+73408. `flutter build ios --release --no-codesign --no-pub` completed with exit 0; Xcode 230.5 seconds, reported app size 390.4 MB. Built Info.plist confirms ai.n42.www, iphoneos and the expected version. Runner is arm64. All ten required model bundle directories are present. nm confirms _n42_pq_sign and _n42_sszip_unzGetCurrentFileInfo. codesign reports the app is unsigned, as requested. No device install, provisioning, archive export or upload occurred.

Device provenance comparison is retained in mlkit-device-slices-2026-11-07.json. The initial comparison included differing fat archive wrappers; after normalizing them, eleven arm64 archives match byte-for-byte. Of the four remaining libraries, the XenoCommon original Mach-O object matches the repackaged archive's sole object exactly. Three payloads remain different: FaceDetection, TextRecognitionCommon and Translate. Their same upstream version and successful compilation do not prove payload equivalence. Before merging, explain those differences or preserve the original Google device payloads; keep simulator compatibility separate from device algorithm changes. No binary equivalence claim is made for these three.

Build log: /tmp/n42-mlkit-device-release-20261107.log.
SHA-256: `e34780dd6dafc4a05b6920b0ea3cbcdc38c976c57a3cd808453d0ce6b46c85ba`.

## Device payload differences resolved

The three remaining raw differences are now explained and verified without modifying any binary. FaceDetection and TextRecognitionCommon replace a 16-byte LC_DATA_IN_CODE command whose data table size is zero with LC_VERSION_MIN_IPHONEOS (minimum iOS 15.5, SDK 17.2). Apple's installed loader.h identifies command constants 0x29 and 0x25. Their code/data sections, relocation records and symbol tables compare identically. Translate adds six newline bytes after the original object; all original bytes match.

Added read-only scripts/verify_mlkit_device_payloads.py. It extracts arm64 fat containers and, only where the original is a single Mach-O object, unwraps the repackaged single-member archive. It accepts no more than seven trailing newline bytes and only the exact empty-data-command/version-command replacement observed above. After those restricted normalizations, every other byte must match; otherwise it exits 1. It never rewrites a framework or broadens a version constraint.

Command: python3 scripts/verify_mlkit_device_payloads.py --original-pods /Users/jieliu/Documents/n42/n42appv2/ios/Pods --output docs/testing/mlkit-device-payload-verification-2026-11-07.json. Result: 15/15 match, exit 0. Python compilation and git diff --check pass. The JSON retains original and normalized candidate SHA-256 plus each permitted normalization. This resolves the unexplained-device-payload gate above, not real-device or production business acceptance. Remaining integration work includes negative/concurrent model notification coverage and final host regression/integration review before merging.

## Notification failure/concurrency and network policy

Added scripts/test_mlkit_notifications.py and test/native/mlkit_notifications. The script compiles the unchanged production Swift manager against controlled Flutter/MLKit API boundaries, running real Foundation notifications and NSLock without model downloads. Before fixes: 9/11 passed; duplicate-error callback reentry deadlocked, and Wi-Fi policy was ignored. After fixes: 11/11 pass. Cases cover equivalent/copied models, unrelated name/type or malformed notifications, failure, duplicate completion, concurrent model routing, duplicate requests, reentry, cache, disposal, Wi-Fi/default policy and synchronous completion. SDK boundaries are test doubles; this is not mobile network acceptance.

Duplicate rejection now unlocks before FlutterResult. The native download condition honors the wifi parameter; absent/invalid values retain Wi-Fi-only behavior. CI runs this Swift suite and prepares checksum-pinned model resources; the IPA builder also prepares models before changing versions or invoking CocoaPods. Workflow YAML and shell syntax checks pass; no remote CI run is claimed. Real iOS model smoke rerun passes eight cases, exit 0 (/tmp/n42-mlkit-native-policy-final-20261107.log). Component logs: /tmp/n42-mlkit-notifications-before-20261107.log and /tmp/n42-mlkit-notifications-final-20261107.log.

A separate real plugin concurrency test reproduces an additional existing issue: the translation plugin replaces GenericModelManager for each request, cancelling the first concurrent download with PlatformException(cancelled). This is not closed by manager-component tests. Keep plugin ownership and its integration fix open.

## Translation plugin ownership and final integration gates

The separate real concurrency probe reproduced PlatformException(cancelled, Model manager deallocated during download) when two fresh model downloads overlapped. The local MIT-licensed google_mlkit_translation 0.15.1 fork now owns one GenericModelManager for the plugin lifetime; checks/downloads/deletes no longer replace and dispose another request's owner. Dart/Android source trees in both local forks were compared byte-for-byte with their published versions and match.

The concurrent case is consolidated into mlkit_native_smoke_test.dart through mlkit_model_concurrency_cases.dart. It requires uncached Spanish and French, starts both downloads, performs a German model-status query while they are pending, requires both download results and installed-model checks to succeed, and checks cleanup return values. Single-model inference, five OCR model loads, face detection and segmentation remain in the same suite. This is real native plugin execution with synthetic data; notification failure/reentry/Wi-Fi mapping uses the separate controlled-boundary Swift suite.

Final local results on the pending ownership patch based on 346efd865, app version 2.5.3+73411:

- Combined real iOS integration: nine passed, zero skipped, exit 0.
- Host Chat initialization/configuration/SSO/push regressions: 125 passed, exit 0.
- Controlled production Swift notification suite: eleven passed, exit 0.
- Device Release compilation: exit 0, Xcode 207.5 seconds, arm64 iphoneos artifact (unsigned). All ten model bundle contents match prepared resources.
- Device binary verifier: 15/15 match after restricted packaging/metadata normalization.
- Scoped Dart analysis: no issues. CI YAML, IPA shell syntax and diff checks pass. Remote CI has not been inspected.

CI and IPA resource preparation changes prevent a clean checkout from silently omitting models. These results resolve the local plugin ownership/concurrency and merge-regression gates above. Physical-device install/signing, real non-Latin accuracy, camera/video quality, cellular-network behavior, authenticated Chat/provider/business flows and TestFlight remain separate open acceptance work. No upload or real account operation occurred. The commit hook's following version-only bump does not describe a newly built artifact.

Retained logs and hashes:
- `/tmp/n42-mlkit-plugin-concurrency-before-20261107.log`: `2ebccedd0bf531a83c11ff42a00fd88fbb4c6c35d5ee3229f6623e0d3a03f64b`.
- `/tmp/n42-mlkit-plugin-concurrency-after-20261107.log`: `00adaf8bad9c2ba1a19372b09d8486af299e08f539059083bcfadc120d26e58d`.
- `/tmp/n42-mlkit-combined-final-20261107.log`: `163c65fdb2699fa038d47a148f449182cf308691702c9832e44f6ab9c2fb77c2`.
- `/tmp/n42-mlkit-host-final-20261107.log`: `176854c36b34478b41822bc1f958c590b49e4cc90ef6ccaa00afb4ef81084f86`.
- `/tmp/n42-mlkit-device-final-20261107.log`: `091f8d045df291efd5334d0dd2defad63c640af327a58d4c1f30a76cc508f449`.
- `/tmp/n42-mlkit-notifications-final-20261107.log`: `9c267a81e71b4fb25a2d7cfb0504d5a5bf3605db5d142d8c6c1ec265827a195a`.

## Main integration and remote CI follow-up

5591d6342 was fast-forwarded to master and pushed; the main worktree's locked pub resolution, model preparation and CocoaPods symlinks were refreshed successfully. Existing untracked plans and packages/n42_chat were preserved.

CI Pipeline run 42360531743 failed in the combined localization/script step: localization passed, but the IPA helper fixture had not provided the newly required model-preparation helper. Updated the isolated fixture and added a failure-path check that preparation failure prevents version mutation and build dispatch. All 50 script tests and localization audit pass locally. No localization baseline was weakened.

Also corrected native Swift/model preparation steps accidentally inserted in the Android build job: they now belong to the macOS iOS build job. The separate iOS integration workflow now prepares models too. YAML structure checks confirm Swift runs only on macOS and both iOS build/integration jobs prepare models; Android has no MLKit resource preparation step. Remote CI acceptance requires the new push results, not the earlier failed run or local syntax checks.

CI run 42360960104 then passed localization/script checks and Flutter analysis but failed the existing formatting gate on two wallet coin-model provider files and the generated generic Aptos fixture. Applied Dart formatting to the provider files. Regenerated the Aptos fixture with node test/native/aptos_reference_vector.cjs --generic --dart, then formatted it; decoded vector values equal both the prior file and the independent Node JSON output. The exact CI format command checks 1,700 lib/test files with zero changes. No formatting gate or localization baseline was relaxed; these are formatting-only changes. New remote results still require verification.
