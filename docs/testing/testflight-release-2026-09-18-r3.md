# Contact refresh release — 2026-09-18, build 2026072683

- App: **2.4.8 (2026072683)**, `ai.n42.www`.
- Source: `dc4f072b71cd4165499117a70f161500800a12d9`, pushed to `master`.
- Chat: `9e9460c6d0c87d645776bcc27273576965838a36`.
- Includes the [absent historical peer refresh repair](contact-refresh-2026-09-18.md)
  and the preceding registration fix. The user's exact contact-refresh failure
  remains uncorrelated with a device error/build/account; this release fixes the
  reproduced missing-member path without claiming native-device acceptance.
- 554 contact/Chat feedback tests passed against the app-resolved Matrix SDK
  6.2.0. Wallet analysis has zero errors/warnings, 196 informational diagnostics.
- Built with Xcode 27.0 and existing private release configuration. IPA main and
  extension versions match, deep/strict signature checks pass, production APNs,
  team, app group, keychain groups and disabled debugging were verified.
- IPA: **162,535,867 bytes**; SHA-256:
  `363ba6067068585770e487bf15b7485308e4e0f7c2fd4fb28028c9c2094d608c`.
- TestFlight upload accepted **2026-09-18 02:15:10 EDT / 06:15:10 UTC**:
  `Upload succeeded`, `Uploaded Runner`, `EXPORT SUCCEEDED`, exit 0. Apple began
  processing; tester availability and processing completion are not verified.
  Non-blocking WebRTC/flutter_vodozemac dSYM warnings remain.
- APK version and signature verified, certificate matches build 2671, not
  debuggable. Stored at `~/Downloads/N42Wallet-2.4.8-2026072683-release.apk`
  with a checksum sidecar. Size: **846,654,518 bytes**; SHA-256:
  `4363eb94f5277c169d4eaf58978866934ced39d61e7320a619244d4775f75678`.

Evidence: [validation](testflight-release-2026-09-18-r3/validation.json),
[upload result](testflight-release-2026-09-18-r3/upload-result.txt).
No existing user accounts, server configuration, device data or chat history
were modified. Device tab-switching acceptance remains outstanding.

This record's commit hook advances the development version. Delivered artifacts
remain **2026072683**, from the source above.
