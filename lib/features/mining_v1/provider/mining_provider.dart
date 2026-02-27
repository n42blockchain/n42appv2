import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v1/models/mining_type.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MiningProvider extends ChangeNotifier {
  /// Whether the current wallet has an active deposit.
  bool? depositsEnable;
  bool miningStatus = false;

  void setDepositsEnable(bool? flag) {
    depositsEnable = flag;
    notifyListeners();
  }

  void setMiningStatus(bool status) {
    miningStatus = status;
    notifyListeners();
  }

  bool isLoadingMiningDeposits = false;

  void setLoadingDeposits(bool flag) {
    isLoadingMiningDeposits = flag;
    notifyListeners();
  }

  int depositsNum = 0;
  double miningIncome = 0;

  void setDepositsNum(int num) {
    depositsNum = num;
    notifyListeners();
  }

  void setMiningIncome(double num) {
    miningIncome = num;
    notifyListeners();
  }

  int mainChainMining = 0;

  void setMiningDev(int num) {
    mainChainMining = num;
    notifyListeners();
  }

  MiningType? _miningType;

  void setMiningType(MiningType? type) {
    _miningType = type;
    notifyListeners();
  }

  MiningType? get miningType => _miningType;

  /// Whether the user is participating in group mining.
  bool? isHaveGroupMining = false;

  void setGroupMiningStatus(bool status) {
    isHaveGroupMining = status;
    notifyListeners();
  }

  int walletIndex = -1;
  String walletName = "";
  String? address;

  void setWalletIndex(int index) {
    walletIndex = index;
    eventBus.fire(EventPublic(EventPublicType.selectMiningWallet,
        intValue: walletIndex));
  }

  void resetData() {
    depositsEnable = null;
    miningStatus = false;
    isLoadingMiningDeposits = false;
    depositsNum = 0;
    miningIncome = 0;
    _miningType = null;
    isHaveGroupMining = null;
    walletIndex = -1;
    walletName = "";
    address = null;
    notifyListeners();
  }

  Future<bool> checkHostNode(String host) async {
    for (int i = 0; i < 3; i++) {
      if (await checkHostConnection(host)) return true;
    }
    return false;
  }

  Future<bool> checkHostConnection(String url) async {
    try {
      final response = await Dio().get(url);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkAddressIsDepositAst(String address) async {
    try {
      final depositsOfResponse = await MiningApi.depositsOf(address);
      debugPrint("checkAddressIsDepositAst data:$depositsOfResponse");
      if (depositsOfResponse != null && depositsOfResponse is List) {
        final astNum = depositsOfResponse[0];
        if (astNum != BigInt.zero) {
          return true;
        }
      }
    } catch (err) {
      return false;
    }
    return false;
  }



  /// 抱团挖矿/质押NFT/质押AST
  /// 新增：FUJI NFT 质押
  /// Check whether the wallet at [wIndex] has an active mining deposit.
  ///
  /// First checks the local cache (SPUtil), then falls back to on-chain query.
  Future<void> checkAddressMiningStatus({int wIndex = -1}) async {
    try {
      if (wIndex == -1) wIndex = walletIndex;

      WalletActionProvider wap = globalWapAdapter;
      Map<String, dynamic>? cInfo = wap.walletInfoLsit[wIndex].coinInfo?[CoinType.N.name];
      if (cInfo == null) {
        walletIndex = wap.walletInfoLsit.indexWhere((e) => e.mainWallet == true);
        address = await wap.getMainWalletAddressAsync(CoinType.N.name);
      } else {
        walletIndex = wIndex;
        WalletInfo info = wap.walletInfoLsit[walletIndex];
        Map<String, dynamic> pathMap = cInfo['baseInfo']['path'];
        var rm = await Trustdart().generateAddress(
          CoinType.N.name,
          getPathWithIndex(pathMap[cInfo['addrType']], cInfo['pathIndex']),
          cInfo['addrType'],
          mnemonic: info.mnemonic ?? "",
          pk: info.privateKey ?? "",
        );
        address = rm[cInfo['addrType']];
      }
      walletName = wap.walletInfoLsit[walletIndex].walletName ?? "";
      if (address == null) return;

      setLoadingDeposits(true);
      bool finalResult = false;
      bool needsOnChainCheck = false;

      // Check local cache first
      Map<String, dynamic>? ms = await SPUtil().getMiningStautus();
      if (ms != null) {
        String? mType = ms[address]?['miningType'];
        if (mType == null) {
          needsOnChainCheck = true;
        } else {
          final key = AppConfig.isMainChainMining ? mType.toLowerCase() : '${mType.toLowerCase()}test';
          int? value = ms[address]?['miningValue']?[key];
          if (value != null && value != 0) {
            finalResult = true;
            if (mType == MiningType.N.name) _miningType = MiningType.N;
          } else {
            needsOnChainCheck = true;
          }
        }
      } else {
        needsOnChainCheck = true;
      }

      // Fall back to on-chain deposit check
      if (needsOnChainCheck) {
        finalResult = await checkAddressIsDepositAst(address ?? "");
        if (finalResult) {
          _miningType = MiningType.N;
          SPUtil().setMiningStatus(address ?? "", {'miningType': MiningType.N.name});
        }
      }

      setDepositsEnable(finalResult);
    } catch (err) {
      setDepositsEnable(null);
      debugPrint("checkAddressMiningStatus err: ${err.toString()}");
    } finally {
      setLoadingDeposits(false);
    }
  }
}