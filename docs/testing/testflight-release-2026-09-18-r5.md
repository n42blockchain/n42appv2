# Contact layout release — 2026-09-18, build 2026072687

- App: **2.4.8 (2026072687)**, `ai.n42.www`.
- Source: `9de5f2685743fe21b4fe3b0deaa0ee2c06b1487d`, pushed to `master`.
- Chat: `3f0bca2ad8744084405b8e1a20590a7a338b549d`.
- Includes the [fixed complete contact index and entry divider](contact-index-layout-2026-09-18.md), plus all repairs in 2685.
- Contact navigation: 14 tests passed in Chat and the app-resolved Matrix SDK 6.2.0. Analysis: no errors/warnings; Chat 219 and app 201 informational diagnostics. All 780 mirrored lib/assets files match the resolved dependency. These checks were completed before the release request; unchanged sources were used for this build.
- Xcode 27.0 archive and App Store export completed. Main and notification extension both carry 2026072687. Deep/strict signature and distribution entitlement checks passed, including production APNs and disabled debugging.
- IPA: **162,549,138 bytes**; SHA-256 `890e508378126e13dcbcd2239483629ba8a9a14dd375ce074cb2f036f7a02139`.
- TestFlight accepted **2026-09-18 03:30:59 EDT / 07:30:59 UTC**: `Upload succeeded`, `Uploaded Runner`, `EXPORT SUCCEEDED`, exit 0. Apple processing started; completion and tester availability are unverified. Non-blocking WebRTC dSYM warning remains.
- APK: `~/Downloads/N42Wallet-2.4.8-2026072687-release.apk`, **846,670,902 bytes**. Signature verified, same certificate as 2671, not debuggable. SHA-256 `fd9ba84bcd1d8d7938cb1510620773a9ee6e404f3510efb7e1405508fdfd450e`; checksum sidecar accompanies the APK.

Evidence: [validation](testflight-release-2026-09-18-r5/validation.json), [upload result](testflight-release-2026-09-18-r5/upload-result.txt).

Native visual acceptance remains pending. No existing device data, accounts or server settings were changed. This record's commit hook advances the development version; delivered artifacts remain **2026072687** from the source above.
