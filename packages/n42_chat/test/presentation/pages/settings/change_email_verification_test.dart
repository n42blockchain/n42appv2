import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_event.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_state.dart';
import 'package:n42_chat/src/presentation/blocs/bloc_message_keys.dart';
import 'package:n42_chat/src/presentation/pages/settings/change_email_page.dart';

class _AuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const fontPath = String.fromEnvironment('EMAIL_SCREENSHOT_FONT');
  late _AuthBloc bloc;
  late StreamController<AuthState> states;
  late List<AuthEvent> events;
  final boundaryKey = GlobalKey();
  Future<void> open(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    double scale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: fontPath.isEmpty ? null : 'EmailAudit'),
        locale: locale,
        supportedLocales: S.supportedLocales,
        localizationsDelegates: S.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: RepaintBoundary(
            key: boundaryKey,
            child: const ChangeEmailPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> request(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'test-password');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      ' alice+tag@example.technology ',
    );
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
  }

  Future<void> deliver(
    WidgetTester tester,
    ChangeEmailStatus status, {
    String? error,
  }) async {
    states.add(
      AuthState(
        status: AuthStatus.authenticated,
        changeEmailStatus: status,
        errorMessage: error,
      ),
    );
    await tester.pumpAndSettle();
  }

  setUpAll(() async {
    registerFallbackValue(const AuthGetBoundEmailRequested());
    if (fontPath.isNotEmpty) {
      final loader = FontLoader('EmailAudit')
        ..addFont(
          File(
            fontPath,
          ).readAsBytes().then((bytes) => bytes.buffer.asByteData()),
        );
      await loader.load();
    }
  });
  setUp(() {
    bloc = _AuthBloc();
    states = StreamController<AuthState>.broadcast();
    events = [];
    whenListen(bloc, states.stream, initialState: const AuthState.initial());
    when(() => bloc.add(any())).thenAnswer(
      (call) => events.add(call.positionalArguments.single as AuthEvent),
    );
  });
  tearDown(() async => states.close());

  testWidgets(
    'request accepts plus addressing and long domains and dispatches once',
    (tester) async {
      await open(tester);
      await request(tester);
      final event = events.whereType<AuthRequestChangeEmailRequested>().single;
      expect(event.newEmail, 'alice+tag@example.technology');
      expect(event.password, 'test-password');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(events.whereType<AuthRequestChangeEmailRequested>(), hasLength(1));
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('link response shows instructions and confirms without a code', (
    tester,
  ) async {
    await open(tester);
    await request(tester);
    await deliver(tester, ChangeEmailStatus.linkSent);
    expect(find.byType(TextFormField), findsNothing);
    expect(
      find.text(
        'Open the verification link in your email, then return here and confirm.',
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(events.whereType<AuthConfirmChangeEmailRequested>().single.code, '');
    final confirmation = events
        .whereType<AuthConfirmChangeEmailRequested>()
        .single;
    expect(confirmation.password, 'test-password');
    expect(confirmation.props, isNot(contains('test-password')));
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'code response accepts opaque token and prevents duplicate keyboard submission',
    (tester) async {
      await open(tester);
      await request(tester);
      await deliver(tester, ChangeEmailStatus.codeSent);
      expect(find.byType(TextFormField), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), ' AbC=123 ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(events.whereType<AuthConfirmChangeEmailRequested>(), hasLength(1));
      expect(
        events.whereType<AuthConfirmChangeEmailRequested>().single.code,
        ' AbC=123 ',
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('failed confirmation shows translated error and allows retry', (
    tester,
  ) async {
    await open(tester);
    await request(tester);
    await deliver(tester, ChangeEmailStatus.linkSent);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await deliver(
      tester,
      ChangeEmailStatus.failed,
      error: BlocMessageKeys.authChangeEmailFailed,
    );
    expect(find.text(BlocMessageKeys.authChangeEmailFailed), findsNothing);
    expect(find.text('Failed to change email'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(events.whereType<AuthConfirmChangeEmailRequested>(), hasLength(2));
    await tester.pumpWidget(const SizedBox());
  });
  for (final locale in [
    const Locale('en'),
    const Locale('zh'),
    const Locale('ar'),
  ]) {
    testWidgets(
      'link instructions fit 320px and large text: ${locale.languageCode}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await open(tester, locale: locale, scale: 1.6);
        await request(tester);
        await deliver(tester, ChangeEmailStatus.linkSent);
        expect(tester.takeException(), isNull);
        final context = tester.element(find.byType(ChangeEmailPage));
        expect(
          find.text(S.of(context)!.settingsEmailLinkInstructions),
          findsOneWidget,
        );
        await tester.ensureVisible(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        const screenshotDir = String.fromEnvironment('EMAIL_SCREENSHOT_DIR');
        if (screenshotDir.isNotEmpty) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final boundary =
                boundaryKey.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final screenshot = await boundary.toImage();
            final bytes = await screenshot.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory(screenshotDir).create(recursive: true);
            await File(
              '$screenshotDir/email-link-${locale.languageCode}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            screenshot.dispose();
          });
        }
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
