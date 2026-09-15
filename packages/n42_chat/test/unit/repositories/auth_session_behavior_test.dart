import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/secure_storage_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_auth_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/remote/social_auth_api.dart';
import 'package:n42_chat/src/data/repositories/auth_repository_impl.dart';
import 'package:n42_chat/src/domain/repositories/auth_repository.dart';

class MockAuth extends Mock implements MatrixAuthDataSource {}

class MockStorage extends Mock implements SecureStorageDataSource {}

class MockManager extends Mock implements MatrixClientManager {}

class MockSocial extends Mock implements SocialAuthApi {}

class MockClient extends Mock implements Client {}

void main() {
  late MockAuth auth;
  late MockStorage storage;
  late MockManager manager;
  late AuthRepositoryImpl repository;
  late StreamController<LoginState> sdk;
  const session = {
    'homeserver': 'https://hs.test',
    'accessToken': 'fixture-token',
    'userId': '@alice:hs.test',
    'deviceId': 'device',
  };
  LoginResponse response({
    String token = 'fixture-token',
    String user = '@alice:hs.test',
  }) => LoginResponse.fromJson({
    'access_token': token,
    'user_id': user,
    'device_id': 'device',
  });
  MatrixException error(String code) => MatrixException(
    http.Response(
      jsonEncode({'errcode': code, 'error': 'Request rejected'}),
      403,
    ),
  );
  Future<AuthResult> login({bool remember = true}) => repository.login(
    homeserver: 'https://hs.test',
    username: 'alice',
    password: 'fixture-password',
    rememberMe: remember,
  );
  Future<AuthResult> tokenLogin() => repository.loginWithToken(
    homeserver: session['homeserver']!,
    accessToken: session['accessToken']!,
    userId: session['userId']!,
    deviceId: session['deviceId']!,
  );
  for (final anonymous in [false, true]) {
    for (final message in [
      'M_FORBIDDEN: Registration has been disabled',
      'Registration is disabled',
    ]) {
      test(
        'disabled registration is explicit (anonymous: $anonymous, $message)',
        () async {
          when(
            () => auth.isUsernameAvailable(any(), any()),
          ).thenAnswer((_) async => true);
          when(
            () => auth.register(
              homeserver: any(named: 'homeserver'),
              username: any(named: 'username'),
              password: any(named: 'password'),
              email: any(named: 'email'),
              registrationToken: any(named: 'registrationToken'),
            ),
          ).thenThrow(
            MatrixException(
              http.Response(
                jsonEncode({'errcode': 'M_FORBIDDEN', 'error': message}),
                403,
              ),
            ),
          );
          final result = anonymous
              ? await repository.registerAnonymously(
                  homeserver: 'https://hs.test',
                  password: 'fixture-password',
                )
              : await repository.register(
                  homeserver: 'https://hs.test',
                  username: 'alice',
                  password: 'fixture-password',
                );
          expect(result.success, isFalse);
          expect(result.errorType, AuthErrorType.registrationDisabled);
          expect(result.errorMessage, message);
        },
      );
    }
  }
  test(
    'registration rejection is not reported as a login password error',
    () async {
      when(
        () => auth.register(
          homeserver: any(named: 'homeserver'),
          username: any(named: 'username'),
          password: any(named: 'password'),
          email: any(named: 'email'),
          registrationToken: any(named: 'registrationToken'),
        ),
      ).thenThrow(error('M_FORBIDDEN'));
      final result = await repository.register(
        homeserver: 'https://hs.test',
        username: 'alice',
        password: 'Password123!',
      );
      expect(result.success, isFalse);
      expect(result.errorType, AuthErrorType.serverError);
      expect(result.errorMessage, 'Request rejected');
    },
  );

  setUpAll(() => registerFallbackValue(Uint8List(0)));
  setUp(() {
    auth = MockAuth();
    storage = MockStorage();
    manager = MockManager();
    sdk = StreamController<LoginState>.broadcast();
    when(() => auth.clientManager).thenReturn(manager);
    when(() => auth.isLoggedIn).thenReturn(false);
    when(() => manager.client).thenReturn(null);
    when(() => manager.onLoginStateChanged).thenAnswer((_) => sdk.stream);
    when(manager.startSync).thenAnswer((_) async {});
    when(storage.getSession).thenAnswer((_) async => null);
    when(storage.getAccounts).thenAnswer((_) async => {});
    when(
      () => storage.saveSession(
        homeserver: any(named: 'homeserver'),
        accessToken: any(named: 'accessToken'),
        userId: any(named: 'userId'),
        deviceId: any(named: 'deviceId'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => storage.addAccount(
        userId: any(named: 'userId'),
        homeserver: any(named: 'homeserver'),
        accessToken: any(named: 'accessToken'),
        deviceId: any(named: 'deviceId'),
        displayName: any(named: 'displayName'),
        avatarUrl: any(named: 'avatarUrl'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => storage.saveCredentials(
        homeserver: any(named: 'homeserver'),
        username: any(named: 'username'),
      ),
    ).thenAnswer((_) async => true);
    when(storage.clearCredentials).thenAnswer((_) async {});
    when(storage.clearSession).thenAnswer((_) async {});
    when(storage.isBiometricEnabled).thenAnswer((_) async => false);
    when(
      () => auth.loginWithPassword(
        homeserver: any(named: 'homeserver'),
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => response());
    when(
      () => auth.loginWithToken(
        homeserver: any(named: 'homeserver'),
        accessToken: any(named: 'accessToken'),
        userId: any(named: 'userId'),
        deviceId: any(named: 'deviceId'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => auth.loginWithLoginToken(
        homeserver: any(named: 'homeserver'),
        loginToken: any(named: 'loginToken'),
      ),
    ).thenAnswer((_) async => response());
    when(auth.logout).thenAnswer((_) async {});
    repository = AuthRepositoryImpl(
      authDataSource: auth,
      secureStorage: storage,
      socialAuthApi: MockSocial(),
    );
  });
  tearDown(() async {
    repository.dispose();
    await sdk.close();
  });

  test(
    'password login persists a session, emits login and starts sync',
    () async {
      final event = repository.loginStateStream.first;
      final result = await login();
      expect(result.success, isTrue);
      expect(result.user!.userId, '@alice:hs.test');
      expect(await event, isTrue);
      verify(
        () => storage.saveSession(
          homeserver: 'https://hs.test',
          accessToken: 'fixture-token',
          userId: '@alice:hs.test',
          deviceId: 'device',
        ),
      ).called(1);
      verify(
        () => storage.saveCredentials(
          homeserver: 'https://hs.test',
          username: 'alice',
        ),
      ).called(1);
      verify(manager.startSync).called(1);
    },
  );
  test('login without remember-me clears older credentials', () async {
    expect((await login(remember: false)).success, isTrue);
    verify(storage.clearCredentials).called(1);
    verifyNever(
      () => storage.saveCredentials(
        homeserver: any(named: 'homeserver'),
        username: any(named: 'username'),
      ),
    );
  });
  for (final invalid in [response(token: ''), response(user: '')]) {
    test(
      'incomplete login response does not persist credentials (${invalid.userId})',
      () async {
        when(
          () => auth.loginWithPassword(
            homeserver: any(named: 'homeserver'),
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => invalid);
        expect((await login()).errorType, AuthErrorType.serverError);
        verifyNever(
          () => storage.saveSession(
            homeserver: any(named: 'homeserver'),
            accessToken: any(named: 'accessToken'),
            userId: any(named: 'userId'),
            deviceId: any(named: 'deviceId'),
          ),
        );
      },
    );
  }
  for (final entry in {
    'M_FORBIDDEN': AuthErrorType.invalidCredentials,
    'M_UNAUTHORIZED': AuthErrorType.invalidCredentials,
    'M_USER_IN_USE': AuthErrorType.usernameExists,
    'M_INVALID_USERNAME': AuthErrorType.usernameUnavailable,
    'M_LIMIT_EXCEEDED': AuthErrorType.rateLimited,
    'M_UNKNOWN_TOKEN': AuthErrorType.tokenExpired,
    'M_UNKNOWN': AuthErrorType.serverError,
  }.entries) {
    test(
      'maps Matrix ${entry.key} independently of human error wording',
      () async {
        when(
          () => auth.loginWithPassword(
            homeserver: any(named: 'homeserver'),
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenThrow(error(entry.key));
        expect((await login()).errorType, entry.value);
      },
    );
  }
  test(
    'a pending password login rejects concurrent auth but releases the lock',
    () async {
      final pending = Completer<LoginResponse>();
      when(
        () => auth.loginWithPassword(
          homeserver: any(named: 'homeserver'),
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => pending.future);
      final first = login();
      expect((await tokenLogin()).errorType, AuthErrorType.rateLimited);
      expect(
        (await repository.restoreSession()).errorType,
        AuthErrorType.rateLimited,
      );
      pending.completeError(StateError('offline'));
      expect((await first).errorType, AuthErrorType.unknown);
      expect((await tokenLogin()).success, isTrue);
    },
  );
  test(
    'restore uses saved token while holding its own authentication lock',
    () async {
      when(storage.getSession).thenAnswer((_) async => session);
      final result = await repository.restoreSession();
      expect(result.success, isTrue);
      verify(
        () => auth.loginWithToken(
          homeserver: 'https://hs.test',
          accessToken: 'fixture-token',
          userId: '@alice:hs.test',
          deviceId: 'device',
        ),
      ).called(1);
    },
  );
  test(
    'absent or incomplete stored session requires reauthentication',
    () async {
      expect(
        (await repository.restoreSession()).errorType,
        AuthErrorType.notLoggedIn,
      );
      when(
        storage.getSession,
      ).thenAnswer((_) async => {'userId': '@alice:hs.test'});
      expect(
        (await repository.restoreSession()).errorType,
        AuthErrorType.notLoggedIn,
      );
      verifyNever(
        () => auth.loginWithPassword(
          homeserver: any(named: 'homeserver'),
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      );
    },
  );
  test(
    'SDK fast restore skips token login and emits authenticated state',
    () async {
      when(() => auth.isLoggedIn).thenReturn(true);
      when(() => auth.userId).thenReturn('@alice:hs.test');
      expect((await repository.restoreSession()).user!.displayName, 'alice');
      verifyNever(
        () => auth.loginWithToken(
          homeserver: any(named: 'homeserver'),
          accessToken: any(named: 'accessToken'),
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
        ),
      );
    },
  );
  test(
    'storage read failure becomes a recoverable expired-session result',
    () async {
      when(storage.getSession).thenThrow(StateError('keychain unavailable'));
      expect(
        (await repository.restoreSession()).errorType,
        AuthErrorType.tokenExpired,
      );
      when(storage.getSession).thenAnswer((_) async => null);
      expect((await tokenLogin()).success, isTrue);
    },
  );
  for (final biometric in [true, false]) {
    test(
      'logout clears session and preserves credentials only for biometric=$biometric',
      () async {
        when(storage.isBiometricEnabled).thenAnswer((_) async => biometric);
        final event = repository.loginStateStream.first;
        await repository.logout();
        expect(await event, isFalse);
        verify(storage.clearSession).called(1);
        if (biometric) {
          verifyNever(storage.clearCredentials);
        } else {
          verify(storage.clearCredentials).called(1);
        }
      },
    );
  }
  test('server logout failure still clears the local session', () async {
    when(auth.logout).thenThrow(StateError('offline'));
    final event = repository.loginStateStream.first;
    await repository.logout();
    expect(await event, isFalse);
    verify(storage.clearSession).called(1);
  });
  for (final state in [LoginState.loggedOut, LoginState.softLoggedOut]) {
    test('SDK $state invalidates the local session after login', () async {
      await tokenLogin();
      final loggedOut = repository.loginStateStream.firstWhere(
        (value) => !value,
      );
      sdk.add(state);
      expect(await loggedOut, isFalse);
      verify(storage.clearSession).called(1);
    });
  }
  test(
    'background sync rejection does not turn a saved login into failure',
    () async {
      when(
        manager.startSync,
      ).thenAnswer((_) async => throw StateError('offline sync'));
      expect((await tokenLogin()).success, isTrue);
      await Future<void>.delayed(Duration.zero);
    },
  );
  test('stored accounts put current first, then newest valid dates', () async {
    when(() => manager.userId).thenReturn('@current:hs.test');
    when(storage.getAccounts).thenAnswer(
      (_) async => {
        '@old:hs.test': {'addedAt': '2025-01-01'},
        '@new:hs.test': {'addedAt': '2026-01-01'},
        '@current:hs.test': {'addedAt': '2024-01-01'},
        '@z:hs.test': {'addedAt': 'invalid'},
        '@a:hs.test': {},
      },
    );
    final accounts = await repository.getStoredAccounts();
    expect(accounts.map((a) => a.userId), [
      '@current:hs.test',
      '@new:hs.test',
      '@old:hs.test',
      '@a:hs.test',
      '@z:hs.test',
    ]);
    expect(accounts.first.isCurrent, isTrue);
    expect(accounts.last.addedAt, isNull);
  });
  test('account switching rejects missing and incomplete sessions', () async {
    expect(
      (await repository.switchStoredAccount('@none:hs.test')).errorType,
      AuthErrorType.notLoggedIn,
    );
    when(storage.getAccounts).thenAnswer(
      (_) async => {
        '@alice:hs.test': {'homeserver': 'https://hs.test'},
      },
    );
    expect(
      (await repository.switchStoredAccount('@alice:hs.test')).errorType,
      AuthErrorType.tokenExpired,
    );
  });
  test('account switching uses stored token and profile identity', () async {
    when(
      storage.getAccounts,
    ).thenAnswer((_) async => {'@alice:hs.test': session});
    expect(
      (await repository.switchStoredAccount('@alice:hs.test')).success,
      isTrue,
    );
    verify(
      () => auth.loginWithToken(
        homeserver: 'https://hs.test',
        accessToken: 'fixture-token',
        userId: '@alice:hs.test',
        deviceId: 'device',
      ),
    ).called(1);
  });
  for (final success in [true, false]) {
    test(
      'password change clears credentials only after server success=$success',
      () async {
        when(() => auth.isLoggedIn).thenReturn(true);
        when(
          () => auth.changeUserPassword(oldPassword: 'old', newPassword: 'new'),
        ).thenAnswer((_) async => success);
        expect(
          await repository.changePassword(
            oldPassword: 'old',
            newPassword: 'new',
          ),
          success,
        );
        if (success) {
          verify(storage.clearCredentials).called(1);
        } else {
          verifyNever(storage.clearCredentials);
        }
      },
    );
  }
  test('sensitive profile operations reject unauthenticated calls', () async {
    await expectLater(
      repository.changePassword(oldPassword: 'old', newPassword: 'new'),
      throwsStateError,
    );
    await expectLater(
      repository.requestChangeEmail(
        password: 'password',
        newEmail: 'test@example.org',
      ),
      throwsStateError,
    );
    await expectLater(
      repository.confirmChangeEmail(newEmail: 'test@example.org', code: '123'),
      throwsStateError,
    );
    expect(await repository.getBoundEmail(), isNull);
    expect(await repository.getBoundPhone(), isNull);
    expect(await repository.getCurrentUserProfile(), isNull);
    expect(await repository.getUserProfileData(), isNull);
    expect(await repository.updateUserProfileData(signature: 'hello'), isFalse);
  });
  test('SSO login token preserves identity and emits authentication', () async {
    expect(
      (await repository.loginWithLoginToken(
        homeserver: 'https://hs.test',
        loginToken: 'single-use',
      )).user!.userId,
      '@alice:hs.test',
    );
    verify(
      () => auth.loginWithLoginToken(
        homeserver: 'https://hs.test',
        loginToken: 'single-use',
      ),
    ).called(1);
  });
  test('SSO invalid response does not save a session', () async {
    when(
      () => auth.loginWithLoginToken(
        homeserver: any(named: 'homeserver'),
        loginToken: any(named: 'loginToken'),
      ),
    ).thenAnswer((_) async => response(token: ''));
    expect(
      (await repository.loginWithLoginToken(
        homeserver: 'https://hs.test',
        loginToken: 'single-use',
      )).errorType,
      AuthErrorType.serverError,
    );
  });
}
