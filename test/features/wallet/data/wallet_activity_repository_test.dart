import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/wallet_activity_repository.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _Database extends AppDatabase {
  final Database db;
  _Database(this.db);
  @override
  Future<Database> get database async => db;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Database db;
  late WalletActivityRepository repository;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    // Types match the two legacy ledgers, including TEXT timestamps/amounts.
    for (final entry in {
      'TransationRecord': TransationRecordModel().toMapDb(),
      'BtcTransactionRecord': BtcTransactionRecodeModel().toMapDb(),
    }.entries) {
      final columns = entry.value.keys
          .map((key) {
            final integer = {
              'coinId',
              'state',
              'isTest',
              'walletIndex',
              'confirmations',
              'gasPrice',
            }.contains(key);
            return '$key ${integer ? 'INTEGER' : 'TEXT'}';
          })
          .join(', ');
      await db.execute(
        'CREATE TABLE ${entry.key} (trId INTEGER PRIMARY KEY AUTOINCREMENT, $columns)',
      );
    }
    repository = WalletActivityRepository(database: _Database(db));
  });
  tearDown(() => db.close());

  Future<void> insertEvm(
    String hash,
    String time, {
    String user = 'alice',
    int status = 1,
    int testnet = 0,
  }) async {
    final tx = TransationRecordModel()
      ..userUuid = user
      ..txHash = hash
      ..txTime = time
      ..state = status
      ..isTest = testnet
      ..address = '0xalice'
      ..coin = {'coinType': 'ETH', 'unit': 'ETH', 'decimals': 18};
    await db.insert('TransationRecord', tx.toMapDb());
  }

  test(
    'merges seconds and milliseconds before pagination and isolates users',
    () async {
      await insertEvm('older', '1700000000000');
      await insertEvm('newest', '1700000002000', testnet: 1);
      await insertEvm('other-user', '1800000000000', user: 'bob');
      final btc = BtcTransactionRecodeModel()
        ..userUuid = 'alice'
        ..txHash = 'middle'
        ..txTime = '1700000001'
        ..coin = {'coinType': 'BTC', 'unit': 'BTC', 'decimals': 8};
      await db.insert('BtcTransactionRecord', btc.toMapDb());
      final first = await repository.load(userId: 'alice', limit: 2);
      expect((first.first.record as TransationRecordModel).txHash, 'newest');
      expect(first.first.coin.isTest, isTrue);
      expect((first.last.record as BtcTransactionRecodeModel).txHash, 'middle');
      final second = await repository.load(
        userId: 'alice',
        limit: 2,
        offset: 2,
      );
      expect(second, hasLength(1));
      expect((second.single.record as TransationRecordModel).txHash, 'older');
      expect(await repository.load(userId: ''), isEmpty);
      expect(await repository.load(userId: "alice' OR 1=1 --"), isEmpty);
    },
  );

  test(
    'status filtering reaches records beyond the first unfiltered page',
    () async {
      for (var i = 0; i < 60; i++) {
        await insertEvm('new-$i', '${1700000100 + i}');
      }
      await insertEvm('old-failure', '1600000000', status: 2);
      final failed = await repository.load(userId: 'alice', status: 2);
      expect(failed, hasLength(1));
      expect(
        (failed.single.record as TransationRecordModel).txHash,
        'old-failure',
      );
    },
  );
}
