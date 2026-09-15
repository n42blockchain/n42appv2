import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/domain/entities/user_entity.dart';
import 'package:n42_chat/src/domain/repositories/auth_repository.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_event.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_state.dart';
import 'package:n42_chat/src/presentation/pages/auth/register_page.dart';
import 'package:n42_chat/src/presentation/pages/auth/reset_password_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc auth;
  late StreamController<AuthState> states;
  late List<AuthEvent> events;
  bool? navigationResult;
  Future<void> open(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                navigationResult = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) =>
                        BlocProvider<AuthBloc>.value(value: auth, child: page),
                  ),
                );
              },
              child: const Text('Open form'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, int index, String value) async {
    final field = find.byType(TextFormField).at(index);
    await tester.ensureVisible(field);
    await tester.enterText(field, value);
    await tester.pump();
  }

  Future<void> registrationFields(
    WidgetTester tester, {
    bool anonymous = false,
  }) async {
    await enter(tester, 0, 'https://hs.test');
    if (!anonymous) {
      await enter(tester, 1, 'alice');
      await enter(tester, 2, 'alice@example.org');
    }
    await enter(tester, anonymous ? 1 : 3, 'Password123!');
    await enter(tester, anonymous ? 2 : 4, 'Password123!');
    await tap(
      tester,
      find
          .ancestor(
            of: find.byType(Checkbox),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
  }

  setUpAll(() => registerFallbackValue(const AuthLogoutRequested()));
  setUp(() {
    auth = MockAuthBloc();
    states = StreamController<AuthState>.broadcast();
    events = [];
    navigationResult = null;
    whenListen(
      auth,
      states.stream,
      initialState: const AuthState(status: AuthStatus.unauthenticated),
    );
    when(() => auth.add(any())).thenAnswer(
      (invocation) =>
          events.add(invocation.positionalArguments.single as AuthEvent),
    );
  });
  tearDown(() async => states.close());

  testWidgets('registration requires agreeing to terms before dispatch', (
    tester,
  ) async {
    await open(tester, const RegisterPage());
    await tap(tester, find.byType(ElevatedButton));
    expect(events.whereType<AuthRegisterRequested>(), isEmpty);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('invalid registration inputs cannot reach the auth repository', (
    tester,
  ) async {
    await open(tester, const RegisterPage());
    await registrationFields(tester);
    await enter(tester, 1, 'invalid name');
    await enter(tester, 2, 'bad-email');
    await enter(tester, 3, 'short');
    await enter(tester, 4, 'different');
    await tap(tester, find.byType(ElevatedButton));
    expect(events.whereType<AuthRegisterRequested>(), isEmpty);
    expect(find.byType(RegisterPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'normal registration submits trimmed identity and matching password',
    (tester) async {
      await open(tester, const RegisterPage());
      await registrationFields(tester);
      await enter(tester, 0, '  https://hs.test  ');
      await tap(tester, find.byType(ElevatedButton));
      final event = events.whereType<AuthRegisterRequested>().single;
      expect(event.homeserver, 'https://hs.test');
      expect(event.username, 'alice');
      expect(event.email, 'alice@example.org');
      expect(event.password, 'Password123!');
      expect(event.registrationToken, isNull);
      expect(find.text('Filled'), findsNothing);
      expect(find.text('Invite Code (Built-in)'), findsNothing);
      expect(events.whereType<AuthAnonymousRegisterRequested>(), isEmpty);
    },
  );
  testWidgets(
    'anonymous registration omits identity fields and dispatches anonymous flow',
    (tester) async {
      await open(tester, const RegisterPage());
      await tap(tester, find.byType(SwitchListTile));
      expect(find.byType(TextFormField), findsNWidgets(3));
      await registrationFields(tester, anonymous: true);
      await tap(tester, find.byType(ElevatedButton));
      expect(events.whereType<AuthAnonymousRegisterRequested>(), hasLength(1));
      expect(events.whereType<AuthRegisterRequested>(), isEmpty);
    },
  );
  testWidgets(
    'registration error retains draft and successful state returns to caller',
    (tester) async {
      await open(tester, const RegisterPage());
      await registrationFields(tester);
      states.add(
        const AuthState(
          status: AuthStatus.error,
          errorType: AuthErrorType.usernameExists,
          errorMessage: 'Username already exists',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(1))
            .controller!
            .text,
        'alice',
      );
      states.add(
        const AuthState(
          status: AuthStatus.authenticated,
          user: UserEntity(userId: '@alice:hs.test', displayName: 'Alice'),
        ),
      );
      await tester.pumpAndSettle();
      expect(navigationResult, isTrue);
      expect(find.byType(RegisterPage), findsNothing);
    },
  );
  testWidgets('loading registration disables duplicate submissions', (
    tester,
  ) async {
    await open(tester, const RegisterPage());
    states.add(const AuthState(status: AuthStatus.loading));
    await tester.pump();
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets('reset rejects empty and malformed email locally', (
    tester,
  ) async {
    await open(tester, const ResetPasswordPage(homeserver: 'https://hs.test'));
    await tap(tester, find.byType(ElevatedButton));
    expect(events.whereType<AuthRequestPasswordResetRequested>(), isEmpty);
    await enter(tester, 0, 'not-an-email');
    await tap(tester, find.byType(ElevatedButton));
    expect(events.whereType<AuthRequestPasswordResetRequested>(), isEmpty);
    expect(find.byType(SnackBar), findsOneWidget);
  });
  testWidgets('reset sends normalized email and enforces resend cooldown', (
    tester,
  ) async {
    await open(tester, const ResetPasswordPage(homeserver: 'https://hs.test'));
    await enter(tester, 0, ' alice@example.org ');
    await tap(tester, find.byType(ElevatedButton));
    final event = events.whereType<AuthRequestPasswordResetRequested>().single;
    expect(event.homeserver, 'https://hs.test');
    expect(event.email, 'alice@example.org');
    states.add(
      const AuthState(
        status: AuthStatus.unauthenticated,
        passwordResetStatus: PasswordResetStatus.codeSent,
      ),
    );
    await tester.pumpAndSettle();
    final resend = find.byType(TextButton).last;
    expect(tester.widget<TextButton>(resend).onPressed, isNull);
    await tester.pump(const Duration(seconds: 61));
    await tester.pump();
    expect(tester.widget<TextButton>(resend).onPressed, isNotNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('reset validates code and password before confirming', (
    tester,
  ) async {
    await open(tester, const ResetPasswordPage(homeserver: 'https://hs.test'));
    await enter(tester, 0, 'alice@example.org');
    states.add(
      const AuthState(
        status: AuthStatus.unauthenticated,
        passwordResetStatus: PasswordResetStatus.codeSent,
      ),
    );
    await tester.pumpAndSettle();
    await tap(tester, find.byType(ElevatedButton));
    expect(events.whereType<AuthConfirmPasswordResetRequested>(), isEmpty);
    await enter(tester, 0, '123456');
    await tap(tester, find.byType(ElevatedButton));
    expect(find.byType(TextFormField), findsNWidgets(2));
    await enter(tester, 0, 'Password123!');
    await enter(tester, 1, 'mismatch');
    await tap(tester, find.byType(ElevatedButton));
    expect(events.whereType<AuthConfirmPasswordResetRequested>(), isEmpty);
    await enter(tester, 1, 'Password123!');
    await tap(tester, find.byType(ElevatedButton));
    final event = events.whereType<AuthConfirmPasswordResetRequested>().single;
    expect(event.code, '123456');
    expect(event.email, 'alice@example.org');
    expect(event.newPassword, 'Password123!');
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'reset success closes the form while failure leaves it retryable',
    (tester) async {
      await open(
        tester,
        const ResetPasswordPage(homeserver: 'https://hs.test'),
      );
      states.add(
        const AuthState(
          status: AuthStatus.unauthenticated,
          passwordResetStatus: PasswordResetStatus.failed,
          errorMessage: 'Offline',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ResetPasswordPage), findsOneWidget);
      states.add(
        const AuthState(
          status: AuthStatus.unauthenticated,
          passwordResetStatus: PasswordResetStatus.success,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ResetPasswordPage), findsNothing);
    },
  );
}
