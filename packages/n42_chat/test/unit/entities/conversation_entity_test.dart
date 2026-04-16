import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/conversation_entity.dart';

void main() {
  group('ConversationEntity', () {
    test('should create with required parameters', () {
      const conversation = ConversationEntity(
        id: '!room:server.com',
        name: 'Test Room',
      );

      expect(conversation.id, '!room:server.com');
      expect(conversation.name, 'Test Room');
      expect(conversation.unreadCount, 0);
      expect(conversation.type, ConversationType.direct);
    });

    test('should identify direct chat correctly', () {
      const conversation = ConversationEntity(
        id: '!room:server.com',
        name: 'Direct Chat',
        type: ConversationType.direct,
      );

      expect(conversation.isDirect, isTrue);
      expect(conversation.isGroup, isFalse);
    });

    test('should identify group chat correctly', () {
      const conversation = ConversationEntity(
        id: '!room:server.com',
        name: 'Group Chat',
        type: ConversationType.group,
      );

      expect(conversation.isDirect, isFalse);
      expect(conversation.isGroup, isTrue);
    });

    test('should calculate hasUnread correctly', () {
      const conversationWithUnread = ConversationEntity(
        id: '!room:server.com',
        name: 'Test',
        unreadCount: 5,
      );

      const conversationWithoutUnread = ConversationEntity(
        id: '!room:server.com',
        name: 'Test',
        unreadCount: 0,
      );

      const mutedConversation = ConversationEntity(
        id: '!room:server.com',
        name: 'Test',
        unreadCount: 5,
        isMuted: true,
      );

      expect(conversationWithUnread.hasUnread, isTrue);
      expect(conversationWithoutUnread.hasUnread, isFalse);
      expect(mutedConversation.hasUnread, isFalse);
    });

    test('should format displayUnreadCount correctly', () {
      const lowCount = ConversationEntity(
        id: '!room:server.com',
        name: 'Test',
        unreadCount: 5,
      );

      const highCount = ConversationEntity(
        id: '!room:server.com',
        name: 'Test',
        unreadCount: 150,
      );

      const zeroCount = ConversationEntity(
        id: '!room:server.com',
        name: 'Test',
        unreadCount: 0,
      );

      expect(lowCount.displayUnreadCount, '5');
      expect(highCount.displayUnreadCount, '99+');
      expect(zeroCount.displayUnreadCount, '');
    });

    test('should generate initials correctly', () {
      const singleWord = ConversationEntity(
        id: '!room:server.com',
        name: 'Alice',
      );

      const twoWords = ConversationEntity(
        id: '!room:server.com',
        name: 'Alice Bob',
      );

      const empty = ConversationEntity(
        id: '!room:server.com',
        name: '',
      );

      expect(singleWord.initials, 'AL');
      expect(twoWords.initials, 'AB');
      expect(empty.initials, '?');
    });

    test('should format lastMessagePreview correctly', () {
      const withMessage = ConversationEntity(
        id: '!room:server.com',
        name: 'Test',
        lastMessage: 'Hello world',
      );

      const withDraft = ConversationEntity(
        id: '!room:server.com',
        name: 'Test',
        lastMessage: 'Hello',
        draft: 'Draft message',
      );

      const groupWithSender = ConversationEntity(
        id: '!room:server.com',
        name: 'Test',
        type: ConversationType.group,
        lastMessage: 'Hello',
        lastMessageSenderName: 'Alice',
      );

      const withTyping = ConversationEntity(
        id: '!room:server.com',
        name: 'Test',
        hasTypingUsers: true,
        typingUsers: ['Alice'],
      );

      expect(withMessage.lastMessagePreview, 'Hello world');
      expect(withDraft.lastMessagePreview, '[Draft] Draft message');
      expect(groupWithSender.lastMessagePreview, 'Alice: Hello');
      expect(withTyping.lastMessagePreview, 'Alice is typing...');
    });

    test('should support copyWith', () {
      const original = ConversationEntity(
        id: '!room:server.com',
        name: 'Original',
        unreadCount: 5,
      );

      final copy = original.copyWith(
        name: 'Modified',
        unreadCount: 10,
      );

      expect(copy.id, '!room:server.com');
      expect(copy.name, 'Modified');
      expect(copy.unreadCount, 10);
    });

    test('should be equal with same properties', () {
      const conversation1 = ConversationEntity(
        id: '!room:server.com',
        name: 'Test',
      );

      const conversation2 = ConversationEntity(
        id: '!room:server.com',
        name: 'Test',
      );

      expect(conversation1, equals(conversation2));
    });
  });
}

