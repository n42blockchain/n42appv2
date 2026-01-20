import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

/// Harmony (ONE) API
/// Note: Harmony is EVM-compatible, so most operations can use EthAPI with coinType="ONE"
/// This API provides Harmony-specific endpoints
class OneApi {
  final bool isTest;
  late String _baseUrl;

  OneApi({this.isTest = false}) {
    _baseUrl = isTest
        ? 'https://api.s0.b.hmny.io'
        : 'https://api.harmony.one';
  }

  /// Get account balance (native ONE)
  Future<MessageModel> getBalance(String address) async {
    try {
      final response = await BaseApi.RequestEmpty_h.post(
        _baseUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'hmy_getBalance',
          'params': [address, 'latest'],
          'id': 1
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        String balanceHex = response['result'];
        if (balanceHex.startsWith('0x')) {
          balanceHex = balanceHex.substring(2);
        }
        mm.data = BigInt.parse(balanceHex, radix: 16);
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

  /// Get transaction count (nonce)
  Future<MessageModel> getTransactionCount(String address) async {
    try {
      final response = await BaseApi.RequestEmpty_h.post(
        _baseUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'hmy_getTransactionCount',
          'params': [address, 'latest'],
          'id': 1
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        String nonceHex = response['result'];
        if (nonceHex.startsWith('0x')) {
          nonceHex = nonceHex.substring(2);
        }
        mm.data = BigInt.parse(nonceHex, radix: 16);
      } else {
        mm.error = true;
        mm.data = 'Failed to get nonce';
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
      final response = await BaseApi.RequestEmpty_h.post(
        _baseUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'hmy_gasPrice',
          'params': [],
          'id': 1
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        String gasPriceHex = response['result'];
        if (gasPriceHex.startsWith('0x')) {
          gasPriceHex = gasPriceHex.substring(2);
        }
        mm.data = BigInt.parse(gasPriceHex, radix: 16);
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

  /// Send raw transaction
  Future<MessageModel> sendTransaction(String rawTx) async {
    try {
      final response = await BaseApi.RequestEmpty_h.post(
        _baseUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'hmy_sendRawTransaction',
          'params': [rawTx],
          'id': 1
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = response['result'];
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
  Future<MessageModel> getTransactionByHash(String txHash) async {
    try {
      final response = await BaseApi.RequestEmpty_h.post(
        _baseUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'hmy_getTransactionByHash',
          'params': [txHash],
          'id': 1
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

  /// Get transaction receipt
  Future<MessageModel> getTransactionReceipt(String txHash) async {
    try {
      final response = await BaseApi.RequestEmpty_h.post(
        _baseUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'hmy_getTransactionReceipt',
          'params': [txHash],
          'id': 1
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        mm.data = response['result'];
      } else {
        mm.error = true;
        mm.data = 'Receipt not found';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get block number
  Future<MessageModel> getBlockNumber() async {
    try {
      final response = await BaseApi.RequestEmpty_h.post(
        _baseUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'hmy_blockNumber',
          'params': [],
          'id': 1
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        String blockHex = response['result'];
        if (blockHex.startsWith('0x')) {
          blockHex = blockHex.substring(2);
        }
        mm.data = BigInt.parse(blockHex, radix: 16);
      } else {
        mm.error = true;
        mm.data = 'Failed to get block number';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
}
