import 'dart:async';

import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_memo.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/services/cardano_quote_service.dart';
import 'package:n42_wallet/features/wallet/utils/cardano/transfer_plan.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _Wallet extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coin) async => false;
}

class _Quotes extends CardanoQuoteService {
  int calls = 0;
  Completer<void>? gate;
  bool fail = false;
  @override
  Future<CardanoTransferPlan> quote({
    required String sender,
    required String recipient,
    required BigInt amount,
    required bool isTest,
    required bool maximum,
    required bool Function() isCurrent,
  }) async {
    calls++;
    await gate?.future;
    if (fail) throw StateError('offline');
    return CardanoTransferPlan.parse(
      {
        'amount': maximum ? '9800000' : amount.toString(),
        'fee': '200000',
        'change': maximum ? '0' : (BigInt.from(9800000) - amount).toString(),
        'available': '10000000',
      },
      requested: maximum ? BigInt.from(10000000) : amount,
      available: BigInt.from(10000000),
      sendMax: maximum,
    );
  }
}

void main() {
  Future<dynamic> mount(
    WidgetTester tester,
    _Quotes quotes, {
    Future<SendResult> Function(SendParams)? sender,
  }) async {
    final coin = CoinModel()
      ..coin = {
        'coinType': 'ADA',
        'blockchainType': 'Cardano',
        'unit': 'ADA',
        'miniName': 'ADA',
        'decimals': 6,
        'isContract': false,
        'contract': '',
      }
      ..address = 'addr_synthetic_sender_for_quote_tests'
      ..balance = BigInt.from(10000000);
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendMemo(
          coin,
          cardanoQuotes: quotes,
          transactionSender: sender,
        ),
        overrides: [wapBridgeProvider.overrideWith((ref) => _Wallet())],
      ),
    );
    await tester.pumpAndSettle();
    return tester.state(find.byType(WalletChainSendMemo));
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('trustdart'), null);
  });
  testWidgets('Max uses native quote amount and fee', (tester) async {
    final quotes = _Quotes();
    final state = await mount(tester, quotes);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('trustdart'),
          (_) async => true,
        );
    state.toCtrl.text = 'addr_recipient';
    await state.maxTag();
    await tester.pump();
    expect(state.valueCtrl.text, '9.8');
    expect(state.transferValue, BigInt.from(9800000));
    expect(state.totalGasPrice, BigInt.from(200000));
    expect(quotes.calls, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('ordinary quote reaches confirmation with exact amount and fee', (
    tester,
  ) async {
    final quotes = _Quotes();
    final state = await mount(tester, quotes);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('trustdart'),
          (_) async => true,
        );
    state.toCtrl.text = 'addr_synthetic_recipient_for_quote_tests';
    state.valueCtrl.text = '1.25';
    final Future<void> pending = state.sendTransaction();
    await tester.pumpAndSettle();
    final page = tester.widget<WalletBaseSend>(find.byType(WalletBaseSend));
    expect(page.transationRecordModel!.price, BigInt.from(1250000));
    expect(page.transationRecordModel!.gasPrice, BigInt.from(200000));
    expect(
      page.transationRecordModel!.to1,
      'addr_synthetic_recipient_for_quote_tests',
    );
    Navigator.of(tester.element(find.byType(WalletBaseSend))).pop(false);
    await tester.pumpAndSettle();
    await pending;
    expect(tester.takeException(), isNull);
  });
  testWidgets('confirmation result cannot sign after form changes', (
    tester,
  ) async {
    var submissions = 0;
    final state = await mount(
      tester,
      _Quotes(),
      sender: (_) async {
        submissions++;
        return const SendResult.fail('fixture');
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('trustdart'),
          (_) async => true,
        );
    state.toCtrl.text = 'addr_synthetic_recipient_for_quote_tests';
    state.valueCtrl.text = '1.25';
    final Future<void> pending = state.sendTransaction();
    await tester.pumpAndSettle();
    state.valueCtrl.text = '2';
    Navigator.of(tester.element(find.byType(WalletBaseSend))).pop(true);
    await tester.pumpAndSettle();
    await pending;
    expect(submissions, 0);
    expect(state.errorMessage, isNotEmpty);
  });
  testWidgets('ADA signing receives exact reviewed fee and fixed amount', (
    tester,
  ) async {
    SendParams? captured;
    final state = await mount(
      tester,
      _Quotes(),
      sender: (params) async {
        captured = params;
        return const SendResult.fail('fixture: no broadcast');
      },
    );
    final coin = tester
        .widget<WalletChainSendMemo>(find.byType(WalletChainSendMemo))
        .coinModel;
    final record = TransationRecordModel()
      ..coin = coin.coin
      ..address = coin.address.toString()
      ..from1 = coin.address.toString()
      ..to1 = 'addr_synthetic_recipient_for_quote_tests'
      ..coinMiniName = 'ADA'
      ..price = BigInt.from(1250000)
      ..gasPrice = BigInt.from(200000);
    await state.signTx(record);
    expect(captured, isNotNull);
    expect(captured!.expectedFeeBaseUnits, BigInt.from(200000));
    expect(captured!.decimalAmountOverride, '1.25');
    expect(captured!.sendMax, false);
  });
  for (final action in ['Max', 'Send']) {
    testWidgets('$action rejects form changed during address validation', (
      tester,
    ) async {
      final quotes = _Quotes();
      final state = await mount(tester, quotes);
      final gate = Completer<bool>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('trustdart'),
            (_) => gate.future,
          );
      state.toCtrl.text = 'addr_original';
      state.valueCtrl.text = '1';
      final Future<void> pending = action == 'Max'
          ? state.maxTag()
          : state.sendTransaction();
      await tester.pump();
      state.toCtrl.text = 'addr_changed';
      gate.complete(true);
      await tester.pump();
      await pending;
      expect(quotes.calls, 0);
      expect(state.errorMessage, isNotEmpty);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('late Max quote cannot overwrite edited amount', (tester) async {
    final quotes = _Quotes()..gate = Completer<void>();
    final state = await mount(tester, quotes);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('trustdart'),
          (_) async => true,
        );
    state.toCtrl.text = 'addr_recipient';
    final Future<void> pending = state.maxTag();
    await tester.pump();
    state.valueCtrl.text = '2';
    quotes.gate!.complete();
    await tester.pump();
    await pending;
    expect(state.valueCtrl.text, '2');
    expect(tester.takeException(), isNull);
  });
  testWidgets('failed Max quote preserves amount', (tester) async {
    final quotes = _Quotes()..fail = true;
    final state = await mount(tester, quotes);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('trustdart'),
          (_) async => true,
        );
    state.toCtrl.text = 'addr_recipient';
    state.valueCtrl.text = '2';
    await state.maxTag();
    expect(state.valueCtrl.text, '2');
    expect(state.errorMessage, isNotEmpty);
  });
}
