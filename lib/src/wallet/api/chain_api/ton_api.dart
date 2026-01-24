import 'package:n42appv2/core/app/app_globals.dart';
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
  getBalanceTon(String address)async{
    MessageModel rmm=await baseRPCTon(
      "getAddressBalance",
      {
        "address": address, // 查询 SUI 代币余额
      },
      'jsonRPC'
    );
    if(rmm.error==false){
      rmm.data=BigInt.parse(rmm.data);
    }
    return rmm;
  }
  getSeqnoTon(String address)async{
    MessageModel rmm=await baseRPC2Ton(
      {
        "address": address,
        "method": "seqno",
        "stack": []
      },
      'runGetMethod',
    );
    if(rmm.error==false){
      if(rmm.data['exit_code']==0){
        rmm.data=int.parse(rmm.data['stack'][0][1]);
      }else{
        rmm.data=0;
      }
    }
    return rmm;
  }
  submitTon(String signStr)async{
    MessageModel rmm= await baseRPC2Ton(
      {
        "boc": signStr,
      },
      'sendBoc',
    );
    if(rmm.error==false){
      rmm.data=rmm.data['@extra'];
    }
    return rmm;
  }
  baseRPCTon(String method,var value,String path)async{
    try{
      MessageModel mm=MessageModel();
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":value,"id":AppGlobals.currentId++};

      final data=await BaseApi.RequestEmpty_h.post(url+path, params: {},data: postData);
      if(data['ok']==false){
        mm.error=true;
        mm.data=data['error'];
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
  baseRPC2Ton(var value,String path)async{
    try{
      MessageModel mm=MessageModel();

      final data=await BaseApi.RequestEmpty_h.post(url+path, params: {},data: value,header: {'x-api-key':apiKey,'Content-Type':'application/json'});
      if(data['ok']==false){
        mm.error=true;
        mm.data=data['error'];
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
