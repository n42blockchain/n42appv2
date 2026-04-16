import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/user_profile_entity.dart';

void main() {
  group('UserProfileEntity', () {
    test('should create with required fields and default values', () {
      const entity = UserProfileEntity(userId: '@alice:server.com');

      expect(entity.userId, '@alice:server.com');
      expect(entity.displayName, isNull);
      expect(entity.avatarUrl, isNull);
      expect(entity.statusMessage, isNull);
      expect(entity.email, isNull);
      expect(entity.phoneNumber, isNull);
      expect(entity.createdAt, isNull);
      expect(entity.lastActiveAt, isNull);
      expect(entity.isOnline, isFalse);
      expect(entity.emailVerified, isFalse);
      expect(entity.phoneVerified, isFalse);
    });

    test('should create with all fields', () {
      final now = DateTime(2025, 6, 1);
      final entity = UserProfileEntity(
        userId: '@bob:server.com',
        displayName: 'Bob',
        avatarUrl: 'https://example.com/avatar.jpg',
        statusMessage: 'Hello!',
        email: 'bob@example.com',
        phoneNumber: '+1234567890',
        createdAt: now,
        lastActiveAt: now,
        isOnline: true,
        emailVerified: true,
        phoneVerified: true,
      );

      expect(entity.displayName, 'Bob');
      expect(entity.avatarUrl, 'https://example.com/avatar.jpg');
      expect(entity.statusMessage, 'Hello!');
      expect(entity.email, 'bob@example.com');
      expect(entity.phoneNumber, '+1234567890');
      expect(entity.createdAt, now);
      expect(entity.lastActiveAt, now);
      expect(entity.isOnline, isTrue);
      expect(entity.emailVerified, isTrue);
      expect(entity.phoneVerified, isTrue);
    });

    group('effectiveDisplayName', () {
      test('returns displayName when non-empty', () {
        const entity = UserProfileEntity(
          userId: '@alice:server.com',
          displayName: 'Alice Smith',
        );
        expect(entity.effectiveDisplayName, 'Alice Smith');
      });

      test('extracts localpart from userId when displayName is null', () {
        const entity = UserProfileEntity(userId: '@alice:server.com');
        expect(entity.effectiveDisplayName, 'alice');
      });

      test('extracts localpart from userId when displayName is empty', () {
        const entity = UserProfileEntity(
          userId: '@bob:server.com',
          displayName: '',
        );
        expect(entity.effectiveDisplayName, 'bob');
      });

      test('handles userId without @ prefix', () {
        const entity = UserProfileEntity(userId: 'charlie:server.com');
        expect(entity.effectiveDisplayName, 'charlie');
      });
    });

    group('initials', () {
      test('returns first two chars for single word name', () {
        const entity = UserProfileEntity(userId: '@x:s', displayName: 'Alice');
        expect(entity.initials, 'AL');
      });

      test('returns initials for two-word name', () {
        const entity = UserProfileEntity(
          userId: '@x:s',
          displayName: 'Alice Smith',
        );
        expect(entity.initials, 'AS');
      });

      test('uses userId localpart when displayName is null', () {
        const entity = UserProfileEntity(userId: '@ab:server.com');
        expect(entity.initials, 'AB');
      });
    });

    group('homeserver', () {
      test('returns server part of userId', () {
        const entity = UserProfileEntity(userId: '@alice:server.com');
        expect(entity.homeserver, 'server.com');
      });

      test('returns empty string when no colon in userId', () {
        const entity = UserProfileEntity(userId: 'alice');
        expect(entity.homeserver, '');
      });
    });

    group('username', () {
      test('returns localpart without @ from Matrix userId', () {
        const entity = UserProfileEntity(userId: '@alice:server.com');
        expect(entity.username, 'alice');
      });

      test('returns full string when no @ prefix', () {
        const entity = UserProfileEntity(userId: 'alice:server.com');
        expect(entity.username, 'alice');
      });
    });

    group('props equality', () {
      test('equal entities with same fields', () {
        final time = DateTime(2025, 1, 1);
        final a = UserProfileEntity(userId: '@alice:s', createdAt: time);
        final b = UserProfileEntity(userId: '@alice:s', createdAt: time);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different userId produces different entities', () {
        const a = UserProfileEntity(userId: '@alice:s');
        const b = UserProfileEntity(userId: '@bob:s');

        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('replaces specified fields', () {
        const original = UserProfileEntity(
          userId: '@alice:s',
          displayName: 'Alice',
          isOnline: false,
        );

        final updated = original.copyWith(
          displayName: 'Alice Updated',
          isOnline: true,
        );

        expect(updated.userId, '@alice:s');
        expect(updated.displayName, 'Alice Updated');
        expect(updated.isOnline, isTrue);
      });

      test('preserves unchanged fields', () {
        const original = UserProfileEntity(
          userId: '@alice:s',
          displayName: 'Alice',
          email: 'alice@example.com',
          emailVerified: true,
        );

        final copied = original.copyWith(displayName: 'Changed');

        expect(copied.userId, original.userId);
        expect(copied.email, original.email);
        expect(copied.emailVerified, original.emailVerified);
        expect(copied.displayName, 'Changed');
      });
    });
  });

  group('UserSettingsEntity', () {
    test('creates with defaults', () {
      const settings = UserSettingsEntity();

      expect(settings.notifications.enabled, isTrue);
      expect(settings.privacy.allowStrangerMessage, isTrue);
      expect(settings.chat.autoDownloadImage, isTrue);
    });

    test('copyWith replaces sub-settings', () {
      const original = UserSettingsEntity();
      final updated = original.copyWith(
        notifications: const NotificationSettings(enabled: false),
      );

      expect(updated.notifications.enabled, isFalse);
      expect(updated.privacy, original.privacy);
      expect(updated.chat, original.chat);
    });
  });

  group('VisibilityLevel', () {
    test('has three values', () {
      expect(VisibilityLevel.values.length, 3);
      expect(VisibilityLevel.values, contains(VisibilityLevel.everyone));
      expect(VisibilityLevel.values, contains(VisibilityLevel.contacts));
      expect(VisibilityLevel.values, contains(VisibilityLevel.nobody));
    });
  });

  group('FontSize', () {
    test('has four values', () {
      expect(FontSize.values.length, 4);
    });
  });

  group('SendMessageKey', () {
    test('has two values', () {
      expect(SendMessageKey.values.length, 2);
      expect(SendMessageKey.values, contains(SendMessageKey.enter));
      expect(SendMessageKey.values, contains(SendMessageKey.ctrlEnter));
    });
  });
}
