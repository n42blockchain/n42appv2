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

  /// Get account balance
  Future<MessageModel> getBalance(String accountId) async {
    try {
      final response = await _rpcPost(_rpcBody('query', {
        'request_type': 'view_account',
        'finality': 'final',
        'account_id': accountId,
      }));
      final mm = MessageModel();
      if (response != null && response['result'] != null) {
        // NEAR balance is in yoctoNEAR (10^-24 NEAR)
        mm.data = BigInt.parse(response['result']['amount'] ?? '0');
      } else if (response != null && response['error'] != null) {
        mm.error = true;
        mm.data = response['error']['message'] ?? 'RPC error';
      } else {
        mm.error = true;
        mm.data = 'Invalid response';
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// Get access key (for nonce)
  Future<MessageModel> getAccessKey(String accountId, String publicKey) async {
    try {
      final response = await _rpcPost(_rpcBody('query', {
        'request_type': 'view_access_key',
        'finality': 'final',
        'account_id': accountId,
        'public_key': publicKey,
      }));
      final mm = MessageModel();
      if (response != null && response['result'] != null) {
        final result = response['result'];
        mm.data = {
          'nonce': result['nonce'],
          'block_hash': result['block_hash'],
          'permission': result['permission'],
        };
      } else if (response != null && response['error'] != null) {
        mm.error = true;
        mm.data = response['error']['message'] ?? 'RPC error';
      } else {
        mm.error = true;
        mm.data = 'Invalid response';
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// Get latest block hash
  Future<MessageModel> getLatestBlockHash() async {
    try {
      final response = await _rpcPost(_rpcBody('block', {'finality': 'final'}));
      final mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = {
          'hash': response['result']['header']['hash'],
          'height': response['result']['header']['height'],
        };
      } else {
        mm.error = true;
        mm.data = 'Failed to get block hash';
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// Send signed transaction
  Future<MessageModel> sendTransaction(String signedTxBase64) async {
    try {
      final response = await _rpcPost(_rpcBody('broadcast_tx_commit', [signedTxBase64]));
      final mm = MessageModel();
      if (response != null && response['result'] != null) {
        final result = response['result'];
        if (result['status'] != null && result['status']['Failure'] != null) {
          mm.error = true;
          mm.data = result['status']['Failure'].toString();
        } else {
          mm.data = result['transaction']['hash'];
        }
      } else if (response != null && response['error'] != null) {
        mm.error = true;
        mm.data = response['error']['message'] ?? 'Transaction failed';
      } else {
        mm.error = true;
        mm.data = 'Unknown error';
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// Get transaction status
  Future<MessageModel> getTransactionStatus(String txHash, String senderId) async {
    try {
      final response = await _rpcPost(_rpcBody('tx', [txHash, senderId]));
      final mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = response['result'];
      } else {
        mm.error = true;
        mm.data = 'Transaction not found';
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// Get gas price
  Future<MessageModel> getGasPrice() async {
    try {
      final response = await _rpcPost(_rpcBody('gas_price', [null]));
      final mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = BigInt.parse(response['result']['gas_price'] ?? '0');
      } else {
        mm.error = true;
        mm.data = 'Failed to get gas price';
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }
}
