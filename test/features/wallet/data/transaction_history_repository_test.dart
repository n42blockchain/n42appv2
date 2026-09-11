import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_history_csv.dart';
import 'package:n42_wallet/features/wallet/data/transaction_history_query.dart';
import 'package:n42_wallet/features/wallet/data/transaction_history_repository.dart';
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
  late TransactionHistoryRepository repository;
  const scope = TransactionHistoryScope(
    userId: 'alice',
    address: '0xAbC',
    coinType: 'ETH',
    blockchainType: 'Ethereum',
  );
  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    for (final entry in {
      'TransationRecord': TransationRecordModel().toMapDb(),
      'BtcTransactionRecord': BtcTransactionRecodeModel().toMapDb(),
    }.entries) {
      final columns = entry.value.keys
          .map(
            (key) =>
                '$key ${{'coinId', 'state', 'isTest', 'walletIndex', 'confirmations', 'gasPrice'}.contains(key) ? 'INTEGER' : 'TEXT'}',
          )
          .join(', ');
      await db.execute(
        'CREATE TABLE ${entry.key} (trId INTEGER PRIMARY KEY AUTOINCREMENT, $columns)',
      );
    }
    repository = TransactionHistoryRepository(database: _Database(db));
  });
  tearDown(() => db.close());

  test(
    'invalid pages and direction are rejected before returning history',
    () async {
      for (final (offset, limit) in [(-1, 50), (0, 0), (0, 201)]) {
        await expectLater(
          repository.load(scope: scope, offset: offset, limit: limit),
          throwsArgumentError,
        );
      }
      await expectLater(
        repository.load(
          scope: scope,
          filter: const TransactionHistoryFilter(direction: 'invalid'),
        ),
        throwsArgumentError,
      );
    },
  );

  Future<void> insert(
    String hash, {
    String user = 'alice',
    int state = 1,
    int testnet = 0,
    String contract = '',
    String from = '0xabc',
    String time = '1700000000',
    String unit = 'ETH',
  }) async {
    final tx = TransationRecordModel()
      ..userUuid = user
      ..address = '0xabc'
      ..coinMiniName = 'ETH'
      ..from1 = from
      ..to1 = 'recipient'
      ..isTest = testnet
      ..contract = contract
      ..state = state
      ..txHash = hash
      ..txTime = time
      ..price = BigInt.parse('900719925474099312345')
      ..coin = {'coinType': 'ETH', 'unit': unit, 'decimals': 18};
    await db.insert('TransationRecord', tx.toMapDb());
  }

  test(
    'filters the full ledger, isolates user/network/token and paginates matched rows',
    () async {
      for (var i = 0; i < 260; i++) {
        await insert('ok-$i', time: '${1700000000 + i}');
      }
      await insert('failed-old', state: 2, time: '1600000000');
      await insert('other-user', user: 'bob', state: 2);
      await insert('testnet', testnet: 1, state: 2);
      await insert('other-token', contract: '0xtoken', state: 2);
      final failures = await repository.load(
        scope: scope,
        filter: const TransactionHistoryFilter(status: 2),
      );
      expect(failures.records, hasLength(1));
      expect(
        (failures.records.single as TransationRecordModel).txHash,
        'failed-old',
      );
      final next = await repository.load(scope: scope, offset: 250);
      expect(next.records, hasLength(11));
      expect(next.hasMore, isFalse);
      expect((next.records.last as TransationRecordModel).txHash, 'failed-old');
      expect((await repository.load(scope: scope)).hasMore, isTrue);
    },
  );

  test(
    'inclusive calendar dates exclude the next midnight across second/ms storage',
    () async {
      final day = DateTime(2026, 9, 10);
      final end = DateTime(2026, 9, 11);
      await insert('before', time: '${day.millisecondsSinceEpoch - 1}');
      await insert('start', time: '${day.millisecondsSinceEpoch ~/ 1000}');
      await insert('last-ms', time: '${end.millisecondsSinceEpoch - 1}');
      await insert('next-day', time: '${end.millisecondsSinceEpoch ~/ 1000}');
      final result = await repository.load(
        scope: scope,
        filter: TransactionHistoryFilter(dateFrom: day, dateTo: day),
      );
      expect(result.records.map((e) => (e as TransationRecordModel).txHash), [
        'last-ms',
        'start',
      ]);
    },
  );

  test(
    'export includes every matching row with exact amounts and escaped cells',
    () async {
      for (var i = 0; i < 260; i++) {
        await insert('row-$i', unit: i == 0 ? '=TOKEN,"bad"\nnext' : 'ETH');
      }
      await insert('incoming', from: '0xother');
      final chunks = <String>[];
      final count = await repository.exportCsv(
        scope: scope,
        filter: const TransactionHistoryFilter(direction: 'out'),
        writeChunk: (s) async => chunks.add(s),
      );
      expect(count, 260);
      expect(chunks.length, greaterThan(2));
      final csv = chunks.join();
      expect(csv, contains('"900.719925474099312345"'));
      expect(csv, contains('"\'=TOKEN,""BAD""\nNEXT"'));
      expect(csv, contains('"row-0"'));
      expect(csv, contains('"row-259"'));
      expect(csv, isNot(contains('incoming')));
      expect(csv, contains('"Mainnet","ETH"'));
      expect(historyCsvCell('  =1+1'), '"\'  =1+1"');
      expect(historyCsvCell('\t@evil'), '"\'\t@evil"');
      expect(historyCsvCell('comma,quote"\rline'), '"comma,quote""\rline"');
    },
  );

  test(
    'BTC direction filtering scans beyond batches and preserves full input addresses',
    () async {
      const btcScope = TransactionHistoryScope(
        userId: 'alice',
        address: '1AbC',
        coinType: 'BTC',
        blockchainType: 'Bitcoin',
      );
      for (var i = 0; i < 205; i++) {
        final tx = BtcTransactionRecodeModel()
          ..userUuid = 'alice'
          ..address = '1AbC'
          ..coinMiniName = 'BTC'
          ..txHash = 'btc-$i'
          ..coin = {'unit': 'BTC', 'decimals': 8}
          ..txTime = '${1700000000 + i}'
          ..inputModels = [
            InputModel()..address = [i == 0 ? '1AbC' : '1abc'],
          ]
          ..outputModels = [
            OutputModel()..address = ['1FullRecipientAddress'],
          ];
        await db.insert('BtcTransactionRecord', tx.toMapDb());
      }
      final filter = const TransactionHistoryFilter(direction: 'out');
      final result = await repository.load(scope: btcScope, filter: filter);
      expect(result.records, hasLength(1));
      expect(
        (result.records.single as BtcTransactionRecodeModel).txHash,
        'btc-0',
      );
      final chunks = <String>[];
      expect(
        await repository.exportCsv(
          scope: btcScope,
          filter: filter,
          writeChunk: (s) async => chunks.add(s),
        ),
        1,
      );
      expect(chunks.join(), contains('"1AbC","1FullRecipientAddress"'));
      expect(
        const TransactionHistoryScope(
          userId: 'alice',
          address: 'SoLaNa',
          coinType: 'SOL',
          blockchainType: 'Solana',
        ).matchesAddress('solana'),
        isFalse,
      );
    },
  );

  test(
    'writer failure aborts export and invalid account cannot read records',
    () async {
      await insert('one');
      await expectLater(
        repository.exportCsv(
          scope: scope,
          writeChunk: (_) async => throw StateError('disk full'),
        ),
        throwsStateError,
      );
      const invalid = TransactionHistoryScope(
        userId: '',
        address: '0xabc',
        coinType: 'ETH',
        blockchainType: 'Ethereum',
      );
      expect((await repository.load(scope: invalid)).records, isEmpty);
      await expectLater(
        repository.exportCsv(scope: invalid, writeChunk: (_) async {}),
        throwsStateError,
      );
    },
  );
}
