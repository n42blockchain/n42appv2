import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:intl/intl.dart';

class CoinModel {
  static final NumberFormat _oCcy = NumberFormat("#,##0.####", "en_US");
  Map<String, dynamic> coin = {};
  Map<String, dynamic> tokens = {};
  bool showList = true;
  String? privateKey;
  bool isTest = false;
  bool supportTest = true;
  BigInt balance = BigInt.zero;
  double coinPrice = 0;
  double value = 0;
  double percentage = 0;
  Map<String, dynamic> walletAddress = {};
  dynamic address;
  Map<String, dynamic> addressType = {};
  String addrType = "legacy";
  int pathIndex = 0;
  bool isRefresh = false;
  bool loadError = false;
  String? mainCoinIcon;
  bool custom = false;

  /// 用户手动置顶标记（运行时状态，不序列化）
  bool isPinned = false;

  dynamic other;

  CoinModel();
  CoinModel.fromJson(Map<String, dynamic> json) {
    coin = (json['coin'] as Map<String, dynamic>?) ?? {};
    tokens = (json['tokens'] as Map<String, dynamic>?) ?? {};
    showList = (json['showList'] as bool?) ?? true;
    privateKey = json['privateKey'] as String?;
    isTest = (json['isTest'] as bool?) ?? false;
    supportTest = (json['supportTest'] as bool?) ?? true;
    balance = BigInt.tryParse(json['balance']?.toString() ?? '') ?? BigInt.zero;
    coinPrice = (json['coinPrice'] as num?)?.toDouble() ?? 0;
    value = (json['value'] as num?)?.toDouble() ?? 0;
    percentage = (json['percentage'] as num?)?.toDouble() ?? 0;
    walletAddress = (json['walletAddress'] as Map<String, dynamic>?) ?? {};
    address = json['address'];
    addressType = (json['addressType'] as Map<String, dynamic>?) ?? {};
    addrType = (json['addrType'] as String?) ?? 'legacy';
    pathIndex = (json['pathIndex'] as int?) ?? 0;
    loadError = (json['loadError'] as bool?) ?? false;
    mainCoinIcon = json['mainCoinIcon'] as String?;
  }
  Map<String, dynamic> toJson() {
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
      'mainCoinIcon': mainCoinIcon,
    };
  }

  double balanceDoubleAll() {
    return toEther(balance.toString(), coin['decimals'] ?? 0).toDouble();
  }

  String balanceString() {
    return _oCcy.format(balanceDoubleAll());
  }

  // toDouble() 会丢精度，直接用 Decimal 保留全部位数
  String balanceStringAll() {
    return toEther(balance.toString(), coin['decimals'] ?? 0).toString();
  }

  String valueString() {
    return _oCcy.format(value);
  }

  String coinPriceString() {
    return _oCcy.format(coinPrice);
  }

  CoinModel.fromMap(Map<String, dynamic> map) {
    coin = map;
  }
}

class AlgoModel {
  int? code;
  BigInt minBalance = BigInt.from(100000);
  AlgoModel.fromCode(this.code);
  AlgoModel.fromMinBalance(this.minBalance);
}

class XrpModel {
  int sequence = 0;
  bool account = false;
  int ownerCount = 0;
  XrpModel(this.sequence, this.account, this.ownerCount);
  //激活账户必须持有的最小值
  int reserveBase = 10000000;
  //每添加一个对象（如 trust line、挂单、payment channel）需加锁
  int reserveInc = 2000000;
  //理论最低手续费单位（网络空闲时）
  int baseFee = 10;
  //固定值，表示最小负载因子基准，一般为 256（不能变）
  int loadBase = 256;
  //当前节点对费用的整体乘数因子，用来估算"标准"费用。
  // 👉 计算：实际费用 = base_fee × (load_factor / load_base)
  int loadFactor = 256;
  void setServiceState(Map<String, dynamic> data) {
    reserveBase = data['reserve_base'];
    reserveInc = data['reserve_inc'];
    baseFee = data['base_fee'];
    loadBase = data['load_base'];
    loadFactor = data['load_factor'];
  }

  int get getLockAmount => reserveBase + ownerCount * reserveInc;
}

class XlmModel {
  bool account = false;
  XlmModel(this.account);
}

class SolModel {
  Map<String, dynamic> solanaTokenAccount = {};
  String selectSolanaTokenAccountKey = "";
  List<dynamic>? spl; //代币余额
}

class TrxModel extends CoinModel {
  List<dynamic>? trc20;
  TrxModel(this.trc20);
}
