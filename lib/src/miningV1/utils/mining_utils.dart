import 'dart:convert';

import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/miningV1/provider/mining_provider.dart';
import 'package:n42appv2/src/miningV1/provider/mining_v1_providers.dart';
import 'package:n42appv2/src/miningV1/utils/mining_cache_utils.dart';
import 'package:n42appv2/src/miningV1/utils/mining_plugin_utils.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/core/providers/legacy_wallet_adapter.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:web3dart/web3dart.dart';

class MiningUtils{
  ///EVM SDK init
  static initEvmSdk() async {
    try{
      final cachePath = await MiningCacheUtils.getMiningCachePath();
      if (cachePath == null) {
        return false;
      }
      WalletActionProvider wap=globalWapAdapter;
      MiningProvider mp=globalMiningV1;
      //获取ast的 private key
      WalletInfo walletInfo=wap.walletInfoLsit[mp.walletIndex];

      final Map<String, dynamic>? map = walletInfo.coinInfo;
      final astMap = map?[CoinType.N.name];
      int pathIndex = astMap['pathIndex'] ?? 0;
      final path =
      getPathWithIndex(astMap["baseInfo"]["path"]["legacy"], pathIndex);
      Trustdart trustdart=Trustdart();
      String? privateKey=walletInfo.privateKey;
      var addressMap= await trustdart.generateAddress(
          CoinType.N.name, path, 'legacy',mnemonic: walletInfo.mnemonic??"",pk: walletInfo.privateKey??"");
      if(walletInfo.privateKey ==null){
        privateKey=await trustdart.getPrivateKey(walletInfo.mnemonic??"", CoinType.N.name, path);
      }
      final pk = base64Decode(privateKey??"");
      final astAddress = addressMap['legacy'];

      // ast 配置信息
      String webSocketUrl = await MiningCacheUtils.getCurrentSocketUrl();
      final data = await MiningPluginUtils.initSetting(
          astAddress, cachePath,
          bytesToHex(pk),
          //HexUtils().uint8ToHex(pk),
          webSocketUrl);
      if (data != null && data["code"] == 0) {
        return true;
      }
      return false;
    }catch(e){
      return false;
    }


  }

  static startMining() async {
    try {
      //判断用户是否开启挖矿
      final openState = await SPUtil().getOpenMining();
      if (!openState) {
        return;
      }
      await MiningPluginUtils.start();
    } catch (err) {
    }
  }

  /// stop mining work
  static stopMining() async {
    try{
      final statusData = await MiningPluginUtils.status();
      if (statusData?["data"] == "started") {
        await MiningPluginUtils.stop();
      }
    }catch(err){
    }
  }

  static Future setMainChainMining(bool value) async {
    return await SPUtil().setBoolValue(SPkey.mainChainMining.name, value);
  }

  static Future isMainChainMining() async {
    // return await SPUtils.getBoolValue(SPKey.mainChainMining,
    //     defaultValue: true);
    return AppConfig.isMainChainMining;
  }
/*
  //设置是否跳过
  static Future setMiningSkip(bool value) async {
    return await SPUtil().setBoolValue(SPkey.isSkipMiningPlans.name, value);
  }

  //是否跳过挖矿计划
  static Future isSkipPlans() async {
    return await SPUtil().getBoolValue(SPkey.isSkipMiningPlans.name,
        defaultValue: false);
  }*/
}