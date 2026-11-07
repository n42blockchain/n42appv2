import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// NEAR Protocol API
class NearApi {
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

  /// Send signed transaction
  Future<MessageModel> sendTransaction(String signedTxBase64) async {
    try {
      final response = await _rpcPost(
        _rpcBody('broadcast_tx_commit', [signedTxBase64]),
      );
      if (response != null && response['result'] != null) {
        final result = response['result'];
        if (result['status'] != null && result['status']['Failure'] != null) {
          return MessageModel()
            ..error = true
            ..data = result['status']['Failure'].toString();
        }
        return MessageModel()..data = result['transaction']['hash'];
      }
      if (response != null && response['error'] != null) {
        return MessageModel()
          ..error = true
          ..data = (response['error']['message'] ?? 'Transaction failed');
      }
      return MessageModel()
        ..error = true
        ..data = 'Unknown error';
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// Get transaction status
  Future<MessageModel> getTransactionStatus(
    String txHash,
    String senderId,
  ) async {
    return _rpcCall(
      'tx',
      [txHash, senderId],
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
