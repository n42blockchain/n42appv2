// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// Contract tests for FCM payload routing to n42_chat vs host. These
// codify the chat integration boundary on the push pipeline — if any
// chat ref bump or host-side refactor changes the routing semantics
// (e.g. someone "simplifies" `roomId is String` to `roomId != null`),
// these tests catch it before users get duplicate notifications, lost
// calls, or n42_chat throwing on malformed payloads.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/utils/chat_push_routing.dart';

void main() {
  group('isChatPushPayload', () {
    test('returns true for non-empty room_id', () {
      expect(
        isChatPushPayload({'room_id': '!room123:matrix.example.com'}),
        isTrue,
      );
    });

    test('returns true for m.call.invite', () {
      expect(isChatPushPayload({'type': 'm.call.invite'}), isTrue);
    });

    test('returns true for m.call.answer', () {
      expect(isChatPushPayload({'type': 'm.call.answer'}), isTrue);
    });

    test('returns true for m.call.hangup', () {
      expect(isChatPushPayload({'type': 'm.call.hangup'}), isTrue);
    });

    test('returns true for m.call.candidates', () {
      expect(isChatPushPayload({'type': 'm.call.candidates'}), isTrue);
    });

    test('returns false for transaction notification', () {
      expect(
        isChatPushPayload({
          'type': 'normal_transaction_failed',
          'tx_hash': '0xabc',
        }),
        isFalse,
      );
    });

    test('returns false for device_login', () {
      expect(
        isChatPushPayload({'type': 'device_login', 'device_id': 'abc'}),
        isFalse,
      );
    });

    test('returns false for empty payload', () {
      expect(isChatPushPayload(<String, dynamic>{}), isFalse);
    });

    test('returns false when room_id is empty string', () {
      expect(isChatPushPayload({'room_id': ''}), isFalse);
    });

    test('returns false when room_id is null', () {
      expect(isChatPushPayload({'room_id': null}), isFalse);
    });

    test('returns false when room_id is a non-string (defensive)', () {
      // FCM payload arrives as Map<String, dynamic>; this catches the case
      // where backend mistakenly puts an int / map in the room_id slot.
      expect(isChatPushPayload({'room_id': 123}), isFalse);
      expect(
        isChatPushPayload({
          'room_id': {'inner': 'val'},
        }),
        isFalse,
      );
    });

    test('returns false when type is null', () {
      expect(isChatPushPayload({'type': null}), isFalse);
    });

    test('returns false when type is a non-string (defensive)', () {
      expect(isChatPushPayload({'type': 42}), isFalse);
    });

    test(
      'returns false for "mcall." typo (must start with literal "m.call.")',
      () {
        expect(isChatPushPayload({'type': 'mcall.invite'}), isFalse);
      },
    );

    test('returns false for case-mismatched prefix', () {
      // Matrix spec uses lowercase; we want strict matching to avoid
      // accidentally swallowing host events that happen to mention "M.Call".
      expect(isChatPushPayload({'type': 'M.call.invite'}), isFalse);
    });

    test('prefers room_id over type (room_id wins)', () {
      // If both fields are present, either field alone is sufficient;
      // the OR semantics in the production code mean a non-call event
      // with a room_id still routes to chat (which is correct — the
      // m.call event WOULD also have a room_id in practice).
      expect(
        isChatPushPayload({
          'room_id': '!room123:srv',
          'type': 'm.room.message',
        }),
        isTrue,
      );
    });
  });

  group('extractChatRoomId', () {
    test('returns the value when room_id is a non-empty String', () {
      expect(extractChatRoomId({'room_id': '!r:srv'}), '!r:srv');
    });

    test('returns null for empty / null / non-string room_id', () {
      expect(extractChatRoomId({'room_id': ''}), isNull);
      expect(extractChatRoomId({'room_id': null}), isNull);
      expect(extractChatRoomId({'room_id': 42}), isNull);
      expect(extractChatRoomId(<String, dynamic>{}), isNull);
    });
  });

  group('extractChatEventId', () {
    test('returns the value when event_id is a non-empty String', () {
      expect(extractChatEventId({'event_id': r'$e:srv'}), r'$e:srv');
    });

    test('returns null for empty / null / non-string event_id', () {
      expect(extractChatEventId({'event_id': ''}), isNull);
      expect(extractChatEventId({'event_id': null}), isNull);
      expect(extractChatEventId({'event_id': []}), isNull);
      expect(extractChatEventId(<String, dynamic>{}), isNull);
    });
  });

  group('isMatrixCallPayload', () {
    test('returns true for m.call.invite', () {
      expect(isMatrixCallPayload({'type': 'm.call.invite'}), isTrue);
    });

    test('returns true for m.call.hangup even without room_id', () {
      expect(isMatrixCallPayload({'type': 'm.call.hangup'}), isTrue);
    });

    test('returns false for plain chat room message', () {
      // A regular room message has room_id but no `m.call.` type — this
      // is the discriminator the cold-start handler uses to decide
      // whether to defer to CallKit (call) vs queue for conversation
      // open (regular message).
      expect(
        isMatrixCallPayload({'room_id': '!room:srv', 'type': 'm.room.message'}),
        isFalse,
      );
    });

    test('returns false for empty payload', () {
      expect(isMatrixCallPayload(<String, dynamic>{}), isFalse);
    });

    test('returns false for null type', () {
      expect(isMatrixCallPayload({'type': null}), isFalse);
    });
  });
}
