import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/src/utils/data_utils.dart';
import 'package:n42_wallet/src/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:date_format/date_format.dart' as dformat;

class BtcTransactionRecodeModel{
  int trId=0;
  String address="";
  String to1="";
  int price=0;
  int gas=0;
  String txHash="";
  int confirmations=0;
  int state=0;
  String txTime=(DateTime.now().millisecondsSinceEpoch~/1000).toString();
  String errorMessage="";
  String coinMiniName="";
  String contract="";
  List<InputModel>? inputModels;
  List<InputModel> get inputModelsList{
    inputModels ??= [];
    return inputModels!;
  }
  List<OutputModel>? outputModels;
  List<OutputModel> get outputModelsList{
    outputModels ??= [];
    return outputModels!;
  }
  Map<String,dynamic> coin={};//币基本信息
  int isTest=0;//是否是测试地址，0不是，1是
  String testnetUri="";//测试网地址api地址
  String userUuid=AppGlobals.userInfo?.uuid??"";//用户uuid
  int walletIndex =0;//钱包id
  bool max=false;//转账最大值

  String signStr="";//不写入数据库
  int gasPrice=0;//gas费
  String addrType="segwit";
  List<String>? inputsAddress;
  List<String>? outputsAddress;
  String? inputAddressStr;
  String? outputAddressStr;

  List<String> get inputsAddressList{
    if(inputsAddress==null){
      inputsAddress=[];
      for(InputModel im in inputModelsList){
        inputsAddress!.addAll(im.address);
      }
    }
    return inputsAddress!;
  }
  List<String> get outputsAddressList{
    if(outputsAddress==null){
      outputsAddress=[];
      for(OutputModel om in outputModelsList){
        outputsAddress!.addAll(om.address);
      }
    }
    return outputsAddress!;
  }
  String get inputAddressStrValue{
    if(inputAddressStr==null){
      inputAddressStr="";
      for(String addr in inputsAddressList){
        if(address.toUpperCase() != addr.toUpperCase()){
          String addrf=DataUtils().addressFarmat(addr);
          inputAddressStr='$inputAddressStr$addrf ';
        }
      }
      inputAddressStr=inputAddressStr!.trimRight();
      inputAddressStr=inputAddressStr!.replaceAll(" ", ',');
    }
    return inputAddressStr!;
  }
  String get outputAddressStrValue{
    if(outputAddressStr==null){
      outputAddressStr="";
      for(String addr in outputsAddressList){
        if(address.toUpperCase() != addr.toUpperCase()){
          String addrf=DataUtils().addressFarmat(addr);
          outputAddressStr='$outputAddressStr$addrf ';
        }
      }
      outputAddressStr=outputAddressStr!.trimRight();
      outputAddressStr=outputAddressStr!.replaceAll(" ", ',');
    }
    return outputAddressStr!;
  }
  String? txTimeStr;

  List<Map<String, dynamic>> inputModelsMap(){
    List<Map<String,dynamic>> utxo=[];
    for(InputModel im in inputModelsList){
      utxo.add(im.toMap());
    }
    return utxo;
  }
  //获取 的转出utxo btc总和
  int inputPrice(){
    if(inputModelsList.isEmpty){
      return 0;
    }else{
      int inputPrice=0;
      for(InputModel im in inputModelsList){
        inputPrice+=im.value;
      }
      return inputPrice;
    }
  }
  //获取double类型的 转出utxo btc总和
  double inputPriceDouble(){
    if(inputModelsList.isEmpty){
      return 0.0;
    }else{
      double inputPrice=0.0;
      for(InputModel im in inputModelsList){
        inputPrice+=im.value/100000000;
      }
      return inputPrice;
    }
  }
  //获取double 类型的 price 转出金额
  double priceDouble(){
    if(price==0){
      return 0;
    }else{
      return toEther(price.toString(),coin['decimals']).toDouble();
    }
  }
  //获取double类型的gas
  double gasDouble(){
    if(gas==0){
      return 0;
    }else{
      return toEther(gas.toString(),coin['decimals']).toDouble();
    }
  }
  //赋值gas
  void setGasDouble(double g){
    gas=BigInt.from(g*100000000).toInt();
  }
  String getTxTimeStr(){
    if(txTimeStr==null){
      int tt=0;
      if(txTime.length==13){
        tt=int.parse(txTime);
      }else{
        tt=int.parse(txTime)* 1000;
      }
      txTimeStr= dformat.formatDate(
          DateTime.fromMillisecondsSinceEpoch(tt), [
        dformat.yyyy,
        '/',
        dformat.mm,
        '/',
        dformat.dd,
        ' ',
        dformat.am,
        ' ',
        dformat.hh,
        ':',
        dformat.nn
      ]);
    }
    return txTimeStr!;
  }
  BtcTransactionRecodeModel();

  BtcTransactionRecodeModel.fromMap(Map<String,dynamic> map){
    List<dynamic> inputs=jsonDecode(map["input"]);
    List<dynamic> outputs=jsonDecode(map["output"]);
    for(dynamic s in inputs){
      Map<String,dynamic> input=jsonDecode(s);
      inputModelsList.add(InputModel.fromMap(input));
    }
    for(dynamic s in outputs){
      Map<String,dynamic> output=jsonDecode(s);
      outputModelsList.add(OutputModel.fromMap(output));
    }
    trId=map['trId'];
    address=map['address'];
    to1=map['to1'];
    price=int.parse(map['price']);
    gas=int.parse(map['gas']);
    txHash=map['txHash'];
    confirmations=map['confirmations'];
    state=map['state'];
    txTime=map['txTime'];
    errorMessage=map['errorMessage'];
    coinMiniName=map['coinMiniName'];
    contract=map['contract'];
    coin=json.decode(map['coin']);
    isTest=map['isTest'];
    testnetUri=map['testnetUri'];
    userUuid=map['userUuid'];
    walletIndex=map['walletIndex'];
    gasPrice=map['gasPrice'];
  }
  Map<String, dynamic> toMapDb(){
    List<String> inputs=[];
    for(InputModel im in inputModelsList){
      inputs.add(jsonEncode(im.toMap()));
    }
    List<String> outputs=[];
    for(OutputModel om in outputModelsList){
      outputs.add(jsonEncode(om.toMap()));
    }
    return {
      "address":address,
      "to1":to1,
      "price":price,
      "gas":gas,
      "txHash":txHash,
      "confirmations":confirmations,
      "state":state,
      "txTime":txTime,
      "coinMiniName":coinMiniName,
      "errorMessage":errorMessage,
      "contract":contract,
      "input":jsonEncode(inputs).toString(),
      "output":jsonEncode(outputs).toString(),
      "coin":json.encode(coin),
      'isTest':isTest,
      'testnetUri':testnetUri,
      'userUuid':userUuid,
      'walletIndex':walletIndex,
      'gasPrice':gasPrice
    };
  }
  Map<String, dynamic> toMap(){
    List<String> inputs=[];
    for(InputModel im in inputModelsList){
      inputs.add(jsonEncode(im.toMap()));
    }
    List<String> outputs=[];
    for(OutputModel om in outputModelsList){
      outputs.add(jsonEncode(om.toMap()));
    }
    return {
      "trId":trId,
      "address":address,
      "to1":to1,
      "price":price,
      "gas":gas,
      "txHash":txHash,
      "confirmations":confirmations,
      "state":state,
      "txTime":txTime,
      "coinMiniName":coinMiniName,
      "errorMessage":errorMessage,
      "contract":contract,
      "input":jsonEncode(inputs).toString(),
      "output":jsonEncode(outputs).toString(),
      "coin":json.encode(coin),
      'isTest':isTest,
      'testnetUri':testnetUri,
      'userUuid':userUuid,
      'walletIndex':walletIndex,
      'gasPrice':gasPrice,
    };
  }
}
class InputModel{
  int value=0;
  String txid="";
  int vout=0;
  String script="";
  String witnessValue="";
  int lockTime=0;
  List<String> address=[];
  double valueDouble(){
    if(value==0){
      return 0;
    }else{
      return value/100000000;
    }
  }
  InputModel({this.value=0,this.txid="",this.vout=0,this.script="",this.witnessValue="",this.lockTime=0});
  InputModel.fromMap(Map<String,dynamic> map){
    value=int.parse(map['value']);
    txid=map['txid'];
    vout=map['vout'];
    script=map['script'];
    witnessValue=map['witnessValue'];
    lockTime=map['lockTime'];
    List<dynamic> addr=map['address'];
    for(dynamic a in addr){
      address.add(a.toString());
    }
  }
  Map<String, dynamic> toMap(){
    return {
      "value":value.toString(),
      "txid":txid,
      "vout":vout,
      "script":script,
      "witnessValue":witnessValue,
      "address":address,
      "lockTime":lockTime,
    };
  }

}
class OutputModel{
  List<String> address=[];
  int price=0;
  String script="";
  double priceDoubleValue(){
    if(price==0){
      return 0;
    }else{
      return price/100000000;
    }
  }
  OutputModel({this.price=0,this.script=""});
  OutputModel.fromMap(Map<String,dynamic> map){
    List<dynamic> addr=map['address'];
    for(dynamic a in addr){
      address.add(a.toString());
    }
    price=map['price'];
    script=map['script'];
  }
  Map<String, dynamic> toMap(){
    return {
      "address":address,
      "price":price,
      "script":script,
    };
  }
}
