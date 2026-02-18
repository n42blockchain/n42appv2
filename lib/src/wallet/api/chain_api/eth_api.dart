import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/utils/message_model_bridge.dart';
import 'package:n42appv2/core/utils/result.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/utils/chain_1559.dart';
import 'package:web3dart/web3dart.dart';

class EthAPI{
  String? cType;
  String? rpc;
  String? api;
  EthAPI();
  EthAPI.init(this.cType,this.rpc,this.api);
  //获取余额
  Future<MessageModel> getBalance(String address,String contract,{bool isTest=false,String? coinType})async{
    if(contract==""){
      final result=await baseRPCEth("eth_getBalance",[address,"latest"],coinType:coinType??cType,isTest: isTest);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }else{
      String addr=strip0x(address);
      final result=await baseRPCEth("eth_call",[{"from": address,
        "to": contract, "data": "0x70a08231000000000000000000000000$addr"
      },"latest"],coinType: coinType??cType,isTest: isTest);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }
  }
  //获取gasPrice
  Future<MessageModel> getGasPrice({bool isTest=false,String? coinType,})async{
    final result=await baseRPCEth("eth_gasPrice",[],coinType: coinType??cType,isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=hexToInt(mm.data);
    }
    return mm;
  }
  //获取预估值
  Future<MessageModel> getGasLimit(
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
        //"id":AppGlobals.nextId,
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
      final result=await baseRPCEth(
          "eth_estimateGas",
          [params,"latest"],
          coinType: coinType??cType,
          isTest: isTest);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      // On error, mm.data is already the message string from AppError.message
      return mm;
    }
    else{
      String toAddress=strip0x(to);
      String aaa=bytesToHex(keccakAscii("transfer(address,uint256)"));
      aaa=aaa.substring(0,8).toLowerCase();
      Uint8List valueList=padUint8ListTo32(unsignedIntToBytes(value));
      String valueHex=bytesToHex(valueList);
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
        "id":AppGlobals.nextId,
      };
      if(get1559WithChainSymbol(coinType??cType??"")){
        params["maxFeePerGas"]='0x${gasPrice.toRadixString(16)}';
      }else{
        params["gasPrice"]='0x${gasPrice.toRadixString(16)}';
      }
      //TokenViewApi tokenViewApi=TokenViewApi();
      //return await tokenViewApi.getGasEstimate_eth(params);
      final result=await baseRPCEth("eth_estimateGas",[params,"latest"],isTest: isTest,coinType: coinType??cType);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      // On error, mm.data is already the message string from AppError.message
      return mm;
    }
  }
  Future<MessageModel> getGasLimitByMap(Map<String,dynamic> map,{String? coinType,bool isTest=false,bool addLatest=true})async{
    List param=[map];
    if(addLatest){
      param.add("latest");
    }
    final result=await baseRPCEth("eth_estimateGas",param,coinType: coinType??cType,isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=hexToInt(mm.data);
    }
    return mm;
  }
  //获取交易收据
  Future<MessageModel> getTransactionReceipt(String txHash,{String? coinType,bool isTest=false})async{
    return resultToMessageModel(
      await baseRPCEth("eth_getTransactionReceipt",[txHash],coinType: coinType??cType,isTest: isTest),
    );
  }
  //获取交易信息
  Future<MessageModel> getTransactionByHash(String txHash, {String? coinType,bool isTest=false})async{
    return resultToMessageModel(
      await baseRPCEth("eth_getTransactionByHash",[txHash],coinType: coinType??cType,isTest: isTest),
    );
  }
  //获取nonce值
  Future<MessageModel> getTransactionCount(String address,{String? coinType,bool isTest=false})async{
    final result=await baseRPCEth("eth_getTransactionCount",[address,"latest"],coinType: coinType??cType,isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=hexToInt(mm.data);
    }
    return mm;
  }

  //发送交易，返回交易hash（明确禁用重试，防止双发）
  Future<MessageModel> sendTransaction(String value,{String? coinType,bool isTest=false})async{
    return resultToMessageModel(
      await baseRPCEth("eth_sendRawTransaction",[value],coinType: coinType??cType,isTest: isTest,enableRetry: false),
    );
  }

  /// Raw eth_call with pre-built data
  /// Used for AA operations like getNonce from EntryPoint
  Future<MessageModel> ethCallRaw(String to, String data, {String? coinType, bool isTest = false}) async {
    return resultToMessageModel(
      await baseRPCEth(
        "eth_call",
        [{"to": to, "data": data}, "latest"],
        coinType: coinType ?? cType,
        isTest: isTest,
      ),
    );
  }

  /// Get contract code at address
  /// Used to check if a smart account is deployed
  Future<MessageModel> getCode(String address, {String? coinType, bool isTest = false}) async {
    return resultToMessageModel(
      await baseRPCEth(
        "eth_getCode",
        [address, "latest"],
        coinType: coinType ?? cType,
        isTest: isTest,
      ),
    );
  }

  Future<Result<dynamic, AppError>> baseRPCEth(
    String method,
    var value, {
    String? coinType,
    bool? isTest,
    bool enableRetry = true,
  }) async {
    try {
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":value,"id":AppGlobals.nextId};
      String url;
      if(coinType==null){
        url=rpc??"";
      }else{
        url=RequestUrl().getUrl2(coinType, "rpc",isTest: isTest);
      }
      final data=await BaseApi.requestEmptyH.post(url, params: {},data: postData,enableRetry: enableRetry);
      if(data.containsKey('error')){
        final errorObj = data['error'];
        final errorMsg = errorObj is Map
            ? (errorObj['message']?.toString() ?? errorObj.toString())
            : errorObj?.toString() ?? 'RPC error';
        return Result.failure(AppError.blockchain(
          errorMsg,
          code: 'ETH_RPC_ERROR',
          originalError: data['error'],
        ));
      }
      return Result.success(data['result']);
    } on DioException catch (e) {
      return Result.failure(AppError.network(
        e.message ?? 'Network error',
        code: 'NET_${e.type.name.toUpperCase()}',
        originalError: e,
      ));
    } catch (e, st) {
      return Result.failure(AppError.unknown(e.toString(), originalError: e, stackTrace: st));
    }
  }
/*
  //获取abi文件
  static getABI(String coinType,String address,{bool isTest=false})async{
    try{
      MessageModel mm=MessageModel();

      final data=await Api.requestEmptyH.get(Api.getUrl2(coinType, "api",isTest:isTest ), params: {
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

      final data=await Api.requestEmptyH.get(Api.getUrl2(coinType, "api",isTest:isTest ), params: {
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
  Future<MessageModel> getTxList(String address,{String? coinType,String contractAddress="",bool isTest=false,int page=1,int offset=10})async{
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
      var data=await BaseApi.requestEmptyH.get(url, params: params,);
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
