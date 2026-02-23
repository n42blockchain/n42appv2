import 'dart:convert';

import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/http/base_api.dart';
import 'package:n42_wallet/src/http/request_url.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/src/wallet/utils/chain_util.dart';

///explorer/tip,返回有关最新块、索引器状态、协议部署和供应统计信息的信息。
///explorer/account/{hash}，返回账户信息
///explorer/op/{hash|id},获取交易信息，参数未交易hash
///explorer/account/{hash}/operations，获取 所有operation 列表
///explorer/op/{hash}获取交易信息
class XtzApi{
  //valueType: "balance"spendable_balance;"revealed"is_revealed
  Future<MessageModel> getBalanceXtz(String address,String contract,String valueType,bool isTest)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XTZ.name,'api',isTest:isTest);
      var data=await BaseApi.requestEmptyH.get('${uri}explorer/account/$address', params: {},defaultReturn: false);
      MessageModel mm=MessageModel();
      if(valueType=="balance"){
        mm.data=ethToWeiString(data['spendable_balance'].toString(), 6);
      }else{
        mm.data=data['is_funded'];//data['is_revealed'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel();
      if(valueType=="balance"){
        mm.data=BigInt.zero;
      }else{
        mm.data=false;
      }
      return mm;
    }
  }
  //counter 获取计数
  Future<MessageModel> getCounterXtz(String address,bool isTest)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XTZ.name,'rpc',isTest:isTest);
      var data=await BaseApi.requestEmptyH.get('${uri}chains/main/blocks/head/context/contracts/$address/counter', params: {},defaultReturn: false);
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  Future<MessageModel> getBranchXgz(bool isTest)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XTZ.name,'rpc',isTest:isTest);
      var data=await BaseApi.requestEmptyH.get('${uri}chains/main/blocks/head/hash', params: {},defaultReturn: false);
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  Future<MessageModel> getTxInfoXtz(String txHash,bool isTest)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XTZ.name,'api',isTest:isTest);
      var data=await BaseApi.requestEmptyH.get('${uri}explorer/op/$txHash', params: {},defaultReturn: false);
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //广播
  Future<MessageModel> sendTxXtz(String signAddress,bool isTest)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XTZ.name, "rpc",isTest:isTest);
      var data=await BaseApi.requestEmptyH.post('${uri}injection/operation?chain=main', params: {},data: json.encode(signAddress),defaultReturn: false);
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
}
