import 'dart:convert';
import 'dart:typed_data';

import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:dio/dio.dart';

class AlgoApi{
  //static test
  //获取余额
  getBalance(String address,{String assetId="",bool isTest=false})async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.ALGO.name,'api',isTest:isTest);
      if(assetId!=""){
        MessageModel data=await BaseApi.requestEmptyH.get('${uri}v2/accounts/$address/assets/$assetId', params: {});
        Response rData=data.data;
        if(rData.statusCode==200 || rData.statusCode==201){
          Map<String,dynamic> rDataMap=jsonDecode(rData.data);
          data.data={
            "balance":BigInt.from(rDataMap['asset-holding']['amount']),
            "code":rData.statusCode,
          };
        }else if(rData.statusCode==404){
          data.data={
            "balance":BigInt.zero,
            "code":rData.statusCode,
          };
        }
        return data;
      }else{
        var data=await BaseApi.requestEmptyH.get('${uri}v2/accounts/$address', params: {});
        MessageModel mm=MessageModel();
        mm.data={
          "balance":BigInt.from(data['amount']),
          "minBalance":BigInt.from(data['min-balance'])
        };
        return mm;
      }

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //获取签名用的数据
  getTransactionsParams({bool isTest=false})async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.ALGO.name,'api',isTest:isTest);
      var data=await BaseApi.requestEmptyH.get('${uri}v2/transactions/params', params: {});
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //发送交易
  sendTx(Uint8List txHash,{bool isTest=false})async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.ALGO.name,'api',isTest:isTest);
      //Uint8List dataUint =DataUtils.hexStringToUint8List(txHash);
      final txData = Stream.fromIterable(txHash.map((i) => [i]));
      //return await sendTransaction(txHash);
      //return await sendTransaction_74(txHash);
      var data=await BaseApi.requestEmptyH.post('${uri}v2/transactions', params: {},data: txData,
        //contentType: "application/x-binary"
        header: {"Content-Type":"application/x-binary"},
      );
      MessageModel mm=MessageModel();
      mm.data=data['txId'];
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  /*
  static sendTransaction_74(Uint8List data) async {
    try{
      MultipartFile f=await MultipartFile.fromBytes(data,filename: 'rawtxn');
      FormData fd=FormData.fromMap({"file":f});
      final a=await Api.tokenViewHelp.post('v1/algo/tx/send', params: {},data: fd);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data'];
      }else{
        mm.data=a['message'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }

  }
  static sendTransaction(Uint8List data) async {
    try{
      String uri=Api.getUrl2(CoinType.ALGO.name,'api',isTest:true);
      final Dio _dio=Dio();
      const _extra = <String, dynamic>{};
      final queryParameters = <String, dynamic>{};
      final _data = Stream.fromIterable(data.map((i) => [i]));
      final _result = await _dio.request<Map<String, dynamic>>('${uri}v2/transactions',
          queryParameters: queryParameters,
          options: Options(
            method: 'POST',
            headers: <String, dynamic>{r'Content-Type': 'application/x-binary'},
            extra: _extra,
            contentType: 'application/x-binary',
          ),
          data: _data);
      MessageModel mm =MessageModel();
      mm.data=_result.data!['txId'];
      return mm;
    }catch(e){
      MessageModel mm =MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  */
  //根据txid获取交易信息
  getTransactionsInfo(String txId,{bool isTest=false})async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.ALGO.name,'api',isTest:isTest);
      var data=await BaseApi.requestEmptyH.get('${uri}v2/transactions/pending/$txId', params: {});
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
