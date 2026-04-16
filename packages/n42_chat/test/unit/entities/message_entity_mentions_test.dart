import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';

void main() {
  group('MessageEntity Mentions', () {
    final testTimestamp = DateTime(2024, 1, 1, 12, 0);

    test('should identify message that mentions room (@all)', () {
      final mentionAllMessage = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: '@all Important announcement',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        mentionsRoom: true,
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

      expect(mentionAllMessage.mentionsRoom, isTrue);
      expect(mentionAllMessage.hasMentions, isTrue);
      expect(normalMessage.mentionsRoom, isFalse);
      expect(normalMessage.hasMentions, isFalse);
    });

    test('should identify message that mentions specific users', () {
      final mentionUsersMessage = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@sender:server.com',
        senderName: 'Sender',
        content: '@alice @bob Hello!',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        mentionedUserIds: ['@alice:server.com', '@bob:server.com'],
      );

      expect(mentionUsersMessage.mentionedUserIds.length, 2);
      expect(mentionUsersMessage.hasMentions, isTrue);
      expect(mentionUsersMessage.mentionsUser('@alice:server.com'), isTrue);
      expect(mentionUsersMessage.mentionsUser('@bob:server.com'), isTrue);
      expect(mentionUsersMessage.mentionsUser('@charlie:server.com'), isFalse);
    });

    test('should handle combined room and user mentions', () {
      final combinedMessage = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@sender:server.com',
        senderName: 'Sender',
        content: '@all @alice Important!',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        mentionsRoom: true,
        mentionedUserIds: ['@alice:server.com'],
      );

      expect(combinedMessage.mentionsRoom, isTrue);
      expect(combinedMessage.mentionedUserIds.length, 1);
      expect(combinedMessage.hasMentions, isTrue);
      expect(combinedMessage.mentionsUser('@alice:server.com'), isTrue);
    });

    test('should return false for mentionsUser when user list is empty', () {
      final noMentionsMessage = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@sender:server.com',
        senderName: 'Sender',
        content: 'Hello everyone',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      expect(noMentionsMessage.mentionsUser('@anyone:server.com'), isFalse);
      expect(noMentionsMessage.mentionedUserIds.isEmpty, isTrue);
    });

    test('should preserve mentions in copyWith', () {
      final original = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@sender:server.com',
        senderName: 'Sender',
        content: '@all Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        mentionsRoom: true,
        mentionedUserIds: ['@alice:server.com'],
      );

      final copy = original.copyWith(content: 'Updated content');

      expect(copy.mentionsRoom, isTrue);
      expect(copy.mentionedUserIds, ['@alice:server.com']);
      expect(copy.content, 'Updated content');
    });

    test('should update mentions with copyWith', () {
      final original = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@sender:server.com',
        senderName: 'Sender',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      final updated = original.copyWith(
        mentionsRoom: true,
        mentionedUserIds: ['@bob:server.com'],
      );

      expect(original.mentionsRoom, isFalse);
      expect(original.mentionedUserIds.isEmpty, isTrue);
      expect(updated.mentionsRoom, isTrue);
      expect(updated.mentionedUserIds, ['@bob:server.com']);
    });

    test('should include mentions in props for equality', () {
      final message1 = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@sender:server.com',
        senderName: 'Sender',
        content: '@all Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        mentionsRoom: true,
      );

      final message2 = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@sender:server.com',
        senderName: 'Sender',
        content: '@all Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        mentionsRoom: true,
      );

      final message3 = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@sender:server.com',
        senderName: 'Sender',
        content: '@all Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        mentionsRoom: false, // Different
      );

      expect(message1, equals(message2));
      expect(message1, isNot(equals(message3)));
    });

    test('should detect hasMentions correctly for different scenarios', () {
      // No mentions
      final noMentions = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@sender:server.com',
        senderName: 'Sender',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      // Only room mention
      final roomMention = MessageEntity(
        id: '\$event2',
        roomId: '!room:server.com',
        senderId: '@sender:server.com',
        senderName: 'Sender',
        content: '@all Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        mentionsRoom: true,
      );

      // Only user mentions
      final userMentions = MessageEntity(
        id: '\$event3',
        roomId: '!room:server.com',
        senderId: '@sender:server.com',
        senderName: 'Sender',
        content: '@alice Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        mentionedUserIds: ['@alice:server.com'],
      );

      // Both room and user mentions
      final bothMentions = MessageEntity(
        id: '\$event4',
        roomId: '!room:server.com',
        senderId: '@sender:server.com',
        senderName: 'Sender',
        content: '@all @alice Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
        mentionsRoom: true,
        mentionedUserIds: ['@alice:server.com'],
      );

      expect(noMentions.hasMentions, isFalse);
      expect(roomMention.hasMentions, isTrue);
      expect(userMentions.hasMentions, isTrue);
      expect(bothMentions.hasMentions, isTrue);
    });
  });
}
