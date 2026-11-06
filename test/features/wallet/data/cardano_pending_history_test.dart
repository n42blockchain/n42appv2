import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ada_api.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class _Database extends AppDatabase {
  _Database(this.connection);
  final Database connection;
  @override
  Future<Database> get database async => connection;
}

class _Api extends AdaApi {
  _Api() : super(projectId: 'fixture');
  bool found = false;
  @override
  Future<MessageModel> getTransaction(
    String hash, {
    bool isTest = false,
  }) async {
    expect(hash, 'ab' * 32);
    expect(isTest, isTrue);
    return found
        ? (MessageModel()
            ..data = {
              'hash': hash,
              'block': 'cd' * 32,
              'block_height': 456,
              'valid_contract': true,
            })
        : MessageModel.error();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  for (final persistedId in [true, false]) {
    test('pending Cardano history survives reopen with persistedId=$persistedId', () async {
      final directory = await Directory.systemTemp.createTemp(
        'n42-cardano-recovery-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final path = '${directory.path}/records.db';
      var connection = await databaseFactoryFfi.openDatabase(path);
      addTearDown(() async {
        if (connection.isOpen) await connection.close();
      });
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
      var database = _Database(connection);
      final record = TransationRecordModel()
        ..userUuid = 'alice'
        ..walletIndex = 2
        ..from1 = 'addr_fixture'
        ..to1 = 'addr_recipient'
        ..coinMiniName = 'ADA'
        ..coin = {'coinType': 'ADA', 'blockchainType': 'Cardano', 'decimals': 6}
        ..txHash = 'ab' * 32
        ..price = BigInt.from(12500000)
        ..isTest = 1;
      record.trId = await database.insertTransationRecord(record);
      await connection.close();
      connection = await databaseFactoryFfi.openDatabase(path);
      database = _Database(connection);
      var pending = await database.selectTransationRecordUnDone('alice');
      expect(pending, hasLength(1));
      expect(pending.single.walletIndex, 2);
      expect(await database.selectTransationRecordUnDone('bob'), isEmpty);
      final api = _Api();
      final resolver = TransactionStateResolver(adaApi: api);
      expect(await resolver.resolveState(pending.single), -1);
      expect(pending.single.state, 0);
      expect(
        await database.selectTransationRecordUnDone('alice'),
        hasLength(1),
      );
      // Same on-chain hash in another user's history must remain untouched.
      final other = TransationRecordModel.fromMap(
        record.toMapDb()..['trId'] = 0,
      );
      other.userUuid = 'bob';
      other.trId = await database.insertTransationRecord(other);
      for (final change in [
        {'walletIndex': 3},
        {'isTest': 0},
        {'coinId': 99},
      ]) {
        await database.insertTransationRecord(
          TransationRecordModel.fromMap({...record.toMap(), ...change}),
        );
      }
      if (!persistedId) pending.single.trId = 0;
      api.found = true;
      pending.single.state = await resolver.resolveState(pending.single);
      expect(pending.single.state, 1);
      expect(await database.updateTransationRecordTxhash(pending.single), 1);
      expect(
        await database.selectTransationRecordUnDone('alice'),
        hasLength(3),
      );
      final saved = await connection.query('TransationRecord');
      expect(saved, hasLength(5));
      expect(saved.where((row) => row['state'] == 1), hasLength(1));
      expect(saved.first['txHash'], 'ab' * 32);
      expect(
        (await database.selectTransationRecordUnDone('bob')).single.userUuid,
        'bob',
      );
      expect(saved.first.keys, isNot(contains('signedTx')));
      expect(saved.first.keys, isNot(contains('privateKey')));
    });
  }
}
