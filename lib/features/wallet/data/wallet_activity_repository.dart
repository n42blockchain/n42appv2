import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';

/// A local transaction with the original network and asset context.
class WalletActivity {
  final Object record;
  final CoinModel coin;
  final bool isBtc;

  WalletActivity.fromRow(Map<String, Object?> row, this.isBtc)
    : record = isBtc
          ? BtcTransactionRecodeModel.fromMap(row)
          : TransationRecordModel.fromMap(row),
      coin = CoinModel() {
    final transaction = record;
    if (transaction is BtcTransactionRecodeModel) {
      coin.coin = transaction.coin;
      coin.address = transaction.address;
      coin.isTest = transaction.isTest == 1;
    } else if (transaction is TransationRecordModel) {
      coin.coin = transaction.coin;
      coin.address = transaction.address;
      coin.isTest = transaction.isTest == 1;
    }
  }
}

/// Merges both local ledgers before pagination. Filters apply to the complete
/// ledger, not just to the currently loaded page. Never queries without a user.
class WalletActivityRepository {
  WalletActivityRepository({AppDatabase? database})
    : _database = database ?? AppDatabase();

  final AppDatabase _database;

  Future<List<WalletActivity>> load({
    required String userId,
    int offset = 0,
    int limit = 50,
    int? status,
  }) async {
    if (userId.isEmpty) return [];
    if (offset < 0 || limit < 1 || limit > 100) {
      throw ArgumentError('Invalid activity page');
    }
    final db = await _database.database;
    final where = 'userUuid = ?${status == null ? '' : ' AND state = ?'}';
    final args = <Object?>[userId, ?status];
    // Old rows store seconds; newer rows store milliseconds, both as TEXT.
    const timestamp =
        'CASE WHEN CAST(txTime AS INTEGER) < 1000000000000 '
        'THEN CAST(txTime AS INTEGER) * 1000 ELSE CAST(txTime AS INTEGER) END';
    return db.transaction((txn) async {
      final ids = await txn.rawQuery(
        '''
        SELECT trId, 0 AS btc, $timestamp AS timestamp
        FROM TransationRecord WHERE $where
        UNION ALL
        SELECT trId, 1 AS btc, $timestamp AS timestamp
        FROM BtcTransactionRecord WHERE $where
        ORDER BY timestamp DESC, btc ASC, trId DESC LIMIT ? OFFSET ?
      ''',
        [...args, ...args, limit, offset],
      );
      final records = <String, WalletActivity>{};
      for (final btc in [0, 1]) {
        final selected = ids.where((row) => row['btc'] == btc).toList();
        if (selected.isEmpty) continue;
        final rows = await txn.query(
          btc == 1 ? 'BtcTransactionRecord' : 'TransationRecord',
          where:
              'userUuid = ? AND trId IN (${List.filled(selected.length, '?').join(',')})',
          whereArgs: [userId, ...selected.map((row) => row['trId'])],
        );
        for (final row in rows) {
          records['$btc:${row['trId']}'] = WalletActivity.fromRow(
            row,
            btc == 1,
          );
        }
      }
      return [for (final id in ids) records['${id['btc']}:${id['trId']}']!];
    });
  }
}
