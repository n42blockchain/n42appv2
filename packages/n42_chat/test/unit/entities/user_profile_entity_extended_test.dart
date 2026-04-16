// Extended tests for UserProfileEntity — covers settings classes NOT exercised by
// user_profile_entity_test.dart:
//   NotificationSettings.copyWith, PrivacySettings.copyWith,
//   AppearanceSettings.copyWith (+ BubbleStyle enum),
//   ChatSettings.copyWith

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/user_profile_entity.dart';

void main() {
  // ─────────────────────────────────────────────────
  // NotificationSettings
  // ─────────────────────────────────────────────────

  group('NotificationSettings', () {
    const defaults = NotificationSettings();

    test('default values', () {
      expect(defaults.enabled, isTrue);
      expect(defaults.showPreview, isTrue);
      expect(defaults.playSound, isTrue);
      expect(defaults.vibrate, isTrue);
      expect(defaults.doNotDisturb, isFalse);
      expect(defaults.doNotDisturbStart, isNull);
      expect(defaults.doNotDisturbEnd, isNull);
      expect(defaults.privacyMode, NotificationPrivacyMode.full);
    });

    test('copyWith changes single field', () {
      final updated = defaults.copyWith(enabled: false);
      expect(updated.enabled, isFalse);
      expect(updated.showPreview, isTrue); // unchanged
      expect(updated.playSound, isTrue); // unchanged
    });

    test('copyWith can set privacy mode', () {
      final updated = defaults.copyWith(
        privacyMode: NotificationPrivacyMode.hidden,
      );
      expect(updated.privacyMode, NotificationPrivacyMode.hidden);
    });

    test('copyWith can set doNotDisturb times', () {
      final updated = defaults.copyWith(
        doNotDisturb: true,
        doNotDisturbStart: '22:00',
        doNotDisturbEnd: '07:00',
      );
      expect(updated.doNotDisturb, isTrue);
      expect(updated.doNotDisturbStart, '22:00');
      expect(updated.doNotDisturbEnd, '07:00');
    });

    test('props equality: two identical instances are equal', () {
      const a = NotificationSettings(enabled: false, playSound: false);
      const b = NotificationSettings(enabled: false, playSound: false);
      expect(a, equals(b));
    });

    test('props inequality: different fields are not equal', () {
      const a = NotificationSettings(enabled: true);
      const b = NotificationSettings(enabled: false);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // PrivacySettings
  // ─────────────────────────────────────────────────

  group('PrivacySettings', () {
    const defaults = PrivacySettings();

    test('default values', () {
      expect(defaults.avatarVisibility, VisibilityLevel.everyone);
      expect(defaults.statusVisibility, VisibilityLevel.everyone);
      expect(defaults.lastSeenVisibility, VisibilityLevel.everyone);
      expect(defaults.allowStrangerMessage, isTrue);
      expect(defaults.showReadReceipts, isTrue);
      expect(defaults.showTypingIndicator, isTrue);
      expect(defaults.showLinkPreviews, isTrue);
    });

    test('copyWith changes visibility fields', () {
      final updated = defaults.copyWith(
        avatarVisibility: VisibilityLevel.contacts,
        lastSeenVisibility: VisibilityLevel.nobody,
      );
      expect(updated.avatarVisibility, VisibilityLevel.contacts);
      expect(updated.lastSeenVisibility, VisibilityLevel.nobody);
      expect(updated.statusVisibility, VisibilityLevel.everyone); // unchanged
    });

    test('copyWith changes bool fields', () {
      final updated = defaults.copyWith(
        allowStrangerMessage: false,
        showReadReceipts: false,
        showTypingIndicator: false,
        showLinkPreviews: false,
      );
      expect(updated.allowStrangerMessage, isFalse);
      expect(updated.showReadReceipts, isFalse);
      expect(updated.showTypingIndicator, isFalse);
      expect(updated.showLinkPreviews, isFalse);
    });

    test('props equality', () {
      const a = PrivacySettings(allowStrangerMessage: false);
      const b = PrivacySettings(allowStrangerMessage: false);
      expect(a, equals(b));
    });

    test('VisibilityLevel has all three values', () {
      expect(VisibilityLevel.values, hasLength(3));
      expect(
        VisibilityLevel.values,
        containsAll([
          VisibilityLevel.everyone,
          VisibilityLevel.contacts,
          VisibilityLevel.nobody,
        ]),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // AppearanceSettings + BubbleStyle
  // ─────────────────────────────────────────────────

  group('AppearanceSettings', () {
    const defaults = AppearanceSettings();

    test('default values', () {
      expect(defaults.themeMode, ThemeMode.system);
      expect(defaults.fontSize, FontSize.medium);
      expect(defaults.chatBackground, isNull);
      expect(defaults.bubbleStyle, BubbleStyle.wechat);
    });

    test('copyWith changes bubbleStyle', () {
      final updated = defaults.copyWith(bubbleStyle: BubbleStyle.modern);
      expect(updated.bubbleStyle, BubbleStyle.modern);
      expect(updated.fontSize, FontSize.medium); // unchanged
    });

    test('copyWith changes fontSize', () {
      final updated = defaults.copyWith(fontSize: FontSize.large);
      expect(updated.fontSize, FontSize.large);
    });

    test('copyWith changes themeMode', () {
      final updated = defaults.copyWith(themeMode: ThemeMode.dark);
      expect(updated.themeMode, ThemeMode.dark);
    });

    test('copyWith sets chatBackground', () {
      final updated = defaults.copyWith(chatBackground: 'bg_01.jpg');
      expect(updated.chatBackground, 'bg_01.jpg');
    });

    test('props equality', () {
      const a = AppearanceSettings(bubbleStyle: BubbleStyle.classic);
      const b = AppearanceSettings(bubbleStyle: BubbleStyle.classic);
      expect(a, equals(b));
    });

    test('BubbleStyle has wechat, modern, classic', () {
      expect(BubbleStyle.values, hasLength(3));
      expect(
        BubbleStyle.values,
        containsAll([
          BubbleStyle.wechat,
          BubbleStyle.modern,
          BubbleStyle.classic,
        ]),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // ChatSettings
  // ─────────────────────────────────────────────────

  group('ChatSettings', () {
    const defaults = ChatSettings();

    test('default values', () {
      expect(defaults.autoDownloadImage, isTrue);
      expect(defaults.autoDownloadVideo, isFalse);
      expect(defaults.autoDownloadFile, isFalse);
      expect(defaults.autoDownloadOnWifi, isTrue);
      expect(defaults.sendMessageKey, SendMessageKey.enter);
    });

    test('copyWith changes autoDownloadVideo', () {
      final updated = defaults.copyWith(autoDownloadVideo: true);
      expect(updated.autoDownloadVideo, isTrue);
      expect(updated.autoDownloadImage, isTrue); // unchanged
    });

    test('copyWith changes sendMessageKey to ctrlEnter', () {
      final updated = defaults.copyWith(
        sendMessageKey: SendMessageKey.ctrlEnter,
      );
      expect(updated.sendMessageKey, SendMessageKey.ctrlEnter);
    });

    test('copyWith changes all download flags', () {
      final updated = defaults.copyWith(
        autoDownloadImage: false,
        autoDownloadVideo: true,
        autoDownloadFile: true,
        autoDownloadOnWifi: false,
      );
      expect(updated.autoDownloadImage, isFalse);
      expect(updated.autoDownloadVideo, isTrue);
      expect(updated.autoDownloadFile, isTrue);
      expect(updated.autoDownloadOnWifi, isFalse);
    });

    test('props equality', () {
      const a = ChatSettings(autoDownloadVideo: true);
      const b = ChatSettings(autoDownloadVideo: true);
      expect(a, equals(b));
    });

    test('props inequality', () {
      const a = ChatSettings(autoDownloadVideo: true);
      const b = ChatSettings(autoDownloadVideo: false);
      expect(a, isNot(equals(b)));
    });
  });
}
