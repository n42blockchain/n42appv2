import 'dart:convert';

import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/utils/sp_util.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
//import 'package:flutter_mining/flutter_mining.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';

//final _flutterMiningPlugin = FlutterMining();

class ChatUtil {
  Future<String?> chatEnCode(String pubKey, String msg) async {
    final Map<String,dynamic> params = {};
    params["type"] = "encrypt";
    params["val"] = {"public_key": pubKey, "msg": msg};
    final evmRes = await Trustdart().evmEmit(params);
    //_flutterMiningPlugin.emit(json.encode(params));
    return evmRes?["data"];
  }

  Future<String?> chatDecode(String privateKey, String msg) async {
    final Map<String,dynamic> params = {};
    params["type"] = "decrypt";
    params["val"] = {"priv_key": privateKey, "msg": msg};
    final evmRes = await await Trustdart().evmEmit(params);
    //_flutterMiningPlugin.emit(json.encode(params));
    return evmRes?["data"];
  }

  Future<String?> getAstPrivateKey() async {
    WalletActionProvider wap=Provider.of<WalletActionProvider>(Application.AppContext,listen: false);
    //获取ast的 private key
    WalletInfo walletInfo;
    if(wap.walletInfo.mainWallet==true){
      walletInfo=wap.walletInfo;
    }else{
      int index=wap.walletInfoLsit.indexWhere((e)=>e.mainWallet==true);
      if(index !=-1){
        walletInfo=wap.walletInfoLsit[index];
      }else{
        return "";
      }
    }


    //WalletInfo walletInfo = Provider.of<WalletActionProvider>(Application.AppContext,listen: false).walletInfo;
    final Map<String, dynamic>? map = walletInfo.coinInfo;
    final astMap = map?[CoinType.N.name];
    if (astMap != null) {
      int pathIndex = astMap['pathIndex'] ?? 0;
      final path =
      getPathWithIndex(astMap["baseInfo"]["path"]["legacy"], pathIndex);
      String? privateKey=walletInfo.privateKey;
      if(walletInfo.privateKey ==null){
        privateKey=await Trustdart().getPrivateKey(walletInfo.mnemonic!, CoinType.N.name, path,);
      }
      final pk = base64Decode(privateKey!);
      return bytesToHex(pk);
        //HexUtils().uint8ToHex(pk);
    }

    return null;
  }

  Future<String?> getAstPubKey() async {
    //获取ast的 private key
    WalletActionProvider wap=Provider.of<WalletActionProvider>(Application.AppContext,listen: false);
    //获取ast的 private key
    WalletInfo walletInfo;
    if(wap.walletInfo.mainWallet==true){
      walletInfo=wap.walletInfo;
    }else{
      int index=wap.walletInfoLsit.indexWhere((e)=>e.mainWallet==true);
      if(index !=-1){
        walletInfo=wap.walletInfoLsit[index];
      }else{
        return "";
      }
    }
    //WalletInfo walletInfo = Provider.of<WalletActionProvider>(Application.AppContext,listen: false).walletInfo;
    final Map<String, dynamic>? map = walletInfo.coinInfo;
    final astMap = map?[CoinType.N.name];
    if (astMap != null) {
      int pathIndex = astMap['pathIndex'] ?? 0;
      final path =
      getPathWithIndex(astMap["baseInfo"]["path"]["legacy"], pathIndex);
      String privateKey=await Trustdart().getPublicKey(
        CoinType.N.name,
        path,
        mnemonic: walletInfo.mnemonic??"",
        pk:walletInfo.privateKey??"",
      );
      final pk = base64Decode(privateKey);
      return bytesToHex(pk);
    }
    return null;
  }

  Future cacheChatMessage(String key, String message) async {
    final chatCacheKey = "${Application.userInfo?.uuid}_chatKey";
    final data = await getChatCacheMessage();
    Map<String, dynamic> map = {};
    map[key] = message;
    if (data != null) {
      map.addAll(data);
    }
    return await SPUtil().putObject(chatCacheKey, map);
  }

  Future getChatCacheMessage() async {
    final chatCacheKey = "${Application.userInfo?.uuid}_chatKey";
    return await SPUtil().getObject(chatCacheKey);
  }
}