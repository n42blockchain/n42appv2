# Task16 UGC moderation design inputs

Research date: 2026-09-26. Narrow source investigation of official Chat and host worktrees. Not an implementation approval, deployed-service audit, or passing-test claim. No tests or production reports were sent.

## Confirmed source findings

Chat paths below are relative to `/Users/jieliu/.codex/worktrees/n42-chat-dependency-completion`.

| Surface | Evidence and actionable finding |
| --- | --- |
| User profile report | **Confirmed false success:** `lib/src/presentation/pages/profile/user_profile_page.dart:608–703` collects reason/description, but Submit at 673–698 only closes the dialog and shows “Report submitted”. No repository/network submission occurs in that callback. Replace with an actual reviewed report contract and awaited outcome; do not invent an endpoint. |
| Chat/group message report | `chat_page_message_menu.dart:329–367` dispatches `ReportMessage(message.id, reason)`. `chat_bloc_action_handlers.part.dart:398–416` awaits repository and emits success only after completion. `message_repository_impl.dart:1817–1828` checks client/room and calls `client.reportEvent(roomId,eventId,reason:reason)`. This is a real submission path, but server receipt does not prove human moderation. Group messages share the chat path; verify actual group entrypoint behavior. |
| Contact block | `contact_settings_page.dart:136–138` awaits repository ignore/unignore. `contact_bloc.dart` also awaits these operations. `matrix_contact_datasource.dart:326–334` delegates to Matrix ignored users, but silently returns if client is null. Change that no-client outcome to an explicit failure so UI cannot claim persistence. |
| Feed/moments/video | No report operation found in inspected `moment_repository.dart`, moment repository implementation, moment detail/video feed pages or the report-symbol search. Repository provides delete/comment and visibility operations. `moment_repository_impl.dart:293–324` persists hidden/blocked moment-user lists to storage; this is not a moderation report and does not prove server-enforced audience restriction. Trace filtering and recipient delivery before describing it as a privacy guarantee. |
| Feed identity mapping | `matrix_moment_datasource.dart:37–40` maintains separate moment-ID→room-ID and moment-ID→event-ID indexes; posts use generated `moment_...` IDs. A feed report must resolve the actual Matrix event identity, not pass a moment ID as an event ID. Define restart/history-miss behavior before reusing message reporting. |
| Mini-app | Inspected `presentation/pages/mini_app/mini_app_page.dart` blocks untrusted origins/navigation. No report operation found by focused search. Origin restrictions are not abuse-report handling. Verify deployed mini-app catalog and exposed UGC before deciding which reporting controls apply. |

Host `lib` searches for reportContent/reportUser/reportEvent/moderation/举报 outside generated files returned no matches. This does not establish absence of external services or every possible localized entrypoint; it establishes no reusable host moderation contract from this scan. Identify service ownership before adding host or mini-app submissions.

## Existing backend protocol versus operational evidence

Matrix event reports use authenticated `POST /_matrix/client/v3/rooms/{roomId}/report/{eventId}` with a reason (and optional score). Reuse the existing repository for actual Matrix events. Do not overload event reports with an arbitrary user ID, mini-app URL or local feed ID. [Matrix stable report API](https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3roomsroomidreporteventid).

Matrix ignored-user persistence is account data, not server-wide banning or moderation. Confirm incoming invites, direct-message admission, existing-room timeline, notifications, calls and feed behavior separately. Do not claim blocking removes historical content or prevents every group interaction unless tested.

For encrypted events the current submission sends event identifiers and reason, not decrypted message evidence or keys. Determine what the operator can actually review. Any voluntary evidence attachment requires explicit user disclosure/consent, bounded content and secure retention; do not silently export conversation history or encryption keys to make reports actionable.

A successful API response does not prove queue ingestion, operator access, triage, response times, takedown, escalation or reporter feedback. Production homeserver implementation, moderation integrations and support ownership remain evidence-required. Source absence cannot prove a deployed service is missing.

## Minimal implementation sequence

1. Prefer the standard SDK `reportUser` for Matrix profiles and `reportRoom` for rooms, subject to server support as documented below. A custom profile-report service is not inherently required. Agree a contract only for non-Matrix content or an explicitly documented operational integration. Define subject identity, reason, optional consented evidence, authenticated reporter, server acknowledgement, retry/rate-limit behavior and privacy retention.
2. Repair profile false success and no-client block success. Preserve draft/error on failure; clear/report success only after acknowledged submission. Bind async operations to the initiating account and subject.
3. Add content report entrypoints for exposed feed/video surfaces, resolving real Matrix event IDs where applicable. Verify cached-index misses and comments as distinct subjects. Do not let unsupported routes show success.
4. Verify block behavior across the actual chat/group/feed/video/call/notification flows. Keep feed hiding, contact blocking and moderation reports accurately distinguished in UI.
5. Connect accessible support and published safety/reporting information to actual owned destinations, then verify operator receipt and resolution using synthetic/disposable content.

## Existing tests and targeted additions

### Follow-up correction: standard user and room reporting already exist

Verified directly in official `matrix 13.0.0` archive (SHA256 `fd8629c8e5c0d39e77208d0f50b68fd7b483340c38da1ecc324fc388835ff02e`), `lib/matrix_api_lite/generated/api.dart`:

- Line 5904: `Future<Map<String, Object?>> reportUser(String userId, String reason)`. Authenticated POST `/_matrix/client/v3/users/{userId}/report`, JSON `reason`; SDK URL-encodes user ID. Standard since **Matrix v1.14**. No shared-room membership prerequisite. [Stable specification](https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3usersuseridreport).
- Line 4902: `Future<void> reportRoom(String roomId, String reason)`. Authenticated POST `/_matrix/client/v3/rooms/{roomId}/report`, JSON `reason`; SDK URL-encodes room ID. Standard since **Matrix v1.13**. No joined-room prerequisite. [Stable specification](https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3roomsroomidreport).

These are preferable concrete seams for the false-success profile callback and a room-level report action. They are distinct from `reportEvent`, which remains appropriate for a specific message. My initial brief did not check these generated endpoints; its suggestion that profile reporting first needs an agreed custom service was too broad and is corrected here.

Discover advertised protocol support using `GET /_matrix/client/versions` (SDK `getVersions()`), checking supported stable versions numerically: v1.14-or-later for user reports and v1.13-or-later for room reports. These endpoints do not define a separate `/capabilities` feature key. Do not invent one or infer support from server product name. Older servers may have backports, but require documented/probed integration evidence; do not submit synthetic reports merely as capability probes. [Version discovery](https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientversions).

Handle runtime `M_UNRECOGNIZED`/unsupported route honestly even when advertised version suggests support. Preserve the report draft, explain unavailability and offer only a verified support route. Do not turn 404 into success or treat every 404 as capability absence: a report endpoint may return not-found for its subject. Handle unauthorized/rate-limited/network outcomes independently. Add fixtures for supported/older advertised versions, actual unsupported route, missing subject, rate limit and success.

Both SDK methods require HTTP 200; the standard permits privacy-preserving 200 responses without revealing whether a subject exists. Therefore receipt means the server accepted the request according to its protocol, not proof of subject existence, queue delivery, investigation or action. Actual production endpoint support and moderator workflow remain unverified. No network report was submitted during this research.

Existing source tests worth extending:

- `test/presentation/pages/contact_settings_page_test.dart`: persistence interactions including unignore.
- `test/unit/blocs/contact_bloc_test.dart:645–725`: ignore/unignore success and repository failure.
- `test/unit/repositories/moment_repository_impl_test.dart`, moment bloc tests, `test/presentation/pages/moment/moment_detail_page_test.dart`, `moment_list_page_test.dart`, `video_feed_refresh_test.dart`.

No dedicated message-report regression surfaced in the focused reportMessage/ReportMessage search. Add:

- Profile submit calls the real contract exactly once; description/reason/subject preserved; offline, unauthorized and rate-limited submission never show success.
- Message report uses correct room/event/account, awaits acknowledgement, handles missing room and network failure. Group event reporting exercises the shared path.
- Feed/video/comment report resolves canonical event identity after reload and fails honestly when unresolved.
- Block fails without an authenticated client; server failure preserves state; successful block persists after restart and remains account-scoped.
- Account switch during report/block cannot update or submit under a different identity. Duplicate taps and cancellation are bounded.
- Visibility and blocking regressions for history, incoming invitations/messages, calls/notifications and relevant feed/video presentation.
- Real operator inbox receipt and synthetic-case handling acceptance, separate from transport/widget tests. No harmful content is necessary for these checks.

## Store and external evidence gates

Apple UGC guidance requires filtering objectionable material, reporting with timely response, blocking abusive users and published contact information. Existing code alone does not establish those operational requirements. [Apple guideline 1.2](https://developer.apple.com/app-store/review/guidelines/#user-generated-content).

For applicable social apps, Google child-safety standards require public anti-CSAE standards, in-app feedback, action on CSAM, compliance with reporting duties and a child-safety contact. Do not assume an adult audience automatically exempts the social app. Confirm actual category, target audience and organizational reporting process. [Google child-safety standards](https://support.google.com/googleplay/android-developer/answer/14747720?hl=en).

Still required: approved public standards/terms and support URLs; operator ownership and access; report triage/escalation/retention rules; actual content-filtering configuration and coverage; jurisdiction-appropriate child-safety reporting process/contact; console declarations; E2EE report-evidence policy; deployed mini-app catalog and responsibilities. Do not infer compliance or violations solely from feature names, a visible button, or an unverified backend assumption.
