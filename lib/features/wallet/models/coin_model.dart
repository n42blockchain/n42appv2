import 'package:flutter/foundation.dart';
import 'package:n42_wallet/features/wallet/models/coin_model_wallet_access.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
class CoinModel {
  //数字格式化实例
  static final NumberFormat _oCcy = NumberFormat("#,##0.####", "en_US");
  Map<String, dynamic> coin = {};//主链基本信息
  Map<String,dynamic> tokens={};//代币列表
  ///提供计算属性 代替coin
  bool showList=true;//是否显示在主页列表上
  String? privateKey;//是否时导入钱包
  bool isTest=false;//是否是测试网，默认主网
  bool supportTest=true;//是否支持测试
  BigInt balance = BigInt.from(0); //余额
  double coinPrice = 0; //币价
  double value = 0; //价值 balance * coinPrice
  double percentage = 0; //百分比
  Map<String, dynamic> walletAddress = {};
  dynamic address;
  Map<String,dynamic> addressType={};//地址类型legacy、segwit
  String addrType="legacy";
  int pathIndex=0;//path index
  bool isRefresh = false;
  bool loadError = false; //加载是否失败，如果失败钱包item会提示叹号
  String? mainCoinIcon;//主链币图标地址
  bool custom=false;
  /// 用户手动置顶标记（运行时状态，不序列化）
  bool isPinned = false;

  dynamic other;

  /// Reference to wallet access layer, set by WalletActionProvider during construction.
  /// This breaks the circular dependency: CoinModel no longer imports WAP directly.
  ICoinModelWalletAccess? walletAccess;

  CoinModel();
  CoinModel.fromJson(Map<String,dynamic> json){
    coin=json['coin'] as Map<String,dynamic>;
    tokens=json['coin'] as Map<String,dynamic>;
    showList=json['showList'] as bool;
    privateKey=json['privateKey'] as String?;
    isTest=json['isTest'] as bool;
    supportTest=json['supportTest'] as bool;
    balance=BigInt.parse(json['balance'] as String);
    coinPrice=(json['coinPrice'] as num).toDouble();
    value=(json['value'] as num).toDouble();
    percentage=(json['percentage'] as num).toDouble();
    walletAddress=json['walletAddress'] as Map<String,dynamic>;
    address=json['address'];
    addressType=json['addressType'] as Map<String,dynamic>;
    addrType=json['addrType'] as String;
    pathIndex=json['pathIndex'] as int;
    mainCoinIcon=json['mainCoinIcon'] as String?;
  }
  Map<String, dynamic> toJson(){
    return {
      'coin': coin,
      'tokens': tokens,
      'showList': showList,
      'privateKey': privateKey,
      'isTest': isTest,
      'supportTest': supportTest,
      'balance': balance.toString(),
      'coinPrice': coinPrice,
      'value': value,
      'percentage': percentage,
      'walletAddress': walletAddress,
      'address': address,
      'addressType': addressType,
      'addrType': addrType,
      'pathIndex': pathIndex,
      'isRefresh': isRefresh,
      'loadError': loadError,
      'mainCoinIcon': mainCoinIcon
    };
  }
  double balanceDoubleAll() {
    return toEther(balance.toString(), coin['decimals']??0).toDouble();
  }

  //返回余额的 科学计数
  String balanceString() {
    return _oCcy.format(balanceDoubleAll());
  }
  //返回余额的 全部位数
  String balanceStringAll(){
    return Decimal.parse(balanceDoubleAll().toString()).toString();
  }

  //返回value 的科学计数
  String valueString() {
    return _oCcy.format(value);
  }
  String coinPriceString() {
    return _oCcy.format(coinPrice);
  }
  CoinModel.fromMap(Map<String, dynamic> map, ) {
    coin = map;
  }
  // setAddress 控制是否将地址写回 walletAccess
  Future<void> buildWallet({String pk = "", bool setAddress = true, int? walletIndex, ICoinModelWalletAccess? walletAccess}) async {
    walletAccess ??= this.walletAccess;
    if (address != null) return;

    if (walletAccess == null) {
      debugPrint('CoinModel.buildWallet: walletAccess is required');
      loadError = true;
      return;
    }

    final String coinType = coin['coinType'];
    final WalletInfo info = walletIndex == null
        ? walletAccess.walletInfo
        : walletAccess.walletInfoList[walletIndex];

    // 观察钱包：直接使用存储的观察地址，跳过密钥推导（仅对主钱包生效）
    if (walletIndex == null && info.watchOnly && info.watchAddress.isNotEmpty) {
      address = info.watchAddress;
      addressType[addrType] = info.watchAddress;
      if (setAddress) {
        walletAccess.setAddress(coinType, addressType);
      }
      return;
    }

    final Map<String, dynamic>? pathMap = coin['path'];
    if (pathMap == null) {
      debugPrint('CoinModel.buildWallet: path is null for $coinType');
      loadError = true;
      return;
    }

    final Map<Object?, Object?> rm = await Trustdart().generateAddress(
      coinType,
      getPathWithIndex(pathMap[addrType], pathIndex),
      pathMap[addrType],
      mnemonic: info.mnemonic ?? "",
      pk: privateKey ?? "",
      isTest: isTest,
    );

    for (final key in rm.keys) {
      addressType[key as String] = rm[key];
    }

    // 安全检查：确保 rm[addrType] 不为 null 且不为空
    final generatedAddress = rm[addrType];
    if (generatedAddress == null || (generatedAddress as String).isEmpty) {
      debugPrint('CoinModel.buildWallet: Failed to generate address for $coinType (addrType: $addrType)');
      loadError = true;
      walletAccess.refresh();
      return;
    }

    address = generatedAddress;
    if (walletIndex == null && setAddress) {
      walletAccess.setAddress(coinType, addressType);
    }
  }
  Future<void> getBalanceDefault()async{
    try {
      if(isTest){
        balance=BigInt.parse(coin['balance_test']?.toString() ?? '0');
      }else{
        balance=BigInt.parse(coin['balance']?.toString() ?? '0');
      }
      percentage = (coin['percentage'] as num?)?.toDouble() ?? 0.0;
      coinPrice = (coin['coinPrice'] as num?)?.toDouble() ?? 0.0;
      value=balanceDoubleAll()*coinPrice;
    } catch (e) {
      debugPrint('CoinModel.getBalanceDefault error: $e');
      balance = BigInt.zero;
      percentage = 0.0;
      coinPrice = 0.0;
      value = 0.0;
    }
  }
  //是否是刷新，目前只有tron 链 使用
  Future<bool> getBalance({bool getToken=true, ICoinModelWalletAccess? walletAccess}) async {
    walletAccess ??= this.walletAccess;
    if (walletAccess == null) {
      debugPrint('CoinModel.getBalance: walletAccess is required');
      return false;
    }
    try {
      //如果币的地址为空，创建地址
      if (address == null) {
        await buildWallet(walletAccess: walletAccess);
      }
      // getBalanceWithCoinModel 返回 true 表示有错误，false 表示成功
      final bool hasError = await walletAccess.getBalanceWithCoinModel(this);
      loadError = false;
      if (hasError) {
        // 获取余额失败，但不设置 loadError，因为已经使用了缓存的余额
        walletAccess.refresh();
        return false;
      }
      // 获取余额成功
      walletAccess.calculateBalanceWidthCoinModel();
      return true;
    } catch (e) {
      debugPrint('CoinModel.getBalance error: $e');
      loadError = true;
      isRefresh = false;
      walletAccess.refresh();
      return false;
    }
  }
}

class AlgoModel {
  int? code;
  BigInt minBalance=BigInt.from(100000);
  AlgoModel.fromCode(this.code);
  AlgoModel.fromMinBalance(this.minBalance);
}
class XrpModel{
  int sequence=0;
  bool account=false;
  int ownerCount=0;
  XrpModel(this.sequence,this.account,this.ownerCount);
  //激活账户必须持有的最小值
  int reserveBase=10000000;
  //每添加一个对象（如 trust line、挂单、payment channel）需加锁
  int reserveInc=2000000;
  //理论最低手续费单位（网络空闲时）
  int baseFee=10;
  //固定值，表示最小负载因子基准，一般为 256（不能变）
  int loadBase=256;
  //当前节点对费用的整体乘数因子，用来估算“标准”费用。
  // 👉 计算：实际费用 = base_fee × (load_factor / load_base)
  int loadFactor=256;
  void setServiceState(Map<String,dynamic> data){
    reserveBase=data['reserve_base'];
    reserveInc=data['reserve_inc'];
    baseFee=data['base_fee'];
    loadBase=data['load_base'];
    loadFactor=data['load_factor'];
  }
  int get getLockAmount => reserveBase + ownerCount * reserveInc;
}
class XlmModel{
  bool account=false;
  XlmModel(this.account);
}
class SolModel {
  Map<String,dynamic> solanaTokenAccount={};
  String selectSolanaTokenAccountKey="";
  List<dynamic>? spl;//代币余额
}
class TrxModel extends CoinModel{
  List<dynamic>? trc20;
  TrxModel(this.trc20);
}
