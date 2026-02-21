# Production Readiness Audit: n42_chat (Flutter/Dart)
Generated: 2026-02-21

| Area | Issue | Severity | File:Line |
|------|-------|----------|-----------|
| Null Safety | `!` on config.giphyApiKey / config.aiApiKey without existence check | **Critical** | injection.dart:162, 269 |
| Null Safety | Chained null-force `_client!.userID!` in critical path | **Critical** | username_service.dart:208 |
| Null Safety | Multiple `!` operators in push token handling | **Critical** | firebase_push_service.dart:241, 249, 760, 763, 792, 869-870 |
| Error Handling | Catch blocks log only via `debugPrint()` — no production telemetry | **High** | matrix_search_datasource.dart:31-33, 49-51, 168-171 |
| Error Handling | Silent error suppression in search/query returns empty list | **High** | matrix_search_datasource.dart:22-34 |
| Error Handling | `debugPrint` in AI datasource exception handler | **High** | ai_datasource.dart:120-123 |
| Configuration | No startup validation for API keys / endpoints | **High** | injection.dart:157-165, 266-274 |
| TODO / Incomplete | 3PID binding flow incomplete | **High** | auth_repository_impl.dart |
| TODO / Incomplete | Sticker store API not implemented | **High** | sticker_repository_impl.dart:38-40 |
| TODO / Incomplete | 8 TODO(backend) comments in chat_page.dart | **High** | chat_page.dart |
| Hardcoded Values | Default homeserver: `https://matrix.org` | **Medium** | app_constants.dart:23 |
| Hardcoded Values | Sync timeout: 30 s | **Medium** | app_constants.dart:34 |
| Hardcoded Values | Retry limits: maxRetryCount=3, retryDelayMs=1000 | **Medium** | app_constants.dart:40, 43 |
| Hardcoded Values | Max message length: 10000 (no backend validation) | **Medium** | app_constants.dart:59 |
| Hardcoded Values | Dio connect/receive timeouts: 30 s / 3 min | **Medium** | ai_datasource.dart:33-34 |
| Hardcoded Values | `https://translation.googleapis.com` endpoint hardcoded | **Medium** | translation_service.dart:88-89 |
| Hardcoded Values | Max concurrent downloads: 3 (not configurable) | **Low** | download_service.dart:54 |
| Test Coverage | 179 test files vs 392 lib files → 45.6% file coverage | **Medium** | test/ |
| Stream Management | 61 StreamController/StreamSubscription instances — cleanup not documented | **Medium** | Multiple services |
| Async Error Propagation | Background sync errors caught but not escalated | **Medium** | auth_repository_impl.dart:121-123 |
| Async Error Propagation | Fire-and-forget AI operations without error tracking | **Medium** | chat_page.dart |
| E2EE | 15+ catch blocks in e2ee_manager log-and-continue | **Medium** | e2ee_manager.dart |
| Search | Search history local storage not implemented | **Medium** | matrix_search_datasource.dart:239-251 |

## Totals: Critical 3 · High 8 · Medium 13 · Low 1
