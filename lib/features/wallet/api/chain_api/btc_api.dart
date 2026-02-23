import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:http/http.dart' as http;

class BtcApi{
  String? uri;
  bool isTest=false;
  BtcApi({bool test = false}) {
    isTest=test;
    uri=RequestUrl().getUrl2(CoinType.BTC.name,'api',isTest:isTest);
  }
  Future<MessageModel> getGasfee()async{
    //https://mempool.space/testnet4/api/v1/fees/recommended
    try{
      var data=await BaseApi.requestEmptyH.get('${uri}v1/fees/recommended', params: {});
      MessageModel mm=MessageModel();
      mm.data=data['economyFee'];
      return mm;
    }catch(e){
      MessageModel mm=MessageModel();
      mm.data=2;
      return mm;
    }
  }
  Future<MessageModel> getUtxos(String address)async{
    try{
      var data=await BaseApi.requestEmptyH.get('${uri}address/$address/utxo', params: {});
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  Future<MessageModel> getUTXOTxid(String txid)async{
    try{
      var data= await BaseApi.requestEmptyH.get("${uri}tx/$txid",
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
  Future<MessageModel> getBalance(String address)async{
    try{
      var data= await BaseApi.requestEmptyH.get("${uri}address/$address",
        params: {},
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
        },
      );
      MessageModel mm=MessageModel();
      if(data['chain_stats'] !=null){
        int fundedTxoSum=data['chain_stats']['funded_txo_sum'];
        int spentTxoSum=data['chain_stats']['spent_txo_sum'];
        /*if(funded_txo_sum==0){
          funded_txo_sum=data['chain_stats']['funded_txo_sum'];
          spent_txo_sum=data['chain_stats']['spent_txo_sum'];
        }*/
        mm.data=BigInt.from(fundedTxoSum-spentTxoSum);
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
  Future<MessageModel> sendTxHttp(String signHase)async{
    String url = "${uri}tx";
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
  Future<MessageModel> sendTx(String signHase)async{
    try{
      var data= await BaseApi.requestEmptyH.post("${uri}tx",
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
  Future<MessageModel> getTxState(String txId)async{
    try{
      var data= await BaseApi.requestEmptyH.get("${uri}tx/$txId/status",
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
