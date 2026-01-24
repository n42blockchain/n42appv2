import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42appv2/src/wallet/models/transaction/btc_response.dart';
import 'package:n42appv2/src/wallet/models/transaction/btc_tran_detail.dart';
import 'package:n42appv2/src/wallet/models/transaction/common_response_item_model.dart';
import 'package:n42appv2/src/wallet/models/transaction/sol_transaction_item.dart';
//import 'package:n42appv2/src/wallet/models/transaction/trx_transaction_item.dart';
//import 'package:n42appv2/src/wallet/utils/chain_browser_url.dart';

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
          //final data =
          return btcTransactionList(coinMiniName,address, page: page, offset: pageSize,isTest:isTest);
          /*final list = (data as List)
              .map((e) => CommonResponseItemModel.fromJson(e.toJson()))
              .toList();
          return list;*/
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
      }
    } catch (_) {
      // 错误安全忽略
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
    } catch (_) {
      // 错误安全忽略
    } finally {}
    return MessageModel();
  }

  /// 根据 miniName 获取对应区块链浏览器的host
  String? getHostByCoinMiniName(String key,{bool isTest=false}) {
    return RequestUrl().getUrl2(key, "api",isTest: isTest);
    /*return isTest
        ? urlMap[key]?.testApi
        : urlMap[key]?.api;*/
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
      var data = await BaseApi.RequestEmpty_h.get(url, params: {},header: header);
      if (data != null) {
        BtcResponse res = BtcResponse.fromJson(data);
        List<Txref> txrefs = res.txrefs;
        List<BtcTranDetail> list = [];
        for (var element in txrefs) {
          List<BtcTransactionRecodeModel> rtrm=await db.selectBtcTransationRecord_txHash(element.txHash);
          if(rtrm.isNotEmpty){
            if(rtrm.first.outputModels?.isNotEmpty ?? false){
              continue;
            }
          }
          final innerUrl = '${hostUrl}txs/${element.txHash}';
          var inData = await BaseApi.RequestEmpty_h.get(innerUrl, params: {});
          if (inData != null) {
            BtcTranDetail bd = BtcTranDetail.fromJson(inData);
            //CommonResponseItemModel item = CommonResponseItemModel();
            /*List<Output>? outs = bd.outputs;
            //设置 发送 和 接收地址
            if (outs != null) {
              item.from = outs[1].addresses?[0];
              item.to = outs[0].addresses?[0];
            }
            item.hash = bd.hash;
            item.value = "${bd.total}";
            item.gasPrice = "${bd.fees}";*/
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
      var data = await BaseApi.RequestEmpty_h.get(requestUrl, params: {},header: h);
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
      var data = await BaseApi.RequestEmpty_h.get(requestUrl, params: {},header: h);
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
          //'${hostUrl}token_trc20/transfers?relatedAddress=$address&contract_address=$contractAddress&limit=$offset&start=$page&sort=-timestamp&count=true';
      Map<String,String> h=header;
      h['TRON-PRO-API-KEY']="1908ecd1-99f1-4480-9353-c5a643b907b4";
      var data = await BaseApi.RequestEmpty_h.get(requestUrl, params: {},header: h);
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
      //'${hostUrl}token_trc20/transfers?relatedAddress=$address&contract_address=$contractAddress&limit=$offset&start=$page&sort=-timestamp&count=true';
      Map<String,String> h=header;
      h['TRON-PRO-API-KEY']="1908ecd1-99f1-4480-9353-c5a643b907b4";
      var data = await BaseApi.RequestEmpty_h.get(requestUrl, params: {},header: h);
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
      var data = await BaseApi.RequestEmpty_h.get(requestUrl, params: {},header: header);

      if (data != null && data["status"] == '1') {
        final response = data["result"];
        List<CommonResponseItemModel> list =
        (response as List).map((e) => CommonResponseItemModel.fromJson(e)).toList();
        mm.data=list;
        //return list;
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
  Future<MessageModel> commonEthTransactionList2(
      String miniName,
      String address,
      {
        int? page = 1,
        int? offset = 10}) async {
    MessageModel mm=MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName(miniName);
      if(hostUrl==""){
        mm.error=true;
        mm.data=[];
        return mm;
      }
      String requestUrl =
          '${hostUrl}address/normal/tx/list?coin=$miniName&addr=$address&page=$page&page_size=$offset';
      var data = await BaseApi.RequestEmpty_h.get(requestUrl, params: {},header: header);
      if (data != null && data["status"] == '1') {
        final response = data["result"];
        List<CommonResponseItemModel> list =
        (response as List).map((e) => CommonResponseItemModel.fromJson(e)).toList();
        mm.data=list;
        //return list;
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
      var data = await BaseApi.RequestEmpty_h.get(requestUrl, params: {},header: header);
      if (data != null && data["status"] == '1') {
        final response = data["result"];
        /*List<BNBItemModel> list = (response as List)
            .map((e) => BNBItemModel.fromJson(e))
            .toList();*/
        mm.data= (response as List).map((e) => CommonResponseItemModel.fromJson(e)).toList();
        //return list;
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
/*
  ///sol 获取合约交易列表
  Future<List<SOLTransactionItem>?> solContractTransactionList(
      String name, String address, String contractAddress,
      {int? fromBlock = 0,
        int? endBlock = 99999999999,
        int? page = 1,
        int? offset = 10}) async {
    try {
      final hostUrl = getHostByCoinMiniName('SOL');
      final isTestApi = false;//ProviderUtil.publicProvider().isTestApi;
      if (isTestApi) {
        //测试地址和返回数据差别较大 单独处理
        //https://api-testnet.solscan.io/account/transaction?address=DYNLXDDjF3j6VYscFJY3FNyyNpxohfWgrSmPhgT8mbwK
        //https://api-testnet.solscan.io/account/transaction?address=7ViD4q77VfADUiE2euhBVmrvYrrMJW3bFbjcgvujmAyZ

      } else {
        //正式环境
        //https://public-api.solscan.io/account/splTransfers?account=1212121&offset=0&limit=10
        String requestUrl =
            '${hostUrl}account/splTransfers?account=${address}&limit=${offset}&offset=${page}';

        var data = await BaseApi.RequestEmpty_h.get(requestUrl, params: {},header: header);

        if (data != null) {
          final res = data['data'];
          // todo model 需重新定义
          List<SOLTransactionItem> list =
          (res as List).map((e) => SOLTransactionItem.fromJson(e)).toList();
          return list;
        } else {
          final err = data["message"];

        }
      }
    } catch (e) {

    }
    return null;
  }
*/
////-----------------------end----------------------------------

}
