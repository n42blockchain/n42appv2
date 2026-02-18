import 'dart:convert';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/utils/message_model_bridge.dart';
import 'package:n42appv2/core/utils/result.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:web3dart/web3dart.dart';

class FilApi{
  Future<MessageModel> getBalance(String address,{bool isTest=false})async{
    final result=await baseRPC("Filecoin.WalletBalance",[address],isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=BigInt.parse(mm.data.toString());
    }
    return mm;
  }
  Future<MessageModel> getGasPrice({bool isTest=false})async{
    final result=await baseRPC("Filecoin.EthGasPrice",[],isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=hexToInt(mm.data);
    }
    return mm;
  }
  Future<MessageModel> getNonce(String address,{bool isTest=false})async{
    final result=await baseRPC("Filecoin.MpoolGetNonce",[address],isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=mm.data.toString();
    }
    return mm;
  }
  Future<MessageModel> getGasLimit(
      String from,
      String to,
      BigInt gas,
      {int version=30,
        String value="0",
        bool isTest=false})async{
    List param=[{
      "Version":version,
      "From": from,
      "To": to,
      "Value":value,
      "GasLimit": 0,
      "GasFeeCap": "0",
      "GasPremium": "0",
      "Method": 0,
      "Params":"",
    },
      {
        "MaxFee": "0"
      },
      []];
    return resultToMessageModel(
      await baseRPC("Filecoin.GasEstimateMessageGas", param, isTest: isTest),
    );
  }
  //发送交易（明确禁用重试，防止双发）
  Future<MessageModel> sendTx(String txHash,{bool isTest=false})async{
    Map<String,dynamic> pMap=json.decode(txHash);
    pMap['Message']['Nonce']=(pMap['Message']['Nonce'] as int);
    return resultToMessageModel(
      await baseRPC("Filecoin.MpoolPush", [pMap], isTest: isTest, enableRetry: false),
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
        RequestUrl().getUrl2("FIL", "rpc",isTest: isTest),
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
          code: 'FIL_RPC_ERROR',
          originalError: data['error'],
        ));
      }
      return Result.success(data['result']);
    } catch (e, st) {
      // BaseHttp converts DioException to a localized String upstream.
      return Result.failure(AppError.network(e.toString(), originalError: e, stackTrace: st));
    }
  }

  Future<MessageModel> getMessageInfo(String mId,{bool isTest=false})async{
    try{
      MessageModel mm=MessageModel();
      String url=RequestUrl().getUrl2("FIL", "api",isTest: isTest);
      url='${url}message/$mId';
      final data=await BaseApi.requestEmptyH.get(url, params: {});
      if(data['receipt']['exitCode']??-1 !=0){
        mm.error=true;
        mm.data="";
      }else{
        mm.data=data;
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
}
