# TestFlight release — 2026-09-15, build 2026072659

- App: `ai.n42.www`, **2.4.8+2026072659**.
- Source: `769832a47bc99a91c4c74fa3cb90e8a3bf7ae68a`, pushed to `master`.
- Chat: `aca3fdad317a8e86a95a664d9bc66bdebae29318`; all 771 mirrored lib/assets
  files match the resolved Git dependency and source manifest.
- Includes the [key-recovery follow-up](key-recovery-2026-09-15/README.md) and the
  clearer [registration-disabled message](../operations/2026-09-15-matrix-registration-disabled.md).
- Validation before building: Chat full suite 6,462 passed, one skipped; wallet
  targeted suite 128 passed. Chat and wallet analysis have zero errors/warnings.
- Xcode 26.6, iOS SDK 26.5. Main app and notification extension versions match.
  Strict/deep signature checks and App Store profiles passed. Production APNs,
  application groups, both keychain groups, Apple sign-in and disabled debugging
  entitlement were verified in the final IPA.
- IPA: `build/ios/ipa/N42Wallet.ipa`, 162,612,777 bytes.
- IPA SHA-256:
  `3b667e40aaee22adbb924ce2a9ef1abc9cfccef932888bd6221f02c568b05594`.
- Xcode reported **Upload succeeded**, **Uploaded Runner**, **EXPORT SUCCEEDED**
  at **2026-09-15 10:14:42 UTC**, exit code 0. Apple reported package processing;
  processing completion and tester availability have not been verified.
- Non-blocking symbol warnings: missing matching WebRTC.framework and
  flutter_vodozemac.framework dSYMs.

Compilation produced an unsigned archive; signing/export used the unlocked desktop
keychain and Xcode's standard Archives directory, following the previously verified
workflow. Project entitlements were applied before the final export. The staged
objective_c.framework minimum OS correction was retained. Automatic build-number
management was disabled for export and upload. The final signed archive is saved
at `build/ios/archive/Runner.xcarchive` and in Xcode Archives as
`2026-09-15/N42Wallet-2026072659.xcarchive`. Private release configuration and signing
material remain untracked.

This upload does not establish real-account historical-key recovery. Registration
is still disabled on the server pending SSH authorization and configuration repair;
unified login was not changed. This remains a TestFlight feedback build rather than
formal production acceptance.

Evidence: [validation](testflight-release-2026-09-15-r2/validation.json),
[upload result](testflight-release-2026-09-15-r2/upload-result.log).

This record is committed after upload. The commit hook may advance the development
version; the uploaded build remains **2026072659**, built from the source above.
