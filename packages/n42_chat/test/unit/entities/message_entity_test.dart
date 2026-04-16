import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';

void main() {
  group('MessageEntity', () {
    final testTimestamp = DateTime(2024, 1, 1, 12, 0);

    test('should create with required parameters', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      expect(message.id, '\$event1');
      expect(message.roomId, '!room:server.com');
      expect(message.senderId, '@user:server.com');
      expect(message.content, 'Hello');
      expect(message.type, MessageType.text);
    });

    test('should identify text message correctly', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      expect(message.isText, isTrue);
      expect(message.type == MessageType.image, isFalse);
      expect(message.isMedia, isFalse);
    });

    test('should identify image message correctly', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test',
        content: 'image.jpg',
        timestamp: testTimestamp,
        type: MessageType.image,
        status: MessageStatus.sent,
      );

      expect(message.isText, isFalse);
      expect(message.type == MessageType.image, isTrue);
      expect(message.isMedia, isTrue);
    });

    test('should identify video message correctly', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test',
        content: 'video.mp4',
        timestamp: testTimestamp,
        type: MessageType.video,
        status: MessageStatus.sent,
      );

      expect(message.type == MessageType.video, isTrue);
      expect(message.isMedia, isTrue);
    });

    test('should identify audio message correctly', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test',
        content: 'audio.m4a',
        timestamp: testTimestamp,
        type: MessageType.voice,
        status: MessageStatus.sent,
      );

      expect(message.type == MessageType.voice, isTrue);
      expect(message.isMedia, isTrue);
    });

    test('should identify file message correctly', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test',
        content: 'document.pdf',
        timestamp: testTimestamp,
        type: MessageType.file,
        status: MessageStatus.sent,
      );

      expect(message.type == MessageType.file, isTrue);
      expect(message.isMedia, isFalse);
    });

    test('should identify system message correctly', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test',
        content: 'User joined',
        timestamp: testTimestamp,
        type: MessageType.system,
        status: MessageStatus.sent,
      );

      expect(message.isSystemMessage, isTrue);
    });

    test('should check message status correctly', () {
      final sendingMessage = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sending,
      );

      final sentMessage = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      final failedMessage = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.failed,
      );

      expect(sendingMessage.isSending, isTrue);
      expect(sentMessage.status == MessageStatus.sent, isTrue);
      expect(failedMessage.isFailed, isTrue);
    });

    test('should support copyWith', () {
      final original = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test',
        content: 'Original',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sending,
      );

      final copy = original.copyWith(
        content: 'Modified',
        status: MessageStatus.sent,
      );

      expect(copy.id, '\$event1');
      expect(copy.content, 'Modified');
      expect(copy.status, MessageStatus.sent);
    });

    test('should be equal with same properties', () {
      final message1 = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      final message2 = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      expect(message1, equals(message2));
    });

    test('should generate sender initials correctly', () {
      final singleName = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Alice',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      final fullName = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Alice Bob',
        content: 'Hello',
        timestamp: testTimestamp,
        type: MessageType.text,
        status: MessageStatus.sent,
      );

      expect(singleName.senderInitials, 'AL');
      expect(fullName.senderInitials, 'AB');
    });
  });
}
