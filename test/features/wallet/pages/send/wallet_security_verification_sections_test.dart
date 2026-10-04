import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gesture_password_widget/gesture_password_widget.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/security/totp_util.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _userId = 'wallet-security-test-user';
const _googleSecret = 'JBSWY3DPEHPK3PXP';

class _WalletProvider extends WalletActionProvider {
  _WalletProvider(String password)
    : _walletInfo = WalletInfo(password: password);

  final WalletInfo _walletInfo;

  @override
  WalletInfo get walletInfo => _walletInfo;
}

class _LocalAuth extends LocalAuthPlatform {
  bool canCheck = true;
  bool authenticated = true;
  List<BiometricType> enrolled = const [BiometricType.fingerprint];

  @override
  Future<bool> isDeviceSupported() async => canCheck;

  @override
  Future<bool> deviceSupportsBiometrics() async => canCheck;

  @override
  Future<List<BiometricType>> getEnrolledBiometrics() async => enrolled;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async => authenticated;
}

void _storeSecurity(Map<String, dynamic> values) {
  FlutterSecureStorage.setMockInitialValues({
    'security': jsonEncode({_userId: values}),
  });
}

Future<void> _mount(
  WidgetTester tester, {
  String password = '',
  required ValueChanged<bool?> onResult,
}) async {
  tester.view.physicalSize = const Size(390, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    wrapForTest(
      Builder(
        builder: (context) => TextButton(
          key: const Key('open-security-verification'),
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute<bool>(
                builder: (_) => const WalletSecurityVerification(),
              ),
            );
            onResult(result);
          },
          child: const Text('Open verification'),
        ),
      ),
      overrides: [
        wapBridgeProvider.overrideWith((ref) => _WalletProvider(password)),
      ],
    ),
  );
  await tester.tap(find.byKey(const Key('open-security-verification')));
  await tester.pumpAndSettle();
}

void main() {
  late LocalAuthPlatform originalAuth;
  late _LocalAuth auth;

  setUp(() {
    originalAuth = LocalAuthPlatform.instance;
    auth = _LocalAuth();
    LocalAuthPlatform.instance = auth;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    AppGlobals.userInfo = UserInfo(uuid: _userId);
  });

  tearDown(() {
    LocalAuthPlatform.instance = originalAuth;
    AppGlobals.userInfo = null;
  });

  testWidgets('disabled verification methods show setup prompts', (
    tester,
  ) async {
    final result = Completer<bool?>();
    await _mount(tester, onResult: result.complete);
    final l10n = S.of(tester.element(find.byType(WalletSecurityVerification)));

    expect(find.text(l10n.g_lock_key24), findsOneWidget);
    expect(find.text(l10n.g_lock_key8), findsOneWidget);
    expect(find.text(l10n.g_lock_key28), findsOneWidget);
    expect(find.text(l10n.g_google_auth_key7), findsOneWidget);
    expect(find.text(l10n.google_verification_message10), findsNWidgets(4));
    expect(find.byType(TextField), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wallet password accepts a match and rejects an incorrect one', (
    tester,
  ) async {
    final result = Completer<bool?>();
    await _mount(tester, password: 'correct horse', onResult: result.complete);
    final l10n = S.of(tester.element(find.byType(WalletSecurityVerification)));
    final field = find.byType(TextField);

    expect(tester.widget<TextField>(field).obscureText, isTrue);
    final eye = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName.contains(
            'icon_denglu_yincang',
          ),
    );
    await tester.tap(eye);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).obscureText, isFalse);

    await tester.enterText(field, 'wrong password');
    await tester.tap(find.text(l10n.g_key_78));
    await tester.pumpAndSettle();
    expect(find.text(l10n.g_key_t_34), findsOneWidget);
    expect(result.isCompleted, isFalse);

    await tester.enterText(field, 'correct horse');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.g_key_78));
    await tester.pumpAndSettle();
    expect(await result.future, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('face, gesture, and authenticator checks gate confirmation', (
    tester,
  ) async {
    _storeSecurity({
      'face': true,
      'gesture': true,
      'gesturePwd': '0,1,4,7',
      'google': true,
      'googleSecret': _googleSecret,
    });
    final result = Completer<bool?>();
    await _mount(tester, onResult: result.complete);
    final page = find.byType(WalletSecurityVerification);
    final l10n = S.of(tester.element(page));
    final confirm = find.text(l10n.g_key_78);

    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(find.text(l10n.verification), findsOneWidget);

    auth.canCheck = false;
    final faceVerify = find.text(l10n.Verification).first;
    await tester.ensureVisible(faceVerify);
    await tester.tap(faceVerify);
    await tester.pumpAndSettle();
    expect(find.text(l10n.g_lock_key7), findsOneWidget);

    auth.canCheck = true;
    auth.authenticated = false;
    await tester.tap(find.text(l10n.Verification).first);
    await tester.pumpAndSettle();
    expect(find.text(l10n.g_lock_key6), findsNWidgets(2));

    auth.authenticated = true;
    await tester.tap(find.text(l10n.Verification).first);
    await tester.pumpAndSettle();
    expect(find.text(l10n.g_lock_key5), findsOneWidget);

    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(find.text(l10n.verification), findsOneWidget);
    final gesture = find.byType(GesturePasswordWidget);
    await tester.ensureVisible(gesture);
    tester.widget<GesturePasswordWidget>(gesture).onComplete!([0, 2, 4, 6]);
    await tester.pumpAndSettle();
    expect(find.text(l10n.g_lock_key6), findsOneWidget);

    tester
        .widget<GesturePasswordWidget>(find.byType(GesturePasswordWidget))
        .onComplete!([0, 1, 4, 7]);
    await tester.pumpAndSettle();
    expect(find.byType(GesturePasswordWidget), findsNothing);
    expect(find.text(l10n.g_lock_key5), findsNWidgets(2));

    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(find.text(l10n.verification), findsOneWidget);
    final googleField = find.byType(TextField);
    await tester.ensureVisible(googleField);
    await tester.enterText(googleField, '12x');
    await tester.tap(find.text(l10n.Verification).last);
    await tester.pumpAndSettle();
    expect(find.text(l10n.g_google_auth_key6), findsOneWidget);

    await tester.enterText(googleField, TotpUtil.generate(_googleSecret));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text(l10n.g_lock_key5), findsNWidgets(3));

    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(await result.future, isTrue);
    expect(tester.takeException(), isNull);
  });
}
