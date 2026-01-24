import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

/// VeChain (VET) API
class VetApi {
  final bool isTest;
  late String _baseUrl;

  VetApi({this.isTest = false}) {
    _baseUrl = isTest
        ? 'https://testnet.veblocks.net'
        : 'https://mainnet.veblocks.net';
  }

  /// Get account balance (VET and VTHO)
  Future<MessageModel> getBalance(String address) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/accounts/$address',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['balance'] != null) {
        // Balance is in hex, convert to BigInt
        String balanceHex = response['balance'];
        if (balanceHex.startsWith('0x')) {
          balanceHex = balanceHex.substring(2);
        }
        mm.data = BigInt.parse(balanceHex, radix: 16);
      } else {
        mm.error = true;
        mm.data = 'Account not found or invalid response';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get VTHO (energy) balance
  Future<MessageModel> getEnergyBalance(String address) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/accounts/$address',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['energy'] != null) {
        String energyHex = response['energy'];
        if (energyHex.startsWith('0x')) {
          energyHex = energyHex.substring(2);
        }
        mm.data = BigInt.parse(energyHex, radix: 16);
      } else {
        mm.error = true;
        mm.data = 'Account not found or invalid response';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get best block info
  Future<MessageModel> getBestBlock() async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/blocks/best',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['id'] != null) {
        mm.data = response;
      } else {
        mm.error = true;
        mm.data = 'Failed to get best block';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get chain tag
  Future<MessageModel> getChainTag() async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/blocks/0',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['id'] != null) {
        // Chain tag is the last byte of genesis block id
        String blockId = response['id'];
        mm.data = int.parse(blockId.substring(blockId.length - 2), radix: 16);
      } else {
        mm.error = true;
        mm.data = 'Failed to get chain tag';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Submit signed transaction
  Future<MessageModel> sendTransaction(String rawTx) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        '$_baseUrl/transactions',
        params: {},
        data: {'raw': rawTx},
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['id'] != null) {
        mm.data = response['id'];
      } else {
        mm.error = true;
        mm.data = response?['message'] ?? 'Transaction failed';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get transaction by id
  Future<MessageModel> getTransaction(String txId) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/transactions/$txId',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['id'] != null) {
        mm.data = response;
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
  Future<MessageModel> getTransactionReceipt(String txId) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/transactions/$txId/receipt',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null) {
        mm.data = response;
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

  /// Get transfer logs for address
  Future<MessageModel> getTransferLogs(String address, {int limit = 20}) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        '$_baseUrl/logs/transfer',
        params: {},
        data: {
          'criteriaSet': [
            {'sender': address},
            {'recipient': address}
          ],
          'order': 'desc',
          'options': {'offset': 0, 'limit': limit}
        },
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response is List) {
        mm.data = response;
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
