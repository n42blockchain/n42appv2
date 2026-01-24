import 'dart:convert';

import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:flutter/services.dart';

class Trustdart {
  final MethodChannel _channel = const MethodChannel('trustdart');
  //生成12个助记词 128 默认，生成15个助记词 160,生成18个助记词 192,生成21个助记词 228,生成24个助记词 256，
  Future<String> generateMnemonic({String passphrase = "",int length = 128}) async {
    try {
      final String mnemonic =
      await _channel.invokeMethod('generateMnemonic', <String, dynamic>{
        'passphrase': passphrase,
        'length': length,
      });
      return mnemonic;
    } catch (e) {
      return "";
    }
  }

  Future<bool> checkMnemonic(
      String mnemonic,
      {String passphrase = ""}) async {
    try {
      final bool importStatus =
      await _channel.invokeMethod('checkMnemonic', <String, String>{
        'mnemonic': mnemonic,
        'passphrase': passphrase,
      });
      if(importStatus==true){
        return true;
      }else{
        return false;
      }
      //return importStatus;
    } catch (e) {
      return false;
    }
  }

  /// generates an address for a particular coin
  Future<Map> generateAddress(
      String coin,
      String path,
      String addressType,
      {String mnemonic="", String passphrase = "",String pk="",bool isImport=false,bool isTest=false}) async {
    try {
      final Map address = await _channel.invokeMethod('generateAddress', <String, String>{
        'coin': coin,
        'path': path,
        'mnemonic': mnemonic,
        'passphrase': passphrase,
        'addressType':addressType,
        'pk':pk,
        'isImport':'$isImport',
        'isTest':'$isTest'
      });
      return address;
    } catch (e) {
      return {'legacy': ''};
    }
  }

  /// validates address belonging to a particular crypto
  Future<bool> validateAddress(String coin, String address) async {
    try {
      final bool isAddressValid =
      await _channel.invokeMethod('validateAddress', <String, String>{
        'coin': coin,
        'address': address,
      });
      return isAddressValid;
    } catch (e) {
      return false;
    }
  }

  /// Returns the hex string format of the public key.
  Future<String> getPublicKey(
      String coin,
      String path,
      {String passphrase = "",String mnemonic="",String pk=""}) async {
    try {
      final String publicKey =
      await _channel.invokeMethod('getPublicKey', <String, String>{
        'coin': coin,
        'path': path,
        'mnemonic': mnemonic,
        'passphrase': passphrase,
        "pk":pk
      });
      return publicKey;
    } catch (e) {
      return '';
    }
  }

  /// Returns the hex string format of the private key.
  Future<String> getPrivateKey(
      String mnemonic,
      String coin,
      String path,
      {String passphrase = ""}) async {
    try {
      final String privateKey =
      await _channel.invokeMethod('getPrivateKey', <String, String>{
        'coin': coin,
        'path': path,
        'mnemonic': mnemonic,
        'passphrase': passphrase,
      });
      return privateKey;
    } catch (e) {
      return '';
    }
  }
  Future<String> getPrivateKeyAndPublicKeyPair(
      String coin,
      String path,
      {String pk="",String mnemonic="",String passphrase=""}) async {
    try {
      final String keyPair =
      await _channel.invokeMethod('getPrivateKeyAndPublicKey', <String, String>{
        'coin': coin,
        'path': path,
        'mnemonic': mnemonic,
        'privateKey':pk,
        'passphrase': passphrase,
      });
      return keyPair;
    } catch (e) {
      return '';
    }
  }
  ///返回最大交易金额
  Future<String> signTransaction_maxValue(
      String coin,
      String path,
      Map txData,
      {String mnemonic="", String pk="",String passphrase = ""}) async {
    try {
      final String txHash =
      await _channel.invokeMethod('getTransactionMaxValue', <String, dynamic>{
        'coin': coin,
        'txData': txData,
        'path': path,
        'mnemonic': mnemonic,
        'passphrase': passphrase,
        'pk':pk,
      });
      return txHash;
    } catch (e) {
      return '';
    }
  }

  ///signs a transaction
  Future<String> signTransaction(
      String coin,
      String path,
      Map txData,
      {String mnemonic="",String pk="",String passphrase = ""}) async {
    try {
      final String txHash =
      await _channel.invokeMethod('signTransaction', <String, dynamic>{
        'coin': coin,
        'txData': txData,
        'path': path,
        'mnemonic': mnemonic,
        'passphrase': passphrase,
        'pk':pk,
      });
      return txHash;
    } catch (e) {
      return '';
    }
  }
  Future<String> signTransaction_g(
      String coin,
      String path,
      Map txData,
      {String mnemonic="",String pk="",String passphrase = ""}) async {
    try {
      final String txHash =
      await _channel.invokeMethod('signTransaction_g', <String, dynamic>{
        'coin': coin,
        'txData': txData,
        'path': path,
        'mnemonic': mnemonic,
        'passphrase': passphrase,
        'pk':pk,
      });
      return txHash;
    } catch (e) {
      return '';
    }
  }
  Future<String> signTransaction_btc_p2wsh(
      String coin,
      String path,
      Map txData,
      {String mnemonic="",String pk="",String passphrase = ""}) async {
    try {
      final String txHash =
      await _channel.invokeMethod('signTransaction_btc_p2wsh', <String, dynamic>{
        'coin': coin,
        'txData': txData,
        'path': path,
        'mnemonic': mnemonic,
        'passphrase': passphrase,
        'pk':pk,
      });
      return txHash;
    } catch (e) {
      return '';
    }
  }
  Future<Map> signTransaction_byteArray(
      String coin,
      String path,
      Map txData,
      {String mnemonic="",String pk="",String passphrase = ""}) async {
    try {
      final String txHash =
      await _channel.invokeMethod('signTransaction_byteArray', <String, dynamic>{
        'coin': coin,
        'txData': txData,
        'path': path,
        'mnemonic': mnemonic,
        'passphrase': passphrase,
        'pk':pk,
      });
      return json.decode(txHash);
    } catch (e) {
      return {"result":false,"signHash":""};
    }
  }
  Future<String> signMessage(
      String coin,
      String path,
      String txData,
      {String mnemonic="",String pk="",String passphrase = ""}) async {
    try {
      final String txHash =
      await _channel.invokeMethod('signMessage', <String, dynamic>{
        'coin': coin,
        'txData': txData,
        'path': path,
        'mnemonic': mnemonic,
        'passphrase': passphrase,
        'pk':pk,
      });
      return txHash;
    } catch (e) {
      return '';
    }
  }
  //返回keystore
  Future<String> getKeyStore(
      String coin,
      String path,
      String addressType,
      String passphrase,
      {String mnemonic="",String pk="",})async{
    try {
      final String keyStoreJson =
      await _channel.invokeMethod('getKeyStore', <String, dynamic>{
        'coin': coin,
        'path': path,
        'mnemonic': mnemonic,
        'passphrase': passphrase,
        'addressType':addressType,
        'pk':pk
      });
      return keyStoreJson;
    } catch (e) {
      return "";
    }
  }
  //根据keystore 返回privateKey，address 等信息
  Future<Map> getWalletInfoWithKeyStore(
      String keyStore,
      String coin,
      String passphrase,)async{
    try {
      final Map keyStoreJson =
      await _channel.invokeMethod('getWalletInfoWithKeyStore', <String, dynamic>{
        'keyStore': keyStore,
        'coin': coin,
        'passphrase': passphrase,
      });
      return keyStoreJson;
    } catch (e) {
      return {"address":"","privateKey":""};
    }
  }
  //返回solana token Account
  Future<String> getPubKeySOL(String address,String mintAddress)async{
    try {
      final String pubKey =
      await _channel.invokeMethod('getPubKeySOL', <String, dynamic>{
        'address': address,
        'mintAddress': mintAddress,
      });
      return pubKey;
    } catch (e) {
      return "";
    }
  }
  //启动 ios LiveActivity 功能
  Future<MessageModel> LiveActivity_Start()async{
    try {
      int? type=await SPUtil().getBackgroundMiningMusic();
      final String rData =
      await _channel.invokeMethod('LiveActivityStart',<String, dynamic>{
      'type': type??0,
      });
      MessageModel rmm=MessageModel();
      if(rData !="true"){
        rmm.data=rData;
      }
      return rmm;
    } catch (e) {
      MessageModel rmm=MessageModel.error();
      rmm.data=e.toString();
      return rmm;
    }
  }
  Future<MessageModel> LiveActivity_Update(int value)async{
    try {
      final String rData =
      await _channel.invokeMethod('LiveActivityUpdate',<String,dynamic>{"value":value});
      MessageModel rmm=MessageModel();
      if(rData !="true"){
        rmm.data=rData;
      }
      return rmm;
    } catch (e) {
      MessageModel rmm=MessageModel.error();
      rmm.data=e.toString();
      return rmm;
    }
  }
  Future<MessageModel> LiveActivity_End(int value)async{
    try {
      final String rData =
      await _channel.invokeMethod('LiveActivityEnd',<String,dynamic>{"value":value});
      MessageModel rmm=MessageModel();
      if(rData !="true"){
        rmm.data=rData;
      }
      return rmm;
    } catch (e) {
      MessageModel rmm=MessageModel.error();
      rmm.data=e.toString();
      return rmm;
    }
  }
  //获取权限，暂时只支持ios
  Future<String> getPermissions(String pType)async{
    try {
      final String rData =
      await _channel.invokeMethod('Permissions',<String, dynamic>{
        'pName': pType
      });
      return rData;
    } catch (e) {
      return "";
    }
  }

  //evm
  Future<Map<String, dynamic>?> evmEmit(Map<String, dynamic> params)async{
    try {
      final String rData =
      await _channel.invokeMethod('EvmEmit',params);
      return jsonDecode(rData);
    } catch (e) {
      return null;
    }
  }
  //mining
  Future<String?> miningGenerateBls12381Keypair()async{
    try {
      final String rData =
      await _channel.invokeMethod('MiningGenerateBls12381Keypair',);
      return rData;
    } catch (e) {
      return null;
    }
  }
  Future<String?> miningCreateDepositUnsignedTx(Map<String, dynamic> params)async{
    try {
      final String rData =
      await _channel.invokeMethod('MiningCreateDepositUnsignedTx',params);
      return rData;
    } catch (e) {
      return null;
    }
  }
  Future<String?> miningRunClient(Map<String, dynamic> params)async{
    try {
      final String rData =
      await _channel.invokeMethod('MiningRunClient',params);
      return rData;
    } catch (e) {
      return null;
    }
  }
  Future<String?> miningCreateGetExitFeeUnsignedTx()async{
    try {
      final String rData =
      await _channel.invokeMethod('MiningCreateGetExitFeeUnsignedTx',);
      return rData;
    } catch (e) {
      return null;
    }
  }
  Future<String?> miningCreateExitUnsignedTx(Map<String, dynamic> params)async{
    try {
      final String rData =
      await _channel.invokeMethod('MiningCreateExitUnsignedTx',params);
      return rData;
    } catch (e) {
      return null;
    }
  }
}
