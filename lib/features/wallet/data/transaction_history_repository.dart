import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:sqflite/sqflite.dart';
import 'transaction_history_csv.dart';
import 'transaction_history_query.dart';

class TransactionHistoryPage {
  final List<Object> records;
  final bool hasMore;
  const TransactionHistoryPage(this.records, {required this.hasMore});
}

class TransactionHistoryRepository {
  TransactionHistoryRepository({AppDatabase? database})
    : _database = database ?? AppDatabase();
  final AppDatabase _database;
  static const _batchSize = 200;
  static const _timestamp =
      'CASE WHEN CAST(txTime AS INTEGER) < 1000000000000 THEN CAST(txTime AS INTEGER) * 1000 ELSE CAST(txTime AS INTEGER) END';

  Future<TransactionHistoryPage> load({
    required TransactionHistoryScope scope,
    TransactionHistoryFilter filter = const TransactionHistoryFilter(),
    int offset = 0,
    int limit = 50,
  }) async {
    if (offset < 0 || limit < 1 || limit > 200) {
      throw ArgumentError('Invalid history page');
    }
    if (!scope.isValid) return const TransactionHistoryPage([], hasMore: false);
    final db = await _database.database;
    return db.transaction((txn) async {
      final selected = <Object>[];
      final startOffset = scope.isBtc && filter.direction != null ? 0 : offset;
      var skipped = startOffset;
      await for (final batch in _batches(
        txn,
        scope,
        filter,
        startOffset: startOffset,
      )) {
        for (final record in batch) {
          if (skipped++ < offset) continue;
          selected.add(record);
          if (selected.length > limit) {
            return TransactionHistoryPage(
              selected.take(limit).toList(),
              hasMore: true,
            );
          }
        }
      }
      return TransactionHistoryPage(selected, hasMore: false);
    });
  }

  /// One SQLite read transaction gives the entire export a consistent snapshot.
  /// Await the writer per batch so large exports need not accumulate in memory.
  Future<int> exportCsv({
    required TransactionHistoryScope scope,
    TransactionHistoryFilter filter = const TransactionHistoryFilter(),
    required Future<void> Function(String) writeChunk,
  }) async {
    if (!scope.isValid) throw StateError('No history account selected');
    final db = await _database.database;
    return db.transaction((txn) async {
      await writeChunk(TransactionHistoryCsv.header);
      var count = 0;
      await for (final batch in _batches(txn, scope, filter)) {
        final output = StringBuffer();
        for (final record in batch) {
          output.write(TransactionHistoryCsv.row(++count, record, scope));
        }
        await writeChunk(output.toString());
      }
      return count;
    });
  }

  Stream<List<Object>> _batches(
    DatabaseExecutor db,
    TransactionHistoryScope scope,
    TransactionHistoryFilter filter, {
    int startOffset = 0,
  }) async* {
    if (filter.direction != null && !['in', 'out'].contains(filter.direction)) {
      throw ArgumentError('Invalid direction');
    }
    final conditions = <String>[
      'userUuid = ?',
      'coinMiniName = ?',
      'isTest = ?',
      scope.isEvm ? 'LOWER(address) = LOWER(?)' : 'address = ?',
      'contract = ?',
      if (!scope.isBtc && filter.direction != null)
        (scope.isEvm ? 'LOWER(from1)' : 'from1') +
            (filter.direction == 'out' ? ' = ' : ' != ') +
            (scope.isEvm ? 'LOWER(?)' : '?'),
      if (filter.status != null) 'state = ?',
      if (filter.fromMs != null) '$_timestamp >= ?',
      if (filter.untilMs != null) '$_timestamp < ?',
    ];
    final arguments = <Object?>[
      scope.userId, scope.coinType, scope.isTest ? 1 : 0, scope.address,
      // Both legacy tables persist the contract key in lowercase.
      scope.contract.toLowerCase(),
      if (!scope.isBtc && filter.direction != null) scope.address,
      ?filter.status, ?filter.fromMs, ?filter.untilMs,
    ];
    var offset = startOffset;
    while (true) {
      final rows = await db.query(
        scope.isBtc ? 'BtcTransactionRecord' : 'TransationRecord',
        where: conditions.join(' AND '),
        whereArgs: arguments,
        orderBy: '$_timestamp DESC, trId DESC',
        limit: _batchSize,
        offset: offset,
      );
      final records = <Object>[];
      for (final row in rows) {
        final Object record = scope.isBtc
            ? BtcTransactionRecodeModel.fromMap(row)
            : TransationRecordModel.fromMap(row);
        if (filter.direction != null &&
            historyIsOutgoing(record, scope) != (filter.direction == 'out')) {
          continue;
        }
        records.add(record);
      }
      yield records;
      if (rows.length < _batchSize) break;
      offset += rows.length;
    }
  }
}
