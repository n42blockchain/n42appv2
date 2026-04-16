import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/user_profile_entity.dart';

void main() {
  group('PrivacySettings', () {
    test('should have default values', () {
      const settings = PrivacySettings();

      expect(settings.avatarVisibility, VisibilityLevel.everyone);
      expect(settings.statusVisibility, VisibilityLevel.everyone);
      expect(settings.lastSeenVisibility, VisibilityLevel.everyone);
      expect(settings.allowStrangerMessage, isTrue);
      expect(settings.showReadReceipts, isTrue);
      expect(settings.showTypingIndicator, isTrue);
      expect(settings.hidePhoneNumber, isFalse);
      expect(settings.showLinkPreviews, isTrue);
      expect(settings.defaultEncryptNewChats, isTrue);
      expect(settings.privateChatMode, isFalse);
      expect(settings.protectIpAddress, isFalse);
      expect(settings.proxyEnabled, isFalse);
      expect(settings.useTor, isFalse);
      expect(settings.defaultSelfDestructSeconds, isNull);
    });

    test('should create with custom values', () {
      const settings = PrivacySettings(
        avatarVisibility: VisibilityLevel.contacts,
        statusVisibility: VisibilityLevel.nobody,
        lastSeenVisibility: VisibilityLevel.contacts,
        allowStrangerMessage: false,
        showReadReceipts: false,
        showTypingIndicator: false,
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

      expect(settings.avatarVisibility, VisibilityLevel.contacts);
      expect(settings.statusVisibility, VisibilityLevel.nobody);
      expect(settings.lastSeenVisibility, VisibilityLevel.contacts);
      expect(settings.allowStrangerMessage, isFalse);
      expect(settings.showReadReceipts, isFalse);
      expect(settings.showTypingIndicator, isFalse);
      expect(settings.hidePhoneNumber, isTrue);
      expect(settings.showLinkPreviews, isFalse);
      expect(settings.defaultEncryptNewChats, isFalse);
      expect(settings.privateChatMode, isTrue);
      expect(settings.protectIpAddress, isTrue);
      expect(settings.proxyEnabled, isTrue);
      expect(settings.proxyUrl, 'http://127.0.0.1:7890');
      expect(settings.defaultSelfDestructSeconds, 300);
    });

    test('should support copyWith for partial updates', () {
      const original = PrivacySettings();

      final updated = original.copyWith(
        showReadReceipts: false,
        showTypingIndicator: false,
        showLinkPreviews: false,
      );

      // Unchanged values
      expect(updated.avatarVisibility, VisibilityLevel.everyone);
      expect(updated.statusVisibility, VisibilityLevel.everyone);
      expect(updated.lastSeenVisibility, VisibilityLevel.everyone);
      expect(updated.allowStrangerMessage, isTrue);

      // Changed values
      expect(updated.showReadReceipts, isFalse);
      expect(updated.showTypingIndicator, isFalse);
      expect(updated.showLinkPreviews, isFalse);
    });

    test('should support copyWith for visibility updates', () {
      const original = PrivacySettings();

      final updated = original.copyWith(
        avatarVisibility: VisibilityLevel.nobody,
        lastSeenVisibility: VisibilityLevel.contacts,
      );

      expect(updated.avatarVisibility, VisibilityLevel.nobody);
      expect(updated.statusVisibility, VisibilityLevel.everyone);
      expect(updated.lastSeenVisibility, VisibilityLevel.contacts);
    });

    test('should be equal when all properties match', () {
      const settings1 = PrivacySettings(
        avatarVisibility: VisibilityLevel.contacts,
        showReadReceipts: false,
      );

      const settings2 = PrivacySettings(
        avatarVisibility: VisibilityLevel.contacts,
        showReadReceipts: false,
      );

      expect(settings1, equals(settings2));
    });

    test('should not be equal when properties differ', () {
      const settings1 = PrivacySettings(showReadReceipts: true);
      const settings2 = PrivacySettings(showReadReceipts: false);

      expect(settings1, isNot(equals(settings2)));
    });

    test('should include all properties in props for equality', () {
      const settings = PrivacySettings(
        avatarVisibility: VisibilityLevel.contacts,
        statusVisibility: VisibilityLevel.nobody,
        lastSeenVisibility: VisibilityLevel.contacts,
        allowStrangerMessage: false,
        showReadReceipts: false,
        showTypingIndicator: false,
        hidePhoneNumber: true,
        showLinkPreviews: false,
        defaultEncryptNewChats: false,
        privateChatMode: true,
        protectIpAddress: true,
        proxyEnabled: true,
        proxyUrl: 'http://127.0.0.1:7890',
        useTor: false,
        defaultSelfDestructSeconds: 60,
      );

      expect(settings.props.length, 15);
      expect(settings.props, contains(VisibilityLevel.contacts));
      expect(settings.props, contains(VisibilityLevel.nobody));
      expect(settings.props, contains(false));
      expect(settings.props, contains('http://127.0.0.1:7890'));
      expect(settings.props, contains(60));
    });
  });

  group('VisibilityLevel', () {
    test('should have all expected values', () {
      expect(VisibilityLevel.values.length, 3);
      expect(VisibilityLevel.values, contains(VisibilityLevel.everyone));
      expect(VisibilityLevel.values, contains(VisibilityLevel.contacts));
      expect(VisibilityLevel.values, contains(VisibilityLevel.nobody));
    });

    test('should convert to string correctly', () {
      expect(VisibilityLevel.everyone.name, 'everyone');
      expect(VisibilityLevel.contacts.name, 'contacts');
      expect(VisibilityLevel.nobody.name, 'nobody');
    });
  });

  group('UserSettingsEntity with PrivacySettings', () {
    test('should have default privacy settings', () {
      const userSettings = UserSettingsEntity();

      expect(userSettings.privacy.showReadReceipts, isTrue);
      expect(userSettings.privacy.showTypingIndicator, isTrue);
    });

    test('should support copyWith for privacy settings update', () {
      const original = UserSettingsEntity();

      final updated = original.copyWith(
        privacy: const PrivacySettings(
          showReadReceipts: false,
          showTypingIndicator: false,
        ),
      );

      expect(updated.privacy.showReadReceipts, isFalse);
      expect(updated.privacy.showTypingIndicator, isFalse);
    });
  });
}
