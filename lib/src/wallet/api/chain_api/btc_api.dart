import 'dart:io';

import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:http/http.dart' as http;

class BtcApi{
  String? uri;
  bool isTest=false;
  BtcApi({test=false}){
    isTest=test;
    uri=RequestUrl().getUrl2(CoinType.BTC.name,'api',isTest:isTest);
  }
  getGasfee()async{
    //https://mempool.space/testnet4/api/v1/fees/recommended
    try{
      var data=await BaseApi.RequestEmpty_h.get('${uri}v1/fees/recommended', params: {});
      MessageModel mm=MessageModel();
      mm.data=data['economyFee'];
      return mm;
    }catch(e){
      MessageModel mm=MessageModel();
      mm.data=2;
      return mm;
    }
  }
  getUtxos(String address)async{
    try{
      var data=await BaseApi.RequestEmpty_h.get('${uri}address/$address/utxo', params: {});
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  getUTXOTxid(String txid)async{
    try{
      var data= await BaseApi.RequestEmpty_h.get("${uri}tx/$txid",
        params: {},
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
        },
      );
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  getBalance(String address)async{
    try{
      var data= await BaseApi.RequestEmpty_h.get("${uri}address/$address",
        params: {},
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
        },
      );
      MessageModel mm=MessageModel();
      if(data['chain_stats'] !=null){
        int funded_txo_sum=data['chain_stats']['funded_txo_sum'];
        int spent_txo_sum=data['chain_stats']['spent_txo_sum'];
        /*if(funded_txo_sum==0){
          funded_txo_sum=data['chain_stats']['funded_txo_sum'];
          spent_txo_sum=data['chain_stats']['spent_txo_sum'];
        }*/
        mm.data=BigInt.from(funded_txo_sum-spent_txo_sum);
      }else{
        mm.data=BigInt.zero;
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  sendTx_http(String signHase)async{
    HttpOverrides.global = MyHttpOverrides();
    String url = "${uri}tx"; // 替换为你的 API 地址
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "text/plain", // 设置请求头
        },
        body: signHase, // 发送的内容
      );

      if (response.statusCode == 200) {
        MessageModel mm=MessageModel();
        mm.data=response.body;
        return mm;
      } else {
        MessageModel mm=MessageModel.error();
        mm.data="Error: ${response.statusCode} - ${response.body}";
        return mm;
      }
    } catch (e) {
      MessageModel mm=MessageModel.error();
      mm.data="Request failed: $e";
      return mm;
    }
  }
  sendTx(String signHase)async{
    try{
      var data= await BaseApi.RequestEmpty_h.post("${uri}tx",
          params: {},
          defaultReturn: false,
          header: {
            "Content-Type":"text/plain",
          },
          data: signHase
      );
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  getTxState(String txId)async{
    try{
      var data= await BaseApi.RequestEmpty_h.get("${uri}tx/$txId/status",
        params: {},
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
        },
      );
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
