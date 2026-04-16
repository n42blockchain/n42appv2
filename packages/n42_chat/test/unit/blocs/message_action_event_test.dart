// Tests for MessageActionEvent subclasses in message_action_event.dart.
// All events except SaveMessage are pure String/List<String> — const-capable.
// SaveMessage(MessageEntity) is skipped for equality; type assertion tested only.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/message_action/message_action_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // LoadSavedMessages (parameterless)
  // ─────────────────────────────────────────────────

  group('LoadSavedMessages', () {
    test('is a MessageActionEvent', () {
      expect(const LoadSavedMessages(), isA<MessageActionEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadSavedMessages(), equals(const LoadSavedMessages()));
    });
  });

  // ─────────────────────────────────────────────────
  // AddReaction / RemoveReaction / ToggleReaction
  // ─────────────────────────────────────────────────

  group('AddReaction', () {
    test('stores roomId, eventId, emoji', () {
      const e = AddReaction('!room:s', '\$event:s', '👍');
      expect(e.roomId, '!room:s');
      expect(e.eventId, '\$event:s');
      expect(e.emoji, '👍');
    });

    test('same fields → equal', () {
      expect(
        const AddReaction('!r:s', '\$e:s', '❤️'),
        equals(const AddReaction('!r:s', '\$e:s', '❤️')),
      );
    });

    test('different emoji → not equal', () {
      expect(
        const AddReaction('!r:s', '\$e:s', '👍'),
        isNot(equals(const AddReaction('!r:s', '\$e:s', '👎'))),
      );
    });

    test('is a MessageActionEvent', () {
      expect(const AddReaction('!r:s', '\$e:s', '🔥'), isA<MessageActionEvent>());
    });
  });

  group('RemoveReaction', () {
    test('stores roomId, eventId, emoji', () {
      const e = RemoveReaction('!room:s', '\$ev:s', '😂');
      expect(e.roomId, '!room:s');
      expect(e.eventId, '\$ev:s');
      expect(e.emoji, '😂');
    });

    test('same fields → equal', () {
      expect(
        const RemoveReaction('!r:s', '\$e:s', '👋'),
        equals(const RemoveReaction('!r:s', '\$e:s', '👋')),
      );
    });

    test('is a MessageActionEvent', () {
      expect(const RemoveReaction('!r:s', '\$e:s', '🎉'), isA<MessageActionEvent>());
    });
  });

  group('ToggleReaction', () {
    test('stores roomId, eventId, emoji', () {
      const e = ToggleReaction('!r:s', '\$e:s', '⭐');
      expect(e.roomId, '!r:s');
      expect(e.eventId, '\$e:s');
      expect(e.emoji, '⭐');
    });

    test('same fields → equal', () {
      expect(
        const ToggleReaction('!r:s', '\$e:s', '❤️'),
        equals(const ToggleReaction('!r:s', '\$e:s', '❤️')),
      );
    });

    test('different emoji → not equal', () {
      expect(
        const ToggleReaction('!r:s', '\$e:s', '👍'),
        isNot(equals(const ToggleReaction('!r:s', '\$e:s', '👎'))),
      );
    });

    test('is a MessageActionEvent', () {
      expect(const ToggleReaction('!r:s', '\$e:s', '🔥'), isA<MessageActionEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // LoadReactions
  // ─────────────────────────────────────────────────

  group('LoadReactions', () {
    test('stores roomId and eventId', () {
      const e = LoadReactions('!room:s', '\$event:s');
      expect(e.roomId, '!room:s');
      expect(e.eventId, '\$event:s');
    });

    test('same fields → equal', () {
      expect(
        const LoadReactions('!r:s', '\$e:s'),
        equals(const LoadReactions('!r:s', '\$e:s')),
      );
    });

    test('different eventId → not equal', () {
      expect(
        const LoadReactions('!r:s', '\$a:s'),
        isNot(equals(const LoadReactions('!r:s', '\$b:s'))),
      );
    });

    test('is a MessageActionEvent', () {
      expect(const LoadReactions('!r:s', '\$e:s'), isA<MessageActionEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // ReplyToMessage
  // ─────────────────────────────────────────────────

  group('ReplyToMessage', () {
    test('stores roomId, originalEventId, content', () {
      const e = ReplyToMessage('!r:s', '\$orig:s', 'Reply text');
      expect(e.roomId, '!r:s');
      expect(e.originalEventId, '\$orig:s');
      expect(e.content, 'Reply text');
    });

    test('same fields → equal', () {
      expect(
        const ReplyToMessage('!r:s', '\$e:s', 'hi'),
        equals(const ReplyToMessage('!r:s', '\$e:s', 'hi')),
      );
    });

    test('different content → not equal', () {
      expect(
        const ReplyToMessage('!r:s', '\$e:s', 'a'),
        isNot(equals(const ReplyToMessage('!r:s', '\$e:s', 'b'))),
      );
    });

    test('is a MessageActionEvent', () {
      expect(const ReplyToMessage('!r:s', '\$e:s', 'hi'), isA<MessageActionEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // EditMessage
  // ─────────────────────────────────────────────────

  group('EditMessage', () {
    test('stores roomId, originalEventId, newContent', () {
      const e = EditMessage('!r:s', '\$orig:s', 'Updated text');
      expect(e.roomId, '!r:s');
      expect(e.originalEventId, '\$orig:s');
      expect(e.newContent, 'Updated text');
    });

    test('same fields → equal', () {
      expect(
        const EditMessage('!r:s', '\$e:s', 'new'),
        equals(const EditMessage('!r:s', '\$e:s', 'new')),
      );
    });

    test('different newContent → not equal', () {
      expect(
        const EditMessage('!r:s', '\$e:s', 'a'),
        isNot(equals(const EditMessage('!r:s', '\$e:s', 'b'))),
      );
    });

    test('is a MessageActionEvent', () {
      expect(const EditMessage('!r:s', '\$e:s', 'new'), isA<MessageActionEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // RedactMessage
  // ─────────────────────────────────────────────────

  group('RedactMessage', () {
    test('stores roomId and eventId', () {
      const e = RedactMessage('!r:s', '\$e:s');
      expect(e.roomId, '!r:s');
      expect(e.eventId, '\$e:s');
    });

    test('reason defaults to null', () {
      expect(const RedactMessage('!r:s', '\$e:s').reason, isNull);
    });

    test('stores reason when provided', () {
      const e = RedactMessage('!r:s', '\$e:s', reason: 'Spam');
      expect(e.reason, 'Spam');
    });

    test('same fields → equal', () {
      expect(
        const RedactMessage('!r:s', '\$e:s', reason: 'Spam'),
        equals(const RedactMessage('!r:s', '\$e:s', reason: 'Spam')),
      );
    });

    test('different reason → not equal', () {
      expect(
        const RedactMessage('!r:s', '\$e:s', reason: 'Spam'),
        isNot(equals(const RedactMessage('!r:s', '\$e:s', reason: 'Abuse'))),
      );
    });

    test('is a MessageActionEvent', () {
      expect(const RedactMessage('!r:s', '\$e:s'), isA<MessageActionEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // ForwardMessage
  // ─────────────────────────────────────────────────

  group('ForwardMessage', () {
    test('stores fromRoomId, eventId, toRoomId', () {
      const e = ForwardMessage('!from:s', '\$e:s', '!to:s');
      expect(e.fromRoomId, '!from:s');
      expect(e.eventId, '\$e:s');
      expect(e.toRoomId, '!to:s');
    });

    test('same fields → equal', () {
      expect(
        const ForwardMessage('!from:s', '\$e:s', '!to:s'),
        equals(const ForwardMessage('!from:s', '\$e:s', '!to:s')),
      );
    });

    test('different toRoomId → not equal', () {
      expect(
        const ForwardMessage('!f:s', '\$e:s', '!a:s'),
        isNot(equals(const ForwardMessage('!f:s', '\$e:s', '!b:s'))),
      );
    });

    test('is a MessageActionEvent', () {
      expect(
        const ForwardMessage('!f:s', '\$e:s', '!t:s'),
        isA<MessageActionEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // ForwardToMultipleRooms
  // ─────────────────────────────────────────────────

  group('ForwardToMultipleRooms', () {
    test('stores fromRoomId, eventId, toRoomIds', () {
      const e = ForwardToMultipleRooms('!from:s', '\$e:s', ['!a:s', '!b:s']);
      expect(e.fromRoomId, '!from:s');
      expect(e.eventId, '\$e:s');
      expect(e.toRoomIds, ['!a:s', '!b:s']);
    });

    test('same fields → equal', () {
      expect(
        const ForwardToMultipleRooms('!f:s', '\$e:s', ['!a:s']),
        equals(const ForwardToMultipleRooms('!f:s', '\$e:s', ['!a:s'])),
      );
    });

    test('different toRoomIds → not equal', () {
      expect(
        const ForwardToMultipleRooms('!f:s', '\$e:s', ['!a:s']),
        isNot(equals(const ForwardToMultipleRooms('!f:s', '\$e:s', ['!b:s']))),
      );
    });

    test('is a MessageActionEvent', () {
      expect(
        const ForwardToMultipleRooms('!f:s', '\$e:s', []),
        isA<MessageActionEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // UnsaveMessage / CheckMessageSaved
  // ─────────────────────────────────────────────────

  group('UnsaveMessage', () {
    test('stores messageId', () {
      expect(const UnsaveMessage('msg_001').messageId, 'msg_001');
    });

    test('same messageId → equal', () {
      expect(const UnsaveMessage('id'), equals(const UnsaveMessage('id')));
    });

    test('different messageId → not equal', () {
      expect(const UnsaveMessage('a'), isNot(equals(const UnsaveMessage('b'))));
    });

    test('is a MessageActionEvent', () {
      expect(const UnsaveMessage('id'), isA<MessageActionEvent>());
    });
  });

  group('CheckMessageSaved', () {
    test('stores messageId', () {
      expect(const CheckMessageSaved('msg_002').messageId, 'msg_002');
    });

    test('same messageId → equal', () {
      expect(const CheckMessageSaved('id'), equals(const CheckMessageSaved('id')));
    });

    test('different messageId → not equal', () {
      expect(
        const CheckMessageSaved('a'),
        isNot(equals(const CheckMessageSaved('b'))),
      );
    });

    test('is a MessageActionEvent', () {
      expect(const CheckMessageSaved('id'), isA<MessageActionEvent>());
    });
  });
}
