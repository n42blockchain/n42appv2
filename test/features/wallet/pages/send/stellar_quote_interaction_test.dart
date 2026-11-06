import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_memo.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';
import '../../../../helpers/stellar_quote_api.dart';

class _OfflineWallet extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coin) async => false;
}

void main() {
  CoinModel coin() => CoinModel()
    ..coin = {
      'coinType': 'XLM',
      'blockchainType': 'Stellar',
      'unit': 'XLM',
      'miniName': 'XLM',
      'decimals': 7,
      'isContract': false,
      'contract': '',
    }
    ..address = 'GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWHF'
    ..balance = BigInt.from(100000000);
  Future<dynamic> mount(
    WidgetTester tester,
    FakeStellarQuoteApi api, {
    CoinModel? model,
  }) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendMemo(model ?? coin(), stellarApi: api),
        overrides: [wapBridgeProvider.overrideWith((ref) => _OfflineWallet())],
      ),
    );
    await tester.pumpAndSettle();
    return tester.state(find.byType(WalletChainSendMemo));
  }

  testWidgets('Max and displayed fee use reserve, liabilities and ledger fee', (
    tester,
  ) async {
    final api = FakeStellarQuoteApi()..fee = 300;
    final state = await mount(tester, api);
    state.maxTag();
    await tester.pump();
    expect(state.valueCtrl.text, '6.99997');
    expect(state.transferValue, BigInt.from(69999700));
    expect(state.totalGasPrice, BigInt.from(300));
    expect(find.text('0.00003 XLM'), findsOneWidget);
    state.amountCheck(value: '7');
    expect(state.amountError, isNotEmpty);
    state.amountCheck(value: '6.99997');
    expect(state.amountError, isEmpty);
    expect(api.calls.single, (
      'GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWHF',
      false,
    ));
    expect(tester.takeException(), isNull);
  });
  for (final problem in ['network', 'malformed', 'wrong account']) {
    testWidgets('invalid quote $problem cannot supply Max and can refresh', (
      tester,
    ) async {
      final api = FakeStellarQuoteApi()
        ..failed = problem == 'network'
        ..malformed = problem == 'malformed'
        ..wrongAccount = problem == 'wrong account' ? 'GOTHER' : null;
      final state = await mount(tester, api);
      state.maxTag();
      expect(state.amountError, isNotEmpty);
      state.amountCheck(value: '1');
      expect(state.amountError, isNotEmpty);
      expect(state.transferValue, BigInt.zero);
      api.failed = false;
      api.malformed = false;
      api.wrongAccount = null;
      await tester.ensureVisible(
        find.byKey(const ValueKey('stellar-refresh-quote')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('stellar-refresh-quote')));
      await tester.pumpAndSettle();
      state.maxTag();
      expect(state.valueCtrl.text, '6.99999');
      expect(state.amountError, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('cached quote cannot be used after a network switch', (
    tester,
  ) async {
    final model = coin();
    final state = await mount(tester, FakeStellarQuoteApi(), model: model);
    model.isTest = true;
    state.maxTag();
    await tester.pump();
    expect(state.amountError, isNotEmpty);
    expect(state.transferValue, BigInt.zero);
    expect(find.text('—'), findsOneWidget);
  });
  testWidgets('reserve and liabilities can leave no spendable balance', (
    tester,
  ) async {
    final state = await mount(tester, FakeStellarQuoteApi()..balance = '1');
    state.maxTag();
    expect(state.amountError, isNotEmpty);
    expect(state.transferValue, BigInt.zero);
    state.amountCheck(value: '0.1');
    expect(state.amountError, isNotEmpty);
  });
  testWidgets(
    'refresh clears the old quote and ignores changed network results',
    (tester) async {
      final api = FakeStellarQuoteApi();
      final model = coin();
      final state = await mount(tester, api, model: model);
      final gate = Completer<void>();
      api.gate = gate;
      final Future<void> pending = state.loadBalance();
      await tester.pump();
      state.maxTag();
      expect(state.amountError, isNotEmpty);
      model.isTest = true;
      gate.complete();
      await pending;
      state.amountCheck(value: '1');
      expect(state.amountError, isNotEmpty);
      api.gate = null;
      await state.loadBalance();
      state.maxTag();
      expect(state.amountError, isEmpty);
      expect(api.calls.last, (
        'GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWHF',
        true,
      ));
      expect(tester.takeException(), isNull);
    },
  );
}
