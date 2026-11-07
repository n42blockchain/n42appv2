import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/n42_chat.dart' show UserEntity;
// ignore: implementation_imports
import 'package:n42_chat/src/domain/repositories/auth_repository.dart';
import 'package:n42_wallet/features/live/services/live_bootstrap.dart';

class _Auth extends Mock implements IAuthRepository {}

void main() {
  final success = AuthResult.success(
    const UserEntity(userId: '@qa:example', displayName: 'QA'),
  );
  tearDown(() => GetIt.instance.reset());

  test('checks login again after a completed anonymous session ends', () async {
    final auth = _Auth();
    var loggedIn = false;
    var registrations = 0;
    when(() => auth.isLoggedIn).thenAnswer((_) => loggedIn);
    when(
      () => auth.registerAnonymously(
        homeserver: any(named: 'homeserver'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {
      registrations++;
      loggedIn = true;
      return success;
    });
    GetIt.instance.registerSingleton<IAuthRepository>(auth);
    await ensureAnonymousLogin();
    loggedIn = false;
    await ensureAnonymousLogin();
    expect(registrations, 2);
  });

  test('shares only in-flight registration for the same repository', () async {
    final auth = _Auth();
    final pending = Completer<AuthResult>();
    var registrations = 0;
    when(() => auth.isLoggedIn).thenReturn(false);
    when(
      () => auth.registerAnonymously(
        homeserver: any(named: 'homeserver'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) {
      registrations++;
      return pending.future;
    });
    GetIt.instance.registerSingleton<IAuthRepository>(auth);
    final first = ensureAnonymousLogin();
    final second = ensureAnonymousLogin();
    expect(identical(first, second), isTrue);
    expect(registrations, 1);
    pending.complete(success);
    await Future.wait([first, second]);
  });

  test(
    'current authenticated account is retained without registration',
    () async {
      final auth = _Auth();
      when(() => auth.isLoggedIn).thenReturn(true);
      GetIt.instance.registerSingleton<IAuthRepository>(auth);
      await ensureAnonymousLogin();
      verifyNever(
        () => auth.registerAnonymously(
          homeserver: any(named: 'homeserver'),
          password: any(named: 'password'),
        ),
      );
    },
  );

  test('failed registration does not prevent a later retry', () async {
    final auth = _Auth();
    var calls = 0;
    when(() => auth.isLoggedIn).thenReturn(false);
    when(
      () => auth.registerAnonymously(
        homeserver: any(named: 'homeserver'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => ++calls == 1 ? AuthResult.failure('offline') : success,
    );
    GetIt.instance.registerSingleton<IAuthRepository>(auth);
    await expectLater(ensureAnonymousLogin(), throwsStateError);
    await ensureAnonymousLogin();
    expect(calls, 2);
  });
  test(
    'replacement auth repository never inherits an old pending login',
    () async {
      final oldAuth = _Auth();
      final newAuth = _Auth();
      final oldResult = Completer<AuthResult>();
      final newResult = Completer<AuthResult>();
      for (final entry in [(oldAuth, oldResult), (newAuth, newResult)]) {
        when(() => entry.$1.isLoggedIn).thenReturn(false);
        when(
          () => entry.$1.registerAnonymously(
            homeserver: any(named: 'homeserver'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) => entry.$2.future);
      }
      GetIt.instance.registerSingleton<IAuthRepository>(oldAuth);
      final oldLogin = ensureAnonymousLogin();
      await GetIt.instance.unregister<IAuthRepository>();
      GetIt.instance.registerSingleton<IAuthRepository>(newAuth);
      final newLogin = ensureAnonymousLogin();
      expect(identical(newLogin, oldLogin), isFalse);
      oldResult.complete(success);
      await oldLogin;
      expect(identical(ensureAnonymousLogin(), newLogin), isTrue);
      newResult.complete(success);
      await newLogin;
    },
  );
}
