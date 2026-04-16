import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';

void main() {
  group('MessageEntity Self-Destruct', () {
    final testTimestamp = DateTime(2024, 1, 1, 12, 0);

    test('should identify self-destructing message correctly', () {
      final selfDestructMessage = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'This message will self-destruct',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        selfDestructAfter: 30, // 30 seconds
      );

      final normalMessage = MessageEntity(
        id: '\$event2',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Normal message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      expect(selfDestructMessage.isSelfDestructing, isTrue);
      expect(normalMessage.isSelfDestructing, isFalse);
    });

    test('should track destruction started state', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'This message will self-destruct',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        selfDestructAfter: 30,
      );

      expect(message.isDestructionStarted, isFalse);

      final startedMessage = message.copyWith(
        destroyedAt: DateTime.now().add(const Duration(seconds: 30)),
      );

      expect(startedMessage.isDestructionStarted, isTrue);
    });

    test('should calculate remaining destruction seconds correctly', () {
      final futureDestroyTime = DateTime.now().add(const Duration(seconds: 15));

      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'This message will self-destruct',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        selfDestructAfter: 30,
        destroyedAt: futureDestroyTime,
      );

      final remaining = message.remainingDestructionSeconds;
      expect(remaining, isNotNull);
      expect(remaining, greaterThan(0));
      expect(remaining, lessThanOrEqualTo(15));
    });

    test('should return null remaining seconds for non-self-destructing message', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Normal message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      expect(message.remainingDestructionSeconds, isNull);
    });

    test('should return null remaining seconds when destruction not started', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'This message will self-destruct',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        selfDestructAfter: 30,
      );

      expect(message.remainingDestructionSeconds, isNull);
    });

    test('should detect expired message correctly', () {
      final pastDestroyTime = DateTime.now().subtract(const Duration(seconds: 5));

      final expiredMessage = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'This message has expired',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        selfDestructAfter: 30,
        destroyedAt: pastDestroyTime,
      );

      final futureDestroyTime = DateTime.now().add(const Duration(seconds: 30));
      final activeMessage = MessageEntity(
        id: '\$event2',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'This message is still active',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        selfDestructAfter: 30,
        destroyedAt: futureDestroyTime,
      );

      expect(expiredMessage.isExpired, isTrue);
      expect(activeMessage.isExpired, isFalse);
    });

    test('should not be expired when destruction not started', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'This message will self-destruct',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        selfDestructAfter: 30,
      );

      expect(message.isExpired, isFalse);
    });

    test('should start destruction correctly', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'This message will self-destruct',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        selfDestructAfter: 30,
      );

      expect(message.isDestructionStarted, isFalse);

      final startedMessage = message.startDestruction();

      expect(startedMessage.isDestructionStarted, isTrue);
      expect(startedMessage.destroyedAt, isNotNull);

      // Verify destroyedAt is approximately 30 seconds in the future
      final expectedDestroyTime = DateTime.now().add(const Duration(seconds: 30));
      final difference = startedMessage.destroyedAt!.difference(expectedDestroyTime).inSeconds.abs();
      expect(difference, lessThanOrEqualTo(1)); // Allow 1 second tolerance
    });

    test('should not restart destruction if already started', () {
      final originalDestroyTime = DateTime.now().add(const Duration(seconds: 15));
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'This message will self-destruct',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        selfDestructAfter: 30,
        destroyedAt: originalDestroyTime,
      );

      final startedAgain = message.startDestruction();

      // Should return the same message without changing destroyedAt
      expect(startedAgain.destroyedAt, equals(originalDestroyTime));
    });

    test('should return same message when calling startDestruction on non-self-destructing message', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Normal message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      final result = message.startDestruction();

      expect(result, equals(message));
      expect(result.destroyedAt, isNull);
    });

    test('should preserve selfDestructAfter and destroyedAt in props for equality', () {
      final message1 = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        selfDestructAfter: 30,
      );

      final message2 = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        selfDestructAfter: 30,
      );

      final message3 = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        selfDestructAfter: 60, // Different self-destruct time
      );

      expect(message1, equals(message2));
      expect(message1, isNot(equals(message3)));
    });

    test('should support copyWith for selfDestructAfter and destroyedAt', () {
      final original = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test',
        content: 'Original',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      final destroyTime = DateTime.now().add(const Duration(seconds: 30));
      final copy = original.copyWith(
        selfDestructAfter: 30,
        destroyedAt: destroyTime,
      );

      expect(copy.selfDestructAfter, 30);
      expect(copy.destroyedAt, destroyTime);
      expect(copy.id, '\$event1');
      expect(copy.content, 'Original');
    });
  });
}
