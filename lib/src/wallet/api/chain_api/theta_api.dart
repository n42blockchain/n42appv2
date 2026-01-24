import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

/// Theta Network API
/// Note: Theta has native and EVM-compatible endpoints
class ThetaApi {
  final bool isTest;
  late String _rpcUrl;
  late String _explorerUrl;

  ThetaApi({this.isTest = false}) {
    _rpcUrl = isTest
        ? 'https://eth-rpc-api-testnet.thetatoken.org/rpc'
        : 'https://eth-rpc-api.thetatoken.org/rpc';
    _explorerUrl = isTest
        ? 'https://testnet-explorer.thetatoken.org:8443/api'
        : 'https://explorer.thetatoken.org:8443/api';
  }

  /// Get account balance (THETA and TFUEL) via EVM RPC
  Future<MessageModel> getBalance(String address) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _rpcUrl,
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

  /// Get account info from explorer API (includes THETA and TFUEL balances)
  Future<MessageModel> getAccountInfo(String address) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_explorerUrl/account/$address',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['body'] != null) {
        final body = response['body'];
        mm.data = {
          'theta': body['balance']?['thetawei'] ?? '0',
          'tfuel': body['balance']?['tfuelwei'] ?? '0',
          'sequence': body['sequence'] ?? 0
        };
      } else {
        mm.error = true;
        mm.data = 'Account not found';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get transaction count (nonce) via EVM RPC
  Future<MessageModel> getTransactionCount(String address) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _rpcUrl,
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

  /// Get gas price via EVM RPC
  Future<MessageModel> getGasPrice() async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _rpcUrl,
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

  /// Send raw transaction via EVM RPC
  Future<MessageModel> sendTransaction(String rawTx) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _rpcUrl,
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

  /// Get transaction by hash via EVM RPC
  Future<MessageModel> getTransactionByHash(String txHash) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _rpcUrl,
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

  /// Get transaction receipt via EVM RPC
  Future<MessageModel> getTransactionReceipt(String txHash) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _rpcUrl,
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

  /// Get block number via EVM RPC
  Future<MessageModel> getBlockNumber() async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        _rpcUrl,
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
}
