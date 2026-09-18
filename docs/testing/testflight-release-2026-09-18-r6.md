# Chat feedback release — 2026-09-18, build 2026072690

- App: **2.4.8 (2026072690)**, `ai.n42.www`.
- Source: `4ea18cc11554a88b64c648b977c4f27fc5952999`, pushed to `master`.
- Chat: `16074f4a57be5b3452d807a2bbcf30fc23082d15`.
- Includes [account isolation, registration, group, tag/star, encryption and video repairs](chat-feedback-2026-09-18-2687.md), plus the project-level CocoaPods configuration documented in [iOS troubleshooting](../IOS_DEPENDENCY_TROUBLESHOOTING.md).
- Pre-release validation: **923 Chat tests passed** in the app, analysis had no errors/warnings (217 informational diagnostics), and all 781 mirrored Chat lib/assets files matched the Git dependency. No implementation changes followed those checks.
- Xcode 27.0 archive and App Store export succeeded. Both main app and notification extension carry 2026072690. Deep/strict signing and distribution entitlement checks passed, including production APNs, required app/keychain groups and disabled debugging.
- IPA: **162,553,963 bytes**; SHA-256 `22de5788fceacb569dc61e198052e88d7cd192407d2fe4747beef5a6ad2b1f0d`.
- TestFlight accepted **2026-09-18 16:11:49 EDT / 20:11:49 UTC**: `Upload succeeded`, `Uploaded Runner`, `EXPORT SUCCEEDED`, exit 0. Apple processing completion and tester availability remain unverified.
- Non-blocking symbol warnings: missing dSYMs for WebRTC.framework and flutter_vodozemac.framework. Upload succeeded, but crash symbolication for those binaries may be incomplete.
- APK: `~/Downloads/N42Wallet-2.4.8-2026072690-release.apk`, **846,769,206 bytes**. Signature verified and matches build 2671; not debuggable. SHA-256 `216f909944a335461c2b85cc5b019affc5651782cb90845857ea5662c1c34cc3`. A checksum sidecar is available beside it.

Evidence: [validation](testflight-release-2026-09-18-r6/validation.json), [upload result](testflight-release-2026-09-18-r6/upload-result.txt).

Feedback-phone acceptance remains open, especially native key persistence and video playback. No device was uninstalled or overwritten during this release. This record's commit hook advances the next development version; delivered artifacts remain **2026072690** from the source above.
