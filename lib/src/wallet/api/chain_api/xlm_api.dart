import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

/// Stellar (XLM) API
class XlmApi {
  final bool isTest;
  late String _baseUrl;

  XlmApi({this.isTest = false}) {
    _baseUrl = isTest
        ? 'https://horizon-testnet.stellar.org'
        : 'https://horizon.stellar.org';
  }

  /// Get account balance
  Future<MessageModel> getBalance(String address) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/accounts/$address',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['balances'] != null) {
        final balances = response['balances'] as List;
        // Find native XLM balance
        final xlmBalance = balances.firstWhere(
          (b) => b['asset_type'] == 'native',
          orElse: () => {'balance': '0'},
        );
        // Convert to stroops (1 XLM = 10^7 stroops)
        final balance = double.parse(xlmBalance['balance'] ?? '0');
        mm.data = BigInt.from(balance * 10000000);
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

  /// Get account info including sequence number
  Future<MessageModel> getAccountInfo(String address) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/accounts/$address',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['sequence'] != null) {
        mm.data = {
          'sequence': response['sequence'],
          'balances': response['balances'],
          'subentry_count': response['subentry_count'],
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

  /// Get current base fee
  Future<MessageModel> getBaseFee() async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/fee_stats',
        params: {},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['last_ledger_base_fee'] != null) {
        mm.data = BigInt.from(int.parse(response['last_ledger_base_fee']));
      } else {
        // Default base fee is 100 stroops
        mm.data = BigInt.from(100);
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Submit signed transaction
  Future<MessageModel> submitTransaction(String signedTxXdr) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        '$_baseUrl/transactions',
        params: {'tx': signedTxXdr},
        data: {'tx': signedTxXdr},
        header: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['hash'] != null) {
        mm.data = response['hash'];
      } else if (response != null && response['extras'] != null) {
        mm.error = true;
        mm.data = response['extras']['result_codes']?.toString() ?? 'Transaction failed';
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

  /// Get transaction history
  Future<MessageModel> getTransactions(String address, {int limit = 20}) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/accounts/$address/transactions',
        params: {'limit': limit.toString(), 'order': 'desc'},
        header: {'Accept': 'application/json'},
      );

      MessageModel mm = MessageModel();
      if (response != null && response['_embedded'] != null) {
        mm.data = response['_embedded']['records'] ?? [];
      } else {
        mm.error = true;
        mm.data = 'Failed to fetch transactions';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
}
