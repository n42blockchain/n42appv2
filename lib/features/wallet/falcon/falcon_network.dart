import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex, keccak256;

import '../utils/transfer_serializer.dart';
import 'falcon_crypto.dart';
import 'falcon_transaction.dart';

final class FalconNetworkNotEnabled extends StateError {
  FalconNetworkNotEnabled()
    : super('This network has not enabled compatible Falcon-512 transactions');
}

final class FalconSubmissionPending extends StateError {
  FalconSubmissionPending() : super('Reconcile the previous submission first');
}

typedef FalconRpc = Future<Object?> Function(
  String method,
  List<Object?> params,
);

/// No fallback to ECDSA or to an unadvertised transaction encoding.
final class FalconNetwork {
  FalconNetwork(this.rpc, {FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();
  factory FalconNetwork.endpoint(String endpoint) {
    final uri = Uri.parse(endpoint);
    if (uri.userInfo.isNotEmpty ||
        uri.fragment.isNotEmpty ||
        uri.query.isNotEmpty ||
        !(uri.scheme == 'https' ||
            (uri.scheme == 'http' &&
                {'localhost', '127.0.0.1', '::1'}.contains(uri.host)))) {
      throw ArgumentError('Use HTTPS or a loopback test RPC');
    }
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );
    var nextId = 0;
    return FalconNetwork((method, params) async {
      final id = ++nextId;
      final response = await dio.post<Object?>(
        endpoint,
        data: {'jsonrpc': '2.0', 'id': id, 'method': method, 'params': params},
      );
      final data = response.data;
      if (data is! Map ||
          data['jsonrpc'] != '2.0' ||
          data['id'] != id ||
          data.containsKey('error') ||
          !data.containsKey('result')) {
        throw StateError('RPC request failed');
      }
      return data['result'];
    });
  }
  final FalconRpc rpc;
  final FlutterSecureStorage _storage;
  static BigInt quantity(Object? value) {
    if (value is! String || !RegExp(r'^0x[0-9a-fA-F]{1,64}$').hasMatch(value)) {
      throw FormatException('Invalid RPC quantity');
    }
    return BigInt.parse(value.substring(2), radix: 16);
  }

  static String _slot(FalconTransaction tx) =>
      'n42.pq.pending.v1.${tx.chainId}.${tx.sender}';
  Future<Map<String, dynamic>?> pending(FalconTransaction tx) =>
      pendingAccount(tx.chainId, tx.sender);
  Future<Map<String, dynamic>?> pendingAccount(
    BigInt chainId,
    String sender,
  ) async {
    final raw = await _storage.read(key: 'n42.pq.pending.v1.$chainId.$sender');
    if (raw == null) return null;
    final value = jsonDecode(raw) as Map<String, dynamic>;
    if (value['chainId'] != '$chainId' ||
        value['sender'] != sender ||
        value['hash'] is! String ||
        !RegExp(r'^0x[0-9a-f]{64}$').hasMatch(value['hash'] as String)) {
      throw StateError('Pending submission record is invalid');
    }
    return value;
  }

  Future<void> validate(FalconTransaction tx) async {
    final capabilities = await rpc('n42_getPQCapabilities', const []);
    if (capabilities is! Map ||
        capabilities['protocol'] != 'n42-pq-v1' ||
        capabilities['enabled'] != true ||
        capabilities['transactionType'] != '0x05' ||
        capabilities['algorithm'] != 'Falcon-512' ||
        capabilities['signatureEncoding'] != 'padded-666' ||
        capabilities['publicKeyMode'] != 0 ||
        quantity(capabilities['chainId']) != tx.chainId ||
        quantity(await rpc('eth_chainId', const [])) != tx.chainId) {
      throw FalconNetworkNotEnabled();
    }
    if (await pending(tx) != null) {
      throw FalconSubmissionPending();
    }
    final nonce = quantity(
      await rpc('eth_getTransactionCount', [tx.sender, 'pending']),
    );
    final balance = quantity(
      await rpc('eth_getBalance', [tx.sender, 'pending']),
    );
    if (nonce != tx.nonce || balance < tx.value + tx.gas * tx.feeCap) {
      throw StateError('Nonce changed or balance is insufficient');
    }
  }

  /// The caller previews this immutable transaction and authenticates the owner
  /// before entering. A durable pending record precedes the sole broadcast.
  Future<String> submit(
    FalconTransaction tx,
    Uint8List signature,
    FalconCrypto crypto, {
    required bool Function() isOwnerCurrent,
  }) => TransferSerializer.run('falcon:${tx.chainId}:${tx.sender}', () async {
    if (!crypto.verify(tx.publicKey, tx.digest, signature)) {
      throw StateError('Invalid Falcon signature');
    }
    await validate(tx);
    if (!isOwnerCurrent()) {
      throw StateError('Wallet owner changed');
    }
    final raw = tx.encodeSigned(signature);
    final hash = bytesToHex(keccak256(raw), include0x: true);
    await _storage.write(
      key: _slot(tx),
      value: jsonEncode({
        'chainId': '${tx.chainId}',
        'sender': tx.sender,
        'nonce': '${tx.nonce}',
        'hash': hash,
        'state': 'pending',
      }),
    );
    // Any error after this point keeps the pending record. A timeout, 5xx,
    // malformed response or RPC rejection is never an instruction to resend.
    if (!isOwnerCurrent()) {
      await _storage.delete(key: _slot(tx));
      throw StateError('Wallet owner changed before broadcast');
    }
    final returned = await rpc('eth_sendRawTransaction', [
      bytesToHex(raw, include0x: true),
    ]);
    if (returned is! String || returned.toLowerCase() != hash) {
      throw StateError(
        'Submission outcome unknown; reconcile the original hash',
      );
    }
    return hash;
  });
  Future<String> reconcile(FalconTransaction tx) =>
      reconcileAccount(tx.chainId, tx.sender);
  Future<String> reconcileAccount(BigInt chainId, String sender) =>
      TransferSerializer.run('falcon:$chainId:$sender', () async {
        final record = await pendingAccount(chainId, sender);
        if (record == null) return 'none';
        if (quantity(await rpc('eth_chainId', const [])) != chainId) {
          throw StateError('Wrong reconciliation network');
        }
        final receipt = await rpc('eth_getTransactionReceipt', [
          record['hash'],
        ]);
        if (receipt == null) return 'pending';
        if (receipt is! Map ||
            receipt['transactionHash'] != record['hash'] ||
            receipt['blockHash'] is! String ||
            !RegExp(r'^0x[0-9a-fA-F]{64}$')
                .hasMatch(receipt['blockHash'] as String)) {
          throw StateError('Invalid transaction receipt');
        }
        final blockNumber = quantity(receipt['blockNumber']);
        final status = quantity(receipt['status']);
        if (status != BigInt.zero && status != BigInt.one) {
          throw StateError('Invalid receipt status');
        }
        final head = quantity(await rpc('eth_blockNumber', const []));
        final block = await rpc('eth_getBlockByNumber', [
          receipt['blockNumber'],
          false,
        ]);
        if (block is! Map ||
            block['hash'] != receipt['blockHash'] ||
            head < blockNumber + BigInt.from(11)) {
          return 'pending';
        }
        // Release only after a canonical receipt has twelve confirmations.
        await _storage.delete(key: 'n42.pq.pending.v1.$chainId.$sender');
        return status == BigInt.one ? 'confirmed' : 'failed';
      });
}
