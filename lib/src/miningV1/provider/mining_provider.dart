import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/providers/legacy_wallet_adapter.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/miningV1/api/mining_api.dart';
import 'package:n42appv2/src/miningV1/models/mining_type.dart';
import 'package:n42appv2/src/miningV1/utils/mining_utils.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MiningProvider extends ChangeNotifier {
  //是否已经质押
  bool? depositsEnable;
  bool miningStatus = false;

  setDepositsEnable(bool? flag) {
    depositsEnable = flag;
    notifyListeners();
  }

  setMiningStatus(bool status) {
    miningStatus = status;
    notifyListeners();
  }

  bool isLoadingMiningDeposits = false;

  setLoadingDeposits(bool flag) {
    isLoadingMiningDeposits = flag;
    notifyListeners();
  }

  int depositsNum = 0;
  double miningIncome = 0;

  setDepositsNum(int num) {
    depositsNum = num;
    notifyListeners();
  }

  setMiningIncome(double num) {
    miningIncome = num;
    notifyListeners();
  }

  int mainChainMining = 0;

  setMiningDev(int num) {
    mainChainMining = num;
    notifyListeners();
  }

  MiningType? _miningType;

  setMiningType(MiningType? type) {
    _miningType = type;
    notifyListeners();
  }

  MiningType? get miningType => _miningType;

  //用户是否参与了团挖矿
  bool? isHaveGroupMining = false;

  setGroupMiningStatus(bool status) {
    isHaveGroupMining = status;
    notifyListeners();
  }
  int walletIndex=-1;
  String walletName="";
  String? address=null;
  setWalletIndex(int index){
    walletIndex=index;
    eventBus.fire(EventPublic(EventPublicType.selectMiningWallet,
        intValue: walletIndex));
  }

  resetData() {
    depositsEnable = null;
    miningStatus = false;
    isLoadingMiningDeposits = false;
    depositsNum = 0;
    miningIncome = 0;
    _miningType = null;
    isHaveGroupMining = null;
    walletIndex=-1;
    walletName="";
    address=null;
    notifyListeners();
  }

  Future<bool> checkHostNode(String host) async {
    const int maxAttempts = 3;
    for (int i = 0; i < maxAttempts; i++) {
      final flag = await checkHostConnection(host);
      if (flag) {
        return true;
      }
    }
    return false;
  }

  Future<bool> checkHostConnection(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get(url);
      return response.statusCode == 200;
    } catch (e) {
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
  Future<void> checkAddressMiningStatus({int wIndex=-1}) async {
    try {
      if(wIndex==-1){
        wIndex=walletIndex;
      }
      WalletActionProvider wap=globalWapAdapter;
      Map<String,dynamic>? cInfo=wap.walletInfoLsit[wIndex].coinInfo?[CoinType.N.name];
      if(cInfo==null){
        walletIndex=wap.walletInfoLsit.indexWhere((e)=>e.mainWallet==true);
        address = await wap.getMainWalletAddressAsync(CoinType.N.name);
      }else{
        walletIndex=wIndex;
        WalletInfo info = wap.walletInfoLsit[walletIndex];
        Map<String, dynamic> pathMap = cInfo['baseInfo']['path'];
        var rm=await Trustdart().generateAddress(
          CoinType.N.name,
          getPathWithIndex(pathMap[cInfo['addrType']], cInfo['pathIndex']),
          cInfo['addrType'],
          mnemonic: info.mnemonic??"",
          pk: info.privateKey??""
        );
        address =rm[cInfo['addrType']];
      }
      walletName=wap.walletInfoLsit[walletIndex].walletName??"";
      if (address == null) return;
      setLoadingDeposits(true);
      bool finalResult=false;
      bool checkAddress=false;
      Map<String,dynamic>? ms=await SPUtil().getMiningStautus();
      if(ms !=null){
        String? mType=ms[address]?['miningType'];
        if(mType ==null){
          checkAddress=true;
        }else{
          int? value;
          if(AppConfig.isMainChainMining){
            value=ms[address]?['miningValue']?[mType.toLowerCase()];
          }else{
            value=ms[address]?['miningValue']?['${mType.toLowerCase()}test'];
          }
          if(value !=null && value !=0){
            finalResult=true;
            if (mType==MiningType.N.name) {
              _miningType = MiningType.N;
            }
          }else{
            checkAddress=true;
          }
        }
      }else{
        checkAddress=true;
      }
      if(checkAddress){
        final future1 = checkAddressIsDepositAst(address??"");
        //final future2 = checkAddressIsDepositNft(address);
        //final future3 = checkAddressIsDepositFUJINft(address);
        //final future4 = checkAddressIsGroupMining(address);

        //setLoadingDeposits(true);
        final results = await Future.wait([future1, /*future2, future3,future4*/]);
        finalResult = results.contains(true);
        if (finalResult) {
          Map<String,dynamic> map={};
          if (results[0]) {
            _miningType = MiningType.N;
            map['miningType']=MiningType.N.name;
          }
          /*else if (results[1]) {
            _miningType = MiningType.NFT;
            map['miningType']=MiningType.NFT.name;
          }else if(results[2]){
            _miningType = MiningType.FUJI_NFT;
            map['miningType']=MiningType.FUJI_NFT.name;
          }
          if (results[3]) {
            setGroupMiningStatus(true);
            map['group']="true";
          }else{
            map['group']="false";
          }*/
          SPUtil().setMiningStatus(address??"", map);
        }
      }
      setDepositsEnable(finalResult);
      //initSkipPlans();
    } catch (err) {
      setDepositsEnable(null);
      debugPrint("checkAddressMiningStatus err：${err.toString()}");
    } finally {
      setLoadingDeposits(false);
    }
  }

  /*bool isSkipPlans = false;

  setSkipPlans(bool flag) {
    isSkipPlans = flag;
    notifyListeners();
  }

  initSkipPlans() async {
    isSkipPlans = await MiningUtils.isSkipPlans();
    notifyListeners();
  }*/
}