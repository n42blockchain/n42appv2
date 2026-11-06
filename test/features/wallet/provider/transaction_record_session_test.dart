import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';

class _Connection implements Database {
  int writes = 0;
  Completer<void>? gate;
  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    writes++;
    await gate?.future;
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Database extends AppDatabase {
  final connection = _Connection();
  final calls = <(String, String)>[];
  Completer<void>? gate;
  @override
  Future<Database> get database async => connection;
  @override
  Future<List<T>> queryList<T>(
    String table,
    T Function(Map<String, dynamic>) fromMap, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final owner = whereArgs!.first as String;
    calls.add((table, owner));
    final wait = gate;
    gate = null;
    await wait?.future;
    if (table == 'TransationRecord') {
      return [fromMap((TransationRecordModel()..userUuid = owner).toMap())];
    }
    return [];
  }
}

class _Resolver extends TransactionStateResolver {
  Completer<int> result = Completer<int>();
  int calls = 0;
  @override
  Future<int> resolveState(TransationRecordModel item) {
    calls++;
    return result.future;
  }

  @override
  Future<int> resolveBtcConfirmations(BtcTransactionRecodeModel item) {
    calls++;
    return result.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final interrupted in ['account', 'session', 'dispose']) {
    test(
      'loading discards $interrupted interruption before second query',
      () async {
        var user = 'alice';
        Object session = Object();
        final db = _Database()..gate = Completer<void>();
        final gate = db.gate!;
        final provider = TransactionRecordItemProvider(
          database: db,
          userUuid: () => user,
          sessionIdentity: () => session,
        );
        final pending = provider.selectUndoneTr();
        if (interrupted == 'account') user = 'bob';
        if (interrupted == 'session') session = Object();
        if (interrupted == 'dispose') provider.dispose();
        gate.complete();
        await pending;
        expect(db.calls, [('TransationRecord', 'alice')]);
        expect(provider.unDoneTrModelList, isEmpty);
        if (interrupted != 'dispose') provider.dispose();
      },
    );
  }
  test('new load wins over an older delayed load', () async {
    var user = 'alice';
    final db = _Database()..gate = Completer<void>();
    final gate = db.gate!;
    final provider = TransactionRecordItemProvider(
      database: db,
      userUuid: () => user,
    );
    addTearDown(provider.dispose);
    final old = provider.selectUndoneTr();
    user = 'bob';
    await provider.selectUndoneTr();
    gate.complete();
    await old;
    expect(provider.unDoneTrModelList.single.userUuid, 'bob');
    expect(db.calls, [
      ('TransationRecord', 'alice'),
      ('TransationRecord', 'bob'),
      ('BtcTransactionRecord', 'bob'),
    ]);
  });
  for (final btc in [false, true]) {
    for (final returning in [false, true]) {
      for (final change in ['account', 'session', 'dispose']) {
        test('receipt btc=$btc return=$returning suppresses $change', () async {
          var user = 'alice';
          Object session = Object();
          final db = _Database();
          final resolver = _Resolver();
          final provider = TransactionRecordItemProvider(
            database: db,
            resolver: resolver,
            userUuid: () => user,
            sessionIdentity: () => session,
          );
          final tx = TransationRecordModel()..userUuid = 'alice';
          final bt = BtcTransactionRecodeModel()..userUuid = 'alice';
          final pending = btc
              ? (returning
                    ? provider.checkUndoneTrBtcReturn(bt)
                    : provider.checkUndoneTrBtc(bt))
              : (returning
                    ? provider.checkUndoneTrReturn(tx)
                    : provider.checkUndoneTr(tx));
          if (change == 'account') user = 'bob';
          if (change == 'session') session = Object();
          if (change == 'dispose') provider.dispose();
          resolver.result.complete(btc ? 6 : 1);
          await pending;
          expect(db.connection.writes, 0);
          expect(tx.state, 0);
          expect(bt.state, 0);
          if (change != 'dispose') provider.dispose();
        });
      }
    }
    test('matching receipt btc=$btc is still persisted and returned', () async {
      final db = _Database();
      final resolver = _Resolver()..result.complete(btc ? 6 : 1);
      final provider = TransactionRecordItemProvider(
        database: db,
        resolver: resolver,
        userUuid: () => 'alice',
      );
      addTearDown(provider.dispose);
      final result = btc
          ? await provider.checkUndoneTrBtcReturn(
              BtcTransactionRecodeModel()..userUuid = 'alice',
            )
          : await provider.checkUndoneTrReturn(
              TransationRecordModel()..userUuid = 'alice',
            );
      expect(result, isNotNull);
      expect(db.connection.writes, 1);
    });
  }
  for (final returning in [false, true]) {
    test(
      'account switch during persistence suppresses return=$returning',
      () async {
        var user = 'alice';
        final db = _Database();
        db.connection.gate = Completer<void>();
        final resolver = _Resolver()..result.complete(1);
        final provider = TransactionRecordItemProvider(
          database: db,
          resolver: resolver,
          userUuid: () => user,
        );
        addTearDown(provider.dispose);
        final tx = TransationRecordModel()..userUuid = 'alice';
        final Future<Object?> pending = returning
            ? provider.checkUndoneTrReturn(tx)
            : provider.checkUndoneTr(tx).then<Object?>((_) => null);
        await Future<void>.delayed(Duration.zero);
        expect(db.connection.writes, 1);
        user = 'bob';
        db.connection.gate!.complete();
        expect(await pending, isNull);
      },
    );
  }
  test('foreign account is neither queued nor queried', () async {
    final resolver = _Resolver();
    final provider = TransactionRecordItemProvider(
      resolver: resolver,
      userUuid: () => 'bob',
    );
    addTearDown(provider.dispose);
    final tx = TransationRecordModel()..userUuid = 'alice';
    final btc = BtcTransactionRecodeModel()..userUuid = 'alice';
    provider.addUndoneTr(tx, 1);
    provider.addUndoneTr(btc, 0);
    expect(provider.unDoneTrModelList, isEmpty);
    expect(provider.trUndoneList, isEmpty);
    expect(await provider.checkUndoneTrReturn(tx), isNull);
    expect(await provider.checkUndoneTrBtcReturn(btc), isNull);
    expect(resolver.calls, 0);
  });
}
