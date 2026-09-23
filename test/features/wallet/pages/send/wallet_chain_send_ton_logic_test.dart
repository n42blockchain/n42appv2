import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_ton.dart';
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

CoinModel _tonCoin({BigInt? balance}) => CoinModel()
  ..coin = {
    'coinType': 'TON',
    'blockchainType': 'TheOpenNetwork',
    'miniName': 'TON',
    'unit': 'TON',
    'decimals': 9,
    'isContract': false,
    'service': 'https://invalid.test/rpc',
    'contract': '',
    'contract_test': '',
    'path': {'legacy': "m/44'/607'/0'"},
  }
  ..addrType = 'legacy'
  ..address = 'EQ1234567890123456789012345678901234567890'
  ..balance = balance ?? BigInt.from(2000000000);

Future<void> _mountOffline(WidgetTester tester, CoinModel coin) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await HttpOverrides.runZoned(
    () async {
      await tester.pumpWidget(
        wrapForTest(
          WalletChainSendTon(coin),
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

  testWidgets('TON amount rejects zero and clears after valid input', (
    tester,
  ) async {
    await _mountOffline(tester, _tonCoin());
    final amountField = find.byType(TextField).at(1);

    await tester.enterText(amountField, '0.0');
    await tester.pump();
    expect(find.text(S.current.g_key_46(0)), findsOneWidget);

    await tester.enterText(amountField, '0.25');
    await tester.pump();
    expect(find.text(S.current.g_key_46(0)), findsNothing);
    expect(find.text(S.current.g_key_134), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets('TON insufficient native balance stops before confirmation', (
    tester,
  ) async {
    await _mountOffline(tester, _tonCoin(balance: BigInt.from(500000)));
    final fields = find.byType(TextField);
    await tester.enterText(
      fields.at(0),
      'EQ9876543210987654321098765432109876543210',
    );
    await tester.enterText(fields.at(1), '0.1');
    await tester.pump();
    await tester.tap(find.text(S.current.g_key_48));
    await tester.pumpAndSettle();

    expect(
      trustdartCalls.where((call) => call.method == 'validateAddress'),
      hasLength(1),
    );
    expect(find.textContaining('Confirm'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });
}
