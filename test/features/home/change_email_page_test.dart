import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/home/setting/change_email_api.dart';
import 'package:n42_wallet/features/home/setting/change_email_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

class _FakeChangeEmailApi extends ChangeEmailApi {
  int sendCalls = 0;
  int verifyCalls = 0;
  int updateCalls = 0;

  @override
  Future<dynamic> sendUpdateEmailCode(String newEmail) async {
    sendCalls++;
  }

  @override
  Future<dynamic> verifyUpdateEmailCode(String code) async {
    verifyCalls++;
  }

  @override
  Future<dynamic> updateEmail({
    required String newEmail,
    required String code,
  }) async {
    updateCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');

  late _FakeChangeEmailApi api;

  setUp(() {
    api = _FakeChangeEmailApi();
    AppGlobals.userInfo = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (_) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
  });

  testWidgets('validates email and completes verification before updating', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrapForTest(ChangeEmailPage(api: api)));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('change_email_email_field')),
      'invalid-address',
    );
    await tester.tap(find.text(S.current.g_ui_send_code));
    await tester.pump();
    expect(find.text(S.current.g_ui_invalid_email), findsOneWidget);
    expect(api.sendCalls, 0);

    await tester.enterText(
      find.byKey(const Key('change_email_email_field')),
      'person@example.com',
    );
    await tester.tap(find.text(S.current.g_ui_send_code));
    await tester.pump();
    expect(api.sendCalls, 1);
    expect(find.text(S.current.g_ui_verification_code), findsOneWidget);

    await tester.tap(
      find.widgetWithText(ElevatedButton, S.current.g_ui_verify_code),
    );
    await tester.pump();
    expect(find.text(S.current.g_google_auth_key4), findsOneWidget);
    expect(api.verifyCalls, 0);

    await tester.enterText(find.byType(TextField).last, '123456');
    await tester.tap(
      find.widgetWithText(ElevatedButton, S.current.g_ui_verify_code),
    );
    await tester.pumpAndSettle();
    expect(api.verifyCalls, 1);
    expect(find.text(S.current.g_ui_confirm_update), findsOneWidget);

    await tester.tap(
      find.widgetWithText(ElevatedButton, S.current.g_ui_update_email),
    );
    await tester.pumpAndSettle();
    expect(api.updateCalls, 1);
    expect(find.text(S.current.g_key_185), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });
}
