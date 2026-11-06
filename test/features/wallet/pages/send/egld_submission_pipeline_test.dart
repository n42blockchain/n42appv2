import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/egld_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/egld_sender.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_memo.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';
import 'package:n42_wallet/features/wallet/services/egld_transaction_hash.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _Database extends AppDatabase {
  _Database(this.connection);
  final Database connection;
  @override
  Future<Database> get database async => connection;
}

class _Wallet extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coin) async => false;
}

class _Projection extends TransactionRecordItemProvider {
  final hashes = <String>[];
  @override
  void addUndoneTr(dynamic record, int type) =>
      hashes.add(record.txHash as String);
}

// Replay public WalletCore output; native signing and network are controlled.
class _Signer extends Trustdart {
  _Signer(this.transaction);
  final Map<String, dynamic> transaction;
  int signatures = 0;
  @override
  Future<Map> generateAddress(
    String coin,
    String path,
    String addressType, {
    String mnemonic = '',
    String passphrase = '',
    String pk = '',
    bool isImport = false,
    bool isTest = false,
  }) async => {'legacy': transaction['sender']};
  @override
  Future<String> signTransaction(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async {
    signatures++;
    return jsonEncode(transaction);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory directory;
  late Database connection;
  late _Database database;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('PonnamKarthik/fluttertoast'),
          (call) async => true,
        );
    directory = await Directory.systemTemp.createTemp('egld-pipeline-');
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
    database = _Database(connection);
  });
  tearDown(() async {
    await connection.close();
    await directory.delete(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('PonnamKarthik/fluttertoast'),
          null,
        );
  });
  final fixtures = jsonDecode(
    File('test/fixtures/multiversx/native_transactions.json')
        .readAsStringSync(),
  ) as List;
  for (final network in [0, 1]) {
    for (final terminal in ['success', 'fail']) {
      testWidgets(
        'EGLD page/sender/database reopen network=$network receipt=$terminal',
        (tester) async {
          final tx = Map<String, dynamic>.from(
            fixtures.firstWhere(
              (tx) => tx['chainID'] == (network == 0 ? '1' : 'T'),
            ) as Map,
          );
          final originalHash = EgldTransactionHash.compute(jsonEncode(tx));
          final signer = _Signer(tx);
          final projection = _Projection();
          var broadcasts = 0;
          final sender = EgldSender(
            trustdart: signer,
            ownerIdentity: () => 'fixture owner',
            readMnemonic: () => 'fixture',
            getAccount: (_) async => {
              'nonce': 0,
              'balance': '20000000000000000000',
            },
            getNetworkConfig: (_) async => {
              'code': 'successful',
              'data': {
                'config': {
                  'erd_chain_id': network == 0 ? '1' : 'T',
                  'erd_denomination': 18,
                  'erd_min_gas_limit': 50000,
                  'erd_min_gas_price': 1000000000,
                  'erd_gas_per_data_byte': 1500,
                  'erd_max_gas_per_transaction': 600000000,
                  'erd_min_transaction_version': 1,
                },
              },
            },
            broadcast: (_, signed) async {
              broadcasts++;
              final rows = await connection.query('TransationRecord');
              expect(rows, hasLength(1));
              expect(
                rows.single['txHash'],
                EgldTransactionHash.compute(signed),
              );
              expect(rows.single['memoDispatchPhase'], 'dispatching');
              throw TimeoutException('node may already have accepted');
            },
          );
          final coin = CoinModel()
            ..coin = {
              'coinType': 'EGLD',
              'blockchainType': 'MultiversX',
              'unit': 'EGLD',
              'miniName': 'EGLD',
              'decimals': 18,
              'isContract': false,
              'contract': '',
            }
            ..address = tx['sender'] as String
            ..isTest = network == 1;
          TransationRecordModel draft() => TransationRecordModel()
            ..coin = coin.coin
            ..coinMiniName = 'EGLD'
            ..from1 = tx['sender'] as String
            ..to1 = tx['receiver'] as String
            ..price = BigInt.parse(tx['value'] as String)
            ..gasPrice = BigInt.from(65000000000000)
            ..message = '你好🙂'
            ..isTest = network;
          Future<dynamic> openPage() async {
            await tester.pumpWidget(
              wrapForTest(
                WalletChainSendMemo(
                  coin,
                  key: UniqueKey(),
                  transactionSender: sender.send,
                  persistTransaction: (record) => database
                      .reserveMemoTransaction(record, trackDispatch: true),
                  markTransactionDispatch: database.markMemoTransactionDispatch,
                  releaseUnsubmittedTransaction:
                      database.releaseUnsubmittedMemoTransaction,
                ),
                overrides: [
                  wapBridgeProvider.overrideWith((ref) => _Wallet()),
                  tripBridgeProvider.overrideWith((ref) => projection),
                ],
              ),
            );
            await tester.pumpAndSettle();
            return tester.state(find.byType(WalletChainSendMemo));
          }

          final dynamic first = await openPage();
          await tester.runAsync(() async => await first.signTx(draft()));
          await tester.pumpAndSettle();
          expect(broadcasts, 1);
          expect(projection.hashes, [originalHash]);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.runAsync(() async {
            await connection.close();
            connection = await databaseFactoryFfi.openDatabase(
              '${directory.path}/history.db',
            );
            database = _Database(connection);
          });
          final dynamic reopened = await openPage();
          await tester.runAsync(() async => await reopened.signTx(draft()));
          await tester.pumpAndSettle();
          expect(
            signer.signatures,
            2,
            reason: 'second attempt reaches the actual sender',
          );
          expect(
            broadcasts,
            1,
            reason: 'durable reservation prevents the second POST',
          );
          await tester.runAsync(() async {
            final rows = await connection.query('TransationRecord');
            expect(rows, hasLength(1));
            final restored = TransationRecordModel.fromMap(rows.single);
            dynamic response;
            final resolver = TransactionStateResolver(
              egldApi: EgldApi(get: (_) async => response),
            );
            expect(await resolver.resolveState(restored), -1);
            await expectLater(
              database.reserveMemoTransaction(draft()..txHash = 'ef' * 32),
              throwsA(isA<PendingMemoTransactionException>()),
            );
            response = {
              'txHash': originalHash,
              'sender': tx['sender'],
              'receiver': tx['receiver'],
              'value': tx['value'],
              'status': terminal,
              'miniBlockHash': 'cd' * 32,
              'timestamp': 123,
            };
            restored.state = await resolver.resolveState(restored);
            expect(restored.state, terminal == 'success' ? 1 : 2);
            expect(await database.updateTransationRecordTxhash(restored), 1);
            expect(
              await database.reserveMemoTransaction(
                draft()..txHash = 'ef' * 32,
              ),
              greaterThan(0),
            );
          });
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
