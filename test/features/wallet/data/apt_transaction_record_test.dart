import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _Database extends AppDatabase {
  final Database connection;
  _Database(this.connection);
  @override
  Future<Database> get database async => connection;
}

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late Database connection;
  late String path;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('n42-apt-history-');
    path = '${directory.path}/history.db';
    connection = await databaseFactoryFfi.openDatabase(path);
    final columns = TransationRecordModel()
        .toMapDb()
        .keys
        .map(
          (key) =>
              '$key ${['coinId', 'state', 'isTest', 'walletIndex'].contains(key) ? 'INTEGER' : 'TEXT'}',
        )
        .join(',');
    await connection.execute(
      'CREATE TABLE TransationRecord (trId INTEGER PRIMARY KEY AUTOINCREMENT, $columns)',
    );
  });
  tearDown(() async {
    await connection.close();
    await directory.delete(recursive: true);
  });
  TransationRecordModel record() => TransationRecordModel()
    ..userUuid = 'alice'
    ..walletIndex = 0
    ..coinMiniName = 'APT'
    ..coinId = 1
    ..address = '0x1'
    ..from1 = '0x1'
    ..to1 = '0x2'
    ..price = BigInt.from(123)
    ..txHash = '0x${'ab' * 32}';

  test('concurrent writes and reopen reuse the original row', () async {
    final ids = await Future.wait(
      List.generate(
        20,
        (_) => _Database(connection).saveAptTransactionRecord(record()),
      ),
    );
    expect(ids.toSet(), hasLength(1));
    await connection.close();
    connection = await databaseFactoryFfi.openDatabase(path);
    final terminal = record()
      ..state = 1
      ..from1 = '0x${'0' * 63}1';
    expect(
      await _Database(connection).saveAptTransactionRecord(terminal),
      ids.first,
    );
    expect(
      await _Database(connection).saveAptTransactionRecord(record()),
      ids.first,
    );
    final rows = await connection.query('TransationRecord');
    expect(rows, hasLength(1));
    expect(rows.single['state'], 1);
    expect(rows.single['price'], '123');
  });
  test('account wallet chain and hash scopes remain distinct', () async {
    final records = [
      record(),
      record()..userUuid = 'bob',
      record()..walletIndex = 1,
      record()..coinId = 2,
      record()..txHash = '0x${'cd' * 32}',
    ];
    for (final r in records) {
      await _Database(connection).saveAptTransactionRecord(r);
    }
    expect(await connection.query('TransationRecord'), hasLength(5));
  });
  test(
    'caller mutation during database await cannot retarget persistence',
    () async {
      final r = record();
      final saving = _Database(connection).saveAptTransactionRecord(r);
      r.userUuid = 'bob';
      r.walletIndex = 9;
      r.price = BigInt.zero;
      await saving;
      final row = (await connection.query('TransationRecord')).single;
      expect(row['userUuid'], 'alice');
      expect(row['walletIndex'], 0);
      expect(row['price'], '123');
    },
  );
  test('recovery preserves payment fields and rejects contradictory terminal state', () async {
    final database = _Database(connection);
    await database.saveAptTransactionRecord(record());
    await database.saveAptTransactionRecord(
      record()
        ..state = 2
        ..price = BigInt.zero
        ..to1 = '0x3',
    );
    final row = (await connection.query('TransationRecord')).single;
    expect(row['state'], 2);
    expect(row['price'], '123');
    expect(row['to1'], '0x2');
    await expectLater(
      database.saveAptTransactionRecord(record()..state = 1),
      throwsStateError,
    );
  });
  test(
    'recovery completes only original matching history and is idempotent',
    () async {
      final database = _Database(connection);
      final original = record();
      await database.saveAptTransactionRecord(original);
      await database.saveAptTransactionRecord(record()..coinId = 2);
      for (var i = 0; i < 2; i++) {
        await database.completeAptTransactionRecord(
          chainId: 1,
          sender: '0x1',
          hash: original.txHash,
          success: true,
        );
      }
      final rows = await connection.query(
        'TransationRecord',
        orderBy: 'coinId',
      );
      expect(rows.map((r) => r['state']).toList(), [1, 0]);
      expect(rows.first['userUuid'], 'alice');
      expect(rows.first['price'], '123');
      await expectLater(
        database.completeAptTransactionRecord(
          chainId: 1,
          sender: '0x1',
          hash: original.txHash,
          success: false,
        ),
        throwsStateError,
      );
      await expectLater(
        database.completeAptTransactionRecord(
          chainId: 1,
          sender: '0x2',
          hash: original.txHash,
          success: true,
        ),
        throwsStateError,
      );
    },
  );

  test('invalid identity cannot create a row', () async {
    for (final r in [
      record()..txHash = '',
      record()..coinId = 0,
      record()..from1 = '0x1\n',
      record()..coinMiniName = 'ETH',
    ]) {
      await expectLater(
        _Database(connection).saveAptTransactionRecord(r),
        throwsArgumentError,
      );
    }
    expect(await connection.query('TransationRecord'), isEmpty);
  });
}
