import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/egld_api.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';

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
      'CREATE TABLE TransationRecord (trId INTEGER PRIMARY KEY AUTOINCREMENT, $columns, memoDispatchPhase TEXT)',
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
        ..coin = {
          'blockchainType': chain == 'EGLD'
              ? 'MultiversX'
              : chain == 'NEAR'
              ? 'Near'
              : chain,
        }
        ..to1 = 'recipient'
        ..price = BigInt.one
        ..from1 = 'sender'
        ..userUuid = 'alice'
        ..txHash = chain == 'NEAR'
            ? Base58Encode(List.filled(32, int.parse(hash, radix: 16)))
            : hash * 32;

  for (final chain in ['ADA', 'XLM', 'EGLD', 'NEAR']) {
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
        if (chain == 'EGLD') {
          final restored = TransationRecordModel.fromMap(
            (await connection.query('TransationRecord')).single,
          );
          var receipt = <String, dynamic>{};
          final resolver = TransactionStateResolver(
            egldApi: EgldApi(get: (_) async => receipt),
          );
          expect(await resolver.resolveState(restored), -1);
          await expectLater(
            db.reserveMemoTransaction(record(chain, hash: 'cd')),
            throwsA(isA<PendingMemoTransactionException>()),
          );
          receipt = {
            'txHash': restored.txHash,
            'sender': restored.from1,
            'receiver': restored.to1,
            'value': '1',
            'status': 'success',
            'miniBlockHash': 'ef' * 32,
            'timestamp': 123,
          };
          original.state = await resolver.resolveState(restored);
          expect(original.state, 1);
        } else if (chain == 'NEAR') {
          final restored = TransationRecordModel.fromMap(
            (await connection.query('TransationRecord')).single,
          );
          var finality = 'EXECUTED_OPTIMISTIC';
          final resolver = TransactionStateResolver(
            nearApiFactory: (_) => NearApi(
              request: (_, body) async {
                expect(body['params'], {
                  'tx_hash': restored.txHash,
                  'sender_account_id': restored.from1,
                  'wait_until': 'FINAL',
                });
                return {
                  'result': {
                    'final_execution_status': finality,
                    'status': {'SuccessValue': ''},
                    'transaction': {
                      'hash': restored.txHash,
                      'signer_id': restored.from1,
                      'receiver_id': restored.to1,
                      'actions': [
                        {
                          'Transfer': {'deposit': restored.price.toString()},
                        },
                      ],
                    },
                  },
                };
              },
            ),
          );
          expect(await resolver.resolveState(restored), -1);
          await expectLater(
            db.reserveMemoTransaction(record(chain, hash: 'cd')),
            throwsA(isA<PendingMemoTransactionException>()),
          );
          finality = 'FINAL';
          original.state = await resolver.resolveState(restored);
          expect(original.state, 1);
        } else {
          original.state = 1;
        }
        expect(await db.updateTransationRecordTxhash(original), 1);
        expect(
          await db.reserveMemoTransaction(record(chain, hash: 'cd')),
          greaterThan(0),
        );
        final rows = await connection.query('TransationRecord');
        expect(rows, hasLength(2));
        expect(rows.first['txHash'], record(chain).txHash);
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
  for (final chain in ['ADA', 'XLM', 'EGLD', 'NEAR']) {
    test('$chain dispatch rejects changed transaction intent', () async {
      final original = record(chain);
      original.trId = await db.reserveMemoTransaction(
        original,
        trackDispatch: true,
      );
      for (final change in [
        {'coinId': 99},
        {'to1': 'other-recipient'},
        {'price': '2'},
        {'contract': 'other-token'},
      ]) {
        expect(
          await db.markMemoTransactionDispatch(
            TransationRecordModel.fromMap({...original.toMap(), ...change}),
          ),
          isFalse,
        );
        expect(
          (await connection.query('TransationRecord'))
              .single['memoDispatchPhase'],
          'reserved',
        );
      }
      expect(await db.markMemoTransactionDispatch(original), isTrue);
    });
    test('$chain release targets only original pending identity', () async {
      final original = record(chain);
      original.trId = await db.reserveMemoTransaction(original);
      for (final change in [
        {'userUuid': 'bob'},
        {'walletIndex': 99},
        {'txHash': 'cd' * 32},
        {'isTest': 1},
        {'from1': 'other'},
        {'coinId': 99},
        {'to1': 'other-recipient'},
        {'price': '2'},
        {'contract': 'other-token'},
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
  for (final chain in ['ADA', 'XLM', 'EGLD', 'NEAR']) {
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

  for (final chain in ['ADA', 'XLM', 'EGLD', 'NEAR']) {
    test(
      '$chain prepared crash can retry after reopen without broadcasting old row',
      () async {
        final original = record(chain);
        original.trId = await db.reserveMemoTransaction(
          original,
          trackDispatch: true,
        );
        await connection.close();
        connection = await databaseFactoryFfi.openDatabase(
          '${directory.path}/history.db',
        );
        db = _Database(connection);
        final retry = record(chain, hash: 'cd');
        retry.trId = await db.reserveMemoTransaction(
          retry,
          trackDispatch: true,
        );
        expect(await db.markMemoTransactionDispatch(original), isFalse);
        expect(await db.markMemoTransactionDispatch(retry), isTrue);
        expect(await db.markMemoTransactionDispatch(retry), isFalse);
        await expectLater(
          db.reserveMemoTransaction(record(chain), trackDispatch: true),
          throwsA(isA<PendingMemoTransactionException>()),
        );
        final rows = await connection.query('TransationRecord');
        expect(rows, hasLength(1));
        expect(rows.single['txHash'], retry.txHash);
        expect(rows.single['memoDispatchPhase'], 'dispatching');
      },
    );
    for (final phase in [null, 'dispatching', 'unknown']) {
      test('$chain recovery preserves ambiguous phase $phase', () async {
        final original = record(chain);
        original.trId = await db.reserveMemoTransaction(original);
        await connection.update('TransationRecord', {
          'memoDispatchPhase': phase,
        });
        await expectLater(
          db.reserveMemoTransaction(
            record(chain, hash: 'cd'),
            trackDispatch: true,
          ),
          throwsA(isA<PendingMemoTransactionException>()),
        );
        expect(await db.markMemoTransactionDispatch(original), isFalse);
        expect(
          (await connection.query('TransationRecord')).single['txHash'],
          original.txHash,
        );
      });
    }
    test(
      '$chain reservation and dispatch race permits at most one broadcast',
      () async {
        var broadcasts = 0;
        Future<void> attempt(String hash) async {
          final tx = record(chain, hash: hash);
          try {
            tx.trId = await db.reserveMemoTransaction(tx, trackDispatch: true);
            if (await db.markMemoTransactionDispatch(tx)) broadcasts++;
          } on PendingMemoTransactionException {
            /* already dispatching */
          }
        }

        await Future.wait([attempt('ab'), attempt('cd')]);
        expect(broadcasts, 1);
        expect(await connection.query('TransationRecord'), hasLength(1));
      },
    );
    test(
      '$chain recovery preserves other accounts, networks and resolved rows',
      () async {
        final original = record(chain);
        original.trId = await db.reserveMemoTransaction(
          original,
          trackDispatch: true,
        );
        final other = record(chain)..userUuid = 'bob';
        await db.reserveMemoTransaction(other, trackDispatch: true);
        final net = record(chain)..isTest = 1;
        await db.reserveMemoTransaction(net, trackDispatch: true);
        original.state = 1;
        await db.updateTransationRecordTxhash(original);
        await db.reserveMemoTransaction(
          record(chain, hash: 'cd'),
          trackDispatch: true,
        );
        expect(await connection.query('TransationRecord'), hasLength(4));
      },
    );
  }

  test('invalid reservation creates no history', () async {
    for (final tx in [
      record('BTC'),
      record('NEAR')..txHash = 'ab' * 32,
      record('NEAR')..txHash = '0' * 44,
      record('NEAR')..txHash = Base58Encode(List.filled(31, 1)),
      record('NEAR')..txHash = Base58Encode(List.filled(33, 1)),
      record('NEAR')..txHash = " ${record('NEAR').txHash}",
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
