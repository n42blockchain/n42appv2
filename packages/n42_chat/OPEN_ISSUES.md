# Open Issues Ledger

This file tracks unresolved issues intentionally left open during recent agent work in `n42_chat`.

## Update Rules

- Add or update an entry whenever work ends with an unresolved bug, unsupported path, partial implementation, or meaningful verification gap.
- Update an existing entry instead of creating a duplicate when the issue is already listed.
- Remove an entry only after the fix is implemented and verified, or mark it `Resolved` with a short note if keeping history is useful.
- Keep entries concrete: current behavior, why it is still open, and the next step needed to close it.

## Active Issues

### GROUP-001 Token gates are not authoritative admission control across join paths

- Severity: H
- Added: 2026-09-14
- Updated: 2026-09-14
- Evidence: `RoomJoinService` now checks locally known gates for GroupRepositoryImpl ID/alias/invite joins and shared MatrixGroupDataSource/MatrixRoomDataSource joins. Channel discovery calls the guarded group repository. GroupBloc renders typed admission failures without a duplicate balance request.
- Current state (partial): alias resolution pins the verified room ID, duplicate pending joins share one check, session changes and changed/replaced gate state reject stale results. Known enabled gates without a verifier fail. Unknown rooms still use normal homeserver join policy; Matrix invite/preview state can be incomplete, so absence of a local gate is not evidence of unrestricted access. A local balance check or saved n42.token_gate event does not enforce private access on the server.
- Remaining observed paths: contact-invite, Moments invitation, voice-room, Space and username-registry helpers still contain their own SDK joins; these need separate protocol-specific review. Alternate clients and direct SDK use can bypass local checks. No homeserver admission contract, live balance query, external room join or fresh device acceptance was verified in this round.
- Next step: define and test authoritative homeserver admission, including pre-join state visibility and restricted private-room rules; migrate the remaining helpers with appropriate integration coverage before claiming complete token-gated access.

### SOCIAL-001 Nearby discovery is limited to location-bearing Moments

- Severity: M
- Updated: 2026-09-12
- Evidence: `lib/src/presentation/pages/discover/nearby_page.dart`, `discover_page.dart`
- Current state: a real NearbyPage now exists and derives candidates from visible Moments with coordinates, after location permission. The previous claim that no discovery page exists was stale. This is not a dedicated proximity-presence protocol or complete people-discovery service.
- Next step: verify consent/visibility/expiry in a controlled multi-user scenario and define any broader discovery backend separately.

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

### OFFICE-001 Collaborative tasks and calendar synchronization remain incomplete

- Severity: M
- Updated: 2026-09-12
- Evidence: `lib/src/core/services/reminder_service.dart`, `chat_page_message_actions.dart`, `favorite_list_page.dart`
- Current state: personal reminders exist, persist as FavoriteEntity values, and are reached from the message menu/favorites. The previous "no todo model" claim was stale. The periodic notifier only runs while the app process is alive; there is no assignee workflow or shared calendar sync.
- Next step: verify notifications after process termination and define collaborative assignment/calendar semantics before claiming full task collaboration.

### OFFICE-002 Whiteboard collaboration needs multi-client acceptance; spreadsheets are absent

- Severity: M
- Updated: 2026-09-12
- Evidence: `lib/src/presentation/pages/chat/whiteboard_page.dart`, `lib/src/presentation/widgets/chat/whiteboard/whiteboard_controller.dart`
- Current state: drawing/export and Matrix stroke/clear exchange exist with a chat entry. The previous "no renderer" claim was stale. Concurrent drawing, offline recovery and room permissions have not been accepted on multiple real clients; there is no spreadsheet editor.
- Next step: validate multi-client convergence and persistence, then scope spreadsheet collaboration independently.

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

### MEDIA-002 Encrypted-room file uploads require bounded in-memory encryption

- Severity: H
- Added: 2026-03-20
- Evidence: `lib/src/presentation/pages/chat/chat_page_media_actions.dart`, `lib/src/data/datasources/matrix/message/matrix_media_sender.dart`
- Current state: the September 18 repair converts picker paths/streams to SDK-encrypted attachments with a 50 MB bound (AppConstants.maxFileSize), including a streaming byte count that does not trust declared size. Larger attachments fail closed rather than uploading plaintext. Large-file support therefore does not meet the `>2GB` requirement for encrypted rooms.
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

### IDHUB-001 Positive ID Hub chat login is blocked on Matrix provisioning

- Severity: H
- Added: 2026-07-14
- Evidence: `lib/src/presentation/blocs/auth/auth_bloc.dart`, `lib/src/data/datasources/remote/id_hub_api.dart`, unified-identity device QA against the deployed development Hub
- Current state: the deployed Hub reports Matrix provisioning disabled, so positive Hub-to-Matrix login cannot yet establish a chat session. The hardened client now permits legacy fallback only when Hub challenge creation fails before signing. Cancellation or any failure after a Hub challenge is signed stops with one clear error and never asks for a second signature. The Hub server code also rejects Chat challenge creation with `matrix-unavailable` before signing when provisioning is disabled.
- Next step: configure the production Hub with the Synapse shared-registration secret and Matrix password secret, deploy it, then run the positive Hub-to-Matrix login on a real device.

## Verification Gaps

### QA-009 TestFlight registration, friendship and historical-key acceptance

- September 19 UX update: search now previews a user's profile rather than creating/opening a pending room. Profiles expose incoming requests, disable repeated outgoing requests and offer relationship-load retry when opened without a contacts provider. Requests are grouped by direction; accepted/rejected entries are removed immediately while refresh completes. Chat filters include muted unread messages; attachment grids scroll at large text sizes; failed-message retry has a larger touch target; undecryptable messages explain that this device cannot read the message and offer recovery options without claiming recoverability. The call return banner shares the existing call lifecycle. Synthetic/widget checks do not establish friend acceptance, restored keys or calls on the feedback phones.

- September 18 / build 2026072690 / Downloads/2.mov: the recording uses explicit logout to alternate dxx/dxx01 on one iPhone. A matching live SDK test reproduced the asymmetry: a sender retains its own key, but a recipient who was logged out before sending starts a new device without that key. The previous concurrent-device logout test did not cover this sequence. This explicit-logout acceptance remains OPEN; do not describe account switching as fixing every logout/re-login case or weaken E2EE/forward another account's history keys to hide it.
- Account-switch repair: independent SDK databases are indexed by server/user/device; the existing database is registered in place. Switching restores the entire saved device identity and sync cursor rather than calling init(newToken) on another account's database. Password/SSO login gets a fresh isolated database; failed login reopens the previous session. Fresh token bootstrap checks its owner and refuses to replace an already published device identity without its private keys. Homeserver probes while adding an account are tokenless and do not mutate the active client. Settings and the logout confirmation offer a localized Switch Account entry; explicit Logout still revokes its device.
- Live acceptance: real MatrixClientManager/AuthDataSource with native crypto/SQLite passed sequential A→B/B→A encrypted sends, unchanged device IDs/fingerprints, process-style client restart, failed-password rollback and logout isolation. Both disposable accounts were deactivated (the intentionally logged-out account required cleanup reauthentication). This uses mocked secure storage/preferences and does not prove iPhone/Android persistence. `test/live/account_switch_encryption_test.dart` is opt-in with disposable QA state; native feedback-phone acceptance remains required.

- September 18 / build 2026072687 feedback: both feedback phones run this version; encrypted placeholders affect new and old messages. Current repairs guard overlapping registration submissions; filter live directories from ordinary groups; invoke the localized group-count function; preserve the selected group name/avatar/count when navigating; include avatar state and both invitees in room creation; count known joined/invited members; read persisted star/tag annotations in contacts; derive tag counts from actual assignments; and isolate tag catalogs by server/account. Video feed items now resolve authenticated media to disposable local files, show retry on failure, and open profiles from authenticated avatars/names. These are code repairs, not confirmation on the feedback phones.
- Validation: 153 focused tests plus a tag-count widget regression pass. The live SDK run also delivered an encrypted production contact card and verified a three-member group's avatar/join/invite state. All three temporary accounts were deactivated. These tests do not constitute native feedback-phone acceptance.
- Encryption follow-up: local session restoration now emits session-key notifications so already-loaded timelines retry decryption. Encrypted send preparation coalesces concurrent work and retries a transient incomplete device/Olm refresh once, preserving device trust checks and never sending plaintext. Contact recommendation renders the localized readiness error. A synthetic live SDK test already passed bidirectional encrypted delivery and logout/login without a recovery key; it uses real server/crypto/SQLite but mocked secure storage, so native Keychain/Android persistence and dxx/dxx01 acceptance remain open. Keys previously lost without any copy cannot be reconstructed.

- September 18 contact appearance: Downloads/9.jpeg is explicitly a reference image, not a current-build screenshot. The index now keeps search/star/A–Z/# visible at the right regardless of populated groups, with bounded centered height; the chat-only/group entry gap becomes the standard divider. Existing 14 contact navigation cases pass; device visual acceptance of this small layout change is pending.

- Severity: H
- Evidence: user confirmed build 2026072683 loses readable messages after logout/login without a recovery key; Downloads/1.mov shows this on both accounts. Caller posted duplicate call summaries, receiver posted another. Picker file paths were explicitly rejected in encrypted rooms. Current-location lookup only formatted coordinates, and send composition discarded the address.
- Client repair: preserve account/homeserver-scoped inbound history sessions in device secure storage before normal logout/logoutAll; restore missing sessions after authenticated login. Retain replay indexes and stop logout if snapshot verification fails. No passwords, access tokens, outbound ratchets or Olm identity are retained. Account deactivation deletes its snapshot. Earlier lost keys and device replacement still require a user-held backup; forced session invalidation is outside this explicit-logout hook.
- Call repair: caller-only shared summary with a stable per-call transaction ID, frozen duration, local deduplication, and no local pending signaling bubble. Remote hangup/reject invalidates pending startup. Both peers need the repair; older clients can still publish their own record.
- Media/location repair: encrypted picker paths and streams feed the SDK attachment encryption path, with no plaintext retry on failure. GPS and map-center selection resolve an address; message composition retains it and location cards allow two text lines. Offline/unavailable geocoding falls back to coordinates. Chat-only contact rows open the friend's profile and refresh permissions on return.
- Verification: native Megolm ciphertext survives mocked logout database clearing and authenticated login restoration; secure-storage platform is mocked. Tests cover failed snapshot storage preserving login, voice/video duplicate termination, late TURN completion, profile navigation/refresh, encrypted file path/stream routing, upload failure without plaintext fallback, and geocoder address/fallback. Physical keychain persistence, live bilateral file download/decryption, GPS address availability and two-device call acceptance remain unverified.
- User confirmation: the okle contact-refresh failure was from build 2026072679; the user now confirms contacts display normally. No further reproduction is claimed for that old build.
- Next step: upgrade both test phones and verify new-message logout/login without manual recovery, file transfer/opening, GPS/map address, one caller summary for either initiator, and chat-only profile navigation. Do not infer native acceptance from automated tests or release upload.

- September 18 contact-tab follow-up: the user reports contact refresh failure; the user subsequently identified account okle on build 2026072679 and confirmed contacts now display normally. Reproduced a concrete failure for stale m.direct mappings where the peer member event returns M_NOT_FOUND: the empty list was classified as unavailable membership. Handle that response as a non-joined peer, preserving send approval checks, existing mappings/history and real network/auth/rate-limit failures. Added SDK Room coverage and both lookup-stage cases; 134 contact tests plus the additional real-Room case passed. The contact-tab symptom is user-confirmed as no longer present; its exact server error was not captured.

- September 18 registration follow-up: build 2026072679 still rejected the SDK 6.2.0 UIA challenge because the registration handler required `MatrixException.response.statusCode`; generated SDK endpoints use `MatrixException.fromJson` with no response. Fixed the handler to use decoded UIA data, preserving session, supported-stage checks and bounded retries. A real SDK transport regression fails before the fix and passes after it. A disposable-account live smoke using the production datasource and SDK HTTP registration completed dummy UIA, password login and deactivation on `https://m.si46.world`. 96 focused auth tests passed. This verifies the registration protocol, not native UI/session initialization: install the replacement iOS/Android builds and repeat registration on both reported phones. Keep the remaining friendship/key/device acceptance items open.

- September 17 confirmed root cause: both feedback clients run 2026072674. A targeted server query found that account A still ignored account B; the newly created direct room contained only its creator, with no recipient membership event. Tuwunel 1.8.2 silently skips blocked invitees during successful createRoom. The settings and legacy profile pages incorrectly inferred block status from the accepted-contacts list, so a blocked/non-contact peer displayed the switch as off. After explicit user authorization, removed only the reported ignore-list entry through the Matrix account-data API, verified readback, revoked the temporary maintenance session and restored server configuration; no rooms/messages or other ignore entries changed.
- Client follow-up: block controls read the account's real ignore list and await successful persistence; direct creation rejects locally blocked users and verifies that a recipient invite/join event exists before reporting success. Empty historical rooms do not prevent a fresh invitation. A real SDK 6.2.0 test also reproduced stale `invite` membership after the server had changed it to `join`; resolving pending peers now requests current room state. The same live test passes invitation delivery, acceptance, bilateral contact discovery and send-admission checks after the repair. Test accounts were deactivated; no actual encrypted message or media-call exchange was asserted by this test. Feedback-device acceptance on the next build remains open.
- TURN follow-up: the user replaced HTTP forwarding on the public gateway. External TLS and authenticated TURN allocation now pass, advertising the gateway's public relay address, but a permitted external UDP peer cannot reach the allocated relay port. Backend INPUT is ACCEPT and default internet return traffic uses its own public interface. Gateway SSH still rejects the supplied key, so forwarding/firewall/return-path inspection remains blocked pending gateway access. Do not claim media relay or cross-platform calls passed.

- September 17 follow-up: the user reports the same friend-add failure after release 2026072674; the two devices' installed versions and current request direction are still awaiting confirmation. Found and removed an additional client dependency: incoming invitations waited for every joined-room membership refresh and then sequential profile lookups. Requests now use available stripped invitation state and publish before contact hydration finishes. Deterministic stalled-query tests verify this path; this does not establish the cause or resolution on dxx/dxx01. Keep QA-009 open until both updated clients show the request, accept it, and exchange messages. The scanner now has a localized Album action with image QR analysis, cancellation/error recovery and duplicate-action guards. Native gallery selection/decoding on the feedback Android/iPhone remains unverified; use a dedicated installation for device tests and preserve app data.

- Current server/device status (2026-09-16): `ubuntu` SSH and sudo now work on the supplied backend. Backed up the active Tuwunel 1.8.2 configuration, enabled ordinary username/password registration and applied SIGUSR1 without restarting the process. Public registration changed from 403 disabled to a dummy UIA challenge; two temporary accounts registered successfully, password login passed, and real `/sync` invitation delivery, bilateral acceptance with m.direct, and reverse-direction rejection passed. Both test accounts were deactivated after leaving/forgetting test rooms; no dxx/dxx01 credentials or data were used. The full Android app development build 2026072672 was reinstalled and launched after the user allowed installation. Previously cleared local application data was not recovered.
- Confirmed call blocker: the advertised `turns:turn.si46.world:443?transport=tcp` accepts valid TLS but answers TURN Allocate with HTTP 400. Backend coturn answers a normal local 401 challenge and its shared secret matches the homeserver; external direct backend 3478 TCP/UDP probes time out, while frontend 3478/5349 refuses TCP. Frontend SSH with ubuntu and the current key is rejected; correct gateway access has been requested. Do not claim live calls passed or substitute an unverified endpoint. Next: inspect the gateway transport proxy and relay-port mapping, verify authenticated allocation/media relay, then repeat cross-platform device acceptance. See `docs/MATRIX_SERVER_VALIDATION_2026-09-16.md`.


- Severity: H
- Added: 2026-09-15
- Evidence: `docs/TESTFLIGHT_FEEDBACK_2026-09-15.md`; user screenshots of registration, pending friendship, encrypted history, a file action surviving onto the wallet home, and Settings. The user explicitly confirmed logout and login, not just reopening a room.
- Client repair: registration no longer pre-submits a bundled token; supported token/dummy UIA stages retain their session and real errors. Contacts and message sends require explicit mutual joined membership, including missing-member-state handling. Chat owns its ScaffoldMessenger. Settings profile has a default authenticated route; Chat already had a default route. Room timelines and mapped-message caches are separated by client/user/device/homeserver; stale asynchronous creations cannot revive disposed timelines. Backup setup now creates an actual server backup through the SDK bootstrap, preserves existing secrets, verifies restored sessions, and exposes recovery from encrypted messages. Logout offers key backup with a translated data-loss explanation.
- Live evidence: read-only checks on the screenshot homeserver returned available usernames and HTTP 403 `M_FORBIDDEN: Server does not allow token registration` for the old bundled token's validity endpoint. This supports removal of unsolicited token authentication; no actual registration or user-account login was performed.
- Follow-up (2026-09-15): after the TestFlight upload, the user reports `M_FORBIDDEN: Registration has been disabled`. Read-only discovery still advertises password/token/application-service login, while a deliberately invalid registration-token probe returns `Server does not allow token registration`. Username availability and the earlier token response did not establish that public registration was enabled. Normal and anonymous registration call Matrix directly, not ID Hub; disabling unified login cannot reopen Matrix registration. The client now distinguishes this rejection from other forbidden responses and displays an administrator-action message in 26 locales, with normal/anonymous repository cases and English/Simplified/Traditional Chinese widget coverage. Production server access/configuration and successful registration remain outstanding; no registration request, real password or account was used in these probes.
- Recovery follow-up (2026-09-15): the user reports a successful recovery notice while messages remain encrypted and the Security page says no backup is configured. Confirmed client defects: zero restored sessions still displayed success, backup discovery depended on the local SSSS secret instead of server metadata, a device-list failure discarded independently loaded backup metadata, and the page imported the backup twice. The follow-up returns and displays the verified session count, reports an empty backup explicitly in 26 locales, reads fresh backup metadata, preserves metadata across device-list failures and imports once. Verified restored sessions also notify existing Matrix timelines to retry decryption, including the SDK's already-known-session path. Actual SDK Timeline coverage verifies the matching event is reprocessed while an event lacking a backed-up session stays encrypted; cryptographic decryption is mocked, so this is not proof of recovering the user's messages. Page tests cover both recovery modes, empty/nonempty results, failure and metadata retention; they also exposed and fixed premature dialog-controller disposal and ListTile material ownership.
- Account-permissions clarification (2026-09-15): the requested settings apply to the current account, not a selected friend. Required global Chat controls are verification/open/closed friend requests, discoverability and blocklist management. These controls are absent in the current wallet; the preceding per-contact navigation answer did not address them. The local Mintus reference enforces its equivalent settings through a separate authenticated backend, which wallet Matrix Chat does not use. Client preferences alone cannot enforce closed invitations, offline auto-acceptance or directory suppression. See `docs/ACCOUNT_FRIEND_PERMISSIONS_2026-09-15.md` for the source inspection, exact requirements and dual-platform acceptance. Implementation is pending identification/access to the deployed enforcement service; SSH as root to the supplied Matrix host still fails public-key authentication. No policy changes or unsupported client toggles have been shipped.
- Face ID and contact-details follow-up (2026-09-15): a direct conversation created from Contacts omitted `directUserId`; Chat details then substituted the room ID, matching the reported `!…` N42 ID and incorrect Add to Contacts action. The client now carries the peer ID, resolves older conversations from Matrix room metadata and refuses room-ID profile navigation. Known contacts remain friends through transient Bloc statuses; deletion restores the add action. Face ID used only remembered account fields to advertise login even after logout revoked/cleared the required session. The page now requires a saved session, and the Bloc checks it before prompting. Privacy & Security has an explicit Biometric Login route; the Security section remains visible when discovery fails, explains device enrollment/permission checks in 26 locales, and refreshes after returning from OS settings. Enrollment uses the current saved session rather than requiring remembered credentials; saves are serialized and failures are visible. These client fixes do not add passwordless server authentication after explicit logout. The user's precise failed Face ID path (logout versus reopening the app versus no system prompt) remains unconfirmed; real iOS Face ID/Android biometric acceptance is still required. See `docs/FACE_ID_CONTACT_FEEDBACK_2026-09-15.md`.
- Friend-info follow-up (2026-09-16): reviewed the supplied 45-second recording. Remark editing now contains only the remark field. Phone, selected tags and notes save and reload in the friend-info page. Photos open the gallery and persist as private device-local annotations, with thumbnails, preview and deletion in that page. Storage is isolated by homeserver/account/friend, and stale-session writes are rejected. Widget coverage exercises editing/reopening/cancellation, tag selection/removal, gallery persistence/preview/deletion and account changes. Native photo-library permission and picker behavior still require iOS/Android device acceptance; these new fixes are not in previously uploaded TestFlight build 2026072666. Tag catalogue membership counts and cross-device annotation sync are not implemented by this local annotation change.
- Privacy/encryption/call follow-up (2026-09-16): implemented account-scoped friend policies enforced through social-room membership, independent status rooms, feed refresh/removal, contact-to-profile navigation, and profile voice/video call actions. New encrypted sends refresh/validate devices and await key delivery; failures stop publication and preserve text for retry. Native key tests cover next-message decryption but do not prove every old failure's origin. Video 8 exposed missing CallKit end dispatch, incompatible native map casts, missing return navigation and ICE/session setup races; these client paths are fixed and regression-tested. Existing unscoped permission preferences must be resaved after upgrading. Previously downloaded content cannot be revoked. See `docs/FRIEND_PRIVACY_ENCRYPTION_CALLS_2026-09-16.md`. Server SSH still fails authentication. Live two-account iOS/Android delivery and audio/video connection, native background/lockscreen behavior, and deployment TURN checks remain unverified; build 2026072667 does not contain these repairs.
- Remaining verification: run registration with the server's enabled flow; send/accept/reject requests between two dedicated accounts; create a backup and retain its recovery key, send encrypted messages, log out/in, restore keys, and verify historical plus new messages on iOS and Android. Check encrypted attachments and the restore dialog on devices. Unit/widget tests do not establish recovery of the user's lost keys.
- Limit: messages whose only keys were cleared by a prior logout and were never backed up cannot be reconstructed by a client display/cache fix. Recovery still requires a valid user-controlled backup/key or a device holding those sessions. Unsupported captcha/email UIA stages remain explicit additional-verification failures.
- Next step: TestFlight `2.4.8+2026072656` was uploaded from the preceding client repairs. Obtain the Matrix deployment target, inspect its effective registration policy and restore the intended registration flow before repeating the above device acceptance. The new explanatory message does not change server policy and is not yet in that uploaded build.


- Device operation follow-up: the connected Android passed the real-camera start/pause/resume smoke test. However, the host Flutter integration command omitted `--no-uninstall`; the tool defaults to uninstalling at teardown and calls `adb uninstall` without data preservation. The test installation and its local application data were removed without a preceding backup. The full-app debug build is ready, but both restore installs were blocked with `INSTALL_FAILED_USER_RESTRICTED`. The user was informed of this mistake and subsequently allowed installation; the full application has now been reinstalled and launched, but the previous local data was not recovered. Further device tests must use a dedicated installation and explicitly disable automatic uninstall when retaining data. See the wallet report `docs/testing/screenshot-regression-2026-09-16/README.md`.

- September 16 camera/request follow-up: the user confirmed screenshots came from build 2026072670 or earlier, so they do not establish failure of 2671. Fixed permission-dialog resume loops and controller replacement in ScanQRPage; passive checks retain usable controls and camera lifecycle operations are serialized. Contact and request loading now preserve independent results; invitations remain reachable during contact failures. Accepted direct-room mapping is immediately retained after server acknowledgment, and missing invitations fail explicitly. Supplementary regression: 96 tests passed, including four camera widget cases and real SDK Room invite/acceptance state transitions with mocked transport. Native permission behavior on the reported Android and live bilateral acceptance are still unverified. The newly supplied SSH public key matches this computer, but root on port 22 rejects it; actual login username/port or authorization correction is outstanding. Production registration has not been changed. See `docs/REGRESSION_SCREENSHOTS_2026-09-16.md`.

- September 16 follow-up (video 9 and tag picker): joined direct rooms now resolve authoritative peer membership with profile fallback disabled before building contacts or sending. An abandoned direct room no longer absorbs a new QR invitation; outgoing invitations are visible as awaiting acceptance. Friend-request actions await the repository result, and failed loading can retry. No rooms, contact account data or history are deleted. The tag picker exposes creation in selection mode, selects the new tag, persists on confirmation and reuses an existing normalized name. Tag catalog contact counts remain legacy catalog data; this change does not reconstruct those counts.
- Verification update: focused contact/profile/tag regression passed 137 cases; both attached Android and iPhone passed native Megolm and WebRTC cancellation smoke scenarios with fixture signaling. The user confirmed the reported phones are different devices. Live dxx/dxx01 contact restoration, bilateral QR acceptance and cross-platform calling remain unverified; retain this issue pending acceptance on those updated clients.

- September 16 profile/media follow-up: the main friend profile now reads private annotations and refreshes them after the editor returns; saved photos have count, thumbnails and zoom preview. Photo management has its own page with multi-selection and atomic metadata save/cleanup on partial import failure. Discover Video Channels now opens the video feed with Publish Video and Go Live actions, not the public Matrix room directory. Video posts use existing Moment visibility/privacy; broadcasting requires the host's existing live stack. Internal live-directory records are excluded from generic channel discovery. Focused profile/discovery regression: 33 passed. Live uploads/broadcasting and native multiple-selection acceptance remain to be checked on updated devices; no test broadcast was published.

- September 16 daily audit: fixed dropped composer audience IDs; new restricted posts now use separate invite-only rooms whose recipients are accepted direct friends, with owner-only invitations and fixed per-post audiences. Own-profile reads and deletion use the actual post rooms. Automatic social-room joining now verifies an accepted direct friendship instead of trusting an invitation label. Superseded video requests, disposed picker results, stale account annotation loads and partial photo files are handled. See `docs/DAILY_CHAT_AUDIT_2026-09-16.md`. Focused regression: 75 passed. Production room enforcement and old-client compatibility remain unverified. Existing restricted posts in shared rooms are not migrated, and previously downloaded events/files cannot be recalled. Failed restricted-room setup can leave an empty private room. TestFlight/APK 2026072670 predates these audit fixes; a later build is required for acceptance.

- Screenshot regression follow-up (1.png, 2.png, 3.png; September 16): the 25 rows contain six explicit passes, twelve blocked by unavailable contacts/failed friend creation, six other pending repairs and one unspecified result. Build under test remains unconfirmed. Fixed confirmed client gaps: concurrent duplicate direct creation and delayed m.direct cache recognition, per-room member-refresh isolation, contact watcher recovery and cached-list visibility, independent incoming invitations, Moment author/profile navigation, actual friend-specific video entry, contact state propagation into social composers, reverse-geocoded post locations, sending-indicator position and suppression of already-redacted posts during stale refresh. No existing room/history/direct mapping was deleted. Focused regression: 131 passed, including an actual SDK Room for delayed direct mapping; server calls remain mocked. See `docs/REGRESSION_SCREENSHOTS_2026-09-16.md` for all 25 rows. Build 2026072671 predates these follow-ups. Actual dxx/dxx01 recovery/calls and production registration/TURN remain unverified; SSH login target is still needed to inspect the supplied compose directory.

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

- September 19 UX update: the chat header exposes the active identity and account selector. The chooser serializes switching/add-account actions, blocks UI switching during a call, and retains a retry/re-authentication explanation after failure. Chat and profile roots are keyed by account identity to discard the preceding account's page state. Narrow-screen, 130% text and light/dark widget checks pass. Native push registration, OS process restart and the feedback phones remain unverified; the earlier synthetic SDK acceptance in QA-009 is not native UI acceptance.

- Severity: M
- Added: 2026-03-21
- Current state: the recent system/account-management pass wired saved-account switching, appearance persistence, and notification settings into the real runtime and covered them with analyze plus unit tests. However the new flows were not exercised against two real Matrix accounts/devices, so there is still no live confirmation that account switching, pusher re-registration, and restored appearance/notification preferences behave correctly across a real homeserver session change.
- Next step: run a smoke with at least two real accounts on the shared homeserver, switch between them on one device, and verify push registration, active room behavior, font/theme persistence, and DND/sound settings after restart.

### AUTO-002 AI group membership and responding bot are absent

- Severity: H
- Added: 2026-09-12
- Evidence: `lib/src/presentation/pages/group/bot_settings_page.dart`, `lib/src/core/services/bot_command_processor.dart`, `lib/src/n42_chat_config.dart`
- Current state: private AI routes exist and are repaired in M2. Group bot settings only configure welcome/webhook automation. There is no AI Matrix bot identity, invitation-specific configuration, response worker or group-context policy in this checkout. The local device build also lacks an AI provider key/model configuration.
- Next step: provide/deploy a responding bot service, specify bot identity and group disclosure/context rules, then wire invitation/member state and verify mention/response/removal in an isolated test room. Ordinary member invitation is not evidence of AI responses.

### MEDIA-005 Sticker pack sharing and importing are still stubs

- Severity: M
- Added: 2026-09-12
- Evidence: `lib/src/data/repositories/sticker_repository_impl.dart` importPack/getPackShareUrl
- Current state: installed/custom packs, upload, search and sending exist; these two cross-user sharing methods still return null. There is no verified share-manifest or import preview path. Do not claim a full sticker sharing ecosystem.
- Next step: define persistent pack distribution, resource validation and receiver preview/install, then wire and test both sender and receiver.

### INTEGRATION-002 Standalone Settings composition — Resolved

- Severity: M
- Added / resolved: 2026-09-12
- Evidence: `docs/SETTINGS_AUDIT_2026-09-12.md`, `settings_navigation_test.dart`, `settings_persistence_test.dart`
- Resolution: direct routes and Profile now share default notification/appearance/chat/language/password/email/logout composition. The 2026-09-15 follow-up adds a default authenticated profile-edit route when an embedded Settings card has no host callback, covered by a real widget navigation test. Existing host overrides retain precedence; account hub navigation preserves the active AuthBloc. Notification and appearance saves are awaited, persisted by default, and rolled back on rejection. The Chat category exposes background, quick replies, translation and auto-download.
- Verification: real widget routes cover direct settings, privacy/account hubs, multi-hop auth propagation, save/reopen, failures, slider commits, logout confirmation, and Arabic narrow-screen layout. Live account mutation is still outside this verification (QA-005).

### QA-006 Direct UI literals still need module-by-module translation review

- September 19 UX update: new interaction labels are translated in English, Simplified/Traditional Chinese, German, French, Spanish, Italian, Portuguese and Brazilian Portuguese. The remaining catalogs explicitly use English fallback for these new labels, keeping key parity; linguistic review/translation for those locales remains open.

- Severity: M
- Added: 2026-09-12
- Evidence: `docs/UI_LOCALIZATION_REVIEW_2026-09-12.md`, `tool/audit_ui_localization.py`
- Current state: all 26 ARB catalogs have matching English keys and no blank values. This does not cover direct UI literals: the conservative scanner initially found 539 candidates in 33 presentation directories, including on-device AI, points and system settings. Brands/examples are not necessarily defects. M1/M3/M4 localized the changed expression/actions labels. The settings follow-up localized six messages in all catalogs and reused the backup label; 533 direct literal candidates remain. Nested account/privacy hubs and notification-filter content still require translation; the complete backlog is not fixed.
- Next step: review and translate candidates by module, regenerate catalogs, then verify RTL and expanded text with real UI tests. Do not treat key parity as full translation coverage.

### QA-007 iPhone data continuity after test-runner cleanup is unverified

- Severity: H
- Added: 2026-09-12
- Evidence: host `docs/chat-audit-2026-09-12/DEVICE_RETRY_2026-09-12.md`; successful Flutter drive verbose log explicitly records app uninstall.
- Current state: iPhone fixture UI tests passed, but Flutter drive's default cleanup removed the host app. The normal app was reinstalled; the missing initialization preference was restored and read back to avoid additional first-install keychain cleanup. This does not recover removed app-container files or prove wallet/Chat data continuity. The agent did not read or export private keys or mnemonics. Host automation now uses `--keep-app-running`, with regression coverage for both drive paths. The user's subsequently established Android Chat session was preserved during the retry.
- User update: Chat login on iPhone is now confirmed, as on Android. Current login availability does not establish preservation of previous chat history or wallet data.
- Next step: verify wallet and historical Chat data in the normal iPhone app with the user; any recovery must use user-controlled backups. Do not mark this resolved based only on renewed login, install success or fixture test results.

### STORAGE-001 Favorite deletion spans two preference keys — Resolved

- September 18 account-isolation repair: build 2026072687 feedback exposed a separate ownership defect in the global record/cache. Favorites, metadata, in-flight reads and serialized writes now use a normalized homeserver/user scope. Old global records remain untouched and are deliberately not assigned to any current user because their owner cannot be established. Regression cases cover account/server changes, restart, failed writes and switching accounts during pending reads. This supersedes the previous automatic legacy migration described below; the historical atomic-deletion fix remains valid within each scope. Native account-switch acceptance remains to be performed.

- Severity: M
- Added: 2026-09-13; local fix: 2026-09-14
- Evidence: `MessageActionRepositoryImpl`, `favorite_record_persistence_test.dart`, `message_action_persistence_test.dart`
- Current state: the canonical audit worktree now saves messages and tag/remark metadata together in one versioned preference record. Legacy data is read without writes, migrated on the first successful mutation, and retained without being used after the new record exists. Invalid records surface an error before mutation. Caches publish only after the complete write succeeds; concurrent initial readers share one load and repository mutations remain serialized. The actual FavoriteBloc retains a failed deletion and clears the error after a successful retry.
- Verification: 18 new regression cases cover the former partial deletion, corrupt legacy metadata, rejected/thrown writes before and after migration, simulated preference-cache restart, invalid/unknown record versions, non-resurrection of legacy data, the actual Bloc failure/retry path, and concurrent initial loading. Two cases reproduce failures against the original repository implementation. These tests use a fake platform store; physical process termination/power-loss durability and cross-isolate locking are not established. SharedPreferences is still the underlying storage.
- Integration: wallet commit `8ecdb286` pins Chat `ebaa003b3dd882be9f951cb73c88633fa618f76c` and synchronizes the lib/assets mirror. The normal wallet Chat/quality suite passes 457 checks, including 104 newly wired favorites/email regressions. This resolves the two-key deletion defect in the wallet dependency. Retained legacy keys remain migration input, not a downgrade synchronization mechanism; UI-001 remains separate.

### UI-001 Legacy favorite tag and remark methods have no visible read/edit path

- Severity: M
- Added: 2026-09-13
- Evidence: `MessageActionRepositoryImpl.editFavoriteTags/editFavoriteRemark`, `FavoriteBloc`, `FavoriteListPage`
- Current state: tag/remark edits persist and their failure/retry behavior is covered, but `getSavedMessages` returns MessageEntity without this metadata and FavoriteListPage has no tag/remark editor. These backend methods are not evidence of a usable tagged-favorites feature. The newer FavoriteEntity/reminder storage is a separate path and must not be confused with this repository.
- Next step: consolidate the two favorites models, expose persisted metadata through the domain contract, and cover create/edit/search/reopen from the actual profile entry.

### AUTH-001 Email verification contract — Client repair integrated; live acceptance and multi-email handling remain open

- Severity: H
- Added: 2026-09-13; local client repair: 2026-09-14
- Evidence: `EmailChangeService`, `AuthRepositoryImpl`, `ChangeEmailPage`, `email_change_service_test.dart`, `email_change_repository_regression_test.dart`, `change_email_verification_test.dart`
- Current state: a versioned secure-storage record binds the email verification secret/session ID to user, homeserver, device and normalized address. Requests only publish a complete response; resends reuse the secret and increment sendAttempt. Confirmation checks account/address/expiry and guards asynchronous account changes. Legacy unbound split records cannot be confirmed. With submit_url, the exact entered token is posted without Matrix credentials to a validated HTTPS URL and requires a successful verification response before add3PID. Without submit_url, the page instructs the user to open the email link and submits no code. Password-only UIA challenges use the password supplied with the confirmation event and the server session; passwords are not retained by the service or persisted. Unsupported UIA stages still fail. The page resolves localized error keys, prevents duplicate submissions and constrains the resend button on small screens.
- Verification: 55 new cases cover the service (45), real repository regressions (2), real Bloc verification-mode propagation (1), and page behavior/layout (7). Two regressions fail against the original repository implementation. Three 320px/1.6-scale screenshots in English, Chinese and Arabic were rendered with a system font and inspected; 26 locale resources include the new verification text. Tests use fake Matrix/HTTP/storage boundaries, without sending email or touching a real account.
- Retry repair (2026-09-14): after a successful token response, confirmation persists a boolean validation checkpoint in the same account-bound session before attempting add3PID. A binding/UIA failure can then retry without resubmitting a consumed token, including when the service is reconstructed from storage. New requests reset the checkpoint even if the server reuses sid; old version 1 records without the field still require validation. This does not bypass server binding authorization. Seventeen additional service regressions pass, including two failures reproduced against the preceding local candidate; the combined targeted suite passes 289 cases.
- Remaining behavior: this endpoint adds a verified address; it does not atomically replace old recovery emails. `getBoundEmail` still selects the first server-provided email when multiple addresses exist. If local cleanup fails after server binding, the operation correctly reports server success but the protected session record can remain until replaced or expired. Real email delivery, homeserver token/link behavior, SSO/multi-stage UIA, expiry and multiple-email recovery semantics remain unverified.
- Registration gap (updated 2026-09-17): registration no longer displays the unused email field or claims it can recover passwords, and the unrelated invitation-token control is no longer exposed for the server's open `m.login.dummy` flow. Email registration remains deferred until production SMTP and a complete verified Matrix UIA flow are available; the lower-level registration-token implementation remains for servers that explicitly request that stage.
- Retry limits: a failed checkpoint write stops before binding and retains the previous record; if the server has already consumed the token, a fresh verification request may be needed. Lost token/add3PID responses are not reconciled with authoritative server state. The checkpoint is not a transaction spanning the server and secure storage. Reconstructing the service is covered; reopening the page still starts its normal request flow rather than automatically restoring a verification form.
- Retry candidate validation: the complete plugin suite passes 6,411 tests with one credential-dependent test skipped; static analysis reports zero errors/warnings and 173 existing infos. A temporary wallet package configuration selecting the canonical candidate passes 498 Chat/quality checks. Evidence is archived in the wallet audit index under `EMAIL_RETRY_2026-09-14.md`; live-account acceptance remains open; subsequent wallet integration is recorded below.
- Wallet integration (2026-09-14): wallet commit `8ecdb286` pins `ebaa003b3dd882be9f951cb73c88633fa618f76c`; pub get changes only n42_chat, and all 769 lib/assets files match the resolved Git source, mirror and source manifest. The normal wallet Chat/quality suite passes 457 checks without a temporary package configuration; static analysis reports zero errors/warnings and 155 existing infos. This suite wires 104 favorites/email repository/service cases; the earlier 498-case candidate run additionally included page/AuthBloc cases. Evidence: wallet `docs/chat-audit-2026-09-12/WALLET_INTEGRATION_2026-09-14.md`. No new device or live-account validation was performed.
- Next step: validate against an isolated account; implement an explicit multi-email management/primary-address policy before claiming complete email replacement. Do not remove recovery addresses implicitly; SSO/multi-stage UIA and lost-response reconciliation remain open.

### QA-008 Xiaomi overwrite installation — Resolved

- Severity: M
- Added: 2026-09-13
- Resolution: after the user enabled USB installation, explicit overwrite installation succeeded on 2026-09-13. No uninstall or data clearing was used. This resolves installation permission only; acceptance exposed the SQLite loader issue below.

### STORAGE-002 Android media database background isolate lacks SQLCipher loader — Resolved

- Severity: H
- Added: 2026-09-13
- Evidence: physical Xiaomi fixture failed resolving `libsqlite3.so`; the APK ships `libsqlcipher.so`. `MediaMetadataDatabase._openConnection` used `NativeDatabase.createInBackground` without configuring its isolate's library loader; the archive main-isolate override cannot propagate to it.
- Resolution: `657a66b` adds Android library preparation and a per-isolate SQLCipher override. A production-path regression writes, closes, reopens and cleans media metadata under an isolated temporary documents directory. All 15 local storage contracts and 49 related service/bloc cases pass. The expanded 19-case suite passed on both physical Xiaomi and iPhone devices. Both normal apps were overwrite-restored; Android Chat opens into the existing logged-in conversation list. No uninstall, account creation or real message/payment was performed. Evidence: host `docs/chat-audit-2026-09-12/DEVICE_ACCEPTANCE_2026-09-13.md` and its two result manifests.

## Resolved in the 2026-09-12 audit

### CONTACT-001 Search misses visible remarks and first blacklist read omits remarks — Resolved 2026-09-14

- Severity: M
- Evidence: three contact regressions fail on the previous implementation: remark lookup, whitespace around a name, and remarks on the first ignored-contact read. Two conversation queries also fail with surrounding/only whitespace.
- Resolution: search both the original and effective display name plus Matrix ID; trim contact/conversation search text and treat whitespace-only input as an empty query. Load current remarks before mapping ignored profiles. Existing ContactBloc and conversation consumers use the repaired repository methods.
- Verification: 32 contact cases cover lookup, identity mapping, remark persistence failures, invitations and presence; 24 conversation cases cover mapping, search, creation failures, unread deduplication and typing subscription/timer cleanup.

### GROUP-002 Failed gate reads and imprecise balances can approve verification — Resolved 2026-09-14

- Severity: H
- Evidence: 21 of 42 initial gate regressions fail, including malformed/failed configuration reads being treated as absent gates, an amount one wei below the threshold passing through double rounding, and unsupported native chains reading Ethereum funds.
- Resolution: a strict datasource read distinguishes a missing gate from an unavailable room/state; enabled rule validation rejects malformed operators, standards, chains, contracts, minimums and ERC-1155 IDs. Invalid saves fail before state writes. Verification returns failure on read/parse errors and converts the wallet's decimal native balance directly to BigInt units. Native chains are restricted to the five supported by the current settings UI; unsupported chains no longer fall back to ETH.
- Verification: 49 gate cases exercise the real datasource and repository with mocked Matrix/wallet boundaries, including the actual AcceptGroupInvite and SetTokenGate Bloc paths, state-write permissions, ERC-20/721/1155, AND/OR, exact unit boundaries, invalid balances and RPC failures. No real blockchain query, transaction or external message occurred. GROUP-001 remains open for broader admission control.

### SEARCH-001 Archived results ignore active message filters — Resolved 2026-09-14

- Severity: M
- Evidence: 21 of 22 initial SQLite-backed regressions returned messages with the wrong sender/type/date, including results outside the active only-from-me filter. SearchRepositoryImpl did not pass MessageSearchFilter to the archive service.
- Resolution: forward the filter through the repository and archive service into parameterized SQL before LIMIT/OFFSET. Apply sender, authenticated only-from-me, inclusive date boundaries, resolved message type and media-only conditions together with hidden/locked room exclusions. Missing authenticated identity returns no only-from-me matches. Preserve the archive mapper's existing type precedence and audio/voice representation.
- Verification: 31 real SQLite repository/service cases cover filter combinations, page limits/offsets, room visibility, SQL binding, snippets, counts and unavailable FTS; 43 repository cases cover discovery, mappings, merging and navigation. These are local synthetic tests, not new live-homeserver/device acceptance.

### SEARCH-002 Loading more results loses the selected message — Resolved 2026-09-14

- Severity: M
- Evidence: all three navigation regressions fail on the previous repository implementation: a newly inserted result shifts selection, deleting the selected result leaves an invalid index, and removing all results leaves index zero.
- Resolution: preserve the selected message by ID after refresh; if it disappeared, clamp to the nearest valid index, or use -1 for an empty list. Regressions also verify filter propagation, expanded page size and unchanged original results.

### BACKUP-001 Password-protected v3 backups can fail authentication — Resolved 2026-09-13

- Severity: H
- Evidence: new file-level tests reproduced correct-password failures for full and incremental backups. The writer serialized the block-rounded GCM output buffer, so the last 16 bytes were not always the actual authentication tag.
- Resolution: serialize the actual bytes returned by the cipher. The reader authenticates normal v3 data first; it also recovers the historical zero-padded layout using a bounded 1–15 byte retry, with successful GCM authentication required for every accepted candidate. Wrong passwords, altered salt/nonce/tag/ciphertext and malformed files remain rejected. Independent Python cryptography fixtures verify both standard and historical layouts. Tests use public synthetic data only.

### BACKUP-002 Repeated backups and exports overwrite earlier files — Resolved 2026-09-13

- Severity: H
- Evidence: consecutive full/incremental backup tests produced identical minute-based paths. HTML/JSON/TXT exports of the same room also reused the same second-based path, replacing files that could still be referenced by a share sheet.
- Resolution: backup filenames include their unique backup ID; each chat export uses its own temporary directory. Regression tests verify distinct paths and byte-for-byte preservation of the earlier file. Existing backup discovery/deletion and export sharing continue to use the returned paths.

### INTEGRATION-001 Wallet build source differed from its declared Chat pin — Resolved

Host master commit `aecb6f77` was published to n42appv2. It pins `cbc7bd1a128d841ff667708e513fc1ca0b708f9e`, removes the tracked Chat path override, and records Git source in pubspec.lock. The resolved Git package and host cache match across all 764 lib/assets files (SHA-256 manifest in host docs/chat-audit-2026-09-12/CHAT_SOURCE_MANIFEST_2026-09-12.json). Host full suite: 4,163 passed; after Git resolution, 18 additional targeted tests passed and analyze reports zero errors/warnings with 155 infos. The original divergence evidence remains in docs/HOST_BASELINE_SYNC_2026-09-12.json.

### INTEGRATION-003 Nested settings failure handling — Resolved

- Severity: M
- Added / resolved: 2026-09-12
- Evidence: `nested_settings_failure_test.dart`, `settings_write_failure_test.dart`
- Resolution: account-list and notification-filter reads show a retry state on failure. Filter saves serialize input, restore confirmed rules on failure, and update the running push filter only after storage succeeds. Appearance, notification and filter writes reject platform `false` results and reload SharedPreferences' optimistic cache from durable storage.
- Verification: fault injection covers both `false` and thrown platform failures, cached-value restoration, successful retry, filter read/write failures and late completion after disposal. If the platform also refuses cache reload, the original write failure is still surfaced; recovery from a persistently unavailable OS store is not claimed.
