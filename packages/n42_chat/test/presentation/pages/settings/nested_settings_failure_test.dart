import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/core/notifications/notification_filter_store.dart';
import 'package:n42_chat/src/domain/entities/notification_filter_rules.dart';
import 'package:n42_chat/src/domain/repositories/auth_repository.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_event.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_state.dart';
import 'package:n42_chat/src/presentation/pages/settings/account_switch_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/notification_filter_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockFilterStore extends Mock implements NotificationFilterStore {}

Widget app(Widget child) => MaterialApp(
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  locale: const Locale('en'),
  home: child,
);

void main() {
  setUpAll(() => registerFallbackValue(NotificationFilterRules.empty));
  tearDown(() async => getIt.reset());

  testWidgets('account read failure offers retry instead of endless loading', (
    tester,
  ) async {
    final repository = MockAuthRepository();
    when(
      () => repository.getStoredAccounts(),
    ).thenThrow(StateError('read failed'));
    getIt.registerSingleton<IAuthRepository>(repository);
    final auth = MockAuthBloc();
    when(
      () => auth.state,
    ).thenReturn(const AuthState(status: AuthStatus.unauthenticated));
    await tester.pumpWidget(
      app(
        BlocProvider<AuthBloc>.value(
          value: auth,
          child: const AccountSwitchPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No saved accounts yet'), findsNothing);
    final l10n = S.of(tester.element(find.byType(AccountSwitchPage)))!;
    expect(find.text(l10n.commonLoadFailed), findsOneWidget);
    when(() => repository.getStoredAccounts()).thenAnswer((_) async => []);
    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();
    expect(find.text('No saved accounts yet'), findsOneWidget);
    verify(() => repository.getStoredAccounts()).called(2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filter load failure retries without replacing stored rules', (
    tester,
  ) async {
    final store = MockFilterStore();
    when(store.load).thenThrow(StateError('read failed'));
    await tester.pumpWidget(app(NotificationFilterPage(store: store)));
    await tester.pumpAndSettle();
    final l10n = S.of(tester.element(find.byType(NotificationFilterPage)))!;
    expect(find.text(l10n.commonLoadFailed), findsOneWidget);
    when(store.load).thenAnswer(
      (_) async =>
          NotificationFilterRules.empty.copyWith(priorityKeywords: ['urgent']),
    );
    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();
    expect(find.text('urgent'), findsOneWidget);
    verifyNever(() => store.save(any()));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'filter save failure restores rules, serializes input and permits retry',
    (tester) async {
      final store = MockFilterStore();
      when(store.load).thenAnswer((_) async => NotificationFilterRules.empty);
      final pending = Completer<void>();
      when(() => store.save(any())).thenAnswer((_) => pending.future);
      await tester.pumpWidget(app(NotificationFilterPage(store: store)));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byType(SwitchListTile), 250);
      await tester.ensureVisible(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue,
      );
      await tester.tap(find.byType(SwitchListTile), warnIfMissed: false);
      await tester.pump();
      verify(() => store.save(any())).called(1);
      pending.completeError(StateError('write failed'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );
      expect(find.byType(SnackBar), findsOneWidget);
      when(() => store.save(any())).thenAnswer((_) async {});
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      final saved =
          verify(() => store.save(captureAny())).captured.single
              as NotificationFilterRules;
      expect(saved.caseSensitive, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('adding a filter keyword trims input and persists the result', (
    tester,
  ) async {
    final store = MockFilterStore();
    when(store.load).thenAnswer((_) async => NotificationFilterRules.empty);
    when(() => store.save(any())).thenAnswer((_) async {});
    await tester.pumpWidget(app(NotificationFilterPage(store: store)));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  urgent  ');
    final l10n = S.of(tester.element(find.byType(NotificationFilterPage)))!;
    await tester.tap(find.widgetWithText(TextButton, l10n.commonAdd));
    await tester.pumpAndSettle();
    expect(find.text('urgent'), findsOneWidget);
    final saved =
        verify(() => store.save(captureAny())).captured.single
            as NotificationFilterRules;
    expect(saved.priorityKeywords, ['urgent']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('late filter read failure after disposal is handled', (
    tester,
  ) async {
    final store = MockFilterStore();
    final pending = Completer<NotificationFilterRules>();
    when(store.load).thenAnswer((_) => pending.future);
    await tester.pumpWidget(app(NotificationFilterPage(store: store)));
    await tester.pump();
    await tester.pumpWidget(app(const SizedBox()));
    pending.completeError(StateError('late read failure'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
