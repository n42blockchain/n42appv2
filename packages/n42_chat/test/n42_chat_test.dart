import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/n42_chat.dart';

void main() {
  group('N42Chat', () {
    test('should not be initialized by default', () {
      expect(N42Chat.isInitialized, isFalse);
    });

    test('should return Widget when accessing chatWidget before initialization', () {
      // chatWidget returns a fallback widget instead of throwing
      final widget = N42Chat.chatWidget();
      expect(widget, isA<Widget>());
    });

    test('should throw when accessing routes before initialization', () {
      expect(
        () => N42Chat.routes(),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('N42ChatConfig', () {
    test('should have default values', () {
      const config = N42ChatConfig();

      expect(config.defaultHomeserver, equals('https://m.si46.world'));
      expect(config.enableEncryption, isTrue);
      expect(config.enablePushNotifications, isTrue);
      expect(config.syncTimeout, equals(const Duration(seconds: 30)));
    });

    test('should support copyWith', () {
      const config = N42ChatConfig();
      final newConfig = config.copyWith(
        defaultHomeserver: 'https://custom.server',
        enableEncryption: false,
      );

      expect(newConfig.defaultHomeserver, equals('https://custom.server'));
      expect(newConfig.enableEncryption, isFalse);
      expect(newConfig.enablePushNotifications, isTrue); // unchanged
    });
  });

  group('N42ChatTheme', () {
    test('wechatLight should have correct primary color', () {
      final theme = N42ChatTheme.wechatLight();

      expect(theme.primaryColor, equals(const Color(0xFF07C160)));
      expect(theme.isDark, isFalse);
    });

    test('wechatDark should have correct dark mode', () {
      final theme = N42ChatTheme.wechatDark();

      expect(theme.primaryColor, equals(const Color(0xFF07C160)));
      expect(theme.isDark, isTrue);
    });

    test('should convert to ThemeData', () {
      final theme = N42ChatTheme.wechatLight();
      final themeData = theme.toThemeData();

      expect(themeData.primaryColor, equals(const Color(0xFF07C160)));
      expect(themeData.brightness, equals(Brightness.light));
    });
  });

  group('Entities', () {
    test('ConversationEntity should calculate properties correctly', () {
      const conversation = ConversationEntity(
        id: '!room:matrix.org',
        name: 'Test Room',
        unreadCount: 150,
        type: ConversationType.group,
      );

      expect(conversation.isGroup, isTrue);
      expect(conversation.isDirect, isFalse);
      expect(conversation.hasUnread, isTrue);
      expect(conversation.displayUnreadCount, equals('99+'));
      expect(conversation.initials, equals('TR'));
    });

    test('MessageEntity should identify types correctly', () {
      final textMessage = MessageEntity(
        id: 'msg1',
        roomId: '!room:matrix.org',
        senderId: '@user:matrix.org',
        senderName: 'User',
        content: 'Hello',
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      expect(textMessage.isText, isTrue);
      expect(textMessage.isMedia, isFalse);
      expect(textMessage.isSystemMessage, isFalse);
    });

    test('ContactEntity should format display name correctly', () {
      const contact = ContactEntity(
        userId: '@john:matrix.org',
        displayName: 'John Doe',
        remark: 'Johnny',
      );

      expect(contact.username, equals('john'));
      expect(contact.server, equals('matrix.org'));
      expect(contact.effectiveDisplayName, equals('Johnny')); // remark优先
    });
  });
}


