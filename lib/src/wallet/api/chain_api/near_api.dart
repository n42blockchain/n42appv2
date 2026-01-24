import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

/// NEAR Protocol API
class NearApi {
  final bool isTest;
  late String _baseUrl;

  NearApi({this.isTest = false}) {
    _baseUrl = isTest
        ? 'https://rpc.testnet.near.org'
        : 'https://rpc.mainnet.near.org';
  }

  /// Get account balance
  Future<MessageModel> getBalance(String accountId) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _baseUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'id': 'dontcare',
          'method': 'query',
          'params': {
            'request_type': 'view_account',
            'finality': 'final',
            'account_id': accountId
          }
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        final result = response['result'];
        // NEAR balance is in yoctoNEAR (10^-24 NEAR)
        mm.data = BigInt.parse(result['amount'] ?? '0');
      } else if (response != null && response['error'] != null) {
        mm.error = true;
        mm.data = response['error']['message'] ?? 'RPC error';
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

  /// Get access key (for nonce)
  Future<MessageModel> getAccessKey(String accountId, String publicKey) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _baseUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'id': 'dontcare',
          'method': 'query',
          'params': {
            'request_type': 'view_access_key',
            'finality': 'final',
            'account_id': accountId,
            'public_key': publicKey
          }
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = {
          'nonce': response['result']['nonce'],
          'block_hash': response['result']['block_hash'],
          'permission': response['result']['permission']
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
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get latest block hash
  Future<MessageModel> getLatestBlockHash() async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _baseUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'id': 'dontcare',
          'method': 'block',
          'params': {'finality': 'final'}
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = {
          'hash': response['result']['header']['hash'],
          'height': response['result']['header']['height']
        };
      } else {
        mm.error = true;
        mm.data = 'Failed to get block hash';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Send signed transaction
  Future<MessageModel> sendTransaction(String signedTxBase64) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _baseUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'id': 'dontcare',
          'method': 'broadcast_tx_commit',
          'params': [signedTxBase64]
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        final result = response['result'];
        if (result['status'] != null && result['status']['SuccessValue'] != null) {
          mm.data = result['transaction']['hash'];
        } else if (result['status'] != null && result['status']['Failure'] != null) {
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
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get transaction status
  Future<MessageModel> getTransactionStatus(String txHash, String senderId) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _baseUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'id': 'dontcare',
          'method': 'tx',
          'params': [txHash, senderId]
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

  /// Get gas price
  Future<MessageModel> getGasPrice() async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _baseUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'id': 'dontcare',
          'method': 'gas_price',
          'params': [null]
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = BigInt.parse(response['result']['gas_price'] ?? '0');
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
}
