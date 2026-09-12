# Settings follow-up — 2026-09-12

## Behavior changes

The direct Settings route previously supplied none of the optional navigation callbacks. Notifications, Appearance, Chat, Language, password and email could look actionable while doing nothing. Profile supplied most callbacks separately, but its Chat row was also unconnected.

- `SettingsNavigation` now composes default routes, loads saved appearance/notification preferences, preserves the existing route-scoped AuthBloc across navigation boundaries, and checks authentication before password/email/account routes. Host callbacks retain precedence.
- Profile uses the same settings composition and supplies its profile editor. Settings cards without an editor no longer display an actionable chevron. Phone numbers remain masked while privacy preferences are loading or fail to load.
- Chat settings groups global background, quick replies, translation and auto-download. Existing direct shortcuts remain available.
- Notification and appearance pages persist by default and await custom save callbacks. While saving, further input is blocked to avoid concurrent writes; failures restore the last confirmed settings and display localized feedback. Slider movement previews locally and commits once at release.
- Platform `false` writes now fail explicitly and reload the optimistic preferences cache. Account and notification-filter load errors offer Retry; filter writes roll back and update the running push filter only after a successful save.
- Account hub navigation passes through the same auth-preserving route helper. Notification summary updates only after a successful save.
- Settings root titles and notification privacy/filter labels use six new localized messages across all 26 catalogs. Backup reuses an existing translation. Redundant explanatory subtitles were removed.
- Verified Flutter’s automatic RTL chevron mirroring; manual double mirroring was removed during screenshot review. Appearance sections use Material surfaces so backgrounds do not hide ListTile ink feedback.

## Automated evidence

`settings_navigation_test.dart` covers direct routes, Chat category destinations, override precedence, authenticated and unauthenticated actions, preference read errors, logout confirmation, multi-hop auth propagation and real account/privacy hub entry.

`settings_persistence_test.dart` covers save/reopen, delayed failure and retry, privacy-mode persistence, appearance rollback, slider commit/rollback, rejection after disposal, phone masking during preference failure, and Arabic at 320 logical pixels with 1.6× text scaling.

`nested_settings_failure_test.dart` and `settings_write_failure_test.dart` cover retryable account/filter reads, serialized filter saves, keyword persistence, disposal, and both `false` and thrown platform-write failures with cache restoration. The targeted settings run passed **41 tests** (40 new tests plus the existing About regression).

Full-suite and coverage totals are recorded in `COVERAGE_AUDIT_2026-09-12.md`. Flutter analysis reports **0 errors, 0 warnings, 173 existing informational diagnostics**. The first full coverage run exhausted the shell’s 256-file limit and was stopped; the retry uses `ulimit -n 4096`; the final committed-source run uses `--concurrency=6` and passed 5,867 tests with one live-credentials skip. Settings-page coverage increased from 13.93% to 42.05%; raw plugin coverage increased from 17.97% to 19.23%.

## Boundaries

These are unit/widget tests with local preferences and mocked authentication. No real password/email/account mutation, push delivery or device settings migration is claimed. The already logged-in iPhone and Android installations were not replaced for this module.

Nested system/privacy hub text and other direct literals remain in the localization backlog. `OPEN_ISSUES.md` remains the single source of unresolved issues.
