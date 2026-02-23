import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/api_keys_config.dart';
import 'package:n42_wallet/src/https/base_api.dart';
import 'package:n42_wallet/src/https/request_url.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/src/sqlite/app_database.dart';
import 'package:n42_wallet/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/src/wallet/models/transaction/btc_response.dart';
import 'package:n42_wallet/src/wallet/models/transaction/btc_tran_detail.dart';
import 'package:n42_wallet/src/wallet/models/transaction/common_response_item_model.dart';
import 'package:n42_wallet/src/wallet/models/transaction/sol_transaction_item.dart';

class TransactionApi {
  /// ------- 对各种区块链进行查询 ----
  late Map<String,String> header;
  TransactionApi(){
    header={'content-type': 'application/json'};
  }
  AppDatabase? _db;
  AppDatabase get db{
    _db ??= AppDatabase();
    return _db!;
  }
  /// 非合约 交易列表
  Future<MessageModel> getTransactionList(
      String coinMiniName, String address,
      {int? page = 1, int? pageSize = 10,bool isTest=false}) async {
    try {
      switch (coinMiniName) {
        case "BTC":
        case "MOVR":
        case "GLMR":
        case "MTR":
        case "LTC":
        case "DASH":
        case "DOGE":
          return btcTransactionList(coinMiniName,address, page: page, offset: pageSize,isTest:isTest);
        case "ETH":
        case "ETC":
        case "HT":
        case "xDAI":
        case "N":
        case "MATIC":
        case "AVAX":
        case "CELO":
        case "BNB":
        case "FTM":
        case "POA":
        case "CLO":
        case "TOMO":
        case "TT":
        case "GO":
        case "WAN":
        case "KLAY":
        case "EVMOS":
        case "BOBA":
        case "KCS":
        case "KAVA":
        case "CRO":
        case "OP":
        case "ARB":
        case "AURORA":
        case "METIS":
          return await commonEthTransactionList(coinMiniName,address, page: page, offset: pageSize,isTest: isTest);
        case "OKT":
          return await commonEthTransactionList(coinMiniName,address, page: page, offset: pageSize);
        case "SOL":
          return await solTransactionList(address,page: page, offset: pageSize);
        case "TRX":
          return await trxTransactionList(address, page: page, offset: pageSize);
        case "DOT":
        case "KSM":
        case "ACA":
          return await dotTransactionList(address, coinMiniName, isTest: isTest);
        case "APT":
          return await aptTransactionList(address, isTest: isTest);
        case "TON":
          return await tonTransactionList(address, isTest: isTest);
      }
    } catch (e) {
      debugPrint('TransactionApi.getTransactionList: $e');
    } finally {}
    return MessageModel();
  }

  /// 合约 交易列表
  Future<MessageModel> getContractTransactionList(
      String coinMiniName, String address, String contractAddress,
      {int? page = 1, int? pageSize = 10,bool isTest=false}) async {
    try {
      switch (coinMiniName) {
        case "ETH":
        case "ETC":
        case "HT":
        case "xDAI":
        case "N":
        case "MATIC":
        case "AVAX":
        case "CELO":
        case "BNB":
        case "FTM":
        case "POA":
        case "CLO":
        case "TOMO":
        case "TT":
        case "GO":
        case "WAN":
        case "OKT":
        case "MTR":
        case "KLAY":
        case "GLMR":
        case "MOVR":
        case "EVMOS":
        case "BOBA":
        case "KCS":
        case "KAVA":
        case "CRO":
        case "OP":
        case "ARB":
        case "AURORA":
        case "METIS":
          return await commContractTransactionList(
              coinMiniName, address, contractAddress,
              page: page, offset: pageSize,isTest:isTest);
        case "TRX":
          return await trxContractTransactionList(address, contractAddress,
              page: page, offset: pageSize);
        case "SOL":
        // sol 的合约查询 和 主链一致 测试环境
        // 线上环境
          return await solTransactionList(address,page: page,offset: pageSize);
        default:
          break;
      }
    } catch (e) {
      debugPrint('TransactionApi.getContractTransactionList: $e');
    } finally {}
    return MessageModel();
  }

  /// 根据 miniName 获取对应区块链浏览器的host
  String? getHostByCoinMiniName(String key,{bool isTest=false}) {
    return RequestUrl().getUrl2(key, "api",isTest: isTest);
  }

  /// BTC 交易列表
  /// 目前测试通过  和线上可能差别较大
  /// https://blockchair.com/api/docs#link_203
  Future<MessageModel> btcTransactionList(String coinType,String address,
      {int? page = 1,
        int? offset = 10,
        int? fromBlock = 0,
        int? endBlock = 99999999999,
        bool isTest=false
      }) async {
    MessageModel mm=MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName(coinType,isTest: isTest);
      if(hostUrl==""){
        mm.data=null;
        return mm;
      }
      final url = '${hostUrl}addrs/$address';
      var data = await BaseApi.requestEmptyH.get(url, params: {},header: header);
      if (data != null) {
        BtcResponse res = BtcResponse.fromJson(data);
        List<Txref> txrefs = res.txrefs;
        List<BtcTranDetail> list = [];
        for (var element in txrefs) {
          List<BtcTransactionRecodeModel> rtrm=await db.selectBtcTransationRecordTxHash(element.txHash);
          if(rtrm.isNotEmpty){
            if(rtrm.first.outputModels?.isNotEmpty ?? false){
              continue;
            }
          }
          final innerUrl = '${hostUrl}txs/${element.txHash}';
          var inData = await BaseApi.requestEmptyH.get(innerUrl, params: {});
          if (inData != null) {
            BtcTranDetail bd = BtcTranDetail.fromJson(inData);
            list.add(bd);
          }
        }
        mm.data= list;
      } else {
        mm.error=true;
        mm.data=data["message"];
        //final err = data["message"];
      }
    } catch (e) {
      mm.error=true;
      mm.data=e.toString();
    }
    return mm;
  }


  ///SQL 交易列表
  /// SQL 文档地址 https://public-api.solscan.io/docs/#/
  Future<MessageModel> solTransactionList(String address,
      {int? fromBlock = 0,
        int? endBlock = 99999999999,
        int? page = 1,
        int? offset = 10}) async {
    MessageModel mm=MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName('SOL');
      //eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3MjI4NDg0NTUxODAsImVtYWlsIjoiamlhbmd5aXdlaUBzdGFybGluay13b3JsZC5jbiIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MSIsImlhdCI6MTcyMjg0ODQ1NX0.nN1kusKNvwXb_SUnpFrhsHoYfUuArbiLqC4HHk5UnNI
      String requestUrl =
          '${hostUrl}account/solTransfers?account=$address&limit=$offset&offset=$page';
      Map<String,String> h=header;
      h['token']="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3MjI4NDg0NTUxODAsImVtYWlsIjoiamlhbmd5aXdlaUBzdGFybGluay13b3JsZC5jbiIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MSIsImlhdCI6MTcyMjg0ODQ1NX0.nN1kusKNvwXb_SUnpFrhsHoYfUuArbiLqC4HHk5UnNI";
      var data = await BaseApi.requestEmptyH.get(requestUrl, params: {},header: h);
      if (data != null) {
        final res = data['data'];
        List<SOLTransactionItem> list =
        (res as List).map((e) => SOLTransactionItem.fromJson(e)).toList();
        mm.data=list;
      } else {
        mm.error=true;
        mm.data=data["message"];
        //final err = data["message"];
      }
    } catch (e) {
      mm.error=true;
      mm.data=e.toString();
    }
    return mm;
  }

  ///TRX 交易列表
  /// TRX 文档地址 https://cn.developers.tron.network/reference/get-transaction-info-by-account-address
  Future<MessageModel> trxTransactionList(String address,
      {int? fromBlock = 0,
        int? endBlock = 99999999999,
        int? page = 1,
        int? offset = 999999}) async {
    MessageModel mm=MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName('TRX');
      //https://apilist.tronscan.org/api/transaction?sort=-timestamp&count=true&limit=20&start=0&address=TMuA6YqfCeX8EhbfYEg5y7S4DqzSJireY9
      //https://nileapi.tronscan.org/api/transaction?address=TU7QQsDsJUNmsaduLVNSTrqzk2e72n5VdA
      String requestUrl ='${hostUrl}transaction?address=$address&limit=$offset&start=$page&sort=-timestamp&count=true';
      Map<String,String> h=header;
      h['TRON-PRO-API-KEY']="1908ecd1-99f1-4480-9353-c5a643b907b4";
      var data = await BaseApi.requestEmptyH.get(requestUrl, params: {},header: h);
      if (data != null) {
        final res = data['data'];
        List<CommonResponseItemModel> list =
        (res as List).map((e){
          CommonResponseItemModel item = CommonResponseItemModel.fromJson(e);
          item.blockHash=e['block'].toString();
          item.hash=e['hash'] as String;
          item.timeStamp = e['timestamp'].toString();
          item.from = e['ownerAddress'] as String;
          item.to = e['toAddress'] as String;
          item.value=e['amount'] as String;
          final triggerInfo=e['trigger_info'];
          if(triggerInfo !=null){
            item.contractAddress=e['trigger_info']['contract_address']??"";
            if(item.contractAddress !="" ){
              item.to=e['trigger_info']['parameter']['_to']??"";
              item.value=e['trigger_info']['parameter']['_value']??"";
            }
          }
          return item;
        }).toList();
        mm.data= list;
      } else {
        mm.data="Error";
        mm.error=true;
      }
    } catch (e) {
      mm.data=e.toString();
      mm.error=true;
    }
    return mm;
  }

  ///TRX 交易列表
  /// TRX 文档地址 https://cn.developers.tron.network/reference/get-transaction-info-by-account-address
  Future<MessageModel> trxContractTransactionList(String address,String contractAddress,
      {int? fromBlock = 0,
        int? endBlock = 99999999999,
        int? page = 1,
        int? offset = 999999}) async {
    MessageModel mm=MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName('TRX');
      //https://apilist.tronscan.org/api/transaction?sort=-timestamp&count=true&limit=20&start=0&address=TMuA6YqfCeX8EhbfYEg5y7S4DqzSJireY9
      //https://nileapi.tronscan.org/api/transaction?address=TU7QQsDsJUNmsaduLVNSTrqzk2e72n5VdA
      String requestUrl ='${hostUrl}transaction?address=$address&limit=$offset&start=$page&sort=-timestamp&count=true';
      Map<String,String> h=header;
      h['TRON-PRO-API-KEY']="1908ecd1-99f1-4480-9353-c5a643b907b4";
      var data = await BaseApi.requestEmptyH.get(requestUrl, params: {},header: h);
      if (data != null) {
        final res = data['data'];
        List<CommonResponseItemModel> list =
        (res as List).map((e){
          CommonResponseItemModel item = CommonResponseItemModel.fromJson(e);
          item.blockHash=e['block'].toString();
          item.hash=e['hash'] as String;
          item.timeStamp = e['timestamp'].toString();
          item.from = e['ownerAddress'] as String;
          //item.to = e['toAddress'] as String;
          //item.value=e['amount'] as String;
          final triggerInfo=e['trigger_info'];
          if(triggerInfo !=null){
            item.contractAddress=e['trigger_info']['contract_address']??"";
            if(item.contractAddress !="" ){
              item.to=e['trigger_info']['parameter']['_to']??"";
              item.value=e['trigger_info']['parameter']['_value']??"";
            }
          }
          return item;
        }).toList();
        mm.data= list;
      } else {
        mm.data="Error";
        mm.error=true;
      }
    } catch (e) {
      mm.data=e.toString();
      mm.error=true;
    }
    return mm;
  }
 //TRX 根据 交易hash获取交易信息
  Future<MessageModel> trxTransactionInfoHash(String hash)async{
    MessageModel mm=MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName('TRX');
      String requestUrl ='${hostUrl}transaction-info?hash=$hash';
      Map<String,String> h=header;
      h['TRON-PRO-API-KEY']="1908ecd1-99f1-4480-9353-c5a643b907b4";
      var data = await BaseApi.requestEmptyH.get(requestUrl, params: {},header: h);
      if (data != null) {
        mm.data= data;
      } else {
        mm.data="Error";
        mm.error=true;
      }
    } catch (e) {
      mm.data=e.toString();
      mm.error=true;
    }
    return mm;
  }

  /// 「以太坊 」类型的 货币
  /// 对 "blockchain": 属于"Ethereum",的币种类统一处理
  /// 返回的结果和查询的方式一致
  Future<MessageModel> commonEthTransactionList(
      String miniName,
      String address,
      {int? fromBlock = 0,
        int? endBlock = 99999999999,
        int? page = 1,
        int? offset = 10,bool isTest=false}) async {
    MessageModel mm=MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName(miniName,isTest: isTest);
      if(hostUrl==""){
        mm.error=true;
        mm.data=null;
        return mm;
      }
      String endblockStr="";
      if(endBlock!=null){
        endblockStr='&endblock=$endBlock';
      }
      String requestUrl =
          '${hostUrl}module=account&action=txlist&address=$address&startblock=$fromBlock&page=$page&offset=$offset&sort=desc$endblockStr';
      var data = await BaseApi.requestEmptyH.get(requestUrl, params: {},header: header);

      if (data != null && data["status"] == '1') {
        final response = data["result"];
        List<CommonResponseItemModel> list =
        (response as List).map((e) => CommonResponseItemModel.fromJson(e)).toList();
        mm.data=list;
      } else {
        mm.error=true;
        mm.data=data["message"];
      }
    } catch (e) {
      mm.error=true;
      mm.data=e.toString();
    }
    return mm;
  }
  // ---------------------------------------------------------------------------
  // DOT / Polkadot — Subscan API v2
  // ---------------------------------------------------------------------------

  /// DOT、KSM、ACA 交易列表，via Subscan transfers API
  Future<MessageModel> dotTransactionList(
    String address,
    String coinType, {
    bool isTest = false,
  }) async {
    MessageModel mm = MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName(coinType, isTest: isTest);
      if (hostUrl == null || hostUrl.isEmpty) {
        mm.data = null;
        return mm;
      }
      final url = '${hostUrl}api/v2/scan/transfers';
      final h = Map<String, String>.from(header)
        ..['x-api-key'] = ApiKeysConfig.dotApiKey;
      final data = await BaseApi.requestEmptyH.post(
        url,
        params: {},
        data: {'address': address, 'row': 25, 'page': 0},
        header: h,
      );
      if (data != null && data['code'] == 0) {
        final transfers = data['data']['transfers'] as List? ?? [];
        final list = transfers.map<CommonResponseItemModel>((e) {
          final item = CommonResponseItemModel();
          item.hash =
              e['extrinsic_hash'] as String? ?? e['hash'] as String? ?? '';
          item.from = e['from'] as String? ?? '';
          item.to = e['to'] as String? ?? '';
          // Subscan returns human-readable amounts (e.g. "1.5000000000")
          // DOT decimals = 10; KSM = 12; ACA = 12
          final decimals = coinType == 'DOT' ? 10 : 12;
          final amountStr = e['amount'] as String? ?? '0';
          item.value = _parseToSmallestUnit(amountStr, decimals).toString();
          item.timeStamp =
              (e['block_timestamp'] as int?)?.toString() ?? '0';
          item.txreceiptStatus = (e['success'] == true) ? '1' : '0';
          item.gas = '0';
          item.gasPrice = '0';
          item.contractAddress = '';
          return item;
        }).toList();
        mm.data = list;
      } else {
        mm.error = true;
        mm.data = data?['message'] ?? 'Subscan error';
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  // ---------------------------------------------------------------------------
  // APT / Aptos — Aptos REST API
  // ---------------------------------------------------------------------------

  /// APT 交易列表，via Aptos REST `/accounts/{addr}/transactions`
  Future<MessageModel> aptTransactionList(
    String address, {
    bool isTest = false,
  }) async {
    MessageModel mm = MessageModel();
    try {
      final rpcUrl = RequestUrl().getUrl2('APT', 'rpc', isTest: isTest);
      if (rpcUrl.isEmpty) {
        mm.data = null;
        return mm;
      }
      final url = '${rpcUrl}accounts/$address/transactions?limit=25';
      final data =
          await BaseApi.requestEmptyH.get(url, params: {}, header: header);
      if (data is List) {
        final list = data
            .map<CommonResponseItemModel?>((e) {
              if (e['type'] != 'user_transaction') return null;
              final item = CommonResponseItemModel();
              item.hash = e['hash'] as String? ?? '';
              item.from = e['sender'] as String? ?? '';
              // Extract recipient and amount from payload arguments
              final payload = e['payload'] as Map<String, dynamic>?;
              final args = payload?['arguments'] as List?;
              item.to =
                  (args != null && args.isNotEmpty) ? args[0].toString() : '';
              item.value = (args != null && args.length > 1)
                  ? args[1].toString()
                  : '0'; // octas (10^8 per APT)
              // Aptos timestamp is in microseconds
              final tsMicro =
                  int.tryParse(e['timestamp']?.toString() ?? '0') ?? 0;
              item.timeStamp = (tsMicro ~/ 1000000).toString();
              item.txreceiptStatus = (e['success'] == true) ? '1' : '0';
              final gasUsed =
                  int.tryParse(e['gas_used']?.toString() ?? '0') ?? 0;
              final gasUnitPrice =
                  int.tryParse(e['gas_unit_price']?.toString() ?? '0') ?? 0;
              item.gas = gasUsed.toString();
              item.gasPrice = (gasUsed * gasUnitPrice).toString(); // octas
              item.contractAddress = '';
              return item;
            })
            .whereType<CommonResponseItemModel>()
            .toList();
        mm.data = list;
      } else {
        mm.error = true;
        mm.data = 'Aptos API error';
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  // ---------------------------------------------------------------------------
  // TON — TON Center v2 API
  // ---------------------------------------------------------------------------

  /// TON 交易列表，via TON Center v2 `/getTransactions`
  Future<MessageModel> tonTransactionList(
    String address, {
    bool isTest = false,
  }) async {
    MessageModel mm = MessageModel();
    try {
      final rpcUrl = RequestUrl().getUrl2('TON', 'rpc', isTest: isTest);
      if (rpcUrl.isEmpty) {
        mm.data = null;
        return mm;
      }
      final url = '${rpcUrl}getTransactions?address=$address&limit=20';
      final data =
          await BaseApi.requestEmptyH.get(url, params: {}, header: header);
      if (data != null && data['ok'] == true) {
        final txList = data['result'] as List? ?? [];
        final list = txList
            .map<CommonResponseItemModel?>((e) {
              try {
                final inMsg = e['in_msg'] as Map<String, dynamic>?;
                if (inMsg == null) return null;
                final item = CommonResponseItemModel();
                final txId = e['transaction_id'] as Map<String, dynamic>?;
                item.hash = txId?['hash'] as String? ?? '';
                item.from = inMsg['source'] as String? ?? '';
                item.to = inMsg['destination'] as String? ?? address;
                item.value = inMsg['value']?.toString() ?? '0'; // nanoTON
                item.timeStamp = e['utime']?.toString() ?? '0'; // Unix seconds
                item.txreceiptStatus = '1'; // listed ⇒ confirmed
                item.gasPrice = e['fee']?.toString() ?? '0'; // total nanoTON
                item.gas = '0';
                item.contractAddress = '';
                return item;
              } catch (_) {
                return null;
              }
            })
            .whereType<CommonResponseItemModel>()
            .toList();
        mm.data = list;
      } else {
        mm.error = true;
        mm.data = 'TON API error';
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  /// 将人类可读的小数金额字符串（如 "1.5000000000"）转换为最小单位 BigInt
  static BigInt _parseToSmallestUnit(String amount, int decimals) {
    try {
      final parts = amount.split('.');
      final intPart = BigInt.parse(parts[0].isEmpty ? '0' : parts[0]);
      final fracRaw = parts.length > 1 ? parts[1] : '';
      final fracPadded =
          fracRaw.padRight(decimals, '0').substring(0, decimals);
      final fracPart = BigInt.parse(fracPadded);
      return intPart * BigInt.from(10).pow(decimals) + fracPart;
    } catch (_) {
      return BigInt.zero;
    }
  }

  /// ------- 合约 代币 交易列表 -------
  ///目前支持的有 ast bnb  ETH avax ftm CELO ht
  Future<MessageModel> commContractTransactionList(
      String name, String address, String contractAddress,
      {int? fromBlock = 0,
        int? endBlock = 99999999999,
        int? page = 1,
        int? offset = 10,
        bool isTest=false,
      }) async {
    MessageModel mm=MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName(name,isTest:isTest);
      if(hostUrl==""){
        mm.data=null;
        return mm;
      }
      String requestUrl =
          '${hostUrl}module=account&action=tokentx&address=$address&contractaddress=$contractAddress&startblock=$fromBlock&endblock=$endBlock&page=$page&offset=$offset&sort=desc';
      var data = await BaseApi.requestEmptyH.get(requestUrl, params: {},header: header);
      if (data != null && data["status"] == '1') {
        final response = data["result"];
        /*List<BNBItemModel> list = (response as List)
            .map((e) => BNBItemModel.fromJson(e))
            .toList();*/
        mm.data= (response as List).map((e) => CommonResponseItemModel.fromJson(e)).toList();
      } else {
        mm.error=true;
        mm.data=data["message"];
        //final err = data["message"];
      }
    } catch (e) {
      mm.error=true;
      mm.data=e.toString();
    }
    return mm;
  }
}
