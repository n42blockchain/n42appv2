import 'dart:convert';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

/// MultiversX (eGLD) API - formerly Elrond
class EgldApi {
  final bool isTest;
  late String _apiUrl;
  late String _gatewayUrl;

  EgldApi({this.isTest = false}) {
    _apiUrl = isTest
        ? 'https://devnet-api.multiversx.com'
        : 'https://api.multiversx.com';
    _gatewayUrl = isTest
        ? 'https://devnet-gateway.multiversx.com'
        : 'https://gateway.multiversx.com';
  }

  /// Get account info (balance, nonce)
  Future<MessageModel> getAccount(String address) async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_apiUrl/accounts/$address',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['address'] != null) {
        mm.data = {
          'address': response['address'],
          'balance': BigInt.parse(response['balance'] ?? '0'),
          'nonce': response['nonce'] ?? 0,
          'shard': response['shard'] ?? 0,
        };
      } else if (response != null && response['error'] != null) {
        mm.error = true;
        mm.data = response['message'] ?? 'Account not found';
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

  /// Get account balance
  Future<MessageModel> getBalance(String address) async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_apiUrl/accounts/$address',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['balance'] != null) {
        mm.data = BigInt.parse(response['balance']);
      } else if (response != null && response['statusCode'] == 404) {
        mm.data = BigInt.zero;
      } else {
        mm.data = BigInt.zero;
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get account nonce
  Future<MessageModel> getNonce(String address) async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_apiUrl/accounts/$address',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['nonce'] != null) {
        mm.data = response['nonce'];
      } else {
        mm.data = 0;
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get network config (gas price, chain ID, etc.)
  Future<MessageModel> getNetworkConfig() async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_gatewayUrl/network/config',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['data'] != null) {
        final config = response['data']['config'];
        mm.data = {
          'chainId': config['erd_chain_id'],
          'gasPerDataByte': config['erd_gas_per_data_byte'],
          'minGasLimit': config['erd_min_gas_limit'],
          'minGasPrice': config['erd_min_gas_price'],
          'minTransactionVersion': config['erd_min_transaction_version'],
        };
      } else {
        mm.error = true;
        mm.data = 'Failed to get network config';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get economics (for estimating gas)
  Future<MessageModel> getEconomics() async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_apiUrl/economics',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null) {
        mm.data = {
          'totalSupply': response['totalSupply'],
          'circulatingSupply': response['circulatingSupply'],
          'staked': response['staked'],
          'price': response['price'],
          'marketCap': response['marketCap'],
        };
      } else {
        mm.error = true;
        mm.data = 'Failed to get economics';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Send signed transaction
  Future<MessageModel> sendTransaction(String signedTxJson) async {
    try {
      final txData = jsonDecode(signedTxJson);

      final response = await BaseApi.RequestEmpty_h.post(
        '$_gatewayUrl/transaction/send',
        params: {},
        data: txData,
        header: {'Content-Type': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['data'] != null) {
        mm.data = response['data']['txHash'];
      } else if (response != null && response['error'] != null) {
        mm.error = true;
        mm.data = response['error'] ?? 'Transaction failed';
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
      final response = await BaseApi.RequestEmpty_h.get(
        '$_apiUrl/transactions/$txHash',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['txHash'] != null) {
        mm.data = {
          'txHash': response['txHash'],
          'status': response['status'],
          'sender': response['sender'],
          'receiver': response['receiver'],
          'value': response['value'],
          'fee': response['fee'],
          'timestamp': response['timestamp'],
        };
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

  /// Get transaction status
  Future<MessageModel> getTransactionStatus(String txHash) async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_gatewayUrl/transaction/$txHash/status',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['data'] != null) {
        mm.data = response['data']['status'];
      } else {
        mm.error = true;
        mm.data = 'Status not found';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get address transactions
  Future<MessageModel> getTransactions(String address, {int size = 25}) async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_apiUrl/accounts/$address/transactions',
        params: {'size': size.toString()},
        header: {'Accept': 'application/json'},
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

  /// Get ESDT tokens for address
  Future<MessageModel> getTokens(String address) async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_apiUrl/accounts/$address/tokens',
        params: {},
        header: {'Accept': 'application/json'},
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

  /// Get NFTs for address
  Future<MessageModel> getNfts(String address, {int size = 25}) async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_apiUrl/accounts/$address/nfts',
        params: {'size': size.toString()},
        header: {'Accept': 'application/json'},
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
