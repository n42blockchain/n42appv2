// Tests for auth_entity.dart — pure Equatable data classes.
// Covers: UserEntity (displayName, copyWith, equality),
// AuthTokenEntity (isExpired), GoogleAuthEntity,
// SecuritySettingsEntity (defaults, copyWith, equality).

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/auth/domain/entities/auth_entity.dart';

void main() {
  // ─────────────────────────────────────────────────
  // UserEntity
  // ─────────────────────────────────────────────────

  group('UserEntity constructor', () {
    test('stores uuid and email', () {
      const e = UserEntity(uuid: 'u1', email: 'alice@example.com');
      expect(e.uuid, 'u1');
      expect(e.email, 'alice@example.com');
    });

    test('optional fields default to null', () {
      const e = UserEntity(uuid: 'u1', email: 'a@b.com');
      expect(e.name, isNull);
      expect(e.avatar, isNull);
      expect(e.description, isNull);
      expect(e.createdAt, isNull);
      expect(e.inviteCode, isNull);
    });

    test('hasWallet defaults to false', () {
      expect(const UserEntity(uuid: 'u', email: 'a@b.com').hasWallet, isFalse);
    });

    test('googleAuthEnabled defaults to false', () {
      expect(
        const UserEntity(uuid: 'u', email: 'a@b.com').googleAuthEnabled,
        isFalse,
      );
    });

    test('stores all optional fields when provided', () {
      final created = DateTime.utc(2024, 1, 1);
      final e = UserEntity(
        uuid: 'u2',
        email: 'bob@example.com',
        name: 'Bob',
        avatar: 'https://avatar.url',
        description: 'A user',
        createdAt: created,
        hasWallet: true,
        googleAuthEnabled: true,
        inviteCode: 'INV123',
      );
      expect(e.name, 'Bob');
      expect(e.avatar, 'https://avatar.url');
      expect(e.description, 'A user');
      expect(e.createdAt, created);
      expect(e.hasWallet, isTrue);
      expect(e.googleAuthEnabled, isTrue);
      expect(e.inviteCode, 'INV123');
    });
  });

  group('UserEntity.displayName', () {
    test('returns name when non-null and non-empty', () {
      const e = UserEntity(uuid: 'u', email: 'a@b.com', name: 'Alice');
      expect(e.displayName, 'Alice');
    });

    test('extracts local part of email when name is null', () {
      const e = UserEntity(uuid: 'u', email: 'alice@example.com');
      expect(e.displayName, 'alice');
    });

    test('returns User when email has no @', () {
      const e = UserEntity(uuid: 'u', email: 'noatsign');
      expect(e.displayName, 'User');
    });

    test('empty name falls back to email extraction', () {
      const e = UserEntity(uuid: 'u', email: 'bob@domain.com', name: '');
      expect(e.displayName, 'bob');
    });
  });

  group('UserEntity.copyWith', () {
    const base = UserEntity(uuid: 'u1', email: 'a@b.com', name: 'Alice');

    test('copies without change when no args', () {
      final copy = base.copyWith();
      expect(copy.uuid, 'u1');
      expect(copy.email, 'a@b.com');
      expect(copy.name, 'Alice');
    });

    test('replaces uuid', () {
      expect(base.copyWith(uuid: 'u99').uuid, 'u99');
    });

    test('replaces email', () {
      expect(base.copyWith(email: 'new@x.com').email, 'new@x.com');
    });

    test('replaces name', () {
      expect(base.copyWith(name: 'Bob').name, 'Bob');
    });

    test('replaces hasWallet', () {
      expect(base.copyWith(hasWallet: true).hasWallet, isTrue);
    });

    test('original is unchanged after copyWith', () {
      base.copyWith(name: 'Changed');
      expect(base.name, 'Alice');
    });

    test('limitation: name cannot be cleared to null via copyWith', () {
      // copyWith uses `??` — passing null silently preserves the existing value.
      // To clear a nullable field, reconstruct the entity directly.
      const withName = UserEntity(uuid: 'u', email: 'a@b.com', name: 'Alice');
      final attempt = withName.copyWith(name: null);
      expect(attempt.name, 'Alice'); // null was silently ignored
    });
  });

  group('UserEntity equality', () {
    test('same fields → equal', () {
      const a = UserEntity(uuid: 'u1', email: 'a@b.com');
      const b = UserEntity(uuid: 'u1', email: 'a@b.com');
      expect(a, equals(b));
    });

    test('different uuid → not equal', () {
      const a = UserEntity(uuid: 'u1', email: 'a@b.com');
      const b = UserEntity(uuid: 'u2', email: 'a@b.com');
      expect(a, isNot(equals(b)));
    });

    test('different email → not equal', () {
      const a = UserEntity(uuid: 'u1', email: 'a@b.com');
      const b = UserEntity(uuid: 'u1', email: 'c@d.com');
      expect(a, isNot(equals(b)));
    });

    test('different hasWallet → not equal', () {
      const a = UserEntity(uuid: 'u', email: 'e', hasWallet: true);
      const b = UserEntity(uuid: 'u', email: 'e', hasWallet: false);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // AuthTokenEntity
  // ─────────────────────────────────────────────────

  group('AuthTokenEntity constructor', () {
    test('stores accessToken and expiresAt', () {
      final expires = DateTime.utc(2030, 1, 1);
      final e = AuthTokenEntity(accessToken: 'tok', expiresAt: expires);
      expect(e.accessToken, 'tok');
      expect(e.expiresAt, expires);
    });

    test('refreshToken defaults to null', () {
      final e = AuthTokenEntity(
        accessToken: 'tok',
        expiresAt: DateTime.utc(2030),
      );
      expect(e.refreshToken, isNull);
    });

    test('stores refreshToken when provided', () {
      final e = AuthTokenEntity(
        accessToken: 'tok',
        refreshToken: 'ref',
        expiresAt: DateTime.utc(2030),
      );
      expect(e.refreshToken, 'ref');
    });
  });

  group('AuthTokenEntity.isExpired', () {
    test('false when expiresAt is in the future', () {
      final future = DateTime.now().add(const Duration(days: 30));
      final e = AuthTokenEntity(accessToken: 'tok', expiresAt: future);
      expect(e.isExpired, isFalse);
    });

    test('true when expiresAt is in the past', () {
      // Use Duration(days: 1) instead of seconds to avoid any clock-skew
      // race between test setup and the DateTime.now() call in isExpired.
      final past = DateTime.now().subtract(const Duration(days: 1));
      final e = AuthTokenEntity(accessToken: 'tok', expiresAt: past);
      expect(e.isExpired, isTrue);
    });
  });

  group('AuthTokenEntity equality', () {
    final date = DateTime.utc(2025, 6, 1);

    test('same fields → equal', () {
      final a = AuthTokenEntity(accessToken: 'tok', expiresAt: date);
      final b = AuthTokenEntity(accessToken: 'tok', expiresAt: date);
      expect(a, equals(b));
    });

    test('different accessToken → not equal', () {
      final a = AuthTokenEntity(accessToken: 'a', expiresAt: date);
      final b = AuthTokenEntity(accessToken: 'b', expiresAt: date);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // GoogleAuthEntity
  // ─────────────────────────────────────────────────

  group('GoogleAuthEntity', () {
    const e = GoogleAuthEntity(
      secret: 'JBSWY3DPEHPK3PXP',
      qrCodeUrl: 'https://chart.googleapis.com/chart?chs=200x200',
      backupCodes: ['code1', 'code2', 'code3'],
    );

    test('stores secret', () {
      expect(e.secret, 'JBSWY3DPEHPK3PXP');
    });

    test('stores qrCodeUrl', () {
      expect(e.qrCodeUrl, 'https://chart.googleapis.com/chart?chs=200x200');
    });

    test('stores backupCodes', () {
      expect(e.backupCodes, ['code1', 'code2', 'code3']);
    });

    test('same fields → equal', () {
      const a = GoogleAuthEntity(
        secret: 'S',
        qrCodeUrl: 'url',
        backupCodes: ['c1'],
      );
      const b = GoogleAuthEntity(
        secret: 'S',
        qrCodeUrl: 'url',
        backupCodes: ['c1'],
      );
      expect(a, equals(b));
    });

    test('different secret → not equal', () {
      const a = GoogleAuthEntity(
        secret: 'A',
        qrCodeUrl: 'url',
        backupCodes: [],
      );
      const b = GoogleAuthEntity(
        secret: 'B',
        qrCodeUrl: 'url',
        backupCodes: [],
      );
      expect(a, isNot(equals(b)));
    });

    test('backupCodes order matters for equality', () {
      // List equality is order-sensitive — ['c1','c2'] ≠ ['c2','c1'].
      const a = GoogleAuthEntity(
        secret: 'S',
        qrCodeUrl: 'url',
        backupCodes: ['c1', 'c2'],
      );
      const b = GoogleAuthEntity(
        secret: 'S',
        qrCodeUrl: 'url',
        backupCodes: ['c2', 'c1'],
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // SecuritySettingsEntity
  // ─────────────────────────────────────────────────

  group('SecuritySettingsEntity defaults', () {
    const e = SecuritySettingsEntity();

    test('lockEnabled defaults to false', () {
      expect(e.lockEnabled, isFalse);
    });

    test('lockPassword defaults to null', () {
      expect(e.lockPassword, isNull);
    });

    test('biometricEnabled defaults to false', () {
      expect(e.biometricEnabled, isFalse);
    });

    test('faceIdEnabled defaults to false', () {
      expect(e.faceIdEnabled, isFalse);
    });

    test('gestureEnabled defaults to false', () {
      expect(e.gestureEnabled, isFalse);
    });

    test('gesturePassword defaults to null', () {
      expect(e.gesturePassword, isNull);
    });

    test('lockTimeout defaults to 30', () {
      expect(e.lockTimeout, 30);
    });
  });

  group('SecuritySettingsEntity.copyWith', () {
    const base = SecuritySettingsEntity();

    test('replaces lockEnabled', () {
      expect(base.copyWith(lockEnabled: true).lockEnabled, isTrue);
    });

    test('replaces biometricEnabled', () {
      expect(base.copyWith(biometricEnabled: true).biometricEnabled, isTrue);
    });

    test('replaces lockTimeout', () {
      expect(base.copyWith(lockTimeout: 60).lockTimeout, 60);
    });

    test('replaces lockPassword', () {
      expect(base.copyWith(lockPassword: '1234').lockPassword, '1234');
    });

    test('original unchanged after copyWith', () {
      base.copyWith(lockEnabled: true);
      expect(base.lockEnabled, isFalse);
    });
  });

  group('SecuritySettingsEntity equality', () {
    test('same defaults → equal', () {
      expect(
        const SecuritySettingsEntity(),
        equals(const SecuritySettingsEntity()),
      );
    });

    test('different lockTimeout → not equal', () {
      expect(
        const SecuritySettingsEntity(lockTimeout: 30),
        isNot(equals(const SecuritySettingsEntity(lockTimeout: 60))),
      );
    });

    test('different biometricEnabled → not equal', () {
      expect(
        const SecuritySettingsEntity(biometricEnabled: true),
        isNot(equals(const SecuritySettingsEntity(biometricEnabled: false))),
      );
    });
  });
}
