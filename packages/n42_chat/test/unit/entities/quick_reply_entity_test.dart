import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/quick_reply_entity.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Construction
  // ─────────────────────────────────────────────────

  group('QuickReplyEntity construction', () {
    test('creates with required fields and defaults', () {
      const reply = QuickReplyEntity(id: 'r1', content: 'OK');
      expect(reply.id, 'r1');
      expect(reply.content, 'OK');
      expect(reply.order, 0);
      expect(reply.isSystem, isFalse);
      expect(reply.lastUsed, isNull);
      expect(reply.createdAt, isNull);
    });

    test('creates with all fields', () {
      final t = DateTime(2025, 6, 1);
      final reply = QuickReplyEntity(
        id: 'r2',
        content: 'Sure',
        order: 3,
        isSystem: true,
        lastUsed: t,
        createdAt: t,
      );
      expect(reply.order, 3);
      expect(reply.isSystem, isTrue);
      expect(reply.lastUsed, t);
    });
  });

  // ─────────────────────────────────────────────────
  // Static defaultReplies
  // ─────────────────────────────────────────────────

  group('QuickReplyEntity.defaultReplies', () {
    test('has 6 default replies', () {
      expect(QuickReplyEntity.defaultReplies.length, 6);
    });

    test('first reply is 好的', () {
      expect(QuickReplyEntity.defaultReplies.first, '好的');
    });
  });

  // ─────────────────────────────────────────────────
  // createDefaultReplies
  // ─────────────────────────────────────────────────

  group('QuickReplyEntity.createDefaultReplies', () {
    late List<QuickReplyEntity> defaults;

    setUp(() {
      defaults = QuickReplyEntity.createDefaultReplies();
    });

    test('returns 6 items', () {
      expect(defaults.length, 6);
    });

    test('all items are system replies', () {
      expect(defaults.every((r) => r.isSystem), isTrue);
    });

    test('IDs follow default_{index} pattern', () {
      for (var i = 0; i < defaults.length; i++) {
        expect(defaults[i].id, 'default_$i');
      }
    });

    test('order matches index', () {
      for (var i = 0; i < defaults.length; i++) {
        expect(defaults[i].order, i);
      }
    });

    test('content matches defaultReplies list', () {
      for (var i = 0; i < defaults.length; i++) {
        expect(defaults[i].content, QuickReplyEntity.defaultReplies[i]);
      }
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson / toJson
  // ─────────────────────────────────────────────────

  group('QuickReplyEntity.fromJson / toJson', () {
    test('round-trips all fields', () {
      final t = DateTime(2025, 6, 1, 12);
      final original = QuickReplyEntity(
        id: 'r1',
        content: 'Hello',
        order: 2,
        isSystem: false,
        lastUsed: t,
        createdAt: t,
      );
      final json = original.toJson();
      final restored = QuickReplyEntity.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.content, original.content);
      expect(restored.order, original.order);
      expect(restored.isSystem, original.isSystem);
      expect(restored.lastUsed, original.lastUsed);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromJson uses defaults for missing optional fields', () {
      final reply = QuickReplyEntity.fromJson({'id': 'r2', 'content': 'Hi'});
      expect(reply.order, 0);
      expect(reply.isSystem, isFalse);
      expect(reply.lastUsed, isNull);
    });

    test('toJson includes all keys', () {
      const reply = QuickReplyEntity(id: 'r3', content: 'Bye');
      final json = reply.toJson();
      expect(json.keys, containsAll(['id', 'content', 'order', 'isSystem', 'lastUsed', 'createdAt']));
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith
  // ─────────────────────────────────────────────────

  group('QuickReplyEntity.copyWith', () {
    test('replaces content only', () {
      const original = QuickReplyEntity(id: 'r1', content: 'Old', order: 1);
      final copy = original.copyWith(content: 'New');
      expect(copy.content, 'New');
      expect(copy.id, 'r1');
      expect(copy.order, 1);
    });

    test('retains all fields when nothing changed', () {
      const original = QuickReplyEntity(id: 'r1', content: 'Hi', isSystem: true);
      final copy = original.copyWith();
      expect(copy, equals(original));
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable props
  // ─────────────────────────────────────────────────

  group('QuickReplyEntity equality', () {
    test('same id and content are equal', () {
      const a = QuickReplyEntity(id: 'r1', content: 'Hi');
      const b = QuickReplyEntity(id: 'r1', content: 'Hi');
      expect(a, equals(b));
    });

    test('different id → not equal', () {
      const a = QuickReplyEntity(id: 'r1', content: 'Hi');
      const b = QuickReplyEntity(id: 'r2', content: 'Hi');
      expect(a, isNot(equals(b)));
    });
  });
}
