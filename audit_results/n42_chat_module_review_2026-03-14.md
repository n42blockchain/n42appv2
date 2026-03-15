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
| Search & Discovery | `presentation/pages/search`, `presentation/pages/discover`, `presentation/blocs/search` | `search_repository_impl.dart` | P2 | done |
| Story & Moment | `presentation/pages/story`, `presentation/pages/moment`, `presentation/blocs/story`, `presentation/blocs/moment` | `story_repository_impl.dart`, `moment_repository_impl.dart` | P2 | in_progress |
| Notifications, Push & VoIP | `presentation/pages/notification`, `presentation/pages/call`, `core/notifications`, `services/voip` | `firebase_push_service.dart`, `push_notification_service.dart`, `call_manager.dart` | P1 | done |
| Security, Backup & Storage | `presentation/pages/security`, `presentation/pages/settings`, `presentation/blocs/backup`, `presentation/blocs/storage` | `chat_backup_service.dart`, `storage_manager_service.dart`, `chat_lock_service.dart` | P1 | in_progress |
| On-chain & Wallet Adjacent | `presentation/pages/transfer`, `presentation/pages/red_packet`, `presentation/pages/points`, `presentation/pages/governance`, `presentation/blocs/transfer`, `presentation/blocs/points`, `presentation/blocs/governance`, `presentation/blocs/on_chain_notification` | `transfer_repository_impl.dart`, `points_repository_impl.dart`, `governance_repository_impl.dart`, `on_chain_notification_repository_impl.dart` | P2 | in_progress |
| AI, Social, Mini App & Voice Room | `presentation/pages/ai`, `presentation/pages/social`, `presentation/pages/mini_app`, `presentation/pages/voice_room`, `presentation/blocs/ai_assistant`, `presentation/blocs/social`, `presentation/blocs/voice_room` | `ai_repository_impl.dart`, `social_graph_repository_impl.dart`, `voice_room_repository_impl.dart`, `mini_app_bridge_service.dart` | P2 | in_progress |
| Sticker & Media Utilities | `presentation/pages/media`, `presentation/pages/sticker`, `core/services/download_service.dart`, `core/services/url_preview_service.dart` | `sticker_repository_impl.dart` | P3 | in_progress |

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
11. `ContactDetailPage` and `FriendInfoPage` only refreshed remark display from `ContactBloc` state. When remark changes arrived through `RemarkService` directly, or those pages were opened without a `ContactBloc` ancestor, the visible name could stay stale. Both pages now subscribe to `RemarkService.onRemarkUpdated`, and `ContactDetailPage` merges cached remarks into loaded contact state.
12. `ContactDetailPage` repeatedly probed `ContactBloc` through `try { context.read<ContactBloc>() }` and dependency churn, which produced noisy logs in non-bloc contexts and unnecessary reloads. The page now resolves the bloc only when present and only refreshes local state on real contact/remark changes.
13. `ProfilePage` only refreshed user info on initial load and after returning from profile edit. Logout, session restore, and other `N42Chat` user changes could therefore leave old avatar/display-name/status values rendered on the tab until a manual rebuild. The page now listens to `N42Chat.userStream`, clears stale state on logout, and reloads when the active chat user changes.

Targeted verification:

- `dart analyze` on contact/profile repository and pages
- `flutter test test/unit/repositories/contact_repository_impl_test.dart`
- `flutter test test/presentation/pages/contact_settings_page_test.dart`
- `dart analyze` on `contact_detail_page.dart`, `profile_page.dart`, and `contact_detail_page_test.dart`
- `flutter test test/presentation/pages/contact_detail_page_test.dart`

Residual risk:

- Chat pages such as `chat_page.dart`, `chat_detail_page.dart`, and `message_item.dart` still read `RemarkService` directly instead of deriving sender display names from a single contact-view model, so remark coupling is reduced but not fully eliminated across the module.
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
10. `cleanupByDateRange(...)` only used `endDate` and ignored `startDate` completely. A caller asking to clean “between A and B” could therefore delete every eligible file older than `endDate`, including files far outside the intended range. Date-range cleanup now filters on both bounds and rejects inverted ranges early.
11. Room-specific cleanup recommendations estimated reclaimable space from total room media stats instead of actual cleanable files. Rooms with mostly pinned files or preserved thumbnails could therefore show large “reclaimable” recommendations that freed little or nothing when executed. Recommendations now calculate room-specific size and file counts from the same cleanable-file query used by execution.
12. Storage cleanup did not invalidate `StorageManagerService`'s 5-minute usage cache after deleting media files. Immediate post-cleanup refreshes could keep showing stale total-used bytes even though file deletion had already succeeded. Cleanup paths now invalidate cached storage totals after successful media deletion.
13. `RoomStorageDetailPage` deleted selected files, immediately cleared selection, and manually reloaded the list before cleanup completed. Failed deletes therefore still lost the user selection, and successful deletes could briefly repopulate the page with stale room data. The page now waits for cleanup completion, and the bloc reloads the current room detail after successful room-scoped deletion.
14. `DeleteSelectedFiles` used `MediaLifecycleService.cleanupFiles(...)` directly and then reloaded storage summary without invalidating `StorageManagerService`'s cache. Room-detail deletes could therefore free disk space while the top-level storage numbers stayed stale for up to five minutes. The delete path now invalidates cache before reloading storage info.

Targeted verification:

- `dart analyze` on backup service, lock service, backup bloc, backup page, and new tests
- `flutter test test/unit/services/chat_backup_service_test.dart test/unit/services/chat_lock_service_test.dart test/unit/blocs/backup_bloc_extended_test.dart`
- `dart analyze` on media metadata database, media lifecycle, storage cleanup, storage monitor, storage bloc, and storage tests
- `flutter test test/unit/services/storage_cleanup_service_test.dart test/unit/blocs/storage_management_bloc_test.dart test/unit/blocs/storage_management_bloc_extended_test.dart`
- `dart analyze` on `room_storage_detail_page.dart`, `storage_management_bloc.dart`, `storage_management_event.dart`, and updated storage tests
- `flutter test test/unit/blocs/storage_management_bloc_extended_test.dart test/unit/blocs/storage_management_event_test.dart`

Residual risk:

- `.n42backup` still does not contain message bodies in a way that can be rehydrated directly into live room timelines; normal restore remains settings-only, while historical message import still depends on the separate archive path.
- Chat-lock PINs are now salted, but they are still stored in `SharedPreferences` rather than hardware-backed secret storage. That is acceptable for local feature gating, but it is not equivalent to secure-enclave-grade credential storage.

## Search & Discovery

Reviewed first:

- `lib/src/data/datasources/matrix/matrix_search_datasource.dart`
- `lib/src/data/repositories/search_repository_impl.dart`
- `lib/src/presentation/blocs/search/search_bloc.dart`
- `lib/src/presentation/pages/search/global_search_page.dart`
- `lib/src/presentation/pages/search/chat_search_page.dart`

Fixed this round:

1. Search history was only stored in a private in-memory list inside `SearchRepositoryImpl`. `LoadSearchHistory`, clear-history, and delete-history therefore looked correct during the same process but lost everything after restart, while `MatrixSearchDataSource` already contained unused `SharedPreferences` persistence. The repository now delegates history reads and writes to the datasource, and single-item delete is persisted too.
2. `SearchBloc` used `debounceTime(...).flatMap(mapper)` for global and in-chat search. Once an older request had already started, a slower response could arrive after a newer query and overwrite the current results with stale state. The transformer now uses `switchMap`, so the latest query wins.
3. `searchLocalConversations(...)` included joined group rooms even though global search already collected groups separately. In the “All” tab, group chats therefore appeared twice: once from `searchGroups()` and again from `searchConversations()`. Conversation search now only returns joined direct chats, leaving groups in the dedicated group bucket.

Targeted verification:

- `dart analyze` on search datasource, repository, bloc, and new tests
- `flutter test test/unit/repositories/search_repository_impl_test.dart test/unit/datasources/matrix_search_datasource_test.dart test/unit/blocs/search_bloc_test.dart test/unit/blocs/search_bloc_extended_test.dart`

Residual risk:

- Message-result taps still only open the containing room; they do not jump to the exact event yet because the public `N42Chat.openConversation(...)` API has no event-target parameter.
- ENS search hits are still modeled as generic contact results, but the result tap path assumes every contact ID is a Matrix user ID. That cross-domain result type still needs a dedicated target flow instead of reusing `openUserProfile(...)`.

## Story & Moment

Reviewed first:

- `lib/src/data/repositories/moment_repository_impl.dart`
- `lib/src/data/repositories/story_repository_impl.dart`
- `lib/src/presentation/blocs/story/story_bloc.dart`

Fixed this round:

1. `MomentRepositoryImpl` kept `_unreadCount`, but it never recomputed it from loaded or watched moments. Unread badges could therefore stay stale at zero until `markMomentsAsRead()` was called. The repository now recomputes unread count from the visible moment list after both `getMoments(...)` and `watchMoments()`.
2. Unread counting and “my own moment” visibility relied only on `MomentEntity.isFromMe`. If a moment was constructed without that flag but still carried the current user’s `userId`, it was counted as someone else’s moment. The repository now falls back to `moment.userId == currentUserId` so self-authored moments stay self-authored even when the boolean flag is missing.
3. `getMomentById(...)` bypassed the same privacy filters used by list queries, so a moment from a hidden user could still be fetched directly by ID and rendered in detail flows. The repository now runs the fetched moment through `_filterMoments(...)` before returning it.
4. `StoryRepositoryImpl.deleteStory(...)` silently no-op’d when the target story was no longer present in the locally loaded story list. If a caller only had the Matrix event ID, delete would appear to succeed while leaving the story on the server. The repository now falls back to deleting the incoming ID directly when it already looks like a Matrix event ID.
5. `StoryBloc` refreshed `userStories` on subscription updates but left `myStories` stale. After `watchStories()` emitted, the “my stories” strip could still show old data until a full reload. The bloc now captures `currentUserId` during load and recomputes `myStories` from incoming streamed `UserStories`.
6. `StoryViewerPage` only exposed a parameterless `onStoryViewed` callback. Callers therefore had no reliable way to know which story was currently visible, and the conversation list recorded the first story of the originally tapped user even after the viewer advanced to a different story or a different user. The callback now passes the actual visible `StoryEntity`, and the caller records the correct story ID.
7. Story replies discarded the typed message. The viewer collected reply text, but `ConversationListPage._handleStoryReply(...)` only created or opened the DM room and never sent the message. Story replies now send the typed text through `IMessageRepository.sendTextMessage(...)` before opening the conversation.
8. `CreateStoryPage` popped immediately after dispatching `PostStory`, before the async upload result was known. On failure the compose page was already gone, so the user lost their draft and only got a late error state elsewhere. The page now runs inside `StoryBloc`, waits for `isPosting` to transition back to false, and only closes on success.
9. `MomentBloc` did not clear stale `errorMessage` when starting a new post. `CreateMomentPage` decides whether to close based on `state.hasError`, so a prior unrelated error could keep a later successful post from closing the page. Post handlers now clear old errors before starting upload.
10. `MomentDetailPage` cleared the comment draft and reply target immediately after dispatching `CommentMoment(...)`. When the repository call failed, the user lost the typed comment and had to reselect the reply target. `MomentState` now carries a lightweight comment-submission result signal, and the detail page only clears the draft on confirmed success while preserving it on failure.
11. `MomentDetailPage` also probed `ContactBloc` through `try { context.read<ContactBloc>() }` in no-provider contexts, which produced repeated provider errors in tests and any host flow that opened the page without contact state. The page now resolves `ContactBloc?` safely and falls back to an empty friend set without log spam.
12. `StoryViewerPage` treated story replies as fire-and-forget. The viewer cleared the reply draft immediately even though `ConversationListPage._handleStoryReply(...)` still had to create a DM, send the message, and open the room asynchronously. The callback contract now returns `Future<bool>`, the viewer keeps the draft on failure, clears it only on success, and resets stale reply input when the visible story changes.
13. `MomentListPage` still used “dispatch then immediately close dialog” for both comment and delete actions. A failed comment or delete therefore dismissed the dialog before the result was known, hiding the failure and discarding the in-progress comment text. The bloc now exposes delete-action result signals alongside comment-action signals, and the list page’s comment/delete dialogs only close on confirmed success.
14. `MomentListPage` also probed `ContactBloc` through a throwing `context.read<ContactBloc>()` path, which produced avoidable provider errors when moments were opened outside the contacts shell. The page now resolves `ContactBloc?` safely and falls back to an empty friend set.
15. Story deletion still had no connected UI path even though `DeleteStory` already existed in the bloc and repository. `StoryViewerPage` now exposes a delete action for the current user’s own story, `ConversationListPage` wires that back into `StoryBloc`, and `StoryState` carries delete-action result signals so the viewer only closes after confirmed success.
16. `ConversationListPage` also used a noisy `try { context.read<ContactBloc>() }` probe just to decide whether to wrap a listener. That produced avoidable provider errors in hosts without a contact bloc. The page now uses nullable lookup instead of exception-driven detection.

Targeted verification:

- `dart analyze` on story/moment repositories, story bloc, and new tests
- `flutter test test/unit/repositories/moment_repository_impl_test.dart test/unit/repositories/story_repository_impl_test.dart test/unit/blocs/story_bloc_test.dart test/unit/blocs/story_bloc_extended_test.dart test/unit/blocs/moment_bloc_test.dart test/unit/blocs/moment_bloc_extended_test.dart`
- `dart analyze` on `create_story_page.dart`, `story_viewer_page.dart`, `conversation_list_page.dart`, `moment_bloc.dart`, and new page tests
- `flutter test test/presentation/pages/story/create_story_page_test.dart test/presentation/pages/story/story_viewer_page_test.dart`
- `dart analyze` on `moment_state.dart`, `moment_detail_page.dart`, `moment_forward_sheet.dart`, `story_viewer_page.dart`, and updated page tests
- `flutter test test/presentation/pages/moment/moment_detail_page_test.dart test/presentation/pages/story/story_viewer_page_test.dart`
- `dart analyze` on `moment_list_page.dart`, `moment_state.dart`, `moment_bloc.dart`, and updated bloc tests
- `flutter test test/unit/blocs/moment_bloc_test.dart test/unit/blocs/moment_bloc_extended_test.dart test/presentation/pages/moment/moment_detail_page_test.dart`
- `dart analyze` on `story_state.dart`, `story_bloc.dart`, `story_viewer_page.dart`, `conversation_list_page.dart`, and updated story tests
- `flutter test test/unit/blocs/story_bloc_test.dart test/presentation/pages/story/story_viewer_page_test.dart`

Residual risk:

- Story reporting/other moderation paths still do not exist in the current story UI, so only the delete path is now success-driven; any future report/hide actions should follow the same pattern instead of dismissing first.
- Moment privacy filtering still depends on locally cached hide/block settings only; if another device changes those preferences, visibility can remain stale until the local settings store is refreshed.

## On-chain & Wallet Adjacent

Reviewed first:

- `lib/src/data/repositories/transfer_repository_impl.dart`
- `lib/src/data/repositories/governance_repository_impl.dart`
- `lib/src/domain/entities/on_chain_notification_entity.dart`

Fixed this round:

1. `TransferRepositoryImpl.initiateTransfer(...)` treated Matrix message-send failure as total transfer failure. If the wallet transfer succeeded on-chain but `sendTransferMessage(...)` threw, the repository bubbled the exception and the UI reported a failed transfer even though funds had already moved. The repository now preserves the successful transfer result, logs the chat-message failure, and only attaches `eventId` when the chat message actually succeeds.
2. Transfer records were not actually associated with rooms. The entity had `eventId` but no `roomId`, `initiateTransfer(...)` never stored the message event ID, and `getTransfersByRoom(...)` filtered by `eventId != null` instead of the requested room. Transfers now persist both `roomId` and `eventId`, and room queries filter correctly.
3. `GovernanceRepositoryImpl.getSpace(...)` cast Snapshot `strategies` to `Map<String, dynamic>?`, but Snapshot returns a list of strategy objects. Space loading could therefore throw a runtime type error as soon as a space carried normal strategy data. `GovernanceSpace` now stores `strategies` as a list, and the repository maps the GraphQL payload accordingly.
4. `OnChainNotificationEntity.fromPushProtocol(...)` used an empty string when Push payloads omitted `payload_id`. Multiple notifications could therefore collapse onto the same local read-state key and interfere with each other. The entity now derives a stable synthetic ID from sender, epoch, title, and body when `payload_id` is missing.
5. `PointsRepositoryImpl._parseConfig(...)` silently mapped unknown backend action names to `PointsAction.sendMessage`. Any new or mistyped action from the server could therefore become a fake “send message” rule and corrupt point-award behavior. Unknown actions are now ignored instead of being remapped.
6. `PointsTrackingService` ignored room reward configuration entirely and used hardcoded defaults for daily login points, cooldown, and daily limits. That made the points-config UI largely cosmetic. The service now resolves room config first, uses configured rule settings when available, and only falls back to the previous defaults when config cannot be loaded.
7. `SendRedPacketPage` and `SendTransferPage` dismissed themselves immediately after invoking `onSend(...)`, even though red-packet creation and chat message dispatch can still fail asynchronously. Both pages now treat send callbacks as `Future<bool>`, keep the form open on failure, and only close after confirmed success. The transfer slider is also forced to rebuild after a failed attempt so it does not get stuck in a completed state.
8. Red-packet creation generated a real `redPacket.id`, but the subsequent chat message never carried that ID. Claim/open flows later used `message.id` as the packet ID, which only worked accidentally when the two IDs happened to match. Red-packet metadata and Matrix custom-message payloads now carry `red_packet_id`, and the tap handler claims against that persisted ID instead of the Matrix event ID.
9. `chat_page_more_features.dart` logged red-packet creation failures and then continued to send a red-packet chat message anyway. The flow now fails closed for creation errors: it surfaces a local error, returns `false` to the composer page, and does not emit a bogus claimable message when no packet was actually created.
10. `PointsAdminPage._save()` cleared `_isDirty` before the async config update finished. If the save failed, the unsaved form still differed from server state but the Save action disappeared, making the failure easy to miss and hard to retry. The page now keeps a separate `_isSaving` flag and only clears dirty state after a confirmed loaded config update.
11. Proposal creation returned the user to the list page without refreshing proposals. After a successful create, `CreateProposalPage` now pops with `true`, and `ProposalsListPage` awaits that result and reloads the list immediately.
12. Governance proposal detail and vote flows only refreshed `selectedProposal`. The proposals list still kept the stale proposal snapshot, so returning from detail after loading or voting could show outdated title, score, or vote-count data. `GovernanceBloc` now merges refreshed proposal detail back into the list for both detail-load and vote-success paths.

Targeted verification:

- `dart analyze` on transfer/governance repositories, `transfer_entity.dart`, `governance_space.dart`, `on_chain_notification_entity.dart`, and new tests
- `flutter test test/unit/repositories/transfer_repository_impl_test.dart test/unit/repositories/governance_repository_impl_test.dart test/unit/entities/on_chain_notification_entity_test.dart`
- `dart analyze` on `points_repository_impl.dart`, `points_tracking_service.dart`, and new points tests
- `flutter test test/unit/repositories/points_repository_impl_test.dart test/unit/services/points_tracking_service_test.dart`
- `dart analyze` on red-packet/transfer send pages, chat red-packet handlers, metadata extraction, and updated message-entity tests
- `flutter test test/presentation/pages/red_packet_send_pages_test.dart test/unit/entities/message_entity_extended_test.dart`
- `dart analyze` on `points_admin_page.dart`, `create_proposal_page.dart`, `proposals_list_page.dart`, and new page tests
- `flutter test test/presentation/pages/points_admin_page_test.dart test/presentation/pages/governance/proposals_list_page_test.dart`
- `dart analyze` on `governance_bloc.dart` and governance bloc tests
- `flutter test test/unit/blocs/governance_bloc_test.dart`

Residual risk:

- `presentation/pages/points` is still only partially reviewed in this module, so leaderboard pagination, redemption UX, and proposal/points overlap remain open.
- Transfer history is still in-memory only; after process restart the repository still cannot reconstruct historical transfers unless that data is later parsed from Matrix events or persisted locally.

## AI, Social, Mini App & Voice Room

Reviewed first:

- `lib/src/data/repositories/social_graph_repository_impl.dart`
- `lib/src/core/services/mini_app_bridge_service.dart`
- `lib/src/services/voip/voice_room_service.dart`
- `lib/src/presentation/blocs/voice_room/voice_room_bloc.dart`
- `lib/src/presentation/pages/voice_room/voice_room_list_page.dart`
- `lib/src/presentation/pages/voice_room/voice_room_page.dart`
- `lib/src/presentation/blocs/ai_assistant/ai_assistant_bloc.dart`
- `lib/src/presentation/pages/mini_app/mini_app_page.dart`
- `lib/src/presentation/pages/mini_app/mini_app_market_page.dart`

Fixed this round:

1. `searchProfiles(...)` only tried ENS/Lens/Farcaster resolution. Entering a raw wallet address returned no results even though `getProfile(...)` fully supports address-based lookup. Direct address queries now short-circuit into `getProfile(...)` and still fall back to a minimal profile if enrichment fails.
2. `getConnections(...)` flattened recommendation connections without deduplication. The same `(fromAddress, toAddress, type)` edge could appear multiple times when several recommendations shared it, which polluted UI counts and downstream consumers. Connections are now deduplicated by source, target, and connection type.
3. `MiniAppBridgeService` defined `chatRead/chatSend` permissions but never enforced them. Mini apps can no longer read room IDs or send chat messages unless those permissions are explicitly declared, and blank/whitespace chat sends are ignored.
4. When mini-app metadata was missing, the bridge defaulted to allow-all for wallet methods. The fallback now keeps only low-risk wallet-address access and no longer silently opens balance/transaction capabilities.
5. `VoiceRoomService.joinRoom(...)` previously treated every join as `listener`, even when the server-side room state marked the current user as host/speaker. The service now syncs role and mute state from the actual room participant record after join and on subsequent room updates, so host controls no longer disappear.
6. `VoiceRoomService.toggleMute()` used to flip local UI state before knowing whether the action succeeded. The bloc now reports toggle failures instead of leaving a false muted/unmuted indicator behind.
7. `VoiceRoomListPage` only dispatched `JoinVoiceRoom` and never navigated into the room page. Existing-room taps now route directly to the voice-room screen, and successful create-and-join flows now auto-open the new room.
8. `VoiceRoomPage` left hosts on a dead detail page after `EndVoiceRoom()` because the state disconnected but the screen stayed mounted. Page exit is now driven by the connection state dropping to disconnected, which also unifies the normal leave flow.
9. `AiAssistantBloc` let an old generation stream continue after switching assistants or clearing history. That could append/save the old response under the new assistant. Switching, re-initializing, and clearing history now cancel the active stream and clear partial text first.
10. `MiniAppPage` could still receive WebView progress/lifecycle callbacks after the page had begun disposing, which risked `setState()` or `runJavaScript()` against a torn-down widget/controller. Lifecycle JS calls are now wrapped safely and page/progress callbacks are guarded by `mounted`.
11. `MiniAppMarketPage` rendered 7 tabs (`All + MiniAppCategory.values`) but only created a `TabController` for 6 categories because `social` was missing from `_categories`. The market page now includes the social tab in the controller model, and a widget test locks that contract in.

Targeted verification:

- `dart analyze` on `social_graph_repository_impl.dart`, `mini_app_bridge_service.dart`, `voice_room_service.dart`, `voice_room_bloc.dart`, `voice_room_page.dart`, `voice_room_list_page.dart`, `ai_assistant_bloc.dart` and the new/updated tests
- `dart analyze` on `mini_app_page.dart`, `mini_app_market_page.dart` and the new market-page widget test
- `flutter test test/unit/repositories/social_graph_repository_impl_test.dart`
- `flutter test test/unit/services/mini_app_bridge_service_test.dart test/unit/services/voice_room_service_test.dart`
- `flutter test test/unit/blocs/voice_room_bloc_test.dart test/unit/blocs/voice_room_bloc_extended_test.dart`
- `flutter test test/unit/blocs/ai_assistant_bloc_test.dart test/unit/blocs/ai_assistant_bloc_extended_test.dart`
- `flutter test test/presentation/pages/mini_app_market_page_test.dart`

Residual risk:

- `voice_room_repository_impl.dart` still exposes a backend `toggleMute(...)` that is effectively a no-op placeholder. UI state is now honest about failures, but actual voice-room microphone control is still not wired to a media engine the way `group_call_screen` is.
- `mini_app_bridge_service.dart` is materially safer now, but there is still no per-app runtime permission grant/deny flow; permissions remain manifest-driven.
- `ai_repository_impl.dart` itself remains lightly reviewed compared with the bloc. Persistence is per-assistant and bounded, but no concurrent write coordination has been audited yet.

## Sticker & Media Utilities

Reviewed first:

- `lib/src/data/repositories/sticker_repository_impl.dart`
- `lib/src/presentation/pages/sticker/sticker_store_page.dart`

Fixed this round:

1. `StickerRepositoryImpl.getStorePacks(category: ...)` ignored the category argument entirely and always returned the same sample store list. Category queries now filter the sample catalog consistently before pagination.
2. `StickerRepositoryImpl.searchPacks(...)` could return the same sticker pack twice when an installed pack also matched the sample store data. Search results are now deduplicated by pack ID, preferring the installed copy.
3. `StickerStorePage` had a category chip UI, but the local filter function always returned `true`, so selecting `Animals`, `Food`, and similar chips never changed the displayed list. The page now applies the same category matching rules as the repository.
4. `VoiceMessageWidget` and `ChatInputBar` instantiated `VoiceService()` directly instead of using the DI-managed shared service. Playback state and recorder state could therefore split across multiple unmanaged service instances. Both widgets now prefer the registered `VoiceService`, fall back safely only when DI is unavailable, and only dispose locally owned fallback instances.
5. `VoiceService.play(...)` downloaded authenticated Matrix voice files into temp storage but never deleted them after playback or stop. The service now tracks downloaded playback files and cleans them on stop, completion, and dispose.
6. `MediaGalleryPage` listed file/audio entries but did nothing on tap. PDF files now open the existing `PdfViewerPage` with auth headers, and other files at least trigger the standard download flow instead of a dead tap target.
7. `UrlPreviewService` could not be tested through its real network surface and only parsed meta tags that used double quotes. The service now supports injected clients/clocks for tests, handles single-quoted meta tags, blocks the whole `127.0.0.0/8` loopback range, and has coverage for request coalescing, cache TTL, and private-address rejection.

Targeted verification:

- `dart analyze` on `sticker_repository_impl.dart`, `sticker_store_page.dart`, and the new sticker repository test
- `flutter test test/unit/repositories/sticker_repository_impl_test.dart`
- `dart analyze` on `voice_service.dart`, `voice_message_widget.dart`, `chat_input_bar.dart`, `media_gallery_page.dart`, `url_preview_service.dart`, and `url_preview_service_test.dart`
- `flutter test test/unit/services/url_preview_service_test.dart`

Residual risk:

- `media_gallery_page.dart` still routes non-PDF files to download rather than a richer inline preview flow, so audio/file browsing remains functional but basic.
- `voice_service.dart` still relies on direct platform audio/record APIs and has no dedicated unit coverage for playback-file cleanup because the current service is not yet abstracted behind a testable audio adapter.
- The sticker store is still backed by sample data rather than a real remote catalog; this round only made the current fallback behavior internally consistent.

## Review Order

Recommended next sequence:

1. Security, Backup & Storage
2. Contacts & Profile
3. Story & Moment pages
4. On-chain & Wallet Adjacent (`points` remaining)
5. AI, Social, Mini App & Voice Room (`voice room media backend` remaining)
6. Sticker & Media Utilities (inline file/audio preview depth and store backend remain)
