# TestFlight release — 2026-09-15

- App: `ai.n42.www`, version **2.4.8+2026072656**.
- Source: `0a20560356fa74d681a95126ce3607a0d297d5d0`, pushed to `master`.
- Chat dependency: `def750f16e553146c484d8a155e6819581f4d3c3`.
- Includes the registration, friendship, encrypted session recovery, file notice
  lifecycle and settings fixes described in the
  [feedback report](../chat-audit-2026-09-12/testflight-feedback-2026-09-15/README.md),
  plus the browser session fixes in the source commit.
- Xcode 26.6, iOS SDK 26.5. Host and notification extension versions match.
- Strict/deep signature checks and App Store profiles passed. Production APNs,
  application groups, both keychain access groups, Apple sign-in and disabled
  debug entitlement were verified in the final exported IPA.
- Local IPA: `build/ios/ipa/N42Wallet.ipa`, 162,624,021 bytes.
- Local IPA SHA-256:
  `4ddb65644908ef37dcdd309cca5dc1c95c0e0d40031096e0891dfa234cf81e1a`.
- Xcode reported **Upload succeeded**, **Uploaded Runner** and **EXPORT SUCCEEDED**
  at **2026-09-15 08:34:02 UTC**, exit code 0. Apple reported package processing.
  Processing completion and tester availability have not been verified.
- Non-blocking symbol warnings: missing matching WebRTC.framework and
  flutter_vodozemac.framework dSYMs.

The background shell could not access the unlocked desktop-session keychain.
Compilation therefore produced an unsigned archive. Signing and export used the
desktop session and a copy in Xcode's standard Archives directory. The first
export omitted the app-specific entitlements and was **not uploaded**. The archive
was signed with the project's complete entitlements and exported again; the final
IPA passed the checks above before upload. The existing release-script correction
for objective_c.framework's minimum iOS version was applied to the staged archive.
The final signed archive is also saved at `build/ios/archive/Runner.xcarchive`.
Upload used that same signed archive with automatic build-number management off.
No credential or private signing material is included in this record.

This is a TestFlight feedback build. The wallet full suite passed 4,870 tests on
the preceding Chat fix commit; the final Chat pin passed 111 targeted wallet
regressions. Exact revisions and results are in the feedback report. Coverage is
45.96%, below the 70% formal release gate. The reported account/device flows still
need real-device retesting; uploading does not close those acceptance gaps.

Evidence: [validation](testflight-release-2026-09-15/validation.json) and
[upload result](testflight-release-2026-09-15/upload-result.log).

This record is committed after upload. The commit hook advances the development
build number; the uploaded build remains **2026072656**, built from the source
commit recorded above.
