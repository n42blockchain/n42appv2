import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';

class DotApi{
  //获取余额
  getTokens(String address,String coinType,{bool isTest=false})async{
    try{
      MessageModel mm=MessageModel();
      String url=RequestUrl().getUrl2(coinType, "api",isTest: isTest);
      url="${url}api/scan/account/tokens";
      Map<String,dynamic> pMap={
        "address":address
      };
      final data=await BaseApi.RequestEmpty_h.post(url, params: {},data: pMap,header: {"x-api-key":"2b9bd66238b546acafe57b2a05ff97e0"});
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
  getGenesisHash({int? index,bool isTest=false})async {
    return await baseRPC("chain_getBlockHash",index==null?[]:[index],isTest: isTest);
  }
  getNonce(String address,{bool isTest=false})async{
    return await baseRPC("system_accountNextIndex",[address],isTest: isTest);
  }
  getChainHeader({bool isTest=false})async{
    return await baseRPC("chain_getHeader",[],isTest: isTest);
  }
  //获取specVersion、TransactionVersion
  getRuntimeVersion({bool isTest=false})async {
    return await baseRPC("state_getRuntimeVersion",[],isTest: isTest);
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
  submitTxHash(String hash,{bool isTest=false})async{
    //author_submitExtrinsic
    return await baseRPC("author_submitExtrinsic",[hash],isTest: isTest);
  }
  //估算gas费
  getGasPrice(String txHash,{bool isTest=false})async{
    return await baseRPC("payment_queryInfo",[txHash],isTest: isTest);
  }
  baseRPC(String method,var value,{bool? isTest=false})async{
    try{
      MessageModel mm=MessageModel();
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":value,"id":AppGlobals.currentId++};
      final data=await BaseApi.RequestEmpty_h.post(RequestUrl().getUrl2(CoinType.DOT.name, "rpc",isTest: isTest), params: {},data: postData);
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
}
