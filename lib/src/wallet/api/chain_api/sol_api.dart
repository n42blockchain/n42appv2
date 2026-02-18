import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/utils/message_model_bridge.dart';
import 'package:n42appv2/core/utils/result.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';

class SolApi{
  //获取账号信息
  Future<MessageModel> getAccountInfo(String address,{bool isTest=false,})async{
    final result=await baseRPCSol("getAccountInfo",[address,{"encoding": "base64"}],isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=mm.data['value']['data'];
    }
    return mm;
  }
  //获取最新区块hash
  Future<MessageModel> getLatestBlockhash({bool isTest=false,})async{
    final result=await baseRPCSol("getLatestBlockhash",[],isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=mm.data['value']['blockhash'];
    }
    return mm;
  }
  //获取余额
  Future<MessageModel> getBalance(String address,String contract,{bool isTest=false,})async{
    if(contract==""){
      final result=await baseRPCSol("getBalance",[address],isTest: isTest);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        mm.data=mm.data['value'];
      }
      return mm;
    }else{
      final result=await baseRPCSol("getTokenAccountsByOwner",[address,{"mint": contract},{"encoding": "jsonParsed"}],isTest: isTest);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        List<Map<String,dynamic>> valueMap=mm.data['value'];
        if(valueMap.isNotEmpty){
          mm.data=BigInt.from(valueMap[0]['account']['data']['parsed']['info']['tokenAmount']['amount']);
        }
      }
      return mm;
    }
  }
  //计算gas费
  Future<MessageModel> getFeeForMessage(String signMessage,{bool isTest=false})async{
    final result=await baseRPCSol("getFeeForMessage",[signMessage,
      /*{
      "commitment":"processed"
    }*/
    ],isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=mm.data['value'];
    }
    return mm;
  }
  //虚拟交易
  Future<MessageModel> simulateTransaction(String signMessage,{bool isTest=false})async{
    final result=await baseRPCSol("simulateTransaction",[signMessage,{
      "sigVerify": true
      //"encoding":"base64"
    }],isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=mm.data['value'];
    }
    return mm;
  }
  //发起交易（明确禁用重试，防止双发）
  Future<MessageModel> sendTransaction(String signMessage,{bool isTest=false})async{
    return resultToMessageModel(
      await baseRPCSol("sendTransaction",[signMessage,{"encoding":"base58"}],isTest: isTest,enableRetry: false),
    );
  }
  Future<Result<dynamic, AppError>> baseRPCSol(
    String method,
    var value, {
    bool? isTest,
    bool enableRetry = true,
  }) async {
    try {
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":value,"id":AppGlobals.nextId};
      String url=RequestUrl().getUrl2(CoinType.SOL.name, "rpc",isTest: isTest);
      final data=await BaseApi.requestEmptyH.post(url, params: {},data: postData,enableRetry: enableRetry);
      if(data.containsKey('error')){
        return Result.failure(AppError.blockchain(
          data['message']?.toString() ?? 'RPC error',
          code: 'SOL_RPC_ERROR',
          originalError: data['error'],
        ));
      }
      return Result.success(data['result']);
    } catch (e, st) {
      // BaseHttp converts DioException to a localized String upstream.
      return Result.failure(AppError.network(e.toString(), originalError: e, stackTrace: st));
    }
  }
}
