import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/home/setting/change_email_page.dart';
import 'package:n42_wallet/features/home/setting/change_email_ui_helpers.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

class _FailingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw const SocketException('blocked by change-email widget test');
  }
}

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FailingHttpClient();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttpOverrides = HttpOverrides.current;

  setUp(() => HttpOverrides.global = _OfflineHttpOverrides());
  tearDown(() => HttpOverrides.global = previousHttpOverrides);

  testWidgets('invalid email stays on the first step without sending', (
    tester,
  ) async {
    await tester.pumpWidget(wrapForTest(const ChangeEmailPage()));
    await tester.pumpAndSettle();

    final emailField = find.byKey(const Key('change_email_email_field'));
    await tester.enterText(emailField, 'not-an-email');
    await tester.tap(find.text(S.current.g_ui_send_code));
    await tester.pumpAndSettle();

    expect(find.text(S.current.g_ui_invalid_email), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(S.current.g_ui_verification_code), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('valid email request reports offline failure and unlocks form', (
    tester,
  ) async {
    await tester.pumpWidget(wrapForTest(const ChangeEmailPage()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('change_email_email_field')),
      'new@example.com',
    );
    await tester.tap(find.text(S.current.g_ui_send_code));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text(S.current.g_ui_invalid_email), findsNothing);
    expect(find.text(S.current.g_ui_verification_code), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(S.current.g_key_error_10), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('email field rejects whitespace and clears validation on edit', (
    tester,
  ) async {
    await tester.pumpWidget(wrapForTest(const ChangeEmailPage()));
    await tester.pumpAndSettle();

    final emailField = find.byKey(const Key('change_email_email_field'));
    await tester.enterText(emailField, 'bad');
    await tester.tap(find.text(S.current.g_ui_send_code));
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_ui_invalid_email), findsOneWidget);

    await tester.enterText(emailField, 'valid@example.com with-space');
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_ui_invalid_email), findsNothing);
    expect(
      tester.widget<TextField>(emailField).controller!.text,
      'valid@example.comwith-space',
    );
  });

  testWidgets('verification code field accepts digits only and caps at six', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);

    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => Scaffold(
            body: changeEmailCodeField(
              ctrl: controller,
              focus: focus,
              textColor: Colors.black,
              fillColor: Colors.white,
              accentColor: Colors.blue,
              subColor: Colors.grey,
              onChanged: (_) {},
              onSubmitted: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '12a345678');
    await tester.pump();
    expect(controller.text, '123456');
    expect(
      tester.widget<TextField>(find.byType(TextField)).keyboardType,
      TextInputType.number,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('resend helper disables during countdown and while loading', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                changeEmailResendRow(
                  context: context,
                  countdown: 7,
                  loading: false,
                  onTap: () => taps++,
                  accentColor: Colors.blue,
                  subColor: Colors.grey,
                ),
                changeEmailResendRow(
                  context: context,
                  countdown: 0,
                  loading: true,
                  onTap: () => taps++,
                  accentColor: Colors.blue,
                  subColor: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final buttons = tester.widgetList<TextButton>(find.byType(TextButton));
    expect(buttons, hasLength(2));
    expect(buttons.every((button) => button.onPressed == null), isTrue);
    expect(find.text(S.current.g_email_resend_countdown(7)), findsOneWidget);
    await tester.tap(find.text(S.current.g_email_resend_countdown(7)));
    await tester.pump();
    expect(taps, 0);
  });

  testWidgets('resend helper invokes callback when ready', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => Scaffold(
            body: changeEmailResendRow(
              context: context,
              countdown: 0,
              loading: false,
              onTap: () => taps++,
              accentColor: Colors.blue,
              subColor: Colors.grey,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(S.current.g_email_resend));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('resend helper becomes enabled when countdown expires', (
    tester,
  ) async {
    var countdown = 1;
    var taps = 0;
    await tester.pumpWidget(
      wrapForTest(
        StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Column(
              children: [
                changeEmailResendRow(
                  context: context,
                  countdown: countdown,
                  loading: false,
                  onTap: () => taps++,
                  accentColor: Colors.blue,
                  subColor: Colors.grey,
                ),
                TextButton(
                  onPressed: () => setState(() => countdown = 0),
                  child: const Text('expire countdown'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(S.current.g_email_resend_countdown(1)), findsOneWidget);
    expect(
      tester.widgetList<TextButton>(find.byType(TextButton)).first.onPressed,
      isNull,
    );
    await tester.tap(find.text('expire countdown'));
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_email_resend), findsOneWidget);
    expect(
      tester.widgetList<TextButton>(find.byType(TextButton)).first.onPressed,
      isNotNull,
    );

    await tester.tap(find.text(S.current.g_email_resend));
    await tester.pump();
    expect(taps, 1);
  });

  test(
    'input decoration carries its hint, error and counter configuration',
    () {
      final decoration = changeEmailInputDeco(
        hint: 'email',
        fillColor: Colors.white,
        accentColor: Colors.blue,
        subColor: Colors.grey,
        errorText: 'invalid',
        counterText: '',
        suffixIcon: const Icon(Icons.mail_outline),
      );

      expect(decoration.hintText, 'email');
      expect(decoration.errorText, 'invalid');
      expect(decoration.counterText, '');
      expect(decoration.suffixIcon, isA<Icon>());
      expect(decoration.filled, isTrue);
      expect(decoration.border, isA<OutlineInputBorder>());
    },
  );
}
