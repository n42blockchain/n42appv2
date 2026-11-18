import 'dart:convert';
import 'dart:io';

import 'package:fast_base58/fast_base58.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';

/// Reply shapes are the Sui GraphQL `transaction(digest:)` responses; the
/// fixture tests replay real mainnet/testnet replies captured from
/// graphql.{mainnet,testnet}.sui.io (test/fixtures/sui_graphql).

final _digest = Base58Encode(List<int>.generate(32, (i) => i + 1));
final _sender = '0x${'a1' * 32}';

Map<String, dynamic> _block({
  String? digest,
  String? sender,
  String status = 'SUCCESS',
  String? error,
  Object? checkpoint = 345134411,
  String? effectsDigest,
}) => {
  'digest': digest ?? _digest,
  'sender': {'address': sender ?? _sender},
  'effects': {
    'digest': effectsDigest ?? digest ?? _digest,
    'status': status,
    'executionError': error == null ? null : {'message': error},
    'checkpoint': checkpoint == null ? null : {'sequenceNumber': checkpoint},
  },
};

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/sui_graphql/$name').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _notFound(String digest) => _fixture('tx_not_found.json');

class _Rpc {
  Map<String, dynamic> Function() reply = () => {};
  Object? throwing;
  final requests = <(String, Map<String, dynamic>)>[];
  final networks = <bool>[];

  SuiApi api(bool isTest) {
    networks.add(isTest);
    return SuiApi(
      isTest: isTest,
      post: (url, body) async {
        requests.add((url, body));
        if (throwing != null) throw throwing!;
        return reply();
      },
    );
  }
}

Map<String, dynamic> _ok(Map<String, dynamic>? transaction) => {
  'data': {'transaction': transaction},
};

TransationRecordModel _record({int network = 0, String? from}) =>
    TransationRecordModel()
      ..trId = 5
      ..userUuid = 'alice'
      ..coin = {'blockchainType': 'Sui', 'coinType': 'SUI'}
      ..coinMiniName = 'SUI'
      ..from1 = from ?? _sender
      ..to1 = '0x${'b2' * 32}'
      ..txHash = _digest
      ..isTest = network;

class _Connection implements Database {
  final saved = <Map<String, Object?>>[];
  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    saved.add(values);
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Db extends AppDatabase {
  final connection = _Connection();
  List<Map<String, Object?>> get saved => connection.saved;
  @override
  Future<Database> get database async => connection;
}

void main() {
  late _Rpc rpc;
  late TransactionStateResolver resolver;
  setUp(() {
    rpc = _Rpc();
    resolver = TransactionStateResolver(suiApiFactory: rpc.api);
  });

  for (final network in [0, 1]) {
    test('checkpointed success confirms on network $network', () async {
      rpc.reply = () => _ok(_block());
      expect(await resolver.resolveState(_record(network: network)), 1);
      expect(rpc.networks, [network == 1]);
      final (url, body) = rpc.requests.single;
      expect(url, contains(network == 1 ? 'testnet' : 'mainnet'));
      expect(body['query'], SuiApi.transactionQuery);
      expect(body['variables'], {'digest': _digest});
    });
  }

  test('checkpointed failure fails with the chain error', () async {
    rpc.reply = () => _ok(_block(status: 'FAILURE', error: 'InsufficientGas'));
    expect(await resolver.resolveStateWithReason(_record()), (
      2,
      'Sui transaction failed: InsufficientGas',
    ));
    expect(await resolver.resolveState(_record()), 2);
  });

  test('failure without an error string still fails', () async {
    rpc.reply = () => _ok(_block(status: 'FAILURE'));
    expect(await resolver.resolveStateWithReason(_record()), (
      2,
      'Sui transaction failed',
    ));
  });

  test('effects without a checkpoint stay pending', () async {
    for (final status in ['SUCCESS', 'FAILURE']) {
      rpc.reply = () => _ok(_block(status: status, checkpoint: null));
      expect(await resolver.resolveStateWithReason(_record()), (0, null));
      // Only a non-negative sequence number is proof of finality.
      for (final bad in [-1, 1.5, 'x']) {
        rpc.reply = () => _ok(_block(status: status, checkpoint: bad));
        expect(await resolver.resolveStateWithReason(_record()), (0, null));
      }
    }
  });

  test('unknown digest is unknown, never failed', () async {
    rpc.reply = () => _notFound(_digest);
    expect(await resolver.resolveStateWithReason(_record()), (-1, null));
  });

  test('GraphQL errors are unknown', () async {
    rpc.reply = () => _fixture('tx_bad_digest.json');
    expect(await resolver.resolveStateWithReason(_record()), (-1, null));
  });

  test('transport failure is unknown', () async {
    rpc.throwing = Exception('connection reset');
    expect(await resolver.resolveStateWithReason(_record()), (-1, null));
  });

  test('replies about another transaction or sender are ignored', () async {
    final other = Base58Encode(List<int>.filled(32, 4));
    for (final block in [
      _block(digest: other),
      _block(effectsDigest: other),
      _block(sender: '0x${'d4' * 32}'),
      _block(status: 'mystery'),
      _block(status: 'success'),
      {..._block(), 'effects': null},
      {..._block(), 'sender': null},
    ]) {
      rpc.reply = () => _ok(block);
      expect(await resolver.resolveStateWithReason(_record()), (-1, null));
    }
  });

  test('records that cannot name a Sui digest are not queried', () async {
    rpc.reply = () => _ok(_block());
    for (final record in [
      _record()..txHash = '0x${'ab' * 32}',
      _record()..txHash = Base58Encode(List<int>.filled(31, 1)),
      _record()..txHash = '',
      _record(from: 'not-an-address'),
      _record(network: 2),
      _record()..contract = '0x2::coin::Coin',
    ]) {
      expect(await resolver.resolveStateWithReason(record), (-1, null));
    }
    expect(rpc.requests, isEmpty);
  });

  test('short-form sender addresses compare by value', () async {
    rpc.reply = () => _ok(_block(sender: '0x${'0' * 63}5'));
    expect(await resolver.resolveState(_record(from: '0x5')), 1);
    rpc.reply = () => _ok(_block(sender: '0x${'A1' * 32}'));
    expect(await resolver.resolveState(_record()), 1);
  });

  test('resolveState no longer leaves Sui pending by default', () async {
    rpc.reply = () => _ok(_block());
    final legacy = _record()..state = 0;
    expect(await resolver.resolveState(legacy), 1);
  });

  group('real GraphQL replies', () {
    TransationRecordModel fromFixture(Map<String, dynamic> reply, int net) {
      final tx = reply['data']['transaction'] as Map;
      return _record(network: net, from: tx['sender']['address'] as String)
        ..txHash = tx['digest'] as String;
    }

    test('mainnet success confirms', () async {
      final reply = _fixture('tx_success_mainnet.json');
      rpc.reply = () => reply;
      expect(await resolver.resolveStateWithReason(fromFixture(reply, 0)), (
        1,
        null,
      ));
    });

    for (final (name, net) in [
      ('tx_failure_mainnet.json', 0),
      ('tx_failure_testnet.json', 1),
    ]) {
      test('$name fails with the execution error', () async {
        final reply = _fixture(name);
        rpc.reply = () => reply;
        final message =
            reply['data']['transaction']['effects']['executionError']['message'];
        expect(await resolver.resolveStateWithReason(fromFixture(reply, net)), (
          2,
          'Sui transaction failed: $message',
        ));
      });
    }

    test('success reply checked against another sender is ignored', () async {
      final reply = _fixture('tx_success_mainnet.json');
      rpc.reply = () => reply;
      final record = fromFixture(reply, 0)..from1 = _sender;
      expect(await resolver.resolveStateWithReason(record), (-1, null));
    });

    test('not found stays unknown', () async {
      rpc.reply = () => _fixture('tx_not_found.json');
      expect(await resolver.resolveStateWithReason(_record()), (-1, null));
    });
  });

  group('history provider', () {
    test('a chain failure is saved with its reason', () async {
      rpc.reply = () =>
          _ok(_block(status: 'FAILURE', error: 'InsufficientGas'));
      final db = _Db();
      final provider = TransactionRecordItemProvider(
        database: db,
        resolver: resolver,
        userUuid: () => 'alice',
      );
      addTearDown(provider.dispose);
      final result = await provider.checkUndoneTrReturn(_record());
      expect(result?.state, 2);
      expect(result?.errorMessage, 'Sui transaction failed: InsufficientGas');
      expect(db.saved.single['state'], 2);
      expect(db.saved.single['errorMessage'], result?.errorMessage);
    });

    test('success is saved without inventing an error', () async {
      rpc.reply = () => _ok(_block());
      final db = _Db();
      final provider = TransactionRecordItemProvider(
        database: db,
        resolver: resolver,
        userUuid: () => 'alice',
      );
      addTearDown(provider.dispose);
      final result = await provider.checkUndoneTrReturn(_record());
      expect(result?.state, 1);
      expect(db.saved.single['errorMessage'], '');
    });

    test('an unknown digest writes nothing', () async {
      rpc.reply = () => _notFound(_digest);
      final db = _Db();
      final provider = TransactionRecordItemProvider(
        database: db,
        resolver: resolver,
        userUuid: () => 'alice',
      );
      addTearDown(provider.dispose);
      expect(await provider.checkUndoneTrReturn(_record()), isNull);
      expect(db.saved, isEmpty);
    });
  });
}
