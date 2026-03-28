import 'package:flutter/foundation.dart';
// api_keys_config removed — API keys migrated to server proxy.
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/models/transaction/explorer_response_utils.dart';
import 'package:n42_wallet/features/wallet/models/transaction/btc_response.dart';
import 'package:n42_wallet/features/wallet/models/transaction/btc_tran_detail.dart';
import 'package:n42_wallet/features/wallet/models/transaction/common_response_item_model.dart';
import 'package:n42_wallet/features/wallet/models/transaction/sol_transaction_item.dart';

part 'transaction_api_btc_sol_trx.dart';
part 'transaction_api_eth_dot_apt_ton.dart';

class TransactionApi {
  late Map<String, String> header;

  TransactionApi() {
    header = {'content-type': 'application/json'};
  }

  AppDatabase? _db;

  AppDatabase get db {
    _db ??= AppDatabase();
    return _db!;
  }

  /// 根据 miniName 获取对应区块链浏览器的 host
  String? getHostByCoinMiniName(String key, {bool isTest = false}) {
    return RequestUrl().getUrl2(key, 'api', isTest: isTest);
  }

  /// 非合约 交易列表
  Future<MessageModel> getTransactionList(
    String coinMiniName,
    String address, {
    int? page = 1,
    int? pageSize = 10,
    bool isTest = false,
  }) async {
    try {
      switch (coinMiniName) {
        case 'BTC':
        case 'MOVR':
        case 'GLMR':
        case 'MTR':
        case 'LTC':
        case 'DASH':
        case 'DOGE':
          return btcTransactionList(coinMiniName, address,
              page: page, offset: pageSize, isTest: isTest);
        case 'ETH':
        case 'ETC':
        case 'HT':
        case 'xDAI':
        case 'N':
        case 'MATIC':
        case 'AVAX':
        case 'CELO':
        case 'BNB':
        case 'FTM':
        case 'POA':
        case 'CLO':
        case 'TOMO':
        case 'TT':
        case 'GO':
        case 'WAN':
        case 'KLAY':
        case 'EVMOS':
        case 'BOBA':
        case 'KCS':
        case 'KAVA':
        case 'CRO':
        case 'OP':
        case 'ARB':
        case 'AURORA':
        case 'METIS':
          return await commonEthTransactionList(coinMiniName, address,
              page: page, offset: pageSize, isTest: isTest);
        case 'OKT':
          return await commonEthTransactionList(coinMiniName, address,
              page: page, offset: pageSize);
        case 'SOL':
          return await solTransactionList(address, page: page, offset: pageSize);
        case 'TRX':
          return await trxTransactionList(address, page: page, offset: pageSize);
        case 'DOT':
        case 'KSM':
        case 'ACA':
          return await dotTransactionList(address, coinMiniName, isTest: isTest);
        case 'APT':
          return await aptTransactionList(address, isTest: isTest);
        case 'TON':
          return await tonTransactionList(address, isTest: isTest);
      }
    } catch (e) {
      debugPrint('TransactionApi.getTransactionList: $e');
    }
    return MessageModel();
  }

  /// 合约 交易列表
  Future<MessageModel> getContractTransactionList(
    String coinMiniName,
    String address,
    String contractAddress, {
    int? page = 1,
    int? pageSize = 10,
    bool isTest = false,
  }) async {
    try {
      switch (coinMiniName) {
        case 'ETH':
        case 'ETC':
        case 'HT':
        case 'xDAI':
        case 'N':
        case 'MATIC':
        case 'AVAX':
        case 'CELO':
        case 'BNB':
        case 'FTM':
        case 'POA':
        case 'CLO':
        case 'TOMO':
        case 'TT':
        case 'GO':
        case 'WAN':
        case 'OKT':
        case 'MTR':
        case 'KLAY':
        case 'GLMR':
        case 'MOVR':
        case 'EVMOS':
        case 'BOBA':
        case 'KCS':
        case 'KAVA':
        case 'CRO':
        case 'OP':
        case 'ARB':
        case 'AURORA':
        case 'METIS':
          return await commContractTransactionList(
              coinMiniName, address, contractAddress,
              page: page, offset: pageSize, isTest: isTest);
        case 'TRX':
          return await trxContractTransactionList(address, contractAddress,
              page: page, offset: pageSize);
        case 'SOL':
          // SOL 合约查询与主链一致
          return await solTransactionList(address, page: page, offset: pageSize);
        default:
          break;
      }
    } catch (e) {
      debugPrint('TransactionApi.getContractTransactionList: $e');
    }
    return MessageModel();
  }
}
