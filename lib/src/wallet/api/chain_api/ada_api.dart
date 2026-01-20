import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

/// Cardano (ADA) API - Using Blockfrost API
class AdaApi {
  final bool isTest;
  late String _baseUrl;
  late String _apiKey;

  AdaApi({this.isTest = false}) {
    _baseUrl = isTest
        ? 'https://cardano-preprod.blockfrost.io/api/v0'
        : 'https://cardano-mainnet.blockfrost.io/api/v0';
    // Note: In production, API key should be stored securely
    _apiKey = '';
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'project_id': _apiKey,
      };

  /// Set API key for Blockfrost
  void setApiKey(String key) {
    _apiKey = key;
  }

  /// Get account info (stake address)
  Future<MessageModel> getAccountInfo(String stakeAddress) async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_baseUrl/accounts/$stakeAddress',
        params: {},
        header: _headers,
      );

      MessageModel mm = MessageModel();
      if (response != null && response['controlled_amount'] != null) {
        mm.data = {
          'balance': BigInt.parse(response['controlled_amount'] ?? '0'),
          'rewards_sum': response['rewards_sum'] ?? '0',
          'withdrawals_sum': response['withdrawals_sum'] ?? '0',
          'reserves_sum': response['reserves_sum'] ?? '0',
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

  /// Get address UTXOs
  Future<MessageModel> getAddressUtxos(String address) async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_baseUrl/addresses/$address/utxos',
        params: {},
        header: _headers,
      );

      MessageModel mm = MessageModel();
      if (response != null && response is List) {
        List<Map<String, dynamic>> utxos = [];
        for (var utxo in response) {
          // Sum up lovelace amount from the utxo
          BigInt amount = BigInt.zero;
          if (utxo['amount'] != null) {
            for (var a in utxo['amount']) {
              if (a['unit'] == 'lovelace') {
                amount = BigInt.parse(a['quantity'] ?? '0');
                break;
              }
            }
          }
          utxos.add({
            'txHash': utxo['tx_hash'],
            'outputIndex': utxo['output_index'],
            'amount': amount.toString(),
            'address': address,
          });
        }
        mm.data = utxos;
      } else if (response != null && response['error'] != null) {
        // No UTXOs means empty list
        mm.data = <Map<String, dynamic>>[];
      } else {
        mm.data = <Map<String, dynamic>>[];
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get address balance (sum of UTXOs)
  Future<MessageModel> getBalance(String address) async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_baseUrl/addresses/$address',
        params: {},
        header: _headers,
      );

      MessageModel mm = MessageModel();
      if (response != null && response['amount'] != null) {
        BigInt balance = BigInt.zero;
        for (var amount in response['amount']) {
          if (amount['unit'] == 'lovelace') {
            balance = BigInt.parse(amount['quantity'] ?? '0');
            break;
          }
        }
        mm.data = balance;
      } else if (response != null && response['status_code'] == 404) {
        // Address not found means balance is 0
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

  /// Get current protocol parameters (for fee calculation)
  Future<MessageModel> getProtocolParameters() async {
    try {
      final latestEpoch = await BaseApi.RequestEmpty_h.get(
        '$_baseUrl/epochs/latest',
        params: {},
        header: _headers,
      );

      if (latestEpoch == null || latestEpoch['epoch'] == null) {
        MessageModel mm = MessageModel.error();
        mm.data = 'Failed to get current epoch';
        return mm;
      }

      final response = await BaseApi.RequestEmpty_h.get(
        '$_baseUrl/epochs/${latestEpoch['epoch']}/parameters',
        params: {},
        header: _headers,
      );

      MessageModel mm = MessageModel();
      if (response != null) {
        mm.data = {
          'minFeeA': response['min_fee_a'],
          'minFeeB': response['min_fee_b'],
          'maxTxSize': response['max_tx_size'],
          'coinsPerUtxoByte': response['coins_per_utxo_size'],
        };
      } else {
        mm.error = true;
        mm.data = 'Failed to get protocol parameters';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Get latest block info (for TTL calculation)
  Future<MessageModel> getLatestBlock() async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_baseUrl/blocks/latest',
        params: {},
        header: _headers,
      );

      MessageModel mm = MessageModel();
      if (response != null && response['slot'] != null) {
        mm.data = {
          'slot': response['slot'],
          'height': response['height'],
          'hash': response['hash'],
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

  /// Submit signed transaction
  Future<MessageModel> submitTransaction(String signedTxHex) async {
    try {
      final response = await BaseApi.RequestEmpty_h.post(
        '$_baseUrl/tx/submit',
        data: signedTxHex,
        header: {
          'Content-Type': 'application/cbor',
          'project_id': _apiKey,
        }, params: {},
      );

      MessageModel mm = MessageModel();
      if (response != null && response is String) {
        mm.data = response; // Returns tx hash
      } else if (response != null && response['error'] != null) {
        mm.error = true;
        mm.data = response['message'] ?? 'Transaction submission failed';
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

  /// Get transaction info by hash
  Future<MessageModel> getTransaction(String txHash) async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_baseUrl/txs/$txHash',
        params: {},
        header: _headers,
      );

      MessageModel mm = MessageModel();
      if (response != null && response['hash'] != null) {
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

  /// Get transaction UTXOs
  Future<MessageModel> getTransactionUtxos(String txHash) async {
    try {
      final response = await BaseApi.RequestEmpty_h.get(
        '$_baseUrl/txs/$txHash/utxos',
        params: {},
        header: _headers,
      );

      MessageModel mm = MessageModel();
      if (response != null) {
        mm.data = {
          'inputs': response['inputs'],
          'outputs': response['outputs'],
        };
      } else {
        mm.error = true;
        mm.data = 'Transaction UTXOs not found';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
}
