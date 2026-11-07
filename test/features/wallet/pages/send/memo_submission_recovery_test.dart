import 'package:fast_base58/fast_base58.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';

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
import '../../../../helpers/stellar_quote_api.dart';

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
  for (final chain in ['XLM', 'EGLD', 'NEAR']) {
    final decimals = chain == 'XLM'
        ? 7
        : chain == 'NEAR'
        ? 24
        : 18;
    final hash = chain == 'NEAR'
        ? Base58Encode(List.filled(32, 0xab))
        : 'ab' * 32;
    final otherHash = chain == 'NEAR'
        ? Base58Encode(List.filled(32, 0xcd))
        : 'cd' * 32;
    for (final scenario in [
      'not submitted',
      'dispatch rejected',
      'dispatch error',
      'dispatch key changed',
      'release refused',
      'release error',
      'abort foreign hash',
      'dispose before abort',
      'unknown',
      'success',
      'in flight duplicate',
      'foreign hash',
      'zero save ID',
      'storage failure',
      'pending reservation',
      'projection failure',
      'dispose before ack',
    ]) {
      testWidgets('$chain memo submission $scenario preserves broadcast boundary', (
        tester,
      ) async {
        final coin = CoinModel()
          ..coin = {
            'coinType': chain,
            'blockchainType': chain == 'XLM'
                ? 'Stellar'
                : chain == 'NEAR'
                ? 'Near'
                : 'MultiversX',
            'unit': chain,
            'miniName': chain,
            'decimals': decimals,
            'isContract': false,
            'contract': '',
          }
          ..address = 'GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWHF'
          ..balance = BigInt.from(10).pow(decimals + 1);
        final record = TransationRecordModel()
          ..from1 = 'GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWHF'
          ..to1 = 'GBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'
          ..price = BigInt.from(125) * BigInt.from(10).pow(decimals - 2)
          ..coin = coin.coin
          ..coinMiniName = chain
          ..gasPrice = BigInt.from(100);
        final projection = _Records()
          ..throwOnAdd = scenario == 'projection failure';
        final noBroadcast = [
          'not submitted',
          'release refused',
          'release error',
          'abort foreign hash',
          'dispose before abort',
        ].contains(scenario);
        final dispatchAbort = [
          'dispatch rejected',
          'dispatch error',
          'dispatch key changed',
        ].contains(scenario);
        final released = [
          'dispatch rejected',
          'dispatch error',
          'dispatch key changed',
          'not submitted',
          'dispose before abort',
        ].contains(scenario);
        final dispatchChecks = <(int, String, int)>[];
        var releases = 0;
        var saves = 0;
        var broadcasts = 0;
        var submissions = 0;
        final ack = Completer<void>();
        final prepared = Completer<void>();
        await tester.pumpWidget(
          wrapForTest(
            WalletChainSendMemo(
              coin,
              stellarApi: FakeStellarQuoteApi(),
              persistTransaction: (tr) async {
                saves++;
                expect(tr.txHash, hash);
                expect(broadcasts, 0);
                if (scenario == 'pending reservation') {
                  throw const PendingMemoTransactionException();
                }
                if (scenario == 'storage failure') {
                  throw StateError('Disk failed');
                }
                return scenario == 'zero save ID' ? 0 : 42;
              },
              markTransactionDispatch: (tr) async {
                dispatchChecks.add((tr.trId, tr.txHash, broadcasts));
                if (scenario == 'dispatch error') {
                  throw StateError('Dispatch store unavailable');
                }
                if (scenario == 'dispatch key changed') {
                  coin.privateKey = 'public-test-placeholder';
                }
                return scenario != 'dispatch rejected';
              },
              releaseUnsubmittedTransaction: (tr) async {
                releases++;
                expect(tr.trId, 42);
                expect(tr.txHash, hash);
                if (scenario == 'release error') {
                  throw StateError('Disk unavailable');
                }
                return scenario != 'release refused';
              },
              transactionSender: (params) async {
                submissions++;
                expect(params.decimalAmountOverride, '1.25');
                expect(params.expectedFeeBaseUnits, BigInt.from(100));
                try {
                  await params.beforeBroadcast!(hash);
                } catch (_) {
                  return const SendResult.fail('Storage failed');
                }
                if (noBroadcast) {
                  if (!prepared.isCompleted) prepared.complete();
                  if (scenario == 'dispose before abort') await ack.future;
                  return SendResult.notSubmitted(
                    scenario == 'abort foreign hash' ? otherHash : hash,
                    'Cancelled before broadcast',
                  );
                }
                try {
                  await params.onBroadcastStarting!(hash);
                } catch (_) {
                  return SendResult.notSubmitted(hash, 'Dispatch not recorded');
                }
                broadcasts++;
                prepared.complete();
                if ([
                  'dispose before ack',
                  'in flight duplicate',
                ].contains(scenario)) {
                  await ack.future;
                }
                if (scenario == 'success') return SendResult.ok(hash);
                if (scenario == 'foreign hash') return SendResult.ok(otherHash);
                return SendResult.uncertain(hash, 'Response lost');
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
        if (scenario == 'dispose before ack' ||
            scenario == 'dispose before abort') {
          for (var i = 0; i < 10 && !prepared.isCompleted; i++) {
            await tester.pump();
          }
          expect(
            prepared.isCompleted,
            isTrue,
            reason:
                'submissions=$submissions saves=$saves broadcasts=$broadcasts error=${state.errorMessage}',
          );
          await tester.pumpWidget(const SizedBox.shrink());
          ack.complete();
        }
        if (scenario == 'in flight duplicate') {
          for (var i = 0; i < 10 && !prepared.isCompleted; i++) {
            await tester.pump();
          }
          expect(
            prepared.isCompleted,
            isTrue,
            reason:
                'submissions=$submissions saves=$saves broadcasts=$broadcasts error=${state.errorMessage}',
          );
          await state.signTx(record);
          expect(submissions, 1);
          ack.complete();
        }
        await pending;
        await tester.pumpAndSettle();
        final failed = [
          'zero save ID',
          'storage failure',
          'pending reservation',
        ].contains(scenario);
        for (final check in dispatchChecks) {
          expect(check, (42, hash, 0));
        }
        expect(saves, 1);
        expect(broadcasts, failed || noBroadcast || dispatchAbort ? 0 : 1);
        expect(
          releases,
          (noBroadcast || dispatchAbort) && scenario != 'abort foreign hash'
              ? 1
              : 0,
        );
        expect(record.trId, failed || released ? 0 : 42);
        expect(record.txHash, released ? '' : hash);
        if (!failed && !released) {
          await state.signTx(record);
          expect(submissions, 1);
        }
        if (scenario == 'not submitted') {
          await state.signTx(record);
          expect(submissions, 2);
          expect(broadcasts, 0);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
