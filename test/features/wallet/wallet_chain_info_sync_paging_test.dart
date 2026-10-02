import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transaction/btc_tran_detail.dart';
import 'package:n42_wallet/features/wallet/models/transaction/common_response_item_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info_sync.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _TestDatabase extends AppDatabase {
  _TestDatabase(this.db);

  final Database db;

  @override
  Future<Database> get database async => db;
}

class _SyncHarness extends ConsumerStatefulWidget {
  const _SyncHarness({required this.db, required this.coin, super.key});

  final AppDatabase db;
  final CoinModel coin;

  @override
  ConsumerState<_SyncHarness> createState() => _SyncHarnessState();
}

class _SyncHarnessState extends ConsumerState<_SyncHarness>
    with WalletChainInfoSyncMixin<_SyncHarness> {
  @override
  AppDatabase get db => widget.db;

  @override
  int pageSize = 2;

  @override
  int page = 1;

  @override
  bool lastPage = false;

  @override
  final List<dynamic> transactionList = [];

  @override
  Load load = Load.finish;

  CoinModel get coin => widget.coin;

  @override
  CoinModel getCoinModel() => coin;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;

  late Database rawDb;
  late _TestDatabase db;

  setUp(() async {
    rawDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await rawDb.execute('''
      CREATE TABLE TransationRecord (
        trId INTEGER PRIMARY KEY AUTOINCREMENT,
        address TEXT, coinId INTEGER, from1 TEXT, to1 TEXT, price TEXT,
        txHash TEXT, state INTEGER, txTime TEXT, errorMessage TEXT,
        coinMiniName TEXT, contract TEXT, coin TEXT, isTest INTEGER,
        testnetUri TEXT, userUuid TEXT, walletIndex INTEGER, message TEXT
      )
    ''');
    await rawDb.execute('''
      CREATE TABLE BtcTransactionRecord (
        trId INTEGER PRIMARY KEY AUTOINCREMENT,
        address TEXT, to1 TEXT, price TEXT, gas TEXT, input TEXT, output TEXT,
        txHash TEXT, confirmations INTEGER, state INTEGER, txTime TEXT,
        errorMessage TEXT, coinMiniName TEXT, contract TEXT, coin TEXT,
        isTest INTEGER, testnetUri TEXT, userUuid TEXT, walletIndex INTEGER,
        gasPrice INTEGER
      )
    ''');
    db = _TestDatabase(rawDb);
  });

  tearDown(() async => rawDb.close());

  Future<void> addRecord(String hash, String time) async {
    await db.insertTransationRecord(
      TransationRecordModel()
        ..address = '0xabc'
        ..coinMiniName = 'ETH'
        ..coin = {'coinType': 'ETH', 'decimals': 18}
        ..txHash = hash
        ..txTime = time,
    );
  }

  CoinModel coinFor(
    String coinType,
    String blockchainType, {
    String contract = '',
  }) => CoinModel()
    ..address = '0xabc'
    ..coin = {
      'coinType': coinType,
      'blockchainType': blockchainType,
      'contract': contract,
      'decimals': 18,
      'chainId': 1,
    };

  Future<_SyncHarnessState> mountHarness(
    WidgetTester tester, {
    required CoinModel coin,
  }) async {
    final key = GlobalKey<_SyncHarnessState>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wapBridgeProvider.overrideWith((ref) => WalletActionProvider()),
        ],
        child: _SyncHarness(key: key, db: db, coin: coin),
      ),
    );
    return key.currentState!;
  }

  testWidgets('refresh replaces rows and next page stops after a short page', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await addRecord('newest', '300');
      await addRecord('middle', '200');
      await addRecord('oldest', '100');
    });

    final state = await mountHarness(tester, coin: coinFor('ETH', 'Ethereum'));

    await tester.runAsync(() => state.getTransactionData(Load.refresh));
    expect(state.transactionList.map((tx) => tx.txHash), ['newest', 'middle']);
    expect(state.page, 1);
    expect(state.lastPage, isFalse);
    expect(state.load, Load.finish);

    await tester.runAsync(() => state.getTransactionData(Load.nextPage));
    expect(state.transactionList.map((tx) => tx.txHash), [
      'newest',
      'middle',
      'oldest',
    ]);
    expect(state.page, 2);
    expect(state.lastPage, isTrue);

    await tester.runAsync(() => state.getTransactionData(Load.nextPage));
    expect(state.page, 2, reason: 'known end must not advance the page');
    expect(state.transactionList, hasLength(3));

    await tester.runAsync(() async {
      await addRecord('latest', '400');
      await state.getTransactionData(Load.refresh);
    });
    expect(state.transactionList.map((tx) => tx.txHash), ['latest', 'newest']);
    expect(state.page, 1);
    expect(state.lastPage, isFalse);
  });

  testWidgets(
    'generic sync inserts, updates timestamps, and skips invalid or unchanged rows',
    (tester) async {
      final state = await mountHarness(tester, coin: coinFor('APT', 'Aptos'));
      final existing = TransationRecordModel()
        ..address = '0xabc'
        ..coinMiniName = 'APT'
        ..coin = {'coinType': 'APT', 'decimals': 18}
        ..txHash = 'existing'
        ..txTime = '10';
      await tester.runAsync(() => db.insertTransationRecord(existing));

      CommonResponseItemModel item(String? hash, String timestamp) =>
          CommonResponseItemModel()
            ..hash = hash
            ..timeStamp = timestamp
            ..value = '1'
            ..from = 'FROM'
            ..to = 'TO';

      await tester.runAsync(() async {
        await state.getTransactionDataNetworkGeneric([
          item('inserted', '30'),
          item('existing', '20'),
          item('', '99'),
        ]);
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      var rows = (await tester.runAsync(
        () => db.selectTransationRecordTxHash('inserted', '0xabc'),
      ))!;
      expect(rows, hasLength(1));
      expect(rows.single.txTime, '30');
      rows = (await tester.runAsync(
        () => db.selectTransationRecordTxHash('existing', '0xabc'),
      ))!;
      expect(rows.single.txTime, '20');
      expect(
        state.transactionList.map((tx) => tx.txHash),
        contains('inserted'),
      );

      await tester.runAsync(() async {
        await state.getTransactionDataNetworkGeneric([item('existing', '20')]);
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      rows = (await tester.runAsync(
        () => db.selectTransationRecordTxHash('existing', '0xabc'),
      ))!;
      expect(rows.single.txTime, '20');
    },
  );

  testWidgets('ETH sync inserts decoded message and updates existing fields', (
    tester,
  ) async {
    final state = await mountHarness(tester, coin: coinFor('ETH', 'Ethereum'));
    CommonResponseItemModel item(
      String hash, {
      String? input,
      String? to,
      String? status,
    }) => CommonResponseItemModel()
      ..hash = hash
      ..timeStamp = '100'
      ..value = '1000000000000000000'
      ..from = '0xFROM'
      ..to = to ?? '0xTO'
      ..gas = '21000'
      ..gasPrice = '7'
      ..nonce = '3'
      ..input = input
      ..txreceiptStatus = status;

    await tester.runAsync(() async {
      await state.getTransactionDataNetworkEth([
        item('created', input: '0x6869', status: 'success'),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    var rows = (await tester.runAsync(
      () => db.selectTransationRecordTxHash('created', '0xabc'),
    ))!;
    expect(rows.single.message, 'hi');
    expect(rows.single.state, 1);
    expect(rows.single.price, BigInt.parse('1000000000000000000'));

    await tester.runAsync(() async {
      await state.getTransactionDataNetworkEth([
        item('created', to: '0xNEW', status: 'failed'),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    rows = (await tester.runAsync(
      () => db.selectTransationRecordTxHash('created', '0xabc'),
    ))!;
    expect(rows.single.to1, '0xnew');
    expect(rows.single.state, 2);
  });

  testWidgets('TRX sync filters contract mismatches before inserting', (
    tester,
  ) async {
    final state = await mountHarness(
      tester,
      coin: coinFor('TRX', 'Tron', contract: 'TContract'),
    );
    CommonResponseItemModel item(String hash, String? contract) =>
        CommonResponseItemModel()
          ..hash = hash
          ..timeStamp = '50'
          ..value = '1'
          ..contractAddress = contract;

    await tester.runAsync(() async {
      await state.getTransactionDataNetworkTrx([
        item('matching', 'tcontract'),
        item('mismatch', 'other'),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    expect(
      await tester.runAsync(
        () => db.selectTransationRecordTxHash('matching', '0xabc'),
      ),
      hasLength(1),
    );
    expect(
      await tester.runAsync(
        () => db.selectTransationRecordTxHash('mismatch', '0xabc'),
      ),
      isEmpty,
    );
  });

  testWidgets('BTC sync inserts and updates confirmations, fee, and outputs', (
    tester,
  ) async {
    final state = await mountHarness(tester, coin: coinFor('BTC', 'Bitcoin'));
    BtcTranDetail detail(int confirmations, int fees) => BtcTranDetail(
      'block',
      1,
      'btc-hash',
      const ['0xabc'],
      200,
      fees,
      '2026-01-01T00:00:00Z',
      confirmations,
      [
        Input('prev', 0, null, 300, const ['0xabc']),
      ],
      [
        Output(100, null, const ['0xabc']),
        Output(200, null, const ['external']),
      ],
    );

    await tester.runAsync(() async {
      await state.getTransactionDataNetworkBtc([detail(1, 5)]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    var rows = (await tester.runAsync(
      () => db.selectBtcTransationRecordTxHash('btc-hash'),
    ))!;
    expect(rows, hasLength(1));
    expect(rows.single.confirmations, 1);
    expect(rows.single.gasPrice, 5);
    expect(rows.single.price, 200);
    expect(rows.single.inputModels, hasLength(1));

    await tester.runAsync(() async {
      await state.getTransactionDataNetworkBtc([detail(6, 9)]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    rows = (await tester.runAsync(
      () => db.selectBtcTransationRecordTxHash('btc-hash'),
    ))!;
    expect(rows.single.confirmations, 6);
    expect(rows.single.state, 1);
    expect(rows.single.gasPrice, 9);

    await tester.runAsync(() async {
      await state.getTransactionDataNetworkBtc([detail(6, 9)]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    rows = (await tester.runAsync(
      () => db.selectBtcTransationRecordTxHash('btc-hash'),
    ))!;
    expect(rows.single.confirmations, 6);
  });

  testWidgets(
    'local sync always releases loading state after database errors',
    (tester) async {
      final state = await mountHarness(
        tester,
        coin: coinFor('ETH', 'Ethereum'),
      );
      await tester.runAsync(() => rawDb.close());

      var didThrow = false;
      await tester.runAsync(() async {
        try {
          await state.getTransactionData(Load.refresh);
        } catch (_) {
          didThrow = true;
        }
      });
      expect(didThrow, isTrue);
      expect(state.load, Load.finish);
    },
  );
}
