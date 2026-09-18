# Registration fix release — 2026-09-18, build 2026072681

- App: **2.4.8 (2026072681)**, `ai.n42.www`.
- Source: `e10c8c832d8967fbad97c0ad46efae8909d7224f`, pushed to `master`.
- Chat: `b6d29770445c1e95e4d7c3f224a0223e2e504376`.
- Includes the [registration UIA repair and live protocol verification](registration-uia-2026-09-18.md).
  This replaces build 2679 for registration regression testing.
- Validation: 96 focused Chat authentication tests and 413 wallet Chat feedback
  tests passed; analysis has zero errors/warnings in both repositories. A
  disposable account completed registration, password login and deactivation
  against the production server through the repaired datasource/SDK transport.
  Native registration UI and session initialization on the feedback devices
  remain unverified.
- IPA built with Xcode 27.0, using desktop signing and the existing private
  release configuration. Main and extension versions match. Deep/strict signing,
  disabled debugging, team, production APNs, app group and keychain groups passed.
- IPA size: **162,535,223 bytes**; SHA-256:
  `f1986486d0cd9696daf257a6fc948ba0fe3ba2e7760c44e3a5b396d9a775960c`.
- Upload completed **2026-09-18 01:57:17 EDT / 05:57:17 UTC**. Xcode reported
  `Upload succeeded`, `Uploaded Runner`, `EXPORT SUCCEEDED`, exit 0.
  Apple began processing; processing completion and tester availability are
  not yet verified. Non-blocking WebRTC/flutter_vodozemac dSYM warnings remain.
- Android release APK built successfully, version/signature verified, certificate
  matches build 2671, not debuggable. Stored at
  `~/Downloads/N42Wallet-2.4.8-2026072681-release.apk`, with checksum sidecar.
- APK size: **846,654,518 bytes**; SHA-256:
  `6a76cf7e092dc5c44af96b4cf37d67fec38ee0027a644b4bf79b2fc72ffe17a0`.

Evidence: [validation](testflight-release-2026-09-18-r2/validation.json),
[upload result](testflight-release-2026-09-18-r2/upload-result.txt).
Repeat releases using the [runbook](../TESTFLIGHT_RUNBOOK.md). No server settings,
existing user accounts or device application data were changed. This is a
TestFlight feedback build, not full production acceptance.

The documentation commit advances the next development build through the Git
hook; delivered artifacts remain **2026072681**, from the source above.
