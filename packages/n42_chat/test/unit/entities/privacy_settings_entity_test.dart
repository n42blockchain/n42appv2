// Tests for PrivacySettingsEntity, PrivacyLevel enum, and PrivacyLevelExtension.
// Pure Dart / Equatable — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/privacy_settings_entity.dart';

void main() {
  // ─────────────────────────────────────────────────
  // PrivacyLevel enum
  // ─────────────────────────────────────────────────

  group('PrivacyLevel', () {
    test('has three values: everyone, contacts, nobody', () {
      expect(PrivacyLevel.values.length, 3);
      expect(PrivacyLevel.values, containsAll([
        PrivacyLevel.everyone,
        PrivacyLevel.contacts,
        PrivacyLevel.nobody,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // PrivacyLevelExtension
  // ─────────────────────────────────────────────────

  group('PrivacyLevelExtension.displayName', () {
    test('everyone displayName', () {
      expect(PrivacyLevel.everyone.displayName, '所有人');
    });

    test('contacts displayName', () {
      expect(PrivacyLevel.contacts.displayName, '仅联系人');
    });

    test('nobody displayName', () {
      expect(PrivacyLevel.nobody.displayName, '仅自己');
    });
  });

  group('PrivacyLevelExtension.hasAccess', () {
    test('everyone grants access to non-contacts', () {
      expect(PrivacyLevel.everyone.hasAccess(isContact: false), isTrue);
    });

    test('everyone grants access to contacts', () {
      expect(PrivacyLevel.everyone.hasAccess(isContact: true), isTrue);
    });

    test('contacts grants access to contacts', () {
      expect(PrivacyLevel.contacts.hasAccess(isContact: true), isTrue);
    });

    test('contacts denies access to non-contacts', () {
      expect(PrivacyLevel.contacts.hasAccess(isContact: false), isFalse);
    });

    test('nobody denies access regardless of contact status', () {
      expect(PrivacyLevel.nobody.hasAccess(isContact: true), isFalse);
      expect(PrivacyLevel.nobody.hasAccess(isContact: false), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // PrivacySettingsEntity — default constructor
  // ─────────────────────────────────────────────────

  group('PrivacySettingsEntity default constructor', () {
    const entity = PrivacySettingsEntity();

    test('showOnlineStatus defaults to true', () {
      expect(entity.showOnlineStatus, isTrue);
    });

    test('sendReadReceipts defaults to true', () {
      expect(entity.sendReadReceipts, isTrue);
    });

    test('sendTypingIndicator defaults to true', () {
      expect(entity.sendTypingIndicator, isTrue);
    });

    test('showLastSeenTime defaults to true', () {
      expect(entity.showLastSeenTime, isTrue);
    });

    test('avatarVisibility defaults to everyone', () {
      expect(entity.avatarVisibility, PrivacyLevel.everyone);
    });

    test('blockStrangerMessages defaults to false', () {
      expect(entity.blockStrangerMessages, isFalse);
    });

    test('allowSearchByContact defaults to true', () {
      expect(entity.allowSearchByContact, isTrue);
    });

    test('allowSearchByUsername defaults to true', () {
      expect(entity.allowSearchByUsername, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // Static presets
  // ─────────────────────────────────────────────────

  group('PrivacySettingsEntity.defaultSettings', () {
    test('is equal to default constructor', () {
      expect(PrivacySettingsEntity.defaultSettings, const PrivacySettingsEntity());
    });
  });

  group('PrivacySettingsEntity.highPrivacy', () {
    const hp = PrivacySettingsEntity.highPrivacy;

    test('showOnlineStatus is false', () {
      expect(hp.showOnlineStatus, isFalse);
    });

    test('sendReadReceipts is false', () {
      expect(hp.sendReadReceipts, isFalse);
    });

    test('sendTypingIndicator is false', () {
      expect(hp.sendTypingIndicator, isFalse);
    });

    test('showLastSeenTime is false', () {
      expect(hp.showLastSeenTime, isFalse);
    });

    test('avatarVisibility is contacts', () {
      expect(hp.avatarVisibility, PrivacyLevel.contacts);
    });

    test('blockStrangerMessages is true', () {
      expect(hp.blockStrangerMessages, isTrue);
    });

    test('allowSearchByContact is false', () {
      expect(hp.allowSearchByContact, isFalse);
    });
  });

  group('PrivacySettingsEntity.mediumPrivacy', () {
    const mp = PrivacySettingsEntity.mediumPrivacy;

    test('showOnlineStatus is true', () {
      expect(mp.showOnlineStatus, isTrue);
    });

    test('sendTypingIndicator is false', () {
      expect(mp.sendTypingIndicator, isFalse);
    });

    test('profileVisibility is contacts', () {
      expect(mp.profileVisibility, PrivacyLevel.contacts);
    });

    test('avatarVisibility is everyone', () {
      expect(mp.avatarVisibility, PrivacyLevel.everyone);
    });
  });

  // ─────────────────────────────────────────────────
  // Computed getters
  // ─────────────────────────────────────────────────

  group('PrivacySettingsEntity.isFullyPrivate', () {
    test('highPrivacy preset is fully private', () {
      expect(PrivacySettingsEntity.highPrivacy.isFullyPrivate, isTrue);
    });

    test('default settings are NOT fully private', () {
      expect(PrivacySettingsEntity.defaultSettings.isFullyPrivate, isFalse);
    });

    test('partially-off settings are not fully private', () {
      const partial = PrivacySettingsEntity(
        showOnlineStatus: false,
        sendReadReceipts: true,
      );
      expect(partial.isFullyPrivate, isFalse);
    });
  });

  group('PrivacySettingsEntity.isFullyPublic', () {
    test('default settings are fully public', () {
      expect(PrivacySettingsEntity.defaultSettings.isFullyPublic, isTrue);
    });

    test('highPrivacy is NOT fully public', () {
      expect(PrivacySettingsEntity.highPrivacy.isFullyPublic, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable props
  // ─────────────────────────────────────────────────

  group('PrivacySettingsEntity equality', () {
    test('two identical instances are equal', () {
      const a = PrivacySettingsEntity();
      const b = PrivacySettingsEntity();
      expect(a, equals(b));
    });

    test('different showOnlineStatus breaks equality', () {
      const a = PrivacySettingsEntity(showOnlineStatus: true);
      const b = PrivacySettingsEntity(showOnlineStatus: false);
      expect(a, isNot(equals(b)));
    });

    test('different avatarVisibility breaks equality', () {
      const a = PrivacySettingsEntity(avatarVisibility: PrivacyLevel.everyone);
      const b = PrivacySettingsEntity(avatarVisibility: PrivacyLevel.nobody);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith
  // ─────────────────────────────────────────────────

  group('PrivacySettingsEntity.copyWith', () {
    test('copies all fields when nothing is overridden', () {
      const original = PrivacySettingsEntity.highPrivacy;
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('overrides single boolean field', () {
      const original = PrivacySettingsEntity();
      final modified = original.copyWith(showOnlineStatus: false);
      expect(modified.showOnlineStatus, isFalse);
      expect(modified.sendReadReceipts, original.sendReadReceipts);
    });

    test('overrides PrivacyLevel field', () {
      const original = PrivacySettingsEntity();
      final modified = original.copyWith(avatarVisibility: PrivacyLevel.nobody);
      expect(modified.avatarVisibility, PrivacyLevel.nobody);
      expect(modified.profileVisibility, original.profileVisibility);
    });
  });

  // ─────────────────────────────────────────────────
  // toMap / fromMap
  // ─────────────────────────────────────────────────

  group('PrivacySettingsEntity.toMap', () {
    test('includes all expected keys', () {
      final map = PrivacySettingsEntity.defaultSettings.toMap();
      expect(map.keys, containsAll([
        'showOnlineStatus', 'sendReadReceipts', 'sendTypingIndicator',
        'showLastSeenTime', 'avatarVisibility', 'profileVisibility',
        'messagePermission', 'groupInvitePermission', 'callPermission',
        'blockStrangerMessages', 'allowSearchByContact', 'allowSearchByUsername',
      ]));
    });

    test('PrivacyLevel is serialized as enum name string', () {
      const entity = PrivacySettingsEntity(avatarVisibility: PrivacyLevel.contacts);
      final map = entity.toMap();
      expect(map['avatarVisibility'], 'contacts');
    });

    test('bool fields are serialized as booleans', () {
      final map = PrivacySettingsEntity.defaultSettings.toMap();
      expect(map['showOnlineStatus'], isA<bool>());
    });
  });

  group('PrivacySettingsEntity.fromMap', () {
    test('deserializes all fields', () {
      final map = PrivacySettingsEntity.defaultSettings.toMap();
      final restored = PrivacySettingsEntity.fromMap(map);
      expect(restored, equals(PrivacySettingsEntity.defaultSettings));
    });

    test('missing bool fields default to true/false per spec', () {
      final entity = PrivacySettingsEntity.fromMap({});
      expect(entity.showOnlineStatus, isTrue);
      expect(entity.blockStrangerMessages, isFalse);
    });

    test('missing PrivacyLevel fields default to everyone', () {
      final entity = PrivacySettingsEntity.fromMap({});
      expect(entity.avatarVisibility, PrivacyLevel.everyone);
    });

    test('fromMap handles PrivacyLevel string correctly', () {
      final entity = PrivacySettingsEntity.fromMap({
        'avatarVisibility': 'nobody',
        'profileVisibility': 'contacts',
      });
      expect(entity.avatarVisibility, PrivacyLevel.nobody);
      expect(entity.profileVisibility, PrivacyLevel.contacts);
    });

    test('unknown PrivacyLevel string defaults to everyone', () {
      final entity = PrivacySettingsEntity.fromMap({
        'avatarVisibility': 'invalid_value',
      });
      expect(entity.avatarVisibility, PrivacyLevel.everyone);
    });
  });

  group('PrivacySettingsEntity toMap/fromMap roundtrip', () {
    test('highPrivacy roundtrip preserves all fields', () {
      final map = PrivacySettingsEntity.highPrivacy.toMap();
      final restored = PrivacySettingsEntity.fromMap(map);
      expect(restored, equals(PrivacySettingsEntity.highPrivacy));
    });

    test('mediumPrivacy roundtrip preserves all fields', () {
      final map = PrivacySettingsEntity.mediumPrivacy.toMap();
      final restored = PrivacySettingsEntity.fromMap(map);
      expect(restored, equals(PrivacySettingsEntity.mediumPrivacy));
    });
  });
}
