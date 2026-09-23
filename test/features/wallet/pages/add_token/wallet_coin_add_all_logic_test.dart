import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/wallet_coin_add_all.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _trustdartChannel = MethodChannel('trustdart');
const _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
var _addressValidationCalls = 0;

class _WalletProvider extends WalletActionProvider {
  _WalletProvider({bool includeEthereum = true}) {
    walletInfoLsit.add(
      WalletInfo(
        coinInfo: {
          if (includeEthereum)
            'ETH': {
              'baseInfo': {
                'coinType': 'ETH',
                'miniName': 'ETH',
                'name': 'Ethereum',
                'blockchainType': 'Ethereum',
                'service': '',
              },
              'isTest': false,
              'showList': true,
              'mainnets': <String, dynamic>{},
              'testnets': [
                {'testnetContract': <String, dynamic>{}},
              ],
            },
        },
      ),
    );
    walletIndex = 0;
  }
}

Future<void> _mountWithoutExternalNetwork(
  WidgetTester tester, {
  _WalletProvider? wallet,
}) async {
  await HttpOverrides.runZoned(
    () => tester.pumpWidget(
      wrapForTest(
        const WalletCoinAddAll(''),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => wallet ?? _WalletProvider()),
        ],
      ),
    ),
    createHttpClient: (_) => throw StateError('Network is disabled in tests'),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _addressValidationCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_trustdartChannel, (call) async {
          if (call.method == 'validateAddress') {
            _addressValidationCalls++;
            return true;
          }
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_toastChannel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_trustdartChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_toastChannel, null);
  });

  testWidgets('empty contract is rejected before invoking address validation', (
    tester,
  ) async {
    await _mountWithoutExternalNetwork(tester);
    await tester.tap(find.text(S.current.g_token_m_key_5));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(FilledButton, S.current.g_token_m_key_9),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WalletCoinAddAll), findsOneWidget);
    expect(_addressValidationCalls, 0);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets(
    'contract import is rejected when the selected chain is missing',
    (tester) async {
      final wallet = _WalletProvider(includeEthereum: false);
      await _mountWithoutExternalNetwork(tester, wallet: wallet);
      await tester.tap(find.text(S.current.g_token_m_key_5));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '0xabc');
      await tester.tap(
        find.widgetWithText(FilledButton, S.current.g_token_m_key_9),
      );
      await tester.pumpAndSettle();

      expect(_addressValidationCalls, 0);
      expect(wallet.walletMap, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 8));
    },
  );

  testWidgets(
    'out-of-range decimals preserve the form and do not add a token',
    (tester) async {
      final wallet = _WalletProvider();
      await _mountWithoutExternalNetwork(tester, wallet: wallet);
      await tester.tap(find.text(S.current.g_token_m_key_5));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      await tester.enterText(
        fields.at(0),
        '0x0000000000000000000000000000000000000001',
      );
      await tester.enterText(fields.at(1), 'TST');
      await tester.enterText(fields.at(2), '19');
      await tester.tap(
        find.widgetWithText(FilledButton, S.current.g_token_m_key_9),
      );
      await tester.pumpAndSettle();

      expect(wallet.walletMap['ETH']['mainnets'], isEmpty);
      expect(
        tester.widget<TextField>(fields.at(0)).controller!.text,
        '0x0000000000000000000000000000000000000001',
      );
      expect(tester.widget<TextField>(fields.at(1)).controller!.text, 'TST');
      expect(tester.widget<TextField>(fields.at(2)).controller!.text, '19');
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 8));
    },
  );
}
