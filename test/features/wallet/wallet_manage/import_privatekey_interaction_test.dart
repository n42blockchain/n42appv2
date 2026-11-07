import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/import_privatekey.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_password.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const trustdart = MethodChannel('trustdart');
  const toast = MethodChannel('PonnamKarthik/fluttertoast');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final nativeCalls = <String>[];
  final toasts = <String>[];

  setUp(() {
    nativeCalls.clear();
    toasts.clear();
    messenger.setMockMethodCallHandler(trustdart, (call) async {
      nativeCalls.add(call.method);
      // Always refuse secret-bearing address generation. No native wallet
      // operation or persistent wallet store is available in this test.
      if (call.method == 'generateAddress') return {'legacy': ''};
      throw PlatformException(code: 'unexpected-native-call');
    });
    messenger.setMockMethodCallHandler(toast, (call) async {
      if (call.method == 'showToast') {
        toasts.add((call.arguments as Map)['msg'] as String);
      }
      return true;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(trustdart, null);
    messenger.setMockMethodCallHandler(toast, null);
  });

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        const ImportPrivatekey(),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => WalletActionProvider()),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.text(S.current.g_key_78));
    await tester.pumpAndSettle();
  }

  Future<void> drainToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 8));
  }

  testWidgets(
    'renders import form and rejects empty input without native call',
    (tester) async {
      await open(tester);

      expect(find.byType(ImportPrivatekey), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      await submit(tester);

      expect(nativeCalls, isEmpty);
      expect(find.text(S.current.g_key_210), findsOneWidget);
      expect(toasts, contains(S.current.g_key_210));
      await drainToast(tester);
    },
  );

  testWidgets('trims the draft and rejects malformed hex locally', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), '  0xnot-hex  ');
    await submit(tester);

    expect(nativeCalls, isEmpty);
    expect(find.text(S.current.g_key_210), findsOneWidget);
    expect(toasts, contains(S.current.g_key_210));
    await drainToast(tester);
  });

  testWidgets('synthetic hex reaches mocked validator and reports refusal', (
    tester,
  ) async {
    await open(tester);
    // Synthetic fixture only; the mocked channel returns no address and
    // cannot derive, import, or persist a wallet.
    await tester.enterText(find.byType(TextField), List.filled(64, 'a').join());
    await submit(tester);

    expect(nativeCalls, ['generateAddress']);
    expect(find.text(S.current.g_key_210), findsOneWidget);
    expect(toasts, contains(S.current.g_key_210));
    expect(tester.takeException(), isNull);
    await drainToast(tester);
  });
  testWidgets('valid native address preserves private-key password setup', (
    tester,
  ) async {
    messenger.setMockMethodCallHandler(trustdart, (call) async {
      nativeCalls.add(call.method);
      if (call.method == 'generateAddress') {
        return {'legacy': '0x7e5f4552091a69125d5dfcb7b8c2659029395bdf'};
      }
      if (call.method == 'validateAddress') return true;
      throw PlatformException(code: 'unexpected-native-call');
    });
    await open(tester);
    await tester.enterText(
      find.byType(TextField),
      '${List.filled(63, '0').join()}1',
    );
    await submit(tester);
    expect(find.byType(CreatePassword), findsOneWidget);
    expect(nativeCalls, [
      'generateAddress',
      'validateAddress',
      'generateAddress',
    ]);
    expect(toasts, isEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final address in <Object?>[null, '', '   ', 42]) {
    testWidgets(
      'invalid native address ($address) cannot advance a base58 import',
      (tester) async {
        messenger.setMockMethodCallHandler(trustdart, (call) async {
          nativeCalls.add(call.method);
          if (call.method == 'generateAddress') {
            return <String, dynamic>{'legacy': address};
          }
          throw PlatformException(code: 'unexpected-native-call');
        });
        await open(tester);
        await tester.enterText(
          find.byType(TextField),
          '11111111111111111111111111111111',
        );
        await submit(tester);
        expect(find.byType(ImportPrivatekey), findsOneWidget);
        expect(find.text(S.current.g_key_210), findsOneWidget);
        expect(tester.takeException(), isNull);
        await drainToast(tester);
      },
    );
  }
}
