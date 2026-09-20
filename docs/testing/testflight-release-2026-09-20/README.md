# Chat feedback release — September 20, 2026

- Delivered version: **2.4.8 (2026072696)**, `ai.n42.www`.
- Source: `b7cb3187498db1627fa5ce58adb888ebe002d1f7`; Chat: `4dd0304d9000bac226e96700f9db26302407626f`.
- Includes the [eight feedback items and second UX pass](../chat-ux-feedback-2026-09-20/README.md), including authenticated free AI summaries and contact notification badges.
- [Eight-item device acceptance checklist](acceptance.md). Ordinary group invitations still require acceptance. Lost historical keys are not reconstructed.

## iOS / TestFlight

- Xcode 27 archive/export and desktop signing succeeded. Main app and notification extension both carry build 2026072696.
- Deep/strict signature and distribution entitlements verified: production APNs, expected app/keychain groups, no debugging entitlement.
- Upload accepted at **2026-09-20T01:15:10.351662-04:00**, exit 0, all three upload/export success markers present. Apple reported processing started; processing completion and tester availability remain unverified.
- IPA size: 162,605,679 bytes; SHA-256 `6ab76b5fbac13237b767987c18779867721387ccd27f9f795ca96b593b6e8d55`.
- Provider-key scan passed. Private key/configuration and raw distribution logs are not committed.

## Android

- APK: `~/Downloads/N42Wallet-2.4.8-2026072696-release.apk` (checksum sidecar alongside).
- Size: 846,884,158 bytes; SHA-256 `af32b8d38419fe85c0411745ae210b62df823c49d0781ea43208a587bb8aa073`.
- Signature verified against retained 2692 APK, correct package/version, not debuggable.
- ZIP and all 55 inspected 64-bit ELF libraries passed 16 KB alignment. This does not establish execution on a 16 KB device.
- Provider-key scan passed. No phone was installed, uninstalled or cleared during this release.

## Validation and remaining acceptance

- 972 main Chat tests passed; analyzer has zero errors/warnings (248 infos).
- 789 Chat library/asset files match the pinned dependency.
- Live Matrix tests passed retained-session history/restart, missing-recipient-key rejection, and newly encrypted peer messages after explicit logout and fresh login. All disposable accounts were deactivated.
- AI gateway synthetic Chinese summary passed using Matrix authentication. No provider subscription account is needed; free-model availability and trial quotas still apply.
- Both feedback phones still need the checklist above on build 2696; automated/SDK checks do not replace native acceptance.
- This documentation commit advances the next development build number; delivered artifacts remain 2696 from the recorded source commit.

Evidence: [artifact validation](validation.json), [upload acceptance](upload-result.txt), [native alignment](native-alignment.json).
