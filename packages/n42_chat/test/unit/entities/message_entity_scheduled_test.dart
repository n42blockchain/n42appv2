import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';

void main() {
  group('MessageEntity Scheduled Messages', () {
    final testTimestamp = DateTime(2024, 1, 1, 12, 0);

    test('should identify scheduled message correctly', () {
      final scheduledMessage = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Scheduled message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sending,
        scheduledAt: testTimestamp.add(const Duration(hours: 1)),
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

      expect(scheduledMessage.isScheduled, isTrue);
      expect(scheduledMessage.scheduledAt, isNotNull);
      expect(normalMessage.isScheduled, isFalse);
      expect(normalMessage.scheduledAt, isNull);
    });

    test('should detect when scheduled time is reached', () {
      final pastSchedule = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Past scheduled message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sending,
        scheduledAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final futureSchedule = MessageEntity(
        id: '\$event2',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Future scheduled message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sending,
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(pastSchedule.isScheduledTimeReached, isTrue);
      expect(futureSchedule.isScheduledTimeReached, isFalse);
    });

    test('should calculate remaining scheduled seconds correctly', () {
      final futureSchedule = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Future scheduled message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sending,
        scheduledAt: DateTime.now().add(const Duration(minutes: 30)),
      );

      final remaining = futureSchedule.remainingScheduledSeconds;
      expect(remaining, isNotNull);
      expect(remaining! > 1700, isTrue); // ~30 minutes in seconds
      expect(remaining < 1900, isTrue);
    });

    test('should return null remaining seconds for non-scheduled message', () {
      final normalMessage = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Normal message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      expect(normalMessage.remainingScheduledSeconds, isNull);
    });

    test('should return 0 remaining seconds when time has passed', () {
      final pastSchedule = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Past scheduled message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sending,
        scheduledAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      expect(pastSchedule.remainingScheduledSeconds, 0);
    });

    test('should preserve scheduledAt in copyWith', () {
      final futureTime = DateTime.now().add(const Duration(hours: 2));
      final original = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Scheduled message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sending,
        scheduledAt: futureTime,
      );

      final copy = original.copyWith(content: 'Updated content');

      expect(copy.scheduledAt, futureTime);
      expect(copy.content, 'Updated content');
      expect(copy.isScheduled, isTrue);
    });

    test('should update scheduledAt with copyWith', () {
      final original = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      final newScheduleTime = DateTime.now().add(const Duration(hours: 3));
      final updated = original.copyWith(scheduledAt: newScheduleTime);

      expect(original.isScheduled, isFalse);
      expect(updated.isScheduled, isTrue);
      expect(updated.scheduledAt, newScheduleTime);
    });

    test('should include scheduledAt in props for equality', () {
      final scheduleTime = DateTime.now().add(const Duration(hours: 1));

      final message1 = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Scheduled message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sending,
        scheduledAt: scheduleTime,
      );

      final message2 = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Scheduled message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sending,
        scheduledAt: scheduleTime,
      );

      final message3 = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Scheduled message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sending,
        scheduledAt: scheduleTime.add(const Duration(hours: 1)),
      );

      expect(message1, equals(message2));
      expect(message1, isNot(equals(message3)));
    });

    test('should work with self-destruct combined', () {
      final combinedMessage = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Scheduled self-destruct message',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sending,
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        selfDestructAfter: 30,
      );

      expect(combinedMessage.isScheduled, isTrue);
      expect(combinedMessage.isSelfDestructing, isTrue);
      expect(combinedMessage.selfDestructAfter, 30);
    });

    test('should work with mentions combined', () {
      final combinedMessage = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: '@all Scheduled announcement',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sending,
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        mentionsRoom: true,
        mentionedUserIds: ['@alice:server.com'],
      );

      expect(combinedMessage.isScheduled, isTrue);
      expect(combinedMessage.hasMentions, isTrue);
      expect(combinedMessage.mentionsRoom, isTrue);
      expect(combinedMessage.mentionedUserIds, ['@alice:server.com']);
    });
  });
}
