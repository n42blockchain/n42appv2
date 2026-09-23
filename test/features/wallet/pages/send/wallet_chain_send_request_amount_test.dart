import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWallet extends WalletActionProvider {
  int balanceReads = 0;

  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async {
    balanceReads++;
    return false;
  }
}

CoinModel _incompleteChainCoin() {
  final coin = CoinModel.fromMap({
    'coinType': 'ETH',
    'blockchainType': '',
    'miniName': 'ETH',
    'name': 'Ethereum',
    'unit': 'ETH',
    'decimals': 18,
  });
  coin
    ..address = '0x1111111111111111111111111111111111111111'
    ..balance = BigInt.from(2000000000000000000);
  return coin;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (_) async => true);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
  });

  testWidgets('positive payment-request amount is locked and not fetched', (
    tester,
  ) async {
    final wallet = _OfflineWallet();
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSend(
          _incompleteChainCoin(),
          initialToAddress: '0x2222222222222222222222222222222222222222',
          initialAmount: '1.25',
        ),
        overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
      ),
    );
    await tester.pumpAndSettle();

    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(
      fields.any((field) => field.readOnly && field.controller?.text == '1.25'),
      isTrue,
    );
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(find.text('Invalid coin configuration'), findsOneWidget);
    expect(wallet.balanceReads, 0);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets('zero payment-request amount remains editable', (tester) async {
    final wallet = _OfflineWallet();
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSend(
          _incompleteChainCoin(),
          initialToAddress: '0x2222222222222222222222222222222222222222',
          initialAmount: '0',
        ),
        overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
      ),
    );
    await tester.pumpAndSettle();

    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(
      fields.any((field) => !field.readOnly && field.controller?.text == '0'),
      isTrue,
    );
    expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    expect(find.text(S.current.g_key_197), findsOneWidget);
    expect(find.text('Invalid coin configuration'), findsOneWidget);
    expect(wallet.balanceReads, 0);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 8));
  });
}
