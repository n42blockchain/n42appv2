import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_algo.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _trustdartChannel = MethodChannel('trustdart');
const _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
const _ownerAddress = 'ALGOOWNER234567890123456789012345678901234567890123456';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;

  @override
  void calculateBalanceWidthCoinModel() {}

  @override
  void refresh() {}
}

CoinModel _algoCoin() => CoinModel()
  ..coin = {
    'coinType': 'ALGO',
    'blockchainType': 'Algorand',
    'miniName': 'ALGO',
    'unit': 'ALGO',
    'decimals': 6,
    'isContract': false,
    'service': '',
    'contract': '',
    'contract_test': '',
    'path': {'legacy': "m/44'/283'/0'/0'/0'"},
  }
  ..addrType = 'legacy'
  ..address = _ownerAddress
  ..balance = BigInt.from(5_000_000);

Future<void> _mountOffline(WidgetTester tester, CoinModel coin) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await HttpOverrides.runZoned(
    () async {
      await tester.pumpWidget(
        wrapForTest(
          WalletChainSendAlgo(coin),
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

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_trustdartChannel, (call) async {
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
    'ALGO amount field rejects invalid values and clears on correction',
    (tester) async {
      await _mountOffline(tester, _algoCoin());
      final amountField = find.byType(TextField).at(1);

      await tester.enterText(amountField, 'not-a-number');
      await tester.pump();
      expect(find.text(S.current.g_key_134), findsOneWidget);

      await tester.enterText(amountField, '0');
      await tester.pump();
      expect(find.text(S.current.g_key_46(0)), findsOneWidget);

      await tester.enterText(amountField, '1.25');
      await tester.pump();
      expect(find.text(S.current.g_key_134), findsNothing);
      expect(find.text(S.current.g_key_46(0)), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 8));
    },
  );

  testWidgets('displays the minimum balance returned by the ALGO service', (
    tester,
  ) async {
    final coin = _algoCoin()
      ..other = AlgoModel.fromMinBalance(BigInt.from(100_000));
    await _mountOffline(tester, coin);

    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets(
    'sending to the same ALGO address stops before transaction APIs',
    (tester) async {
      var addressValidationCalls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_trustdartChannel, (call) async {
            if (call.method == 'validateAddress') {
              addressValidationCalls++;
              return true;
            }
            return null;
          });
      await _mountOffline(tester, _algoCoin());

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), _ownerAddress);
      await tester.enterText(fields.at(1), '1');
      await tester.tap(find.widgetWithText(FilledButton, S.current.g_key_48));
      await tester.pumpAndSettle();

      expect(addressValidationCalls, 1);
      expect(find.text(S.current.g_key_t_50), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 8));
    },
  );
}
