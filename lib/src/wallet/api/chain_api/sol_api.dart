import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';

class SolApi{
  //获取账号信息
  getAccountInfo(String address,{bool isTest=false,})async{
    MessageModel mm=await BaseRPC_sol("getAccountInfo",[address,{"encoding": "base64"}],isTest: isTest);
    if(mm.error==false){
      mm.data=mm.data['value']['data'];
    }
    return mm;
  }
  //获取最新区块hash
  getLatestBlockhash({bool isTest=false,})async{
    MessageModel mm=await BaseRPC_sol("getLatestBlockhash",[],isTest: isTest);
    if(mm.error==false){
      mm.data=mm.data['value']['blockhash'];
    }
    return mm;
  }
  //获取余额
  getBalance(String address,String contract,{bool isTest=false,})async{
    if(contract==""){
      MessageModel mm=await BaseRPC_sol("getBalance",[address],isTest: isTest);
      if(mm.error==false){
        mm.data=mm.data['value'];
      }
      return mm;
    }else{
      MessageModel mm=await BaseRPC_sol("getTokenAccountsByOwner",[address,{"mint": contract},{"encoding": "jsonParsed"}],isTest: isTest);
      if(mm.error==false){
        List<Map<String,dynamic>> valueMap=mm.data['value'];
        if(valueMap.length !=0){
          mm.data=BigInt.from(valueMap[0]['account']['data']['parsed']['info']['tokenAmount']['amount']);
        }
      }
      return mm;
    }
  }
  //计算gas费
  getFeeForMessage(String signMessage,{isTest=false})async{
    MessageModel mm=await BaseRPC_sol("getFeeForMessage",[signMessage,
      /*{
      "commitment":"processed"
    }*/
    ],isTest: isTest);
    if(mm.error==false){
      mm.data=mm.data['value'];
    }
    return mm;
  }
  //虚拟交易
  simulateTransaction(String signMessage,{isTest=false})async{
    MessageModel mm=await BaseRPC_sol("simulateTransaction",[signMessage,{
      "sigVerify": true
      //"encoding":"base64"
    }],isTest: isTest);
    if(mm.error==false){
      mm.data=mm.data['value'];
    }
    return mm;
  }
  //发起交易
  sendTransaction(String signMessage,{isTest=false})async{
    return await BaseRPC_sol("sendTransaction",[signMessage,{"encoding":"base58"}],isTest: isTest);
  }
  BaseRPC_sol(String method,var value,{bool? isTest=null})async{
    try{
      MessageModel mm=MessageModel();
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":value,"id":AppGlobals.currentId++};
      String url=RequestUrl().getUrl2(CoinType.SOL.name, "rpc",isTest: isTest);
      final data=await BaseApi.RequestEmpty_h.post(url, params: {},data: postData);
      if(data.containsKey('error')){
        mm.error=true;
        mm.data=data['message'];
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
}
