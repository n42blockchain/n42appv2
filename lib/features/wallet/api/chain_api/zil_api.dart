import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';

/// Zilliqa (ZIL) API
class ZilApi {
  final bool isTest;
  late String _baseUrl;

  ZilApi({this.isTest = false}) {
    _baseUrl = isTest
        ? 'https://api.testnet.zilliqa.com'
        : 'https://api.zilliqa.com';
  }

  /// Get account balance
  Future<MessageModel> getBalance(String address,{bool nonce=false}) async {
    try {
      Map<String,dynamic> params={
    'id': '1',
    'jsonrpc': '2.0',
    'method': 'GetBalance',
    'params': [address]
    };
      final response = await BaseApi.requestEmptyH.post(
        _baseUrl,
        params: {},
        data: params,
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        // ZIL balance is in Qa (10^-12 ZIL)
        if(nonce){
          mm.data={
            'balance':BigInt.parse(response['result']['balance'] ?? '0'),
            'nonce':response['result']['nonce']
          };
        }else{
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
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get minimum gas price
  Future<MessageModel> getMinimumGasPrice() async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _baseUrl,
        params: {},
        data: {
          'id': '1',
          'jsonrpc': '2.0',
          'method': 'GetMinimumGasPrice',
          'params': []
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = BigInt.parse(response['result']);
      } else {
        mm.error = true;
        mm.data = 'Failed to get gas price';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get network ID
  Future<MessageModel> getNetworkId() async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _baseUrl,
        params: {},
        data: {
          'id': '1',
          'jsonrpc': '2.0',
          'method': 'GetNetworkId',
          'params': []
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = response['result'];
      } else {
        mm.error = true;
        mm.data = 'Failed to get network ID';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get latest block number
  Future<MessageModel> getLatestTxBlock() async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _baseUrl,
        params: {},
        data: {
          'id': '1',
          'jsonrpc': '2.0',
          'method': 'GetLatestTxBlock',
          'params': []
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = {
          'header': response['result']['header'],
          'body': response['result']['body']
        };
      } else {
        mm.error = true;
        mm.data = 'Failed to get latest block';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Send signed transaction
  Future<MessageModel> createTransaction(Map<String, dynamic> txParams) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _baseUrl,
        params: {},
        data: {
          'id': '1',
          'jsonrpc': '2.0',
          'method': 'CreateTransaction',
          'params': [txParams]
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = response['result']['TranID'];
      } else if (response != null && response['error'] != null) {
        mm.error = true;
        mm.data = response['error']['message'] ?? 'Transaction failed';
      } else {
        mm.error = true;
        mm.data = 'Unknown error';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get transaction by hash
  Future<MessageModel> getTransaction(String txHash) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _baseUrl,
        params: {},
        data: {
          'id': '1',
          'jsonrpc': '2.0',
          'method': 'GetTransaction',
          'params': [txHash]
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = response['result'];
      } else {
        mm.error = true;
        mm.data = 'Transaction not found';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get transactions for address
  Future<MessageModel> getTransactionsForTxBlock(String blockNum) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _baseUrl,
        params: {},
        data: {
          'id': '1',
          'jsonrpc': '2.0',
          'method': 'GetTransactionsForTxBlock',
          'params': [blockNum]
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = response['result'];
      } else {
        mm.data = [];
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
}
