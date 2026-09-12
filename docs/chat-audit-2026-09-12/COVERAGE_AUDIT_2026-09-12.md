# Chat coverage audit — 2026-09-12

Full plugin suite at `a3b4a13`: **5,826 passed; one credential-dependent live smoke skipped**. This is an execution count, not a feature-completeness claim. Test-only warning cleanup was then verified by 333 passing targeted tests.

| Scope | Covered lines | Instrumented lines | Coverage |
|---|---:|---:|---:|
| Raw lcov (includes generated code) | 23507 | 130813 | 17.97% |
| Excluding l10n/generated/g.dart/freezed.dart | 22975 | 79128 | 29.04% |

The exclusion view is informational; CI thresholds were not changed. Raw coverage is retained as a separate figure, not replaced by a higher filtered number.

## Non-generated module breakdown

| Module | Covered | Instrumented | Coverage |
|---|---:|---:|---:|
| data/datasources | 1494 | 6462 | 23.12% |
| core/utils | 1187 | 1548 | 76.68% |
| core/services | 1807 | 5078 | 35.58% |
| domain/entities | 2924 | 3417 | 85.57% |
| core/constants | 4 | 4 | 100.00% |
| core/extensions | 61 | 126 | 48.41% |
| core/theme | 188 | 261 | 72.03% |
| lib/src/n42_chat_config.dart | 132 | 133 | 99.25% |
| integration/api_hub_bridge.dart | 0 | 6 | 0.00% |
| integration/wallet_bridge.dart | 28 | 47 | 59.57% |
| presentation/blocs | 4262 | 6596 | 64.61% |
| presentation/pages | 6371 | 37560 | 16.96% |
| presentation/widgets | 2260 | 8960 | 25.22% |
| data/models | 29 | 223 | 13.00% |
| core/encryption | 39 | 324 | 12.04% |
| core/di | 3 | 496 | 0.60% |
| core/router | 60 | 305 | 19.67% |
| lib/src/n42_chat.dart | 33 | 366 | 9.02% |
| core/notifications | 407 | 731 | 55.68% |
| data/repositories | 884 | 3064 | 28.85% |
| domain/repositories | 11 | 29 | 37.93% |
| services/voip | 475 | 2035 | 23.34% |
| domain/protocols | 2 | 59 | 3.39% |
| data/protocols | 0 | 103 | 0.00% |
| data/mappers | 1 | 50 | 2.00% |
| integration/bridge | 104 | 274 | 37.96% |
| services/auth | 38 | 448 | 8.48% |
| presentation/helpers | 170 | 373 | 45.58% |
| services/ringtone | 1 | 50 | 2.00% |

The largest remaining gaps are UI pages, native/Matrix adapters, DI and encrypted multi-device flows. Prioritize real route/callback/permission/error-recovery tests. Broad widget construction counts cannot certify delivery, storage or provider behavior.


## Settings follow-up at `16fe83a`

The final committed source passed **5,867 tests; one credential-dependent live smoke skipped**. The settings batch adds 40 behavior tests; the focused run including the existing About test passed 41.

Command: `ulimit -n 4096; flutter test --no-pub --coverage --concurrency=6 --reporter expanded`. The initial 256-file shell limit was exhausted; no coverage from that interrupted run is reported here.

| Scope | First audit baseline | Settings follow-up |
|---|---:|---:|
| Raw lcov (including generated code) | 23,507/130,813 (17.97%) | 25,212/131,079 (19.23%) |
| Non-generated reference view | 22,975/79,128 (29.04%) | 24,584/79,238 (31.03%) |
| Settings pages | 664/4,768 (13.93%) | 2,067/4,916 (42.05%) |
| Preferences data source | 500/656 (76.22%) | 502/658 (76.29%) |
| Notification filter store | 0/6 (0.00%) | 6/6 (100.00%) |

The raw total remains below the 70% CI target; the target and generated-code exclusions were not changed. The reference view is not used to replace the raw figure.

Changed/new settings navigation and persistence surfaces:

| Source | Covered/instrumented |
|---|---:|
| `lib/src/core/utils/preference_write_utils.dart` | 4/4 (100.00%) |
| `lib/src/presentation/pages/settings/account_switch_page.dart` | 47/106 (44.34%) |
| `lib/src/presentation/pages/settings/appearance_settings_page.dart` | 171/180 (95.00%) |
| `lib/src/presentation/pages/settings/chat_settings_page.dart` | 32/33 (96.97%) |
| `lib/src/presentation/pages/settings/notification_filter_page.dart` | 122/147 (82.99%) |
| `lib/src/presentation/pages/settings/notification_settings_page.dart` | 142/195 (72.82%) |
| `lib/src/presentation/pages/settings/settings_navigation.dart` | 40/42 (95.24%) |
| `lib/src/presentation/pages/settings/settings_page.dart` | 185/244 (75.82%) |
| `lib/src/presentation/pages/settings/system_accounts_page.dart` | 91/149 (61.07%) |
