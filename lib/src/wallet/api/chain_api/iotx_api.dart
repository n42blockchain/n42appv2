import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

/// IoTeX (IOTX) API
/// Note: IoTeX has both native and EVM-compatible endpoints
/// EVM operations can use EthAPI with coinType="IOTX"
class IotxApi {
  final bool isTest;
  late String _evmUrl;

  IotxApi({this.isTest = false}) {
    _evmUrl = isTest
        ? 'https://babel-api.testnet.iotex.io'
        : 'https://babel-api.mainnet.iotex.io';
  }

  /// Get account balance (native IOTX) via EVM RPC
  Future<MessageModel> getBalance(String address) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _evmUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'eth_getBalance',
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
        mm.data = BigInt.parse(balanceHex.isEmpty ? '0' : balanceHex, radix: 16);
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
      final response = await BaseApi.requestEmptyH.post(
        _evmUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'eth_getTransactionCount',
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
        mm.data = BigInt.parse(nonceHex.isEmpty ? '0' : nonceHex, radix: 16);
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
      final response = await BaseApi.requestEmptyH.post(
        _evmUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'eth_gasPrice',
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
        mm.data = BigInt.parse(gasPriceHex.isEmpty ? '0' : gasPriceHex, radix: 16);
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
      final response = await BaseApi.requestEmptyH.post(
        _evmUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'eth_sendRawTransaction',
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
      final response = await BaseApi.requestEmptyH.post(
        _evmUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'eth_getTransactionByHash',
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
      final response = await BaseApi.requestEmptyH.post(
        _evmUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'eth_getTransactionReceipt',
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
      final response = await BaseApi.requestEmptyH.post(
        _evmUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'eth_blockNumber',
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
        mm.data = BigInt.parse(blockHex.isEmpty ? '0' : blockHex, radix: 16);
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

  /// Get chain ID
  Future<MessageModel> getChainId() async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _evmUrl,
        params: {},
        data: {
          'jsonrpc': '2.0',
          'method': 'eth_chainId',
          'params': [],
          'id': 1
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['result'] != null) {
        String chainIdHex = response['result'];
        if (chainIdHex.startsWith('0x')) {
          chainIdHex = chainIdHex.substring(2);
        }
        mm.data = int.parse(chainIdHex, radix: 16);
      } else {
        mm.error = true;
        mm.data = 'Failed to get chain ID';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
}
