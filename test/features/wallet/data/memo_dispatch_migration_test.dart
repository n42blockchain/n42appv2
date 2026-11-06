import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('v8 upgrade preserves legacy unknown submissions and enables tracked dispatch', () async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final previousPath = await databaseFactory.getDatabasesPath();
    final directory = await Directory.systemTemp.createTemp('memo-v8-');
    await databaseFactory.setDatabasesPath(directory.path);
    Database? connection;
    addTearDown(() async {
      await connection?.close();
      await databaseFactory.setDatabasesPath(previousPath);
      await directory.delete(recursive: true);
    });
    final legacy = TransationRecordModel()
      ..userUuid = 'alice'
      ..coinMiniName = 'ADA'
      ..from1 = 'sender'
      ..txHash = 'ab' * 32;
    final columns = legacy
        .toMapDb()
        .keys
        .map(
          (key) =>
              '$key ${['coinId', 'state', 'isTest', 'walletIndex'].contains(key) ? 'INTEGER' : 'TEXT'}',
        )
        .join(', ');
    connection = await databaseFactory.openDatabase(
      '${directory.path}/astranet.db',
      options: OpenDatabaseOptions(
        version: 8,
        onCreate: (db, _) async {
          await db.execute(
            'CREATE TABLE TransationRecord(trId INTEGER PRIMARY KEY AUTOINCREMENT, $columns)',
          );
          await db.execute(
            'CREATE TABLE AddressBook(userUuid TEXT, coinName TEXT)',
          );
        },
      ),
    );
    await connection.insert('TransationRecord', legacy.toMapDb());
    await connection.close();
    final app = AppDatabase();
    connection = await app.database;
    expect(await connection.getVersion(), 9);
    final row = (await connection.query('TransationRecord')).single;
    expect(row['memoDispatchPhase'], isNull);
    expect(row['txHash'], legacy.txHash);
    await expectLater(
      app.reserveMemoTransaction(legacy, trackDispatch: true),
      throwsA(isA<PendingMemoTransactionException>()),
    );
    final fresh = TransationRecordModel.fromMap(legacy.toMap())
      ..userUuid = 'bob';
    fresh.trId = await app.reserveMemoTransaction(fresh, trackDispatch: true);
    expect(await app.markMemoTransactionDispatch(fresh), isTrue);
    expect(
      (await connection.query(
        'TransationRecord',
        where: 'userUuid=?',
        whereArgs: ['alice'],
      )).single['memoDispatchPhase'],
      isNull,
    );
  });
}
