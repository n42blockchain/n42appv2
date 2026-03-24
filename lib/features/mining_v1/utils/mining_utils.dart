import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_provider.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_cache_utils.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_plugin_utils.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:web3dart/web3dart.dart';

class MiningUtils {
  ///EVM SDK init
  static Future<bool> initEvmSdk() async {
    try {
      final cachePath = await MiningCacheUtils.getMiningCachePath();
      if (cachePath == null) {
        return false;
      }
      final wap = globalWapAdapter;
      final MiningProvider mp = globalMiningV1;
      final WalletInfo walletInfo = wap.walletInfoLsit[mp.walletIndex];

      final Map<String, dynamic>? map = walletInfo.coinInfo;
      final astMap = map?[CoinType.N.name];
      final int pathIndex = astMap['pathIndex'] ?? 0;
      final path = getPathWithIndex(
        astMap["baseInfo"]["path"]["legacy"],
        pathIndex,
      );
      final Trustdart trustdart = Trustdart();
      String? privateKey = walletInfo.privateKey;
      final Map<dynamic, dynamic> addressMap = await trustdart.generateAddress(
        CoinType.N.name,
        path,
        'legacy',
        mnemonic: walletInfo.mnemonic ?? "",
        pk: walletInfo.privateKey ?? "",
      );
      if (walletInfo.privateKey == null) {
        privateKey = await trustdart.getPrivateKey(
          walletInfo.mnemonic ?? "",
          CoinType.N.name,
          path,
        );
      }
      final pk = base64Decode(privateKey ?? "");
      final astAddress = addressMap['legacy'];
      final String webSocketUrl = await MiningCacheUtils.getCurrentSocketUrl();
      final data = await MiningPluginUtils.initSetting(
        astAddress,
        cachePath,
        bytesToHex(pk),
        webSocketUrl,
      );
      if (data != null && data["code"] == 0) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> startMining() async {
    try {
      final openState = await SPUtil().getOpenMining();
      if (!openState) {
        return;
      }
      await MiningPluginUtils.start();
    } catch (err) {
      if (kDebugMode) debugPrint('[MiningUtils] startMining failed: $err');
    }
  }

  /// stop mining work
  static Future<void> stopMining() async {
    try {
      final statusData = await MiningPluginUtils.status();
      if (statusData?["data"] == "started") {
        await MiningPluginUtils.stop();
      }
    } catch (err) {
      if (kDebugMode) debugPrint('[MiningUtils] stopMining failed: $err');
    }
  }

  static Future<bool?> setMainChainMining(bool value) async {
    return SPUtil().setBoolValue(SPkey.mainChainMining.name, value);
  }

  static Future<bool> isMainChainMining() async {
    return AppConfig.isMainChainMining;
  }
}
