import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';

class AtomApi{
  getBalance(String address,String token)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.ATOM.name,'api',isTest:false);
      uri+='cosmos/bank/v1beta1/balances/$address';
      var data=await BaseApi.requestEmptyH.get(
        uri,
        params: {},
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
          //"x-api-key":'200968d8-1f1a-4d25-a7b6-e5768e723a10',//"bc0a6024-148a-4c6e-8188-0a0523f3f713",
        },
      );
      MessageModel mm=MessageModel();
      List<dynamic> balances=data['balances'];
      mm.data=BigInt.zero;
      if(token==""){
        for(int i=0;i<balances.length;i++){
          Map<String,dynamic> b=balances[i];
          if(b['denom']=='uatom'){
            mm.data=BigInt.parse(b['amount']);
            break;
          }
        }
      }else{
        for(int i=0;i<balances.length;i++){
          Map<String,dynamic> b=balances[i];
          if(b['denom']==token){
            mm.data=BigInt.parse(b['amount'].toString());
            break;
          }
        }
      }
      return mm;

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //cosmos/auth/v1beta1/accounts/
  getAccounts(String address)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.ATOM.name,'api',isTest:false);
      var data=await await BaseApi.requestEmptyH.get(
        '${uri}cosmos/auth/v1beta1/accounts/$address',
        params: {},
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
          //"x-api-key":"bc0a6024-148a-4c6e-8188-0a0523f3f713",
        },
      );
      MessageModel mm=MessageModel();
      mm.data=data['account'];
      return mm;

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //cosmos/bank/v1beta1/denoms_metadata/
  getMetadata(String denom)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.ATOM.name,'api',isTest:false);
      var data=await await BaseApi.requestEmptyH.get(
        '${uri}cosmos/bank/v1beta1/denoms_metadata/$denom',
        params: {},
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
          //"x-api-key":"bc0a6024-148a-4c6e-8188-0a0523f3f713",
        },
      );
      MessageModel mm=MessageModel();
      mm.data=data['metadata'];
      return mm;

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //cosmos/tx/v1beta1/txs/
  getTxs(String txHash)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.ATOM.name,'api',isTest:false);
      var data=await await BaseApi.requestEmptyH.get(
        '${uri}cosmos/tx/v1beta1/txs/$txHash',
        params: {},
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
          //"x-api-key":"bc0a6024-148a-4c6e-8188-0a0523f3f713",
        },
      );
      MessageModel mm=MessageModel();
      mm.data=data['metadata'];
      return mm;

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //cosmos/tx/v1beta1/txs
  sendTxs(var rawTx)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.ATOM.name,'api',isTest:false);
      var data=await BaseApi.requestEmptyH.post(
        '${uri}cosmos/tx/v1beta1/txs',
        params: {},
        data: {
          "tx_bytes":rawTx,
          "mode":"BROADCAST_MODE_SYNC"
        },
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
          //"x-api-key":"bc0a6024-148a-4c6e-8188-0a0523f3f713",
        },
      );
      MessageModel mm=MessageModel();
      if(data['tx_response']==null){
        mm.data=data['message'];
      }else{
        mm.data=data['tx_response']['txhash'];
      }
      return mm;

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //cosmos/tx/v1beta1/simulate
  sendTxsSimulate(var rawTx)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.ATOM.name,'api',isTest:false);
      var data=await BaseApi.requestEmptyH.post(
        '${uri}cosmos/tx/v1beta1/simulate',
        params: {},
        data: {
          "tx_bytes":rawTx,
          "mode":"BROADCAST_MODE_SYNC"
        },
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
          //"x-api-key":"bc0a6024-148a-4c6e-8188-0a0523f3f713",
        },
      );
      MessageModel mm=MessageModel();
      if(data['tx_response']==null){
        mm.data=data['message'];
      }else{
        mm.data=data['tx_response']['txhash'];
      }
      return mm;

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  /*
  * {
            "state": "STATE_OPEN",
            "ordering": "ORDER_ORDERED",
            "counterparty": {
                "port_id": "icahost",
                "channel_id": "channel-4672"
            },
            "connection_hops": [
                "connection-809"
            ],
            "version": "{\"version\":\"ics27-1\",\"controller_connection_id\":\"connection-809\",\"host_connection_id\":\"connection-0\",\"address\":\"neutron1u5gaalvlg2nr5spaxuvxuhx69yx05xfs0lnxjeuezq53px9au9esfrhj7t\",\"encoding\":\"proto3\",\"tx_type\":\"sdk_multi_msg\"}",
            "port_id": "icacontroller-cosmos10d07y265gmmuvt4z0w9aw880jnsr700j6zn9kn",
            "channel_id": "channel-914",
            "upgrade_sequence": "0"
        },
        * state: 通道的状态，通常是 STATE_OPEN（开放状态）或 STATE_CLOSED（关闭状态）。
ordering: 表示通道的消息传递顺序，ORDER_UNORDERED 表示不要求顺序，ORDER_ORDERED 表示要求顺序。
counterparty: 目标链的信息，包括：
port_id: 目标链上的端口名称（例如 cosmos.osmosis）。
channel_id: 目标链上对应的通道 ID（例如 channel-1）。
connection_hops: 连接跳跃，表示通道之间的连接路径。
version: IBC 协议的版本，通常会标明使用的版本号（如 ics20-1）。
        * */
  ///ibc/core/channel/v1/channels
  getChannels()async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.ATOM.name,'api',isTest:false);
      var data=await await BaseApi.requestEmptyH.get(
        '${uri}ibc/core/channel/v1/channels',
        params: {},
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
          //"x-api-key":"bc0a6024-148a-4c6e-8188-0a0523f3f713",
        },
      );
      MessageModel mm=MessageModel();
      mm.data=data['channels'];
      return mm;

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
}
