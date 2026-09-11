import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/data/transaction_history_csv.dart';
import 'package:n42_wallet/features/wallet/data/transaction_history_query.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';

void main() {
  const scope = TransactionHistoryScope(
    userId: 'alice',
    address: 'bc1alice',
    coinType: 'BTC',
    blockchainType: 'Bitcoin',
    isTest: true,
  );

  test('BTC export uses legacy recipient when outputs are absent', () {
    final tx = BtcTransactionRecodeModel()
      ..txTime = '1700000000'
      ..state = 0
      ..price = 1
      ..coin = {'decimals': 8}
      ..to1 = 'legacy-recipient'
      ..inputModels = [
        InputModel()..address = ['BC1ALICE'],
      ];
    expect(historyIsOutgoing(tx, scope), isTrue);
    final csv = TransactionHistoryCsv.row(1, tx, scope);
    expect(csv, contains('"Send","Pending","0.00000001","BTC"'));
    expect(csv, contains('"BC1ALICE","legacy-recipient"'));
    expect(csv, endsWith('"Testnet","BTC"\r\n'));
  });

  test('unknown status and incoming transfer remain identifiable', () {
    final tx = TransationRecordModel()
      ..txTime = '1700000000000'
      ..state = 99
      ..price = BigInt.one
      ..from1 = 'different-sender'
      ..coin = {'unit': 'TOKEN', 'decimals': 0};
    expect(
      TransactionHistoryCsv.row(7, tx, scope),
      contains('"Receive","Unknown","1","TOKEN"'),
    );
    expect(() => historyIsOutgoing(Object(), scope), throwsArgumentError);
    expect(
      () => TransactionHistoryCsv.row(1, Object(), scope),
      throwsArgumentError,
    );
  });

  test('all formula prefixes are escaped without damaging ordinary cells', () {
    for (final value in [
      '=1',
      '+1',
      '-1',
      '@SUM(A1)',
      '  =1',
      '\r1',
      '\n1',
      '\t1',
    ]) {
      expect(historyCsvCell(value), startsWith('"\''));
    }
    expect(historyCsvCell('0xAbC'), '"0xAbC"');
    expect(historyCsvCell(''), '""');
    expect(historyCsvCell('a,"b"'), '"a,""b"""');
  });

  test(
    'clearing one filter preserves the others; reset removes all bounds',
    () {
      final filter = TransactionHistoryFilter(
        direction: 'out',
        status: 0,
        dateFrom: DateTime(2026, 9, 9, 13),
        dateTo: DateTime(2026, 9, 10, 23),
      );
      final changed = filter.copyWith(status: null);
      expect(changed.activeCount, 3);
      expect(changed.direction, 'out');
      expect(changed.fromMs, DateTime(2026, 9, 9).millisecondsSinceEpoch);
      expect(changed.untilMs, DateTime(2026, 9, 11).millisecondsSinceEpoch);
      final cleared = changed.clear();
      expect(cleared.isActive, isFalse);
      expect(cleared.fromMs, isNull);
      expect(cleared.untilMs, isNull);
    },
  );
}
