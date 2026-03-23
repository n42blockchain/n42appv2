import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transaction/btc_sync_utils.dart';
import 'package:n42_wallet/features/wallet/models/transaction/btc_tran_detail.dart';

void main() {
  group('parseBtcTimestamp', () {
    test('parses confirmed ISO8601 time into epoch seconds', () {
      expect(parseBtcTimestamp('2024-01-02T03:04:05Z'), '1704164645');
    });

    test('falls back when confirmed time is absent', () {
      expect(
        parseBtcTimestamp(
          null,
          fallbackTime: DateTime.utc(2024, 1, 2, 3, 4, 5),
        ),
        '1704164645',
      );
    });
  });

  group('syncBtcRecordFromDetail', () {
    test(
      'updates existing record status, fee, detail models, and outgoing value',
      () {
        final record = BtcTransactionRecodeModel()
          ..address = 'bc1-wallet'
          ..confirmations = 0
          ..state = 0
          ..price = 999999
          ..gasPrice = 1
          ..txTime = '0';

        final detail = BtcTranDetail(
          'blockhash',
          1,
          '0xbtc',
          const ['bc1-wallet', 'bc1-dest'],
          50000,
          1200,
          '2024-01-02T03:04:05Z',
          7,
          [
            Input('prev', 0, 'script-in', 70000, const ['bc1-wallet']),
          ],
          [
            Output(18000, 'change', const ['bc1-wallet']),
            Output(50000, 'payment', const ['bc1-dest']),
          ],
        );

        expect(syncBtcRecordFromDetail(record, detail), isTrue);
        expect(record.confirmations, 7);
        expect(record.state, 1);
        expect(record.gasPrice, 1200);
        expect(record.txTime, '1704164645');
        expect(record.price, 50000);
        expect(record.inputModels, isNotNull);
        expect(record.outputModels, isNotNull);
        expect(record.outputsAddressList, contains('bc1-dest'));
      },
    );

    test('keeps incoming value as outputs to the wallet address', () {
      final detail = BtcTranDetail(
        'blockhash',
        1,
        '0xbtc',
        const ['bc1-source', 'bc1-wallet'],
        42000,
        300,
        null,
        0,
        [
          Input('prev', 0, 'script-in', 45000, const ['bc1-source']),
        ],
        [
          Output(42000, 'receive', const ['bc1-wallet']),
          Output(2700, 'change', const ['bc1-source']),
        ],
      );

      expect(computeBtcDisplayPrice('bc1-wallet', detail), 42000);
    });

    test('returns false when detail would not change the record', () {
      final record = BtcTransactionRecodeModel()
        ..address = 'bc1-wallet'
        ..confirmations = 6
        ..state = 1
        ..price = 50000
        ..gasPrice = 1200
        ..txTime = '1704164645'
        ..inputModels = [
          InputModel()
            ..txid = 'prev'
            ..vout = 70000
            ..script = 'script-in'
            ..address = const ['bc1-wallet'],
        ]
        ..outputModels = [
          OutputModel()
            ..price = 18000
            ..script = 'change'
            ..address = const ['bc1-wallet'],
          OutputModel()
            ..price = 50000
            ..script = 'payment'
            ..address = const ['bc1-dest'],
        ];

      final detail = BtcTranDetail(
        'blockhash',
        1,
        '0xbtc',
        const ['bc1-wallet', 'bc1-dest'],
        50000,
        1200,
        '2024-01-02T03:04:05Z',
        6,
        [
          Input('prev', 0, 'script-in', 70000, const ['bc1-wallet']),
        ],
        [
          Output(18000, 'change', const ['bc1-wallet']),
          Output(50000, 'payment', const ['bc1-dest']),
        ],
      );

      expect(syncBtcRecordFromDetail(record, detail), isFalse);
    });
  });
}
