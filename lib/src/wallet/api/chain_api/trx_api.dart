import 'dart:convert';
import 'dart:typed_data';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/message_model_bridge.dart';
import 'package:n42_wallet/core/utils/result.dart';
import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/http/base_api.dart';
import 'package:n42_wallet/src/http/request_url.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:web3dart/web3dart.dart';
import 'package:fast_base58/fast_base58.dart';

class TrxApi{
  late String url;
  late Map<String,String> header;
  TrxApi(){
    url="";//AppConfig.getApiUrlOnline('activiteHost');
    header={'content-type': 'application/json','TRON-PRO-API-KEY':'c0093859-4ae0-47b5-8650-6b14fec2d771'};
  }
  //trx,Tron
  //获取余额
  Future<MessageModel> getBalanceTrx(String address,String contract,{bool isTest=false})async{
    address= getAddressTron(address);
    if(contract==""){
      final result=await baseRPCEth("eth_getBalance",["0x$address","latest"]);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }else{
      contract=getAddressTron(contract);
      String addr=strip0x(address);
      final result=await baseRPCEth("eth_call",[{"from": "0x$address",
        "to": "0x$contract", "data": "0x70a082310000000000000000000000$addr"
      },"latest"]);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }
  }
  Future<MessageModel> getGasPriceTrx({bool isTest=false})async{
    final result=await baseRPCEth("eth_gasPrice",[],isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=hexToInt(mm.data);
    }
    return mm;
  }
  Future<MessageModel> getGasEstimateTrx(String from,String to,BigInt gasPrice,BigInt value,BigInt gas,{String contract="",bool isTest=false})async{
    from=getAddressTron(from);
    to=getAddressTron(to);
    if(contract==""){
      final result=await baseRPCEth("eth_estimateGas",
          [{"from": from,
            "to": to,
            "gasPrice":'0x${gasPrice.toRadixString(16)}',
            "gas":"0x${gas.toRadixString(16)}",
            "value":"0x${value.toRadixString(16)}",
          }],isTest:isTest);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }
    else{
      contract=getAddressTron(contract);
      String aaa=bytesToHex(keccakAscii("transfer(address,uint256)"));
      aaa=aaa.substring(0,8).toLowerCase();
      Uint8List valueList=padUint8ListTo32(unsignedIntToBytes(value));
      String valueHex=bytesToHex(valueList);
      final result=await baseRPCEth(
          "eth_estimateGas",
          [{"from": "0x$from",
            "to": "0x$contract",
            "gasPrice":'0x${gasPrice.toRadixString(16)}',
            "gas":"0x${gas.toRadixString(16)}",
            "data": "0x${aaa}0000000000000000000000$to$valueHex",
          }],isTest:isTest);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }
  }
  //或去最新块信息
  Future<MessageModel> getBlockNowTrx({bool isTest=false})async{
    try{
      String urlStr=RequestUrl().getUrl2(CoinType.TRX.name, 'rpc',isTest: isTest);
      var data=await BaseApi.requestEmptyH.post('$urlStr/wallet/getnowblock', params: {},header: header);
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
  Future<MessageModel> createTransaction(String fromAddress,String toAddress,int amount,{bool isTest=false})async{
    try{
      String url=RequestUrl().getUrl2(CoinType.TRX.name, 'api',isTest: isTest);
      Map<String,dynamic> map={
        "owner_address": fromAddress,
        "to_address": toAddress,
        "amount": amount,
        "visible": true
      };
      final rData=await BaseApi.requestEmptyH.post('$url/wallet/createtransaction', params: {},data: map);
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
  Future<MessageModel> sendTxTrx(String signStr,{bool isTest=false})async{
    try{
      String urlStr=RequestUrl().getUrl2(CoinType.TRX.name, 'api',isTest: isTest);
      final rData=await BaseApi.requestEmptyH.post('$urlStr/wallet/broadcasttransaction', params: {},data: jsonDecode(signStr),header: header);
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

  Future<Result<dynamic, AppError>> baseRPCEth(
    String method,
    var value, {
    bool? isTest,
    bool enableRetry = true,
  }) async {
    try {
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":value,"id":AppGlobals.nextId};
      String urlStr="${RequestUrl().getUrl2("TRX", "rpc",isTest: isTest)}/jsonrpc";
      final data=await BaseApi.requestEmptyH.post(
        urlStr,
        params: {},
        data: postData,
        header: header,
        enableRetry: enableRetry,
      );
      if(data.containsKey('error')){
        final errorMsg = data['error'] is Map
            ? (data['error']['message']?.toString() ?? 'RPC error')
            : data['error']?.toString() ?? 'RPC error';
        return Result.failure(AppError.blockchain(
          errorMsg,
          code: 'TRX_RPC_ERROR',
          originalError: data['error'],
        ));
      }
      return Result.success(data['result']);
    } catch (e, st) {
      // BaseHttp converts DioException to a localized String upstream.
      return Result.failure(AppError.network(e.toString(), originalError: e, stackTrace: st));
    }
  }
  String getAddressTron(String address){
    var decodeStr = Base58Decode(address);
    String hexAddress = bytesToHex(Uint8List.fromList(decodeStr));
    //HexUtils().uint8ToHex(Uint8List.fromList(decodeStr));
    return "41${hexAddress.substring(2, 42).toLowerCase()}";
  }
}
