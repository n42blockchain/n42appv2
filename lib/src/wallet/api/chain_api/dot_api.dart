import 'package:dio/dio.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/utils/message_model_bridge.dart';
import 'package:n42appv2/core/utils/result.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';

class DotApi{
  //获取余额
  Future<MessageModel> getTokens(String address,String coinType,{bool isTest=false})async{
    try{
      MessageModel mm=MessageModel();
      String url=RequestUrl().getUrl2(coinType, "api",isTest: isTest);
      url="${url}api/scan/account/tokens";
      Map<String,dynamic> pMap={
        "address":address
      };
      final data=await BaseApi.requestEmptyH.post(url, params: {},data: pMap,header: {"x-api-key":"2b9bd66238b546acafe57b2a05ff97e0"});
      if(data['code'] !=0){
        mm.error=true;
        mm.data="error";
      }else{
        if(data['data']['native']==null){
          mm.data=BigInt.zero;
        }else{
          bool find=false;
          for(Map c in data['data']['native']){
            //if(c['symbol']==coinType){
              mm.data=BigInt.parse(c['balance']);
              find=true;
            //}
          }
          if(find==false){
            mm.data=BigInt.zero;
          }
        }
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  //GenesisHash=0和BlockHash=nll
  Future<MessageModel> getGenesisHash({int? index,bool isTest=false})async {
    return resultToMessageModel(
      await baseRPC("chain_getBlockHash",index==null?[]:[index],isTest: isTest),
    );
  }
  Future<MessageModel> getNonce(String address,{bool isTest=false})async{
    return resultToMessageModel(
      await baseRPC("system_accountNextIndex",[address],isTest: isTest),
    );
  }
  Future<MessageModel> getChainHeader({bool isTest=false})async{
    return resultToMessageModel(
      await baseRPC("chain_getHeader",[],isTest: isTest),
    );
  }
  //获取specVersion、TransactionVersion
  Future<MessageModel> getRuntimeVersion({bool isTest=false})async {
    return resultToMessageModel(
      await baseRPC("state_getRuntimeVersion",[],isTest: isTest),
    );
    /*{
  "jsonrpc": "2.0",
  "result": {
    "specName": "polkadot",
    "implName": "parity-polkadot",
    "authoringVersion": 1,
    "specVersion": 9430,
    "implVersion": 1,
    "apis": [...],
    "transactionVersion": 20,
    "stateVersion": 0
  },
  "id": 1
}
    * */
  }
  //发送交易（明确禁用重试，防止双发）
  Future<MessageModel> submitTxHash(String hash,{bool isTest=false})async{
    return resultToMessageModel(
      await baseRPC("author_submitExtrinsic",[hash],isTest: isTest,enableRetry: false),
    );
  }
  //估算gas费
  Future<MessageModel> getGasPrice(String txHash,{bool isTest=false})async{
    return resultToMessageModel(
      await baseRPC("payment_queryInfo",[txHash],isTest: isTest),
    );
  }
  Future<Result<dynamic, AppError>> baseRPC(
    String method,
    var value, {
    bool? isTest = false,
    bool enableRetry = true,
  }) async {
    try {
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":value,"id":AppGlobals.nextId};
      final data=await BaseApi.requestEmptyH.post(
        RequestUrl().getUrl2(CoinType.DOT.name, "rpc",isTest: isTest),
        params: {},
        data: postData,
        enableRetry: enableRetry,
      );
      if(data.containsKey('error')){
        final errorMsg = data['error'] is Map
            ? (data['error']['message']?.toString() ?? 'RPC error')
            : data['error']?.toString() ?? 'RPC error';
        return Result.failure(AppError.blockchain(
          errorMsg,
          code: 'DOT_RPC_ERROR',
          originalError: data['error'],
        ));
      }
      return Result.success(data['result']);
    } on DioException catch (e) {
      return Result.failure(AppError.network(
        e.message ?? 'Network error',
        code: 'NET_${e.type.name.toUpperCase()}',
        originalError: e,
      ));
    } catch (e, st) {
      return Result.failure(AppError.unknown(e.toString(), originalError: e, stackTrace: st));
    }
  }
}
