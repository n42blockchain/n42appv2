import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';

class _Database extends AppDatabase {
  _Database(this.connection);
  final Database connection;
  @override
  Future<Database> get database async => connection;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory directory;
  late Database connection;
  late _Database db;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('memo-reservation-');
    connection = await databaseFactoryFfi.openDatabase(
      '${directory.path}/history.db',
    );
    final columns = TransationRecordModel()
        .toMapDb()
        .keys
        .map(
          (key) =>
              '$key ${['coinId', 'state', 'isTest', 'walletIndex'].contains(key) ? 'INTEGER' : 'TEXT'}',
        )
        .join(', ');
    await connection.execute(
      'CREATE TABLE TransationRecord (trId INTEGER PRIMARY KEY AUTOINCREMENT, $columns)',
    );
    db = _Database(connection);
  });
  tearDown(() async {
    await connection.close();
    await directory.delete(recursive: true);
  });
  TransationRecordModel record(String chain, {String hash = 'ab'}) =>
      TransationRecordModel()
        ..coinMiniName = chain
        ..from1 = 'sender'
        ..userUuid = 'alice'
        ..txHash = hash * 32;

  for (final chain in ['ADA', 'XLM']) {
    for (final sameHash in [false, true]) {
      test(
        '$chain simultaneous reservations sameHash=$sameHash allow one broadcast',
        () async {
          var broadcasts = 0;
          var blocked = 0;
          Future<void> send(
            _Database database,
            TransationRecordModel tx,
          ) async {
            try {
              tx.trId = await database.reserveMemoTransaction(tx);
              broadcasts++;
            } on PendingMemoTransactionException {
              blocked++;
            }
          }

          await Future.wait([
            send(db, record(chain)),
            send(
              _Database(connection),
              record(chain, hash: sameHash ? 'ab' : 'cd'),
            ),
          ]);
          expect(broadcasts, 1);
          expect(blocked, 1);
          expect(await connection.query('TransationRecord'), hasLength(1));
        },
      );
    }
    test(
      '$chain reopen keeps reservation until original receipt resolves',
      () async {
        final original = record(chain);
        original.trId = await db.reserveMemoTransaction(original);
        await connection.close();
        connection = await databaseFactoryFfi.openDatabase(
          '${directory.path}/history.db',
        );
        db = _Database(connection);
        await expectLater(
          db.reserveMemoTransaction(record(chain, hash: 'cd')),
          throwsA(isA<PendingMemoTransactionException>()),
        );
        original.state = 1;
        expect(await db.updateTransationRecordTxhash(original), 1);
        expect(
          await db.reserveMemoTransaction(record(chain, hash: 'cd')),
          greaterThan(0),
        );
        final rows = await connection.query('TransationRecord');
        expect(rows, hasLength(2));
        expect(rows.first['txHash'], 'ab' * 32);
        expect(rows.first['state'], 1);
      },
    );
    test(
      '$chain sender reservation spans wallet aliases but isolates users and networks',
      () async {
        await db.reserveMemoTransaction(record(chain));
        await expectLater(
          db.reserveMemoTransaction(record(chain)..walletIndex = 8),
          throwsA(isA<PendingMemoTransactionException>()),
        );
        expect(
          await db.reserveMemoTransaction(record(chain)..userUuid = 'bob'),
          greaterThan(0),
        );
        expect(
          await db.reserveMemoTransaction(record(chain)..isTest = 1),
          greaterThan(0),
        );
        expect(
          await db.reserveMemoTransaction(
            record(chain)..from1 = 'other-sender',
          ),
          greaterThan(0),
        );
        expect(await connection.query('TransationRecord'), hasLength(4));
      },
    );
  }
  for (final chain in ['ADA', 'XLM']) {
    test('$chain release targets only original pending identity', () async {
      final original = record(chain);
      original.trId = await db.reserveMemoTransaction(original);
      for (final change in [
        {'userUuid': 'bob'},
        {'walletIndex': 99},
        {'txHash': 'cd' * 32},
        {'isTest': 1},
        {'from1': 'other'},
        {'trId': 0},
      ]) {
        expect(
          await db.releaseUnsubmittedMemoTransaction(
            TransationRecordModel.fromMap({...original.toMap(), ...change}),
          ),
          isFalse,
        );
      }
      expect(await connection.query('TransationRecord'), hasLength(1));
      expect(await db.releaseUnsubmittedMemoTransaction(original), isTrue);
      expect(await connection.query('TransationRecord'), isEmpty);
      expect(await db.reserveMemoTransaction(record(chain)), greaterThan(0));
    });
    for (final terminal in [1, 2]) {
      test('$chain release preserves terminal state $terminal', () async {
        final original = record(chain);
        original.trId = await db.reserveMemoTransaction(original);
        original.state = terminal;
        await db.updateTransationRecordTxhash(original);
        expect(await db.releaseUnsubmittedMemoTransaction(original), isFalse);
        expect(
          (await connection.query('TransationRecord')).single['state'],
          terminal,
        );
      });
    }
  }
  for (final chain in ['ADA', 'XLM']) {
    for (final terminal in [1, 2]) {
      test(
        '$chain late polling cannot overwrite terminal state $terminal',
        () async {
          final original = record(chain);
          original.trId = await db.reserveMemoTransaction(original);
          final late = TransationRecordModel.fromMap(original.toMap());
          original.state = terminal;
          expect(await db.updateTransationRecordTxhash(original), 1);
          await connection.close();
          connection = await databaseFactoryFfi.openDatabase(
            '${directory.path}/history.db',
          );
          db = _Database(connection);
          for (final staleState in [0, terminal == 1 ? 2 : 1]) {
            late.state = staleState;
            late.errorMessage = 'stale response';
            expect(await db.updateTransationRecordTxhash(late), 0);
            final stored = (await connection.query('TransationRecord')).single;
            expect(stored['state'], terminal);
            expect(stored['errorMessage'], original.errorMessage);
          }
          // Rechecking the same terminal result can still drain background queues.
          expect(await db.updateTransationRecordTxhash(original), 1);
        },
      );
    }
    test(
      '$chain competing receipt writes accept only one terminal result',
      () async {
        final original = record(chain);
        original.trId = await db.reserveMemoTransaction(original);
        final success = TransationRecordModel.fromMap(original.toMap())
          ..state = 1;
        final failure = TransationRecordModel.fromMap(original.toMap())
          ..state = 2;
        final updates = await Future.wait([
          db.updateTransationRecordTxhash(success),
          _Database(connection).updateTransationRecordTxhash(failure),
        ]);
        expect(updates.reduce((a, b) => a + b), 1);
        final stored = (await connection.query('TransationRecord')).single;
        expect(stored['state'], updates.first == 1 ? 1 : 2);
      },
    );
  }

  test('invalid reservation creates no history', () async {
    for (final tx in [
      record('BTC'),
      record('ADA')..txHash = 'bad',
      record('XLM')..state = 1,
      record('ADA')..isTest = 2,
      record('XLM')..from1 = '',
    ]) {
      await expectLater(db.reserveMemoTransaction(tx), throwsArgumentError);
    }
    expect(await connection.query('TransationRecord'), isEmpty);
  });
}
