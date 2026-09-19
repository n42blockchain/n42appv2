# Account switching release — 2026-09-18, build 2026072692

- App: **2.4.8 (2026072692)**, `ai.n42.www`.
- Source: `f5d3f7ad7723d3a3459b03dc1afc017c4ef2fe12`; Chat: `e1598c798db499b79309fe806a2c0e750c9272ad`.
- Includes [independent encrypted account sessions and Switch Account UI](account-switch-encryption-2026-09-18.md). Use Settings → Switch Account for daily account changes; explicit Log Out still revokes the session. Previously missing keys are not reconstructed.
- Validation before release: 935 app Chat tests passed, analyzer zero errors/warnings (232 infos), 783 mirrored Chat library/assets matched the dependency. Live Matrix SDK 6.2 test verified bidirectional offline decryption, retained device identities, manager restart, failed-login recovery and isolated logout. All temporary accounts deactivated.
- Xcode 27.0 archive/export succeeded; app and notification extension both carry 2026072692. Deep/strict signatures and distribution entitlements verified, including production APNs, required app/keychain groups and disabled debugging.
- IPA: 162,582,390 bytes; SHA-256 `9b6a28f3e255e178f0d49298dff51aac54fce8b470401b6498b926a92efad4c4`.
- TestFlight upload accepted **2026-09-18 21:04:03 EDT / 2026-09-19 01:04:03 UTC**, exit 0, all upload/export success markers present. Apple processing and tester availability remain unverified.
- Non-blocking missing dSYM warnings for WebRTC.framework and flutter_vodozemac.framework may limit crash symbolication.
- APK: `~/Downloads/N42Wallet-2.4.8-2026072692-release.apk`, 846,785,678 bytes; SHA-256 `2dcd6c9d326d8b5e77f6ecb953e483cec7b12cb1d7d03e065470894c9b1dd2c0`. Signature verified; signer matches the retained verification record for 2690 (the old APK is no longer present). Not debuggable. Checksum sidecar saved alongside the APK.

Evidence: [validation](testflight-release-2026-09-18-r7/validation.json), [upload result](testflight-release-2026-09-18-r7/upload-result.txt).

Both feedback phones still need acceptance testing: add each account once, switch without logout, receive new offline messages, restart the app, and check account isolation. No device data was removed or overwritten. This documentation commit advances the next development version; the delivered artifacts remain **2026072692** from the source above.
