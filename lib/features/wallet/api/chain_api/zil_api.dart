import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// Zilliqa (ZIL) API
class ZilApi {
  final bool isTest;
  late String _baseUrl;

  ZilApi({this.isTest = false}) {
    _baseUrl = isTest
        ? 'https://api.testnet.zilliqa.com'
        : 'https://api.zilliqa.com';
  }

  Future<Map<String, dynamic>?> _rpc(String method, List<dynamic> params) async {
    final response = await BaseApi.requestEmptyH.post(
      _baseUrl,
      params: {},
      data: {'id': '1', 'jsonrpc': '2.0', 'method': method, 'params': params},
      header: {'Content-Type': 'application/json'},
    );
    return response as Map<String, dynamic>?;
  }

  static MessageModel _errorMm(dynamic e) => MessageModel.error()..data = e.toString();

  /// Helper: execute RPC and extract result, with optional error message
  Future<MessageModel> _rpcResult(
    String method,
    List<dynamic> params,
    dynamic Function(dynamic result) extractor, {
    String errorMsg = 'RPC error',
  }) async {
    try {
      final response = await _rpc(method, params);
      if (response != null && response['result'] != null) {
        return MessageModel()..data = extractor(response['result']);
      }
      if (response != null && response['error'] != null) {
        return MessageModel()..error = true..data = response['error']['message'] ?? errorMsg;
      }
      return MessageModel()..error = true..data = errorMsg;
    } catch (e) {
      return _errorMm(e);
    }
  }

  /// Get account balance
  Future<MessageModel> getBalance(String address, {bool nonce = false}) async {
    try {
      final response = await _rpc('GetBalance', [address]);
      final mm = MessageModel();
      if (response != null && response['result'] != null) {
        // ZIL balance is in Qa (10^-12 ZIL)
        if (nonce) {
          mm.data = {
            'balance': BigInt.parse(response['result']['balance'] ?? '0'),
            'nonce': response['result']['nonce'],
          };
        } else {
          mm.data = BigInt.parse(response['result']['balance'] ?? '0');
        }
      } else if (response != null && response['error'] != null) {
        // Account not found means balance is 0
        if (response['error']['code'] == -5) {
          mm.data = BigInt.zero;
        } else {
          mm.error = true;
          mm.data = response['error']['message'] ?? 'RPC error';
        }
      } else {
        mm.error = true;
        mm.data = 'Invalid response';
      }
      return mm;
    } catch (e) {
      return _errorMm(e);
    }
  }

  /// Get minimum gas price
  Future<MessageModel> getMinimumGasPrice() async {
    return _rpcResult('GetMinimumGasPrice', [], (r) => BigInt.parse(r),
        errorMsg: 'Failed to get gas price');
  }

  /// Get network ID
  Future<MessageModel> getNetworkId() async {
    return _rpcResult('GetNetworkId', [], (r) => r,
        errorMsg: 'Failed to get network ID');
  }

  /// Get latest block number
  Future<MessageModel> getLatestTxBlock() async {
    return _rpcResult('GetLatestTxBlock', [], (r) => {'header': r['header'], 'body': r['body']},
        errorMsg: 'Failed to get latest block');
  }

  /// Send signed transaction
  Future<MessageModel> createTransaction(Map<String, dynamic> txParams) async {
    return _rpcResult('CreateTransaction', [txParams], (r) => r['TranID'],
        errorMsg: 'Transaction failed');
  }

  /// Get transaction by hash
  Future<MessageModel> getTransaction(String txHash) async {
    return _rpcResult('GetTransaction', [txHash], (r) => r,
        errorMsg: 'Transaction not found');
  }

  /// Get transactions for address
  Future<MessageModel> getTransactionsForTxBlock(String blockNum) async {
    try {
      final response = await _rpc('GetTransactionsForTxBlock', [blockNum]);
      return MessageModel()..data = response?['result'] ?? [];
    } catch (e) {
      return _errorMm(e);
    }
  }
}
