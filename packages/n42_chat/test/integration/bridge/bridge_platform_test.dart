import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/n42_chat.dart';

void main() {
  group('BridgePlatform enum', () {
    test('should have 16 platforms', () {
      expect(BridgePlatform.values.length, 16);
    });

    test('should include all expected platforms', () {
      expect(BridgePlatform.values, containsAll([
        BridgePlatform.discord,
        BridgePlatform.messenger,
        BridgePlatform.instagram,
        BridgePlatform.twitter,
        BridgePlatform.linkedin,
        BridgePlatform.whatsapp,
        BridgePlatform.signal,
        BridgePlatform.googleMessages,
        BridgePlatform.googleVoice,
        BridgePlatform.slack,
        BridgePlatform.bluesky,
        BridgePlatform.irc,
        BridgePlatform.zulip,
        BridgePlatform.telegram,
        BridgePlatform.imessage,
        BridgePlatform.googleChat,
      ]));
    });
  });

  group('BridgePlatformInfo', () {
    test('should have info for every platform', () {
      for (final platform in BridgePlatform.values) {
        final info = BridgePlatformRegistry.getInfo(platform);
        expect(info, isNotNull);
        expect(info.platform, platform);
      }
    });

    test('each platform should have non-empty display name', () {
      for (final platform in BridgePlatform.values) {
        final info = BridgePlatformRegistry.getInfo(platform);
        expect(info.displayName, isNotEmpty);
      }
    });

    test('each platform should have a bot username', () {
      for (final platform in BridgePlatform.values) {
        final info = BridgePlatformRegistry.getInfo(platform);
        expect(info.botUsername, isNotEmpty);
        expect(info.botUsername, isNot(contains('@')));
        expect(info.botUsername, isNot(contains(':')));
      }
    });

    test('each platform should have a repo name', () {
      for (final platform in BridgePlatform.values) {
        final info = BridgePlatformRegistry.getInfo(platform);
        expect(info.repoName, isNotEmpty);
      }
    });

    test('each platform should have at least one auth method', () {
      for (final platform in BridgePlatform.values) {
        final info = BridgePlatformRegistry.getInfo(platform);
        expect(info.authMethods, isNotEmpty);
      }
    });

    test('botUserId should format correctly', () {
      final info = BridgePlatformRegistry.getInfo(BridgePlatform.discord);
      expect(info.botUserId('matrix.org'), '@discordbot:matrix.org');
    });

    test('brand colors should be valid', () {
      for (final platform in BridgePlatform.values) {
        final info = BridgePlatformRegistry.getInfo(platform);
        expect(info.brandColor, isA<Color>());
      }
    });

    test('ghostPrefix should be set for deployed bridges', () {
      final deployed = [
        BridgePlatform.whatsapp,
        BridgePlatform.messenger,
        BridgePlatform.instagram,
        BridgePlatform.telegram,
        BridgePlatform.discord,
        BridgePlatform.signal,
      ];
      for (final p in deployed) {
        final info = BridgePlatformRegistry.getInfo(p);
        expect(info.ghostPrefix, isNotEmpty,
            reason: '${info.displayName} should have a ghostPrefix');
      }
    });
  });

  group('BridgePlatformRegistry', () {
    test('allPlatforms should return 16 platforms', () {
      expect(BridgePlatformRegistry.allPlatforms.length, 16);
    });

    test('activePlatforms should exclude low-maintenance bridges', () {
      final active = BridgePlatformRegistry.activePlatforms;
      expect(active.length, 14); // 16 - 2 inactive (iMessage, Google Chat)
      expect(active.every((p) => p.isActive), isTrue);
    });

    test('groupedByStatus should separate active and inactive', () {
      final grouped = BridgePlatformRegistry.groupedByStatus;
      expect(grouped[true]?.length, 14); // Active
      expect(grouped[false]?.length, 2); // iMessage, Google Chat
    });

    test('findByBotUsername should find existing bot', () {
      final info = BridgePlatformRegistry.findByBotUsername('discordbot');
      expect(info, isNotNull);
      expect(info!.platform, BridgePlatform.discord);
    });

    test('findByBotUsername should return null for unknown bot', () {
      final info = BridgePlatformRegistry.findByBotUsername('unknownbot');
      expect(info, isNull);
    });

    test('bot usernames should be unique', () {
      final usernames = <String>{};
      for (final info in BridgePlatformRegistry.allPlatforms) {
        expect(usernames.add(info.botUsername), isTrue,
            reason: '${info.botUsername} is duplicated');
      }
    });

    test('findByBotUsername should find messenger and instagram separately', () {
      final messenger = BridgePlatformRegistry.findByBotUsername('messengerbot');
      expect(messenger, isNotNull);
      expect(messenger!.platform, BridgePlatform.messenger);

      final instagram = BridgePlatformRegistry.findByBotUsername('instagrambot');
      expect(instagram, isNotNull);
      expect(instagram!.platform, BridgePlatform.instagram);
    });
  });

  group('BridgeAuthMethod', () {
    test('should have expected values', () {
      expect(BridgeAuthMethod.values, containsAll([
        BridgeAuthMethod.qrCode,
        BridgeAuthMethod.emailPassword,
        BridgeAuthMethod.phoneVerification,
        BridgeAuthMethod.oauth,
        BridgeAuthMethod.apiToken,
        BridgeAuthMethod.usernamePassword,
        BridgeAuthMethod.none,
      ]));
    });
  });

  group('Platform-specific checks', () {
    test('Discord should support relay mode', () {
      final info = BridgePlatformRegistry.getInfo(BridgePlatform.discord);
      expect(info.supportsRelay, isTrue);
    });

    test('Twitter should not support groups', () {
      final info = BridgePlatformRegistry.getInfo(BridgePlatform.twitter);
      expect(info.supportsGroups, isFalse);
    });

    test('WhatsApp should use QR code auth', () {
      final info = BridgePlatformRegistry.getInfo(BridgePlatform.whatsapp);
      expect(info.authMethods, contains(BridgeAuthMethod.qrCode));
    });

    test('Telegram should be active', () {
      final info = BridgePlatformRegistry.getInfo(BridgePlatform.telegram);
      expect(info.isActive, isTrue);
    });

    test('IRC should support no-auth login', () {
      final info = BridgePlatformRegistry.getInfo(BridgePlatform.irc);
      expect(info.authMethods, contains(BridgeAuthMethod.none));
    });

    test('Messenger and Instagram should have independent bot usernames', () {
      final messenger = BridgePlatformRegistry.getInfo(BridgePlatform.messenger);
      final instagram = BridgePlatformRegistry.getInfo(BridgePlatform.instagram);
      expect(messenger.botUsername, 'messengerbot');
      expect(instagram.botUsername, 'instagrambot');
      expect(messenger.botUsername, isNot(instagram.botUsername));
    });
  });

  group('BridgeDetectionUtils', () {
    test('should detect WhatsApp from ghost MXID', () {
      final result = BridgeDetectionUtils.detectFromUserId(
          '@whatsapp_1234567890:m.si46.world');
      expect(result, BridgePlatform.whatsapp);
    });

    test('should detect Messenger from ghost MXID', () {
      final result = BridgeDetectionUtils.detectFromUserId(
          '@messenger_john:m.si46.world');
      expect(result, BridgePlatform.messenger);
    });

    test('should detect Instagram from ghost MXID', () {
      final result = BridgeDetectionUtils.detectFromUserId(
          '@instagram_user42:m.si46.world');
      expect(result, BridgePlatform.instagram);
    });

    test('should detect Telegram from ghost MXID', () {
      final result = BridgeDetectionUtils.detectFromUserId(
          '@telegram_9876:m.si46.world');
      expect(result, BridgePlatform.telegram);
    });

    test('should return null for non-bridged user', () {
      final result = BridgeDetectionUtils.detectFromUserId(
          '@alice:m.si46.world');
      expect(result, isNull);
    });

    test('should detect from conversation directUserId', () {
      const conv = ConversationEntity(
        id: '!room:server',
        name: 'Test',
        directUserId: '@whatsapp_123:server',
      );
      final result = BridgeDetectionUtils.detectFromConversation(conv);
      expect(result, BridgePlatform.whatsapp);
    });

    test('should detect from conversation memberIds', () {
      const conv = ConversationEntity(
        id: '!room:server',
        name: 'Group',
        type: ConversationType.group,
        memberIds: ['@alice:server', '@telegram_456:server'],
      );
      final result = BridgeDetectionUtils.detectFromConversation(conv);
      expect(result, BridgePlatform.telegram);
    });

    test('should return null for non-bridged conversation', () {
      const conv = ConversationEntity(
        id: '!room:server',
        name: 'Normal Chat',
        directUserId: '@bob:server',
      );
      final result = BridgeDetectionUtils.detectFromConversation(conv);
      expect(result, isNull);
    });
  });
}
