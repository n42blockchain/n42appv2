# Chat Plugin Full Review Plan

## Scope

- Repository: `n42_chat`
- Review target: full plugin source, tests, wiring, runtime flows, and integration boundaries
- Source files counted: `534`
- Test files counted: `231`
- High-churn areas:
  - `lib/src/presentation/pages`: `168`
  - `lib/src/presentation/blocs`: `79`
  - `lib/src/presentation/widgets`: `76`
  - `lib/src/data`: `65`
  - `lib/src/core`: `63`

## Previously Reviewed By Codex

These areas were already handled recently and must be treated as "revalidate, do not restart from zero":

- AI proxy endpoint integration
- Giphy proxy integration
- Speech proxy integration
- Market `/price` proxy integration
- DeBank proxy integration
- Alchemy social graph proxy integration
- Social graph proxy auth injection
- App-side host wiring in `n42appv2`

Primary files already touched in recent work:

- `lib/src/n42_chat_config.dart`
- `lib/src/core/di/injection.dart`
- `lib/src/core/services/giphy_service.dart`
- `lib/src/core/services/speech_to_text_service.dart`
- `lib/src/core/services/bot_command_processor.dart`
- `lib/src/data/datasources/ai_datasource.dart`
- `lib/src/data/datasources/social/debank_datasource.dart`
- `lib/src/data/datasources/social/alchemy_social_datasource.dart`
- `lib/src/presentation/pages/chat/chat_page.dart`

## Review Goals

For every module:

1. Check architecture boundaries and dependency direction.
2. Find bugs, unsafe assumptions, stale contracts, duplicated logic, and missing tests.
3. Fix issues in small reviewable batches.
4. Add or update tests for each fix.
5. Run targeted verification before moving to the next module.

## Execution Log

### 2026-03-16 - Phase 1 batch A completed

Reviewed:

- `lib/src/n42_chat.dart`
- `lib/src/n42_chat_config.dart`
- `lib/src/core/di/injection.dart`
- `lib/src/core/router/app_router.dart`
- `lib/src/integration/bridge/bridge_bot_service.dart`

Fixed:

- `N42Chat.dispose()` was not actually disposing `CallManager`; cleanup now uses the runtime singleton, cancels TURN refresh, clears pending notification state, and resets router state.
- DI now disposes long-lived services on `resetDependencies()` for `MatrixClientManager`, `VoiceService`, `GiphyService`, `AiService`, `DownloadService`, `MediaLifecycleService`, `StorageMonitorService`, and `VoiceRoomService`.
- `N42ChatConfig.copyWith()` now supports explicitly clearing nullable fields back to `null` instead of silently preserving stale keys, callbacks, or bridges.
- Router debug logging is now configured explicitly from `N42Chat.initialize()` instead of being always-on.
- `BridgeBotService` now rejects concurrent commands per management room, completes pending requests on dispose, and correctly parses usernames from `logged in as <user>` messages that end at end-of-line.

Tests added or updated:

- `test/unit/config/n42_chat_config_test.dart`
- `test/unit/core/app_router_test.dart`
- `test/unit/integration/bridge_bot_service_test.dart`

Verification:

- `flutter test test/unit/config/n42_chat_config_test.dart test/unit/core/app_router_test.dart`
- `flutter test test/unit/integration/bridge_bot_service_test.dart`
- `flutter analyze lib/src/n42_chat.dart lib/src/core/di/injection.dart lib/src/core/router/app_router.dart lib/src/n42_chat_config.dart test/unit/config/n42_chat_config_test.dart test/unit/core/app_router_test.dart`
- `flutter analyze lib/src/integration/bridge/bridge_bot_service.dart test/unit/integration/bridge_bot_service_test.dart`

### 2026-03-16 - Phase 1 batch B completed

Reviewed:

- `lib/src/core/constants/app_constants.dart`
- `lib/src/presentation/pages/auth/login_page.dart`
- `lib/src/presentation/pages/auth/register_page.dart`
- `example/lib/server_test_page.dart`
- `tool/server_test.dart`

Fixed:

- Unified homeserver defaults so config constants, login/register flows, and example tooling all use the same Matrix base server.
- Updated example and CLI Matrix client setup to the current SDK contract by wiring `MatrixSdkDatabase.init(...)` instead of relying on removed constructor defaults.
- Replaced removed `setDisplayName` helper usage in examples with a direct profile `PUT` request.
- Updated secure-storage tests to the current credential model that intentionally stores only `homeserver + username`.

Tests added or updated:

- `test/unit/core/app_constants_test.dart`
- `test/unit/datasources/secure_storage_datasource_test.dart`

Verification:

- `flutter test test/unit/core/app_constants_test.dart test/unit/datasources/secure_storage_datasource_test.dart`
- `flutter analyze tool/server_test.dart example/lib/server_test_page.dart test/unit/datasources/secure_storage_datasource_test.dart test/unit/core/app_constants_test.dart lib/src/core/constants/app_constants.dart lib/src/presentation/pages/auth/login_page.dart lib/src/presentation/pages/auth/register_page.dart`

### 2026-03-16 - Phase 2 batch completed

Reviewed:

- `lib/src/core/services/chat_backup_service.dart`
- `lib/src/services/auth/auth_methods_service.dart`
- `lib/src/core/services/biometric_service.dart`
- `lib/src/core/services/chat_lock_service.dart`
- `lib/src/data/datasources/local/preferences_datasource.dart`

Fixed:

- Backup files now carry a checksum, restore/verify paths validate it, encrypted backups reject invalid passwords cleanly, and incremental backups deduplicate events by `eventId`.
- WeChat auth initialization now registers a single response listener, disposes it correctly, and blocks concurrent sign-in attempts instead of overwriting an in-flight completer.
- Biometric availability now requires both device support and enrolled biometrics, avoiding false-positive enablement on devices with no enrolled credential.
- Chinese weekday labels now use the compact `周一`...`周日` format expected by the rest of the UI and tests.

Tests added or updated:

- `test/unit/services/chat_backup_service_test.dart`
- `test/unit/services/biometric_service_test.dart`
- `test/unit/utils/date_utils_test.dart`

Verification:

- `flutter test test/unit/services/chat_backup_service_test.dart test/unit/services/biometric_service_test.dart test/unit/services/auth_methods_service_test.dart test/unit/services/chat_lock_service_test.dart`
- `flutter analyze lib/src/core/services/chat_backup_service.dart lib/src/services/auth/auth_methods_service.dart lib/src/core/services/biometric_service.dart test/unit/services/chat_backup_service_test.dart test/unit/services/biometric_service_test.dart test/unit/services/auth_methods_service_test.dart test/unit/services/chat_lock_service_test.dart`

### 2026-03-16 - Regression stabilization completed

Reviewed:

- `lib/src/presentation/pages/discover/discover_page.dart`
- `lib/src/presentation/pages/social/social_graph_page.dart`
- `test/presentation/pages/discover_page_test.dart`
- `test/presentation/pages/social_graph_page_test.dart`
- `test/unit/config/voip_config_test.dart`
- `test/unit/services/voip_audio_processing_test.dart`

Fixed:

- Discover page tests were updated to the current visible menu contract, including the enabled channel-discovery entry.
- Discover page no longer logs provider errors when `MomentBloc` is intentionally absent in lightweight hosts or tests.
- VoIP call-recording expectations were aligned with the current product behavior: recording stays disabled by default until the backend egress path is wired.
- Social graph navigation test now uses bounded route pumping instead of `pumpAndSettle()` against a page that intentionally shows an indeterminate loading spinner.

Verification:

- `flutter test test/unit/utils/date_utils_test.dart test/unit/config/voip_config_test.dart test/unit/services/voip_audio_processing_test.dart test/presentation/pages/discover_page_test.dart`
- `flutter test test/presentation/pages/social_graph_page_test.dart`
- `flutter test -r compact`
- `flutter analyze`

Residual debt:

- `flutter analyze` still reports existing test-lint warnings (`prefer_const_constructors`, raw generic inference, `avoid_print`, unused imports, etc.) across unrelated test files.
- No new analyzer errors or failing tests remain after the fixes above.

### 2026-03-16 - Phase 3 transport review and final hardening completed

Reviewed:

- `lib/src/data/datasources/matrix/message/matrix_message_sender.dart`
- `lib/src/data/datasources/matrix/message/matrix_message_operations.dart`
- `lib/src/data/datasources/matrix/matrix_message_datasource.dart`
- `lib/src/data/repositories/message_repository_impl.dart`
- `lib/src/domain/repositories/message_repository.dart`
- `lib/src/presentation/blocs/chat/chat_event.dart`
- `lib/src/presentation/blocs/chat/chat_bloc_send_handlers.part.dart`
- `lib/src/presentation/blocs/chat/chat_bloc_action_handlers.part.dart`

Fixed:

- Reply sends now preserve `selfDestructAfter`, `mentionedUserIds`, and `mentionsRoom` instead of silently dropping them on the reply path.
- Added a shared Matrix text-content builder so normal sends and reply sends use the same `m.mentions` and `n42.self_destruct` contract.
- Reply sends that carry extra metadata now manually preserve the reply-target mention while still attaching the Matrix reply relation.
- Chat bloc reply events now accept and forward the same optional metadata as standard text sends, keeping the send API consistent.

Tests added or updated:

- `test/unit/blocs/chat_bloc_test.dart`
- `test/unit/blocs/chat_bloc_extended_test.dart`
- `test/unit/blocs/chat_event_test.dart`
- `test/unit/repositories/message_repository_impl_test.dart`

Verification:

- `flutter test test/unit/blocs/chat_bloc_test.dart test/unit/blocs/chat_bloc_extended_test.dart test/unit/blocs/chat_event_test.dart test/unit/repositories/message_repository_impl_test.dart`
- `flutter analyze lib/src/data/datasources/matrix/message/matrix_message_operations.dart lib/src/data/datasources/matrix/message/matrix_message_sender.dart lib/src/data/datasources/matrix/message/matrix_text_message_content.dart lib/src/data/datasources/matrix/matrix_message_datasource.dart lib/src/domain/repositories/message_repository.dart lib/src/data/repositories/message_repository_impl.dart lib/src/presentation/blocs/chat/chat_event.dart lib/src/presentation/blocs/chat/chat_bloc_send_handlers.part.dart lib/src/presentation/blocs/chat/chat_bloc_action_handlers.part.dart test/unit/blocs/chat_bloc_test.dart test/unit/blocs/chat_bloc_extended_test.dart test/unit/blocs/chat_event_test.dart test/unit/repositories/message_repository_impl_test.dart`
- `flutter test -r compact`
- `flutter analyze`

Residual debt:

- Full-suite `flutter analyze` still reports the previously known `123` warnings/infos across unrelated files; there are still no analyzer errors.
- The repository remains on a dirty worktree with unrelated user changes outside this review scope.

### 2026-03-16 - Grouped worktree audit and optimization pass completed

Reviewed:

- `lib/src/core/services/mini_app_bridge_service.dart`
- `lib/src/core/services/bot_command_processor.dart`
- `lib/src/core/services/social_graph_service.dart`
- `lib/src/data/models/social/social_similarity_model.dart`
- `lib/src/presentation/blocs/governance/governance_state.dart`

Fixed / optimized:

- Mini App bridge chat dispatch is now explicit: `sendMessage` no longer risks cascading into the `close` path, and the action parsing logic is isolated into a testable helper.
- Governance proposal filtering can now be cleared back to `null`; previously a selected `filterState` would stick in state even after loading the full proposal list again.
- `/balance` now formats short or non-EVM wallet identifiers safely instead of assuming a 42-character address and risking `substring` range errors.
- Social graph similarity assembly now uses a single weighted-score helper path, avoiding duplicated model construction and keeping score weights centralized.

Tests added or updated:

- `test/unit/services/mini_app_bridge_service_test.dart`
- `test/unit/services/bot_command_processor_test.dart`
- `test/unit/blocs/governance_bloc_test.dart`

Verification:

- `flutter test test/unit/services/mini_app_bridge_service_test.dart test/unit/services/bot_command_processor_test.dart test/unit/blocs/governance_bloc_test.dart test/unit/services/social_graph_service_test.dart`
- `flutter analyze lib/src/core/services/mini_app_bridge_service.dart lib/src/core/services/bot_command_processor.dart lib/src/core/services/social_graph_service.dart lib/src/data/models/social/social_similarity_model.dart lib/src/presentation/blocs/governance/governance_state.dart test/unit/services/mini_app_bridge_service_test.dart test/unit/services/bot_command_processor_test.dart test/unit/blocs/governance_bloc_test.dart test/unit/services/social_graph_service_test.dart`
- `flutter test -r compact`
- `flutter analyze`

## Execution Order

### Phase 0 - Baseline and freeze

- Capture current inventory and existing dirty-worktree boundaries.
- Record which files were already changed by earlier Codex work.
- Do not revert unrelated user changes.

### Phase 1 - Bootstrap, config, DI, and integration boundaries

Review order:

- `lib/src/n42_chat.dart`
- `lib/src/n42_chat_config.dart`
- `lib/src/core/di/injection.dart`
- `lib/src/integration/**`
- `lib/src/core/router/**`
- `lib/src/core/constants/**`

Focus:

- initialization order
- singleton lifecycle
- configuration defaults
- proxy/auth propagation
- route safety
- host-app contract drift

Deliverables:

- config or DI fixes
- lifecycle tests
- integration contract notes

### Phase 2 - Auth, security, encryption, backup, and storage

Review order:

- `lib/src/core/encryption/**`
- `lib/src/services/auth/**`
- `lib/src/core/services/biometric_service.dart`
- `lib/src/core/services/chat_lock_service.dart`
- `lib/src/core/services/chat_backup_service.dart`
- `lib/src/core/services/chat_export_service.dart`
- `lib/src/core/services/archive_*`
- `lib/src/core/services/storage_*`
- `lib/src/core/notifications/**`
- `lib/src/data/datasources/local/**`
- related auth/security/settings pages and blocs

Focus:

- credential handling
- local persistence correctness
- backup/export integrity
- privacy and recovery flows
- device lifecycle cleanup

### Phase 3 - Matrix client and transport layer

Review order:

- `lib/src/data/datasources/matrix/**`
- `lib/src/data/datasources/matrix/message/**`
- `lib/src/data/protocols/**`
- `lib/src/domain/protocols/**`
- `lib/src/services/voip/**` where transport coupling exists

Focus:

- Matrix client initialization
- send/retry/idempotency behavior
- attachment upload pipeline
- thread/poll/reaction consistency
- failure handling

### Phase 4 - Core chat state machine and message flow

Review order:

- `lib/src/presentation/blocs/chat/**`
- `lib/src/presentation/blocs/message_action/**`
- `lib/src/presentation/blocs/thread/**`
- `lib/src/presentation/pages/chat/**`
- `lib/src/presentation/widgets/chat/**`

Focus:

- event/state correctness
- optimistic updates
- retry paths
- menu/action duplication
- editor/input/send flow
- slash command handling

### Phase 5 - Conversation, contacts, groups, spaces, search

Review order:

- `lib/src/presentation/blocs/contact/**`
- `lib/src/presentation/blocs/conversation/**`
- `lib/src/presentation/blocs/group/**`
- `lib/src/presentation/blocs/group_album/**`
- `lib/src/presentation/blocs/search/**`
- `lib/src/presentation/blocs/space/**`
- `lib/src/presentation/pages/contact/**`
- `lib/src/presentation/pages/conversation/**`
- `lib/src/presentation/pages/group/**`
- `lib/src/presentation/pages/search/**`
- `lib/src/presentation/pages/space/**`

Focus:

- list loading and pagination
- membership updates
- permission gates
- folder/tag behavior
- search correctness

### Phase 6 - Media, files, preview, archive, and self-destruct

Review order:

- `lib/src/core/services/download_service.dart`
- `lib/src/core/services/media_lifecycle_service.dart`
- `lib/src/core/services/url_preview_service.dart`
- `lib/src/core/services/self_destruct_service.dart`
- `lib/src/core/services/screenshot_protection_service.dart`
- `lib/src/presentation/pages/media/**`
- media viewer pages
- message item media rendering

Focus:

- file lifecycle
- viewer consistency
- destructive-message edge cases
- preview safety
- platform differences

### Phase 7 - AI, translation, bots, social graph, on-chain add-ons

Review order:

- `lib/src/core/services/ai_service.dart`
- `lib/src/core/services/translation_service.dart`
- `lib/src/core/services/mymemory_translation_service.dart`
- `lib/src/core/services/giphy_service.dart`
- `lib/src/core/services/speech_to_text_service.dart`
- `lib/src/core/services/bot_command_processor.dart`
- `lib/src/core/services/social_graph_service.dart`
- `lib/src/core/services/on_chain_notification_service.dart`
- `lib/src/data/datasources/ai_datasource.dart`
- `lib/src/data/datasources/social/**`
- `lib/src/data/repositories/ai_repository_impl.dart`
- `lib/src/data/repositories/social_graph_repository_impl.dart`
- `lib/src/presentation/blocs/ai_assistant/**`
- `lib/src/presentation/blocs/social/**`
- `lib/src/presentation/pages/ai/**`
- `lib/src/presentation/pages/social/**`

Focus:

- third-party contract drift
- proxy correctness
- prompt safety
- caching behavior
- social graph fallbacks
- command output correctness

### Phase 8 - Wallet, transfer, red packet, bridge, profile identity

Review order:

- `lib/src/integration/wallet_bridge.dart`
- `lib/src/integration/api_hub_bridge.dart`
- `lib/src/integration/bridge/**`
- `lib/src/core/services/red_packet_service.dart`
- `lib/src/presentation/blocs/transfer/**`
- transfer and red-packet pages/widgets
- identity/profile pages that depend on wallet data

Focus:

- payment flow correctness
- bridge isolation
- transfer validation
- wallet null-state safety

### Phase 9 - Calls, voice rooms, notifications, push, and VOIP

Review order:

- `lib/src/services/voip/**`
- `lib/src/core/services/voice_service.dart`
- `lib/src/data/datasources/matrix/matrix_voice_room_datasource.dart`
- `lib/src/data/repositories/voice_room_repository_impl.dart`
- `lib/src/presentation/blocs/voice_room/**`
- call and voice-room pages/widgets

Focus:

- lifecycle cleanup
- incoming call race conditions
- room join/leave stability
- push and in-call UI consistency

### Phase 10 - Secondary features and polish modules

Review order:

- governance
- points
- moments
- stories
- mini apps
- games
- settings/profile/discover

Focus:

- feature isolation
- stale dependencies
- hidden regressions in lower-priority modules

### Phase 11 - Test gap closure and final hardening

- fill missing unit/widget/integration coverage
- run broad analyze/test sweeps
- produce final issue matrix and remediation summary

## Module Inventory Summary

- `core` (`63` files): bootstrap, DI, router, notifications, services, theme, utilities
- `data` (`65` files): datasources, models, repositories, protocol adapters
- `domain` (`64` files): entities, repositories, protocol contracts
- `integration` (`7` files): host bridges
- `presentation/blocs` (`79` files): state machines by feature
- `presentation/pages` (`168` files): feature pages and chat subpages
- `presentation/widgets` (`76` files): reusable feature widgets
- `services` (`9` files): auth, ringtone, VOIP
- `test/unit` (`199` files)
- `test/integration` (`4` files)
- `test/presentation` (`26` files)
- `test/mocks` (`1` file)

## Raw Source Inventory By Module

### core

```text
lib/src/core/constants/app_constants.dart
lib/src/core/di/injection.dart
lib/src/core/encryption/e2ee_manager.dart
lib/src/core/encryption/key_backup_service.dart
lib/src/core/extensions/context_extension.dart
lib/src/core/extensions/string_extension.dart
lib/src/core/notifications/firebase_push_service.dart
lib/src/core/notifications/push_notification_service.dart
lib/src/core/router/app_router.dart
lib/src/core/router/routes.dart
lib/src/core/services/ai_service.dart
lib/src/core/services/archive_integrity_service.dart
lib/src/core/services/archive_search_service.dart
lib/src/core/services/biometric_service.dart
lib/src/core/services/bot_command_processor.dart
lib/src/core/services/chat_backup_service.dart
lib/src/core/services/chat_export_service.dart
lib/src/core/services/chat_lock_service.dart
lib/src/core/services/contact_sync_service.dart
lib/src/core/services/data_tier_service.dart
lib/src/core/services/download_service.dart
lib/src/core/services/ens_cache_service.dart
lib/src/core/services/giphy_service.dart
lib/src/core/services/in_app_notification_service.dart
lib/src/core/services/media_lifecycle_service.dart
lib/src/core/services/message_archive_service.dart
lib/src/core/services/mini_app_bridge_service.dart
lib/src/core/services/mymemory_translation_service.dart
lib/src/core/services/nft_metadata_service.dart
lib/src/core/services/on_chain_notification_service.dart
lib/src/core/services/points_tracking_service.dart
lib/src/core/services/red_packet_service.dart
lib/src/core/services/remark_service.dart
lib/src/core/services/screenshot_protection_service.dart
lib/src/core/services/self_destruct_service.dart
lib/src/core/services/social_graph_service.dart
lib/src/core/services/speech_to_text_service.dart
lib/src/core/services/storage_cleanup_service.dart
lib/src/core/services/storage_manager_service.dart
lib/src/core/services/storage_monitor_service.dart
lib/src/core/services/sync_optimization_service.dart
lib/src/core/services/translation_service.dart
lib/src/core/services/tts_service.dart
lib/src/core/services/url_preview_service.dart
lib/src/core/services/username_service.dart
lib/src/core/services/voice_service.dart
lib/src/core/theme/app_colors.dart
lib/src/core/theme/app_dimensions.dart
lib/src/core/theme/app_text_styles.dart
lib/src/core/theme/chat_background_presets.dart
lib/src/core/theme/n42_chat_theme.dart
lib/src/core/utils/bridge_detection_utils.dart
lib/src/core/utils/date_utils.dart
lib/src/core/utils/debug_log.dart
lib/src/core/utils/face_blur_util.dart
lib/src/core/utils/io_helper.dart
lib/src/core/utils/io_helper_io.dart
lib/src/core/utils/io_helper_web.dart
lib/src/core/utils/matrix_utils.dart
lib/src/core/utils/platform_utils.dart
lib/src/core/utils/responsive_utils.dart
lib/src/core/utils/string_utils.dart
lib/src/core/utils/username_validator.dart
```

### data

```text
lib/src/data/datasources/ai_datasource.dart
lib/src/data/datasources/governance/snapshot_graphql_datasource.dart
lib/src/data/datasources/governance/snapshot_hub_datasource.dart
lib/src/data/datasources/local/archive_database.dart
lib/src/data/datasources/local/archive_database.g.dart
lib/src/data/datasources/local/local_red_packet_service.dart
lib/src/data/datasources/local/media_metadata_database.dart
lib/src/data/datasources/local/media_metadata_database.g.dart
lib/src/data/datasources/local/preferences_datasource.dart
lib/src/data/datasources/local/secure_storage_datasource.dart
lib/src/data/datasources/matrix/matrix_auth_datasource.dart
lib/src/data/datasources/matrix/matrix_client_manager.dart
lib/src/data/datasources/matrix/matrix_contact_datasource.dart
lib/src/data/datasources/matrix/matrix_group_datasource.dart
lib/src/data/datasources/matrix/matrix_message_datasource.dart
lib/src/data/datasources/matrix/matrix_moment_datasource.dart
lib/src/data/datasources/matrix/matrix_reaction_datasource.dart
lib/src/data/datasources/matrix/matrix_room_datasource.dart
lib/src/data/datasources/matrix/matrix_search_datasource.dart
lib/src/data/datasources/matrix/matrix_space_datasource.dart
lib/src/data/datasources/matrix/matrix_sticker_datasource.dart
lib/src/data/datasources/matrix/matrix_story_datasource.dart
lib/src/data/datasources/matrix/matrix_voice_room_datasource.dart
lib/src/data/datasources/matrix/message/matrix_event_mapper.dart
lib/src/data/datasources/matrix/message/matrix_media_sender.dart
lib/src/data/datasources/matrix/message/matrix_media_uploader.dart
lib/src/data/datasources/matrix/message/matrix_message_operations.dart
lib/src/data/datasources/matrix/message/matrix_message_sender.dart
lib/src/data/datasources/matrix/message/matrix_metadata_extractor.dart
lib/src/data/datasources/matrix/message/matrix_poll_handler.dart
lib/src/data/datasources/matrix/message/matrix_room_media.dart
lib/src/data/datasources/matrix/message/matrix_thread_handler.dart
lib/src/data/datasources/points/points_api_datasource.dart
lib/src/data/datasources/push_protocol/push_protocol_datasource.dart
lib/src/data/datasources/remote/social_auth_api.dart
lib/src/data/datasources/social/alchemy_social_datasource.dart
lib/src/data/datasources/social/debank_datasource.dart
lib/src/data/datasources/social/on_chain_identity_datasource.dart
lib/src/data/mappers/archived_message_mapper.dart
lib/src/data/models/governance/snapshot_proposal_model.dart
lib/src/data/models/governance/snapshot_vote_model.dart
lib/src/data/models/points/points_balance_model.dart
lib/src/data/models/points/points_transaction_model.dart
lib/src/data/models/social/debank_portfolio_model.dart
lib/src/data/models/social/social_similarity_model.dart
lib/src/data/protocols/matrix_protocol.dart
lib/src/data/protocols/protocol_registry.dart
lib/src/data/repositories/ai_repository_impl.dart
lib/src/data/repositories/auth_repository_impl.dart
lib/src/data/repositories/contact_repository_impl.dart
lib/src/data/repositories/conversation_repository_impl.dart
lib/src/data/repositories/governance_repository_impl.dart
lib/src/data/repositories/group_repository_impl.dart
lib/src/data/repositories/message_action_repository_impl.dart
lib/src/data/repositories/message_repository_impl.dart
lib/src/data/repositories/moment_repository_impl.dart
lib/src/data/repositories/on_chain_notification_repository_impl.dart
lib/src/data/repositories/points_repository_impl.dart
lib/src/data/repositories/search_repository_impl.dart
lib/src/data/repositories/social_graph_repository_impl.dart
lib/src/data/repositories/space_repository_impl.dart
lib/src/data/repositories/sticker_repository_impl.dart
lib/src/data/repositories/story_repository_impl.dart
lib/src/data/repositories/transfer_repository_impl.dart
lib/src/data/repositories/voice_room_repository_impl.dart
```

### domain

```text
lib/src/domain/entities/ai_assistant_entity.dart
lib/src/domain/entities/bot_command_entity.dart
lib/src/domain/entities/bot_config_entity.dart
lib/src/domain/entities/channel_entity.dart
lib/src/domain/entities/chat_folder_entity.dart
lib/src/domain/entities/contact_entity.dart
lib/src/domain/entities/content_filter_entity.dart
lib/src/domain/entities/conversation_entity.dart
lib/src/domain/entities/favorite_entity.dart
lib/src/domain/entities/governance/governance_space.dart
lib/src/domain/entities/governance/proposal_entity.dart
lib/src/domain/entities/governance/vote_entity.dart
lib/src/domain/entities/group_album_entity.dart
lib/src/domain/entities/group_entity.dart
lib/src/domain/entities/group_file_entity.dart
lib/src/domain/entities/live_location_entity.dart
lib/src/domain/entities/media_folder_entity.dart
lib/src/domain/entities/message_entity.dart
lib/src/domain/entities/message_reaction_entity.dart
lib/src/domain/entities/mini_app_entity.dart
lib/src/domain/entities/moment_entity.dart
lib/src/domain/entities/on_chain_notification_entity.dart
lib/src/domain/entities/points/points_balance.dart
lib/src/domain/entities/points/points_config.dart
lib/src/domain/entities/points/points_transaction.dart
lib/src/domain/entities/points/redemption_item.dart
lib/src/domain/entities/points/reward_rule.dart
lib/src/domain/entities/privacy_settings_entity.dart
lib/src/domain/entities/quick_reply_entity.dart
lib/src/domain/entities/red_packet_entity.dart
lib/src/domain/entities/search_result_entity.dart
lib/src/domain/entities/social/social_connection.dart
lib/src/domain/entities/social/social_profile.dart
lib/src/domain/entities/social/social_recommendation.dart
lib/src/domain/entities/space_entity.dart
lib/src/domain/entities/sticker_pack_entity.dart
lib/src/domain/entities/story_entity.dart
lib/src/domain/entities/thread_entity.dart
lib/src/domain/entities/token_gate_entity.dart
lib/src/domain/entities/transfer_entity.dart
lib/src/domain/entities/user_entity.dart
lib/src/domain/entities/user_profile_entity.dart
lib/src/domain/entities/voice_room_entity.dart
lib/src/domain/protocols/messaging_protocol.dart
lib/src/domain/protocols/protocol_capabilities.dart
lib/src/domain/protocols/protocol_event.dart
lib/src/domain/repositories/ai_repository.dart
lib/src/domain/repositories/auth_repository.dart
lib/src/domain/repositories/contact_repository.dart
lib/src/domain/repositories/conversation_repository.dart
lib/src/domain/repositories/governance_repository.dart
lib/src/domain/repositories/group_repository.dart
lib/src/domain/repositories/message_action_repository.dart
lib/src/domain/repositories/message_repository.dart
lib/src/domain/repositories/moment_repository.dart
lib/src/domain/repositories/on_chain_notification_repository.dart
lib/src/domain/repositories/points_repository.dart
lib/src/domain/repositories/search_repository.dart
lib/src/domain/repositories/social_graph_repository.dart
lib/src/domain/repositories/space_repository.dart
lib/src/domain/repositories/sticker_repository.dart
lib/src/domain/repositories/story_repository.dart
lib/src/domain/repositories/transfer_repository.dart
lib/src/domain/repositories/voice_room_repository.dart
```

### integration

```text
lib/src/integration/api_hub_bridge.dart
lib/src/integration/bridge/bridge.dart
lib/src/integration/bridge/bridge_bot_service.dart
lib/src/integration/bridge/bridge_manager.dart
lib/src/integration/bridge/bridge_platform.dart
lib/src/integration/bridge/bridge_state.dart
lib/src/integration/wallet_bridge.dart
```

### presentation/blocs

```text
lib/src/presentation/blocs/ai_assistant/ai_assistant_bloc.dart
lib/src/presentation/blocs/ai_assistant/ai_assistant_event.dart
lib/src/presentation/blocs/ai_assistant/ai_assistant_state.dart
lib/src/presentation/blocs/auth/auth_bloc.dart
lib/src/presentation/blocs/auth/auth_event.dart
lib/src/presentation/blocs/auth/auth_state.dart
lib/src/presentation/blocs/backup/backup_bloc.dart
lib/src/presentation/blocs/backup/backup_event.dart
lib/src/presentation/blocs/backup/backup_state.dart
lib/src/presentation/blocs/bloc_message_keys.dart
lib/src/presentation/blocs/chat/chat_bloc.dart
lib/src/presentation/blocs/chat/chat_bloc_action_handlers.part.dart
lib/src/presentation/blocs/chat/chat_bloc_feature_handlers.part.dart
lib/src/presentation/blocs/chat/chat_bloc_message_handlers.part.dart
lib/src/presentation/blocs/chat/chat_bloc_poll_handlers.part.dart
lib/src/presentation/blocs/chat/chat_bloc_retry_handlers.part.dart
lib/src/presentation/blocs/chat/chat_bloc_send_handlers.part.dart
lib/src/presentation/blocs/chat/chat_event.dart
lib/src/presentation/blocs/chat/chat_state.dart
lib/src/presentation/blocs/chat_folder/chat_folder_bloc.dart
lib/src/presentation/blocs/chat_folder/chat_folder_event.dart
lib/src/presentation/blocs/chat_folder/chat_folder_state.dart
lib/src/presentation/blocs/contact/contact_bloc.dart
lib/src/presentation/blocs/contact/contact_event.dart
lib/src/presentation/blocs/contact/contact_state.dart
lib/src/presentation/blocs/conversation/conversation_bloc.dart
lib/src/presentation/blocs/conversation/conversation_event.dart
lib/src/presentation/blocs/conversation/conversation_state.dart
lib/src/presentation/blocs/favorite/favorite_bloc.dart
lib/src/presentation/blocs/favorite/favorite_event.dart
lib/src/presentation/blocs/favorite/favorite_state.dart
lib/src/presentation/blocs/governance/governance_bloc.dart
lib/src/presentation/blocs/governance/governance_event.dart
lib/src/presentation/blocs/governance/governance_state.dart
lib/src/presentation/blocs/group/group_bloc.dart
lib/src/presentation/blocs/group/group_event.dart
lib/src/presentation/blocs/group/group_state.dart
lib/src/presentation/blocs/group_album/group_album_bloc.dart
lib/src/presentation/blocs/group_album/group_album_event.dart
lib/src/presentation/blocs/group_album/group_album_state.dart
lib/src/presentation/blocs/live_location/live_location_bloc.dart
lib/src/presentation/blocs/live_location/live_location_event.dart
lib/src/presentation/blocs/live_location/live_location_state.dart
lib/src/presentation/blocs/message_action/message_action_bloc.dart
lib/src/presentation/blocs/message_action/message_action_event.dart
lib/src/presentation/blocs/message_action/message_action_state.dart
lib/src/presentation/blocs/moment/moment_bloc.dart
lib/src/presentation/blocs/moment/moment_event.dart
lib/src/presentation/blocs/moment/moment_state.dart
lib/src/presentation/blocs/on_chain_notification/on_chain_notification_bloc.dart
lib/src/presentation/blocs/on_chain_notification/on_chain_notification_event.dart
lib/src/presentation/blocs/on_chain_notification/on_chain_notification_state.dart
lib/src/presentation/blocs/points/points_bloc.dart
lib/src/presentation/blocs/points/points_event.dart
lib/src/presentation/blocs/points/points_state.dart
lib/src/presentation/blocs/search/search_bloc.dart
lib/src/presentation/blocs/search/search_event.dart
lib/src/presentation/blocs/search/search_state.dart
lib/src/presentation/blocs/social/social_graph_bloc.dart
lib/src/presentation/blocs/social/social_graph_event.dart
lib/src/presentation/blocs/social/social_graph_state.dart
lib/src/presentation/blocs/space/space_bloc.dart
lib/src/presentation/blocs/space/space_event.dart
lib/src/presentation/blocs/space/space_state.dart
lib/src/presentation/blocs/storage/storage_management_bloc.dart
lib/src/presentation/blocs/storage/storage_management_event.dart
lib/src/presentation/blocs/storage/storage_management_state.dart
lib/src/presentation/blocs/story/story_bloc.dart
lib/src/presentation/blocs/story/story_event.dart
lib/src/presentation/blocs/story/story_state.dart
lib/src/presentation/blocs/thread/thread_bloc.dart
lib/src/presentation/blocs/thread/thread_event.dart
lib/src/presentation/blocs/thread/thread_state.dart
lib/src/presentation/blocs/transfer/transfer_bloc.dart
lib/src/presentation/blocs/transfer/transfer_event.dart
lib/src/presentation/blocs/transfer/transfer_state.dart
lib/src/presentation/blocs/voice_room/voice_room_bloc.dart
lib/src/presentation/blocs/voice_room/voice_room_event.dart
lib/src/presentation/blocs/voice_room/voice_room_state.dart
```

### presentation/pages

```text
lib/src/presentation/pages/ai/ai_assistant_page.dart
lib/src/presentation/pages/ai/ai_assistant_settings_page.dart
lib/src/presentation/pages/auth/login_page.dart
lib/src/presentation/pages/auth/register_page.dart
lib/src/presentation/pages/auth/reset_password_page.dart
lib/src/presentation/pages/auth/welcome_page.dart
lib/src/presentation/pages/bridge/bridge_detail_page.dart
lib/src/presentation/pages/bridge/bridge_list_page.dart
lib/src/presentation/pages/call/call_screen.dart
lib/src/presentation/pages/call/group_call_screen.dart
lib/src/presentation/pages/chat/chat_detail_page.dart
lib/src/presentation/pages/chat/chat_export_page.dart
lib/src/presentation/pages/chat/chat_folder_management_page.dart
lib/src/presentation/pages/chat/chat_lock_page.dart
lib/src/presentation/pages/chat/chat_page.dart
lib/src/presentation/pages/chat/chat_page_ai_features.dart
lib/src/presentation/pages/chat/chat_page_app_bar.dart
lib/src/presentation/pages/chat/chat_page_event_handlers.dart
lib/src/presentation/pages/chat/chat_page_input.dart
lib/src/presentation/pages/chat/chat_page_media_actions.dart
lib/src/presentation/pages/chat/chat_page_message_actions.dart
lib/src/presentation/pages/chat/chat_page_message_list.dart
lib/src/presentation/pages/chat/chat_page_message_menu.dart
lib/src/presentation/pages/chat/chat_page_more_features.dart
lib/src/presentation/pages/chat/dialogs/call_dialog.dart
lib/src/presentation/pages/chat/dialogs/contact_select_dialog.dart
lib/src/presentation/pages/chat/dialogs/dialogs.dart
lib/src/presentation/pages/chat/dialogs/forward_message_sheet.dart
lib/src/presentation/pages/chat/dialogs/member_picker_sheet.dart
lib/src/presentation/pages/chat/dialogs/multi_forward_sheet.dart
lib/src/presentation/pages/chat/dialogs/poll_create_sheet.dart
lib/src/presentation/pages/chat/image_viewer_page.dart
lib/src/presentation/pages/chat/live_location_page.dart
lib/src/presentation/pages/chat/location_picker_page.dart
lib/src/presentation/pages/chat/message_item.dart
lib/src/presentation/pages/chat/message_item_helpers.dart
lib/src/presentation/pages/chat/thread_detail_page.dart
lib/src/presentation/pages/chat/video_player_page.dart
lib/src/presentation/pages/chat/viewers/image_viewer_page.dart
lib/src/presentation/pages/chat/viewers/pdf_viewer_page.dart
lib/src/presentation/pages/chat/viewers/video_player_page.dart
lib/src/presentation/pages/chat/viewers/viewers.dart
lib/src/presentation/pages/chat/widgets/chat_widgets.dart
lib/src/presentation/pages/chat/widgets/message_menu_sheet.dart
lib/src/presentation/pages/contact/add_friend_page.dart
lib/src/presentation/pages/contact/chat_only_friends_page.dart
lib/src/presentation/pages/contact/common_groups_page.dart
lib/src/presentation/pages/contact/contact_detail_page.dart
lib/src/presentation/pages/contact/contact_index_bar.dart
lib/src/presentation/pages/contact/contact_list_page.dart
lib/src/presentation/pages/contact/contact_permissions_page.dart
lib/src/presentation/pages/contact/contact_settings_page.dart
lib/src/presentation/pages/contact/contact_tile.dart
lib/src/presentation/pages/contact/enterprise_contacts_page.dart
lib/src/presentation/pages/contact/official_accounts_page.dart
lib/src/presentation/pages/contact/phone_contacts_page.dart
lib/src/presentation/pages/contact/service_accounts_page.dart
lib/src/presentation/pages/contact/tags_management_page.dart
lib/src/presentation/pages/conversation/conversation_list_page.dart
lib/src/presentation/pages/conversation/conversation_tile.dart
lib/src/presentation/pages/discover/channel_discover_page.dart
lib/src/presentation/pages/discover/discover_page.dart
lib/src/presentation/pages/favorite/favorite_list_page.dart
lib/src/presentation/pages/game/block_drop/block_drop_board.dart
lib/src/presentation/pages/game/block_drop/block_drop_logic.dart
lib/src/presentation/pages/game/block_drop/block_drop_page.dart
lib/src/presentation/pages/game/game_2048/game_2048_board.dart
lib/src/presentation/pages/game/game_2048/game_2048_logic.dart
lib/src/presentation/pages/game/game_2048/game_2048_page.dart
lib/src/presentation/pages/game/game_center_page.dart
lib/src/presentation/pages/game/match3/match3_board.dart
lib/src/presentation/pages/game/match3/match3_logic.dart
lib/src/presentation/pages/game/match3/match3_page.dart
lib/src/presentation/pages/game/minesweeper/minesweeper_board.dart
lib/src/presentation/pages/game/minesweeper/minesweeper_logic.dart
lib/src/presentation/pages/game/minesweeper/minesweeper_page.dart
lib/src/presentation/pages/game/models/game_score.dart
lib/src/presentation/pages/game/services/game_score_service.dart
lib/src/presentation/pages/game/widgets/game_over_dialog.dart
lib/src/presentation/pages/game/widgets/game_scaffold.dart
lib/src/presentation/pages/game/widgets/leaderboard_widget.dart
lib/src/presentation/pages/governance/create_proposal_page.dart
lib/src/presentation/pages/governance/proposal_detail_page.dart
lib/src/presentation/pages/governance/proposals_list_page.dart
lib/src/presentation/pages/group/bot_settings_page.dart
lib/src/presentation/pages/group/content_filter_settings_page.dart
lib/src/presentation/pages/group/create_group_page.dart
lib/src/presentation/pages/group/group_album_page.dart
lib/src/presentation/pages/group/group_channels_page.dart
lib/src/presentation/pages/group/group_files_page.dart
lib/src/presentation/pages/group/group_list_page.dart
lib/src/presentation/pages/group/group_media_hub_page.dart
lib/src/presentation/pages/group/group_members_page.dart
lib/src/presentation/pages/group/group_settings_page.dart
lib/src/presentation/pages/group/group_topics_page.dart
lib/src/presentation/pages/group/invite_members_page.dart
lib/src/presentation/pages/group/token_gate_settings_page.dart
lib/src/presentation/pages/group/token_gate_verify_page.dart
lib/src/presentation/pages/main/chat_main_page.dart
lib/src/presentation/pages/media/media_editor_page.dart
lib/src/presentation/pages/media/media_gallery_page.dart
lib/src/presentation/pages/media/media_preview_page.dart
lib/src/presentation/pages/mini_app/mini_app_market_page.dart
lib/src/presentation/pages/mini_app/mini_app_page.dart
lib/src/presentation/pages/moment/create_moment_page.dart
lib/src/presentation/pages/moment/moment_detail_page.dart
lib/src/presentation/pages/moment/moment_forward_sheet.dart
lib/src/presentation/pages/moment/moment_list_page.dart
lib/src/presentation/pages/moment/visibility_selection_page.dart
lib/src/presentation/pages/notification/on_chain_notifications_page.dart
lib/src/presentation/pages/points/leaderboard_page.dart
lib/src/presentation/pages/points/points_admin_page.dart
lib/src/presentation/pages/points/points_dashboard_page.dart
lib/src/presentation/pages/points/redemption_page.dart
lib/src/presentation/pages/profile/n42_bean_page.dart
lib/src/presentation/pages/profile/nft_avatar_picker_page.dart
lib/src/presentation/pages/profile/orders_and_cards_page.dart
lib/src/presentation/pages/profile/profile_address_manage_page.dart
lib/src/presentation/pages/profile/profile_edit_page.dart
lib/src/presentation/pages/profile/profile_invoice_manage_page.dart
lib/src/presentation/pages/profile/profile_page.dart
lib/src/presentation/pages/profile/profile_ringtone_select_page.dart
lib/src/presentation/pages/profile/services_page.dart
lib/src/presentation/pages/profile/set_username_page.dart
lib/src/presentation/pages/profile/status_page.dart
lib/src/presentation/pages/profile/user_profile_page.dart
lib/src/presentation/pages/qrcode/my_qrcode_page.dart
lib/src/presentation/pages/qrcode/scan_qr_page.dart
lib/src/presentation/pages/red_packet/red_packet_detail_page.dart
lib/src/presentation/pages/red_packet/red_packet_history_page.dart
lib/src/presentation/pages/red_packet/send_red_packet_page.dart
lib/src/presentation/pages/red_packet/send_transfer_page.dart
lib/src/presentation/pages/search/chat_search_bar.dart
lib/src/presentation/pages/search/chat_search_page.dart
lib/src/presentation/pages/search/global_search_page.dart
lib/src/presentation/pages/search/search_result_tile.dart
lib/src/presentation/pages/security/emoji_verification_widget.dart
lib/src/presentation/pages/security/sas_verification_page.dart
lib/src/presentation/pages/settings/about_page.dart
lib/src/presentation/pages/settings/appearance_settings_page.dart
lib/src/presentation/pages/settings/auto_download_settings_page.dart
lib/src/presentation/pages/settings/backup_restore_page.dart
lib/src/presentation/pages/settings/change_email_page.dart
lib/src/presentation/pages/settings/change_password_page.dart
lib/src/presentation/pages/settings/chat_background_page.dart
lib/src/presentation/pages/settings/hidden_chats_page.dart
lib/src/presentation/pages/settings/language_settings_page.dart
lib/src/presentation/pages/settings/notification_settings_page.dart
lib/src/presentation/pages/settings/privacy_settings_page.dart
lib/src/presentation/pages/settings/quick_replies_page.dart
lib/src/presentation/pages/settings/room_storage_detail_page.dart
lib/src/presentation/pages/settings/security_settings_page.dart
lib/src/presentation/pages/settings/settings_page.dart
lib/src/presentation/pages/settings/storage_management_page.dart
lib/src/presentation/pages/settings/translation_settings_page.dart
lib/src/presentation/pages/social/social_graph_page.dart
lib/src/presentation/pages/social/user_similarity_page.dart
lib/src/presentation/pages/space/space_create_page.dart
lib/src/presentation/pages/space/space_detail_page.dart
lib/src/presentation/pages/space/space_list_page.dart
lib/src/presentation/pages/sticker/sticker_store_page.dart
lib/src/presentation/pages/story/create_story_page.dart
lib/src/presentation/pages/story/story_viewer_page.dart
lib/src/presentation/pages/story/story_viewers_page.dart
lib/src/presentation/pages/transfer/receive_page.dart
lib/src/presentation/pages/transfer/transfer_page.dart
lib/src/presentation/pages/voice_room/voice_room_list_page.dart
lib/src/presentation/pages/voice_room/voice_room_page.dart
```

### presentation/widgets

```text
lib/src/presentation/widgets/animations/animations.dart
lib/src/presentation/widgets/animations/fade_animation.dart
lib/src/presentation/widgets/animations/scale_animation.dart
lib/src/presentation/widgets/animations/slide_animation.dart
lib/src/presentation/widgets/auth/social_login_buttons.dart
lib/src/presentation/widgets/chat/ai_link_summary_card.dart
lib/src/presentation/widgets/chat/ai_rewrite_bar.dart
lib/src/presentation/widgets/chat/ai_summary_bubble.dart
lib/src/presentation/widgets/chat/call_dialog.dart
lib/src/presentation/widgets/chat/chat_confirm_sheets.dart
lib/src/presentation/widgets/chat/chat_folder_tab_bar.dart
lib/src/presentation/widgets/chat/chat_input_bar.dart
lib/src/presentation/widgets/chat/chat_more_panel.dart
lib/src/presentation/widgets/chat/chat_widgets.dart
lib/src/presentation/widgets/chat/contact_card_message_widget.dart
lib/src/presentation/widgets/chat/contact_card_select_sheet.dart
lib/src/presentation/widgets/chat/contact_select_dialog.dart
lib/src/presentation/widgets/chat/edit_history_sheet.dart
lib/src/presentation/widgets/chat/emoji_picker.dart
lib/src/presentation/widgets/chat/forward_message_sheet.dart
lib/src/presentation/widgets/chat/gif_picker.dart
lib/src/presentation/widgets/chat/image_message_widget.dart
lib/src/presentation/widgets/chat/in_call_chat_panel.dart
lib/src/presentation/widgets/chat/markdown_message_widget.dart
lib/src/presentation/widgets/chat/member_picker_sheet.dart
lib/src/presentation/widgets/chat/message_bubble.dart
lib/src/presentation/widgets/chat/message_menu.dart
lib/src/presentation/widgets/chat/message_reaction_bar.dart
lib/src/presentation/widgets/chat/message_status_indicator.dart
lib/src/presentation/widgets/chat/multi_forward_sheet.dart
lib/src/presentation/widgets/chat/music_select_sheet.dart
lib/src/presentation/widgets/chat/open_red_packet_dialog.dart
lib/src/presentation/widgets/chat/poll_create_sheet.dart
lib/src/presentation/widgets/chat/quick_reply_sheet.dart
lib/src/presentation/widgets/chat/red_packet_dialogs.dart
lib/src/presentation/widgets/chat/self_destruct_overlay.dart
lib/src/presentation/widgets/chat/slash_command_picker.dart
lib/src/presentation/widgets/chat/sticker_picker.dart
lib/src/presentation/widgets/chat/thread_indicator.dart
lib/src/presentation/widgets/chat/time_separator.dart
lib/src/presentation/widgets/chat/transfer_message_widget.dart
lib/src/presentation/widgets/chat/translated_message.dart
lib/src/presentation/widgets/chat/url_preview_widget.dart
lib/src/presentation/widgets/chat/voice_message_widget.dart
lib/src/presentation/widgets/chat/wechat_message_menu.dart
lib/src/presentation/widgets/common/common_widgets.dart
lib/src/presentation/widgets/common/ens_badge.dart
lib/src/presentation/widgets/common/n42_app_bar.dart
lib/src/presentation/widgets/common/n42_avatar.dart
lib/src/presentation/widgets/common/n42_badge.dart
lib/src/presentation/widgets/common/n42_bottom_nav_bar.dart
lib/src/presentation/widgets/common/n42_button.dart
lib/src/presentation/widgets/common/n42_empty_state.dart
lib/src/presentation/widgets/common/n42_list_tile.dart
lib/src/presentation/widgets/common/n42_search_bar.dart
lib/src/presentation/widgets/common/slide_to_pay_button.dart
lib/src/presentation/widgets/common/sync_progress_overlay.dart
lib/src/presentation/widgets/common/web3_identity_card.dart
lib/src/presentation/widgets/common/wechat_toast.dart
lib/src/presentation/widgets/governance/vote_progress_bar.dart
lib/src/presentation/widgets/optimized/optimized_list_view.dart
lib/src/presentation/widgets/points/points_badge.dart
lib/src/presentation/widgets/points/streak_indicator.dart
lib/src/presentation/widgets/settings/recovery_key_display_dialog.dart
lib/src/presentation/widgets/settings/recovery_key_import_dialog.dart
lib/src/presentation/widgets/settings/recovery_key_reminder_dialog.dart
lib/src/presentation/widgets/social/similarity_card.dart
lib/src/presentation/widgets/social/social_graph_visualization.dart
lib/src/presentation/widgets/story/story_bar.dart
lib/src/presentation/widgets/story/story_music_picker.dart
lib/src/presentation/widgets/story/story_progress_bar.dart
lib/src/presentation/widgets/story/story_ring.dart
lib/src/presentation/widgets/voice_room/participant_grid.dart
lib/src/presentation/widgets/voice_room/speaking_avatar.dart
lib/src/presentation/widgets/voice_room/voice_room_mini_player.dart
lib/src/presentation/widgets/widgets.dart
```

### services

```text
lib/src/services/auth/auth_methods_service.dart
lib/src/services/ringtone/system_ringtone_service.dart
lib/src/services/voip/call_manager.dart
lib/src/services/voip/call_notification_service.dart
lib/src/services/voip/livekit_service.dart
lib/src/services/voip/voice_room_service.dart
lib/src/services/voip/voip.dart
lib/src/services/voip/voip_config.dart
lib/src/services/voip/webrtc_service.dart
```

## Raw Test Inventory By Module

### test/unit

```text
test/unit/blocs/ai_assistant_bloc_extended_test.dart
test/unit/blocs/ai_assistant_bloc_test.dart
test/unit/blocs/ai_assistant_event_test.dart
test/unit/blocs/ai_assistant_state_test.dart
test/unit/blocs/auth_bloc_extended_test.dart
test/unit/blocs/auth_bloc_test.dart
test/unit/blocs/auth_event_test.dart
test/unit/blocs/auth_state_test.dart
test/unit/blocs/backup_bloc_extended_test.dart
test/unit/blocs/backup_bloc_test.dart
test/unit/blocs/backup_event_test.dart
test/unit/blocs/backup_state_test.dart
test/unit/blocs/chat_bloc_extended_test.dart
test/unit/blocs/chat_bloc_test.dart
test/unit/blocs/chat_event_test.dart
test/unit/blocs/chat_folder_bloc_extended_test.dart
test/unit/blocs/chat_folder_bloc_test.dart
test/unit/blocs/chat_folder_event_test.dart
test/unit/blocs/chat_folder_state_test.dart
test/unit/blocs/chat_state_test.dart
test/unit/blocs/contact_bloc_test.dart
test/unit/blocs/contact_event_test.dart
test/unit/blocs/contact_state_test.dart
test/unit/blocs/conversation_bloc_extended_test.dart
test/unit/blocs/conversation_bloc_test.dart
test/unit/blocs/conversation_event_test.dart
test/unit/blocs/conversation_state_test.dart
test/unit/blocs/favorite_bloc_test.dart
test/unit/blocs/favorite_event_test.dart
test/unit/blocs/favorite_state_test.dart
test/unit/blocs/governance_bloc_test.dart
test/unit/blocs/group_album_bloc_test.dart
test/unit/blocs/group_album_event_test.dart
test/unit/blocs/group_album_state_test.dart
test/unit/blocs/group_bloc_test.dart
test/unit/blocs/group_event_test.dart
test/unit/blocs/group_state_test.dart
test/unit/blocs/live_location_bloc_test.dart
test/unit/blocs/live_location_event_test.dart
test/unit/blocs/live_location_state_test.dart
test/unit/blocs/message_action_bloc_extended_test.dart
test/unit/blocs/message_action_bloc_test.dart
test/unit/blocs/message_action_event_test.dart
test/unit/blocs/message_action_state_test.dart
test/unit/blocs/moment_bloc_extended_test.dart
test/unit/blocs/moment_bloc_test.dart
test/unit/blocs/moment_event_test.dart
test/unit/blocs/moment_state_test.dart
test/unit/blocs/points_bloc_test.dart
test/unit/blocs/search_bloc_extended_test.dart
test/unit/blocs/search_bloc_test.dart
test/unit/blocs/search_event_test.dart
test/unit/blocs/search_state_test.dart
test/unit/blocs/social_graph_bloc_test.dart
test/unit/blocs/storage_management_bloc_extended_test.dart
test/unit/blocs/storage_management_bloc_test.dart
test/unit/blocs/storage_management_event_test.dart
test/unit/blocs/storage_management_state_test.dart
test/unit/blocs/story_bloc_extended_test.dart
test/unit/blocs/story_bloc_test.dart
test/unit/blocs/story_event_test.dart
test/unit/blocs/story_state_test.dart
test/unit/blocs/thread_bloc_extended_test.dart
test/unit/blocs/thread_bloc_test.dart
test/unit/blocs/thread_event_test.dart
test/unit/blocs/thread_state_test.dart
test/unit/blocs/transfer_bloc_test.dart
test/unit/blocs/transfer_event_test.dart
test/unit/blocs/transfer_state_test.dart
test/unit/blocs/voice_room_bloc_extended_test.dart
test/unit/blocs/voice_room_bloc_test.dart
test/unit/blocs/voice_room_event_test.dart
test/unit/blocs/voice_room_state_test.dart
test/unit/config/n42_chat_config_test.dart
test/unit/config/voip_config_test.dart
test/unit/core/app_constants_test.dart
test/unit/core/app_dimensions_test.dart
test/unit/core/bloc_message_keys_test.dart
test/unit/core/chat_background_presets_test.dart
test/unit/core/string_extension_test.dart
test/unit/core/string_utils_test.dart
test/unit/core/username_validator_test.dart
test/unit/datasources/ai_datasource_test.dart
test/unit/datasources/alchemy_social_datasource_test.dart
test/unit/datasources/debank_datasource_test.dart
test/unit/datasources/matrix_search_datasource_test.dart
test/unit/datasources/preferences_datasource_test.dart
test/unit/datasources/secure_storage_datasource_test.dart
test/unit/datasources/secure_storage_test.dart
test/unit/datasources/social_auth_api_test.dart
test/unit/entities/ai_assistant_entity_test.dart
test/unit/entities/chat_folder_entity_extended_test.dart
test/unit/entities/chat_folder_entity_test.dart
test/unit/entities/contact_entity_test.dart
test/unit/entities/conversation_entity_test.dart
test/unit/entities/favorite_entity_extended_test.dart
test/unit/entities/favorite_entity_test.dart
test/unit/entities/group_album_entity_extended_test.dart
test/unit/entities/group_album_entity_test.dart
test/unit/entities/group_entity_channel_test.dart
test/unit/entities/group_entity_pinned_test.dart
test/unit/entities/group_entity_test.dart
test/unit/entities/group_file_entity_extended_test.dart
test/unit/entities/group_file_entity_test.dart
test/unit/entities/group_member_test.dart
test/unit/entities/live_location_entity_test.dart
test/unit/entities/media_folder_entity_test.dart
test/unit/entities/message_entity_extended_test.dart
test/unit/entities/message_entity_mentions_test.dart
test/unit/entities/message_entity_poll_test.dart
test/unit/entities/message_entity_scheduled_test.dart
test/unit/entities/message_entity_self_destruct_test.dart
test/unit/entities/message_entity_test.dart
test/unit/entities/message_entity_transcription_test.dart
test/unit/entities/message_reaction_entity_test.dart
test/unit/entities/moment_entity_extended_test.dart
test/unit/entities/moment_entity_test.dart
test/unit/entities/moment_visibility_test.dart
test/unit/entities/on_chain_notification_entity_test.dart
test/unit/entities/privacy_settings_entity_test.dart
test/unit/entities/privacy_settings_test.dart
test/unit/entities/quick_reply_entity_test.dart
test/unit/entities/red_packet_entity_test.dart
test/unit/entities/search_result_entity_test.dart
test/unit/entities/space_entity_test.dart
test/unit/entities/sticker_pack_entity_extended_test.dart
test/unit/entities/sticker_pack_entity_test.dart
test/unit/entities/story_entity_extended_test.dart
test/unit/entities/story_entity_test.dart
test/unit/entities/thread_entity_test.dart
test/unit/entities/token_gate_entity_test.dart
test/unit/entities/transfer_entity_extended_test.dart
test/unit/entities/transfer_entity_test.dart
test/unit/entities/user_entity_test.dart
test/unit/entities/user_profile_entity_extended_test.dart
test/unit/entities/user_profile_entity_test.dart
test/unit/entities/voice_room_entity_test.dart
test/unit/game/block_drop_logic_test.dart
test/unit/game/game_2048_logic_test.dart
test/unit/game/game_score_service_test.dart
test/unit/game/game_score_test.dart
test/unit/game/match3_logic_test.dart
test/unit/game/minesweeper_logic_test.dart
test/unit/image_upload_test.dart
test/unit/integration/bridge_state_test.dart
test/unit/integration/wallet_bridge_test.dart
test/unit/repositories/ai_repository_impl_test.dart
test/unit/repositories/auth_repository_test.dart
test/unit/repositories/contact_repository_impl_test.dart
test/unit/repositories/conversation_repository_impl_test.dart
test/unit/repositories/governance_repository_impl_test.dart
test/unit/repositories/group_repository_impl_test.dart
test/unit/repositories/message_repository_impl_test.dart
test/unit/repositories/moment_repository_impl_test.dart
test/unit/repositories/points_repository_impl_test.dart
test/unit/repositories/search_repository_impl_test.dart
test/unit/repositories/social_graph_repository_impl_test.dart
test/unit/repositories/sticker_repository_impl_test.dart
test/unit/repositories/story_repository_impl_test.dart
test/unit/repositories/transfer_repository_impl_test.dart
test/unit/services/ai_service_test.dart
test/unit/services/auth_methods_service_test.dart
test/unit/services/background_call_kit_test.dart
test/unit/services/bot_command_processor_test.dart
test/unit/services/call_manager_dedup_test.dart
test/unit/services/chat_backup_service_test.dart
test/unit/services/chat_export_service_test.dart
test/unit/services/chat_lock_service_test.dart
test/unit/services/contact_sync_service_test.dart
test/unit/services/data_tier_service_test.dart
test/unit/services/firebase_push_service_test.dart
test/unit/services/giphy_service_test.dart
test/unit/services/media_lifecycle_service_test.dart
test/unit/services/mini_app_bridge_service_test.dart
test/unit/services/points_tracking_service_test.dart
test/unit/services/push_and_config_test.dart
test/unit/services/remark_service_test.dart
test/unit/services/self_destruct_service_test.dart
test/unit/services/social_graph_service_test.dart
test/unit/services/speech_to_text_service_test.dart
test/unit/services/storage_cleanup_service_test.dart
test/unit/services/storage_manager_service_test.dart
test/unit/services/storage_monitor_service_test.dart
test/unit/services/translation_service_test.dart
test/unit/services/tts_service_test.dart
test/unit/services/url_preview_service_test.dart
test/unit/services/voice_room_service_test.dart
test/unit/services/voip_audio_processing_test.dart
test/unit/services/voip_service_test.dart
test/unit/services/webrtc_encryption_test.dart
test/unit/utils/date_utils_test.dart
test/unit/utils/matrix_utils_test.dart
test/unit/utils/platform_utils_test.dart
test/unit/utils/responsive_utils_test.dart
test/unit/utils/string_utils_test.dart
test/unit/utils/username_validator_test.dart
test/unit/widgets/markdown_detection_test.dart
test/unit/widgets/slide_to_pay_button_test.dart
test/unit/widgets/web3_identity_card_test.dart
```

### test/integration

```text
test/integration/auth_flow_test.dart
test/integration/bridge/bridge_platform_test.dart
test/integration/bridge/bridge_state_test.dart
test/integration/wallet_bridge_test.dart
```

### test/presentation

```text
test/presentation/pages/ai_assistant_page_test.dart
test/presentation/pages/contact_detail_page_test.dart
test/presentation/pages/contact_settings_page_test.dart
test/presentation/pages/discover_page_test.dart
test/presentation/pages/governance/create_proposal_page_test.dart
test/presentation/pages/governance/proposal_detail_page_test.dart
test/presentation/pages/governance/proposals_list_page_test.dart
test/presentation/pages/group/group_topics_page_test.dart
test/presentation/pages/leaderboard_page_test.dart
test/presentation/pages/mini_app_market_page_test.dart
test/presentation/pages/mini_app_page_test.dart
test/presentation/pages/moment/moment_detail_page_test.dart
test/presentation/pages/my_qrcode_page_test.dart
test/presentation/pages/points_admin_page_test.dart
test/presentation/pages/points_dashboard_page_test.dart
test/presentation/pages/red_packet_send_pages_test.dart
test/presentation/pages/redemption_page_test.dart
test/presentation/pages/social_graph_page_test.dart
test/presentation/pages/story/create_story_page_test.dart
test/presentation/pages/story/story_viewer_page_test.dart
test/presentation/pages/user_similarity_page_test.dart
test/presentation/pages/voice_room_list_page_test.dart
test/presentation/pages/voice_room_page_test.dart
test/presentation/widgets/chat/slash_command_picker_test.dart
test/presentation/widgets/common/sync_progress_overlay_test.dart
test/presentation/widgets/settings/recovery_key_reminder_dialog_test.dart
```

### test/mocks

```text
test/mocks/mock_wallet_bridge.dart
```

## Current Execution Status

- [x] Inventory captured
- [x] Plan file written
- [x] Phase 1 review finished
- [x] Phase 2 review finished
- [x] Phase 3 review finished
- [x] Phase 4 review finished
- [x] Phase 5 review finished
- [x] Phase 6 review finished
- [x] Phase 7 review finished
- [x] Phase 8 review finished
- [x] Phase 9 review finished
- [x] Phase 10 review finished
- [x] Phase 11 final hardening finished

## Current Worktree Grouping

Notes:

- I did not stage, stash, or revert anything. The index remains untouched.
- The current worktree now groups cleanly into the batches below.
- Generated metadata files should travel with the functional batch they support, not as a standalone commit.

### Batch A - Bootstrap, config, host wiring, and examples

```text
example/lib/server_test_page.dart
example/pubspec.lock
example/pubspec.yaml
lib/src/core/constants/app_constants.dart
lib/src/core/di/injection.dart
lib/src/core/router/app_router.dart
lib/src/integration/bridge/bridge_bot_service.dart
lib/src/n42_chat.dart
lib/src/n42_chat_config.dart
lib/src/presentation/pages/auth/login_page.dart
lib/src/presentation/pages/auth/register_page.dart
test/unit/config/n42_chat_config_test.dart
test/unit/core/app_constants_test.dart
test/unit/core/app_router_test.dart
test/unit/datasources/secure_storage_datasource_test.dart
test/unit/integration/bridge_bot_service_test.dart
tool/server_test.dart
```

### Batch B - Auth, backup, biometric, and local security

```text
lib/src/core/services/biometric_service.dart
lib/src/core/services/chat_backup_service.dart
lib/src/core/utils/date_utils.dart
lib/src/services/auth/auth_methods_service.dart
test/unit/services/biometric_service_test.dart
test/unit/services/chat_backup_service_test.dart
```

### Batch C - AI, proxy integrations, and social graph

```text
lib/src/core/services/bot_command_processor.dart
lib/src/core/services/giphy_service.dart
lib/src/core/services/social_graph_service.dart
lib/src/core/services/speech_to_text_service.dart
lib/src/data/datasources/ai_datasource.dart
lib/src/data/datasources/social/alchemy_social_datasource.dart
lib/src/data/datasources/social/debank_datasource.dart
lib/src/data/models/social/social_similarity_model.dart
lib/src/data/repositories/ai_repository_impl.dart
lib/src/data/repositories/social_graph_repository_impl.dart
lib/src/domain/repositories/social_graph_repository.dart
lib/src/presentation/blocs/ai_assistant/ai_assistant_bloc.dart
lib/src/presentation/blocs/ai_assistant/ai_assistant_event.dart
lib/src/presentation/blocs/social/social_graph_bloc.dart
lib/src/presentation/blocs/social/social_graph_state.dart
lib/src/presentation/pages/ai/ai_assistant_page.dart
lib/src/presentation/pages/social/social_graph_page.dart
lib/src/presentation/pages/social/user_similarity_page.dart
test/presentation/pages/ai_assistant_page_test.dart
test/presentation/pages/social_graph_page_test.dart
test/presentation/pages/user_similarity_page_test.dart
test/unit/blocs/ai_assistant_bloc_extended_test.dart
test/unit/blocs/social_graph_bloc_test.dart
test/unit/datasources/ai_datasource_test.dart
test/unit/datasources/alchemy_social_datasource_test.dart
test/unit/datasources/debank_datasource_test.dart
test/unit/repositories/ai_repository_impl_test.dart
test/unit/repositories/social_graph_repository_impl_test.dart
test/unit/services/bot_command_processor_test.dart
test/unit/services/giphy_service_test.dart
test/unit/services/social_graph_service_test.dart
test/unit/services/speech_to_text_service_test.dart
```

### Batch D - Matrix transport and chat send pipeline

```text
lib/src/data/datasources/matrix/matrix_message_datasource.dart
lib/src/data/datasources/matrix/message/matrix_message_operations.dart
lib/src/data/datasources/matrix/message/matrix_message_sender.dart
lib/src/data/datasources/matrix/message/matrix_text_message_content.dart
lib/src/data/repositories/message_repository_impl.dart
lib/src/domain/repositories/message_repository.dart
lib/src/presentation/blocs/chat/chat_bloc_action_handlers.part.dart
lib/src/presentation/blocs/chat/chat_bloc_send_handlers.part.dart
lib/src/presentation/blocs/chat/chat_event.dart
lib/src/presentation/pages/chat/chat_page.dart
test/unit/blocs/chat_bloc_extended_test.dart
test/unit/blocs/chat_bloc_test.dart
test/unit/blocs/chat_event_test.dart
test/unit/repositories/message_repository_impl_test.dart
```

### Batch E - Governance, points, mini-app, and discover UI

```text
lib/src/core/services/mini_app_bridge_service.dart
lib/src/domain/entities/points/points_config.dart
lib/src/presentation/blocs/governance/governance_bloc.dart
lib/src/presentation/blocs/governance/governance_event.dart
lib/src/presentation/blocs/governance/governance_state.dart
lib/src/presentation/blocs/points/points_bloc.dart
lib/src/presentation/blocs/points/points_event.dart
lib/src/presentation/blocs/points/points_state.dart
lib/src/presentation/pages/discover/discover_page.dart
lib/src/presentation/pages/governance/create_proposal_page.dart
lib/src/presentation/pages/governance/proposal_detail_page.dart
lib/src/presentation/pages/governance/proposals_list_page.dart
lib/src/presentation/pages/mini_app/mini_app_page.dart
lib/src/presentation/pages/points/leaderboard_page.dart
lib/src/presentation/pages/points/points_dashboard_page.dart
lib/src/presentation/pages/points/redemption_page.dart
test/presentation/pages/discover_page_test.dart
test/presentation/pages/governance/create_proposal_page_test.dart
test/presentation/pages/governance/proposal_detail_page_test.dart
test/presentation/pages/governance/proposals_list_page_test.dart
test/presentation/pages/leaderboard_page_test.dart
test/presentation/pages/mini_app_page_test.dart
test/presentation/pages/points_dashboard_page_test.dart
test/presentation/pages/redemption_page_test.dart
test/unit/blocs/governance_bloc_test.dart
test/unit/blocs/points_bloc_test.dart
test/unit/services/mini_app_bridge_service_test.dart
```

### Batch F - Voice room and VoIP-related UI

```text
lib/src/presentation/blocs/voice_room/voice_room_bloc.dart
lib/src/presentation/pages/voice_room/voice_room_list_page.dart
lib/src/presentation/pages/voice_room/voice_room_page.dart
lib/src/services/voip/voice_room_service.dart
test/presentation/pages/voice_room_list_page_test.dart
test/presentation/pages/voice_room_page_test.dart
test/unit/blocs/voice_room_bloc_extended_test.dart
test/unit/config/voip_config_test.dart
test/unit/services/voice_room_service_test.dart
test/unit/services/voip_audio_processing_test.dart
```

### Batch G - Repo metadata and review docs

```text
.flutter-plugins-dependencies
docs/CHAT_PLUGIN_FULL_REVIEW_PLAN_2026-03-16.md
pubspec.lock
pubspec.yaml
```
