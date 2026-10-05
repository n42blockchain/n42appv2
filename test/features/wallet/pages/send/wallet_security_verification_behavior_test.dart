import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gesture_password_widget/gesture_password_widget.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/security/totp_util.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _LocalAuth extends LocalAuthPlatform {
  bool canCheck = true;
  bool authenticated = true;
  List<BiometricType> enrolled = [BiometricType.fingerprint];
  int authenticationCalls = 0;

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> deviceSupportsBiometrics() async => canCheck;

  @override
  Future<List<BiometricType>> getEnrolledBiometrics() async => enrolled;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    authenticationCalls++;
    return authenticated;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalAuthPlatform originalAuth;
  late _LocalAuth auth;

  setUp(() {
    originalAuth = LocalAuthPlatform.instance;
    auth = _LocalAuth();
    LocalAuthPlatform.instance = auth;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    AppGlobals.userInfo = UserInfo(
      uuid: 'verification-test-user',
      email: 'verification@example.test',
    );
  });

  tearDown(() {
    LocalAuthPlatform.instance = originalAuth;
    AppGlobals.userInfo = null;
  });

  Future<List<bool?>> openVerification(
    WidgetTester tester, {
    Map<String, dynamic> security = const {},
    String walletPassword = '',
  }) async {
    final results = <bool?>[];
    final walletProvider = WalletActionProvider();
    walletProvider.walletInfoLsit.add(WalletInfo(password: walletPassword));
    walletProvider.walletIndex = 0;

    await SPUtil().setSecurity({
      'verification-test-user': {
        'face': false,
        'gesture': false,
        'gesturePwd': '',
        'google': false,
        'googleSecret': '',
        ...security,
      },
    });

    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              results.add(
                await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const WalletSecurityVerification(),
                  ),
                ),
              );
            },
            child: const Text('Open verification'),
          ),
        ),
        overrides: [wapBridgeProvider.overrideWith((ref) => walletProvider)],
      ),
    );
    await tester.tap(find.text('Open verification'));
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
    });
    return results;
  }

  Future<void> completeGesture(WidgetTester tester, List<int> pattern) async {
    tester
        .widget<GesturePasswordWidget>(find.byType(GesturePasswordWidget))
        .onComplete!(pattern);
    await tester.pumpAndSettle();
  }

  Future<void> hideKeyboard(WidgetTester tester) async {
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
  }

  testWidgets(
    'disabled verification sections prompt setup and keep confirm disabled',
    (tester) async {
      final results = await openVerification(tester);

      expect(find.text(S.current.g_lock_key24), findsOneWidget);
      expect(find.text(S.current.g_lock_key8), findsOneWidget);
      expect(find.text(S.current.g_lock_key28), findsOneWidget);
      expect(find.text(S.current.g_google_auth_key7), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(GesturePasswordWidget), findsNothing);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, S.current.g_key_78),
            )
            .onPressed,
        isNull,
      );

      await tester.tap(find.text(S.current.g_key_79));
      await tester.pumpAndSettle();
      expect(results, [false]);
    },
  );

  testWidgets(
    'wallet password rejects a mismatch and accepts the stored password',
    (tester) async {
      final results = await openVerification(
        tester,
        walletPassword: 'stored-wallet-password',
      );
      final passwordInput = find.byType(TextField);

      await tester.enterText(passwordInput, 'wrong-password');
      await hideKeyboard(tester);
      await tester.tap(find.text(S.current.g_key_78));
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_key_t_34), findsOneWidget);
      expect(results, isEmpty);

      await tester.enterText(passwordInput, 'stored-wallet-password');
      await hideKeyboard(tester);
      await tester.tap(find.text(S.current.g_key_78));
      await tester.pumpAndSettle();
      expect(results, [true]);
    },
  );

  testWidgets(
    'biometric verification reports unavailable, failure, and success',
    (tester) async {
      final results = await openVerification(tester, security: {'face': true});

      await tester.tap(find.text(S.current.g_key_78));
      await tester.pumpAndSettle();
      expect(find.text(S.current.verification), findsOneWidget);
      expect(results, isEmpty);

      auth.canCheck = false;
      await tester.tap(find.text(S.current.Verification));
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_lock_key7), findsOneWidget);
      expect(auth.authenticationCalls, 0);

      auth.canCheck = true;
      auth.authenticated = false;
      await tester.tap(find.text(S.current.Verification));
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_lock_key6), findsAtLeastNWidgets(1));
      expect(auth.authenticationCalls, 1);

      auth.authenticated = true;
      await tester.tap(find.text(S.current.Verification));
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_lock_key5), findsOneWidget);
      expect(auth.authenticationCalls, 2);

      await tester.tap(find.text(S.current.g_key_78));
      await tester.pumpAndSettle();
      expect(results, [true]);
    },
  );

  testWidgets(
    'gesture feedback rejects a wrong pattern then confirms the saved one',
    (tester) async {
      final results = await openVerification(
        tester,
        security: {'gesture': true, 'gesturePwd': '0,1,4,7'},
      );

      await tester.tap(find.text(S.current.g_key_78));
      await tester.pumpAndSettle();
      expect(find.text(S.current.verification), findsOneWidget);
      expect(results, isEmpty);

      await completeGesture(tester, [0, 2, 4, 6]);
      expect(find.text(S.current.g_lock_key6), findsOneWidget);
      expect(results, isEmpty);

      await completeGesture(tester, [0, 1, 4, 7]);
      expect(find.text(S.current.g_lock_key5), findsOneWidget);
      await tester.tap(find.text(S.current.g_key_78));
      await tester.pumpAndSettle();
      expect(results, [true]);
    },
  );

  testWidgets(
    'Google authenticator feedback rejects a short code then accepts TOTP',
    (tester) async {
      const secret = 'JBSWY3DPEHPK3PXP';
      final results = await openVerification(
        tester,
        security: {'google': true, 'googleSecret': secret},
      );
      final codeInput = find.byType(TextField);

      await tester.tap(find.text(S.current.g_key_78));
      await tester.pumpAndSettle();
      expect(find.text(S.current.verification), findsOneWidget);
      expect(results, isEmpty);

      await tester.enterText(codeInput, '123');
      await hideKeyboard(tester);
      await tester.tap(find.text(S.current.Verification));
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_google_auth_key6), findsOneWidget);
      expect(results, isEmpty);

      await tester.enterText(codeInput, TotpUtil.generate(secret));
      await hideKeyboard(tester);
      await tester.tap(find.text(S.current.Verification));
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_lock_key5), findsOneWidget);

      await tester.tap(find.text(S.current.g_key_78));
      await tester.pumpAndSettle();
      expect(results, [true]);
    },
  );
}
