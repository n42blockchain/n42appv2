import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_memo.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_record_iterms_provider.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _Wallet extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel model) async => false;
}

class _Records extends TransactionRecordItemProvider {
  final List<String> hashes = [];
  bool throwOnAdd = false;
  @override
  void addUndoneTr(dynamic record, int type) {
    hashes.add(record.txHash as String);
    if (throwOnAdd) throw StateError('UI projection unavailable');
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final scenario in [
    'unknown',
    'success',
    'in flight duplicate',
    'foreign hash',
    'zero save ID',
    'storage failure',
    'projection failure',
    'dispose before ack',
  ]) {
    testWidgets('memo submission $scenario preserves broadcast boundary', (
      tester,
    ) async {
      final coin = CoinModel()
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
      final record = TransationRecordModel()
        ..from1 = 'GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWHF'
        ..to1 = 'GBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'
        ..price = BigInt.from(12500000)
        ..coin = coin.coin
        ..coinMiniName = 'XLM';
      final projection = _Records()
        ..throwOnAdd = scenario == 'projection failure';
      var saves = 0;
      var broadcasts = 0;
      var submissions = 0;
      final ack = Completer<void>();
      final prepared = Completer<void>();
      await tester.pumpWidget(
        wrapForTest(
          WalletChainSendMemo(
            coin,
            persistTransaction: (tr) async {
              saves++;
              expect(tr.txHash, 'ab' * 32);
              expect(broadcasts, 0);
              if (scenario == 'storage failure') {
                throw StateError('Disk failed');
              }
              return scenario == 'zero save ID' ? 0 : 42;
            },
            transactionSender: (params) async {
              submissions++;
              expect(params.decimalAmountOverride, '1.25');
              try {
                await params.beforeBroadcast!('ab' * 32);
              } catch (_) {
                return const SendResult.fail('Storage failed');
              }
              broadcasts++;
              prepared.complete();
              if ([
                'dispose before ack',
                'in flight duplicate',
              ].contains(scenario)) {
                await ack.future;
              }
              if (scenario == 'success') return SendResult.ok('ab' * 32);
              if (scenario == 'foreign hash') return SendResult.ok('cd' * 32);
              return SendResult.uncertain('ab' * 32, 'Response lost');
            },
          ),
          overrides: [
            wapBridgeProvider.overrideWith((ref) => _Wallet()),
            tripBridgeProvider.overrideWith((ref) => projection),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(WalletChainSendMemo));
      final Future<void> pending = state.signTx(record) as Future<void>;
      if (scenario == 'dispose before ack') {
        await tester.pump();
        await prepared.future;
        await tester.pumpWidget(const SizedBox.shrink());
        ack.complete();
      }
      if (scenario == 'in flight duplicate') {
        await tester.pump();
        await prepared.future;
        await state.signTx(record);
        expect(submissions, 1);
        ack.complete();
      }
      await pending;
      await tester.pumpAndSettle();
      final failed = ['zero save ID', 'storage failure'].contains(scenario);
      expect(saves, 1);
      expect(broadcasts, failed ? 0 : 1);
      expect(record.trId, failed ? 0 : 42);
      expect(record.txHash, 'ab' * 32);
      if (!failed) {
        await state.signTx(record);
        expect(submissions, 1);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
