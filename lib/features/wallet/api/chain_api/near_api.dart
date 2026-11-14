import 'dart:convert';

import 'near_transaction_hash.dart';

import 'package:fast_base58/fast_base58.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// NEAR Protocol API
class NearApi {
  // Conservative reserve, not the exact gas burned by a native transfer.
  static final transferGasReserve = BigInt.from(300000000000000);
  final bool isTest;
  final Future<dynamic> Function(String, Map<String, dynamic>)? request;
  late final String _baseUrl;

  NearApi({this.isTest = false, this.request}) {
    _baseUrl = isTest
        ? 'https://rpc.testnet.near.org'
        : 'https://rpc.mainnet.near.org';
  }

  static const Map<String, String> _jsonHeader = {
    'Content-Type': 'application/json',
  };

  /// 构建 JSON-RPC 请求 body
  Map<String, dynamic> _rpcBody(String method, dynamic params) => {
    'jsonrpc': '2.0',
    'id': 'dontcare',
    'method': method,
    'params': params,
  };

  /// 发送 JSON-RPC 请求，返回原始响应 Map
  Future<dynamic> _rpcPost(Map<String, dynamic> body) async {
    if (request != null) return request!(_baseUrl, body);
    return BaseApi.requestEmptyH.post(
      _baseUrl,
      params: {},
      data: body,
      header: _jsonHeader,
    );
  }

  /// Helper: execute RPC, extract result via [extractor], handle error responses
  Future<MessageModel> _rpcCall(
    String method,
    dynamic params,
    dynamic Function(dynamic result) extractor, {
    String errorMsg = 'RPC error',
  }) async {
    try {
      final response = await _rpcPost(_rpcBody(method, params));
      if (response != null && response['result'] != null) {
        return MessageModel()..data = extractor(response['result']);
      }
      if (response != null && response['error'] != null) {
        return MessageModel()
          ..error = true
          ..data = (response['error']['message'] ?? errorMsg);
      }
      return MessageModel()
        ..error = true
        ..data = errorMsg;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// Get account balance
  Future<MessageModel> getBalance(String accountId) async {
    return _rpcCall('query', {
      'request_type': 'view_account',
      'finality': 'final',
      'account_id': accountId,
    }, (r) => BigInt.parse(r['amount'] ?? '0'));
  }

  /// Account amount and liquid storage reserve at the same finalized block.
  /// Keep getBalance's existing display contract unchanged.
  Future<MessageModel> getTransferBalance(String accountId) async {
    try {
      BigInt integer(dynamic value) {
        final text = value is String || value is int ? value.toString() : '';
        if (!RegExp(r'^[0-9]+$').hasMatch(text)) {
          throw const FormatException('Invalid NEAR balance field');
        }
        return BigInt.parse(text);
      }

      final response = await _rpcPost(
        _rpcBody('query', {
          'request_type': 'view_account',
          'finality': 'final',
          'account_id': accountId,
        }),
      );
      if (response is! Map || response['result'] is! Map) {
        throw const FormatException('Missing NEAR account');
      }
      final account = response['result'] as Map;
      final amount = integer(account['amount']);
      final locked = integer(account['locked']);
      final storage = integer(account['storage_usage']);
      final block = account['block_hash'];
      if (block is! String || block.isEmpty) {
        throw const FormatException('Missing finalized block');
      }
      final configResponse = await _rpcPost(
        _rpcBody('EXPERIMENTAL_protocol_config', {'block_id': block}),
      );
      if (configResponse is! Map || configResponse['result'] is! Map) {
        throw const FormatException('Missing NEAR protocol configuration');
      }
      final config = configResponse['result']['runtime_config'];
      if (config is! Map) {
        throw const FormatException('Missing NEAR runtime configuration');
      }
      final price = integer(config['storage_amount_per_byte']);
      if (price <= BigInt.zero) {
        throw const FormatException('Invalid NEAR storage price');
      }
      // NEP-448 exempts accounts using at most 770 bytes. Above that limit,
      // all storage is billable; locked staking balance also covers storage.
      final required = storage <= BigInt.from(770)
          ? BigInt.zero
          : storage * price;
      final reserve = required > locked ? required - locked : BigInt.zero;
      if (amount >= (BigInt.one << 128) ||
          locked >= (BigInt.one << 128) ||
          required >= (BigInt.one << 128) ||
          storage >= (BigInt.one << 64)) {
        throw const FormatException('NEAR balance field overflow');
      }
      return MessageModel()
        ..data = {'balance': amount, 'storageReserve': reserve};
    } catch (_) {
      return MessageModel.error()
        ..data = 'Unable to determine NEAR spendable balance';
    }
  }

  /// Get access key (for nonce)
  Future<MessageModel> getAccessKey(String accountId, String publicKey) async {
    return _rpcCall(
      'query',
      {
        'request_type': 'view_access_key',
        'finality': 'final',
        'account_id': accountId,
        'public_key': publicKey,
      },
      (r) => {
        'nonce': r['nonce'],
        'block_hash': r['block_hash'],
        'permission': r['permission'],
      },
    );
  }

  /// Get latest block hash
  Future<MessageModel> getLatestBlockHash() async {
    return _rpcCall(
      'block',
      {'finality': 'final'},
      (r) => {'hash': r['header']['hash'], 'height': r['header']['height']},
      errorMsg: 'Failed to get block hash',
    );
  }

  /// Submit once. An absent/nonterminal receipt is an unknown outcome, not
  /// evidence that the signed transaction was rejected or is safe to resend.
  Future<MessageModel> sendTransaction(String signedTxBase64) async {
    MessageModel unknown() =>
        MessageModel.error()
          ..data = 'NEAR transaction outcome is unknown; check its status';
    late final String expectedHash;
    try {
      expectedHash = nearSignedTransactionHash(signedTxBase64);
      if (signedTxBase64.isEmpty ||
          base64Encode(base64Decode(signedTxBase64)) != signedTxBase64) {
        return MessageModel.error()..data = 'Invalid signed NEAR encoding';
      }
    } catch (_) {
      return MessageModel.error()..data = 'Invalid signed NEAR encoding';
    }
    try {
      final response = await _rpcPost(
        _rpcBody('broadcast_tx_commit', [signedTxBase64]),
      );
      if (response is Map && response['result'] == null) {
        // INVALID_TRANSACTION is the node refusing this exact transaction
        // during validation (bad nonce, expired block hash, insufficient
        // balance, bad signature...): it never entered the chain or a pool.
        final error = response['error'];
        final cause = error is Map ? error['cause'] : null;
        if (cause is Map && cause['name'] == 'INVALID_TRANSACTION') {
          return MessageModel.error()
            ..data = const BroadcastRejected('NEAR rejected the transaction');
        }
      }
      if (response is! Map || response['result'] is! Map) return unknown();
      final result = response['result'] as Map;
      final status = result['status'];
      // SuccessReceiptId only points to subsequent execution; it is not the
      // terminal SuccessValue returned after that receipt completes.
      if (status is! Map || status.length != 1) return unknown();
      if (status.containsKey('Failure')) {
        final transaction = result['transaction'];
        if (transaction is Map && transaction['hash'] == expectedHash) {
          // Executed and failed on chain: terminal, it cannot succeed later.
          return MessageModel.error()
            ..data = const BroadcastRejected(
              'NEAR transaction execution failed',
            );
        }
        return MessageModel.error()..data = 'NEAR transaction execution failed';
      }
      final value = status['SuccessValue'];
      if (value is! String || base64Encode(base64Decode(value)) != value) {
        return unknown();
      }
      final transaction = result['transaction'];
      if (transaction is! Map || transaction['hash'] is! String) {
        return unknown();
      }
      final hash = transaction['hash'] as String;
      final bytes = Base58Decode(hash);
      if (bytes.length != 32 ||
          Base58Encode(bytes) != hash ||
          hash != expectedHash) {
        return unknown();
      }
      return MessageModel()..data = hash;
    } catch (_) {
      return unknown();
    }
  }

  /// Get transaction status
  Future<MessageModel> getTransactionStatus(
    String txHash,
    String senderId,
  ) async {
    return _rpcCall(
      'tx',
      {'tx_hash': txHash, 'sender_account_id': senderId, 'wait_until': 'FINAL'},
      (r) => r,
      errorMsg: 'Transaction not found',
    );
  }

  /// Get gas price
  Future<MessageModel> getGasPrice() async {
    return _rpcCall(
      'gas_price',
      [null],
      (r) => BigInt.parse(r['gas_price'] ?? '0'),
      errorMsg: 'Failed to get gas price',
    );
  }
}
