import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/core/services/username_service.dart';
import 'package:n42_chat/src/domain/repositories/auth_repository.dart';
import 'package:n42_chat/src/presentation/pages/settings/account_switch_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/privacy_security_page.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/domain/entities/user_entity.dart';
import 'package:n42_chat/src/domain/entities/user_profile_entity.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_event.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_state.dart';
import 'package:n42_chat/src/presentation/pages/settings/appearance_settings_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/auto_download_settings_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/change_email_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/change_password_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/chat_background_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/chat_settings_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/language_settings_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/notification_settings_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/quick_replies_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/settings_navigation.dart';
import 'package:n42_chat/src/presentation/pages/settings/settings_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/translation_settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockUsernameService extends Mock implements UsernameService {}

class FailingPreferences extends PreferencesDataSource {
  @override
  Future<NotificationSettings> getNotificationSettingsModel() async =>
      throw StateError('unavailable');
}

Widget app(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  locale: locale,
  home: child,
);

Future<void> tapLabel(WidgetTester tester, String label) async {
  final target = find.text(label);
  await tester.scrollUntilVisible(
    target,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    getIt.registerSingleton<PreferencesDataSource>(PreferencesDataSource());
  });
  tearDown(() async => getIt.reset());

  for (final entry in <String, Type>{
    'Notifications': NotificationSettingsPage,
    'Appearance': AppearanceSettingsPage,
    'Chat': ChatSettingsPage,
    'Language': LanguageSettingsPage,
  }.entries) {
    testWidgets('direct settings opens ${entry.key} without host callbacks', (
      tester,
    ) async {
      await tester.pumpWidget(app(const SettingsPage()));
      await tester.pumpAndSettle();
      await tapLabel(tester, entry.key);
      expect(find.byType(entry.value), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final entry in <String, Type>{
    'Chat Background': ChatBackgroundPage,
    'Quick Reply': QuickRepliesPage,
    'Translation': TranslationSettingsPage,
    'Auto-Download': AutoDownloadSettingsPage,
  }.entries) {
    testWidgets('Chat settings opens ${entry.key}', (tester) async {
      await tester.pumpWidget(app(const ChatSettingsPage()));
      await tester.pumpAndSettle();
      await tapLabel(tester, entry.key);
      expect(find.byType(entry.value), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('host overrides take precedence over default routes', (
    tester,
  ) async {
    final calls = <String>[];
    await tester.pumpWidget(
      app(
        SettingsPage(
          onNotification: () => calls.add('Notifications'),
          onAppearance: () => calls.add('Appearance'),
          onChat: () => calls.add('Chat'),
          onLanguage: () => calls.add('Language'),
          onChangePassword: () => calls.add('Change Password'),
          onChangeEmail: () => calls.add('Change Email'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in [
      'Notifications',
      'Appearance',
      'Chat',
      'Language',
      'Change Password',
      'Change Email',
    ]) {
      await tapLabel(tester, label);
    }
    expect(calls, [
      'Notifications',
      'Appearance',
      'Chat',
      'Language',
      'Change Password',
      'Change Email',
    ]);
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('password and email retain the route-scoped authenticated bloc', (
    tester,
  ) async {
    final auth = MockAuthBloc();
    when(() => auth.state).thenReturn(
      const AuthState(
        status: AuthStatus.authenticated,
        user: UserEntity(userId: '@test:example.org', displayName: 'Test'),
      ),
    );
    await tester.pumpWidget(
      app(
        BlocProvider<AuthBloc>.value(value: auth, child: const SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tapLabel(tester, 'Change Password');
    expect(find.byType(ChangePasswordPage), findsOneWidget);
    expect(
      tester.element(find.byType(ChangePasswordPage)).read<AuthBloc>(),
      same(auth),
    );
    Navigator.of(tester.element(find.byType(ChangePasswordPage))).pop();
    await tester.pumpAndSettle();
    await tapLabel(tester, 'Change Email');
    expect(find.byType(ChangeEmailPage), findsOneWidget);
    expect(
      tester.element(find.byType(ChangeEmailPage)).read<AuthBloc>(),
      same(auth),
    );
    verify(() => auth.add(const AuthGetBoundEmailRequested())).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'unauthenticated account actions explain login instead of throwing',
    (tester) async {
      await tester.pumpWidget(app(const SettingsPage()));
      await tester.pumpAndSettle();
      await tapLabel(tester, 'Change Password');
      expect(find.byType(ChangePasswordPage), findsNothing);
      final l10n = S.of(tester.element(find.byType(SettingsPage)))!;
      expect(find.text(l10n.authLoginNow), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('read failure stays on settings with localized feedback', (
    tester,
  ) async {
    await getIt.unregister<PreferencesDataSource>();
    getIt.registerSingleton<PreferencesDataSource>(FailingPreferences());
    await tester.pumpWidget(app(const SettingsPage()));
    await tester.pumpAndSettle();
    await tapLabel(tester, 'Notifications');
    expect(find.byType(NotificationSettingsPage), findsNothing);
    expect(
      find.text(
        S.of(tester.element(find.byType(SettingsPage)))!.commonLoadFailed,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing preferences has feedback for Chat entries', (
    tester,
  ) async {
    await getIt.reset();
    await tester.pumpWidget(app(const ChatSettingsPage()));
    await tester.pumpAndSettle();
    await tapLabel(tester, 'Quick Reply');
    expect(find.byType(QuickRepliesPage), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('logout needs confirmation and targets existing auth bloc', (
    tester,
  ) async {
    final auth = MockAuthBloc();
    when(() => auth.state).thenReturn(
      const AuthState(
        status: AuthStatus.authenticated,
        user: UserEntity(userId: '@test:example.org', displayName: 'Test'),
      ),
    );
    await tester.pumpWidget(
      app(
        BlocProvider<AuthBloc>.value(value: auth, child: const SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tapLabel(tester, 'Log Out');
    verifyNever(() => auth.add(const AuthLogoutRequested()));
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => auth.add(const AuthLogoutRequested()));
    await tapLabel(tester, 'Log Out');
    await tester.tap(find.widgetWithText(TextButton, 'Log Out'));
    await tester.pumpAndSettle();
    verify(() => auth.add(const AuthLogoutRequested())).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigation carries auth across multiple route boundaries', (
    tester,
  ) async {
    final auth = MockAuthBloc();
    when(() => auth.state).thenReturn(
      const AuthState(
        status: AuthStatus.authenticated,
        user: UserEntity(userId: '@test:example.org', displayName: 'Test'),
      ),
    );
    Widget launcher(String label, WidgetBuilder next) => Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () =>
              SettingsNavigation.page(context, next(context), needsAuth: true),
          child: Text(label),
        ),
      ),
    );
    await tester.pumpWidget(
      app(
        BlocProvider<AuthBloc>.value(
          value: auth,
          child: launcher(
            'hub',
            (_) => launcher('account', (_) => const ChangeEmailPage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('hub'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('account'));
    await tester.pumpAndSettle();
    expect(
      tester.element(find.byType(ChangeEmailPage)).read<AuthBloc>(),
      same(auth),
    );
    verify(() => auth.add(const AuthGetBoundEmailRequested())).called(1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('standalone account hub opens accounts with the current bloc', (
    tester,
  ) async {
    final auth = MockAuthBloc();
    when(() => auth.state).thenReturn(
      const AuthState(
        status: AuthStatus.authenticated,
        user: UserEntity(userId: '@test:example.org', displayName: 'Test'),
      ),
    );
    final repository = MockAuthRepository();
    when(() => repository.getStoredAccounts()).thenAnswer((_) async => []);
    final usernames = MockUsernameService();
    when(() => usernames.getMyUsername()).thenAnswer((_) async => null);
    getIt.registerSingleton<IAuthRepository>(repository);
    getIt.registerSingleton<UsernameService>(usernames);
    await tester.pumpWidget(
      app(
        BlocProvider<AuthBloc>.value(value: auth, child: const SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tapLabel(tester, 'System & Accounts');
    await tapLabel(tester, 'Accounts');
    expect(find.byType(AccountSwitchPage), findsOneWidget);
    expect(
      tester.element(find.byType(AccountSwitchPage)).read<AuthBloc>(),
      same(auth),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('standalone privacy hub opens without a Profile callback', (
    tester,
  ) async {
    final usernames = MockUsernameService();
    when(() => usernames.getMyUsername()).thenAnswer((_) async => null);
    getIt.registerSingleton<UsernameService>(usernames);
    await tester.pumpWidget(app(const SettingsPage()));
    await tester.pumpAndSettle();
    await tapLabel(tester, 'Privacy & Security');
    expect(find.byType(PrivacySecurityPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
