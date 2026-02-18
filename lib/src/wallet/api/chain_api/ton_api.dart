import 'package:dio/dio.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/utils/message_model_bridge.dart';
import 'package:n42appv2/core/utils/result.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';

class TonApi{
  String url="";
  String apiKey="";
  TonApi({bool isTest=false}){
    url=RequestUrl().getUrl2(CoinType.TON.name, "rpc",isTest: isTest);
    if(isTest){
      apiKey="871d3fcd705d694b83aab1edc44e7395c7698f4b57f54f722795b2d32e0604aa";
    }else{
      apiKey="39b7ef60a7dfdaaefe04484218e249d9b18547dee3a32170a25bd24ad928a732";
    }
  }
  Future<MessageModel> getBalanceTon(String address)async{
    final result=await baseRPCTon(
      "getAddressBalance",
      {
        "address": address,
      },
      'jsonRPC',
    );
    final rmm=resultToMessageModel(result);
    if(rmm.error==false){
      rmm.data=BigInt.parse(rmm.data);
    }
    return rmm;
  }
  Future<MessageModel> getSeqnoTon(String address)async{
    final result=await baseRPC2Ton(
      {
        "address": address,
        "method": "seqno",
        "stack": []
      },
      'runGetMethod',
    );
    final rmm=resultToMessageModel(result);
    if(rmm.error==false){
      if(rmm.data['exit_code']==0){
        rmm.data=int.parse(rmm.data['stack'][0][1]);
      }else{
        rmm.data=0;
      }
    }
    return rmm;
  }
  //发送交易（明确禁用重试，防止双发）
  Future<MessageModel> submitTon(String signStr)async{
    final result=await baseRPC2Ton(
      {"boc": signStr},
      'sendBoc',
      enableRetry: false,
    );
    final rmm=resultToMessageModel(result);
    if(rmm.error==false){
      rmm.data=rmm.data['@extra'];
    }
    return rmm;
  }
  Future<Result<dynamic, AppError>> baseRPCTon(
    String method,
    var value,
    String path, {
    bool enableRetry = true,
  }) async {
    try {
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":value,"id":AppGlobals.nextId};
      final data=await BaseApi.requestEmptyH.post(url+path, params: {},data: postData,enableRetry: enableRetry);
      if(data['ok']==false){
        return Result.failure(AppError.blockchain(
          data['description']?.toString() ?? data['error']?.toString() ?? 'RPC error',
          code: 'TON_RPC_ERROR',
          originalError: data,
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
  Future<Result<dynamic, AppError>> baseRPC2Ton(
    dynamic value,
    String path, {
    bool enableRetry = true,
  }) async {
    try {
      final data=await BaseApi.requestEmptyH.post(
        url+path,
        params: {},
        data: value,
        header: {'x-api-key':apiKey,'Content-Type':'application/json'},
        enableRetry: enableRetry,
      );
      if(data['ok']==false){
        return Result.failure(AppError.blockchain(
          data['description']?.toString() ?? data['error']?.toString() ?? 'RPC error',
          code: 'TON_RPC2_ERROR',
          originalError: data,
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
