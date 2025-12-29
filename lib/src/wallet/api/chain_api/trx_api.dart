import 'dart:convert';
import 'dart:typed_data';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:eth_sig_util/util/bigint.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:web3dart/crypto.dart';
import 'package:fast_base58/fast_base58.dart';

class TrxApi{
  late String url;
  late Map<String,String> header;
  TrxApi(){
    url="";//AppConfig.getApiUrl_online('activiteHost');
    header={'content-type': 'application/json','TRON-PRO-API-KEY':'c0093859-4ae0-47b5-8650-6b14fec2d771'};
  }
  //trx,Tron
  //获取余额
  getBalance_trx(String address,String contract,{bool isTest=false})async{
    address= getAddress_tron(address);
    if(contract==""){
      MessageModel mm=await BaseRPC_eth("eth_getBalance",["0x${address}","latest"]);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }else{
      contract=getAddress_tron(contract);
      String addr=strip0x(address);
      MessageModel mm=await BaseRPC_eth("eth_call",[{"from": "0x${address}",
        "to": "0x${contract}", "data": "0x70a082310000000000000000000000${addr}"
      },"latest"]);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }
  }
  getGasPrice_trx({bool isTest=false})async{
    MessageModel mm=await BaseRPC_eth("eth_gasPrice",[],isTest: isTest);
    if(mm.error==false){
      mm.data=hexToInt(mm.data);
    }
    return mm;
  }
  /*static getBalance2_trx(String address,String contract,bool isTest)async{
    try{
      String uri=Api.getUrl2(CoinType.TRX.name,'rpc',isTest:isTest);
      var data=await Api.tronHelp.get('${uri}/v1/accounts/$address', params: {});
      if(data['success']){
        MessageModel mm=MessageModel();
        mm.data=null;
        List addrs=data['data'];
        for(Map addr in addrs){
          bool isFind=false;
          List owner_ps=addr['owner_permission']['keys'];
          for(Map owner in owner_ps){
            if(owner['address']==address){
              isFind=true;
              break;
            }
          }
          if(isFind){
            mm.data=addr;
            break;
          }
        }
        return mm;
      }else{
        MessageModel mm=MessageModel.error();
        mm.data=data['message'];
        return mm;
      }

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  static getBalance1_trx(String address,String contract)async{
    try{
      String uri=Api.getUrl2(CoinType.TRX.name,'rpc');
      var data=await Api.tronHelp.get('${uri}/v1/accounts/$address', params: {});
      if(data['success']){
        MessageModel mm=MessageModel();
        mm.data=BigInt.from(0);
        List addrs=data['data'];
        for(Map addr in addrs){
          bool isFind=false;
          if(contract==""){
            List owner_ps=addr['owner_permission']['keys'];
            for(Map owner in owner_ps){
              if(owner['address']==address){
                isFind=true;
                break;
              }
            }
            if(isFind){
              mm.data=BigInt.from(addr['balance']);
              break;
            }
          }else{
            BigInt balance=BigInt.from(0);
            List owner_ps=addr['trc20'];
            for(Map owner in owner_ps){
              String? cBalance=owner[contract];
              if(cBalance!=null){
                balance=BigInt.parse(cBalance);
                break;
              }
            }
            mm.data=balance;
          }
        }
        return mm;
      }else{
        MessageModel mm=MessageModel.error();
        mm.data=data['message'];
        return mm;
      }

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  */
  getGasEstimate_trx(String from,String to,BigInt gasPrice,BigInt value,BigInt gas,{String contract="",bool isTest=false})async{
    from=getAddress_tron(from);
    to=getAddress_tron(to);
    if(contract==""){
      MessageModel mm= await BaseRPC_eth("eth_estimateGas",
          [{"from": from,
            "to": to,
            "gasPrice":'0x${gasPrice.toRadixString(16)}',
            "gas":"0x${gas.toRadixString(16)}",
            "value":"0x${value.toRadixString(16)}",
          }],isTest:isTest);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }
    else{
      contract=getAddress_tron(contract);
      //toAddress=DataUtils.strip0x(to);
      String aaa=hex(keccakAscii("transfer(address,uint256)"));
      aaa=aaa.substring(0,8).toLowerCase();
      Uint8List valueList=encodeBigInt(value,length: 32);
      String valueHex=hex(valueList).toLowerCase();
      MessageModel mm= await BaseRPC_eth(
          "eth_estimateGas",
          [{"from": "0x${from}",
            "to": "0x${contract}",
            "gasPrice":'0x${gasPrice.toRadixString(16)}',
            "gas":"0x${gas.toRadixString(16)}",
            "data": "0x${aaa}0000000000000000000000${to}${valueHex}",
          }],isTest:isTest);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }
  }
  //或去最新块信息
  getBlockNow_trx({bool isTest=false})async{
    try{
      String urlStr=RequestUrl().getUrl2(CoinType.TRX.name, 'rpc',isTest: isTest);
      var data=await BaseApi.RequestEmpty_h.post('${urlStr}/wallet/getnowblock', params: {},header: header);
      if(data['block_header']==null){
        MessageModel mm=MessageModel.error();
        mm.data=data['message'];
        return mm;

      }else{
        MessageModel mm=MessageModel();
        mm.data=data['block_header'];
        return mm;
      }
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  createTransaction(String fromAddress,String toAddress,int amount,{bool isTest=false})async{
    try{
      String url=RequestUrl().getUrl2(CoinType.TRX.name, 'api',isTest: isTest);
      Map<String,dynamic> map={
        "owner_address": fromAddress,
        "to_address": toAddress,
        "amount": amount,
        "visible": true
      };
      final rData=await BaseApi.RequestEmpty_h.post('${url}/wallet/createtransaction', params: {},data: map);
      MessageModel mm=MessageModel();
      if(rData['result']==false){
        mm.error=true;
        mm.data=rData['message'];
      }else{
        mm.data=rData['txid'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  //广播交易
  sendTx_trx(String signStr,{bool isTest=false})async{
    try{
      String urlStr=RequestUrl().getUrl2(CoinType.TRX.name, 'api',isTest: isTest);
      final rData=await BaseApi.RequestEmpty_h.post('${urlStr}/wallet/broadcasttransaction', params: {},data: jsonDecode(signStr),header: header);
      MessageModel mm=MessageModel();
      if(rData['result']==false){
        mm.error=true;
        mm.data=rData['Error'];
      }else{
        mm.data=rData['txid'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }

  /*
  sendCall(Map<String,dynamic> params,{bool isTest=false,int id=1})async{
    Map<String,dynamic> postMap={
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [params, "latest"],
      "id": id
    };
    try{
      var a=await Api.tronHelp.post('${Api.getUrl2(CoinType.TRX.name,'api',isTest:isTest)}', params: {},data: postMap);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        if(a['data']['error']['code']!=0){
          mm.data=a['data']['error']['message'];
        }else{
          mm.error=false;
          mm.data=a['data']['result'];
        }

      }else{
        mm.data=a['data'];
      }
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  */
  BaseRPC_eth(String method,var value,{bool? isTest=null})async{
    try{
      MessageModel mm=MessageModel();
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":value,"id":AppGlobals.currentId++};
      String urlStr=RequestUrl().getUrl2("TRX", "rpc",isTest: isTest)+"/jsonrpc";
      final data=await BaseApi.RequestEmpty_h.post(urlStr, params: {},data: postData,header: header,);
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
  String getAddress_tron(String address){
    var decodeStr = Base58Decode(address);
    String hexAddress = bytesToHex(Uint8List.fromList(decodeStr));
    //HexUtils().uint8ToHex(Uint8List.fromList(decodeStr));
    return "41${hexAddress.substring(2, 42).toLowerCase()}";
  }
}