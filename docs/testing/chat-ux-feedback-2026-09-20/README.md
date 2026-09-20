# Chat UX and eight feedback items — September 20, 2026

Feedback version: TestFlight 2.4.8 (2026072692). The user confirmed explicit logout
and login to change accounts; this differs from the retained-session account picker.
No feedback phone was reinstalled, logged out or wiped during this work.

## Implemented changes

| Feedback | Change | Verification boundary |
|---|---|---|
| 1. Conversation preview differs from timeline | Retry preview decryption using available keys, observe key/event updates, reset room cache across account identities | Unit repository/SDK fixtures and live retained-session test passed; native UI pending |
| 2. New friends cannot send / encrypted text after logout | Distinguish missing recipient device keys from generic encryption failure; preserve strict encrypted-send checks; promote retained-session switch in logout dialog | Live SDK confirms retained-device messages/history and rejects peer with no published keys; explicit logout does not preserve a receiving device |
| 3. AI summary forbidden | Deploy authenticated server-only OpenRouter free-model gateway; resolve current Matrix token per call; localize access failures; show summary action only with at least two eligible messages | Live gateway Chinese summary and invalid-token rejection passed; native summary pending |
| 4. Tags cannot open contacts | Tag management rows open matching contacts; member row opens profile; account identity guards async results | Tag member widget regression passed |
| 5. Star index has no star section | Group starred contacts at the star index without duplicating alphabetic rows | Contact grouping regression passed |
| 6. Invited group members need acceptance | Retain ordinary invite consent; display joined/invited counts separately | Group entity/repository tests passed; no automatic joining added |
| 7. My Moments/My Status repeated invitations | Identify social rooms using state markers, create type or own invitation reason; exclude from ordinary group invites | Actual SDK-room fixtures passed; no room-name matching and no deletion |
| 8. Contacts bottom tab lacks pending count | Share group state between contact entries and bottom navigation; count incoming friend requests plus ordinary group invites | Compilation/static checks and contact widget suite; feedback-phone badge clearing pending |

## Second UI pass

Earlier filter/account-selector/request-card/attachment changes are retained.
This pass adds stale-result rejection in contact search, explicit search failure and
retry, refresh completion tied to actual asynchronous work, retained cached lists,
scrollable short-screen menus with Material press feedback, and consistent account
row typography and safe-area spacing. The attached light/dark images are synthetic
Flutter widget captures, not screenshots from the feedback devices.

New feedback labels are translated in English, Simplified and Traditional Chinese;
other locales currently use English fallbacks. Track remaining acceptance and
translation work in n42_chat/OPEN_ISSUES.md (QA-003/005/006/009).

## AI trial deployment

See [gateway deployment and quotas](../../../backend/ai-proxy/README.md).
The provider key exists only in private local/server configuration and is not in
Git or the app. User-stated validity is one year; actual expiration is controlled
by the provider console. No subscription account is used.

Free routing is variable: a low-output-budget request returned gateway 503, while
the 1,024-token Chinese-summary smoke succeeded. This is a text-only trial, not
proof of image generation, streaming latency or production capacity.

## Completed validation

- Source focused feedback/UX: 179 tests passed.
- Source AI account-authentication and contact navigation: 17 tests passed.
- Backend: six unit tests passed, including concurrent persisted quotas.
- Real Matrix SDK: extended retained-session test passed; both disposable accounts
  deactivated. No private session keys or raw SDK logs included in this report.
- A second real Matrix run confirmed fresh-device login after explicit logout can
  receive newly encrypted peer messages without restoring old keys; both accounts
  were deactivated.
- Live AI gateway: valid temporary Matrix account returned HTTP 200 Chinese summary;
  invalid credentials returned 401; temporary account deactivated.
- Main application Chat suite: 972 tests passed.
- Main `flutter analyze --no-pub --no-fatal-infos`: zero errors/warnings, 248 infos.
- Exact provider-key scan: no matches in tracked or unignored files in either repository.
- Earlier second-pass UX: 90 focused tests passed; 26 visual/widget checks passed.

Native acceptance on the reported Android/iPhone is still required. Build 2692 does
not include this work. No TestFlight/APK release was produced in this task.

Pinned Chat revision: `4dd0304d9000bac226e96700f9db26302407626f`.
