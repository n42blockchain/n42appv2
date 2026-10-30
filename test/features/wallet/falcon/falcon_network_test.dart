import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart' show hexToBytes, keccak256, bytesToHex;
import 'package:n42_wallet/features/wallet/falcon/falcon_crypto.dart';
import 'package:n42_wallet/features/wallet/falcon/falcon_transaction.dart';
import 'package:n42_wallet/features/wallet/falcon/falcon_network.dart';

class _WriteFailStorage extends FlutterSecureStorage {
  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => throw StateError('injected durable write failure');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final path = Platform.environment['N42_PQ_LIBRARY'];
  if (path == null) {
    test('native network suite', () {}, skip: 'Set N42_PQ_LIBRARY');
    return;
  }
  final crypto = FalconCrypto(DynamicLibrary.open(path));
  final pair = crypto.generate();
  tearDownAll(() => pair.secretKey.fillRange(0, pair.secretKey.length, 0));
  final tx = FalconTransaction(
    chainId: BigInt.from(94),
    nonce: BigInt.zero,
    recipient: '0x2222222222222222222222222222222222222222',
    value: BigInt.one,
    gas: BigInt.from(21000),
    tipCap: BigInt.one,
    feeCap: BigInt.two,
    publicKey: pair.publicKey,
  );
  final sig = crypto.sign(pair.secretKey, tx.digest);
  late Map<String, Object?> caps;
  late int sends;
  late bool timeout, wrongHash, forked, owner;
  Object? receipt;
  var head = '0x20';
  late FalconNetwork network;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    caps = {
      'protocol': 'n42-pq-v1',
      'transactionType': '0x05',
      'algorithm': 'Falcon-512',
      'signatureEncoding': 'padded-666',
      'publicKeyMode': 0,
      'enabled': true,
      'chainId': '0x5e',
    };
    sends = 0;
    timeout = false;
    wrongHash = false;
    forked = false;
    owner = true;
    receipt = null;
    head = '0x20';
    network = FalconNetwork((method, params) async {
      switch (method) {
        case 'n42_getPQCapabilities':
          return caps;
        case 'eth_chainId':
          return '0x5e';
        case 'eth_getTransactionCount':
          return '0x0';
        case 'eth_getBalance':
          return '0xffffffffffff';
        case 'eth_sendRawTransaction':
          sends++;
          if (timeout) throw TimeoutException('unknown');
          return wrongHash
              ? '0x${'00' * 32}'
              : bytesToHex(
                  keccak256(hexToBytes(params.single as String)),
                  include0x: true,
                );
        case 'eth_getTransactionReceipt':
          return receipt;
        case 'eth_blockNumber':
          return head;
        case 'eth_getBlockByNumber':
          return {'hash': '0x${(forked ? 'bb' : 'aa') * 32}'};
        default:
          throw StateError(method);
      }
    });
  });
  test('disabled, wrong algorithm, encoding, mode, chain and protocol reject before send', () async {
    for (final item in <String, Object?>{
      'enabled': false,
      'algorithm': 'ECDSA',
      'signatureEncoding': 'compressed',
      'publicKeyMode': 1,
      'chainId': '0x1',
      'protocol': 'unknown',
    }.entries) {
      final previous = caps[item.key];
      caps[item.key] = item.value;
      await expectLater(
        network.submit(tx, sig, crypto, isOwnerCurrent: () => true),
        throwsStateError,
      );
      caps[item.key] = previous;
    }
    expect(sends, 0);
  });
  test(
    'signed raw transaction is submitted once and same account stays locked',
    () async {
      final hash = await network.submit(
        tx,
        sig,
        crypto,
        isOwnerCurrent: () => true,
      );
      expect(hash, startsWith('0x'));
      expect(sends, 1);
      await expectLater(
        network.submit(tx, sig, crypto, isOwnerCurrent: () => true),
        throwsStateError,
      );
      expect(sends, 1);
      final pending = await network.pending(tx);
      expect(pending!['hash'], hash);
      expect(await network.reconcileAccount(tx.chainId, tx.sender), 'pending');
      expect(sends, 1);
    },
  );
  test(
    'timeout remains pending across network facade restart and never retries',
    () async {
      timeout = true;
      await expectLater(
        network.submit(tx, sig, crypto, isOwnerCurrent: () => true),
        throwsA(isA<TimeoutException>()),
      );
      final restarted = FalconNetwork(network.rpc);
      await expectLater(
        restarted.submit(tx, sig, crypto, isOwnerCurrent: () => true),
        throwsStateError,
      );
      expect(await restarted.reconcile(tx), 'pending');
      expect(sends, 1);
    },
  );
  test('hash mismatch remains pending', () async {
    wrongHash = true;
    await expectLater(
      network.submit(tx, sig, crypto, isOwnerCurrent: () => true),
      throwsStateError,
    );
    expect(await network.pending(tx), isNotNull);
    expect(sends, 1);
  });
  test('durable storage failure prevents broadcast', () async {
    final guarded = FalconNetwork(network.rpc, storage: _WriteFailStorage());
    await expectLater(
      guarded.submit(tx, sig, crypto, isOwnerCurrent: () => true),
      throwsStateError,
    );
    expect(sends, 0);
  });
  test(
    'owner loss after durable write removes only the unsent reservation',
    () async {
      var checks = 0;
      await expectLater(
        network.submit(tx, sig, crypto, isOwnerCurrent: () => ++checks == 1),
        throwsStateError,
      );
      expect(sends, 0);
      expect(await network.pending(tx), isNull);
    },
  );
  test('concurrent sends produce only one broadcast', () async {
    final results = await Future.wait(
      List.generate(5, (_) async {
        try {
          await network.submit(tx, sig, crypto, isOwnerCurrent: () => true);
          return true;
        } catch (_) {
          return false;
        }
      }),
    );
    expect(results.where((v) => v).length, 1);
    expect(sends, 1);
  });
  test('owner change rejects before any broadcast', () async {
    owner = false;
    await expectLater(
      network.submit(tx, sig, crypto, isOwnerCurrent: () => owner),
      throwsStateError,
    );
    expect(sends, 0);
    expect(await network.pending(tx), isNull);
  });
  test(
    'only canonical receipt with twelve confirmations releases pending state',
    () async {
      final hash = await network.submit(
        tx,
        sig,
        crypto,
        isOwnerCurrent: () => true,
      );
      receipt = {
        'transactionHash': hash,
        'blockHash': '0x${'aa' * 32}',
        'blockNumber': '0x10',
        'status': '0x1',
      };
      head = '0x11';
      expect(await network.reconcile(tx), 'pending');
      head = '0x20';
      forked = true;
      expect(await network.reconcile(tx), 'pending');
      forked = false;
      expect(await network.reconcile(tx), 'confirmed');
      expect(await network.pending(tx), isNull);
      expect(sends, 1);
    },
  );
  test(
    'failed canonical receipt is a failure, not a successful payment',
    () async {
      final hash = await network.submit(
        tx,
        sig,
        crypto,
        isOwnerCurrent: () => true,
      );
      receipt = {
        'transactionHash': hash,
        'blockHash': '0x${'aa' * 32}',
        'blockNumber': '0x10',
        'status': '0x0',
      };
      expect(await network.reconcile(tx), 'failed');
      expect(sends, 1);
    },
  );
  test('HTTPS policy rejects credentials, fragments, query secrets and remote HTTP', () {
    for (final url in [
      'http://example.com',
      'https://u:p@example.com',
      'https://example.com/#x',
      'https://example.com/?key=x',
    ]) {
      expect(() => FalconNetwork.endpoint(url), throwsArgumentError);
    }
    expect(FalconNetwork.endpoint('http://127.0.0.1:8545'), isNotNull);
  });
}
