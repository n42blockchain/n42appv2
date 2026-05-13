// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// Contract tests for the chat notification tap dedup utilities. These
// guard the invariants that came out of the chat-side push notification
// audit: a single physical tap must not trigger duplicate
// `N42Chat.openConversation` calls when both cold-start and
// onMessageOpenedApp fire for it.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/utils/chat_tap_dedup.dart';

void main() {
  group('chatTapMatches', () {
    test('matches identical roomId + identical eventId', () {
      expect(
        chatTapMatches(
          roomId: '!room1:srv',
          eventId: r'$evt1',
          otherRoomId: '!room1:srv',
          otherEventId: r'$evt1',
        ),
        isTrue,
      );
    });

    test('does not match different roomId', () {
      expect(
        chatTapMatches(
          roomId: '!room1:srv',
          eventId: r'$evt1',
          otherRoomId: '!room2:srv',
          otherEventId: r'$evt1',
        ),
        isFalse,
      );
    });

    test('does not match when otherRoomId is null', () {
      expect(
        chatTapMatches(
          roomId: '!room1:srv',
          eventId: r'$evt1',
          otherRoomId: null,
          otherEventId: r'$evt1',
        ),
        isFalse,
      );
    });

    test('matches when both eventIds are null (room-only signal)', () {
      // FCM may omit event_id; the room id alone is the dedup key.
      expect(
        chatTapMatches(
          roomId: '!room1:srv',
          eventId: null,
          otherRoomId: '!room1:srv',
          otherEventId: null,
        ),
        isTrue,
      );
    });

    test('matches when one eventId is null (room-only signal)', () {
      expect(
        chatTapMatches(
          roomId: '!room1:srv',
          eventId: null,
          otherRoomId: '!room1:srv',
          otherEventId: r'$evt1',
        ),
        isTrue,
      );
    });

    test('matches when one eventId is empty', () {
      expect(
        chatTapMatches(
          roomId: '!room1:srv',
          eventId: '',
          otherRoomId: '!room1:srv',
          otherEventId: r'$evt1',
        ),
        isTrue,
      );
    });

    test('matches when one eventId is whitespace-only', () {
      expect(
        chatTapMatches(
          roomId: '!room1:srv',
          eventId: '   ',
          otherRoomId: '!room1:srv',
          otherEventId: r'$evt1',
        ),
        isTrue,
      );
    });

    test('does not match when both eventIds are non-blank but differ', () {
      expect(
        chatTapMatches(
          roomId: '!room1:srv',
          eventId: r'$evtA',
          otherRoomId: '!room1:srv',
          otherEventId: r'$evtB',
        ),
        isFalse,
      );
    });

    test('matches eventIds after trim', () {
      expect(
        chatTapMatches(
          roomId: '!room1:srv',
          eventId: '  \$evt1  ',
          otherRoomId: '!room1:srv',
          otherEventId: r'$evt1',
        ),
        isTrue,
      );
    });

    test('roomId comparison is case-sensitive', () {
      // Matrix room IDs are case-sensitive — keep dedup strict.
      expect(
        chatTapMatches(
          roomId: '!room1:srv',
          eventId: null,
          otherRoomId: '!Room1:srv',
          otherEventId: null,
        ),
        isFalse,
      );
    });
  });

  group('wasChatNotificationHandledRecently', () {
    final now = DateTime(2026, 5, 13, 12, 0, 0);
    const window = Duration(seconds: 8);

    test('returns false when handledAt is null', () {
      expect(
        wasChatNotificationHandledRecently(
          roomId: '!r1:srv',
          eventId: null,
          handledRoomId: '!r1:srv',
          handledEventId: null,
          handledAt: null,
          now: now,
          dedupWindow: window,
        ),
        isFalse,
      );
    });

    test('returns false when handledRoomId is null', () {
      expect(
        wasChatNotificationHandledRecently(
          roomId: '!r1:srv',
          eventId: null,
          handledRoomId: null,
          handledEventId: null,
          handledAt: now.subtract(const Duration(seconds: 2)),
          now: now,
          dedupWindow: window,
        ),
        isFalse,
      );
    });

    test('returns false when last tap is older than window', () {
      expect(
        wasChatNotificationHandledRecently(
          roomId: '!r1:srv',
          eventId: r'$e1',
          handledRoomId: '!r1:srv',
          handledEventId: r'$e1',
          handledAt: now.subtract(const Duration(seconds: 30)),
          now: now,
          dedupWindow: window,
        ),
        isFalse,
      );
    });

    test('returns true when last tap is within window AND tap matches', () {
      expect(
        wasChatNotificationHandledRecently(
          roomId: '!r1:srv',
          eventId: r'$e1',
          handledRoomId: '!r1:srv',
          handledEventId: r'$e1',
          handledAt: now.subtract(const Duration(seconds: 3)),
          now: now,
          dedupWindow: window,
        ),
        isTrue,
      );
    });

    test('returns false when within window but different room', () {
      expect(
        wasChatNotificationHandledRecently(
          roomId: '!other:srv',
          eventId: r'$e1',
          handledRoomId: '!r1:srv',
          handledEventId: r'$e1',
          handledAt: now.subtract(const Duration(seconds: 3)),
          now: now,
          dedupWindow: window,
        ),
        isFalse,
      );
    });

    test('boundary: exactly at the dedup window edge is inside', () {
      // `difference > window` so equal-to-window is still inside.
      expect(
        wasChatNotificationHandledRecently(
          roomId: '!r1:srv',
          eventId: null,
          handledRoomId: '!r1:srv',
          handledEventId: null,
          handledAt: now.subtract(window),
          now: now,
          dedupWindow: window,
        ),
        isTrue,
      );
    });

    test('boundary: just past the window is outside', () {
      expect(
        wasChatNotificationHandledRecently(
          roomId: '!r1:srv',
          eventId: null,
          handledRoomId: '!r1:srv',
          handledEventId: null,
          handledAt: now.subtract(window + const Duration(milliseconds: 1)),
          now: now,
          dedupWindow: window,
        ),
        isFalse,
      );
    });
  });
}
