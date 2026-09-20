# Chat UI plan completion — 2026-09-20

## Scope and outcome

The approved [chat, contacts and account switching plan](../chat-ux-2026-09-19.md) is implemented. This final pass completes the shared visual language, touch targets, responsive layouts and accessibility behavior on top of the earlier interaction and feedback fixes.

Chat dependency: `ae51faceaa98c2c499a3b9084ac4cf423670eaff`.

| Planned area | Completed behavior |
| --- | --- |
| Chat organization | All / Unread / Groups filters, pinned ordering, muted unread visibility, recoverable empty/error states and completed-refresh feedback. |
| Search | Shared rounded search surface in messages and contacts; visible focus, clear/cancel controls, disabled-state handling and safe external controller/focus-node replacement. Stale searches cannot overwrite newer input. |
| Conversation list | Consistent avatar/spacing/type tokens, localized draft label, expanding rows for enlarged text and readable supporting text in both themes. |
| Composer and attachments | 48-point send/tool targets, visible press feedback, responsive scrollable attachment grids and accessible unavailable actions. |
| Contact identity and requests | Search and contact entries open profiles; sent/received requests and busy states remain explicit. Tags open their members; starred contacts have a dedicated section without duplicates. |
| Contact index | Full search/star/A–Z/# rail with reserved list space; standard icons, compact two-column layout on short screens, drag preview and adjustable screen-reader semantics. |
| Navigation | Shared navigation with selected icons, tint and semantics; 99+ visual cap with exact spoken counts; friend/group request totals update together. Labels wrap on narrow screens with large text. |
| Accounts | Active identity in an expanding toolbar; separate account cards show user ID/server/current/switching state. Actions serialize, calls block switching, and switch errors stay visible above the list. Account-scoped roots preserve isolation. |
| Calls and unreadable messages | Existing return-to-call banner and accessible delivery/retry actions retained. Missing-key explanations and recovery options remain accurate; UI changes do not recreate lost keys. |
| Empty states and localization | Retry/actions remain reachable on short screens; new labels translated in English, Simplified/Traditional Chinese, German, French, Spanish, Italian and Portuguese/Brazilian Portuguese. Other catalogs explicitly retain English fallbacks. |

## Validation

- Targeted interaction regression: 42 passed; an additional final 10-test run verifies the composer with all tool buttons enabled at 320-point width.
- Chat analyzer: zero errors/warnings; 269 informational diagnostics.
- Host Chat regression: **984 passed**.
- Host analyzer: **zero errors/warnings**, 253 informational diagnostics.
- Dependency consistency: all **791** resolved Chat library/asset files match the host mirror.
- Supporting-text contrast checks cover both themes against surface and input backgrounds (at least 4.5:1).
- Widget checks cover controller ownership, disabled search, badge updates, selected semantics, large text up to 200%, compact index gestures/accessibility adjustment, persistent account errors and reachable retry controls.

## Visual review

These are Flutter widget fixtures with synthetic accounts and local fonts, not captures from deployed phones. Light/dark screenshots were inspected; an observed index/chevron overlap was corrected and recaptured.

| Surface | Light | Dark |
| --- | --- | --- |
| Messages | [Preview](messages-light.png) | [Preview](messages-dark.png) |
| Contacts and navigation | [Preview](contacts-light.png) | [Preview](contacts-dark.png) |
| Composer at enlarged text | [Preview](composer-light.png) | [Preview](composer-dark.png) |
| Account selector | [Preview](accounts-light.png) | [Preview](accounts-dark.png) |
| Requests / return to call | [Preview](requests-light.png) | [Preview](requests-dark.png) |
| Short-screen menu | [Preview](menu-light.png) | [Preview](menu-dark.png) |

## Release and device acceptance

The UI implementation and automated checks are complete. This pass does not upload a new TestFlight build or create a new APK; previously uploaded build 2026072696 predates this final polish.

Native VoiceOver/TalkBack, keyboard/safe-area behavior, account push re-registration and restart persistence still need acceptance on the feedback phones. These verification gaps remain in the Chat repository's `OPEN_ISSUES.md` (QA-005/QA-009); translation review remains in QA-006. Existing encryption recovery limitations are not marked resolved by UI testing.
