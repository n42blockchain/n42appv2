// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
//
// Pure helpers for routing FCM payloads to either `n42_chat` or the host
// app's notification handler. Extracted from [AppPushUtils] so the
// routing semantics can be pinned with unit tests instead of relying on
// three separate `if (roomId != null || dataType.startsWith('m.call.'))`
// blocks staying in lockstep across the FG / BG / cold-start handlers.

import 'dart:convert';

/// FCM `data` payload keys for chat / Matrix events. Centralized here so
/// any future backend rename surfaces at one call site instead of being
/// fanned out across the four push handlers.
const String pushDataKeyRoomId = 'room_id';
const String pushDataKeyEventId = 'event_id';
const String pushDataKeyType = 'type';

/// Prefix for Matrix VoIP signaling `type` values
/// (`m.call.invite` / `.answer` / `.candidates` / `.hangup` / etc.).
const String matrixCallTypePrefix = 'm.call.';

/// Returns true when an FCM `data` payload should be delegated to the
/// `n42_chat` plugin.
///
/// **Routing rules (must match across FG / BG / cold-start paths):**
/// 1. Payload has a non-empty `room_id` string → chat room message →
///    delegate so n42_chat can render the chat notification, deep-link
///    the user to the conversation, or trigger MLS decryption.
/// 2. Payload `type` starts with `m.call.` (Matrix VoIP signaling) →
///    delegate so CallKit / the in-app call screen can pick it up.
/// 3. Otherwise → host handles (transaction notifications, device-login
///    alerts, marketing pushes, mining rewards, etc.).
///
/// Non-string / null values for `room_id` and `type` are treated as
/// "not chat" — the host should NEVER hand a malformed payload to
/// n42_chat (it would throw on cast). This defensively guards the
/// boundary.
bool isChatPushPayload(Map<String, dynamic> data) {
  if (extractChatRoomId(data) != null) {
    return true;
  }
  return isMatrixCallPayload(data);
}

/// Returns true when an FCM `data` payload is specifically a Matrix VoIP
/// call event (not a regular chat room message).
///
/// The host's cold-start and background handlers use this to decide
/// whether CallKit/sync should drive the call flow on its own (call
/// events are async-handled by the chat plugin's call lifecycle, not
/// by the host's local-notification renderer).
bool isMatrixCallPayload(Map<String, dynamic> data) {
  final dataType = data[pushDataKeyType];
  return dataType is String && dataType.startsWith(matrixCallTypePrefix);
}

/// Returns the `room_id` from an FCM payload if it is a non-empty
/// String, else null. Treat any other shape (int, null, empty) as
/// "no chat room" — backend should always send a String, but the host
/// has no compile-time contract guarantee.
String? extractChatRoomId(Map<String, dynamic> data) {
  final value = data[pushDataKeyRoomId];
  return value is String && value.isNotEmpty ? value : null;
}

/// Returns the `event_id` from an FCM payload if it is a non-empty
/// String, else null. Same defensive shape check as [extractChatRoomId].
String? extractChatEventId(Map<String, dynamic> data) {
  final value = data[pushDataKeyEventId];
  return value is String && value.isNotEmpty ? value : null;
}

/// Decoded local-notification payload routed to the chat module.
typedef ChatNotificationRoute = ({String roomId, String? eventId});

/// Decodes a local-notification JSON [payload] and returns the chat
/// route when it carries a non-empty `room_id`, else null (host-owned
/// payload or malformed JSON).
///
/// Used by the host's local-notification tap handler: before `n42_chat`
/// finishes initializing, taps on chat local notifications land on the
/// host callback, and must be queued for the chat module instead of
/// being fed into host navigation.
ChatNotificationRoute? tryExtractChatRouteFromPayload(String payload) {
  Object? decoded;
  try {
    decoded = json.decode(payload);
  } catch (_) {
    return null;
  }
  if (decoded is! Map<String, dynamic>) {
    return null;
  }
  final roomId = extractChatRoomId(decoded);
  if (roomId == null) {
    return null;
  }
  return (roomId: roomId, eventId: extractChatEventId(decoded));
}
