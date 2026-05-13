// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
//
// Pure helpers for chat notification tap deduplication.
//
// Extracted from [AppPushUtils] so they can be unit-tested without pulling
// in `package:n42_chat` (which has native transitive dependencies that
// fail to resolve in pure-Dart unit tests).
//
// The dedup logic is what landed on the chat side after several rounds of
// push notification audit: without it, opening a chat notification can
// trigger duplicate `openConversation` calls when the cold-start path
// and the OS tap path both fire for the same physical tap.

/// Returns true when `(roomId, eventId)` should be treated as the **same**
/// chat notification tap as `(otherRoomId, otherEventId)`.
///
/// Rules:
/// 1. Different `roomId` (or other is null) → always not a match.
/// 2. Same `roomId`, and either eventId is missing/blank → match.
///    (FCM payload may omit `event_id`, especially for cold-start; without
///    an event id, the room id alone is the strongest signal we have.)
/// 3. Same `roomId` AND both eventIds non-blank → match iff they are equal
///    after `trim()`.
bool chatTapMatches({
  required String roomId,
  String? eventId,
  required String? otherRoomId,
  String? otherEventId,
}) {
  if (otherRoomId == null || roomId != otherRoomId) {
    return false;
  }

  final normalizedEventId = eventId?.trim() ?? '';
  final normalizedOtherEventId = otherEventId?.trim() ?? '';
  if (normalizedEventId.isEmpty || normalizedOtherEventId.isEmpty) {
    return true;
  }

  return normalizedEventId == normalizedOtherEventId;
}

/// Returns true when a notification handled at [handledAt] with
/// `(handledRoomId, handledEventId)` is recent enough — within [dedupWindow]
/// of [now] — that a duplicate tap for `(roomId, eventId)` should be
/// suppressed.
///
/// Used by the push pipeline to drop the second fire when iOS / Android
/// dispatches both an `onMessageOpenedApp` and a cold-start initial
/// message for the same physical tap.
bool wasChatNotificationHandledRecently({
  required String roomId,
  String? eventId,
  required String? handledRoomId,
  String? handledEventId,
  required DateTime? handledAt,
  required DateTime now,
  required Duration dedupWindow,
}) {
  if (handledAt == null || handledRoomId == null) {
    return false;
  }
  if (now.difference(handledAt) > dedupWindow) {
    return false;
  }
  return chatTapMatches(
    roomId: roomId,
    eventId: eventId,
    otherRoomId: handledRoomId,
    otherEventId: handledEventId,
  );
}
