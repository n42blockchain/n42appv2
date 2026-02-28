import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';

/// NEAR Protocol API
class NearApi {
  final bool isTest;
  late final String _baseUrl;

  NearApi({this.isTest = false}) {
    _baseUrl = isTest ? 'https://rpc.testnet.near.org' : 'https://rpc.mainnet.near.org';
  }

  static const Map<String, String> _jsonHeader = {'Content-Type': 'application/json'};

  /// 构建 JSON-RPC 请求 body
  Map<String, dynamic> _rpcBody(String method, dynamic params) => {
        'jsonrpc': '2.0',
        'id': 'dontcare',
        'method': method,
        'params': params,
      };

  /// 发送 JSON-RPC 请求，返回原始响应 Map
  Future<dynamic> _rpcPost(Map<String, dynamic> body) async {
    return BaseApi.requestEmptyH.post(_baseUrl, params: {}, data: body, header: _jsonHeader);
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
        return MessageModel()..error = true..data = (response['error']['message'] ?? errorMsg);
      }
      return MessageModel()..error = true..data = errorMsg;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// Get account balance
  Future<MessageModel> getBalance(String accountId) async {
    return _rpcCall('query', {
      'request_type': 'view_account', 'finality': 'final', 'account_id': accountId,
    }, (r) => BigInt.parse(r['amount'] ?? '0'));
  }

  /// Get access key (for nonce)
  Future<MessageModel> getAccessKey(String accountId, String publicKey) async {
    return _rpcCall('query', {
      'request_type': 'view_access_key', 'finality': 'final',
      'account_id': accountId, 'public_key': publicKey,
    }, (r) => {'nonce': r['nonce'], 'block_hash': r['block_hash'], 'permission': r['permission']});
  }

  /// Get latest block hash
  Future<MessageModel> getLatestBlockHash() async {
    return _rpcCall('block', {'finality': 'final'},
        (r) => {'hash': r['header']['hash'], 'height': r['header']['height']},
        errorMsg: 'Failed to get block hash');
  }

  /// Send signed transaction
  Future<MessageModel> sendTransaction(String signedTxBase64) async {
    try {
      final response = await _rpcPost(_rpcBody('broadcast_tx_commit', [signedTxBase64]));
      if (response != null && response['result'] != null) {
        final result = response['result'];
        if (result['status'] != null && result['status']['Failure'] != null) {
          return MessageModel()..error = true..data = result['status']['Failure'].toString();
        }
        return MessageModel()..data = result['transaction']['hash'];
      }
      if (response != null && response['error'] != null) {
        return MessageModel()..error = true..data = (response['error']['message'] ?? 'Transaction failed');
      }
      return MessageModel()..error = true..data = 'Unknown error';
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// Get transaction status
  Future<MessageModel> getTransactionStatus(String txHash, String senderId) async {
    return _rpcCall('tx', [txHash, senderId], (r) => r,
        errorMsg: 'Transaction not found');
  }

  /// Get gas price
  Future<MessageModel> getGasPrice() async {
    return _rpcCall('gas_price', [null], (r) => BigInt.parse(r['gas_price'] ?? '0'),
        errorMsg: 'Failed to get gas price');
  }
}
