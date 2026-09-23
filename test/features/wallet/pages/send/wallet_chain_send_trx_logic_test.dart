import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_trx.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _trustdartChannel = MethodChannel('trustdart');
const _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;

  @override
  void calculateBalanceWidthCoinModel() {}

  @override
  void refresh() {}
}

CoinModel _trxCoin() => CoinModel()
  ..coin = {
    'coinType': 'TRX',
    'blockchainType': 'Tron',
    'miniName': 'TRX',
    'unit': 'TRX',
    'decimals': 6,
    'isContract': false,
    'service': '',
    'contract': '',
    'contract_test': '',
    'path': {'legacy': "m/44'/195'/0'/0/0"},
  }
  ..addrType = 'legacy'
  ..address = 'T1234567890123456789012345678901234'
  ..balance = BigInt.from(100000000);

Future<void> _mountOffline(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await HttpOverrides.runZoned(
    () async {
      await tester.pumpWidget(
        wrapForTest(
          WalletChainSendTrx(_trxCoin()),
          overrides: [
            wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
          ],
        ),
      );
      await tester.pumpAndSettle();
    },
    createHttpClient: (_) => throw StateError('Live network disabled in test'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var trustdartCalls = <MethodCall>[];

  setUp(() {
    trustdartCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_trustdartChannel, (call) async {
          trustdartCalls.add(call);
          if (call.method == 'validateAddress') return true;
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_toastChannel, (_) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_trustdartChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_toastChannel, null);
  });

  testWidgets(
    'TRX amount validation rejects zero and clears for valid amount',
    (tester) async {
      await _mountOffline(tester);
      final amountField = find.byType(TextField).at(1);

      await tester.enterText(amountField, '0.0');
      await tester.pump();
      expect(find.text(S.current.g_key_46(0)), findsOneWidget);

      await tester.enterText(amountField, '50');
      await tester.pump();
      expect(find.text(S.current.g_key_46(0)), findsNothing);
      expect(find.text(S.current.g_key_47), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 8));
    },
  );

  testWidgets(
    'TRX amount above native balance is rejected before address lookup',
    (tester) async {
      await _mountOffline(tester);
      final fields = find.byType(TextField);
      await tester.enterText(
        fields.at(0),
        'T1234567890123456789012345678901235',
      );
      await tester.enterText(fields.at(1), '101');
      await tester.pump();
      expect(find.text(S.current.g_key_47), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, S.current.g_key_48));
      await tester.pumpAndSettle();
      expect(
        trustdartCalls.where((call) => call.method == 'validateAddress'),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 8));
    },
  );
}
