import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_memo.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/services/egld_quote_service.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _Wallet extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coin) async => false;
}

class _Quotes extends EgldQuoteService {
  Completer<void>? gate;
  bool failed = false;
  String? memo;
  @override
  Future<EgldFeeQuote> quote({
    required bool isTest,
    required int decimals,
    required String memo,
  }) async {
    this.memo = memo;
    await gate?.future;
    if (failed) throw StateError('offline');
    return EgldFeeQuote(BigInt.from(65000), 1000000000, 1);
  }
}

void main() {
  CoinModel coin() => CoinModel()
    ..coin = {
      'coinType': 'EGLD',
      'blockchainType': 'MultiversX',
      'unit': 'EGLD',
      'miniName': 'EGLD',
      'decimals': 18,
      'isContract': false,
      'contract': '',
    }
    ..address = 'erd1sender'
    ..balance = BigInt.parse('10000000000000000000');
  Future<dynamic> mount(
    WidgetTester tester,
    _Quotes quotes, {
    CoinModel? model,
    Future<SendResult> Function(SendParams)? send,
  }) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendMemo(
          model ?? coin(),
          egldQuotes: quotes,
          transactionSender: send,
        ),
        overrides: [wapBridgeProvider.overrideWith((ref) => _Wallet())],
      ),
    );
    await tester.pumpAndSettle();
    return tester.state(find.byType(WalletChainSendMemo));
  }

  testWidgets('Max uses reviewed fee and trimmed Unicode memo', (tester) async {
    final quotes = _Quotes();
    final state = await mount(tester, quotes);
    state.memoCtrl.text = '  你好🙂  ';
    await state.maxTag();
    await tester.pump();
    expect(quotes.memo, '你好🙂');
    expect(state.valueCtrl.text, '9.999935');
    expect(state.totalGasPrice, BigInt.from(65000000000000));
    expect(find.text('0.000065 EGLD'), findsOneWidget);
    state.memoCtrl.text = 'edited';
    await tester.pump();
    expect(find.text('—'), findsOneWidget);
  });
  testWidgets('failed balance refresh cannot create a spending quote', (
    tester,
  ) async {
    final model = coin();
    final quotes = _Quotes();
    final state = await mount(tester, quotes, model: model);
    model.loadError = true;
    await state.maxTag();
    await tester.pump();
    expect(state.valueCtrl.text, '0');
    expect(state.errorMessage, isNotEmpty);
    expect(quotes.memo, isNull);
  });
  for (final scenario in ['memo', 'network', 'failure']) {
    testWidgets('late or failed EGLD quote cannot supply Max: $scenario', (
      tester,
    ) async {
      final model = coin();
      final quotes = _Quotes();
      final state = await mount(tester, quotes, model: model);
      quotes.gate = Completer<void>();
      final Future<void> pending = state.maxTag();
      if (scenario == 'memo') state.memoCtrl.text = 'changed';
      if (scenario == 'network') model.isTest = true;
      if (scenario == 'failure') quotes.failed = true;
      quotes.gate!.complete();
      await pending;
      await tester.pump();
      expect(state.valueCtrl.text, '0');
      expect(find.text('—'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final scenario in [
    'confirm',
    'edit during confirmation',
    'edit during quote',
  ]) {
    testWidgets('EGLD confirmation binds fee and form: $scenario', (
      tester,
    ) async {
      const channel = MethodChannel('trustdart');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async => true);
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      SendParams? submitted;
      final quotes = _Quotes();
      final state = await mount(
        tester,
        quotes,
        send: (params) async {
          submitted = params;
          return const SendResult.fail('fixture stops before broadcast');
        },
      );
      state.toCtrl.text = 'erd1recipient';
      state.valueCtrl.text = '1.25';
      state.memoCtrl.text = '  你好🙂  ';
      if (scenario == 'edit during quote') quotes.gate = Completer<void>();
      final Future<void> pending = state.sendTransaction();
      await tester.pump();
      if (scenario == 'edit during quote') {
        state.memoCtrl.text = 'new memo';
        quotes.gate!.complete();
        await pending;
        await tester.pumpAndSettle();
        expect(find.byType(WalletBaseSend), findsNothing);
      } else {
        await tester.pumpAndSettle();
        final confirmation = tester.widget<WalletBaseSend>(
          find.byType(WalletBaseSend),
        );
        expect(
          confirmation.transationRecordModel!.gasPrice,
          BigInt.from(65000000000000),
        );
        expect(confirmation.transationRecordModel!.message, '你好🙂');
        if (scenario == 'edit during confirmation') state.valueCtrl.text = '2';
        Navigator.of(tester.element(find.byType(WalletBaseSend))).pop(true);
        await tester.pumpAndSettle();
        await pending;
      }
      if (scenario == 'confirm') {
        expect(submitted!.expectedFeeBaseUnits, BigInt.from(65000000000000));
        expect(submitted!.amountDecimalString, '1.25');
        expect(submitted!.memo, '你好🙂');
        expect(submitted!.sendMax, false);
      } else {
        expect(submitted, isNull);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
