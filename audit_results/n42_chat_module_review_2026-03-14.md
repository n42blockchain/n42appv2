# n42_chat Module Review Baseline

Date: 2026-03-14

## Scope

This baseline splits `n42_chat` into reviewable feature modules so fixes can be tracked incrementally instead of mixing UI, auth, push, and business features in one stream.

Review status values:

- `done`: reviewed this round, concrete issues fixed, targeted verification completed
- `in_progress`: module boundary and first findings identified, more review still needed
- `pending`: not reviewed in detail yet

## Module Map

| Module | Main dirs | Core repos/services | Risk | Status |
| --- | --- | --- | --- | --- |
| Auth & Session | `presentation/pages/auth`, `presentation/blocs/auth` | `auth_repository_impl.dart`, `auth_methods_service.dart`, `matrix_auth_datasource.dart` | P1 | done |
| Conversation & Chat Core | `presentation/pages/conversation`, `presentation/pages/chat`, `presentation/blocs/conversation`, `presentation/blocs/chat` | `conversation_repository_impl.dart`, `message_repository_impl.dart`, `message_action_repository_impl.dart` | P1 | done |
| Contacts & Profile | `presentation/pages/contact`, `presentation/pages/contacts`, `presentation/pages/profile`, `presentation/blocs/contact`, `core/services/remark_service.dart` | `contact_repository_impl.dart` | P2 | in_progress |
| Group & Space | `presentation/pages/group`, `presentation/pages/space`, `presentation/blocs/group`, `presentation/blocs/group_album`, `presentation/blocs/space` | `group_repository_impl.dart`, `space_repository_impl.dart` | P1 | done |
| Search & Discovery | `presentation/pages/search`, `presentation/pages/discover`, `presentation/blocs/search` | `search_repository_impl.dart` | P2 | pending |
| Story & Moment | `presentation/pages/story`, `presentation/pages/moment`, `presentation/blocs/story`, `presentation/blocs/moment` | `story_repository_impl.dart`, `moment_repository_impl.dart` | P2 | pending |
| Notifications, Push & VoIP | `presentation/pages/notification`, `presentation/pages/call`, `core/notifications`, `services/voip` | `firebase_push_service.dart`, `push_notification_service.dart`, `call_manager.dart` | P1 | done |
| Security, Backup & Storage | `presentation/pages/security`, `presentation/pages/settings`, `presentation/blocs/backup`, `presentation/blocs/storage` | `chat_backup_service.dart`, `storage_manager_service.dart`, `chat_lock_service.dart` | P1 | in_progress |
| On-chain & Wallet Adjacent | `presentation/pages/transfer`, `presentation/pages/red_packet`, `presentation/pages/points`, `presentation/pages/governance`, `presentation/blocs/transfer`, `presentation/blocs/points`, `presentation/blocs/governance`, `presentation/blocs/on_chain_notification` | `transfer_repository_impl.dart`, `points_repository_impl.dart`, `governance_repository_impl.dart`, `on_chain_notification_repository_impl.dart` | P2 | pending |
| AI, Social, Mini App & Voice Room | `presentation/pages/ai`, `presentation/pages/social`, `presentation/pages/mini_app`, `presentation/pages/voice_room`, `presentation/blocs/ai_assistant`, `presentation/blocs/social`, `presentation/blocs/voice_room` | `ai_repository_impl.dart`, `social_graph_repository_impl.dart`, `voice_room_repository_impl.dart`, `mini_app_bridge_service.dart` | P2 | pending |
| Sticker & Media Utilities | `presentation/pages/media`, `presentation/pages/sticker`, `core/services/download_service.dart`, `core/services/url_preview_service.dart` | `sticker_repository_impl.dart` | P3 | pending |

## Auth & Session

Reviewed files:

- `lib/src/presentation/blocs/auth/auth_bloc.dart`
- `lib/src/presentation/pages/auth/login_page.dart`
- `lib/src/presentation/pages/auth/register_page.dart`
- `lib/src/presentation/widgets/auth/social_login_buttons.dart`

Fixed this round:

1. Successful auth flows were inconsistent about notifying the host app after login and restore. `AuthBloc` now uses a shared authenticated completion path so password login, register, restore, social login, token login, and SSO login all call `N42Chat.notifyUserChanged()`, initialize call handling, and register push consistently.
2. Login and register errors could surface raw `BlocMessageKeys.*` strings in SnackBars. UI now resolves bloc message keys through `resolveBlocMessage(...)`.
3. SSO login token flow and `loginStateStream` forced logout were not covered by tests. Both are now covered.

Targeted verification:

- `dart analyze` on auth bloc/pages/widgets
- `flutter test test/unit/blocs/auth_bloc_test.dart test/unit/blocs/auth_bloc_extended_test.dart`

Residual risk:

- Unit tests still exercise real static `N42Chat` side effects, so logs are noisy and integration failures around DI registration are not isolated in test doubles yet.

## Conversation & Chat Core

Reviewed first:

- `lib/src/presentation/pages/conversation/conversation_list_page.dart`
- `lib/src/presentation/blocs/conversation/conversation_bloc.dart`
- `lib/src/presentation/blocs/conversation/conversation_event.dart`

Fixed this round:

1. New-conversation navigation used a sticky `newConversationId` state field that was never cleared. Any later state emission could retrigger navigation into the same room.
2. `ConversationListPage` could crash when `newConversationId` was set before the refreshed conversation list contained the newly created room, because it fell back to `state.conversations.first`.
3. Creating a direct chat or group chat now inserts the created conversation into local state before refresh, and the page consumes navigation through a one-shot `ClearNewConversationNavigation` event.
4. Reply mode only cleared after text sends. Media, file, contact card, GIF, sticker, custom message, and poke sends could leave a stale `replyTarget` in state; successful non-text sends now clear reply mode and update `lastMessageSentAt`.
5. Slow mode only applied to text sends. Attachment-style sends could bypass the room cooldown. User-initiated non-text send handlers now enforce the same cooldown gate.
6. `MessageRepositoryImpl.watchMessage(...)` did not emit an initial snapshot when the message already existed in timeline memory. Thread/detail consumers waiting on `.first` could stall until the next sync tick. The repository now yields the in-memory message immediately before listening for sync updates.
7. `ChatDetailPage` could lock a chat even after the PIN setup dialog was cancelled. The page now aborts lock enablement when the user dismisses PIN creation.

Targeted verification:

- `dart analyze` on conversation bloc/page
- `flutter test test/unit/blocs/conversation_bloc_test.dart test/unit/blocs/conversation_bloc_extended_test.dart`
- `dart analyze` on chat send handlers and chat bloc tests
- `flutter test test/unit/blocs/chat_bloc_test.dart test/unit/blocs/chat_bloc_extended_test.dart`

Residual risk:

- `chat_detail_page.dart` and related settings pages still have several action flows that pop UI immediately after dispatching BLoC events, so backend failures can still surface after navigation has already changed.

## Contacts & Profile

Reviewed first:

- `lib/src/data/repositories/contact_repository_impl.dart`
- `lib/src/presentation/pages/contact/contact_list_page.dart`
- `lib/src/presentation/pages/contact/contact_settings_page.dart`
- `lib/src/presentation/pages/contact/contact_detail_page.dart`
- `lib/src/presentation/pages/profile/user_profile_page.dart`
- `lib/src/presentation/pages/profile/profile_page.dart`

Fixed this round:

1. `ContactListPage` exposed a "Set remark" action that never persisted anything. The dialog now dispatches `SetContactRemark(...)` through `ContactBloc` instead of only showing a toast.
2. `ContactRepositoryImpl.getContactById(...)` skipped remark-cache loading, so direct profile fetches lost local remarks even when they were already stored. The repository now loads cached remarks before mapping remote profiles.
3. `UserProfilePage` fabricated a placeholder contact whenever the user was not already present in `ContactBloc` state. It now falls back to `IContactRepository.getContactById(...)` before synthesizing a minimal profile.
4. `ProfilePage` only kept status text in local widget state. Reopening the page lost the current status, and clearing the status only updated local UI. The page now loads `getMyStatus()` on entry and calls `setMyStatus(null)` when clearing.
5. NFT avatar binding previously called `client.setAvatar(null)`, which cleared the Matrix avatar instead of syncing the external NFT image. The page now skips that destructive call and keeps the change local until a real upload path exists.
6. `ContactSettingsPage` deleted contacts by manually awaiting `bloc.stream` and treating any later `loaded` state as success. The page now drives deletion from `ContactStatus.deleted` only, with an explicit in-page loading overlay instead of ad hoc stream waiting.
7. `EditRemarkPage` wrote the same remark twice by updating `RemarkService` directly and then dispatching `SetContactRemark(...)`, which triggered a second write and refresh. It now prefers the bloc path and only falls back to `RemarkService` when no `ContactBloc` is available.
8. Contact mapping did not carry `isBlocked` from Matrix ignore state, so settings/profile block toggles often rendered the wrong initial value. Repository mapping now preserves blocked state and `ContactSettingsPage` initializes its switch from the loaded contact.
9. `ProfileEditPage` showed success SnackBars for gender, region, poke text, signature, and ringtone immediately after dispatching update events, while failures were either silent or arrived later as unrelated global auth errors. The page now tracks pending profile operations and only shows success or failure after `AuthBloc` confirms the result.
10. `EditRemarkPage` still popped immediately after dispatching `SetContactRemark(...)`, which made remark-save failures invisible. The page now waits for `ContactStatus.remarkUpdated` before closing and keeps the editor open on error. `UserProfilePage` remark edits were aligned to the same success-driven flow.

Targeted verification:

- `dart analyze` on contact/profile repository and pages
- `flutter test test/unit/repositories/contact_repository_impl_test.dart`
- `flutter test test/presentation/pages/contact_settings_page_test.dart`

Residual risk:

- `ContactDetailPage` and `FriendInfoPage` still mix direct `RemarkService` reads with `ContactBloc` state, so remark updates remain more coupled than they should be.
- `ProfilePage` still keeps NFT-avatar state only in widget memory; the setting is not persisted across restarts because there is no durable avatar-source model yet.

## Group & Space

Reviewed first:

- `lib/src/data/datasources/matrix/matrix_group_datasource.dart`
- `lib/src/data/repositories/group_repository_impl.dart`
- `lib/src/presentation/pages/group/group_channels_page.dart`
- `lib/src/presentation/pages/group/group_topics_page.dart`
- `lib/src/presentation/pages/group/group_members_page.dart`
- `lib/src/data/datasources/matrix/matrix_space_datasource.dart`
- `lib/src/presentation/pages/space/space_detail_page.dart`

Fixed this round:

1. Group topic channels were created as ordinary private rooms with no read-only enforcement. The channel creation flow now writes channel metadata and creates the child room with elevated message/state power levels so member posting is blocked by room rules instead of only by client hints.
2. Group repository mapping treated every room as a normal group. Channel rooms carrying `n42.room.channel_meta` were never identified as `GroupType.channel`, which meant chat input never entered read-only mode and slow-mode metadata could not be applied. Channel metadata and power-level-derived posting rules are now mapped into `GroupEntity`.
3. Updating a group channel only rewrote the parent room's custom `n42.room.channels` state. The actual child room name/topic stayed stale, so the channel list and the opened room could diverge. Channel updates now sync both the parent metadata and the child room state.
4. Group/space custom settings writes relied almost entirely on UI gating. Data sources now fail early with explicit permission errors before attempting restricted state changes such as max-members, bot config, content filter, token gate, and space channel management.
5. `GroupTopicsPage` and `GroupChannelsPage` could load channels without loading the parent group's permissions, which hid management actions for admins until some other page had already primed `currentGroup`. Both pages now load group details alongside channels.
6. Group and space member management sheets exposed kick/ban or admin-role actions against self, owners, or equal-level admins. The UI now constrains destructive actions to targets the current role can actually manage.
7. `SpaceDetailPage` popped navigation immediately after dispatching leave/delete actions. A server-side failure could therefore surface after the user had already left the page. Leave/delete flows now wait for the success callback before popping.
8. `GroupSettingsPage` used one coarse `canChangeSettings` flag to gate unrelated actions. Avatar, name, description, visibility, channel management, bot config, content filter, member limit, and token-gate controls now respect per-action capabilities derived from room power levels and state-event permissions.
9. Group/channel success toasts mixed localized bloc keys with raw English strings (`Group visibility updated`, `Channel created`, etc.). Group and channel management success paths now use localized bloc keys consistently.

Targeted verification:

- `dart analyze` on group/space datasources, repositories, and pages
- `flutter test test/unit/repositories/group_repository_impl_test.dart`
- `flutter test test/unit/repositories/message_repository_impl_test.dart test/unit/blocs/group_bloc_test.dart`

Residual risk:

- `SpaceDetailPage` still infers admin capability from the loaded members list on the client side. If membership/power-level data is stale, the UI can temporarily hide valid actions until the page reloads, even though datasource-level checks now fail safe.
- Group settings and channel flows now use localized success keys, but several other group-related actions in `GroupBloc` still carry raw fallback error prefixes intended for logs rather than user-facing copy.

## Security, Backup & Storage

Reviewed first:

- `lib/src/core/services/chat_backup_service.dart`
- `lib/src/core/services/chat_lock_service.dart`
- `lib/src/presentation/blocs/backup/backup_bloc.dart`
- `lib/src/presentation/pages/settings/backup_restore_page.dart`
- `lib/src/core/services/storage_manager_service.dart`

Fixed this round:

1. `ChatBackupService.createBackup(...)` exposed an `includeKeys` option but never exported local encryption keys. The generated manifest still claimed `includesKeys: true`, which made the backup file look stronger than it was. File backups now explicitly record `includesKeys: false` and surface a warning that encrypted-message access is backed up separately through Recovery Key.
2. The backup UI advertised “Backup your settings and encryption keys” and let users toggle “Include encryption keys”, even though `.n42backup` files could not restore those keys. The page now removes that dead toggle and points users to `Security > Recovery Key`.
3. Settings backup was reading legacy secure-storage keys like `language`, `theme_mode`, and `auto_download`, but real chat settings live in `SharedPreferences` blobs such as `n42_chat_settings`, `n42_chat_appearance_settings`, and `n42_chat_auto_download_settings`. Backups now export and restore the actual preference payloads instead of empty or unused secure-storage slots.
4. `restoreFromBackup(...)` reported `keysRestored: restoreKeys` and `roomsRestored: rooms.length` even though it did not restore local keys or message history. Restore results now keep `keysRestored: false`, stop claiming room restoration, and tell the UI that message history will re-sync from the server.
5. Older flat backups can contain legacy keys like `language`, `theme_mode`, and `chat_font_size`. Restore now maps those into the current preference model so existing backup files are not stranded.
6. Chat-lock PINs were stored as unsalted SHA-256 hashes in `SharedPreferences`. New locks now use a per-room random salt, and successful verification of a legacy unsalted PIN transparently migrates it to the salted format.
7. Backup warnings previously had no way to reach the user without being treated as hard failures. `BackupBloc` now appends warnings to success messages so restore can still complete while warning that Recovery Key is separate.
8. The `Preserve Thumbnails` toggle in storage settings was a dead configuration path. Cleanable-file queries always excluded thumbnails regardless of the saved setting, so recommendations, cleanup execution, and cleanable-space totals never changed. Thumbnail preservation now flows through metadata queries, cleanup recommendations, storage-status totals, and the storage-management BLoC.
9. `restoreToArchive(...)` iterated backup messages and returned success counts without ever writing them into `archive.db`. Archive restore now maps backup payloads into `ArchivedMessagesCompanion`, skips already archived events, inserts new entries through `MessageArchiveService`, and updates archive metadata so restored rooms become queryable.

Targeted verification:

- `dart analyze` on backup service, lock service, backup bloc, backup page, and new tests
- `flutter test test/unit/services/chat_backup_service_test.dart test/unit/services/chat_lock_service_test.dart test/unit/blocs/backup_bloc_extended_test.dart`
- `dart analyze` on media metadata database, media lifecycle, storage cleanup, storage monitor, storage bloc, and storage tests
- `flutter test test/unit/services/storage_cleanup_service_test.dart test/unit/blocs/storage_management_bloc_test.dart test/unit/blocs/storage_management_bloc_extended_test.dart`

Residual risk:

- `.n42backup` still does not contain message bodies in a way that can be rehydrated directly into live room timelines; normal restore remains settings-only, while historical message import still depends on the separate archive path.
- Chat-lock PINs are now salted, but they are still stored in `SharedPreferences` rather than hardware-backed secret storage. That is acceptable for local feature gating, but it is not equivalent to secure-enclave-grade credential storage.

## Review Order

Recommended next sequence:

1. Conversation & Chat Core
2. Group & Space
3. Security, Backup & Storage
4. Contacts & Profile
5. Search & Discovery
6. Story & Moment
7. On-chain & Wallet Adjacent
8. AI, Social, Mini App & Voice Room
9. Sticker & Media Utilities
