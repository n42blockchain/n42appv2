# Chat feedback release — 2026-09-18, build 2026072685

- App: **2.4.8 (2026072685)**, `ai.n42.www`.
- Source: `2e2d24fbda81cbdd2f72598b0a7873be82f77a86`, pushed to `master`.
- Chat: `aed4d9539f6e12c64e347c543ec930119b025d54`.
- Includes [history retention, caller-only summaries, chat-only profile navigation, encrypted file sends and location addresses](chat-feedback-2026-09-18.md).
- Chat targeted tests: **188 passed**. App-resolved SDK 6.2.0 feedback/history/contacts tests: **545 passed**. Analysis: no errors/warnings; Chat 219 and app 201 informational diagnostics. All 780 mirrored lib/assets files match the resolved dependency.
- Xcode archive and App Store export completed. Main app and notification extension both carry 2026072685. Deep/strict signature verification passed; distribution team/application IDs, production APNs, app group/keychain access and disabled debugging checked.
- IPA: **162,551,305 bytes**; SHA-256 `3a23c70d73e9f33728ac0c1ce18bfdca62dd3e2f3b09d92d064b43034722bc14`.
- TestFlight upload accepted **2026-09-18 03:11:51 EDT / 07:11:51 UTC**: `Upload succeeded`, `Uploaded Runner`, `EXPORT SUCCEEDED`, exit 0. Apple processing started; processing completion and tester availability are unverified. Non-blocking WebRTC dSYM warning remains.
- APK: `~/Downloads/N42Wallet-2.4.8-2026072685-release.apk`, **846,670,902 bytes**. Signature verified, same certificate as 2671, not debuggable. SHA-256 `8b331dc3ffa86941f9097f1d0364f70d78a445bf7b475caf263ec312541d09f7`; checksum sidecar accompanies the APK.

Evidence: [validation](testflight-release-2026-09-18-r4/validation.json), [upload result](testflight-release-2026-09-18-r4/upload-result.txt).

Both test phones should upgrade before call-summary acceptance. Explicit same-device logout retention cannot recreate already lost history keys, and physical secure-storage/file-transfer/address/call behavior remains to be verified. No existing user accounts, server settings or device data were changed in this pass.

This record's commit hook advances the development version. Delivered artifacts remain **2026072685** from the source above.
