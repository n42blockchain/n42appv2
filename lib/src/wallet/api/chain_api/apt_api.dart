

import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/http/base_api.dart';
import 'package:n42_wallet/src/http/request_url.dart';
import 'package:n42_wallet/src/models/message_model.dart';

class AptApi{
  String url="";
  AptApi({bool isTest=false}){
    url=RequestUrl().getUrl2(CoinType.APT.name, "rpc",isTest: isTest);
  }
  Future<MessageModel> getBalance(String address,{String contract="",String tokenName=""})async{
    try{
      MessageModel mm=MessageModel();
      String uri='${url}accounts/$address/balance/';
      if(contract==""){
        uri='${uri}0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>';
      }else{
        uri='${uri}0x1::coin::CoinStore<$contract::celer_coin_manager::$tokenName>';
      }
      final data=await BaseApi.requestEmptyH.get(uri, params: {},);
      mm.data=BigInt.from(data);
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  Future<MessageModel> getGasPrice()async{
    try{
      MessageModel mm=MessageModel();
      String uri='${url}estimate_gas_price';
      final data=await BaseApi.requestEmptyH.get(uri, params: {},);
      mm.data=BigInt.from(data['gas_estimate']);
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  Future<MessageModel> getAccountInfo(String address)async{
    try{
      MessageModel mm=MessageModel();
      String uri='${url}accounts/$address';
      final data=await BaseApi.requestEmptyH.get(uri, params: {},);
      mm.data=int.parse(data['sequence_number']);
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  Future<MessageModel> getServiceInfo()async{
    try{
      MessageModel mm=MessageModel();
      String uri='${url}ledger/info';
      final data=await BaseApi.requestEmptyH.get(uri, params: {},);
      mm.data=int.parse(data['ledger_timestamp']);
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  Future<MessageModel> sendTxHash(String txHash)async{
    try{
      MessageModel mm=MessageModel();
      String uri='${url}transactions';

      final data=await BaseApi.requestEmptyH.post(uri, params: {},data: txHash,header: {'content-type':'application/x.aptos.signed_transaction+bcs'});
      mm.data=data['hash'];
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
}
