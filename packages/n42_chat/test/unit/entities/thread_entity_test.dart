import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/thread_entity.dart';

MessageEntity _makeMessage({
  String id = r'$root:s',
  String roomId = '!room:s',
}) =>
    MessageEntity(
      id: id,
      roomId: roomId,
      senderId: '@alice:s',
      senderName: 'Alice',
      content: 'Hello',
      timestamp: DateTime(2025, 6, 1, 12),
      type: MessageType.text,
      status: MessageStatus.sent,
    );

void main() {
  // ─────────────────────────────────────────────────
  // Construction
  // ─────────────────────────────────────────────────

  group('ThreadEntity construction', () {
    test('creates with required fields and defaults', () {
      final thread = ThreadEntity(rootMessage: _makeMessage());
      expect(thread.replies, isEmpty);
      expect(thread.replyCount, 0);
      expect(thread.participantIds, isEmpty);
      expect(thread.hasMore, isFalse);
    });

    test('creates with all fields', () {
      final root = _makeMessage();
      final reply = _makeMessage(id: r'$reply1:s');
      final thread = ThreadEntity(
        rootMessage: root,
        replies: [reply],
        replyCount: 1,
        participantIds: ['@alice:s', '@bob:s'],
        hasMore: true,
      );
      expect(thread.replies.length, 1);
      expect(thread.participantIds.length, 2);
      expect(thread.hasMore, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // Derived getters
  // ─────────────────────────────────────────────────

  group('ThreadEntity.participantCount', () {
    test('returns participantIds.length', () {
      final thread = ThreadEntity(
        rootMessage: _makeMessage(),
        participantIds: ['@a:s', '@b:s', '@c:s'],
      );
      expect(thread.participantCount, 3);
    });

    test('returns 0 when no participants', () {
      final thread = ThreadEntity(rootMessage: _makeMessage());
      expect(thread.participantCount, 0);
    });
  });

  group('ThreadEntity.rootEventId', () {
    test('returns rootMessage.id', () {
      final thread = ThreadEntity(rootMessage: _makeMessage(id: r'$abc:s'));
      expect(thread.rootEventId, r'$abc:s');
    });
  });

  group('ThreadEntity.roomId', () {
    test('returns rootMessage.roomId', () {
      final thread = ThreadEntity(
        rootMessage: _makeMessage(roomId: '!myroom:s'),
      );
      expect(thread.roomId, '!myroom:s');
    });
  });

  group('ThreadEntity.latestReply', () {
    test('returns null when no replies', () {
      final thread = ThreadEntity(rootMessage: _makeMessage());
      expect(thread.latestReply, isNull);
    });

    test('returns last reply when replies exist', () {
      final r1 = _makeMessage(id: r'$r1:s');
      final r2 = _makeMessage(id: r'$r2:s');
      final thread = ThreadEntity(
        rootMessage: _makeMessage(),
        replies: [r1, r2],
      );
      expect(thread.latestReply?.id, r'$r2:s');
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable props
  // ─────────────────────────────────────────────────

  group('ThreadEntity equality', () {
    test('two instances with same fields are equal', () {
      final root = _makeMessage();
      final a = ThreadEntity(rootMessage: root, replyCount: 5);
      final b = ThreadEntity(rootMessage: root, replyCount: 5);
      expect(a, equals(b));
    });

    test('different replyCount → not equal', () {
      final root = _makeMessage();
      final a = ThreadEntity(rootMessage: root, replyCount: 1);
      final b = ThreadEntity(rootMessage: root, replyCount: 2);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith
  // ─────────────────────────────────────────────────

  group('ThreadEntity.copyWith', () {
    test('replaces only specified field', () {
      final original = ThreadEntity(
        rootMessage: _makeMessage(),
        replyCount: 2,
        hasMore: false,
      );
      final copy = original.copyWith(hasMore: true);
      expect(copy.hasMore, isTrue);
      expect(copy.replyCount, 2);
      expect(copy.rootMessage, original.rootMessage);
    });

    test('retains all fields when nothing changed', () {
      final original = ThreadEntity(
        rootMessage: _makeMessage(),
        participantIds: ['@a:s'],
      );
      final copy = original.copyWith();
      expect(copy, equals(original));
    });
  });
}
