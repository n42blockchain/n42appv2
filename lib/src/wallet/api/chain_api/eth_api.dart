import 'dart:typed_data';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/utils/chain_1559.dart';
import 'package:eth_sig_util/util/bigint.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:web3dart/crypto.dart';

class EthAPI{
  String? cType;
  String? rpc;
  String? api;
  EthAPI();
  EthAPI.init(this.cType,this.rpc,this.api);
  //static int currentId=0;
  /*
  //获取 opensea 的balanceOf
  static getBalanceOf_opensea(String address,String contract,String tokenId)async{
    String addr=DataUtils.strip0x(address);
    //String aaa=hex(keccakAscii("balanceOf(address,uint256)"));
    Uint8List tIntList=encodeBigInt(BigInt.parse(tokenId),length: 32);
    String thex=hex(tIntList);
    MessageModel mm=await BaseRPC_eth("ETH","eth_call",[{"from": address,
      "to": contract, "data": "0x00fdd58e000000000000000000000000${addr}${thex}"
    },"latest"],isTest: false);
    if(mm.error==false){
      mm.data=DataUtils.hexToInt(mm.data).toInt();
    }
    return mm;
  }
  //以太坊 获取 erc721 的tokenId
  static getTokenOfOwnerByIndex(String coinType,String address,String contract,int index)async{
    String addr=DataUtils.strip0x(address);
    String aaa=hex(keccakAscii("tokenOfOwnerByIndex(address,uint256)"));
    aaa=aaa.substring(0,8).toLowerCase();
    Uint8List tIntList=encodeBigInt(BigInt.from(index),length: 32);
    String thex=hex(tIntList);
    MessageModel mm=await BaseRPC_eth(coinType,"eth_call",[{"from": address,
      "to": contract, "data": "0x${aaa}000000000000000000000000${addr}${thex}"
    },"latest"],isTest: false);
    if(mm.error==false){
      mm.data=DataUtils.hexToInt(mm.data).toInt();
    }
    return mm;
  }
  //以太坊 获取 erc721 的 tokenURI
  static getTokenURI(String coinType,String address,String contract,String tokenId)async{
    //String addr=DataUtils.strip0x(address);
    String aaa=hex(keccakAscii("tokenURI(uint256)"));
    aaa=aaa.substring(0,8).toLowerCase();
    Uint8List tIntList=encodeBigInt(BigInt.parse(tokenId),length: 32);
    String thex=hex(tIntList);
    MessageModel mm=await BaseRPC_eth(coinType,"eth_call",[{"from": address,
      "to": contract, "data": "0x${aaa}${thex}"
    },"latest"],isTest: false);
    if(mm.error==false){
      mm.data=DataUtils.hexToInt(mm.data).toInt();
    }
    return mm;
  }
  //以太坊 获取 erc1155 的 URI
  //params{
  //"method":"uri(uint256)",
  //"from":address
  //"to":address
  //"value":[String,String],
  // }
  //
  static ethCall(String coinType,Map<String,dynamic> params,{bool isTest=false})async{
    String aaa=hex(keccakAscii(params['method']));
    aaa=aaa.substring(0,8).toLowerCase();
    String data="0x$aaa";
    List<String> value=params['value'];
    if(value.length !=0){
      for(String v in value){
        data="$data$v";
      }
    }
    MessageModel mm=await BaseRPC_eth(coinType,"eth_call",[{
      "from": params['from'],
      "to": params['to'],
      "data": data
    },"latest"],isTest: isTest);
    return mm;
  }
  /*static ethCall(String coinType,String address,String contract,String tokenId)async{
    //String addr=DataUtils.strip0x(address);
    //String aaa=hex(keccakAscii("itemURI(uint256)"));
    String aaa=hex(keccakAscii("uri(uint256)"));
    aaa=aaa.substring(0,8).toLowerCase();
    Uint8List tIntList=encodeBigInt(BigInt.parse(tokenId),length: 32);
    String thex=hex(tIntList).toLowerCase();
    //0x0e89341c0ec245261eccad28a8a8d5ca51233425c08241d2000000000000020000000001
    MessageModel mm=await BaseRPC_eth(coinType,"eth_call",[{//"from": address,
      "to": contract, "data": "0x${aaa}${thex}"
    },"latest"],isTest: false);
    /*if(mm.error==false){
      mm.data=DataUtils.hexToInt(mm.data).toInt();
    }*/
    Uint8List a=DataUtils.hexStringToUint8List(mm.data);
    return mm;
  }*/
  */
  //获取余额
  getBalance(String address,String contract,{bool isTest=false,String? coinType})async{
    if(contract==""){
      MessageModel mm=await BaseRPC_eth("eth_getBalance",[address,"latest"],coinType:coinType??cType,isTest: isTest);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }else{
      String addr=strip0x(address);
      MessageModel mm=await BaseRPC_eth("eth_call",[{"from": address,
        "to": contract, "data": "0x70a08231000000000000000000000000$addr"
      },"latest"],coinType: coinType??cType,isTest: isTest);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }
  }
  //获取gasPrice
  getGasPrice({bool isTest=false,String? coinType,})async{
    MessageModel mm=await BaseRPC_eth("eth_gasPrice",[],coinType: coinType??cType,isTest: isTest);
    if(mm.error==false){
      mm.data=hexToInt(mm.data);
    }
    return mm;
  }
  //获取预估值
  getGasLimit(
      String from,
      String to,
      BigInt gasPrice,
      BigInt value,
      BigInt gas,
      {String? coinType,String contract="",String data="",bool isTest=false,bool addLatest=true}
      )async{
    if(contract==""){
      /*List param=[];
      param.add({"from": from,
        "to": to,
        "gas":"0x${gas.toRadixString(16)}",
        "gasPrice":'0x${gasPrice.toRadixString(16)}',
        //"maxFeePerGas":'0x${gasPrice.toRadixString(16)}'
        //"id":currentId++,
      });
      if(addLatest){
        param.add("latest");
      }*/

      Map<String,dynamic> params={
        "from": from,
        "to": to,
        //"gas_price":'0x${gasPrice.toRadixString(16)}',
        //"gasPrice":'0x${gasPrice.toRadixString(16)}',
        "gas":"0x${gas.toRadixString(16)}",
        //"maxFeePerGas":'0x${gasPrice.toRadixString(16)}',
        //"price":"0x${value.toRadixString(16)}",
        "value":"0x${value.toRadixString(16)}",
        //"coin":coinType??cType??"",
        //"net_mode":isTest?"test":"main",
        //"id":AppGlobals.currentId++,
      };
      //params["gasPrice"]='0x${gasPrice.toRadixString(16)}';
      if(get1559WithChainSymbol(coinType??cType??"")){
        params["maxFeePerGas"]='0x${gasPrice.toRadixString(16)}';
      }else{
        params["gasPrice"]='0x${gasPrice.toRadixString(16)}';
      }
      if(data !=""){
        params['data']=data;
      }
      //TokenViewApi tokenViewApi=TokenViewApi();
      //return await tokenViewApi.getGasEstimate_eth(params);
      MessageModel mm=await BaseRPC_eth(
          "eth_estimateGas",
          [params,"latest"],
          coinType: coinType??cType,
          isTest: isTest);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }else{
        mm.error=true;
        mm.data=mm.data['message']??"Error";
      }
      return mm;
    }
    else{
      String toAddress=strip0x(to);
      String aaa=hex(keccakAscii("transfer(address,uint256)"));
      aaa=aaa.substring(0,8).toLowerCase();
      Uint8List valueList=encodeBigInt(value,length: 32);
      String valueHex=hex(valueList).toLowerCase();
      /*List param=[];
      param.add({"from": from,
        "to": contract,
        "gasPrice":'0x${gasPrice.toRadixString(16)}',
        "gas":"0x${gas.toRadixString(16)}",
        "data": "0x${aaa}000000000000000000000000$toAddress$valueHex",
        //"maxPriorityFee":"0x0",
        //"maxFeePerGas":'0x${gasPrice.toRadixString(16)}'
      });
      if(addLatest){
        param.add("latest");
      }*/
      Map<String,dynamic> params={"from": from,
        "to": contract,
        //"gas_price":'0x${gasPrice.toRadixString(16)}',
        //"gasPrice":'0x${gasPrice.toRadixString(16)}',
        "gas":"0x${gas.toRadixString(16)}",
        //"maxFeePerGas":'0x${gasPrice.toRadixString(16)}',
        "data": "0x${aaa}000000000000000000000000$toAddress$valueHex",
        //"coin":coinType??cType??"",
        //"net_mode":isTest?"test":"main",
        "id":AppGlobals.currentId++,
      };
      if(get1559WithChainSymbol(coinType??cType??"")){
        params["maxFeePerGas"]='0x${gasPrice.toRadixString(16)}';
      }else{
        params["gasPrice"]='0x${gasPrice.toRadixString(16)}';
      }
      //TokenViewApi tokenViewApi=TokenViewApi();
      //return await tokenViewApi.getGasEstimate_eth(params);
      MessageModel mm=await BaseRPC_eth("eth_estimateGas",[params,"latest"],isTest: isTest,coinType: coinType??cType);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }else{
        mm.error=true;
        if(mm.data.runtimeType != String){
          mm.data=mm.data['message'];
        }
      }
      return mm;
    }
  }
  getGasLimitByMap(Map<String,dynamic> map,{String? coinType,bool isTest=false,bool addLatest=true})async{
    List param=[map];
    if(addLatest){
      param.add("latest");
    }
    MessageModel mm=await BaseRPC_eth("eth_estimateGas",param,coinType: coinType??cType,isTest: isTest);
    if(mm.error==false){
      mm.data=hexToInt(mm.data);
    }
    return mm;
  }
  //获取交易收据
  getTransactionReceipt(String txHash,{String? coinType,bool isTest=false})async{
    return await BaseRPC_eth("eth_getTransactionReceipt",[txHash],coinType: coinType??cType,isTest: isTest);
  }
  //获取交易信息
  getTransactionByHash(String txHash, {String? coinType,bool isTest=false})async{
    return await BaseRPC_eth("eth_getTransactionByHash",[txHash],coinType: coinType??cType,isTest: isTest);
  }
  //获取nonce值
  getTransactionCount(String address,{String? coinType,bool isTest=false})async{
    MessageModel mm=await BaseRPC_eth("eth_getTransactionCount",[address,"latest"],coinType: coinType??cType,isTest: isTest);
    if(mm.error==false){
      mm.data=hexToInt(mm.data);
    }
    return mm;
  }

  //发送交易，返回交易hash
  sendTransaction(String value,{String? coinType,bool isTest=false})async{
    return await BaseRPC_eth("eth_sendRawTransaction",[value],coinType: coinType??cType,isTest: isTest);
  }

  BaseRPC_eth(String method,var value,{String? coinType,bool? isTest})async{
    try{
      MessageModel mm=MessageModel();
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":value,"id":AppGlobals.currentId++};
      String url;
      if(coinType==null){
        url=rpc??"";
      }else{
        url=RequestUrl().getUrl2(coinType, "rpc",isTest: isTest);
      }
      final data=await BaseApi.RequestEmpty_h.post(url, params: {},data: postData);
      if(data.containsKey('error')){
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
/*
  //获取abi文件
  static getABI(String coinType,String address,{bool isTest=false})async{
    try{
      MessageModel mm=MessageModel();

      final data=await Api.RequestEmpty_h.get(Api.getUrl2(coinType, "api",isTest:isTest ), params: {
        "module":"contract",
        "action":"getabi",
        "address":address,
      },);
      if(data.containsKey('error')){
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
  //获取abi文件
  static getTokenInfo(String coinType,String address,{bool isTest=false})async{
    try{
      MessageModel mm=MessageModel();

      final data=await Api.RequestEmpty_h.get(Api.getUrl2(coinType, "api",isTest:isTest ), params: {
        "module":"token",
        "action":"tokeninfo",
        "address":address,
      },);
      if(data.containsKey('error')){
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
*/

  //获取 address 的交易列表
  getTxList(String address,{String? coinType,String contractAddress="",bool isTest=false,int page=1,int offset=10})async{
    //?module=账户&action= txlist &address={地址哈希}
    try{
      MessageModel mm=MessageModel();
      Map<String,dynamic> params;
      if(contractAddress==""){
        params={
          "address":address,
          "action":"txlist",
          "module":"account",
          "page":page,
          "offset":offset,
        };
      }else{
        params={
          "address":address,
          "action":"tokentx",
          "module":"account",
          "page":page,
          "offset":offset,
          "contractaddress":contractAddress,
        };
      }
      String url;
      if(coinType==null){
        url=api??"";
      }else{
        url=RequestUrl().getUrl2(coinType, "api",isTest: isTest);
      }
      var data=await BaseApi.RequestEmpty_h.get(url, params: params,);
      if(data.containsKey('error')){
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
