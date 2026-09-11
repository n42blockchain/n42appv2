# Three-app audit and physical-device regression — 2026-09-04

## Scope and source revisions

Review window: 2026-06-04 through 2026-09-04. This is a risk-based review of
recent history, changed execution paths and automated regressions, not a claim
that every line in every commit has been manually verified.

| Repository | Branch | Synced revision | Commits in review window |
| --- | --- | --- | ---: |
| N42 | master | `efcfb47a3537a5c38939605d0fd7467f41c62da7` | 488 |
| Minto | main | `3c866e02f8e8bf3f0951ab03e39ac22fcf23a184` | 896 |
| 11X | dev | `d4587bfc787de29ea5a5535800b52150f1692349` | 1043 |

N42 and Minto were already current. 11X was fast-forwarded from `72d8d6f7bd`;
SSH fetch succeeded after HTTPS credential retrieval failed. No force push,
history rewrite, remote configuration change, account reset or app uninstall.
Audit changes remain local and uncommitted.

Focus: transaction gas accounting, login/account switching, HTTP authorization
and timeout lifetime, payment request handling, recent video/navigation changes,
native release configuration, and UI regression reliability.

## Findings and repairs

1. **N42 — replacement fee reservation (high).** A higher replacement tip could
   increase the signed gas cap after the native balance check. Move effective
   tip/cap resolution before estimation and reservation. Two local JSON-RPC
   regression cases cover native and ERC-20 sends, verify the estimated cap,
   and verify insufficient gas stops before nonce retrieval or broadcast.
2. **Minto — account validation isolation (high).** Switching to a saved account
   temporarily replaced the global access token before validating that account.
   Validate with an explicit per-request token; commit the global token only
   after successful validation. A superseding login/logout invalidates the
   pending switch. Validation failure no longer restores an obsolete token.
3. **Minto — stale unauthorized responses (high).** A delayed 401 or an invalid
   saved-account refresh could remove the active account's credentials. Only
   clear the currently matching implicit request token; explicit-token requests
   and public refresh validation do not clear another session. Uploads receive
   the same current-token check. This is not a transactional redesign of all
   multi-key secure-storage writes.
4. **Minto — response-body timeout (medium).** Returning the JSON promise without
   awaiting it ended the timeout in `finally` before the body finished. Await
   parsing inside the protected region for API calls and uploads. Regression
   covers headers arriving followed by a stalled response body.
5. **N42 — release version drift (medium).** Hardcoded target-level Flutter
   version values overrode generated settings and explicit Flutter build flags.
   The first audited build incorrectly reported `2026072636` despite requesting
   `2026072637`. Runner now inherits its existing generated configuration;
   all three notification-extension configurations inherit `Generated.xcconfig`.
   Remove release-script project rewrites and validate host/extension versions
   with `scripts/check_ios_version.sh` before IPA export. Rebuilt host and
   extension both verified as `2.4.8+2026072637`.
6. **Regression maintenance.** Align 11X assertions with approved normalized
   colors, the current React Native video PiP API, and screen-scoped minimal
   navigation. Fix Minto root-layout test to wait for an actually rendered stack
   and unmount, preventing post-teardown asynchronous work from failing Jest.
   Update physical-device selectors for iOS accessibility `tab`/`Other` elements
   and verify the N42 backup safety gate without opening the seed phrase.

## Automated verification

| Check | Final result |
| --- | --- |
| N42 `flutter test --coverage` | 3603 passed |
| N42 chat package tests | 435 passed |
| N42 LiveKit JWT Go tests | Passed |
| N42 `flutter analyze --no-fatal-infos` | Exit 0; 139 info diagnostics, no warnings/errors |
| N42 raw LCOV line coverage | 18,359 / 120,624 = **15.22%**, below configured 70% gate |
| Minto consumer Jest | 62 suites; 358 passed, 5 skipped after accessibility follow-up; final command exit 0 |
| Minto consumer TypeScript and lint | Passed |
| Minto backend unit Vitest | 214 files; 3616 passed |
| Minto shared/deployment tests | 9 files; 157 passed |
| 11X Jest | 119 suites; 1939 passed, 28 todo; 21 snapshots passed |
| 11X iOS/Android/web TypeScript | All three passed |
| 11X lint | Passed |
| Three iOS Release builds | Passed; signatures verified |

Minto backend's initial concurrent run had one 10-second timeout in a 501-session
expiry-worker fixture. The isolated suite passed (63 tests), and a complete
two-worker rerun passed all 3616 tests. No timeout threshold was loosened.
Minto's first final consumer run exposed an obsolete refresh-token expectation;
the next run exposed a root-layout test teardown error despite green assertions.
Both were corrected before the clean final run. React `act` warnings in other
existing tests remain; they are not being presented as production exceptions.

Backend unit command excluded `**/__tests__/integration/**` and
`**/__tests__/payment-session-concurrency.test.ts`, matching the unit/integration
boundary. Real-database integration tests were not run against user services.

## Physical devices and installed packages

| Device | OS | N42 | Mintus | 11X |
| --- | --- | --- | --- | --- |
| iPhone 13 Pro Max, Sitian's iPhone | iOS 26.6 | `2.4.8 (2026072637)` installed | `0.2.1 (2234)` installed | `1.131.1 (23169)` installed |
| iPhone 17 Pro Max | iOS 27 beta, 24A5424a | `2.4.8 (2026072637)` installed | `0.2.1 (2234)` installed | `1.131.1 (23169)` installed |

Existing user data was preserved. Mintus was built with the staging backend
configuration (`merchant-test.mintus.world`). Xcode reports iPhone 17 transport
as `localNetwork`, so this is not evidence of an exclusively USB network path.

### Device execution status

- iPhone 17 first corrected run: **6 passed, 2 failed, 0 skipped**. Passed:
  three-app cold launch/background recovery, N42 primary tabs and wallet scroll,
  N42 send/receive backup gates, 11X repeated sheet open/drag/reopen, 60 feed
  scrolls with post-scroll responsiveness, and identity center access.
- The initial two failures were accessibility selector mismatches: the recovery link
  is an `Other` element, and the first wallet `Button` was in an offscreen drawer
  while the actual bottom wallet tab is an `Other` element. Corrected selectors
  and reran both routes. Recovery form now passes. The wallet page also opens;
  the subsequent profile step reaches the account-suspension screen instead of
  the expected profile header, and remains a failing end-to-end case.
- Extended run: **2 passed, 3 failed, 1 skipped**. Minto login/recovery and 11X
  lightbox double-tap, drag, pinch and dismissal pass. Profile fails due to the
  suspended account, Works share fails because both lists cannot load, and
  keyboard avoidance initially fails because the old script tapped the empty
  home-search button instead of entering and submitting a query. Corrected the
  search entry and reran it. Pull-to-refresh measurement is explicitly
  skipped because XCTest exposes neither content offset nor the refresh control;
  the gesture alone is not proof that refresh completed.
- Final-package cross-app run: **all 5 `ThreeAppAuditTests` passed**. This includes
  N42 chat Contacts/Discover/Me navigation and return to the host wallet in
  addition to launch/resume, login/recovery, primary navigation and backup gates.
- The corrected search test reached search results and the advanced-filter
  sheet. Its first measurement attempt failed to locate a keyboard frame.
  Screenshot inspection shows the third-party keyboard present and the query
  field above it; the app accessibility tree confirms the query has keyboard
  focus, but neither app nor SpringBoard exposes a `Keyboard` element. The
  subsequent test explicitly records **1 skipped**, not passed. Repeat with an
  accessible system keyboard for automated appearance/dismissal geometry checks.
- iPhone 13: install/signature checks passed, but both automation attempts failed
  before tests initialized. The device displays **“为 XCTest 输入 iPhone 密码 /
  Enable UI Automation”**. Ordinary lock state is unlocked; this separate OS
  authorization still requires the owner to enter the passcode on the phone.
  Independent developer-service launches and screenshots verified N42's wallet,
  Mintus's preserved signed-in wallet/assets, and the 11X home feed render after
  the final installs. This is a launch smoke check, not an interactive UI pass.

Latest outcome by distinct iPhone 17 case: **9 passed, 2 failed (suspended profile
and missing Works APIs), 2 skipped (keyboard geometry and refresh measurement)**.
These outcomes combine the relevant result bundles; they are not a fabricated
single all-green run. Both device inventories independently confirm all three
installed bundle versions listed above.
The final baseline/login selector-maintenance rerun also passed both cases;
the baseline now accepts a preserved signed-in Mintus wallet without requiring
logout merely to run startup checks.

### Confirmed service/account blockers

The iPhone 17 profile screenshot displays “你的账户已被冻结”. Source routes the
current profile to this screen when `isAccountSuspendedError(profileError)` is
true. No restriction was removed and no logout was performed.

Read-only unauthenticated probes to the configured 11X production API returned
HTTP 404 for both `GET /pds/works/novels?page=1&pageSize=30` and
`GET /pds/works/dramas?page=1&pageSize=30` on `https://pro.si46.world`.
The body reports `Cannot GET` for the corresponding route. This agrees with the
physical device's retry/error state and existing 11X QA reports of unavailable
Works routes. No alternative endpoint was invented and no backend deployment
was performed. List/detail/share/purchase testing needs the service route fixed.

## Owner-authorized iPhone 13 follow-up (23:14 local time)

After the owner confirmed authorization, XCTest initialized and executed real
UI interactions on the iPhone 13. The previous automation-permission blocker is
resolved; the historical failed initialization bundles above are retained.

The first authorized run executed 9 cases: 6 passed, 2 failed, 1 skipped.
Passed: three-app launch/resume, N42 primary navigation and backup gates, 11X
wallet/profile navigation, repeated post-sheet interactions, and identity center.
Unlike the iPhone 17 account, this phone's 11X profile opens normally.
N42 chat was initially signed out during the first authorized run. After the
owner signed in, the focused rerun passed Contacts, Discover and Me navigation
and returned to the wallet host. No messages were sent. Minto login/recovery is
skipped on this already signed-in phone, preserving its account.

The other first-run failure was an XCTest hit-point error after 60 feed scrolls:
the script selected an offscreen virtualized post-menu node. The helper now
filters menu instances by a nonzero onscreen frame before testing hittability.
This is a test-harness correction, not evidence of an app crash.

Additional Minto testing identified an actual accessibility omission: the
shared icon-only back control had no button role or spoken label. Added a
localized `common.back` label, button role and stable test identifier, with two
regression cases. Consumer Jest now passes **358 tests in 62 suites**, with the
same 5 pre-existing skips; TypeScript and targeted ESLint also pass. The updated
Release package was rebuilt, signature-verified and installed on both phones.
On iPhone 13, explicit localized Back-button navigation from Receive now passes,
as do incomplete-payment submission blocking, Messages/Me/Wallet tab navigation,
and transaction-history navigation/scroll. Receive's screenshot also shows an
actual QR code rather than its loading or unavailable state; no payment was sent.
The updated iPhone 17 package again passes login/recovery-form testing.

11X's corrected long-list run completed all 60 scrolls and reopened a post menu.
Lightbox gestures also pass. Keyboard geometry and refresh measurement remain
explicitly skipped on the second phone for the same automation observability
limits as the first. N42's signed-in chat tabs and return to the host now pass on
this phone.

The Minto payment screenshot and accessibility tree explicitly report **“You
have no transferable cards yet”** with **Confirm payment disabled**. Wallet assets
shown on the home screen are not proof of transfer eligibility: source code
requires personal assets with `allowedActions.canTransfer === true`. The initial
over-balance test assumed an eligible card and failed to find a balance field.
The corrected fixture check records this prerequisite separately; no account or
asset permissions were changed to make the test pass.

The follow-up re-probed both 11X Works endpoints; both still return HTTP 404.

Final iPhone 13 outcome, retaining the latest result of each distinct case:
**13 passed, 4 skipped, 0 remaining failed cases**. The four skips are Minto's
signed-out login/recovery flow on a signed-in device, Minto over-balance
validation without a transferable card, keyboard geometry, and pull-to-refresh
measurement. These are incomplete coverage, not passes.
The totals combine `authorized-ui-13`, `authorized-extended-ui-13`,
`authorized-minto-ui-13`, and `authorized-card-fixture-ui-13` result bundles;
intermediate failures remain available as evidence. The new-package iPhone 17
login/recovery check is in `authorized-minto-ui-17.xcresult` (1 passed).

## Limits and follow-up

- Not a complete release approval: some flows still require appropriate test
  accounts/assets, 11X has service blockers and an account restriction on the
  iPhone 17, and N42's measured coverage is below its gate.
- No real transfers, paid purchases, posts, outbound chat messages, seed-phrase
  display, account deletion or password-reset submissions were performed.
- Minto authenticated UI checks run on the already signed-in iPhone 13;
  authenticated iPhone 17 checks need a designated test login. N42 real
  signing/payment flows require backed-up
  test-wallet fixtures and approved test funds, not bypassing the safety gate.
- Unit/mocked tests do not validate APNs delivery, biometric success, camera QR
  scanning, calls/media delivery between both phones, real payment settlement,
  all network-failure modes, battery/performance soak, or every OS/device variant.
- No TestFlight upload or commit/push was performed in this audit turn.

## Evidence

Local logs, screenshots, accessibility trees and `.xcresult` bundles:
`build/audits/2026-09-04-three-apps/` (Git-ignored local evidence).
Original execution directory: `/tmp/n42-three-app-audit-20260904.uWVYzG`.
Device test source: `../11x/ios-uitests/X11UITests/X11UITests.swift`.
Raw device artifacts may contain existing user content and are intentionally
not committed.
