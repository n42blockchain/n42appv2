import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transaction/btc_tran_detail.dart';
import 'package:n42_wallet/features/wallet/models/transaction/common_response_item_model.dart';
import 'package:n42_wallet/features/wallet/models/transaction/sol_transaction_item.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info_sync.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/widget_test_helpers.dart';

const _walletAddress = '0xAbCdEf';

class _MemoryDatabase extends AppDatabase {
  final Database handle;

  _MemoryDatabase(this.handle);

  @override
  Future<Database> get database async => handle;
}

class _SyncHarness extends ConsumerStatefulWidget {
  final AppDatabase database;
  final CoinModel coin;

  const _SyncHarness({required this.database, required this.coin, super.key});

  @override
  ConsumerState<_SyncHarness> createState() => _SyncHarnessState();
}

class _SyncHarnessState extends ConsumerState<_SyncHarness>
    with WalletChainInfoSyncMixin<_SyncHarness> {
  @override
  AppDatabase get db => widget.database;

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

  @override
  CoinModel getCoinModel() => widget.coin;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

CoinModel _coin({
  String coinType = 'ETH',
  String blockchainType = 'Ethereum',
  String contract = '',
  bool isTest = false,
}) => CoinModel()
  ..coin = {
    'coinType': coinType,
    'blockchainType': blockchainType,
    'miniName': coinType,
    'unit': coinType,
    'decimals': 18,
    'chainId': 1,
    'chainId_test': 5,
    'isContract': contract.isNotEmpty,
    'contract': contract,
  }
  ..address = _walletAddress
  ..isTest = isTest;

TransationRecordModel _record(int i) => TransationRecordModel()
  ..address = _walletAddress
  ..coinMiniName = 'ETH'
  ..coin = {'coinType': 'ETH', 'decimals': 18}
  ..txHash = 'local-$i'
  ..txTime = i.toString().padLeft(2, '0');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database rawDatabase;
  late _MemoryDatabase database;

  setUp(() async {
    rawDatabase = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await rawDatabase.execute('''
      CREATE TABLE TransationRecord (
        trId INTEGER PRIMARY KEY AUTOINCREMENT,
        address TEXT, coinId INTEGER, from1 TEXT, to1 TEXT, price TEXT,
        txHash TEXT, state INTEGER, txTime TEXT, errorMessage TEXT,
        coinMiniName TEXT, contract TEXT, coin TEXT, isTest INTEGER,
        testnetUri TEXT, userUuid TEXT, walletIndex INTEGER, message TEXT
      )
    ''');
    await rawDatabase.execute('''
      CREATE TABLE BtcTransactionRecord (
        trId INTEGER PRIMARY KEY AUTOINCREMENT,
        address TEXT, to1 TEXT, price TEXT, gas TEXT, input TEXT,
        output TEXT, txHash TEXT, confirmations INTEGER, state INTEGER,
        txTime TEXT, errorMessage TEXT, coinMiniName TEXT, contract TEXT,
        coin TEXT, isTest INTEGER, testnetUri TEXT, userUuid TEXT,
        walletIndex INTEGER, gasPrice INTEGER
      )
    ''');
    database = _MemoryDatabase(rawDatabase);
  });

  tearDown(() async => rawDatabase.close());

  Future<GlobalKey<_SyncHarnessState>> mount(
    WidgetTester tester, {
    CoinModel? coin,
  }) async {
    final key = GlobalKey<_SyncHarnessState>();
    await tester.pumpWidget(
      wrapForTest(
        _SyncHarness(key: key, database: database, coin: coin ?? _coin()),
        overrides: [
          wapBridgeProvider.overrideWith(
            (ref) => WalletActionProvider()..walletIndex = 7,
          ),
        ],
      ),
    );
    return key;
  }

  testWidgets(
    'local history refreshes, paginates, and stops at the last page',
    (tester) async {
      await tester.runAsync(() async {
        for (var i = 0; i < 5; i++) {
          await database.insertTransationRecord(_record(i));
        }
      });
      final key = await mount(tester);
      final state = key.currentState!;

      await tester.runAsync(() => state.getTransactionData(Load.refresh));
      expect(state.page, 1);
      expect(state.transactionList, hasLength(2));
      expect(
        (state.transactionList.first as TransationRecordModel).txHash,
        'local-4',
      );
      expect(state.lastPage, isFalse);

      await tester.runAsync(() => state.getTransactionData(Load.nextPage));
      expect(state.page, 2);
      expect(state.transactionList, hasLength(4));
      expect(state.lastPage, isFalse);

      await tester.runAsync(() => state.getTransactionData(Load.nextPage));
      expect(state.page, 3);
      expect(state.transactionList, hasLength(5));
      expect(state.lastPage, isTrue);

      await tester.runAsync(() => state.getTransactionData(Load.nextPage));
      expect(state.page, 3);
      expect(state.transactionList, hasLength(5));

      await tester.runAsync(() => state.getTransactionData(Load.refresh));
      expect(state.page, 1);
      expect(state.transactionList, hasLength(2));
      expect(state.load, Load.finish);
    },
  );

  testWidgets('Ethereum sync inserts and updates normalized local records', (
    tester,
  ) async {
    final key = await mount(tester);
    final state = key.currentState!;
    final first = CommonResponseItemModel.fromJson({
      'hash': '0xOne',
      'from': '0xABCDEF',
      'to': '0xFEDCBA',
      'value': '1000000000000000000',
      'gas': '21000',
      'gasPrice': '9',
      'timeStamp': '1700000000',
      'txreceipt_status': '0x1',
      'input': '0x4869',
    });

    List<TransationRecordModel> matches = [];
    await tester.runAsync(() async {
      await state.getTransactionDataNetworkEth([first]);
      matches = await database.selectTransationRecordTxHash(
        '0xOne',
        _walletAddress,
      );
    });
    expect(matches, hasLength(1));
    expect(matches.single.from1, '0xabcdef');
    expect(matches.single.to1, '0xfedcba');
    expect(matches.single.price, BigInt.parse('1000000000000000000'));
    expect(matches.single.state, 1);
    expect(matches.single.message, 'Hi');
    expect(matches.single.walletIndex, 7);

    final updated = CommonResponseItemModel.fromJson({
      'hash': '0xOne',
      'from': '0xABCDEF',
      'to': '0x123456',
      'value': '2000000000000000000',
      'gas': '22000',
      'gasPrice': '10',
      'timeStamp': '1700000001',
      'txreceipt_status': '0x0',
      'input': '0xzz',
    });
    await tester.runAsync(() async {
      await state.getTransactionDataNetworkEth([updated]);
      matches = await database.selectTransationRecordTxHash(
        '0xOne',
        _walletAddress,
      );
    });
    expect(matches, hasLength(1));
    expect(matches.single.to1, '0x123456');
    expect(matches.single.price, BigInt.parse('2000000000000000000'));
    expect(matches.single.state, 2);
    expect(matches.single.txTime, '1700000001');
    expect(matches.single.message, isEmpty);
  });

  testWidgets(
    'TRON sync ignores other token contracts and stores matching ones',
    (tester) async {
      final token = _coin(
        coinType: 'TRX',
        blockchainType: 'Tron',
        contract: '0xToken',
      );
      final key = await mount(tester, coin: token);
      CommonResponseItemModel item(String hash, String contract) =>
          CommonResponseItemModel.fromJson({
            'hash': hash,
            'from': 'TFrom',
            'to': 'TTo',
            'value': '42',
            'gas': '1',
            'gasPrice': '2',
            'timeStamp': '1700000000',
            'contractAddress': contract,
            'status': 'success',
          });

      List<TransationRecordModel> records = [];
      await tester.runAsync(() async {
        await key.currentState!.getTransactionDataNetworkTrx([
          item('wrong-contract', '0xOther'),
          item('matching-contract', '0xtoken'),
        ]);
        records = await database.selectTransationRecordMiniName(
          _walletAddress,
          'TRX',
          0,
          contract: '0xToken',
        );
      });
      expect(records, hasLength(1));
      expect(records.single.txHash, 'matching-contract');
      expect(records.single.state, 1);
    },
  );

  testWidgets(
    'Solana sync inserts transfers and refreshes changed timestamps',
    (tester) async {
      final coin = _coin(coinType: 'SOL', blockchainType: 'Solana');
      final key = await mount(tester, coin: coin);
      final item = SOLTransactionItem(
        'id',
        'SOURCE',
        'DESTINATION',
        5000,
        1700000000,
        4,
        'sol-hash',
        'Success',
        500,
        9,
        1,
      );

      List<TransationRecordModel> records = [];
      await tester.runAsync(() async {
        await key.currentState!.getTransactionDataNetworkSol([item]);
        records = await database.selectTransationRecordTxHash(
          'sol-hash',
          _walletAddress,
        );
      });
      expect(records, hasLength(1));
      expect(records.single.from1, 'source');
      expect(records.single.to1, 'destination');
      expect(records.single.price, BigInt.from(5000));
      expect(records.single.state, 1);

      await tester.runAsync(() async {
        await key.currentState!.getTransactionDataNetworkSol([
          SOLTransactionItem(
            'id',
            'SOURCE',
            'DESTINATION',
            5000,
            1700000001,
            4,
            'sol-hash',
            'Success',
            500,
            9,
            1,
          ),
        ]);
        records = await database.selectTransationRecordTxHash(
          'sol-hash',
          _walletAddress,
        );
      });
      expect(records.single.txTime, '1700000001');
    },
  );

  testWidgets('Bitcoin sync persists confirmations and wallet net output', (
    tester,
  ) async {
    final coin = _coin(coinType: 'BTC', blockchainType: 'Bitcoin');
    final key = await mount(tester, coin: coin);
    final detail = BtcTranDetail(
      'block-hash',
      4,
      'btc-hash',
      [_walletAddress],
      80,
      3,
      '2026-09-20T12:00:00Z',
      6,
      [
        Input('prev-hash', 0, 'script', 100, [_walletAddress]),
      ],
      [
        Output(70, 'change', [_walletAddress]),
        Output(10, 'recipient', ['external']),
      ],
    );

    List<BtcTransactionRecodeModel> matches = [];
    await tester.runAsync(() async {
      await key.currentState!.getTransactionDataNetworkBtc([detail]);
      matches = await database.selectBtcTransationRecordTxHash('btc-hash');
    });

    expect(matches, hasLength(1));
    expect(matches.single.confirmations, 6);
    expect(matches.single.state, 1);
    expect(matches.single.price, 10);
    expect(matches.single.gasPrice, 3);
    expect(matches.single.walletIndex, 7);
  });
}
