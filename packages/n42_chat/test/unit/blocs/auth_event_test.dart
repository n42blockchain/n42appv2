// Tests for AuthEvent subclasses in auth_event.dart.
// Pure Dart Equatable event classes — no platform deps invoked.
// UpdateAvatar contains Uint8List (non-const): tested via runtime reference.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Parameterless events
  // ─────────────────────────────────────────────────

  for (final pair in [
    ['AuthCheckRequested', () => const AuthCheckRequested()],
    ['AuthLogoutRequested', () => const AuthLogoutRequested()],
    ['AuthRestoreSessionRequested', () => const AuthRestoreSessionRequested()],
    ['AuthErrorCleared', () => const AuthErrorCleared()],
    ['LoadUserProfileData', () => const LoadUserProfileData()],
    ['AuthGetBoundEmailRequested', () => const AuthGetBoundEmailRequested()],
    ['AuthBiometricLoginRequested', () => const AuthBiometricLoginRequested()],
    [
      'AuthCheckBiometricAvailability',
      () => const AuthCheckBiometricAvailability(),
    ],
    ['AuthEnableBiometricLogin', () => const AuthEnableBiometricLogin()],
    ['AuthDisableBiometricLogin', () => const AuthDisableBiometricLogin()],
  ]) {
    final name = pair[0] as String;
    final factory = pair[1] as AuthEvent Function();
    group(name, () {
      test('is an AuthEvent', () => expect(factory(), isA<AuthEvent>()));
      test(
        'two instances are equal',
        () => expect(factory(), equals(factory())),
      );
    });
  }

  // ─────────────────────────────────────────────────
  // AuthLoginRequested
  // ─────────────────────────────────────────────────

  group('AuthLoginRequested', () {
    test('stores required fields', () {
      const e = AuthLoginRequested(
        homeserver: 'https://matrix.org',
        username: 'alice',
        password: 'secret',
      );
      expect(e.homeserver, 'https://matrix.org');
      expect(e.username, 'alice');
      expect(e.password, 'secret');
    });

    test('rememberMe defaults to true', () {
      expect(
        const AuthLoginRequested(
          homeserver: 'h',
          username: 'u',
          password: 'p',
        ).rememberMe,
        isTrue,
      );
    });

    test('stores rememberMe=false', () {
      const e = AuthLoginRequested(
        homeserver: 'h',
        username: 'u',
        password: 'p',
        rememberMe: false,
      );
      expect(e.rememberMe, isFalse);
    });

    test('same fields → equal', () {
      expect(
        const AuthLoginRequested(homeserver: 'h', username: 'u', password: 'p'),
        equals(
          const AuthLoginRequested(
            homeserver: 'h',
            username: 'u',
            password: 'p',
          ),
        ),
      );
    });

    test('different username → not equal', () {
      expect(
        const AuthLoginRequested(homeserver: 'h', username: 'a', password: 'p'),
        isNot(
          equals(
            const AuthLoginRequested(
              homeserver: 'h',
              username: 'b',
              password: 'p',
            ),
          ),
        ),
      );
    });

    test('is an AuthEvent', () {
      expect(
        const AuthLoginRequested(homeserver: 'h', username: 'u', password: 'p'),
        isA<AuthEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // AuthRegisterRequested
  // ─────────────────────────────────────────────────

  group('AuthRegisterRequested', () {
    test('stores required fields', () {
      const e = AuthRegisterRequested(
        homeserver: 'h',
        username: 'u',
        password: 'p',
      );
      expect(e.homeserver, 'h');
      expect(e.username, 'u');
      expect(e.password, 'p');
    });

    test('email defaults to null', () {
      expect(
        const AuthRegisterRequested(
          homeserver: 'h',
          username: 'u',
          password: 'p',
        ).email,
        isNull,
      );
    });

    test('registrationToken defaults to null', () {
      expect(
        const AuthRegisterRequested(
          homeserver: 'h',
          username: 'u',
          password: 'p',
        ).registrationToken,
        isNull,
      );
    });

    test('stores optional fields', () {
      const e = AuthRegisterRequested(
        homeserver: 'h',
        username: 'u',
        password: 'p',
        email: 'a@b.com',
        registrationToken: 'tok123',
      );
      expect(e.email, 'a@b.com');
      expect(e.registrationToken, 'tok123');
    });

    test('same fields → equal', () {
      expect(
        const AuthRegisterRequested(
          homeserver: 'h',
          username: 'u',
          password: 'p',
        ),
        equals(
          const AuthRegisterRequested(
            homeserver: 'h',
            username: 'u',
            password: 'p',
          ),
        ),
      );
    });

    test('is an AuthEvent', () {
      expect(
        const AuthRegisterRequested(
          homeserver: 'h',
          username: 'u',
          password: 'p',
        ),
        isA<AuthEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // AuthHomeserverCheckRequested
  // ─────────────────────────────────────────────────

  group('AuthHomeserverCheckRequested', () {
    test('stores homeserver', () {
      expect(
        const AuthHomeserverCheckRequested('https://matrix.org').homeserver,
        'https://matrix.org',
      );
    });

    test('same homeserver → equal', () {
      expect(
        const AuthHomeserverCheckRequested('h'),
        equals(const AuthHomeserverCheckRequested('h')),
      );
    });

    test('different homeserver → not equal', () {
      expect(
        const AuthHomeserverCheckRequested('a'),
        isNot(equals(const AuthHomeserverCheckRequested('b'))),
      );
    });

    test('is an AuthEvent', () {
      expect(const AuthHomeserverCheckRequested('h'), isA<AuthEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // AuthTokenLoginRequested
  // ─────────────────────────────────────────────────

  group('AuthTokenLoginRequested', () {
    test('stores all fields', () {
      const e = AuthTokenLoginRequested(
        homeserver: 'https://matrix.org',
        accessToken: 'tok_abc',
        userId: '@alice:matrix.org',
        deviceId: 'dev_001',
      );
      expect(e.homeserver, 'https://matrix.org');
      expect(e.accessToken, 'tok_abc');
      expect(e.userId, '@alice:matrix.org');
      expect(e.deviceId, 'dev_001');
    });

    test('same fields → equal', () {
      expect(
        const AuthTokenLoginRequested(
          homeserver: 'h',
          accessToken: 't',
          userId: 'u',
          deviceId: 'd',
        ),
        equals(
          const AuthTokenLoginRequested(
            homeserver: 'h',
            accessToken: 't',
            userId: 'u',
            deviceId: 'd',
          ),
        ),
      );
    });

    test('different accessToken → not equal', () {
      expect(
        const AuthTokenLoginRequested(
          homeserver: 'h',
          accessToken: 'a',
          userId: 'u',
          deviceId: 'd',
        ),
        isNot(
          equals(
            const AuthTokenLoginRequested(
              homeserver: 'h',
              accessToken: 'b',
              userId: 'u',
              deviceId: 'd',
            ),
          ),
        ),
      );
    });

    test('is an AuthEvent', () {
      expect(
        const AuthTokenLoginRequested(
          homeserver: 'h',
          accessToken: 't',
          userId: 'u',
          deviceId: 'd',
        ),
        isA<AuthEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // UpdateAvatar (Uint8List — runtime reference)
  // ─────────────────────────────────────────────────

  group('UpdateAvatar', () {
    test('stores avatarBytes and filename', () {
      final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF]);
      final e = UpdateAvatar(avatarBytes: bytes, filename: 'avatar.jpg');
      expect(e.avatarBytes, bytes);
      expect(e.filename, 'avatar.jpg');
    });

    test('is an AuthEvent', () {
      expect(
        UpdateAvatar(avatarBytes: Uint8List(0), filename: 'f.jpg'),
        isA<AuthEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // UpdateDisplayName
  // ─────────────────────────────────────────────────

  group('UpdateDisplayName', () {
    test('stores displayName', () {
      expect(const UpdateDisplayName('Alice').displayName, 'Alice');
    });

    test('same name → equal', () {
      expect(
        const UpdateDisplayName('n'),
        equals(const UpdateDisplayName('n')),
      );
    });

    test('different name → not equal', () {
      expect(
        const UpdateDisplayName('a'),
        isNot(equals(const UpdateDisplayName('b'))),
      );
    });

    test('is an AuthEvent', () {
      expect(const UpdateDisplayName('n'), isA<AuthEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // UpdateUserProfile
  // ─────────────────────────────────────────────────

  group('UpdateUserProfile', () {
    test('all fields default to null', () {
      const e = UpdateUserProfile();
      expect(e.displayName, isNull);
      expect(e.signature, isNull);
      expect(e.gender, isNull);
      expect(e.region, isNull);
      expect(e.pokeText, isNull);
      expect(e.ringtone, isNull);
      expect(e.avatarDecorationPreset, isNull);
      expect(e.nftContractAddress, isNull);
      expect(e.nftTokenId, isNull);
      expect(e.nftChainId, isNull);
      expect(e.nftImageUrl, isNull);
      expect(e.clearNftAvatar, isFalse);
    });

    test('stores provided fields', () {
      const e = UpdateUserProfile(
        displayName: 'Alice',
        signature: 'Dev @ N42',
        gender: 'female',
        region: 'US',
        pokeText: 'Poke me!',
        ringtone: 'default',
        avatarDecorationPreset: 'aurora',
        nftContractAddress: '0xabc',
        nftTokenId: 9,
        nftChainId: 1,
        nftImageUrl: 'https://example.com/nft.png',
        clearNftAvatar: true,
      );
      expect(e.displayName, 'Alice');
      expect(e.signature, 'Dev @ N42');
      expect(e.gender, 'female');
      expect(e.region, 'US');
      expect(e.pokeText, 'Poke me!');
      expect(e.ringtone, 'default');
      expect(e.avatarDecorationPreset, 'aurora');
      expect(e.nftContractAddress, '0xabc');
      expect(e.nftTokenId, 9);
      expect(e.nftChainId, 1);
      expect(e.nftImageUrl, 'https://example.com/nft.png');
      expect(e.clearNftAvatar, isTrue);
    });

    test('same fields → equal', () {
      expect(
        const UpdateUserProfile(displayName: 'Alice'),
        equals(const UpdateUserProfile(displayName: 'Alice')),
      );
    });

    test('different displayName → not equal', () {
      expect(
        const UpdateUserProfile(displayName: 'Alice'),
        isNot(equals(const UpdateUserProfile(displayName: 'Bob'))),
      );
    });

    test('is an AuthEvent', () {
      expect(const UpdateUserProfile(), isA<AuthEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // Social login events (single homeserver field)
  // ─────────────────────────────────────────────────

  group('AuthSsoLoginRequested', () {
    test('stores homeserver', () {
      expect(const AuthSsoLoginRequested(homeserver: 'h').homeserver, 'h');
    });

    test('providerId defaults to null', () {
      expect(const AuthSsoLoginRequested(homeserver: 'h').providerId, isNull);
    });

    test('stores providerId', () {
      expect(
        const AuthSsoLoginRequested(
          homeserver: 'h',
          providerId: 'google',
        ).providerId,
        'google',
      );
    });

    test('same fields → equal', () {
      expect(
        const AuthSsoLoginRequested(homeserver: 'h', providerId: 'g'),
        equals(const AuthSsoLoginRequested(homeserver: 'h', providerId: 'g')),
      );
    });

    test('is an AuthEvent', () {
      expect(const AuthSsoLoginRequested(homeserver: 'h'), isA<AuthEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // Password management events
  // ─────────────────────────────────────────────────

  group('AuthRequestPasswordResetRequested', () {
    test('stores homeserver and email', () {
      const e = AuthRequestPasswordResetRequested(
        homeserver: 'h',
        email: 'a@b.com',
      );
      expect(e.homeserver, 'h');
      expect(e.email, 'a@b.com');
    });

    test('same fields → equal', () {
      expect(
        const AuthRequestPasswordResetRequested(homeserver: 'h', email: 'e'),
        equals(
          const AuthRequestPasswordResetRequested(homeserver: 'h', email: 'e'),
        ),
      );
    });

    test('is an AuthEvent', () {
      expect(
        const AuthRequestPasswordResetRequested(homeserver: 'h', email: 'e'),
        isA<AuthEvent>(),
      );
    });
  });

  group('AuthConfirmPasswordResetRequested', () {
    test('stores all fields', () {
      const e = AuthConfirmPasswordResetRequested(
        homeserver: 'h',
        email: 'e@e.com',
        code: '123',
        newPassword: 'pw',
      );
      expect(e.homeserver, 'h');
      expect(e.email, 'e@e.com');
      expect(e.code, '123');
      expect(e.newPassword, 'pw');
    });

    test('same fields → equal', () {
      expect(
        const AuthConfirmPasswordResetRequested(
          homeserver: 'h',
          email: 'e',
          code: 'c',
          newPassword: 'p',
        ),
        equals(
          const AuthConfirmPasswordResetRequested(
            homeserver: 'h',
            email: 'e',
            code: 'c',
            newPassword: 'p',
          ),
        ),
      );
    });

    test('is an AuthEvent', () {
      expect(
        const AuthConfirmPasswordResetRequested(
          homeserver: 'h',
          email: 'e',
          code: 'c',
          newPassword: 'p',
        ),
        isA<AuthEvent>(),
      );
    });
  });

  group('AuthChangePasswordRequested', () {
    test('stores old and new password', () {
      final e = AuthChangePasswordRequested(
        oldPassword: 'old123',
        newPassword: 'new456',
      );
      expect(e.oldPassword, 'old123');
      expect(e.newPassword, 'new456');
    });

    // 每个实例含唯一 _id，两次构造永远不相等（防止 BLoC Equatable 去重）
    test('same fields → NOT equal (each instance is unique)', () {
      expect(
        AuthChangePasswordRequested(oldPassword: 'o', newPassword: 'n'),
        isNot(
          equals(
            AuthChangePasswordRequested(oldPassword: 'o', newPassword: 'n'),
          ),
        ),
      );
    });

    test('different newPassword → not equal', () {
      expect(
        AuthChangePasswordRequested(oldPassword: 'o', newPassword: 'a'),
        isNot(
          equals(
            AuthChangePasswordRequested(oldPassword: 'o', newPassword: 'b'),
          ),
        ),
      );
    });

    test('is an AuthEvent', () {
      expect(
        AuthChangePasswordRequested(oldPassword: 'o', newPassword: 'n'),
        isA<AuthEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // Email management events
  // ─────────────────────────────────────────────────

  group('AuthRequestChangeEmailRequested', () {
    test('stores password and newEmail', () {
      const e = AuthRequestChangeEmailRequested(
        password: 'pw',
        newEmail: 'new@e.com',
      );
      expect(e.password, 'pw');
      expect(e.newEmail, 'new@e.com');
    });

    test('same fields → equal', () {
      expect(
        const AuthRequestChangeEmailRequested(password: 'pw', newEmail: 'e'),
        equals(
          const AuthRequestChangeEmailRequested(password: 'pw', newEmail: 'e'),
        ),
      );
    });

    test('is an AuthEvent', () {
      expect(
        const AuthRequestChangeEmailRequested(password: 'pw', newEmail: 'e'),
        isA<AuthEvent>(),
      );
    });
  });

  group('AuthConfirmChangeEmailRequested', () {
    test('stores newEmail and code', () {
      const e = AuthConfirmChangeEmailRequested(
        newEmail: 'new@e.com',
        code: '654321',
      );
      expect(e.newEmail, 'new@e.com');
      expect(e.code, '654321');
    });

    test('same fields → equal', () {
      expect(
        const AuthConfirmChangeEmailRequested(newEmail: 'e', code: 'c'),
        equals(const AuthConfirmChangeEmailRequested(newEmail: 'e', code: 'c')),
      );
    });

    test('is an AuthEvent', () {
      expect(
        const AuthConfirmChangeEmailRequested(newEmail: 'e', code: 'c'),
        isA<AuthEvent>(),
      );
    });
  });
}
