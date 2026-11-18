import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fast_base58/fast_base58.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/network/base_http.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ada_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/egld_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xlm_api.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';
import 'package:n42_wallet/features/wallet/utils/chain/memo_expiry_proof.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// A pending ADA/XLM/EGLD/NEAR record may only become failed when chain state
/// proves (twice, at an advancing chain point) that it can never land.
/// Everything else - transport errors, lagging indexers, missing proofs,
/// unfamiliar bodies - must leave it pending.

class _Xlm extends XlmApi {
  _Xlm(Future<HttpStatusResult> Function(String, Map<String, String>) lookup)
    : super(lookup: lookup);
  @override
  Future<MessageModel> getTransaction(
    String txHash, {
    bool isTest = false,
  }) async => MessageModel.error()..data = 'not found';
}

class _Ada extends AdaApi {
  _Ada(Future<HttpStatusResult> Function(String, Map<String, String>) lookup)
    : super(projectId: 'fixture', lookup: lookup);
  @override
  Future<MessageModel> getTransaction(
    String txHash, {
    bool isTest = false,
  }) async => MessageModel.error()..data = 'not found';
}

HttpStatusResult _ok(Object body) => HttpStatusResult(200, body);

TransationRecordModel _record(String chain, String type, String hash) =>
    TransationRecordModel()
      ..trId = 7
      ..coin = {'blockchainType': type, 'coinType': chain}
      ..coinMiniName = chain
      ..from1 = chain == 'NEAR' ? 'alice.near' : 'sender-$chain'
      ..to1 = 'receiver'
      ..price = BigInt.from(5)
      ..txHash = hash
      ..isTest = 0;

void main() {
  group('signed byte extraction', () {
    test('Stellar v1 envelope sequence', () {
      final bytes = BytesBuilder()
        ..add([0, 0, 0, 2, 0, 0, 0, 0])
        ..add(List.filled(32, 7))
        ..add([0, 0, 0, 100])
        ..add([0, 0, 0, 1, 0, 0, 0, 5]);
      expect(
        stellarEnvelopeSequence(base64Encode(bytes.toBytes())),
        (BigInt.one << 32) + BigInt.from(5),
      );
      expect(stellarEnvelopeSequence(base64Encode([0, 0, 0, 5])), isNull);
      expect(stellarEnvelopeSequence('not base64'), isNull);
    });

    test('Stellar v0 and muxed envelopes', () {
      final v0 = BytesBuilder()
        ..add([0, 0, 0, 0])
        ..add(List.filled(32, 1))
        ..add([0, 0, 0, 100])
        ..add([0, 0, 0, 0, 0, 0, 0, 9]);
      expect(
        stellarEnvelopeSequence(base64Encode(v0.toBytes())),
        BigInt.from(9),
      );
      final muxed = BytesBuilder()
        ..add([0, 0, 0, 2, 0, 0, 1, 0])
        ..add(List.filled(40, 1))
        ..add([0, 0, 0, 100])
        ..add([0, 0, 0, 0, 0, 0, 0, 11]);
      expect(
        stellarEnvelopeSequence(base64Encode(muxed.toBytes())),
        BigInt.from(11),
      );
    });

    test('Cardano TTL from the signed body', () {
      // [ {0: [[h'00..', 0]] (tag 258 set), 1: [], 2: 170000, 3: 123456789}, {}, true, null ]
      final hex = StringBuffer('84')
        ..write('a4')
        ..write('00d9010281825820${'00' * 32}00')
        ..write('0180')
        ..write('021a00029810')
        ..write('031a075bcd15')
        ..write('a0f5f6');
      expect(cardanoSignedTtl('0x$hex'), BigInt.from(123456789));
      expect(cardanoSignedTtl('0x84a3${'0080' * 1}021a00029810'), isNull);
      expect(cardanoSignedTtl('0xzz'), isNull);
    });

    test('NEAR nonce and reference block from the reference envelope', () {
      final fixture = jsonDecode(
        File('test/native/near_reference.json').readAsStringSync(),
      ) as Map;
      final fields = nearSignedNonceAndBlock(
        fixture['signedTransaction'] as String,
      );
      expect(fields?.$1, BigInt.from(4));
      expect(fields?.$2, Base58Encode(List.filled(32, 2)));
      expect(nearSignedNonceAndBlock('AQ=='), isNull);
    });

    test('foreign or malformed proofs are ignored', () {
      final proof = MemoExpiryProof.multiversx(nonce: BigInt.from(3));
      expect(MemoExpiryProof.decode(proof, 'EGLD')?['nonce'], '3');
      expect(MemoExpiryProof.decode(proof, 'XLM'), isNull);
      expect(MemoExpiryProof.decode('{', 'EGLD'), isNull);
      expect(MemoExpiryProof.decode('{"v":2,"chain":"EGLD"}', 'EGLD'), isNull);
    });
  });

  group('Stellar', () {
    final hash = 'ab' * 32;
    late int latest;
    late int elder;
    late String accountSequence;
    late HttpStatusResult tx;
    late bool transportDown;
    setUp(() {
      latest = 2000;
      elder = 100;
      accountSequence = '500';
      tx = const HttpStatusResult(404, {
        'type': 'https://stellar.org/horizon-errors/not_found',
        'status': 404,
      });
      transportDown = false;
    });
    TransactionStateResolver resolver() => TransactionStateResolver(
      xlmApi: _Xlm((url, _) async {
        if (transportDown) return const HttpStatusResult(null, null);
        if (url.endsWith('/transactions/$hash')) return tx;
        if (url.endsWith('/accounts/sender-XLM')) {
          return _ok({'account_id': 'sender-XLM', 'sequence': accountSequence});
        }
        if (url.endsWith('/')) {
          return _ok({
            'history_elder_ledger': elder,
            'history_latest_ledger': latest,
          });
        }
        return const HttpStatusResult(500, null);
      }),
    );
    TransationRecordModel record() => _record('XLM', 'Stellar', hash)
      ..memoExpiry = MemoExpiryProof.stellar(
        sequence: BigInt.from(500),
        ledger: 1000,
      );

    test(
      'consumed sequence and unknown hash fail after a second proof',
      () async {
        final r = resolver();
        final trm = record();
        expect(await r.resolveState(trm), -1);
        latest += 1;
        expect(await r.resolveState(trm), -1, reason: 'advance too small');
        latest += 2;
        expect(await r.resolveState(trm), 2);
      },
    );

    test('an interrupted proof starts over', () async {
      final r = resolver();
      final trm = record();
      expect(await r.resolveState(trm), -1);
      transportDown = true;
      latest += 5;
      expect(await r.resolveState(trm), -1);
      transportDown = false;
      latest += 5;
      expect(await r.resolveState(trm), -1);
      latest += 5;
      expect(await r.resolveState(trm), 2);
    });

    for (final (name, change) in <(String, void Function())>[
      ('sequence still usable', () => accountSequence = '499'),
      ('history pruned past signing ledger', () => elder = 1001),
      (
        'transaction lookup failed',
        () => tx = const HttpStatusResult(503, {'status': 503}),
      ),
      ('foreign 404 body', () => tx = const HttpStatusResult(404, '<html>')),
      ('transport down', () => transportDown = true),
    ]) {
      test('$name stays pending', () async {
        change();
        final r = resolver();
        final trm = record();
        for (var i = 0; i < 3; i++) {
          latest += 10;
          expect(await r.resolveState(trm), -1);
        }
      });
    }

    test('legacy record without proof stays pending', () async {
      final r = resolver();
      final trm = record()..memoExpiry = null;
      for (var i = 0; i < 3; i++) {
        latest += 10;
        expect(await r.resolveState(trm), -1);
      }
    });
  });

  group('Cardano', () {
    final hash = 'cd' * 32;
    final ttl = BigInt.from(5000);
    late int slot;
    late HttpStatusResult tx;
    setUp(() {
      slot = 5000 + TransactionStateResolver.cardanoStabilitySlots.toInt();
      tx = const HttpStatusResult(404, {
        'status_code': 404,
        'error': 'Not Found',
        'message': 'The requested component has not been found.',
      });
    });
    TransactionStateResolver resolver() => TransactionStateResolver(
      adaApi: _Ada((url, header) async {
        expect(header['project_id'], 'fixture');
        if (url.endsWith('/txs/$hash')) return tx;
        if (url.endsWith('/blocks/latest')) return _ok({'slot': slot});
        return const HttpStatusResult(500, null);
      }),
    );
    TransationRecordModel record() =>
        _record('ADA', 'Cardano', hash)
          ..memoExpiry = MemoExpiryProof.cardano(ttl: ttl);

    test('TTL past the stability window fails after a second proof', () async {
      final r = resolver();
      final trm = record();
      expect(await r.resolveState(trm), -1);
      slot += 60;
      expect(await r.resolveState(trm), 2);
    });

    test(
      'TTL passed but still inside the rollback window stays pending',
      () async {
        slot -= 1;
        final r = resolver();
        final trm = record();
        expect(await r.resolveState(trm), -1);
        expect(await r.resolveState(trm), -1);
      },
    );

    test('mempool full / rate limit responses stay pending', () async {
      tx = const HttpStatusResult(429, {'status_code': 429});
      final r = resolver();
      final trm = record();
      expect(await r.resolveState(trm), -1);
      slot += 100;
      expect(await r.resolveState(trm), -1);
    });
  });

  group('MultiversX', () {
    final hash = 'ef' * 32;
    late int meta;
    late int accountNonce;
    late HttpStatusResult tx;
    setUp(() {
      meta = 900;
      accountNonce = 12;
      tx = const HttpStatusResult(404, {
        'message': 'Transaction not found',
        'error': 'Not Found',
        'statusCode': 404,
      });
    });
    TransactionStateResolver resolver() => TransactionStateResolver(
      egldApi: EgldApi(
        get: (_) async => throw Exception('404'),
        lookup: (url) async {
          if (url.endsWith('/transactions/$hash')) return tx;
          if (url.endsWith('/accounts/sender-EGLD')) {
            return _ok({'address': 'sender-EGLD', 'nonce': accountNonce});
          }
          if (url.contains('/blocks?shard=4294967295')) {
            return _ok([
              {'nonce': meta, 'shard': 4294967295},
            ]);
          }
          return const HttpStatusResult(500, null);
        },
      ),
    );
    TransationRecordModel record() =>
        _record('EGLD', 'MultiversX', hash)
          ..memoExpiry = MemoExpiryProof.multiversx(nonce: BigInt.from(11));

    test('nonce consumed elsewhere fails after a second proof', () async {
      final r = resolver();
      final trm = record();
      expect(await r.resolveState(trm), -1);
      meta += 3;
      expect(await r.resolveState(trm), 2);
    });

    test('nonce not yet consumed stays pending', () async {
      accountNonce = 11;
      final r = resolver();
      final trm = record();
      expect(await r.resolveState(trm), -1);
      meta += 10;
      expect(await r.resolveState(trm), -1);
    });

    test('gateway error stays pending', () async {
      tx = const HttpStatusResult(502, '<html>');
      final r = resolver();
      final trm = record();
      expect(await r.resolveState(trm), -1);
      meta += 10;
      expect(await r.resolveState(trm), -1);
    });
  });

  group('NEAR', () {
    final hash = Base58Encode(List.filled(32, 3));
    const reference = 1000;
    late int height;
    late int keyNonce;
    late Map<String, dynamic> txResponse;
    late bool configMissing;
    setUp(() {
      height = reference + 86401;
      keyNonce = 3;
      configMissing = false;
      txResponse = {
        'error': {
          'name': 'HANDLER_ERROR',
          'cause': {
            'name': 'UNKNOWN_TRANSACTION',
            'info': {'requested_transaction_hash': hash},
          },
        },
      };
    });
    TransactionStateResolver resolver() => TransactionStateResolver(
      nearApiFactory: (_) => NearApi(
        request: (_, body) async {
          final params = body['params'];
          return switch (body['method']) {
            'EXPERIMENTAL_protocol_config' =>
              configMissing
                  ? {'result': {}}
                  : {
                      'result': {
                        'transaction_validity_period': 86400,
                        'epoch_length': 43200,
                      },
                    },
            'block' => {
              'result': {
                'header': {'height': height},
              },
            },
            'query' => {
              'result': {'nonce': keyNonce, 'block_height': height},
            },
            'tx' => txResponse,
            _ => throw StateError('unexpected ${body['method']} $params'),
          };
        },
      ),
    );
    TransationRecordModel record() =>
        _record('NEAR', 'Near', hash)
          ..memoExpiry = MemoExpiryProof.near(
            nonce: BigInt.from(4),
            publicKey: 'ed25519:${Base58Encode(List.filled(32, 1))}',
            height: BigInt.from(reference),
          );

    test('expired reference block fails after a second proof', () async {
      final r = resolver();
      final trm = record();
      expect(await r.resolveState(trm), -1);
      height += 10;
      expect(await r.resolveState(trm), 2);
    });

    test('used access-key nonce fails before expiry', () async {
      height = reference + 50;
      keyNonce = 4;
      final r = resolver();
      final trm = record();
      expect(await r.resolveState(trm), -1);
      height += 10;
      expect(await r.resolveState(trm), 2);
    });

    test('still valid transaction stays pending', () async {
      height = reference + 50;
      final r = resolver();
      final trm = record();
      expect(await r.resolveState(trm), -1);
      height += 10;
      expect(await r.resolveState(trm), -1);
    });

    test('beyond the node history window stays pending', () async {
      height = reference + 4 * 43200 + 1;
      final r = resolver();
      final trm = record();
      expect(await r.resolveState(trm), -1);
      height += 10;
      expect(await r.resolveState(trm), -1);
    });

    test('timeouts and missing protocol config stay pending', () async {
      txResponse = {
        'error': {
          'name': 'HANDLER_ERROR',
          'cause': {'name': 'TIMEOUT_ERROR'},
        },
      };
      final r = resolver();
      final trm = record();
      expect(await r.resolveState(trm), -1);
      height += 10;
      expect(await r.resolveState(trm), -1);
      configMissing = true;
      txResponse = {
        'error': {
          'cause': {'name': 'UNKNOWN_TRANSACTION'},
        },
      };
      height += 10;
      expect(await r.resolveState(trm), -1);
      height += 10;
      expect(await r.resolveState(trm), -1);
    });
  });
}
