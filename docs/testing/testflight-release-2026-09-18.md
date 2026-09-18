# TestFlight release — 2026-09-18

- App: `ai.n42.www`, **2.4.8+2026072679**.
- Source: `3fb0309bb8e143e6534d41be7c7e021aaa7ee51a` on `master`.
- Chat: `f03cb063bb1d558aa03a74bec69a6f71f0b2ca2d`.
- Includes the registration UI simplification in the source commit. This
  release operation does not establish successful real-account registration.
- Built with Xcode 27.0 (27A266a), using the existing private release config.
  Desktop Terminal provided signing-key access; the background session could
  list identities but failed its signing probe with `errSecInternalComponent`.
- Main app and notification extension both report 2.4.8 / 2026072679. The final
  IPA passed deep/strict signature verification. Main-app production APNs,
  Apple sign-in, app group and both keychain groups match the project settings;
  debugging is disabled in both bundles. The extension has no custom groups,
  matching its source entitlement file.
- The canonical builder corrected `objective_c.framework` minimum OS to 16.0
  before the final export. Automatic upload version management was disabled.
- IPA: `build/ios/ipa/N42Wallet.ipa`, **162,536,015 bytes**.
- IPA SHA-256:
  `4e24aca85b01b60f6b8073e65afd4edfb265ceebbc3deaa40d3215ef977ab7e1`.
- Xcode reported **Upload succeeded**, **Uploaded Runner**, and
  **EXPORT SUCCEEDED**, exit 0, at **2026-09-18 00:16:10 EDT / 04:16:10 UTC**.
  Apple accepted the package and began processing. Processing completion and
  availability to testers have not been verified.
- Non-blocking dSYM warnings remain for WebRTC.framework and
  flutter_vodozemac.framework; these affect symbolication of framework crashes.

## Android companion

The existing release APK was verified and copied to
`~/Downloads/N42Wallet-2.4.8-2026072679-release.apk` with a `.sha256` sidecar.
Its embedded version is 2.4.8 / 2026072679, it is not debuggable, and Android SDK
`apksigner` verified its signature and the certificate match with build 2671.

- Size: **846,670,902 bytes**.
- SHA-256: `683aa7c7b433ccda1991f276415cf480063aa8972057b41bc4e512f5f2fc793b`.
- No new device regression or installation was performed during this upload task.

## Repeatable handoff

Use the [TestFlight runbook](../TESTFLIGHT_RUNBOOK.md) for subsequent releases,
including operation by Sol. Its embedded Python examples were syntax checked;
the IPA version/signature/checksum example was executed successfully against
this build. No application code changed during this task, so unit tests were
not rerun. This TestFlight upload is not full production-release acceptance.

Evidence: [validation](testflight-release-2026-09-18/validation.json),
[sanitized upload result](testflight-release-2026-09-18/upload-result.txt).
Signing credentials and raw build/distribution logs remain local.

This record is committed after upload. The commit hook advances the development
build number; the uploaded build remains **2026072679** from the source above.
