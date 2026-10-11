import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _Database extends AppDatabase {
  _Database(this.connection);
  final Database connection;
  @override
  Future<Database> get database async => connection;
}

class _Signer extends Trustdart {
  @override
  Future<String> signTransaction(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async => 'f8${'0' * 100}';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  test('saved pre-broadcast hash survives database reopen and drives receipt recovery', () async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = previous);
    await S.load(const Locale('en'));
    final directory = await Directory.systemTemp.createTemp(
      'n42-broadcast-qa-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final path = '${directory.path}/transactions.db';
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
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final calls = <String>[];
    dynamic receipt;
    server.listen((request) async {
      final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
      final method = body['method'] as String;
      calls.add(method);
      if (method == 'eth_sendRawTransaction') {
        // Node accepted the bytes, but the client never gets the response.
        final socket = await request.response.detachSocket(writeHeaders: false);
        socket.destroy();
        return;
      }
      final result = switch (method) {
        'eth_chainId' => '0x1',
        'eth_getBalance' => '0x100000000000000000',
        'eth_gasPrice' => '0x1',
        'eth_estimateGas' => '0x5208',
        'eth_getTransactionReceipt' => receipt,
        _ => '0x0',
      };
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({'jsonrpc': '2.0', 'id': body['id'], 'result': result}),
      );
      await request.response.close();
    });
    final record = TransationRecordModel()
      ..userUuid = 'qa-alice'
      ..address = '0x${'1' * 40}'
      ..from1 = '0x${'1' * 40}'
      ..to1 = '0x${'2' * 40}'
      ..price = BigInt.one
      ..coinMiniName = 'ETH'
      ..coin = {
        'coinType': 'ETH',
        'blockchainType': 'Ethereum',
        'chainId': 1,
        'decimals': 18,
        'service': 'http://127.0.0.1:${server.port}',
      };
    final result = await EvmSender(trustdart: _Signer()).send(
      SendParams(
        coinType: 'ETH',
        fromAddress: record.from1,
        toAddress: record.to1,
        amount: 0,
        decimals: 18,
        path: '',
        privateKey: 'fixture-only',
        valueWeiOverride: record.price,
        nonceOverride: BigInt.zero,
        chainConfig: record.coin,
        beforeBroadcast: (hash) async {
          record.txHash = hash;
          record.trId = await database.insertTransationRecord(record);
        },
      ),
    );
    expect(result.success, isFalse);
    expect(result.txHash, record.txHash);
    expect(calls.where((m) => m == 'eth_sendRawTransaction'), hasLength(1));
    await connection.close();
    connection = await databaseFactoryFfi.openDatabase(path);
    database = _Database(connection);
    final pending = await database.selectTransationRecordUnDone('qa-alice');
    expect(pending, hasLength(1));
    expect(pending.single.txHash, result.txHash);
    expect(await database.selectTransationRecordUnDone('qa-bob'), isEmpty);
    final resolver = TransactionStateResolver();
    expect(await resolver.resolveState(pending.single), 0);
    receipt = {'status': '0x1', 'transactionHash': result.txHash};
    expect(await resolver.resolveState(pending.single), 1);
    receipt = {'status': '0x0', 'transactionHash': result.txHash};
    expect(await resolver.resolveState(pending.single), 2);
    receipt = {'status': '0x1', 'transactionHash': 'foreign'};
    expect(await resolver.resolveState(pending.single), -1);
    receipt = {'status': 'unknown'};
    expect(await resolver.resolveState(pending.single), -1);
    expect(calls.where((m) => m == 'eth_sendRawTransaction'), hasLength(1));
    final saved = await connection.query('TransationRecord');
    expect(saved.single.keys, isNot(contains('privateKey')));
    expect(saved.single.keys, isNot(contains('signedTx')));
  });
}
