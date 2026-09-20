import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/services/auto_download_policy_service.dart';
import 'package:n42_chat/src/core/services/biometric_service.dart';
import 'package:n42_chat/src/data/datasources/local/secure_storage_datasource.dart';
import 'package:n42_chat/src/domain/repositories/auth_repository.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:n42_chat/src/presentation/pages/auth/register_page.dart';
import 'package:n42_chat/src/presentation/widgets/chat/image_message_widget.dart';
import 'package:n42_chat/src/presentation/widgets/chat/poll_create_sheet.dart';
import 'package:n42_chat/src/presentation/widgets/chat/transfer_message_widget.dart';

// Run the same SQL behavior contracts on the actual ARM64 device libraries.
import '../packages/n42_chat/test/unit/datasources/storage_database_behavior_test.dart'
    as storage_contracts;

class _AuthRepository extends Mock implements IAuthRepository {}

class _SecureStorage extends Mock implements SecureStorageDataSource {}

class _Biometrics extends Mock implements BiometricService {}

class _Policy extends Mock implements AutoDownloadPolicyService {}

typedef DeviceCapture = Future<void> Function(WidgetTester tester, String name);

void registerChatCoverageDeviceCases(DeviceCapture capture) {
  setUpAll(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
      open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
    }
  });
  storage_contracts.registerStorageDatabaseBehaviorTests(
    registerCase: (description, body) =>
        testWidgets(description, (tester) async {
          await tester.runAsync(body);
        }),
  );

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(finder, 160);
    }
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await reveal(tester, finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> enterOption(
    WidgetTester tester,
    String hint,
    String value,
  ) async {
    final finder = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.hintText == hint,
    );
    await reveal(tester, finder);
    await tester.enterText(finder, value);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(finder).controller!.text, value);
  }

  testWidgets(
    'device poll composer validates, schedules and keeps quizzes single choice',
    (tester) async {
      // Profile mode does not accept the debug-only -1 text-input client ID.
      // Register a test connection so injected edits target a real client ID.
      tester.testTextInput.register();
      addTearDown(tester.testTextInput.unregister);
      PollComposerResult? result;
      for (final language in ['en', 'ar']) {
        await tester.pumpWidget(
          _app(
            Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () async {
                      result = await showModalBottomSheet<PollComposerResult>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const PollCreateSheet(),
                      );
                    },
                    child: const Text('Open poll'),
                  ),
                ),
              ),
            ),
            locale: language,
          ),
        );
        await tap(tester, find.text('Open poll'));
        final strings = S.of(tester.element(find.byType(PollCreateSheet)))!;
        await capture(tester, 'coverage-poll-$language');
        await tap(tester, find.text(strings.chatSubmitPoll));
        expect(find.byType(PollCreateSheet), findsOneWidget);
        await enterOption(
          tester,
          strings.chatEnterPollQuestionHint,
          ' Device question ',
        );
        await enterOption(tester, strings.chatOptionHintWithIndex(1), ' One ');
        await enterOption(tester, strings.chatOptionHintWithIndex(2), ' Two ');
        await reveal(tester, find.text('Quiz mode'));
        final quiz = find.descendant(
          of: find
              .ancestor(of: find.text('Quiz mode'), matching: find.byType(Row))
              .first,
          matching: find.byType(Switch),
        );
        await tap(tester, quiz);
        await tap(tester, find.text(strings.chatMultiChoiceLabel));
        await tap(tester, find.text('Schedule'));
        expect(result, isNotNull);
        expect(result!.question, 'Device question');
        expect(result!.options, ['One', 'Two']);
        expect(result!.maxSelections, 1);
        expect(result!.quizCorrectIndex, 0);
        expect(result!.action, PollComposerAction.schedule);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'device protected image and payment detail callbacks obey state',
    (tester) async {
      final policy = _Policy();
      when(
        () => policy.shouldAutoDownload(AutoDownloadMediaType.image),
      ).thenAnswer((_) async => false);
      var viewed = 0;
      var details = 0;
      Widget page({bool consumed = false}) => Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 48),
                ImageMessageWidget(
                  key: const ValueKey('protected'),
                  imageUrl: '',
                  isViewOnce: true,
                  isViewed: consumed,
                  autoDownloadPolicyService: policy,
                  onTap: () => viewed++,
                ),
                const SizedBox(height: 24),
                TransferMessageWidget(
                  amount: '12.50',
                  currency: 'ETH',
                  status: TransferMessageStatus.completed,
                  isSelf: true,
                  onTap: () => details++,
                ),
                const SizedBox(height: 24),
                ImageMessageWidget(
                  key: const ValueKey('manual'),
                  imageUrl: '',
                  autoDownloadPolicyService: policy,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpWidget(_app(page()));
      await tester.pumpAndSettle();
      await capture(tester, 'coverage-protected-media');
      expect(
        tester.getSize(find.byKey(const ValueKey('protected'))).height,
        lessThan(240),
      );
      await tap(tester, find.byIcon(Icons.lock));
      expect(viewed, 1);
      await tap(tester, find.text('Ξ12.50'));
      expect(details, 1);
      await tap(tester, find.byIcon(Icons.download_for_offline_outlined));
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
      await tester.pumpWidget(_app(page(consumed: true)));
      await tester.pumpAndSettle();
      await tap(tester, find.byIcon(Icons.visibility));
      expect(viewed, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'device registration keeps failed drafts and switches anonymous fields',
    (tester) async {
      tester.testTextInput.register();
      addTearDown(tester.testTextInput.unregister);
      final repository = _AuthRepository();
      when(
        () => repository.loginStateStream,
      ).thenAnswer((_) => const Stream<bool>.empty());
      when(
        () => repository.register(
          homeserver: any(named: 'homeserver'),
          username: any(named: 'username'),
          password: any(named: 'password'),
          email: any(named: 'email'),
          registrationToken: any(named: 'registrationToken'),
        ),
      ).thenAnswer(
        (_) async => AuthResult.failure(
          'Offline fixture',
          type: AuthErrorType.networkError,
        ),
      );
      final auth = AuthBloc(
        authRepository: repository,
        secureStorage: _SecureStorage(),
        biometricService: _Biometrics(),
      );
      addTearDown(auth.close);
      await tester.pumpWidget(
        _app(
          BlocProvider<AuthBloc>.value(
            value: auth,
            child: const RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      for (final value in [
        ' https://hs.test ',
        'device_fixture',
        'FixturePass123!',
        'FixturePass123!',
      ].indexed) {
        final field = find.byType(TextFormField).at(value.$1);
        await reveal(tester, field);
        await tester.enterText(field, value.$2);
        await tester.pump();
        expect(tester.widget<TextFormField>(field).controller!.text, value.$2);
      }
      await tap(
        tester,
        find
            .ancestor(
              of: find.byType(Checkbox),
              matching: find.byType(GestureDetector),
            )
            .first,
      );
      await tap(tester, find.byType(ElevatedButton));
      verify(
        () => repository.register(
          homeserver: 'https://hs.test',
          username: 'device_fixture',
          password: 'FixturePass123!',
          email: null,
          registrationToken: any(named: 'registrationToken'),
        ),
      ).called(1);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(1))
            .controller!
            .text,
        'device_fixture',
      );
      await tap(tester, find.byType(SwitchListTile));
      expect(find.byType(TextFormField), findsNWidgets(3));
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await capture(tester, 'coverage-anonymous-registration');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}

Widget _app(Widget home, {String locale = 'en'}) => MaterialApp(
  key: ValueKey(locale),
  debugShowCheckedModeBanner: false,
  locale: Locale(locale),
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  home: home,
);
