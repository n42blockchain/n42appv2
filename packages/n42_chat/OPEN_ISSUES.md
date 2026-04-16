# Open Issues Ledger

This file tracks unresolved issues intentionally left open during recent agent work in `n42_chat`.

## Update Rules

- Add or update an entry whenever work ends with an unresolved bug, unsupported path, partial implementation, or meaningful verification gap.
- Update an existing entry instead of creating a duplicate when the issue is already listed.
- Remove an entry only after the fix is implemented and verified, or mark it `Resolved` with a short note if keeping history is useful.
- Keep entries concrete: current behavior, why it is still open, and the next step needed to close it.

## Active Issues

### SOCIAL-001 Nearby people is still not implemented as a real discovery feature

- Severity: M
- Added: 2026-03-21
- Evidence: `lib/src/presentation/pages/discover/discover_page.dart`, `lib/src/presentation/pages/chat/location_picker_page.dart`
- Current state: entertainment/social review confirmed that Moments, Stories, Games, QR scan, Voice Rooms, and Mini Apps already exist, and Discover now exposes the reusable Live/Mini App entries. However there is still no dedicated nearby-people repository, proximity protocol, privacy consent flow, or real "people around me" page. The only nearby-related UI in the repo today is place selection for location sharing, which is not user discovery.
- Next step: define the proximity model first, for example explicit ephemeral location sharing, server-side geo buckets, or a privacy-preserving nearby service, then add the opt-in UI and ranking/filtering rules on top of that data source.

### SOCIAL-002 AR effects are still missing beyond reusable image filters/editor tools

- Severity: M
- Added: 2026-03-21
- Evidence: `lib/src/presentation/pages/story/create_story_page.dart`, `lib/src/presentation/pages/moment/create_moment_page.dart`, `lib/src/presentation/pages/media/media_editor_page.dart`
- Current state: Stories and Moments now reuse the existing `MediaEditorPage` flow, so crop/draw/text/filter editing is available for social posting without duplicating editor code. However there is still no real AR stack for masks, face anchors, body tracking, or camera-time effects.
- Next step: choose the supported AR surface and SDK first, then decide whether it should run only at capture time, export rendered media into Stories/Moments, or also support live preview and interactive effects.

### SOCIAL-003 Virtual avatar support is still decorative, not a full persona system

- Severity: M
- Added: 2026-03-21
- Evidence: `lib/src/presentation/widgets/common/n42_avatar.dart`, `lib/src/presentation/pages/profile/profile_edit_page.dart`, `lib/src/domain/entities/avatar_decoration_preset.dart`
- Current state: the latest entertainment/social pass added reusable avatar-decoration presets so profile and settings surfaces can share a consistent decorated avatar without duplicating border/badge code. However there is still no full virtual-avatar stack such as custom character builders, Bitmoji-style assets, 3D mesh avatars, or cross-user persona syncing beyond the owner account's profile data.
- Next step: decide whether the product wants lightweight 2D avatar kits, full 3D avatars, or both, then define the asset model, editor flow, and how avatar persona data should sync across devices and other users' clients.

### SOCIAL-004 24-hour status expiry is still client-owned, not an authoritative cross-user protocol

- Severity: M
- Added: 2026-03-21
- Evidence: `lib/src/data/datasources/matrix/matrix_contact_datasource.dart`, `lib/src/core/utils/timed_status_utils.dart`, `lib/src/presentation/pages/profile/status_page.dart`
- Current state: status posts now store expiry metadata and the client clears expired statuses on session restore/profile reads instead of treating "visible for 24 hours" as a pure label. However the expiry is still enforced by the owner's client path. Other users still only see Matrix presence text, so there is no canonical shared expiry event that remote clients can independently honor.
- Next step: define a shared status-expiry model, for example room/state/account-data that contacts can read or a server-shaped ephemeral-status API, then migrate contact rendering off plain presence text for this feature.

### OFFICE-001 Task / todo and calendar collaboration are still not implemented

- Severity: M
- Added: 2026-03-21
- Evidence: no task entity, assignee/state model, calendar sync datasource, or task/calendar UI flow was added in the recent office-collaboration review of `lib/` and `test/`.
- Current state: chat search, rich text, mentions, export/backup, and basic collaboration primitives exist, but there is still no real task/todo domain model or calendar integration path.
- Next step: define a task entity + storage/sync model first, then decide whether calendar support should be Matrix state/account data, an external CalDAV/ICS bridge, or both.

### OFFICE-002 Whiteboard and spreadsheet collaboration are still absent

- Severity: M
- Added: 2026-03-21
- Evidence: no canvas/whiteboard renderer, drawing sync protocol, spreadsheet grid/editor, or collaborative state engine was found in the current codebase.
- Current state: rich-text messages and document preview exist, but there is still no shared whiteboard/canvas or worksheet-style collaboration surface.
- Next step: choose a collaboration engine (CRDT/OT or server-owned state) and a rendering/editor stack before wiring room permissions and persistence.

### OFFICE-003 Audit logging is still missing

- Severity: M
- Added: 2026-03-21
- Evidence: no audit-log repository, append-only event sink, or admin-facing audit UI was found during the office-collaboration review.
- Current state: group settings and moderation actions exist, but they are not mirrored into a durable audit stream for enterprise review/export.
- Next step: define the audit event schema and storage boundary, then hook high-value actions such as membership changes, permission changes, export/backup actions, and moderation actions into it.

### COMPLIANCE-001 DLP remains a client-side display filter, not an enforced policy system

- Severity: M
- Added: 2026-03-21
- Evidence: `lib/src/core/utils/content_filter_utils.dart`, `lib/src/presentation/blocs/chat/chat_bloc_message_handlers.part.dart`, `lib/src/presentation/pages/group/content_filter_settings_page.dart`
- Current state: groups can now configure keyword and sensitive-data redaction/hide rules, but enforcement currently happens only in the client when rendering loaded text messages. It does not block outbound sends, scan files, enforce server-side policy, or produce compliance/audit artifacts.
- Next step: decide which DLP paths must be authoritative, then add pre-send checks, media scanning hooks, and a server-side/admin-enforced policy surface instead of relying only on local rendering filters.

### AUTO-001 Group bot webhook/workflow automation is still client-session scoped

- Severity: M
- Added: 2026-03-21
- Evidence: `lib/src/presentation/blocs/group/group_bloc.dart`, `lib/src/core/services/bot_webhook_service.dart`
- Current state: member-join welcome messages and webhook callbacks now share the same room bot config, but they still execute from the client-side `GroupBloc`. If no logged-in client is online and subscribed, those automations do not fire.
- Next step: move room automation triggers to a durable server-side worker/bot account, or introduce a background sync service with explicit delivery guarantees.

### MEDIA-002 Encrypted-room large file uploads still cap at 64MB

- Severity: H
- Added: 2026-03-20
- Evidence: `lib/src/presentation/pages/chat/chat_page_media_actions.dart`, `lib/src/data/datasources/matrix/message/matrix_media_sender.dart`
- Current state: the secure fallback for encrypted rooms intentionally fail-closes above 64MB to avoid sending unencrypted attachments. Large-file support therefore does not meet the `>2GB` requirement for encrypted rooms.
- Next step: implement a streaming encrypted upload path that preserves Matrix attachment encryption semantics instead of falling back to whole-file bytes or unencrypted upload.

### MEDIA-003 Built-in document preview is still incomplete for office formats

- Severity: M
- Added: 2026-03-20
- Evidence: `lib/src/presentation/pages/chat/chat_page_event_handlers.dart`, `lib/src/presentation/pages/chat/viewers/text_document_preview_page.dart`
- Current state: built-in preview currently covers text-like formats such as `txt`, `md`, `json`, `log`, `csv`, `yaml`, `xml`, and `html`. `docx`, `xlsx`, and `pptx` still do not have true in-app preview support.
- Next step: add a safe office-document rendering path or explicitly route these formats to a separate preview/open flow with clear UX.

### MEDIA-004 Collaborative document editing is not implemented

- Severity: M
- Added: 2026-03-20
- Evidence: no CRDT/OT/co-editing implementation was found in the recent review of `lib/` and `test/`.
- Current state: files can be sent and, for some formats, previewed, but they cannot be co-edited in-app.
- Next step: choose a collaboration model and editor stack, then define room/document synchronization, permissions, and conflict handling.

### MSG-001 Recent real-homeserver smoke does not cover several advanced message features

- Severity: M
- Added: 2026-03-20
- Evidence: `tool/live_message_smoke.dart`
- Current state: the live smoke script covers UTF-8 text, reply, edit, reaction redaction, and thread behavior, and now includes a poll send/vote/end path in code. However the latest confirmed real-homeserver run still does not cover search, favorites/bookmarks, pinning, built-in translation, scheduled send, and the new poll path still needs a live run with credentials to count as verified.
- Next step: run the updated smoke script against a real homeserver, then either extend it further for the remaining Matrix-facing flows or add a Flutter-hosted live test path for client-local features such as scheduled send that depend on local storage/BLoC wiring.

### CALL-001 Background blur / replacement still lacks a real video processor path

- Severity: M
- Added: 2026-03-21
- Evidence: `lib/src/services/voip/livekit_service.dart`, `lib/src/services/voip/webrtc_service.dart`
- Current state: call config and toggles exist for background blur / virtual background, but the actual processor hookup is still not implemented. LiveKit currently only stores the config and logs intent, and the 1:1 WebRTC path still has no outbound background-processing pipeline.
- Next step: wire a real local video processor into LiveKit local tracks and decide whether 1:1 calls should share the same processor stack or explicitly remain unsupported.

### CALL-002 Call recording still depends on missing server-side Egress wiring

- Severity: M
- Added: 2026-03-21
- Evidence: `lib/src/services/voip/livekit_service.dart`
- Current state: the client exposes recording config, but `startRecording()` still returns `false` and `stopRecording()` is a no-op because there is no backend Egress integration.
- Next step: add an authenticated backend endpoint that starts/stops LiveKit Egress jobs and surface its status back into the client.

### CALL-004 Exact per-app system ringtone playback is still constrained by CallKit/plugin limits

- Severity: M
- Added: 2026-03-21
- Evidence: `lib/src/services/voip/incoming_call_ringtone_preference.dart`, `lib/src/services/voip/call_notification_service.dart`, `lib/src/core/notifications/firebase_push_service.dart`
- Current state: ringtone preference is now persisted locally and applied to foreground/background incoming-call params. However `flutter_callkit_incoming` still only accepts `system_ringtone_default` or bundled app resources, not arbitrary Android ringtone URIs. Exact system-ringtone picks are therefore normalized to the OS default sound for CallKit playback, and `silent` / `vibrate` still fall back to system default on iOS until the host app ships dedicated bundled assets.
- Next step: either limit the ringtone UI to truly supported options per platform, or replace the current CallKit sound path with a deeper native implementation that can honor exact system ringtone URIs and silent/vibrate semantics.

### CALL-005 Legacy profile ringtone labels are not fully migrated into the new local CallKit preference

- Severity: M
- Added: 2026-03-21
- Evidence: `lib/src/services/voip/incoming_call_ringtone_preference.dart`, `lib/src/presentation/pages/profile/profile_ringtone_select_page.dart`, `lib/src/data/repositories/auth_repository_impl.dart`
- Current state: the new incoming-call ringtone bridge reads from local SharedPreferences, while older accounts may only have a `ringtone` label stored in Matrix account data. The ringtone picker now prefers the local preference when present, but there is still no app-start/session-time migration that converts legacy server-stored labels into the new local format before the next incoming call arrives.
- Next step: add a migration step during profile/session load, ideally by switching the persisted profile field to a stable ringtone key instead of a localized display label.

### SEC-001 Full 2FA is still missing

- Severity: M
- Added: 2026-03-20
- Evidence: `lib/src/presentation/pages/settings/security_settings_page.dart`
- Current state: the current security surface covers biometrics and passkey management, but not a full TOTP/SMS-style 2FA flow with enrollment, challenge, recovery, and device migration semantics.
- Next step: decide the supported 2FA modes and implement the required client and homeserver flows end to end.

### SEC-002 Screenshot blocking exists, but screenshot notification is still not surfaced

- Severity: M
- Added: 2026-03-20
- Evidence: `lib/src/core/services/screenshot_protection_service.dart`
- Current state: the service enables screenshot/screen-recording protection, but it does not expose a cross-platform callback or event stream that the app can use for "screenshot taken" notification behavior.
- Next step: add native hooks on supported platforms and surface a Dart-side event API for policy/UI handling.

### SEC-004 Account deactivation still lacks a full non-password UIA flow

- Severity: M
- Added: 2026-03-20
- Evidence: `lib/src/presentation/pages/settings/security_settings_page.dart`, `lib/src/core/utils/matrix_uia_utils.dart`, `lib/src/data/datasources/matrix/matrix_auth_datasource.dart`
- Current state: account deactivation no longer forces a password up front, but the retry path only handles `m.login.password`. Homeservers that require SSO/passkey or other UIA stages still fail closed.
- Next step: implement a generic UIA handler for deactivation instead of password-only fallback logic.

### SEC-005 iOS background APNs still bypasses client-side notification privacy mode

- Severity: H
- Added: 2026-03-21
- Evidence: `lib/src/core/notifications/firebase_push_service.dart`, `lib/src/n42_chat.dart`
- Current state: foreground notification privacy now applies in the local-notification path, and foreground iOS banners are suppressed when preview privacy would leak content. However iOS background/locked-screen APNs alerts still come from the homeserver push payload, so `senderOnly` / `hidden` privacy modes are not guaranteed once the app is backgrounded.
- Next step: decide whether iOS should switch to an `event_id_only` / local-rendered path for privacy-sensitive modes, or explicitly scope the setting as foreground/local-only until server-side push shaping exists.

### SYSTEM-001 Bandwidth control is still coarse auto-download policy, not real traffic throttling

- Severity: M
- Added: 2026-03-21
- Evidence: `lib/src/presentation/pages/settings/auto_download_settings_page.dart`, `lib/src/core/services/auto_download_policy_service.dart`, `lib/src/core/services/download_service.dart`
- Current state: the recent system/account-management pass confirmed that storage management, offline cache, appearance, notifications, and multi-account switching now have real wiring. However "bandwidth / traffic control" is still limited to media auto-download allow/deny policy by network type. There is still no explicit upload/download rate limit, background sync quota, metered-network throttle, or room/file priority scheduler.
- Next step: define whether traffic control should be policy-only or include actual throughput limiting, then add a shared network budget service that media downloads, backups, and sync jobs must consult.

### SYSTEM-002 Accessibility coverage is still partial

- Severity: M
- Added: 2026-03-21
- Evidence: `lib/src/n42_chat.dart`, `lib/src/presentation/pages/settings/account_switch_page.dart`, repository-wide search for `Semantics`, `ExcludeSemantics`, `MergeSemantics`, and `accessibleNavigation`
- Current state: font scaling is now wired through the chat presentation wrapper, which improves large-text behavior, but the broader accessibility surface is still incomplete. The recent audit did not find systematic screen-reader labels, semantics grouping, high-contrast accommodations, reduced-motion handling, or accessibility-focused regression tests across key chat/settings flows.
- Next step: define an accessibility checklist for navigation, message cells, media viewers, and settings controls, then add targeted semantics labels/tests and handle platform accessibility flags such as reduced motion and high contrast where applicable.

### SYSTEM-003 Notification customization still lacks keyword-based alerts

- Severity: M
- Added: 2026-03-21
- Evidence: `lib/src/presentation/pages/settings/notification_settings_page.dart`, `lib/src/presentation/pages/chat/chat_detail_page.dart`, `lib/src/core/notifications/firebase_push_service.dart`
- Current state: the latest pass closed room-level notification granularity by wiring `all messages / mentions only / mute` to Matrix push rules, and it added notification privacy levels for sender/body hiding. However there is still no Slack-style keyword alert list that can trigger notifications outside direct mentions.
- Next step: decide whether keyword rules should live in homeserver push rules or client-side preferences, then add a shared keyword matcher/editor and integrate it into foreground/background notification evaluation.

## Verification Gaps

### QA-003 AI smart replies and webhook automation were not live-tested end to end

- Severity: M
- Added: 2026-03-21
- Current state: the new AI smart reply suggestions, extensible bot command registry, and webhook automation paths were unit/analyze verified only. They were not exercised against the shared real homeserver or a real external webhook endpoint in this round.
- Next step: run a live smoke covering AI suggestions in chat, a custom registered slash command, and a member-join webhook delivery against a disposable endpoint.

### QA-004 Protected story-music playback was not tested end to end

- Severity: M
- Added: 2026-03-21
- Current state: story music playback for protected Matrix media now predownloads authenticated audio to a temporary local file before starting `audioplayers`, but this path was only compile/analyze reviewed in this round. There is no dedicated widget/integration test or real-homeserver smoke covering authenticated `mxc://` story music yet.
- Next step: add at least one automated test around the story music source-selection/cache path and run a real-homeserver smoke with a protected audio attachment in a story.

### QA-001 Anonymous registration and destructive account deactivation were not live-tested

- Severity: M
- Added: 2026-03-20
- Current state: these flows were intentionally not automated against the shared real homeserver during recent rounds because they create and destroy real accounts.
- Next step: add a disposable homeserver account fixture or a sandbox homeserver so these paths can be exercised safely.

### QA-002 Group-call token fetching and multi-party rendering were not live-tested

- Severity: M
- Added: 2026-03-21
- Current state: the new group-call entry flow now fetches LiveKit JWTs dynamically and the screen switched from a placeholder renderer to the real `VideoTrackRenderer`, but this path has only been compile/test verified so far, not exercised end to end against a real Matrix homeserver + LiveKit focus.
- Next step: run a real multi-device or multi-account smoke covering group voice join, group video join, screen share, and the JWT endpoint contract.

### QA-005 Multi-account switching and persisted notification settings were not live-tested end to end

- Severity: M
- Added: 2026-03-21
- Current state: the recent system/account-management pass wired saved-account switching, appearance persistence, and notification settings into the real runtime and covered them with analyze plus unit tests. However the new flows were not exercised against two real Matrix accounts/devices, so there is still no live confirmation that account switching, pusher re-registration, and restored appearance/notification preferences behave correctly across a real homeserver session change.
- Next step: run a smoke with at least two real accounts on the shared homeserver, switch between them on one device, and verify push registration, active room behavior, font/theme persistence, and DND/sound settings after restart.
