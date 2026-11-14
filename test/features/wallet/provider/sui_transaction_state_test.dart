import 'package:fast_base58/fast_base58.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';

/// Response envelopes follow the Sui JSON-RPC reference for
/// `sui_getTransactionBlock` (showInput + showEffects) and its error shape for
/// an unknown digest.

final _digest = Base58Encode(List<int>.generate(32, (i) => i + 1));
final _sender = '0x${'a1' * 32}';

Map<String, dynamic> _block({
  String? digest,
  String? sender,
  Map<String, dynamic> status = const {'status': 'success'},
  Object? checkpoint = '1934',
  String? effectsDigest,
}) => {
  'digest': digest ?? _digest,
  'transaction': {
    'data': {
      'messageVersion': 'v1',
      'transaction': {
        'kind': 'ProgrammableTransaction',
        'inputs': [
          {'type': 'pure', 'valueType': 'u64', 'value': '1000'},
          {'type': 'pure', 'valueType': 'address', 'value': '0x${'b2' * 32}'},
        ],
        'transactions': [
          {
            'SplitCoins': [
              'GasCoin',
              [
                {'Input': 0},
              ],
            ],
          },
          {
            'TransferObjects': [
              [
                {'Result': 0},
              ],
              {'Input': 1},
            ],
          },
        ],
      },
      'sender': sender ?? _sender,
      'gasData': {
        'payment': [
          {
            'objectId': '0x${'c3' * 32}',
            'version': 2,
            'digest': Base58Encode(List<int>.filled(32, 9)),
          },
        ],
        'owner': sender ?? _sender,
        'price': '1000',
        'budget': '2000000',
      },
    },
    'txSignatures': ['AAAA'],
  },
  'effects': {
    'messageVersion': 'v1',
    'status': status,
    'executedEpoch': '42',
    'gasUsed': {
      'computationCost': '1000000',
      'storageCost': '1976000',
      'storageRebate': '978120',
      'nonRefundableStorageFee': '9880',
    },
    'transactionDigest': effectsDigest ?? digest ?? _digest,
    'gasObject': {
      'owner': {'AddressOwner': sender ?? _sender},
      'reference': {
        'objectId': '0x${'c3' * 32}',
        'version': 3,
        'digest': Base58Encode(List<int>.filled(32, 8)),
      },
    },
  },
  'timestampMs': '1700000000000',
  'checkpoint': ?checkpoint,
};

Map<String, dynamic> _notFound(String digest) => {
  'jsonrpc': '2.0',
  'error': {
    'code': -32602,
    'message':
        'Could not find the referenced transaction [TransactionDigest($digest)].',
  },
  'id': 1,
};

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

Map<String, dynamic> _ok(Map<String, dynamic> result) => {
  'jsonrpc': '2.0',
  'result': result,
  'id': 1,
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
      final (_, body) = rpc.requests.single;
      expect(body['method'], 'sui_getTransactionBlock');
      expect(body['params'][0], _digest);
      expect(body['params'][1]['showEffects'], true);
      expect(body['params'][1]['showInput'], true);
    });
  }

  test('checkpointed failure fails with the chain error', () async {
    rpc.reply = () =>
        _ok(_block(status: {'status': 'failure', 'error': 'InsufficientGas'}));
    expect(await resolver.resolveStateWithReason(_record()), (
      2,
      'Sui transaction failed: InsufficientGas',
    ));
    expect(await resolver.resolveState(_record()), 2);
  });

  test('failure without an error string still fails', () async {
    rpc.reply = () => _ok(_block(status: {'status': 'failure'}));
    expect(await resolver.resolveStateWithReason(_record()), (
      2,
      'Sui transaction failed',
    ));
  });

  test('effects without a checkpoint stay pending', () async {
    for (final status in [
      {'status': 'success'},
      {'status': 'failure', 'error': 'InsufficientGas'},
    ]) {
      rpc.reply = () => _ok(_block(status: status, checkpoint: null));
      expect(await resolver.resolveStateWithReason(_record()), (0, null));
      // The reference encodes checkpoints as decimal strings; anything else
      // is not taken as proof of finality.
      rpc.reply = () => _ok(_block(status: status, checkpoint: 1934));
      expect(await resolver.resolveStateWithReason(_record()), (0, null));
    }
  });

  test('unknown digest is unknown, never failed', () async {
    rpc.reply = () => _notFound(_digest);
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
      _block(status: {'status': 'mystery'}),
      {..._block(), 'effects': null},
      {..._block(), 'transaction': null},
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

  group('history provider', () {
    test('a chain failure is saved with its reason', () async {
      rpc.reply = () => _ok(
        _block(status: {'status': 'failure', 'error': 'InsufficientGas'}),
      );
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
