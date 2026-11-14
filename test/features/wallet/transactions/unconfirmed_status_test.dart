import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_detail_page.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_transactions_item.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

TransationRecordModel _sui({required int state, required Duration age}) =>
    TransationRecordModel()
      ..from1 = '0x${'11' * 32}'
      ..to1 = '0x${'22' * 32}'
      ..address = '0x${'11' * 32}'
      ..state = state
      ..price = BigInt.from(1000000000)
      ..txHash = 'sui-digest'
      ..txTime = (DateTime.now().subtract(age).millisecondsSinceEpoch ~/ 1000)
          .toString()
      ..coin = {
        'coinType': 'SUI',
        'blockchainType': 'Sui',
        'unit': 'SUI',
        'decimals': 9,
      };

void main() {
  group('unknown threshold', () {
    final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);
    TransationRecordModel at(Duration age, {int state = 0, bool ms = false}) {
      final sent = now.subtract(age).millisecondsSinceEpoch;
      return TransationRecordModel()
        ..state = state
        ..txTime = (ms ? sent : sent ~/ 1000).toString();
    }

    test('only a pending record older than the threshold', () {
      const limit = TransactionStateResolver.unknownAfter;
      bool check(TransationRecordModel r) =>
          TransactionStateResolver.isUnconfirmed(r, now: now);
      expect(check(at(limit - const Duration(minutes: 1))), isFalse);
      expect(check(at(limit + const Duration(minutes: 1))), isTrue);
      expect(check(at(limit + const Duration(minutes: 1), ms: true)), isTrue);
      expect(check(at(const Duration(days: 3), state: 1)), isFalse);
      expect(check(at(const Duration(days: 3), state: 2)), isFalse);
      expect(check(TransationRecordModel()..txTime = 'garbage'), isFalse);
      expect(check(TransationRecordModel()..txTime = '0'), isFalse);
    });

    test('labelling never changes the stored state', () {
      final record = at(const Duration(days: 1));
      TransactionStateResolver.isUnconfirmed(record, now: now);
      expect(record.state, 0);
    });
  });

  Future<void> show(
    WidgetTester tester,
    TransationRecordModel tx, {
    bool readOnly = false,
  }) async {
    final coin = CoinModel()
      ..coin = tx.coin
      ..address = tx.address;
    await tester.pumpWidget(
      wrapForTest(
        WalletChainInfoTransactionsItem(
          type: 1,
          transactionModel: tx,
          coinModel: coin,
          readOnly: readOnly,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final readOnly in [false, true]) {
    testWidgets('long pending record reads "not confirmed" in list and detail '
        '(readOnly=$readOnly)', (tester) async {
      await show(
        tester,
        _sui(state: 0, age: const Duration(hours: 2)),
        readOnly: readOnly,
      );
      expect(find.text(S.current.g_tx_status_unconfirmed), findsOneWidget);
      expect(find.text(S.current.g_key_t_2), findsNothing);

      await tester.tap(find.byType(WalletChainInfoTransactionsItem));
      await tester.pumpAndSettle();
      final detail = tester.widget<TransactionDetailPage>(
        find.byType(TransactionDetailPage),
      );
      expect(detail.status, S.current.g_tx_status_unconfirmed);
      expect(detail.statusHint, S.current.g_tx_status_unconfirmed_hint);
      expect(find.text(S.current.g_tx_status_unconfirmed), findsOneWidget);
      expect(find.text(S.current.g_tx_status_unconfirmed_hint), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('recent pending record still reads "pending"', (tester) async {
    await show(tester, _sui(state: 0, age: const Duration(minutes: 1)));
    expect(find.text(S.current.g_key_t_2), findsOneWidget);
    expect(find.text(S.current.g_tx_status_unconfirmed), findsNothing);
    await tester.tap(find.byType(WalletChainInfoTransactionsItem));
    await tester.pumpAndSettle();
    final detail = tester.widget<TransactionDetailPage>(
      find.byType(TransactionDetailPage),
    );
    expect(detail.status, S.current.g_key_t_2);
    expect(detail.statusHint, isNull);
    expect(tester.takeException(), isNull);
  });

  for (final (state, label) in [(1, 'g_key_t_1'), (2, 'g_key_t_3')]) {
    testWidgets('old settled record keeps its result label ($label)', (
      tester,
    ) async {
      await show(tester, _sui(state: state, age: const Duration(days: 2)));
      expect(
        find.text(state == 1 ? S.current.g_key_t_1 : S.current.g_key_t_3),
        findsOneWidget,
      );
      expect(find.text(S.current.g_tx_status_unconfirmed), findsNothing);
    });
  }

  test('every shipped locale provides the status texts', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final en = await S.load(const Locale('en'));
    expect(en.g_tx_status_unconfirmed, 'Not confirmed');
    for (final locale in S.delegate.supportedLocales) {
      final s = await S.load(locale);
      expect(s.g_tx_status_unconfirmed, isNotEmpty, reason: '$locale');
      expect(s.g_tx_status_unconfirmed_hint, isNotEmpty, reason: '$locale');
    }
    final zh = await S.load(const Locale('zh', 'TW'));
    expect(zh.g_tx_status_unconfirmed, '未確認');
    await S.load(const Locale('en'));
  });
}
