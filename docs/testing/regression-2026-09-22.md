# Regression follow-up — 2026-09-22

## Confirmed scope

User confirms TestFlight 2.4.8 (2026072778) and explicitly identifies
**Switch account**, not logout/relogin, for the encryption reproduction.
The latest eight-item list supersedes the earlier truncated table.
`Downloads/1.mov` was decoded using AVFoundation; it shows group-member
operations, not account switching. User then supplied `Downloads/2.mov`: it shows switching from Dxx to xian07,
returning to settings with the old Dxx profile, while the main list correctly
shows xian07. It does not show encrypted message contents.
`Downloads/3.mov` (72.3 seconds) shows dxx01 sending, a login page reporting
session expiry, password reauthentication as dxx, incoming messages unavailable,
and another expired-session login. The user entered the switch-account flow,
but the recording includes reauthentication; do not describe it as an
uninterrupted successful stored-session switch. No credentials are recorded here.

| Issue | Source status and limits |
| --- | --- |
| Received messages encrypted after account switch | Fixed stale SDK logout source attribution and disposal of prior-account routes; 49 auth/navigation tests passed. Device decryption and old history recovery unconfirmed |
| Share-contact picker includes current peer | Fixed current direct peer exclusion; focused contact/group suite: 10 passed |
| GIF list fails | Local configured Giphy trending HTTP 200, 25 valid items; Tenor unconfigured. Device-specific failure not reproduced; not fixed |
| Image translation model unavailable | Fixed illegal remote-model management of built-in English; 9 translation tests passed |
| Video bubble lacks cover | Fixed encrypted thumbnail metadata and authenticated decryption; 5 metadata/resolver tests and 16 widget tests passed |
| Add event to calendar fails | Fixed pending request retained after interactive editor dismissal; iOS Debug compile passed (138.5 s Xcode), reported failure still needs device reproduction |
| Settings account identity stale after switch | AuthBloc-driven identity refresh; 22 settings tests passed |
| Add-account FaceID unusable | Add-account login hides current-account biometric shortcut; included in 22 settings tests |

## Additional validated checks

- Focused analysis of settings/login/contact picker/translation: no issues.
- Added fenced-cloud-response translation tests; existing parser already
  supported these responses. No production parser correction was required.
- Local GIF success is not device acceptance and does not prove reachability
  from the tester's network.

English is built into ML Kit and must not be passed to remote model management:
[Google iOS reference](https://developers.google.com/ml-kit/reference/swift/mlkittranslate/api/reference/Classes/TranslateRemoteModel),
[Google Android reference](https://developers.google.com/android/reference/com/google/mlkit/nl/translate/TranslateRemoteModel).
The translation change preserves user consent before cloud fallback.

## User-confirmed passed

- Transfer QR recognition and error dismissal.
- Single/multiple-face blur on sent photos.
- Android incoming-call vibration stops after answering.
- Other prior cases outside the final eight-item list.

A separate reviewed group-filter correction excludes departed/banned users from
active member enumeration (join/invite remain). The latest user list no longer
identifies group invitation as failing; do not report it as an unresolved item.

Source fixes are committed per feature. None establishes TestFlight/device
acceptance until the next build is installed and each reported flow is repeated.

Native validation: `flutter build ios --debug --no-codesign --no-pub` succeeded.
This was a compile-only check, not a newly signed distribution or device test.

## Account lifecycle corrections

- Bind SDK logout notifications to the emitting Matrix client. Ignore replaced
  client emissions before queuing and before flushing a deferred logout.
- Keep real current-client logout behavior intact.
- On successful identity changes, reset only the nested chat navigator after
  the picker handles its own close; dispose account-bound routes and avoid
  over-popping the host. Failed switches retain their routes.
- Do not change inbound Megolm snapshot selection: old sessions may decrypt
  future messages, and blindly preferring a newer pickle can lose history.

## Upstream reconciliation

Integrated colleague commit `2f2d51452`, preserving input-panel, call and
crypto diagnostic changes. Its lockfile required seven SDK-pinned dependency
versions to be resolved for release Flutter 3.44.8; strict lock validation
then passed. After integration, all 17 encrypted-send guard tests passed.
Canonical Chat commits are synchronized individually into the tracked host
mirror without overwriting unrelated upstream edits.

## Remaining acceptance work

- GIF: pending tester network details and device-specific failure evidence.
- Repeat account switching without unexpected reauthentication, then verify
  both directions of newly sent messages on the reported phone.
- Verify first and repeated native calendar additions, including swipe dismissal.
- Regress FaceID availability, profile identity, contact selection, image
  translation and encrypted video thumbnails on the next installed build.
- These changes have not yet been uploaded as a new TestFlight build; latest
  uploaded version remains 2.4.8 (2026072778).
