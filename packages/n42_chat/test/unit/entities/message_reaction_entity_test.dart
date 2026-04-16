import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_reaction_entity.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Construction
  // ─────────────────────────────────────────────────

  group('MessageReactionEntity construction', () {
    test('creates with emoji only — empty user lists', () {
      const reaction = MessageReactionEntity(emoji: '👍');
      expect(reaction.emoji, '👍');
      expect(reaction.userIds, isEmpty);
      expect(reaction.userNames, isEmpty);
    });

    test('creates with user lists', () {
      const reaction = MessageReactionEntity(
        emoji: '❤️',
        userIds: ['@alice:s', '@bob:s'],
        userNames: ['Alice', 'Bob'],
      );
      expect(reaction.userIds.length, 2);
      expect(reaction.userNames.length, 2);
    });
  });

  // ─────────────────────────────────────────────────
  // count getter
  // ─────────────────────────────────────────────────

  group('MessageReactionEntity.count', () {
    test('returns userIds.length', () {
      const reaction = MessageReactionEntity(
        emoji: '😄',
        userIds: ['@a:s', '@b:s', '@c:s'],
        userNames: ['A', 'B', 'C'],
      );
      expect(reaction.count, 3);
    });

    test('returns 0 for empty reaction', () {
      const reaction = MessageReactionEntity(emoji: '😮');
      expect(reaction.count, 0);
    });
  });

  // ─────────────────────────────────────────────────
  // hasReacted
  // ─────────────────────────────────────────────────

  group('MessageReactionEntity.hasReacted', () {
    const reaction = MessageReactionEntity(
      emoji: '👍',
      userIds: ['@alice:s'],
      userNames: ['Alice'],
    );

    test('returns true when user has reacted', () {
      expect(reaction.hasReacted('@alice:s'), isTrue);
    });

    test('returns false when user has not reacted', () {
      expect(reaction.hasReacted('@bob:s'), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // displayUsers
  // ─────────────────────────────────────────────────

  group('MessageReactionEntity.displayUsers', () {
    test('returns empty string when no users', () {
      const reaction = MessageReactionEntity(emoji: '👍');
      expect(reaction.displayUsers, '');
    });

    test('joins names with 、 when <= 3 users', () {
      const reaction = MessageReactionEntity(
        emoji: '👍',
        userIds: ['@a:s', '@b:s'],
        userNames: ['Alice', 'Bob'],
      );
      expect(reaction.displayUsers, 'Alice、Bob');
    });

    test('shows first 3 + count when > 3 users', () {
      const reaction = MessageReactionEntity(
        emoji: '👍',
        userIds: ['@a:s', '@b:s', '@c:s', '@d:s'],
        userNames: ['Alice', 'Bob', 'Carol', 'Dave'],
      );
      expect(reaction.displayUsers, contains('Alice'));
      expect(reaction.displayUsers, contains('等4人'));
    });
  });

  // ─────────────────────────────────────────────────
  // addUser
  // ─────────────────────────────────────────────────

  group('MessageReactionEntity.addUser', () {
    test('adds new user to lists', () {
      const reaction = MessageReactionEntity(emoji: '👍');
      final updated = reaction.addUser('@alice:s', 'Alice');
      expect(updated.userIds, contains('@alice:s'));
      expect(updated.userNames, contains('Alice'));
      expect(updated.count, 1);
    });

    test('is idempotent — does not add duplicate', () {
      const reaction = MessageReactionEntity(
        emoji: '👍',
        userIds: ['@alice:s'],
        userNames: ['Alice'],
      );
      final updated = reaction.addUser('@alice:s', 'Alice');
      expect(identical(updated, reaction), isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // removeUser
  // ─────────────────────────────────────────────────

  group('MessageReactionEntity.removeUser', () {
    test('removes existing user', () {
      const reaction = MessageReactionEntity(
        emoji: '👍',
        userIds: ['@alice:s', '@bob:s'],
        userNames: ['Alice', 'Bob'],
      );
      final updated = reaction.removeUser('@alice:s');
      expect(updated.userIds, isNot(contains('@alice:s')));
      expect(updated.count, 1);
    });

    test('is no-op when user not found', () {
      const reaction = MessageReactionEntity(
        emoji: '👍',
        userIds: ['@alice:s'],
        userNames: ['Alice'],
      );
      final updated = reaction.removeUser('@unknown:s');
      expect(identical(updated, reaction), isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable props
  // ─────────────────────────────────────────────────

  group('MessageReactionEntity equality', () {
    test('same emoji and userIds are equal', () {
      const a = MessageReactionEntity(
        emoji: '👍',
        userIds: ['@alice:s'],
        userNames: ['Alice'],
      );
      const b = MessageReactionEntity(
        emoji: '👍',
        userIds: ['@alice:s'],
        userNames: ['Alice'],
      );
      expect(a, equals(b));
    });

    test('different emoji → not equal', () {
      const a = MessageReactionEntity(emoji: '👍');
      const b = MessageReactionEntity(emoji: '❤️');
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // CommonEmojis
  // ─────────────────────────────────────────────────

  group('CommonEmojis', () {
    test('reactions list has 9 entries', () {
      expect(CommonEmojis.reactions.length, 9);
    });

    test('extendedReactions list has 32 entries', () {
      expect(CommonEmojis.extendedReactions.length, 32);
    });

    test('reactions contains 👍', () {
      expect(CommonEmojis.reactions, contains('👍'));
    });
  });
}
