import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/user_profile_entity.dart';

void main() {
  late PreferencesDataSource dataSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dataSource = PreferencesDataSource();
  });

  // ============================================
  // 1. 外观设置
  // ============================================
  group('Appearance Settings', () {
    test('should save and retrieve appearance settings', () async {
      await dataSource.saveAppearanceSettings(
        themeMode: 'dark',
        fontSize: 'large',
        chatBackground: '/images/bg.png',
        bubbleStyle: 'wechat',
      );

      final result = await dataSource.getAppearanceSettings();

      expect(result, isNotNull);
      expect(result!['themeMode'], equals('dark'));
      expect(result['fontSize'], equals('large'));
      expect(result['chatBackground'], equals('/images/bg.png'));
      expect(result['bubbleStyle'], equals('wechat'));
    });

    test('should return null when no appearance settings saved', () async {
      final result = await dataSource.getAppearanceSettings();
      expect(result, isNull);
    });

    test('should save appearance settings with null chatBackground', () async {
      await dataSource.saveAppearanceSettings(
        themeMode: 'light',
        fontSize: 'medium',
        chatBackground: null,
        bubbleStyle: 'telegram',
      );

      final result = await dataSource.getAppearanceSettings();

      expect(result, isNotNull);
      expect(result!['chatBackground'], isNull);
    });

    test('should overwrite previous appearance settings', () async {
      await dataSource.saveAppearanceSettings(
        themeMode: 'dark',
        fontSize: 'large',
        bubbleStyle: 'wechat',
      );
      await dataSource.saveAppearanceSettings(
        themeMode: 'light',
        fontSize: 'small',
        bubbleStyle: 'telegram',
      );

      final result = await dataSource.getAppearanceSettings();

      expect(result!['themeMode'], equals('light'));
      expect(result['fontSize'], equals('small'));
      expect(result['bubbleStyle'], equals('telegram'));
    });

    group('Theme Mode', () {
      test('should save and retrieve theme mode', () async {
        await dataSource.saveThemeMode('dark');

        final result = await dataSource.getThemeMode();
        expect(result, equals('dark'));
      });

      test('should return null when no theme mode saved', () async {
        final result = await dataSource.getThemeMode();
        expect(result, isNull);
      });

      test('should preserve other settings when saving theme mode', () async {
        await dataSource.saveAppearanceSettings(
          themeMode: 'light',
          fontSize: 'large',
          chatBackground: '/bg.png',
          bubbleStyle: 'wechat',
        );

        await dataSource.saveThemeMode('dark');

        final result = await dataSource.getAppearanceSettings();
        expect(result!['themeMode'], equals('dark'));
        expect(result['fontSize'], equals('large'));
        expect(result['chatBackground'], equals('/bg.png'));
        expect(result['bubbleStyle'], equals('wechat'));
      });

      test(
        'should use defaults for missing fields when saving theme mode alone',
        () async {
          await dataSource.saveThemeMode('system');

          final result = await dataSource.getAppearanceSettings();
          expect(result!['themeMode'], equals('system'));
          expect(result['fontSize'], equals('medium'));
          expect(result['bubbleStyle'], equals('wechat'));
        },
      );
    });

    test('should save and retrieve appearance settings model', () async {
      const settings = AppearanceSettings(
        themeMode: ThemeMode.dark,
        fontSize: FontSize.extraLarge,
        chatBackground: '/images/chat-bg.png',
        bubbleStyle: BubbleStyle.classic,
      );

      await dataSource.saveAppearanceSettingsModel(settings);
      final restored = await dataSource.getAppearanceSettingsModel();

      expect(restored, equals(settings));
    });
  });

  group('Notification Settings', () {
    test(
      'should return defaults when no notification settings are saved',
      () async {
        final settings = await dataSource.getNotificationSettingsModel();

        expect(settings, equals(const NotificationSettings()));
      },
    );

    test('should save and retrieve notification settings model', () async {
      const settings = NotificationSettings(
        enabled: false,
        showPreview: false,
        playSound: false,
        vibrate: true,
        doNotDisturb: true,
        doNotDisturbStart: '22:30',
        doNotDisturbEnd: '07:15',
        privacyMode: NotificationPrivacyMode.senderOnly,
      );

      await dataSource.saveNotificationSettingsModel(settings);
      final restored = await dataSource.getNotificationSettingsModel();

      expect(restored, equals(settings));
    });
  });

  // ============================================
  // 2. 联系人备注
  // ============================================
  group('Contact Remarks', () {
    test('should set and get contact remark', () async {
      await dataSource.setContactRemark('@alice:server.com', '好友小明');

      final result = await dataSource.getContactRemark('@alice:server.com');
      expect(result, equals('好友小明'));
    });

    test('should return null for non-existent contact remark', () async {
      final result = await dataSource.getContactRemark('@unknown:server.com');
      expect(result, isNull);
    });

    test('should get all contact remarks', () async {
      await dataSource.setContactRemark('@alice:server.com', '小明');
      await dataSource.setContactRemark('@bob:server.com', '小红');

      final remarks = await dataSource.getContactRemarks();

      expect(remarks.length, equals(2));
      expect(remarks['@alice:server.com'], equals('小明'));
      expect(remarks['@bob:server.com'], equals('小红'));
    });

    test('should return empty map when no remarks saved', () async {
      final remarks = await dataSource.getContactRemarks();
      expect(remarks, isEmpty);
    });

    test(
      'should remove contact remark via setContactRemark with null',
      () async {
        await dataSource.setContactRemark('@alice:server.com', '小明');
        await dataSource.setContactRemark('@alice:server.com', null);

        final result = await dataSource.getContactRemark('@alice:server.com');
        expect(result, isNull);
      },
    );

    test(
      'should remove contact remark via setContactRemark with empty string',
      () async {
        await dataSource.setContactRemark('@alice:server.com', '小明');
        await dataSource.setContactRemark('@alice:server.com', '');

        final result = await dataSource.getContactRemark('@alice:server.com');
        expect(result, isNull);
      },
    );

    test('should remove contact remark via removeContactRemark', () async {
      await dataSource.setContactRemark('@alice:server.com', '小明');
      await dataSource.removeContactRemark('@alice:server.com');

      final result = await dataSource.getContactRemark('@alice:server.com');
      expect(result, isNull);
    });

    test('should update existing contact remark', () async {
      await dataSource.setContactRemark('@alice:server.com', '旧备注');
      await dataSource.setContactRemark('@alice:server.com', '新备注');

      final result = await dataSource.getContactRemark('@alice:server.com');
      expect(result, equals('新备注'));
    });
  });

  // ============================================
  // 3. 强提醒
  // ============================================
  group('Strong Reminders', () {
    test('should set and get strong reminder for a room', () async {
      await dataSource.setStrongReminder('!room1:server.com', true);

      final status = await dataSource.getStrongReminderStatus(
        '!room1:server.com',
      );
      expect(status, isTrue);
    });

    test('should return false for rooms without strong reminder', () async {
      final status = await dataSource.getStrongReminderStatus(
        '!unknown:server.com',
      );
      expect(status, isFalse);
    });

    test('should disable strong reminder by setting false', () async {
      await dataSource.setStrongReminder('!room1:server.com', true);
      await dataSource.setStrongReminder('!room1:server.com', false);

      final status = await dataSource.getStrongReminderStatus(
        '!room1:server.com',
      );
      expect(status, isFalse);
    });

    test('should get all strong reminders', () async {
      await dataSource.setStrongReminder('!room1:server.com', true);
      await dataSource.setStrongReminder('!room2:server.com', true);

      final reminders = await dataSource.getStrongReminders();

      expect(reminders.length, equals(2));
      expect(reminders['!room1:server.com'], isTrue);
      expect(reminders['!room2:server.com'], isTrue);
    });

    test('should return empty map when no reminders set', () async {
      final reminders = await dataSource.getStrongReminders();
      expect(reminders, isEmpty);
    });

    test('should not contain disabled rooms in reminders map', () async {
      await dataSource.setStrongReminder('!room1:server.com', true);
      await dataSource.setStrongReminder('!room2:server.com', true);
      await dataSource.setStrongReminder('!room1:server.com', false);

      final reminders = await dataSource.getStrongReminders();

      expect(reminders.containsKey('!room1:server.com'), isFalse);
      expect(reminders['!room2:server.com'], isTrue);
    });
  });

  // ============================================
  // 4. 通用设置
  // ============================================
  group('Generic Settings', () {
    test('should save and retrieve a setting', () async {
      await dataSource.saveSetting('language', 'zh-CN');

      final result = await dataSource.getSetting('language');
      expect(result, equals('zh-CN'));
    });

    test('should return null for non-existent setting', () async {
      final result = await dataSource.getSetting('non_existent_key');
      expect(result, isNull);
    });

    test('should remove a setting', () async {
      await dataSource.saveSetting('language', 'zh-CN');
      await dataSource.removeSetting('language');

      final result = await dataSource.getSetting('language');
      expect(result, isNull);
    });

    test('should overwrite existing setting', () async {
      await dataSource.saveSetting('language', 'zh-CN');
      await dataSource.saveSetting('language', 'en-US');

      final result = await dataSource.getSetting('language');
      expect(result, equals('en-US'));
    });

    test('should store multiple settings independently', () async {
      await dataSource.saveSetting('language', 'zh-CN');
      await dataSource.saveSetting('region', 'CN');

      expect(await dataSource.getSetting('language'), equals('zh-CN'));
      expect(await dataSource.getSetting('region'), equals('CN'));
    });

    test('should not affect other settings when removing one', () async {
      await dataSource.saveSetting('language', 'zh-CN');
      await dataSource.saveSetting('region', 'CN');

      await dataSource.removeSetting('language');

      expect(await dataSource.getSetting('language'), isNull);
      expect(await dataSource.getSetting('region'), equals('CN'));
    });
  });

  // ============================================
  // 5. 本地删除消息
  // ============================================
  group('Deleted Messages', () {
    test('should mark messages as locally deleted', () async {
      await dataSource.markMessagesAsLocallyDeleted('!room1:server.com', [
        'msg1',
        'msg2',
        'msg3',
      ]);

      final ids = await dataSource.getLocallyDeletedMessageIds(
        '!room1:server.com',
      );

      expect(ids, containsAll(['msg1', 'msg2', 'msg3']));
      expect(ids.length, equals(3));
    });

    test(
      'should return empty set for rooms with no deleted messages',
      () async {
        final ids = await dataSource.getLocallyDeletedMessageIds(
          '!unknown:server.com',
        );
        expect(ids, isEmpty);
      },
    );

    test('should accumulate deleted messages across multiple calls', () async {
      await dataSource.markMessagesAsLocallyDeleted('!room1:server.com', [
        'msg1',
        'msg2',
      ]);
      await dataSource.markMessagesAsLocallyDeleted('!room1:server.com', [
        'msg3',
        'msg4',
      ]);

      final ids = await dataSource.getLocallyDeletedMessageIds(
        '!room1:server.com',
      );

      expect(ids, containsAll(['msg1', 'msg2', 'msg3', 'msg4']));
    });

    test('should not duplicate message IDs', () async {
      await dataSource.markMessagesAsLocallyDeleted('!room1:server.com', [
        'msg1',
        'msg2',
      ]);
      await dataSource.markMessagesAsLocallyDeleted('!room1:server.com', [
        'msg2',
        'msg3',
      ]);

      final ids = await dataSource.getLocallyDeletedMessageIds(
        '!room1:server.com',
      );

      // Uses a Set internally, so msg2 should not be duplicated
      expect(ids.contains('msg1'), isTrue);
      expect(ids.contains('msg2'), isTrue);
      expect(ids.contains('msg3'), isTrue);
    });

    test('should keep messages separate per room', () async {
      await dataSource.markMessagesAsLocallyDeleted('!room1:server.com', [
        'msg1',
      ]);
      await dataSource.markMessagesAsLocallyDeleted('!room2:server.com', [
        'msg2',
      ]);

      final ids1 = await dataSource.getLocallyDeletedMessageIds(
        '!room1:server.com',
      );
      final ids2 = await dataSource.getLocallyDeletedMessageIds(
        '!room2:server.com',
      );

      expect(ids1, contains('msg1'));
      expect(ids1, isNot(contains('msg2')));
      expect(ids2, contains('msg2'));
      expect(ids2, isNot(contains('msg1')));
    });

    test('should clear deleted messages for a room', () async {
      await dataSource.markMessagesAsLocallyDeleted('!room1:server.com', [
        'msg1',
        'msg2',
      ]);
      await dataSource.markMessagesAsLocallyDeleted('!room2:server.com', [
        'msg3',
      ]);

      await dataSource.clearLocallyDeletedMessages('!room1:server.com');

      final ids1 = await dataSource.getLocallyDeletedMessageIds(
        '!room1:server.com',
      );
      final ids2 = await dataSource.getLocallyDeletedMessageIds(
        '!room2:server.com',
      );

      expect(ids1, isEmpty);
      expect(ids2, contains('msg3'));
    });

    test('should handle clearing messages for room with no data', () async {
      // Should not throw
      await dataSource.clearLocallyDeletedMessages('!nonexistent:server.com');

      final ids = await dataSource.getLocallyDeletedMessageIds(
        '!nonexistent:server.com',
      );
      expect(ids, isEmpty);
    });

    test('should enforce 1000 message limit per room', () async {
      // Mark 1005 messages
      final messageIds = List.generate(
        1005,
        (i) => 'msg_${i.toString().padLeft(5, '0')}',
      );
      await dataSource.markMessagesAsLocallyDeleted(
        '!room1:server.com',
        messageIds,
      );

      final ids = await dataSource.getLocallyDeletedMessageIds(
        '!room1:server.com',
      );

      expect(ids.length, lessThanOrEqualTo(1000));
    });
  });

  // ============================================
  // 6. 消息销毁时间
  // ============================================
  group('Destruction Times', () {
    test('should set and get message destruction time', () async {
      final destroyAt = DateTime(2025, 6, 15, 12, 0, 0);

      await dataSource.setMessageDestroyedAt(
        '!room1:server.com',
        'msg1',
        destroyAt,
      );

      final result = await dataSource.getMessageDestroyedAt(
        '!room1:server.com',
        'msg1',
      );

      expect(result, isNotNull);
      expect(result, equals(destroyAt));
    });

    test('should return null for message without destruction time', () async {
      final result = await dataSource.getMessageDestroyedAt(
        '!room1:server.com',
        'msg_unknown',
      );
      expect(result, isNull);
    });

    test('should get all destruction times for a room', () async {
      final time1 = DateTime(2025, 6, 15, 12, 0, 0);
      final time2 = DateTime(2025, 6, 15, 13, 0, 0);

      await dataSource.setMessageDestroyedAt(
        '!room1:server.com',
        'msg1',
        time1,
      );
      await dataSource.setMessageDestroyedAt(
        '!room1:server.com',
        'msg2',
        time2,
      );

      final times = await dataSource.getMessageDestructionTimes(
        '!room1:server.com',
      );

      expect(times.length, equals(2));
      expect(times['msg1'], equals(time1));
      expect(times['msg2'], equals(time2));
    });

    test(
      'should return empty map for room with no destruction times',
      () async {
        final times = await dataSource.getMessageDestructionTimes(
          '!unknown:server.com',
        );
        expect(times, isEmpty);
      },
    );

    test('should clear specific message destruction times', () async {
      final time1 = DateTime(2025, 6, 15, 12, 0, 0);
      final time2 = DateTime(2025, 6, 15, 13, 0, 0);
      final time3 = DateTime(2025, 6, 15, 14, 0, 0);

      await dataSource.setMessageDestroyedAt(
        '!room1:server.com',
        'msg1',
        time1,
      );
      await dataSource.setMessageDestroyedAt(
        '!room1:server.com',
        'msg2',
        time2,
      );
      await dataSource.setMessageDestroyedAt(
        '!room1:server.com',
        'msg3',
        time3,
      );

      await dataSource.clearMessageDestructionTimes('!room1:server.com', [
        'msg1',
        'msg2',
      ]);

      final times = await dataSource.getMessageDestructionTimes(
        '!room1:server.com',
      );

      expect(times.length, equals(1));
      expect(times.containsKey('msg1'), isFalse);
      expect(times.containsKey('msg2'), isFalse);
      expect(times['msg3'], equals(time3));
    });

    test('should clear all destruction times for a room', () async {
      final time1 = DateTime(2025, 6, 15, 12, 0, 0);
      final time2 = DateTime(2025, 6, 15, 13, 0, 0);

      await dataSource.setMessageDestroyedAt(
        '!room1:server.com',
        'msg1',
        time1,
      );
      await dataSource.setMessageDestroyedAt(
        '!room1:server.com',
        'msg2',
        time2,
      );
      await dataSource.setMessageDestroyedAt(
        '!room2:server.com',
        'msg3',
        time1,
      );

      await dataSource.clearAllMessageDestructionTimes('!room1:server.com');

      final times1 = await dataSource.getMessageDestructionTimes(
        '!room1:server.com',
      );
      final times2 = await dataSource.getMessageDestructionTimes(
        '!room2:server.com',
      );

      expect(times1, isEmpty);
      expect(times2.length, equals(1));
      expect(times2['msg3'], equals(time1));
    });

    test(
      'should handle clearing destruction times for non-existent room',
      () async {
        // Should not throw
        await dataSource.clearAllMessageDestructionTimes(
          '!nonexistent:server.com',
        );
        await dataSource.clearMessageDestructionTimes(
          '!nonexistent:server.com',
          ['msg1'],
        );
      },
    );

    test('should keep destruction times separate per room', () async {
      final time1 = DateTime(2025, 6, 15, 12, 0, 0);
      final time2 = DateTime(2025, 6, 15, 13, 0, 0);

      await dataSource.setMessageDestroyedAt(
        '!room1:server.com',
        'msg1',
        time1,
      );
      await dataSource.setMessageDestroyedAt(
        '!room2:server.com',
        'msg1',
        time2,
      );

      final result1 = await dataSource.getMessageDestroyedAt(
        '!room1:server.com',
        'msg1',
      );
      final result2 = await dataSource.getMessageDestroyedAt(
        '!room2:server.com',
        'msg1',
      );

      expect(result1, equals(time1));
      expect(result2, equals(time2));
    });
  });

  // ============================================
  // 7. 隐私设置
  // ============================================
  group('Privacy Settings', () {
    test('should save and retrieve privacy settings', () async {
      await dataSource.savePrivacySettings(
        avatarVisibility: 'contacts',
        statusVisibility: 'nobody',
        lastSeenVisibility: 'everyone',
        allowStrangerMessage: false,
        showReadReceipts: false,
        showTypingIndicator: true,
        hidePhoneNumber: true,
        showLinkPreviews: false,
        defaultEncryptNewChats: false,
        privateChatMode: true,
        protectIpAddress: true,
        proxyEnabled: true,
        proxyUrl: 'http://127.0.0.1:7890',
        useTor: false,
        defaultSelfDestructSeconds: 300,
      );

      final result = await dataSource.getPrivacySettings();

      expect(result, isNotNull);
      expect(result!['avatarVisibility'], equals('contacts'));
      expect(result['statusVisibility'], equals('nobody'));
      expect(result['lastSeenVisibility'], equals('everyone'));
      expect(result['allowStrangerMessage'], equals(false));
      expect(result['showReadReceipts'], equals(false));
      expect(result['showTypingIndicator'], equals(true));
      expect(result['hidePhoneNumber'], equals(true));
      expect(result['showLinkPreviews'], equals(false));
      expect(result['defaultEncryptNewChats'], equals(false));
      expect(result['privateChatMode'], equals(true));
      expect(result['protectIpAddress'], equals(true));
      expect(result['proxyEnabled'], equals(true));
      expect(result['proxyUrl'], equals('http://127.0.0.1:7890'));
      expect(result['defaultSelfDestructSeconds'], equals(300));
    });

    test('should return null when no privacy settings saved', () async {
      final result = await dataSource.getPrivacySettings();
      expect(result, isNull);
    });

    test('should save with default values', () async {
      await dataSource.savePrivacySettings();

      final result = await dataSource.getPrivacySettings();

      expect(result, isNotNull);
      expect(result!['avatarVisibility'], equals('everyone'));
      expect(result['statusVisibility'], equals('everyone'));
      expect(result['lastSeenVisibility'], equals('everyone'));
      expect(result['allowStrangerMessage'], equals(true));
      expect(result['showReadReceipts'], equals(true));
      expect(result['showTypingIndicator'], equals(true));
      expect(result['showLinkPreviews'], equals(true));
      expect(result['defaultEncryptNewChats'], equals(true));
      expect(result['privateChatMode'], equals(false));
      expect(result['protectIpAddress'], equals(false));
      expect(result['proxyEnabled'], equals(false));
      expect(result['defaultSelfDestructSeconds'], isNull);
    });

    group('Read Receipts', () {
      test('should return true by default when no settings saved', () async {
        final result = await dataSource.shouldShowReadReceipts();
        expect(result, isTrue);
      });

      test('should return saved read receipts setting', () async {
        await dataSource.savePrivacySettings(showReadReceipts: false);

        final result = await dataSource.shouldShowReadReceipts();
        expect(result, isFalse);
      });
    });

    group('Typing Indicator', () {
      test('should return true by default when no settings saved', () async {
        final result = await dataSource.shouldShowTypingIndicator();
        expect(result, isTrue);
      });

      test('should return saved typing indicator setting', () async {
        await dataSource.savePrivacySettings(showTypingIndicator: false);

        final result = await dataSource.shouldShowTypingIndicator();
        expect(result, isFalse);
      });
    });

    test('should update a single privacy setting', () async {
      await dataSource.savePrivacySettings(
        avatarVisibility: 'everyone',
        showReadReceipts: true,
      );

      await dataSource.updatePrivacySetting('avatarVisibility', 'nobody');

      final result = await dataSource.getPrivacySettings();
      expect(result!['avatarVisibility'], equals('nobody'));
      // Other settings should remain unchanged
      expect(result['showReadReceipts'], equals(true));
    });

    test('should update privacy setting even with no prior settings', () async {
      await dataSource.updatePrivacySetting('showReadReceipts', false);

      final result = await dataSource.getPrivacySettings();
      expect(result, isNotNull);
      expect(result!['showReadReceipts'], equals(false));
    });

    test('should expose typed privacy settings model', () async {
      await dataSource.savePrivacySettings(
        hidePhoneNumber: true,
        defaultEncryptNewChats: false,
        privateChatMode: true,
        protectIpAddress: true,
        proxyEnabled: true,
        proxyUrl: 'http://127.0.0.1:7890',
        showLinkPreviews: false,
        defaultSelfDestructSeconds: 60,
      );

      final settings = await dataSource.getPrivacySettingsModel();

      expect(settings.hidePhoneNumber, isTrue);
      expect(settings.defaultEncryptNewChats, isFalse);
      expect(settings.privateChatMode, isTrue);
      expect(settings.protectIpAddress, isTrue);
      expect(settings.proxyEnabled, isTrue);
      expect(settings.proxyUrl, 'http://127.0.0.1:7890');
      expect(settings.showLinkPreviews, isFalse);
      expect(settings.defaultSelfDestructSeconds, 60);
    });
  });

  // ============================================
  // 8. 隐藏聊天
  // ============================================
  group('Hidden Chats', () {
    test('should hide a chat', () async {
      await dataSource.hideChat('!room1:server.com');

      final isHidden = await dataSource.isChatHidden('!room1:server.com');
      expect(isHidden, isTrue);
    });

    test('should return false for non-hidden chat', () async {
      final isHidden = await dataSource.isChatHidden('!room1:server.com');
      expect(isHidden, isFalse);
    });

    test('should unhide a chat', () async {
      await dataSource.hideChat('!room1:server.com');
      await dataSource.unhideChat('!room1:server.com');

      final isHidden = await dataSource.isChatHidden('!room1:server.com');
      expect(isHidden, isFalse);
    });

    test('should get all hidden chat IDs', () async {
      await dataSource.hideChat('!room1:server.com');
      await dataSource.hideChat('!room2:server.com');

      final hiddenIds = await dataSource.getHiddenChatIds();

      expect(hiddenIds.length, equals(2));
      expect(hiddenIds, contains('!room1:server.com'));
      expect(hiddenIds, contains('!room2:server.com'));
    });

    test('should return empty set when no chats hidden', () async {
      final hiddenIds = await dataSource.getHiddenChatIds();
      expect(hiddenIds, isEmpty);
    });

    test('should not duplicate chat IDs when hiding same chat twice', () async {
      await dataSource.hideChat('!room1:server.com');
      await dataSource.hideChat('!room1:server.com');

      final hiddenIds = await dataSource.getHiddenChatIds();
      expect(hiddenIds.length, equals(1));
    });

    test('should handle unhiding a non-hidden chat gracefully', () async {
      // Should not throw
      await dataSource.unhideChat('!nonexistent:server.com');

      final hiddenIds = await dataSource.getHiddenChatIds();
      expect(hiddenIds, isEmpty);
    });
  });

  // ============================================
  // 9. 快捷回复
  // ============================================
  group('Quick Replies', () {
    test('should return default quick replies when none saved', () async {
      final replies = await dataSource.getQuickReplies();

      expect(replies, isNotEmpty);
      expect(replies.length, equals(6));
      expect(replies[0]['content'], equals('好的'));
      expect(replies[0]['isSystem'], equals(true));
      expect(replies[1]['content'], equals('收到'));
      expect(replies[5]['content'], equals('没问题'));
    });

    test('should add a custom quick reply', () async {
      await dataSource.addQuickReply('自定义回复');

      final replies = await dataSource.getQuickReplies();

      // Default 6 + 1 custom
      expect(replies.length, equals(7));

      final customReply = replies.last;
      expect(customReply['content'], equals('自定义回复'));
      expect(customReply['isSystem'], equals(false));
      expect((customReply['id'] as String).startsWith('custom_'), isTrue);
    });

    test('should remove a quick reply by ID', () async {
      await dataSource.addQuickReply('临时回复');

      final repliesBefore = await dataSource.getQuickReplies();
      final customReply = repliesBefore.firstWhere(
        (r) => r['content'] == '临时回复',
      );
      final customId = customReply['id'] as String;

      await dataSource.removeQuickReply(customId);

      final repliesAfter = await dataSource.getQuickReplies();
      final found = repliesAfter.where((r) => r['id'] == customId);
      expect(found, isEmpty);
    });

    test('should save and retrieve custom quick replies list', () async {
      final customReplies = [
        {'id': 'test_1', 'content': '回复1', 'order': 0, 'isSystem': false},
        {'id': 'test_2', 'content': '回复2', 'order': 1, 'isSystem': false},
      ];

      await dataSource.saveQuickReplies(customReplies);

      final result = await dataSource.getQuickReplies();
      expect(result.length, equals(2));
      expect(result[0]['content'], equals('回复1'));
      expect(result[1]['content'], equals('回复2'));
    });

    test('should update quick reply last used time', () async {
      await dataSource.addQuickReply('测试回复');

      final repliesBefore = await dataSource.getQuickReplies();
      final customReply = repliesBefore.firstWhere(
        (r) => r['content'] == '测试回复',
      );
      final customId = customReply['id'] as String;

      // Initially no lastUsed
      expect(customReply['lastUsed'], isNull);

      await dataSource.updateQuickReplyLastUsed(customId);

      final repliesAfter = await dataSource.getQuickReplies();
      final updatedReply = repliesAfter.firstWhere((r) => r['id'] == customId);
      expect(updatedReply['lastUsed'], isNotNull);
    });

    test(
      'should handle removing non-existent quick reply ID gracefully',
      () async {
        // Pre-save some replies so we have data
        await dataSource.addQuickReply('保留的回复');

        final countBefore = (await dataSource.getQuickReplies()).length;

        // Should not throw
        await dataSource.removeQuickReply('nonexistent_id');

        final countAfter = (await dataSource.getQuickReplies()).length;
        expect(countAfter, equals(countBefore));
      },
    );
  });

  // ============================================
  // 10. 翻译缓存
  // ============================================
  group('Translation Cache', () {
    test('should save and retrieve translation cache', () async {
      await dataSource.saveTranslationCache('msg1', 'en', 'Hello World');

      final result = await dataSource.getTranslationCache('msg1', 'en');
      expect(result, equals('Hello World'));
    });

    test('should return null for missing translation cache', () async {
      final result = await dataSource.getTranslationCache('msg_unknown', 'en');
      expect(result, isNull);
    });

    test('should distinguish translations by target language', () async {
      await dataSource.saveTranslationCache('msg1', 'en', 'Hello');
      await dataSource.saveTranslationCache('msg1', 'ja', 'こんにちは');

      final enResult = await dataSource.getTranslationCache('msg1', 'en');
      final jaResult = await dataSource.getTranslationCache('msg1', 'ja');

      expect(enResult, equals('Hello'));
      expect(jaResult, equals('こんにちは'));
    });

    test('should overwrite existing translation cache', () async {
      await dataSource.saveTranslationCache('msg1', 'en', 'Old translation');
      await dataSource.saveTranslationCache('msg1', 'en', 'New translation');

      final result = await dataSource.getTranslationCache('msg1', 'en');
      expect(result, equals('New translation'));
    });

    test('should enforce 500 entry size limit by evicting oldest', () async {
      // Fill cache beyond the 500 limit
      for (var i = 0; i < 510; i++) {
        await dataSource.saveTranslationCache('msg_$i', 'en', 'Translation $i');
      }

      // After exceeding 500, eviction should have removed some early entries.
      // The cache trims 100 entries when exceeding 500, leaving ~410 entries
      // plus the newly added one. The exact count depends on when the trim
      // fires, but the total should be <= 500.
      // We verify by checking the oldest entries were evicted.
      final oldEntry = await dataSource.getTranslationCache('msg_0', 'en');
      final recentEntry = await dataSource.getTranslationCache('msg_509', 'en');

      // msg_0 should have been evicted (it is among the first 100 removed)
      expect(oldEntry, isNull);
      // msg_509 should still exist
      expect(recentEntry, equals('Translation 509'));
    });

    group('Translation Settings', () {
      test('should save and get translation settings', () async {
        await dataSource.saveTranslationSettings(
          defaultTargetLanguage: 'en',
          autoTranslate: true,
        );

        final result = await dataSource.getTranslationSettings();
        expect(result, isNotNull);
        expect(result!['defaultTargetLanguage'], equals('en'));
        expect(result['autoTranslate'], equals(true));
      });

      test('should return null when no translation settings saved', () async {
        final result = await dataSource.getTranslationSettings();
        expect(result, isNull);
      });

      test('should partially update translation settings', () async {
        await dataSource.saveTranslationSettings(
          defaultTargetLanguage: 'en',
          autoTranslate: false,
        );

        await dataSource.saveTranslationSettings(autoTranslate: true);

        final result = await dataSource.getTranslationSettings();
        expect(result!['defaultTargetLanguage'], equals('en'));
        expect(result['autoTranslate'], equals(true));
      });
    });
  });

  // ============================================
  // 11. 草稿
  // ============================================
  group('Drafts', () {
    test('should save and retrieve a draft', () async {
      await dataSource.saveDraft('!room1:server.com', '草稿消息内容');

      final result = await dataSource.getDraft('!room1:server.com');
      expect(result, equals('草稿消息内容'));
    });

    test('should return null for room without draft', () async {
      final result = await dataSource.getDraft('!unknown:server.com');
      expect(result, isNull);
    });

    test('should clear draft by saving empty string', () async {
      await dataSource.saveDraft('!room1:server.com', '草稿消息');
      await dataSource.saveDraft('!room1:server.com', '');

      final result = await dataSource.getDraft('!room1:server.com');
      expect(result, isNull);
    });

    test('should store drafts per room independently', () async {
      await dataSource.saveDraft('!room1:server.com', '草稿1');
      await dataSource.saveDraft('!room2:server.com', '草稿2');

      expect(await dataSource.getDraft('!room1:server.com'), equals('草稿1'));
      expect(await dataSource.getDraft('!room2:server.com'), equals('草稿2'));
    });

    test('should overwrite existing draft', () async {
      await dataSource.saveDraft('!room1:server.com', '旧草稿');
      await dataSource.saveDraft('!room1:server.com', '新草稿');

      final result = await dataSource.getDraft('!room1:server.com');
      expect(result, equals('新草稿'));
    });

    test('should not affect other room drafts when clearing one', () async {
      await dataSource.saveDraft('!room1:server.com', '草稿1');
      await dataSource.saveDraft('!room2:server.com', '草稿2');

      await dataSource.saveDraft('!room1:server.com', '');

      expect(await dataSource.getDraft('!room1:server.com'), isNull);
      expect(await dataSource.getDraft('!room2:server.com'), equals('草稿2'));
    });
  });

  // ============================================
  // 12. 聊天文件夹
  // ============================================
  group('Chat Folders', () {
    test('should save and retrieve chat folders', () async {
      final folders = [
        {
          'id': 'folder_1',
          'name': '工作',
          'roomIds': ['!room1:server.com', '!room2:server.com'],
        },
        {
          'id': 'folder_2',
          'name': '家庭',
          'roomIds': ['!room3:server.com'],
        },
      ];

      await dataSource.saveChatFolders(folders);

      final result = await dataSource.getChatFolders();

      expect(result.length, equals(2));
      expect(result[0]['name'], equals('工作'));
      expect(result[1]['name'], equals('家庭'));
      expect((result[0]['roomIds'] as List).length, equals(2));
    });

    test('should return empty list when no folders saved', () async {
      final result = await dataSource.getChatFolders();
      expect(result, isEmpty);
    });

    test('should overwrite folders on save', () async {
      final oldFolders = [
        {'id': 'folder_1', 'name': '旧文件夹'},
      ];
      await dataSource.saveChatFolders(oldFolders);

      final newFolders = [
        {'id': 'folder_2', 'name': '新文件夹'},
      ];
      await dataSource.saveChatFolders(newFolders);

      final result = await dataSource.getChatFolders();
      expect(result.length, equals(1));
      expect(result[0]['name'], equals('新文件夹'));
    });

    test('should save empty folder list', () async {
      final folders = [
        {'id': 'folder_1', 'name': '文件夹'},
      ];
      await dataSource.saveChatFolders(folders);
      await dataSource.saveChatFolders([]);

      final result = await dataSource.getChatFolders();
      // jsonDecode('[]') returns an empty list
      expect(result, isEmpty);
    });
  });

  // ============================================
  // 13. 收藏消息
  // ============================================
  group('Favorites', () {
    group('Favorite Messages', () {
      test('should save and retrieve favorite messages JSON', () async {
        final favJson = jsonEncode([
          {'eventId': 'evt1', 'roomId': '!room1:server.com', 'type': 'text'},
          {'eventId': 'evt2', 'roomId': '!room2:server.com', 'type': 'image'},
        ]);

        await dataSource.saveFavoriteMessages(favJson);

        final result = await dataSource.getFavoriteMessages();
        expect(result, isNotNull);

        final decoded = jsonDecode(result!) as List;
        expect(decoded.length, equals(2));
        expect(decoded[0]['eventId'], equals('evt1'));
        expect(decoded[1]['type'], equals('image'));
      });

      test('should return null when no favorites saved', () async {
        final result = await dataSource.getFavoriteMessages();
        expect(result, isNull);
      });

      test('should overwrite favorites on save', () async {
        await dataSource.saveFavoriteMessages(
          jsonEncode([
            {'eventId': 'evt1'},
          ]),
        );
        await dataSource.saveFavoriteMessages(
          jsonEncode([
            {'eventId': 'evt2'},
            {'eventId': 'evt3'},
          ]),
        );

        final result = await dataSource.getFavoriteMessages();
        final decoded = jsonDecode(result!) as List;
        expect(decoded.length, equals(2));
        expect(decoded[0]['eventId'], equals('evt2'));
      });
    });

    group('Favorite Meta', () {
      test('should save and retrieve favorite meta JSON', () async {
        final metaJson = jsonEncode({
          'evt1': {
            'tags': ['work', 'important'],
            'note': '重要消息',
          },
          'evt2': {
            'tags': ['personal'],
            'note': '',
          },
        });

        await dataSource.saveFavoriteMeta(metaJson);

        final result = await dataSource.getFavoriteMeta();
        expect(result, isNotNull);

        final decoded = jsonDecode(result!) as Map<String, dynamic>;
        expect(decoded['evt1']['tags'], contains('important'));
        expect(decoded['evt1']['note'], equals('重要消息'));
      });

      test('should return null when no favorite meta saved', () async {
        final result = await dataSource.getFavoriteMeta();
        expect(result, isNull);
      });
    });
  });

  // ============================================
  // 14. 通用键值存储 (read / write / delete)
  // ============================================
  group('Generic Key-Value Storage', () {
    test('should write and read a value', () async {
      await dataSource.write('custom_key', 'custom_value');

      final result = await dataSource.read('custom_key');
      expect(result, equals('custom_value'));
    });

    test('should return null for non-existent key', () async {
      final result = await dataSource.read('nonexistent_key');
      expect(result, isNull);
    });

    test('should delete a value', () async {
      await dataSource.write('custom_key', 'custom_value');
      await dataSource.delete('custom_key');

      final result = await dataSource.read('custom_key');
      expect(result, isNull);
    });

    test('should overwrite existing value', () async {
      await dataSource.write('custom_key', 'old_value');
      await dataSource.write('custom_key', 'new_value');

      final result = await dataSource.read('custom_key');
      expect(result, equals('new_value'));
    });
  });

  // ============================================
  // 15. 聊天背景
  // ============================================
  group('Chat Background', () {
    test('should set and get chat background for a room', () async {
      await dataSource.setChatBackground(
        '!room1:server.com',
        '/images/bg1.png',
      );

      final result = await dataSource.getChatBackground('!room1:server.com');
      expect(result, equals('/images/bg1.png'));
    });

    test('should return null when no chat background set', () async {
      final result = await dataSource.getChatBackground('!unknown:server.com');
      expect(result, isNull);
    });

    test('should set and get default chat background', () async {
      await dataSource.setDefaultChatBackground('/images/default_bg.png');

      final result = await dataSource.getDefaultChatBackground();
      expect(result, equals('/images/default_bg.png'));
    });

    test('should return null when no default background set', () async {
      final result = await dataSource.getDefaultChatBackground();
      expect(result, isNull);
    });

    test('should keep per-room and default backgrounds separate', () async {
      await dataSource.setChatBackground(
        '!room1:server.com',
        '/images/room_bg.png',
      );
      await dataSource.setDefaultChatBackground('/images/default_bg.png');

      final roomBg = await dataSource.getChatBackground('!room1:server.com');
      final defaultBg = await dataSource.getDefaultChatBackground();

      expect(roomBg, equals('/images/room_bg.png'));
      expect(defaultBg, equals('/images/default_bg.png'));
    });
  });

  // ============================================
  // 16. 字体大小
  // ============================================
  group('Message Font Size', () {
    test('should set and get message font size', () async {
      await dataSource.setMessageFontSize(20.0);

      final result = await dataSource.getMessageFontSize();
      expect(result, equals(20.0));
    });

    test('should return default 16.0 when no font size set', () async {
      final result = await dataSource.getMessageFontSize();
      expect(result, equals(16.0));
    });
  });

  // ============================================
  // 17. 自动下载设置
  // ============================================
  group('Auto Download Settings', () {
    test('should save and get auto download settings', () async {
      final settings = {'wifi': true, 'cellular': false, 'maxSize': 10485760};

      await dataSource.saveAutoDownloadSettings(settings);

      final result = await dataSource.getAutoDownloadSettings();
      expect(result['wifi'], equals(true));
      expect(result['cellular'], equals(false));
      expect(result['maxSize'], equals(10485760));
    });

    test('should return defaults when no settings saved', () async {
      final result = await dataSource.getAutoDownloadSettings();
      expect(result['wifi_images'], isTrue);
      expect(result['mobile_video'], isFalse);
      expect(result['roaming_files'], isFalse);
    });
  });

  // ============================================
  // 18. 定时消息
  // ============================================
  group('Scheduled Messages', () {
    test('should save and retrieve scheduled messages', () async {
      final scheduledAt = DateTime(2025, 12, 25, 10, 0, 0);

      await dataSource.saveScheduledMessage(
        roomId: '!room1:server.com',
        messageId: 'scheduled_1',
        text: '圣诞快乐！',
        scheduledAt: scheduledAt,
      );

      final messages = await dataSource.getScheduledMessages(
        '!room1:server.com',
      );

      expect(messages.length, equals(1));
      expect(messages[0].messageId, equals('scheduled_1'));
      expect(messages[0].text, equals('圣诞快乐！'));
    });

    test(
      'should return empty list for room with no scheduled messages',
      () async {
        final messages = await dataSource.getScheduledMessages(
          '!unknown:server.com',
        );
        expect(messages, isEmpty);
      },
    );

    test('should save scheduled message with optional fields', () async {
      final scheduledAt = DateTime(2025, 12, 25, 10, 0, 0);

      await dataSource.saveScheduledMessage(
        roomId: '!room1:server.com',
        messageId: 'scheduled_2',
        text: '提醒消息',
        scheduledAt: scheduledAt,
        selfDestructAfter: 60,
        mentionedUserIds: ['@alice:server.com'],
        mentionsRoom: true,
      );

      final messages = await dataSource.getScheduledMessages(
        '!room1:server.com',
      );

      expect(messages[0].selfDestructAfter, equals(60));
      expect(messages[0].mentionedUserIds, contains('@alice:server.com'));
      expect(messages[0].mentionsRoom, equals(true));
    });

    test('should save scheduled poll payload', () async {
      final scheduledAt = DateTime(2025, 12, 25, 10, 0, 0);

      await dataSource.saveScheduledMessage(
        roomId: '!room1:server.com',
        messageId: 'scheduled_poll',
        text: 'Lunch?',
        type: MessageType.poll,
        payload: {
          'options': ['Sushi', 'Pizza'],
          'maxSelections': 1,
          'isAnonymous': true,
        },
        scheduledAt: scheduledAt,
      );

      final messages = await dataSource.getScheduledMessages(
        '!room1:server.com',
      );

      expect(messages.single.type, MessageType.poll);
      expect(messages.single.pollOptions, ['Sushi', 'Pizza']);
      expect(messages.single.pollMaxSelections, 1);
      expect(messages.single.payload['isAnonymous'], isTrue);
    });

    test('should remove a scheduled message', () async {
      final scheduledAt = DateTime(2025, 12, 25, 10, 0, 0);

      await dataSource.saveScheduledMessage(
        roomId: '!room1:server.com',
        messageId: 'scheduled_1',
        text: '消息1',
        scheduledAt: scheduledAt,
      );
      await dataSource.saveScheduledMessage(
        roomId: '!room1:server.com',
        messageId: 'scheduled_2',
        text: '消息2',
        scheduledAt: scheduledAt,
      );

      await dataSource.removeScheduledMessage(
        '!room1:server.com',
        'scheduled_1',
      );

      final messages = await dataSource.getScheduledMessages(
        '!room1:server.com',
      );
      expect(messages.length, equals(1));
      expect(messages[0].messageId, equals('scheduled_2'));
    });

    test('should clear all scheduled messages for a room', () async {
      final scheduledAt = DateTime(2025, 12, 25, 10, 0, 0);

      await dataSource.saveScheduledMessage(
        roomId: '!room1:server.com',
        messageId: 'scheduled_1',
        text: '消息1',
        scheduledAt: scheduledAt,
      );

      await dataSource.clearScheduledMessages('!room1:server.com');

      final messages = await dataSource.getScheduledMessages(
        '!room1:server.com',
      );
      expect(messages, isEmpty);
    });
  });

  // ============================================
  // 19. 朋友圈设置
  // ============================================
  group('Moment Settings', () {
    test('should save and get moment settings', () async {
      await dataSource.saveMomentSettings(
        allowStrangers: true,
        visibleDays: 30,
      );

      final result = await dataSource.getMomentSettings();
      expect(result, isNotNull);
      expect(result!['allowStrangers'], equals(true));
      expect(result['visibleDays'], equals(30));
    });

    test('should return null when no moment settings saved', () async {
      final result = await dataSource.getMomentSettings();
      expect(result, isNull);
    });

    test('should save and get hidden moment users', () async {
      await dataSource.saveHiddenMomentUsers([
        '@alice:server.com',
        '@bob:server.com',
      ]);

      final result = await dataSource.getHiddenMomentUsers();
      expect(result, isNotNull);
      expect(result!.length, equals(2));
      expect(result, contains('@alice:server.com'));
    });

    test('should return null when no hidden moment users saved', () async {
      final result = await dataSource.getHiddenMomentUsers();
      expect(result, isNull);
    });

    test('should save and get blocked moment users', () async {
      await dataSource.saveBlockedMomentUsers(['@blocked:server.com']);

      final result = await dataSource.getBlockedMomentUsers();
      expect(result, isNotNull);
      expect(result!.length, equals(1));
      expect(result[0], equals('@blocked:server.com'));
    });

    test('should return null when no blocked moment users saved', () async {
      final result = await dataSource.getBlockedMomentUsers();
      expect(result, isNull);
    });

    test('should save and get moment last read time', () async {
      final time = DateTime(2025, 6, 15, 12, 0, 0);
      await dataSource.saveMomentLastReadTime(time);

      final result = await dataSource.getMomentLastReadTime();
      expect(result, equals(time));
    });

    test('should return null when no moment last read time saved', () async {
      final result = await dataSource.getMomentLastReadTime();
      expect(result, isNull);
    });
  });

  // ============================================
  // 20. 跨功能交互测试
  // ============================================
  group('Cross-feature Isolation', () {
    test('different features should not interfere with each other', () async {
      // Save data across different features
      await dataSource.saveDraft('!room1:server.com', '草稿');
      await dataSource.hideChat('!room1:server.com');
      await dataSource.setContactRemark('@alice:server.com', '小明');
      await dataSource.saveSetting('language', 'zh-CN');

      // Each feature should return its own data independently
      expect(await dataSource.getDraft('!room1:server.com'), equals('草稿'));
      expect(await dataSource.isChatHidden('!room1:server.com'), isTrue);
      expect(
        await dataSource.getContactRemark('@alice:server.com'),
        equals('小明'),
      );
      expect(await dataSource.getSetting('language'), equals('zh-CN'));
    });

    test('fresh instance should read previously saved data', () async {
      await dataSource.saveSetting('persistent_key', 'persistent_value');

      // Create a new instance (simulates app restart with same prefs)
      final newDataSource = PreferencesDataSource();
      final result = await newDataSource.getSetting('persistent_key');

      expect(result, equals('persistent_value'));
    });
  });
}
