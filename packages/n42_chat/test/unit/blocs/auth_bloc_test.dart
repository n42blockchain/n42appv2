import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/user_entity.dart';
import 'package:n42_chat/src/domain/repositories/auth_repository.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_event.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_state.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late StreamController<bool> loginStateController;

  const testUser = UserEntity(
    userId: '@user:server.com',
    displayName: 'Test User',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginStateController = StreamController<bool>.broadcast();

    // 设置默认行为
    when(
      () => mockAuthRepository.loginStateStream,
    ).thenAnswer((_) => loginStateController.stream);
    when(() => mockAuthRepository.isLoggedIn).thenReturn(false);
    when(() => mockAuthRepository.currentUser).thenReturn(null);
    when(
      () => mockAuthRepository.getCurrentUserProfile(),
    ).thenAnswer((_) async => null);
  });

  tearDown(() async {
    await loginStateController.close();
  });

  group('AuthBloc', () {
    test('initial state should be AuthState.initial', () async {
      final authBloc = AuthBloc(authRepository: mockAuthRepository);
      expect(authBloc.state.status, AuthStatus.initial);
      expect(authBloc.state.user, isNull);
      await authBloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when login succeeds',
      build: () {
        when(
          () => mockAuthRepository.login(
            homeserver: any(named: 'homeserver'),
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => AuthResult.success(testUser));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          homeserver: 'https://server.com',
          username: 'user',
          password: 'password',
        ),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when login fails',
      build: () {
        when(
          () => mockAuthRepository.login(
            homeserver: any(named: 'homeserver'),
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => AuthResult.failure(
            '用户名或密码错误',
            type: AuthErrorType.invalidCredentials,
          ),
        );
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          homeserver: 'https://server.com',
          username: 'user',
          password: 'wrong',
        ),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having(
              (s) => s.errorType,
              'errorType',
              AuthErrorType.invalidCredentials,
            ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when register succeeds',
      build: () {
        when(
          () => mockAuthRepository.register(
            homeserver: any(named: 'homeserver'),
            username: any(named: 'username'),
            password: any(named: 'password'),
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async => AuthResult.success(testUser));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthRegisterRequested(
          homeserver: 'https://server.com',
          username: 'newuser',
          password: 'password',
        ),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when anonymous register succeeds',
      build: () {
        when(
          () => mockAuthRepository.registerAnonymously(
            homeserver: any(named: 'homeserver'),
            password: any(named: 'password'),
            registrationToken: any(named: 'registrationToken'),
          ),
        ).thenAnswer((_) async => AuthResult.success(testUser));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthAnonymousRegisterRequested(
          homeserver: 'https://server.com',
          password: 'password',
        ),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, unauthenticated] when logout succeeds',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.unauthenticated,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when switching stored account succeeds',
      build: () {
        const switchedUser = UserEntity(
          userId: '@other:server.com',
          displayName: 'Other User',
        );
        when(
          () => mockAuthRepository.switchStoredAccount('@other:server.com'),
        ).thenAnswer((_) async => AuthResult.success(switchedUser));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      seed: () =>
          const AuthState(status: AuthStatus.authenticated, user: testUser),
      act: (bloc) => bloc.add(
        const AuthSwitchStoredAccountRequested(userId: '@other:server.com'),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user?.userId, 'userId', '@other:server.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'keeps previous user when switching stored account fails',
      build: () {
        when(
          () => mockAuthRepository.switchStoredAccount('@other:server.com'),
        ).thenAnswer(
          (_) async => AuthResult.failure(
            '账号数据不完整',
            type: AuthErrorType.tokenExpired,
          ),
        );
        return AuthBloc(authRepository: mockAuthRepository);
      },
      seed: () =>
          const AuthState(status: AuthStatus.authenticated, user: testUser),
      act: (bloc) => bloc.add(
        const AuthSwitchStoredAccountRequested(userId: '@other:server.com'),
      ),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.loading)
            .having((s) => s.user, 'user', testUser),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having((s) => s.user, 'user', testUser)
            .having((s) => s.errorType, 'errorType', AuthErrorType.tokenExpired),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [checking, authenticated] when session restore succeeds',
      build: () {
        when(
          () => mockAuthRepository.restoreSession(),
        ).thenAnswer((_) async => AuthResult.success(testUser));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthRestoreSessionRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.checking),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [checking, unauthenticated] when session restore fails',
      build: () {
        when(
          () => mockAuthRepository.restoreSession(),
        ).thenAnswer((_) async => AuthResult.notLoggedIn());
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthRestoreSessionRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.checking),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.unauthenticated,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, unauthenticated] when loginStateStream forces logout',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        return AuthBloc(authRepository: mockAuthRepository);
      },
      seed: () =>
          const AuthState(status: AuthStatus.authenticated, user: testUser),
      act: (bloc) async {
        loginStateController.add(false);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.unauthenticated,
        ),
      ],
    );
  });

  group('Password Change', () {
    blocTest<AuthBloc, AuthState>(
      'emits [changingPassword, success, loading, unauthenticated] when change password succeeds',
      build: () {
        when(
          () => mockAuthRepository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer((_) async => true);
        // Mock logout since changePassword triggers logout on success
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        AuthChangePasswordRequested(
          oldPassword: 'oldPass123',
          newPassword: 'newPass456',
        ),
      ),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.changePasswordStatus,
          'status',
          ChangePasswordStatus.changing,
        ),
        isA<AuthState>().having(
          (s) => s.changePasswordStatus,
          'status',
          ChangePasswordStatus.success,
        ),
        // After success, logout is triggered
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.unauthenticated,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [changingPassword, failed] when change password fails with wrong password',
      build: () {
        when(
          () => mockAuthRepository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer((_) async => false);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        AuthChangePasswordRequested(
          oldPassword: 'wrongOldPass',
          newPassword: 'newPass456',
        ),
      ),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.changePasswordStatus,
          'status',
          ChangePasswordStatus.changing,
        ),
        isA<AuthState>().having(
          (s) => s.changePasswordStatus,
          'status',
          ChangePasswordStatus.failed,
        ),
      ],
    );
  });

  group('Password Reset', () {
    blocTest<AuthBloc, AuthState>(
      'emits [sendingCode, codeSent] when request reset code succeeds',
      build: () {
        when(
          () => mockAuthRepository.requestPasswordReset(
            homeserver: any(named: 'homeserver'),
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async => true);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthRequestPasswordResetRequested(
          homeserver: 'https://server.com',
          email: 'test@example.com',
        ),
      ),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.passwordResetStatus,
          'status',
          PasswordResetStatus.sendingCode,
        ),
        isA<AuthState>().having(
          (s) => s.passwordResetStatus,
          'status',
          PasswordResetStatus.codeSent,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [sendingCode, failed] when request reset code fails',
      build: () {
        when(
          () => mockAuthRepository.requestPasswordReset(
            homeserver: any(named: 'homeserver'),
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async => false);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthRequestPasswordResetRequested(
          homeserver: 'https://server.com',
          email: 'notfound@example.com',
        ),
      ),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.passwordResetStatus,
          'status',
          PasswordResetStatus.sendingCode,
        ),
        isA<AuthState>().having(
          (s) => s.passwordResetStatus,
          'status',
          PasswordResetStatus.failed,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [resetting, success] when confirm reset succeeds',
      build: () {
        when(
          () => mockAuthRepository.confirmPasswordReset(
            homeserver: any(named: 'homeserver'),
            email: any(named: 'email'),
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer((_) async => true);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthConfirmPasswordResetRequested(
          homeserver: 'https://server.com',
          email: 'test@example.com',
          code: '123456',
          newPassword: 'newPassword123',
        ),
      ),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.passwordResetStatus,
          'status',
          PasswordResetStatus.resetting,
        ),
        isA<AuthState>().having(
          (s) => s.passwordResetStatus,
          'status',
          PasswordResetStatus.success,
        ),
      ],
    );
  });

  group('Email Change', () {
    blocTest<AuthBloc, AuthState>(
      'emits [sendingCode, codeSent] when request email change succeeds',
      build: () {
        when(
          () => mockAuthRepository.requestChangeEmail(
            password: any(named: 'password'),
            newEmail: any(named: 'newEmail'),
          ),
        ).thenAnswer((_) async => true);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthRequestChangeEmailRequested(
          password: 'password123',
          newEmail: 'newemail@example.com',
        ),
      ),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.changeEmailStatus,
          'status',
          ChangeEmailStatus.sendingCode,
        ),
        isA<AuthState>().having(
          (s) => s.changeEmailStatus,
          'status',
          ChangeEmailStatus.codeSent,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [confirming, success] when confirm email change succeeds',
      build: () {
        when(
          () => mockAuthRepository.confirmChangeEmail(
            newEmail: any(named: 'newEmail'),
            code: any(named: 'code'),
          ),
        ).thenAnswer((_) async => true);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const AuthConfirmChangeEmailRequested(
          newEmail: 'newemail@example.com',
          code: '123456',
        ),
      ),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.changeEmailStatus,
          'status',
          ChangeEmailStatus.confirming,
        ),
        isA<AuthState>().having(
          (s) => s.changeEmailStatus,
          'status',
          ChangeEmailStatus.success,
        ),
      ],
    );
  });

  group('Social Login', () {
    // Note: Google and Apple login tests are limited because AuthMethodsService
    // is created internally in AuthBloc. Full integration tests should be used
    // to verify the complete social login flow.

    test('Google login event should have homeserver parameter', () {
      const event = AuthGoogleLoginRequested(homeserver: 'https://server.com');
      expect(event.homeserver, equals('https://server.com'));
    });

    test('Apple login event should have homeserver parameter', () {
      const event = AuthAppleLoginRequested(homeserver: 'https://server.com');
      expect(event.homeserver, equals('https://server.com'));
    });

    test('SSO login event should have homeserver parameter', () {
      const event = AuthSsoLoginRequested(homeserver: 'https://server.com');
      expect(event.homeserver, equals('https://server.com'));
    });

    test('Facebook login event should have homeserver parameter', () {
      const event = AuthFacebookLoginRequested(
        homeserver: 'https://server.com',
      );
      expect(event.homeserver, equals('https://server.com'));
      expect(event.props, contains('https://server.com'));
    });

    test('Twitter login event should have homeserver parameter', () {
      const event = AuthTwitterLoginRequested(homeserver: 'https://server.com');
      expect(event.homeserver, equals('https://server.com'));
      expect(event.props, contains('https://server.com'));
    });

    test('WeChat login event should have homeserver parameter', () {
      const event = AuthWeChatLoginRequested(homeserver: 'https://server.com');
      expect(event.homeserver, equals('https://server.com'));
      expect(event.props, contains('https://server.com'));
    });

    test('loginWithSocialToken should be available in repository', () {
      // Verify the repository interface has the required method
      when(
        () => mockAuthRepository.loginWithSocialToken(
          homeserver: any(named: 'homeserver'),
          provider: any(named: 'provider'),
          idToken: any(named: 'idToken'),
          accessToken: any(named: 'accessToken'),
          email: any(named: 'email'),
          displayName: any(named: 'displayName'),
        ),
      ).thenAnswer((_) async => AuthResult.success(testUser));

      // Method should be callable
      expect(
        () => mockAuthRepository.loginWithSocialToken(
          homeserver: 'https://server.com',
          provider: 'google',
        ),
        returnsNormally,
      );
    });

    test('startSsoLogin should be available in repository', () {
      when(
        () => mockAuthRepository.startSsoLogin(
          homeserver: any(named: 'homeserver'),
          providerId: any(named: 'providerId'),
        ),
      ).thenAnswer((_) async => AuthResult.success(testUser));

      expect(
        () =>
            mockAuthRepository.startSsoLogin(homeserver: 'https://server.com'),
        returnsNormally,
      );
    });

    test('loginWithSocialToken should support facebook provider', () {
      when(
        () => mockAuthRepository.loginWithSocialToken(
          homeserver: any(named: 'homeserver'),
          provider: 'facebook',
          idToken: any(named: 'idToken'),
          accessToken: any(named: 'accessToken'),
          email: any(named: 'email'),
          displayName: any(named: 'displayName'),
        ),
      ).thenAnswer((_) async => AuthResult.success(testUser));

      expect(
        () => mockAuthRepository.loginWithSocialToken(
          homeserver: 'https://server.com',
          provider: 'facebook',
          idToken: 'fb_token',
          accessToken: 'fb_access_token',
        ),
        returnsNormally,
      );
    });

    test('loginWithSocialToken should support twitter provider', () {
      when(
        () => mockAuthRepository.loginWithSocialToken(
          homeserver: any(named: 'homeserver'),
          provider: 'twitter',
          idToken: any(named: 'idToken'),
          accessToken: any(named: 'accessToken'),
          email: any(named: 'email'),
          displayName: any(named: 'displayName'),
        ),
      ).thenAnswer((_) async => AuthResult.success(testUser));

      expect(
        () => mockAuthRepository.loginWithSocialToken(
          homeserver: 'https://server.com',
          provider: 'twitter',
          idToken: 'twitter_auth_token',
          accessToken: 'twitter_token_secret',
        ),
        returnsNormally,
      );
    });

    test('loginWithSocialToken should support wechat provider', () {
      when(
        () => mockAuthRepository.loginWithSocialToken(
          homeserver: any(named: 'homeserver'),
          provider: 'wechat',
          idToken: any(named: 'idToken'),
          accessToken: any(named: 'accessToken'),
          email: any(named: 'email'),
          displayName: any(named: 'displayName'),
        ),
      ).thenAnswer((_) async => AuthResult.success(testUser));

      expect(
        () => mockAuthRepository.loginWithSocialToken(
          homeserver: 'https://server.com',
          provider: 'wechat',
          idToken: 'wechat_auth_code',
        ),
        returnsNormally,
      );
    });
  });

  group('Social Login Events Equality', () {
    test('Facebook login events with same homeserver should be equal', () {
      const event1 = AuthFacebookLoginRequested(
        homeserver: 'https://server.com',
      );
      const event2 = AuthFacebookLoginRequested(
        homeserver: 'https://server.com',
      );
      expect(event1, equals(event2));
    });

    test('Twitter login events with same homeserver should be equal', () {
      const event1 = AuthTwitterLoginRequested(
        homeserver: 'https://server.com',
      );
      const event2 = AuthTwitterLoginRequested(
        homeserver: 'https://server.com',
      );
      expect(event1, equals(event2));
    });

    test('WeChat login events with same homeserver should be equal', () {
      const event1 = AuthWeChatLoginRequested(homeserver: 'https://server.com');
      const event2 = AuthWeChatLoginRequested(homeserver: 'https://server.com');
      expect(event1, equals(event2));
    });

    test('Different social login events should not be equal', () {
      const facebookEvent = AuthFacebookLoginRequested(
        homeserver: 'https://server.com',
      );
      const twitterEvent = AuthTwitterLoginRequested(
        homeserver: 'https://server.com',
      );
      const wechatEvent = AuthWeChatLoginRequested(
        homeserver: 'https://server.com',
      );

      expect(facebookEvent, isNot(equals(twitterEvent)));
      expect(twitterEvent, isNot(equals(wechatEvent)));
      expect(facebookEvent, isNot(equals(wechatEvent)));
    });
  });
}
