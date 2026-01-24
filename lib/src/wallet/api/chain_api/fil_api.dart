import 'dart:convert';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:web3dart/crypto.dart';

class FilApi{
  Future<MessageModel> getBalance(String address,{bool isTest=false})async{
    MessageModel mm=await baseRPC("Filecoin.WalletBalance",[address],isTest: isTest);
    if(mm.error==false){
      mm.data=BigInt.parse(mm.data.toString());
    }
    return mm;
  }
  Future<MessageModel> getGasPrice({bool isTest=false})async{
    MessageModel mm=await baseRPC("Filecoin.EthGasPrice",[],isTest: isTest);
    if(mm.error==false){
      mm.data=hexToInt(mm.data);
    }
    return mm;
  }
  /*
  static getVersion({bool isTest=false})async{
    MessageModel mm=await baseRPC("Filecoin.Version",[],isTest: isTest);
    if(mm.error==false){
      mm.data=mm.data['BlockDelay'];
    }
    return mm;
  }
  */
  Future<MessageModel> getNonce(String address,{bool isTest=false})async{
    MessageModel mm=await baseRPC("Filecoin.MpoolGetNonce",[address],isTest: isTest);
    if(mm.error==false){
      mm.data=mm.data.toString();
    }
    return mm;
  }
  /*
  static getPushMessage(String from,
      String to,
      BigInt gas,
      String gasFeeCap,
      String gasPremium,
      {int version=30,
        String value="0",bool isTest=false})async{
    List param=[{
      "Version":version,
      "From": from,
      "To": to,
      "Value":value,
      "GasLimit": gas.toInt(),
      "GasFeeCap": gasFeeCap,
      "GasPremium": gasPremium,
      "Method": 0,
      "Params":"",
    },
      {
        "MaxFee": "0"
      }];
    return await baseRPC(
        "Filecoin.MpoolPushMessage",
        param,
        isTest: isTest);
  }
  */
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
    return await baseRPC(
        "Filecoin.GasEstimateMessageGas",
        param,
        isTest: isTest);
  }
  Future<MessageModel> sendTx(String txHash,{bool isTest=false})async{
    Map<String,dynamic> pMap=json.decode(txHash);
    pMap['Message']['Nonce']=(pMap['Message']['Nonce'] as int);
    return await baseRPC(
        "Filecoin.MpoolPush",
        [pMap],
        isTest: isTest);
  }
  Future<MessageModel> baseRPC(String method,var value,{bool? isTest=false})async{
    try{
      MessageModel mm=MessageModel();
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":value,"id":AppGlobals.currentId++};
      final data=await BaseApi.requestEmptyH.post(RequestUrl().getUrl2("FIL", "rpc",isTest: isTest), params: {},data: postData);
      if(data.containsKey('error')){
        mm.error=true;
        mm.data=data['error']['message'];
      }else{
        mm.data=data['result'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
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
