import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/shared/di/service_locator.dart';
import 'package:n42_wallet/core/network/external_http.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/api/market_api_payload_utils.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model_wallet_access.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_token.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_coin_model.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_delete_utils.dart';
import 'package:n42_wallet/features/wallet/provider/watch_only_wallet_utils.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:web3dart/web3dart.dart';

part 'wallet_action_provider_wallet.dart';
part 'wallet_action_provider_token.dart';
part 'wallet_action_provider_sort.dart';
part 'wallet_action_provider_market.dart';

String? resolveBalanceRpcOverride(CoinModel coinModel) {
  final coinType = coinModel.coin['coinType']?.toString().toUpperCase();
  if (coinType != CoinType.N.name || !coinModel.isTest) {
    return null;
  }

  final rpc = coinModel.coin['service_test']?.toString().trim() ?? '';
  return rpc.isEmpty ? null : rpc;
}

class WalletActionProvider extends ChangeNotifier
    implements ICoinModelWalletAccess {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  /// 公开的刷新方法，用于通知监听者数据已更新
  @override
  void refresh() {
    notifyListeners();
  }

  //刷新coin 余额
  Map<int, dynamic> coinRefreshMap = {};

  // ── 置顶同步缓存（避免无变化时重复遍历）────────────────────────────────────
  /// 上次 _syncPinnedState 时的 fingerprint；格式：pinnedHash|coinListLength
  String _lastSyncFingerprint = '';
  String defaultWalletUUID = "AstranetWallet";
  String get userUUID {
    if (AppGlobals.userInfo == null) return defaultWalletUUID;
    return AppGlobals.userInfo?.uuid ?? "";
  }

  late final TokenViewApi tokenViewApi = TokenViewApi();
  Load _load = Load.finish; //当前状态
  Load get load => _load;
  Load loadBalance = Load.finish;
  bool buildwallet = false;
  //数字格式化实例
  final NumberFormat _oCcy = NumberFormat("#,##0.00", "en_US");

  //钱包列表
  List<WalletInfo> _walletInfoLsit = [];
  List<WalletInfo> get walletInfoLsit => _walletInfoLsit;
  @override
  List<WalletInfo> get walletInfoList => _walletInfoLsit;
  @override
  WalletInfo get walletInfo {
    if (walletIndex < 0 || walletIndex >= _walletInfoLsit.length) {
      throw StateError(
        'Invalid walletIndex ($walletIndex) for list of ${_walletInfoLsit.length} wallets. '
        'Ensure wallet is initialized before accessing walletInfo.',
      );
    }
    return _walletInfoLsit[walletIndex];
  }

  //获取用户设置的钱包名字
  String get walletName {
    if (_walletInfoLsit.isEmpty ||
        walletIndex < 0 ||
        walletIndex >= _walletInfoLsit.length) {
      return "";
    }
    return walletInfo.walletName ?? "";
  }

  int walletIndex = -1; //钱包索引
  Future<void> setWalletIndex(int index) async {
    if (index == walletIndex) return;
    removeConRefreshMap(walletIndex);
    walletIndex = index;
    await saveWalletInfo(walletInfoLsit[walletIndex], walletIndex);

    await initWallet(shouldInitCoinInfo: true);
    notifyListeners();
  }

  int walletMiningIndex = -1; //钱包挖矿索引
  Future<void> setWalletMiningIndex(int index) async {
    if (index == walletMiningIndex) return;
    walletMiningIndex = index;
    await saveWalletInfo(walletInfoLsit[walletIndex], walletIndex);
  }

  Map<String, String>? _publicKeyAndPrivateKeyPair; //_walletInfoLsit所有钱包N的公钥私钥对
  Future<Map<String, String>> publicKeyAndPrivateKeyPair() async {
    if (_publicKeyAndPrivateKeyPair == null) {
      await getPublicKeyAndPrivateKeyPairN();
    }
    return _publicKeyAndPrivateKeyPair!;
  }

  //当前钱包数据
  Map<String, dynamic> get walletMap {
    // 安全访问 coinInfo，如果为 null 返回空 Map
    if (walletInfo.coinInfo == null) {
      debugPrint(
        'WalletActionProvider: walletMap accessed but coinInfo is null',
      );
      return {};
    }
    return walletInfo.coinInfo!;
  }

  /// 安全地更新 walletMap 中的数据
  void _safeUpdateWalletMap(CoinModel coinModel) {
    final coinType = coinModel.coin['coinType'];
    if (coinType == null || walletMap.isEmpty) return;

    final chainData = walletMap[coinType];
    if (chainData == null) return;

    try {
      if (coinModel.coin['isContract'] == false) {
        if (chainData['baseInfo'] != null) {
          walletMap[coinType]['baseInfo'] = coinModel.coin;
        }
      } else {
        if (coinModel.isTest) {
          final testnets = chainData['testnets'];
          if (testnets != null &&
              testnets.isNotEmpty &&
              testnets[0]['testnetContract'] != null) {
            walletMap[coinType]['testnets'][0]['testnetContract'][coinModel
                    .coin['mKey']] =
                coinModel.coin;
          }
        } else {
          final mainnets = chainData['mainnets'];
          if (mainnets != null) {
            walletMap[coinType]['mainnets'][coinModel.coin['mKey']] =
                coinModel.coin;
          }
        }
      }
    } catch (e) {
      debugPrint(
        'WalletActionProvider: Error updating walletMap for ${coinModel.coin['miniName']}: $e',
      );
    }
  }

  /// 深拷贝链配置，确保所有嵌套对象都被正确复制
  Map<String, dynamic> _deepCopyChainConfig(Map<String, dynamic> config) =>
      _deepCopyMap(config);

  /// 深拷贝 Map
  Map<String, dynamic> _deepCopyMap(Map map) {
    final copy = <String, dynamic>{};
    for (final key in map.keys) {
      final value = map[key];
      if (value is Map) {
        copy[key.toString()] = _deepCopyMap(value);
      } else if (value is List) {
        copy[key.toString()] = _deepCopyList(value);
      } else {
        copy[key.toString()] = value;
      }
    }
    return copy;
  }

  /// 深拷贝 List
  List<dynamic> _deepCopyList(List list) {
    return list.map((item) {
      if (item is Map) {
        return _deepCopyMap(item);
      } else if (item is List) {
        return _deepCopyList(item);
      } else {
        return item;
      }
    }).toList();
  }

  List<CoinModel> _coinModels = [];
  List<CoinModel> get coinModels => _coinModels;
  //首页 显示的币列表（包含 CoinModel 和 AggregatedCoinModel）
  List<dynamic> coinList = [];
  //钱包所有币种余额
  //可用余额，美刀
  double _balanceTotal = 0.0;
  double get balanceTotal => _balanceTotal;
  void setBalanceTotal(double price) {
    _balanceTotal = price;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  //获取外国余额，美刀形式
  String getBalanceTotal() {
    return _oCcy.format(_balanceTotal);
  }

  //市场上 币的信息，价格、涨跌幅、名称、名称缩写、icon地址
  List<dynamic> _coinMarketInfo = [];
  //币的地址 集合
  final Map<String, dynamic> _addrsss = {};
  Map<String, dynamic> get address => _addrsss;
  //根据 key 获取 币的地址
  dynamic getAddress(String coinKey, {String addrType = 'legacy'}) {
    Map<Object?, Object?>? addrs = _addrsss[coinKey];
    return addrs?[addrType];
  }

  Future<dynamic> getMainWalletAddressAsync(
    String coinKey, {
    String addrType = 'legacy',
  }) async {
    int index = walletInfoLsit.indexWhere((e) => e.mainWallet == true);
    if (index == -1) return "";
    if (walletInfoLsit[index].coinInfo == null) return "";
    Map<String, dynamic>? nCoinInfo = walletInfoLsit[index].coinInfo![coinKey];
    if (nCoinInfo == null) return "";
    Map<String, dynamic> pathMap = nCoinInfo['baseInfo']['path'];
    Map<Object?, Object?> rm = await Trustdart().generateAddress(
      coinKey,
      getPathWithIndex(pathMap[addrType], nCoinInfo['pathIndex']),
      addrType,
      mnemonic: walletInfoLsit[index].mnemonic ?? "",
      pk: walletInfoLsit[index].privateKey ?? "",
    );
    return rm[addrType];
  }

  //输入的是小写的coinKey
  CoinModel? getAddressCoinKeyLowerCase(String coinKey, String contract) {
    CoinModel? returnCM;
    if (contract == "") {
      for (CoinModel cm in _coinModels) {
        String cmCoinType = cm.coin['coinType'].toString().toLowerCase();
        if (cmCoinType == coinKey) {
          returnCM = cm;
          break;
        }
      }
    } else {
      contract = contract.toLowerCase();
      // 安全访问 walletMap
      final chainData = walletMap[coinKey.toUpperCase()];
      if (chainData != null && chainData['mainnets'] != null) {
        Map<String, dynamic> mainnets = chainData['mainnets'];
        if (mainnets.isNotEmpty) {
          List<String> mKeys = mainnets.keys.toList();
          for (String key in mKeys) {
            Map<String, dynamic> coin = mainnets[key];
            if (contract.toLowerCase() ==
                coin['contract'].toString().toLowerCase()) {
              returnCM = CoinModel.fromMap(mainnets[key]);
              break;
            }
          }
        }
      }
    }
    return returnCM;
  }

  //添加币到 集合中
  @override
  void setAddress(String key, Map<String, dynamic> value) {
    _addrsss[key] = value;
  }

  //返回 coinType 的主链 coinmodel
  CoinModel? getCoinModelWithCoinType(String coinType) {
    final index = _coinModels.indexWhere((e) => e.coin['coinType'] == coinType);
    return index != -1 ? _coinModels[index] : null;
  }

  //返回对应symbol 的coinmodel 列表（每个 symbol 只取第一个匹配）
  List<CoinModel> getCoinModelWithSymbols({
    String symbols = "ETH,BNB,TRX,OKT",
  }) {
    final symbolList = symbols.split(",");
    return [
      for (final symbol in symbolList)
        ...switch (getCoinModelWithCoinType(symbol)) {
          final cm? => [cm],
          null => const <CoinModel>[],
        },
    ];
  }

  /// 聚合代币列表 (USDT, USDC)
  List<AggregatedCoinModel> _aggregatedCoins = [];
  List<AggregatedCoinModel> get aggregatedCoins => _aggregatedCoins;

  /// 当前已置顶代币数量（O(1)，可安全在 build 中访问）。
  int get pinnedCoinCount => walletInfo.pinnedCoins.length;

  // ── 稳定币价格相关字段 ──────────────────────────────────────────────────

  /// 稳定币价格缓存（从 CoinGecko 获取）
  Map<String, Map<String, double>> _stablecoinPrices = {};

  /// 稳定币价格缓存时间戳
  DateTime? _stablecoinPricesFetchTime;

  /// 稳定币价格缓存有效期（5分钟）
  static const Duration _stablecoinCacheDuration = Duration(minutes: 5);

  // ---------------------------------------------------------------------------
  // USD → CNY 汇率（动态，从 CoinGecko 稳定币 CNY 报价推导）
  // ---------------------------------------------------------------------------

  /// 当前 USD→CNY 参考汇率，备用值 7.3
  double _usdToCnyRate = 7.3;
  double get usdToCnyRate => _usdToCnyRate;

  // ---------------------------------------------------------------------------
  // 市场价格最后成功更新时间（用于 UI "更新于 X 分钟前" 展示）
  // ---------------------------------------------------------------------------

  DateTime? _priceLastUpdated;
  DateTime? get priceLastUpdated => _priceLastUpdated;

  // ---------------------------------------------------------------------------
  // 市场数据防重复请求：两次 getCoinInfo() 间隔 < 30s 时跳过网络请求
  // ---------------------------------------------------------------------------

  DateTime? _coinMarketInfoFetchTime;
  static const Duration _marketInfoMinInterval = Duration(seconds: 30);

  /// 稳定币价格有效范围（防止异常数据）
  static const double _stablecoinMinPrice = 0.9;
  static const double _stablecoinMaxPrice = 1.1;

  /// 稳定币 symbol 到 CoinGecko ID 的映射
  static const Map<String, String> _stablecoinGeckoIds = {
    'usdt': 'tether',
    'usdc': 'usd-coin',
    'dai': 'dai',
    'busd': 'binance-usd',
    'tusd': 'true-usd',
    'usdp': 'paxos-standard',
    'gusd': 'gemini-dollar',
    'frax': 'frax',
  };

  /// 稳定币列表
  static const Set<String> _stablecoins = {
    'usdt',
    'usdc',
    'dai',
    'busd',
    'tusd',
    'usdp',
    'gusd',
    'frax',
  };

  //计算余额
  @override
  void calculateBalanceWidthCoinModel() {
    double tBalance = 0.0;
    for (int i = 0; i < coinList.length; i++) {
      tBalance += coinList[i].value;
    }
    setBalanceTotal(tBalance);
  }

  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async {
    //获取coin 的地址
    // 如果地址为 null，说明该链的地址生成失败，跳过余额获取
    if (coinModel.address == null) {
      debugPrint(
        'WalletActionProvider: Skipping balance fetch for ${coinModel.coin['miniName']} - address is null',
      );
      coinModel.loadError = true;
      return true; // 返回 true 表示有错误
    }
    String address = coinModel.address.toString();
    if (coinModel.coin['coinType'] == CoinType.BCH.name) {
      address = getAddress(coinModel.coin['coinType'], addrType: 'legacy');
    }
    //合约地址
    String contract = "";
    if (coinModel.coin['isContract'] == true) {
      contract = coinModel.isTest
          ? coinModel.coin['contract_test']
          : coinModel.coin['contract'];
    }
    if (coinModel.coin['isContract'] &&
        coinModel.coin['coinType'] == CoinType.ALGO.name) {
      return await getBalanceTokenAlgoWithCoinModel(coinModel);
    }

    //获取 coin 的余额
    MessageModel mm =
        await tokenViewApi.getBalance(
          coinModel.coin['blockchainType'],
          coinModel.coin['coinType'],
          address,
          contract: contract,
          isTest: coinModel.isTest,
          rpc: resolveBalanceRpcOverride(coinModel),
        ) ??
        MessageModel.error();
    _applyMarketPrice(coinModel);

    if (mm.error) {
      // 网络请求失败，使用缓存的余额数据
      debugPrint(
        'WalletActionProvider: Balance fetch failed for ${coinModel.coin['miniName']}, using cached balance',
      );
      _safeUpdateWalletMap(coinModel);
      coinModel.getBalanceDefault();
      coinModel.loadError = false;
      return true;
    }

    BigInt balance = BigInt.zero;
    if (coinModel.coin['coinType'] == CoinType.ALGO.name) {
      balance = mm.data['balance'];
      coinModel.other = AlgoModel.fromMinBalance(mm.data['minBalance']);
    } else if (coinModel.coin['coinType'] == CoinType.XRP.name) {
      balance = mm.data['balance'];
      coinModel.other = XrpModel(
        mm.data['sequence'],
        mm.data['account'],
        mm.data['ownerCount'],
      );
    } else {
      balance = mm.data;
    }
    final balanceKey = coinModel.isTest ? 'balance_test' : 'balance';
    coinModel.coin[balanceKey] = balance.toString();
    _safeUpdateWalletMap(coinModel);
    coinModel.getBalanceDefault();
    return false;
  }

  /// 从市场数据更新 coinModel 的价格信息
  void _applyMarketPrice(CoinModel coinModel) {
    final coinInfo = getCoinPriceWithUnit(coinModel.coin['unit'].toString());
    if (coinInfo == null) return;
    coinModel.coin['percentage'] = coinInfo['percentage'];
    coinModel.coin['coinPrice'] = coinModel.isTest
        ? 0.0
        : coinInfo['coinPrice'];
    coinModel.coin['icon'] = coinInfo['icon'];
  }
}
