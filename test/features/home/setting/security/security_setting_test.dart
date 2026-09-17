import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gesture_password_widget/gesture_password_widget.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/home/setting/security/security_setting.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _LocalAuth extends LocalAuthPlatform {
  bool supported = true;
  bool canCheck = true;
  bool authenticated = true;
  List<BiometricType> enrolled = [BiometricType.fingerprint];
  int authenticationCalls = 0;

  @override
  Future<bool> isDeviceSupported() async => supported;

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
      uuid: 'security-test-user',
      email: 'security@example.test',
    );
  });

  tearDown(() {
    LocalAuthPlatform.instance = originalAuth;
    AppGlobals.userInfo = null;
  });

  Future<void> storeSecurity(Map<String, dynamic> values) async {
    FlutterSecureStorage.setMockInitialValues({
      'security': jsonEncode({'security-test-user': values}),
    });
  }

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrapForTest(const SecuritySetting()));
    await tester.pumpAndSettle();
  }

  testWidgets('renders persisted settings and authenticates page entry', (
    tester,
  ) async {
    await storeSecurity({
      'email': true,
      'google': true,
      'face': true,
      'gesture': true,
      'gesturePwd': '0,1,4,7',
      'googleSecret': 'fixture-secret',
    });
    await mount(tester);

    expect(auth.authenticationCalls, 1);
    expect(find.text('Account Security'), findsOneWidget);
    expect(find.text('security@example.test'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      tester
          .widget<Switch>(
            find.byKey(const ValueKey<String>('security_face_toggle')),
          )
          .value,
      isTrue,
    );
    expect(find.text(S.current.g_lock_key22), findsOneWidget);
  });

  testWidgets('cancelled entry authentication closes protected settings', (
    tester,
  ) async {
    auth.authenticated = false;
    await storeSecurity({
      'email': false,
      'google': false,
      'face': true,
      'gesture': false,
      'gesturePwd': '',
      'googleSecret': '',
    });
    await mount(tester);

    expect(auth.authenticationCalls, 1);
    expect(find.byType(SecuritySetting), findsNothing);
  });

  testWidgets('face toggle requires authentication and persists success', (
    tester,
  ) async {
    await mount(tester);
    final face = find.byKey(const ValueKey<String>('security_face_toggle'));
    expect(tester.widget<Switch>(face).value, isFalse);

    auth.authenticated = false;
    await tester.tap(face);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(face).value, isFalse);

    auth.authenticated = true;
    await tester.tap(face);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(face).value, isTrue);
    expect(auth.authenticationCalls, 2);
    final saved = await SPUtil().getSecurity();
    expect(saved?['security-test-user']?['face'], isTrue);
  });

  testWidgets('unavailable biometrics disables verification settings', (
    tester,
  ) async {
    auth.supported = false;
    await mount(tester);

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches, hasLength(3));
    expect(
      switches,
      everyElement(predicate<Switch>((s) => s.onChanged == null)),
    );
    expect(find.text(S.current.g_lock_key7), findsOneWidget);
  });

  testWidgets('gesture setup result is persisted after face is enabled', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('security_face_toggle')),
    );
    await tester.pumpAndSettle();

    final gestureSwitch = tester
        .widgetList<Switch>(find.byType(Switch))
        .elementAt(1);
    gestureSwitch.onChanged!(true);
    await tester.pumpAndSettle();
    final first = tester.widget<GesturePasswordWidget>(
      find.byType(GesturePasswordWidget),
    );
    first.onComplete!([0, 1, 4, 7]);
    await tester.pumpAndSettle();
    tester
        .widget<GesturePasswordWidget>(find.byType(GesturePasswordWidget))
        .onComplete!([0, 1, 4, 7]);
    await tester.pumpAndSettle();

    final saved = await SPUtil().getSecurity();
    expect(saved?['security-test-user']?['gesture'], isTrue);
    expect(saved?['security-test-user']?['gesturePwd'], '0,1,4,7');
    expect(find.text(S.current.g_lock_key22), findsOneWidget);
  });
}
