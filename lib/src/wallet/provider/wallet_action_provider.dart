import 'dart:convert';
import 'dart:math';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/miningV2/provider/mining_v2_provider.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/shared/di/service_locator.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/wallet/api/market_api.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/models/aggregated_token.dart';
import 'package:n42appv2/src/wallet/models/aggregated_coin_model.dart';
import 'package:n42appv2/src/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:decimal/decimal.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:provider/provider.dart';

class WalletActionProvider extends ChangeNotifier{
  /// 公开的刷新方法，用于通知监听者数据已更新
  void refresh() {
    notifyListeners();
  }

  //刷新coin 余额
  Map<int,dynamic> coinRefreshMap={};
  String defaultWalletUUID="AstranetWallet";
  String get userUUID{
    if(AppGlobals.userInfo==null){
      return defaultWalletUUID;
    }else{
      return AppGlobals.userInfo?.uuid??"";
    }
  }
  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi{
    _tokenViewApi ??= TokenViewApi();
    return _tokenViewApi!;
  }
  //bool existWallet = false; //是否存在钱包
  Load _load = Load.finish; //当前状态
  Load get load => _load;
  Load loadBalance = Load.finish;
  bool buildwallet=false;
  //数字格式化实例
  final NumberFormat _oCcy = NumberFormat("#,##0.00", "en_US");

  //钱包列表
  List<WalletInfo> _walletInfoLsit = [];
  List<WalletInfo> get walletInfoLsit => _walletInfoLsit;
  WalletInfo get walletInfo{
    return _walletInfoLsit[walletIndex];
  }
  //获取用户设置的钱包名字
  String get walletName {
    if (_walletInfoLsit.isEmpty) return "";
    return walletInfo.walletName??"";
  }
  int walletIndex=-1;//钱包索引
  Future<void> setWalletIndex(int index)async{
    if(index==walletIndex)return;
    removeConRefreshMap(walletIndex);
    walletIndex=index;
    await saveWalletInfo(walletInfoLsit[walletIndex], walletIndex);

    await initWallet(shouldInitCoinInfo: true);
    notifyListeners();

  }
  int walletMiningIndex=-1;//钱包挖矿索引
  Future<void> setWalletMiningIndex(int index)async{
    if(index==walletMiningIndex)return;
    walletMiningIndex=index;
    await saveWalletInfo(walletInfoLsit[walletIndex], walletIndex);
    //eventBus.fire(EventPublic(EventPublicType.selectMiningWallet, intValue: walletMiningIndex));
  }
  Map<String,String>? _publicKeyAndPrivateKeyPair;//_walletInfoLsit所有钱包N的公钥私钥对
  Future<Map<String,String>> publicKeyAndPrivateKeyPair() async{
    if(_publicKeyAndPrivateKeyPair==null){
      await getPublicKeyAndPrivateKeyPairN();
    }
    return _publicKeyAndPrivateKeyPair!;
  }
  //当前钱包数据
  Map<String,dynamic> get walletMap{
    // 安全访问 coinInfo，如果为 null 返回空 Map
    if (walletInfo.coinInfo == null) {
      debugPrint('WalletActionProvider: walletMap accessed but coinInfo is null');
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
          if (testnets != null && testnets.isNotEmpty && testnets[0]['testnetContract'] != null) {
            walletMap[coinType]['testnets'][0]['testnetContract'][coinModel.coin['mKey']] = coinModel.coin;
          }
        } else {
          final mainnets = chainData['mainnets'];
          if (mainnets != null) {
            walletMap[coinType]['mainnets'][coinModel.coin['mKey']] = coinModel.coin;
          }
        }
      }
    } catch (e) {
      debugPrint('WalletActionProvider: Error updating walletMap for ${coinModel.coin['miniName']}: $e');
    }
  }
  List<CoinModel> _coinModels = [];
  List<CoinModel> get coinModels => _coinModels;
  //首页 显示的币列表（包含 CoinModel 和 AggregatedCoinModel）
  List<dynamic> coinList=[];
  //钱包所有币种余额
  //可用余额，美刀
  double _balanceTotal = 0.0;
  double get balanceTotal => _balanceTotal;
  void setBalanceTotal(double price) {
    //if(existWallet==false)return;
    _balanceTotal = price;
    notifyListeners();
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
  dynamic getAddress(String coinKey,{String addrType='legacy'}) {
    Map<Object?, Object?>? addrs = _addrsss[coinKey];
    return addrs?[addrType];
  }
  Future<dynamic> getMainWalletAddressAsync(String coinKey,{String addrType='legacy'}) async{
    int index=walletInfoLsit.indexWhere((e)=>e.mainWallet==true);
    if(index==-1)return "";
    if(walletInfoLsit[index].coinInfo == null) return "";
    Map<String,dynamic>? nCoinInfo=walletInfoLsit[index].coinInfo![coinKey];
    if(nCoinInfo ==null)return "";
    Map<String, dynamic> pathMap = nCoinInfo['baseInfo']['path'];
    Map<Object?, Object?> rm=await Trustdart().generateAddress(
      coinKey,
      getPathWithIndex(pathMap[addrType], nCoinInfo['pathIndex']),
      addrType,
      mnemonic: walletInfoLsit[index].mnemonic??"",
      pk:walletInfoLsit[index].privateKey??"",
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
        Map<String,dynamic> mainnets = chainData['mainnets'];
        if (mainnets.isNotEmpty) {
          List<String> mKeys = mainnets.keys.toList();
          for (String key in mKeys) {
            Map<String,dynamic> coin = mainnets[key];
            if (contract.toLowerCase() == coin['contract'].toString().toLowerCase()) {
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
  void setAddress(String key, Map<String, dynamic> value) {
    _addrsss[key] = value;
  }
  //返回 coinType 的主链 coinmodel
  CoinModel? getCoinModelWithCoinType(String coinType){
    CoinModel? rCoinModel;
    int index=_coinModels.indexWhere((element){
      if(element.coin['coinType']==coinType){
        return true;
      }
      return false;
    });
    if(index !=-1){
      rCoinModel=_coinModels[index];
    }
    return rCoinModel;
  }
//返回对应symbol 的coinmodel 列表
  List<CoinModel> getCoinModelWithSymbols({String symbols="ETH,BNB,TRX,OKT"}){
    List<String> symbolList=symbols.split(",");
    List<CoinModel> cList=[];
    for(String symbol in symbolList){
      int index=coinModels.indexWhere((element) {
        if(element.coin['coinType']==symbol){
          return true;
        }
        return false;
      });
      if(index !=-1){
        cList.add(coinModels[index]);
      }
    }
    return cList;
  }

  Future<void> initWallet({bool shouldInitCoinInfo=false})async{
    if(buildwallet==true)return;
    buildwallet=true;
    await getWalletInfo();
    // 同步新链到现有钱包
    await _syncNewChains();
    //导入的钱包
    //await initImportWallet();
    await buildCoinModel();
    buildwallet=false;
    notifyListeners();
    if(shouldInitCoinInfo){
      ///发送一个event事件 对挖矿进行初始化
      eventBus.fire(EventPublic(EventPublicType.selectWallet,
          intValue: walletIndex,stringValue: "wallet"));
      initCoinInfo();
    }
    await refreshWalletListNotifier();
  }
  //读取钱包信息
  Future<void> getWalletInfo() async {
    //if (walletInfoLsit.isNotEmpty) return;
    //await checkWalletInfo();
    Map<String, dynamic>? walletAll=await SPUtil().getWalletInfo();
    if (walletAll == null){
      await createWallet();
    }else{
      Map<String, dynamic>? walletUser=walletAll[userUUID];
      if(walletUser !=null){
        walletIndex=walletAll[userUUID]?['index'];
        if(walletAll[userUUID]?['miningIndex']==null || walletAll[userUUID]?['miningIndex']==-1){
          walletMiningIndex=walletIndex;
        }else{
          walletMiningIndex=walletAll[userUUID]?['miningIndex'];
        }
        List<dynamic> walletInfos =
            walletAll[userUUID]?["wallet"]??[]; //await SPUtils.getWalletInfo();
        _walletInfoLsit=[];
        //await getCoinSort();//获取当前钱包币的排序缓存
        for (int i = 0; i < walletInfos.length; i++) {
          _walletInfoLsit.add(WalletInfo.fromJson(walletInfos[i]));
        }
        //await getPublicKeyAndPrivateKeyPairN();
        //await createWallet();
        //existWallet = true;
      }
      else{
        Map<String, dynamic>? walletDefault=walletAll["AstranetWallet"];
        if(walletDefault !=null){
          walletIndex=walletDefault['index'];
          walletMiningIndex=walletDefault['miningIndex']??walletIndex;
          List<dynamic> walletInfos = walletDefault["wallet"]??[]; //await SPUtils.getWalletInfo();
          _walletInfoLsit=[];
          //await getCoinSort();//获取当前钱包币的排序缓存
          for (int i = 0; i < walletInfos.length; i++) {
            _walletInfoLsit.add(WalletInfo.fromJson(walletInfos[i]));
          }
          //await getPublicKeyAndPrivateKeyPairN();
          walletAll[userUUID]=walletDefault;
          walletAll.remove("AstranetWallet");
          await SPUtil().setWalletInfo(walletAll);
          //saveWalletInfo(walletInfo, walletIndex,isNewWallet: true);
        }else{
          await createWallet();
        }
      }
    }
    _load = Load.finish;
    notifyListeners();
  }

  /// 同步新链到现有钱包
  /// 检查 chainUrlMap 中是否有新链不在当前钱包中，如果有则自动添加
  Future<void> _syncNewChains() async {
    if (_walletInfoLsit.isEmpty) return;

    bool hasNewChains = false;

    // 遍历所有钱包
    for (int walletIdx = 0; walletIdx < _walletInfoLsit.length; walletIdx++) {
      final wallet = _walletInfoLsit[walletIdx];
      if (wallet.coinInfo == null) continue;

      // 检查 chainUrlMap 中的每条链
      for (final chainKey in chainUrlMap.keys) {
        // 如果钱包中没有这条链，添加它
        if (!wallet.coinInfo!.containsKey(chainKey)) {
          final chainConfig = chainUrlMap[chainKey];
          if (chainConfig != null && chainConfig['showList'] == true) {
            // 完全深拷贝链配置
            wallet.coinInfo![chainKey] = _deepCopyChainConfig(chainConfig);
            hasNewChains = true;
            debugPrint('WalletActionProvider: Added new chain $chainKey to wallet ${wallet.walletName}');
          }
        }
      }
    }

    // 如果有新链被添加，保存钱包信息
    if (hasNewChains) {
      for (int i = 0; i < _walletInfoLsit.length; i++) {
        await saveWalletInfo(_walletInfoLsit[i], i);
      }
      debugPrint('WalletActionProvider: Synced new chains to all wallets');
    }
  }

  /// 深拷贝链配置，确保所有嵌套对象都被正确复制
  Map<String, dynamic> _deepCopyChainConfig(Map<String, dynamic> config) {
    final copy = <String, dynamic>{};

    for (final key in config.keys) {
      final value = config[key];
      if (value is Map) {
        // 递归深拷贝 Map
        copy[key] = _deepCopyMap(value);
      } else if (value is List) {
        // 深拷贝 List
        copy[key] = _deepCopyList(value);
      } else {
        // 基本类型直接复制
        copy[key] = value;
      }
    }

    return copy;
  }

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

  //构建 币模型
  Future<void> buildCoinModel() async {
    if (_walletInfoLsit.isEmpty) return;
    List<dynamic> keym =walletMap.keys.toList();

    _coinModels=[];
    for (int i = 0; i < keym.length; i++) {
      CoinModel cm = CoinModel.fromMap(walletMap[keym[i]]['baseInfo']);
      bool? showList=walletMap[keym[i]]['showList'];
      if(showList==null){
        walletMap[keym[i]]['showList']=true;
      }
      cm.showList=walletMap[keym[i]]['showList'];
      cm.isTest=walletMap[keym[i]]['isTest'];
      cm.addrType=walletMap[keym[i]]['addrType'];
      cm.custom=walletMap[keym[i]]['baseInfo']['custom']??false;
      cm.pathIndex=walletMap[keym[i]]['pathIndex'] ?? 0;
      if(cm.isTest){
        Map<dynamic,dynamic> tokens=walletMap[keym[i]]['testnets'][0]['testnetContract'];
        if(tokens.isNotEmpty){
          cm.tokens=walletMap[keym[i]]['testnets'][0]['testnetContract'];
        }
      }else{
        Map<dynamic,dynamic> tokens=walletMap[keym[i]]['mainnets'];
        if(tokens.isNotEmpty){
          cm.tokens=walletMap[keym[i]]['mainnets'];
        }
      }
      cm.privateKey=walletInfo.privateKey;
      _coinModels.add(cm);
    }
    notifyListeners();
    await buildCoinModelInfo();
    if (!AppGlobals.appContext.mounted) return;
    Provider.of<TransactionRecordItemProvider>(AppGlobals.appContext,listen: false).selectUndoneTr();
  }
  /// 聚合代币列表 (USDT, USDC)
  List<AggregatedCoinModel> _aggregatedCoins = [];
  List<AggregatedCoinModel> get aggregatedCoins => _aggregatedCoins;

  Future<void> buildCoinModelInfo() async {
    coinList=[];
    _aggregatedCoins = [];
    int ethIndex = -1; // 记录 ETH 的位置，用于后续插入聚合代币

    for (int i = 0; i < _coinModels.length; i++) {
      CoinModel mm = _coinModels[i];
      await mm.buildWallet();
      mm.getBalanceDefault();
      if(mm.showList){
        coinList.add(mm);

        // 记录 ETH 的位置
        if (mm.coin['coinType'] == 'ETH' && ethIndex == -1) {
          ethIndex = coinList.length; // 记录插入位置（ETH 之后）
        }
      }
      List<String> tokenKeys=mm.tokens.keys.toList();
      for(String key in tokenKeys){
        Map<String,dynamic> token=mm.tokens[key];
        CoinModel cm=buildTokenCoinModel(mm,token);
        coinList.add(cm);
        //setTokenBalanceTotal(tokenBalanceTotal+cm.value);
      }
      notifyListeners();
    }

    // 在所有代币添加完成后，插入聚合代币
    await _insertAggregatedTokensAt(0); // 先插入，后面会排序

    // 应用优先级排序：N, BTC, ETH, USDT, USDC 在最前面
    _applyPriorityOrder();

    //coinSortAssets();
    calculateBalanceWidthCoinModel();
    saveCoinSort();
  }

  /// 优先级币种列表（按显示顺序）
  static const List<String> _priorityCoins = ['N', 'BTC', 'ETH', 'USDT', 'USDC'];

  /// 应用优先级排序，确保 N, BTC, ETH, USDT, USDC 在列表最前面
  void _applyPriorityOrder() {
    if (coinList.isEmpty) return;

    // 分离优先级币种和其他币种
    final priorityItems = <dynamic>[];
    final otherItems = <dynamic>[];

    for (final coin in coinList) {
      final symbol = _getCoinSymbol(coin);
      final priorityIndex = _priorityCoins.indexOf(symbol);
      if (priorityIndex != -1) {
        priorityItems.add({'index': priorityIndex, 'coin': coin});
      } else {
        otherItems.add(coin);
      }
    }

    // 按优先级排序
    priorityItems.sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));

    // 重建 coinList
    coinList.clear();
    for (final item in priorityItems) {
      coinList.add(item['coin']);
    }
    coinList.addAll(otherItems);
  }

  /// 获取币种符号（支持 CoinModel 和 AggregatedCoinModel）
  String _getCoinSymbol(dynamic coin) {
    if (coin is AggregatedCoinModel) {
      return coin.tokenConfig.symbol.toUpperCase();
    } else if (coin is CoinModel) {
      // 主链币使用 coinType，代币使用 miniName
      final coinType = coin.coin['coinType'] as String?;
      final miniName = coin.coin['miniName'] as String?;
      // 如果是主链币（coinType 和 miniName 相同或 miniName 为空）
      if (miniName == null || miniName.isEmpty || miniName == coinType) {
        return coinType?.toUpperCase() ?? '';
      }
      return miniName.toUpperCase();
    }
    return '';
  }

  /// 添加聚合代币 (USDT, USDC) 到列表，并进行去重检查
  /// [insertIndex] 参数已废弃，现在使用 _applyPriorityOrder 进行排序
  Future<void> _insertAggregatedTokensAt(int insertIndex) async {
    // 获取各链地址
    final addressByChain = <String, String>{};
    for (final cm in _coinModels) {
      final coinType = cm.coin['coinType'] as String?;
      if (coinType != null && cm.address != null) {
        addressByChain[coinType] = cm.address.toString();
      }
    }

    // 收集 coinList 中所有代币的符号（用于去重）
    final existingTokenSymbols = <String>{};
    for (final coin in coinList) {
      if (coin is CoinModel) {
        final miniName = (coin.coin['miniName'] ?? '').toString().toUpperCase();
        if (miniName.isNotEmpty) {
          existingTokenSymbols.add(miniName);
        }
      }
    }

    // 创建聚合代币（跳过已存在的）
    final toAdd = <AggregatedCoinModel>[];
    for (final tokenConfig in AggregatedTokens.all) {
      // 检查是否已存在相同符号的聚合代币
      final alreadyExists = _aggregatedCoins.any(
        (coin) => coin.tokenConfig.symbol == tokenConfig.symbol
      );
      if (alreadyExists) {
        continue; // 跳过已存在的聚合代币
      }

      // 检查 coinList 中是否已存在相同符号的代币
      if (existingTokenSymbols.contains(tokenConfig.symbol.toUpperCase())) {
        continue; // 跳过已存在的代币
      }

      final aggregatedCoin = AggregatedCoinModel(tokenConfig: tokenConfig);
      _aggregatedCoins.add(aggregatedCoin);
      toAdd.add(aggregatedCoin);

      // 异步获取余额（不阻塞 UI）
      aggregatedCoin.fetchAllBalances(addressByChain).then((_) {
        notifyListeners();
      });
    }

    // 添加聚合代币到列表（后续由 _applyPriorityOrder 排序）
    if (toAdd.isNotEmpty) {
      coinList.addAll(toAdd);
    }
  }
  CoinModel buildTokenCoinModel(CoinModel mainChain,Map<String,dynamic> token){
    CoinModel cm=CoinModel.fromMap(token);
    cm.mainCoinIcon=mainChain.coin['icon'];
    cm.privateKey=mainChain.privateKey;
    cm.pathIndex=mainChain.pathIndex;
    cm.isTest=mainChain.isTest;
    cm.addrType=mainChain.addrType;
    cm.custom=mainChain.custom;
    //ProviderUtil.walletActionProvider().getCoinPrice(cm);
    cm.address=mainChain.address;
    cm.addressType=mainChain.addressType;
    cm.getBalanceDefault();
    return cm;
  }
  //加载指定network的币
  Future<void> buildCoinModelInfoWithCoin() async {
    coinList=[];
    _aggregatedCoins = [];
    int ethIndex = -1; // 记录 ETH 的位置

    if(walletInfo.networkIndex==-1){
      for (int i = 0; i < _coinModels.length; i++) {
        CoinModel mm = _coinModels[i];
        await mm.buildWallet();
        if(mm.showList){
          mm.getBalanceDefault();
          coinList.add(mm);

          // 记录 ETH 的位置
          if (mm.coin['coinType'] == 'ETH' && ethIndex == -1) {
            ethIndex = coinList.length;
          }
        }
        List<String> tokenKeys=mm.tokens.keys.toList();
        for(String key in tokenKeys){
          CoinModel cm=buildTokenCoinModel(mm,mm.tokens[key]);
          coinList.add(cm);
        }
        notifyListeners();
      }

      // 在所有代币添加完成后，插入聚合代币
      await _insertAggregatedTokensAt(0);

      // 应用优先级排序：N, BTC, ETH, USDT, USDC 在最前面
      _applyPriorityOrder();
    }
    else{
      CoinModel mm = _coinModels[walletInfo.networkIndex];
      if(mm.showList){
        mm.getBalanceDefault();
        coinList.add(mm);
      }
      List<String> tokenKeys=mm.tokens.keys.toList();
      for(String key in tokenKeys){
        CoinModel cm=buildTokenCoinModel(mm,mm.tokens[key]);
        coinList.add(cm);
      }
    }
    // 排序时保持优先级（如果有自定义排序，之后会覆盖）
    if (walletInfo.coinSort['assets'] == -1 && walletInfo.coinSort['name'] == -1) {
      _applyPriorityOrder();
    } else {
      coinSortAssets();
    }
    notifyListeners();
    calculateBalanceWidthCoinModel();
    addCoinRefreshMap();
  }
  //币列表排序
  void setCoinSortAssets(String type){
    if(type=="assets"){
      if(walletInfo.coinSort['assets'] == 0){
        walletInfo.coinSort['assets']=1;
      }else if(walletInfo.coinSort['assets'] == 1){
        walletInfo.coinSort['assets']=0;
      }else{
        walletInfo.coinSort['assets']=1;
      }
      walletInfo.coinSort['name']=-1;
    }else{
      if(walletInfo.coinSort['name'] == 0){
        walletInfo.coinSort['name']=1;
      }else if(walletInfo.coinSort['name'] == 1){
        walletInfo.coinSort['name']=0;
      }else{
        walletInfo.coinSort['name']=1;
      }
      walletInfo.coinSort['assets']=-1;
    }

    //setCoinSort();
    coinSortAssets();
    notifyListeners();
  }
  //排序type all\keystore\main
  void coinSortAssets(){
    if(walletInfo.coinSort['assets']==0){
      coinList.sort((a, b,)=>(b.value).compareTo(a.value));
    }else if(walletInfo.coinSort['assets']==1){
      coinList.sort((a, b,)=>(a.value).compareTo(b.value));
    }
    if(walletInfo.coinSort['name']==0){
      coinList.sort((a, b,){
        String aName=a.coin['miniName'];
        String bName=b.coin['miniName'];
        return sortString(aName, bName);
      });
    }else if(walletInfo.coinSort['name']==1){
      coinList.sort((a, b,){
        String aName=a.coin['miniName'];
        String bName=b.coin['miniName'];
        return sortString(bName,aName);
      });
    }
    /*if(walletInfo.coinSort['assets']==-1 && walletInfo.coinSort['name']==-1){
      int index=coinList.indexWhere((e){
        if(e.coin['coinType']==CoinType.N.name){
          if(e.coin['mKey']=="0XE062FD6F7B483A648AB9F84AD2BA76F9DEB0A550"){
            return true;
          }
        }
        return false;
      });
      if(index !=-1){
        CoinModel cm=coinList[index];
        coinList.removeAt(index);
        coinList.insert(coinList.length,cm);
      }
    }*/
  }
  int sortString(String aName,String bName){
    int minCount=min(aName.length, bName.length);
    for(int i=0;i<minCount;i++){
      final l1=aName.codeUnitAt(i);
      final l2=bName.codeUnitAt(i);
      if(l1>l2){
        return 1;
      }else if(l1<l2){
        return -1;
      }else{
        continue;
      }
    }
    if(aName.length>bName.length){
      return 1;
    }else if(aName.length<bName.length){
      return -1;
    }else{
      return 0;
    }
  }
  //设置主钱包
  MessageModel setMainWallet(int wIndex){
    int index=walletInfoLsit.indexWhere((e){
      if(e.mainWallet==true){
        return true;
      }
      return false;
    });
    if(index==-1){
      MessageModel rmm=MessageModel.error();
      rmm.data="Main wallet not found!";
      return rmm;
    }else{
      walletInfoLsit[index].mainWallet=false;
      walletInfoLsit[wIndex].mainWallet=true;
      saveWalletInfoAll();
      eventBus.fire(EventPublic(EventPublicType.selectWallet,
          intValue: -1,stringValue: "mainwallet"));
      MessageModel rmm=MessageModel();
      return rmm;
    }
  }
  //保存钱包修改到SPUtil
  //isNewWallet，是否是添加新钱包
  Future<void> saveWalletInfo(WalletInfo newWalletInfo,int wIndex,{bool isNewWallet=false}) async{
    try{
      SPUtil sPUtils=SPUtil();
      Map<String, dynamic>? walletAll = await sPUtils.getWalletInfo();
      if (walletAll == null) {
        Map<String,dynamic> wallet=newWalletInfo.toJson();
        await sPUtils.setWalletInfo({
          userUUID: {
            "index":0,
            "miningIndex":0,
            "wallet":[wallet],
          }
        });
      } else {
        Map<String,dynamic>? userWallets=walletAll[userUUID];
        if(userWallets==null){
          walletAll[userUUID] = {
            "index":0,
            "miningIndex":0,
            "wallet":[newWalletInfo.toJson()],
          };
        }else{
          if(isNewWallet){
            List<dynamic> wallet=userWallets['wallet'];
            wallet.add(newWalletInfo.toJson());
            //userWallets['wallet']=wallet;
          }else{
            userWallets['wallet'][wIndex]=newWalletInfo.toJson();
          }
          userWallets['index']=wIndex;
          userWallets['miningIndex']=walletMiningIndex;
          walletAll[userUUID]=userWallets;
        }
        await sPUtils.setWalletInfo(walletAll);
      }
      await refreshWalletListNotifier();

    }catch(e){
      //ToastUtils.show3(e.toString());
      debugPrint("saveWalletInfo error: $e");
    }
  }
  //保存钱包数据
  Future<void> saveWalletInfoAll()async{
    SPUtil sPUtils=SPUtil();
    Map<String, dynamic>? walletAll = await sPUtils.getWalletInfo();
    if (walletAll != null) {
      walletAll[userUUID]['wallet']=walletInfoLsit.map((e) => e.toJson()).toList();
      walletAll[userUUID]['index']=walletIndex;
      walletAll[userUUID]['miningIndex']=walletMiningIndex;
      await sPUtils.setWalletInfo(walletAll);
      await refreshWalletListNotifier();
    }
  }
  //刷新缓存
  Future<void> refreshWalletListNotifier()async{
    // 刷新 WalletListNotifier 以同步数据
    try {
      final walletService = ServiceLocatorSetup.walletService;
      if (walletService != null) {
        await walletService.refreshWallets();
        debugPrint("saveWalletInfo: WalletListNotifier refreshed successfully");
      } else {
        debugPrint("saveWalletInfo: WalletService not available, skipping refresh");
      }
    } catch (refreshError) {
      debugPrint("saveWalletInfo: Error refreshing WalletListNotifier: $refreshError");
      // 不抛出异常，因为保存已经成功
    }
  }
  //保存币的排序缓存
  Future<void> saveCoinSort()async{
    saveWalletInfo(walletInfo,walletIndex);
  }
  //创建钱包
  Future<void> createWallet()async{
    WalletInfo wInfo=WalletInfo(
      walletName: "",
      password: "",
      walletUuid: userUUID,
    );
    wInfo.mnemonic= await Trustdart().generateMnemonic();
    wInfo.walletName="Account${walletInfoLsit.length+1}";
    wInfo.coinInfo = chainUrlMap;
    wInfo.mainWallet=true;
    //根据导入时间设置时间戳 标记钱包的唯一标识
    wInfo.timestamp = "${DateTime.now().millisecondsSinceEpoch}";
    await addWalletInfo(wInfo);
  }
  ///添加钱包
  Future<void> addWalletInfo(WalletInfo info) async {
    try{
      // 为了安全 存储时不在sp工具中存储助记词
      //克隆一份数据 不污染数据源
      Map<String, dynamic> newMap = info.toJson();//jsonDecode(jsonEncode(info));
      WalletInfo newWalletInfo = WalletInfo.fromJson(newMap);
      _walletInfoLsit.add(info);
      walletIndex=_walletInfoLsit.length-1;
      if(walletMiningIndex ==-1){
        walletMiningIndex=walletIndex;
      }
      await saveWalletInfo(newWalletInfo,walletIndex,isNewWallet: true);
      initWallet(shouldInitCoinInfo: true);
      //await getPublicKeyAndPrivateKeyPairN();
      notifyListeners();
    }catch(e){
      ToastUtils.show(e.toString());
    }

  }
  ///删除一个钱包
  Future<MessageModel?> deleteWalletInfo({WalletInfo? info}) async{
    if (_walletInfoLsit.isEmpty) return null;
    if (info == null) {
      //不传 默认移除第一个
      _walletInfoLsit.removeAt(0);
      return null;
    } else {
      int rIndex=_walletInfoLsit.indexWhere((element){
        if(element==info){
          return true;
        }else{
          return false;
        }
      });
      Map<String,dynamic> cInfo=_walletInfoLsit[rIndex].coinInfo?[CoinType.N.name];
      Map<String, dynamic> pathMap = cInfo['baseInfo']['path'];
      var rmAddress=await Trustdart().generateAddress(
          CoinType.N.name,
          getPathWithIndex(pathMap[cInfo['addrType']], cInfo['pathIndex']),
          cInfo['addrType'],
          mnemonic: _walletInfoLsit[rIndex].mnemonic??"",
          pk: _walletInfoLsit[rIndex].privateKey??""
      );
      if (!AppGlobals.appContext.mounted) return MessageModel.error();
      String miningAddress=rmAddress[cInfo['addrType']];
      var miningData=Provider.of<MiningV2Provider>(AppGlobals.appContext,listen: false).miningData?[miningAddress];
      if(miningData !=null){
        if(miningData['isMining']==true){
          MessageModel rmm=MessageModel.error();
          rmm.data="The validator's wallet cannot be deleted!";//"验证者钱包，无法删除！";
          return rmm;
        }
      }
      if(rIndex<walletIndex){
        walletIndex--;
        _walletInfoLsit.remove(info);
        //setWalletIndex(walletIndex);
      }else{
        _walletInfoLsit.remove(info);
      }
      saveWalletInfoAll();
      return null;
    }
  }
  //isFirst 用户第一次创建钱包 缓存中还未有数据
  Future<int> checkWalletMnemonic(WalletInfo info) async {
    try{
      bool rData=await Trustdart().checkMnemonic(info.mnemonic!);
      if(rData==true){
        return 0;
      }else{
        return -1;
      }
    }catch(e){
      return -1;
    }
  }
  WalletInfo? findWallet({String pk="",String mnemonic=""}){
    int index=walletInfoLsit.indexWhere((e){
      if(pk !=""){
        if(e.privateKey==pk){
          return true;
        }
      }else{
        if(e.mnemonic==mnemonic){
          return true;
        }
      }
      return false;
    });
    if(index == -1){
      return null;
    }else{
      return walletInfoLsit[index];
    }
  }
  //返回公钥、私钥对
  Future<void> getPublicKeyAndPrivateKeyPairN()async{
    _publicKeyAndPrivateKeyPair={};
    Trustdart trustdart=Trustdart();
    for(WalletInfo wInfo in walletInfoLsit){
      if(wInfo.mainWallet==false){
        continue;
      }
      // 检查 coinInfo 和 N 链配置是否存在
      if (wInfo.coinInfo == null || wInfo.coinInfo![CoinType.N.name] == null) {
        debugPrint('WalletActionProvider: Skipping wallet ${wInfo.walletName} - coinInfo or N chain config is null');
        continue;
      }
      final nChainConfig = wInfo.coinInfo![CoinType.N.name];
      if (nChainConfig['baseInfo'] == null || nChainConfig['baseInfo']['path'] == null) {
        debugPrint('WalletActionProvider: Skipping wallet ${wInfo.walletName} - N chain baseInfo or path is null');
        continue;
      }
      String path=getPathWithIndex(nChainConfig['baseInfo']['path'][nChainConfig['addrType']], nChainConfig['pathIndex']);
      String privateKeyStr=await trustdart.getPrivateKeyAndPublicKeyPair(
        CoinType.N.name,
        path,
        mnemonic: wInfo.mnemonic??"",
        pk: wInfo.privateKey??"",
      );
      Map<dynamic,dynamic> pkPair=json.decode(privateKeyStr);
      final pubKey = bytesToHex(base64Decode(pkPair['publicKey'].toString()));//hexUtils.uint8ToHex(base64Decode(pkPair['publicKey'].toString()));
      final privateKey = bytesToHex(base64Decode(pkPair['privateKey'].toString()));//hexUtils.uint8ToHex(base64Decode(pkPair['privateKey'].toString()));
      _publicKeyAndPrivateKeyPair![pubKey] = privateKey;
    }
  }
  String? getPrivateKeyWithPublicKey(String publicKey){
    return _publicKeyAndPrivateKeyPair?[publicKey];
  }
  /// 稳定币价格缓存（从 CoinGecko 获取）
  Map<String, Map<String, double>> _stablecoinPrices = {};

  /// 稳定币价格缓存时间戳
  DateTime? _stablecoinPricesFetchTime;

  /// 稳定币价格缓存有效期（5分钟）
  static const Duration _stablecoinCacheDuration = Duration(minutes: 5);

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

  /// 从 CoinGecko 获取稳定币价格
  Future<void> _fetchStablecoinPrices() async {
    // 检查缓存是否有效
    if (_stablecoinPricesFetchTime != null &&
        DateTime.now().difference(_stablecoinPricesFetchTime!) < _stablecoinCacheDuration &&
        _stablecoinPrices.isNotEmpty) {
      debugPrint('WalletActionProvider: Using cached stablecoin prices');
      return;
    }

    try {
      final geckoIds = _stablecoinGeckoIds.values.join(',');
      final baseUrl = AppConfig.apiUrl['coinGeckoApi'] ?? 'https://api.coingecko.com/api/v3';
      final url = '$baseUrl/simple/price?ids=$geckoIds&vs_currencies=usd&include_24hr_change=true';

      final response = await BaseApi.requestEmptyH.get(url, params: {}, header: {'content-type': 'application/json'});

      if (response != null && response is Map) {
        final newPrices = <String, Map<String, double>>{};
        // 将 CoinGecko ID 映射回 symbol
        for (final entry in _stablecoinGeckoIds.entries) {
          final symbol = entry.key;
          final geckoId = entry.value;
          final coinData = response[geckoId];
          if (coinData != null && coinData is Map) {
            // 安全的类型转换
            final rawPrice = coinData['usd'];
            final rawChange = coinData['usd_24h_change'];

            final price = _parseDouble(rawPrice, 1.0);
            final change = _parseDouble(rawChange, 0.0);

            // 验证价格在合理范围内
            if (price >= _stablecoinMinPrice && price <= _stablecoinMaxPrice) {
              newPrices[symbol] = {'price': price, 'change': change};
              debugPrint('WalletActionProvider: Stablecoin $symbol price: \$$price, change: $change%');
            } else {
              // 价格异常，使用默认值
              newPrices[symbol] = {'price': 1.0, 'change': 0.0};
              debugPrint('WalletActionProvider: Stablecoin $symbol price out of range ($price), using default 1.0');
            }
          }
        }

        if (newPrices.isNotEmpty) {
          _stablecoinPrices = newPrices;
          _stablecoinPricesFetchTime = DateTime.now();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('WalletActionProvider: Failed to fetch stablecoin prices: $e');
      debugPrint('WalletActionProvider: Stack trace: $stackTrace');
      // 失败时保留之前的缓存，如果没有缓存则使用默认值
    }
  }

  /// 安全的 double 解析
  double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  ///获取钱包 币的基本数据，成功后初始化主页币列表
  Future<void> getCoinInfo() async {
    //钱包币列表，默认查询币种的当前价格等基本信息
    String coinSelectPriceKeys="";
    for(CoinModel cm in coinList){
      coinSelectPriceKeys+="${cm.coin['miniName'].toString().toLowerCase()},";
    }
    debugPrint('WalletActionProvider: Getting coin info for: $coinSelectPriceKeys');

    // 先获取稳定币价格（从 CoinGecko）
    await _fetchStablecoinPrices();

    //查询coins中的币种信息
    var list = await MarketApi().getWalletCoinsInfo(coinSelectPriceKeys);
    //判断查询是否成功
    if (list['error'] == true) {
      //查询失败，设置当前操作状态为error，并设置错误信息
      debugPrint('WalletActionProvider: getCoinInfo failed: ${list['data']}');
      ToastUtils.show(S.current.g_key_5);
      notifyListeners();
    } else {
      //查询成功，将币的信息赋值到_coinslist
      final data = list['data'];
      if (data != null && data['data'] != null) {
        _coinMarketInfo = data['data'];
        debugPrint('WalletActionProvider: Loaded ${_coinMarketInfo.length} coins market info');
        // 遍历并设置每个币的价格
        for(CoinModel cm in coinList){
          getCoinPrice(cm);
        }
        // 价格更新后重新计算总余额并通知UI刷新
        calculateBalanceWidthCoinModel();
        notifyListeners();
      } else {
        debugPrint('WalletActionProvider: No market data in response');
      }
    }
    //getBalance_main();
    addCoinRefreshMap();
  }

  /// 稳定币列表
  static const Set<String> _stablecoins = {'usdt', 'usdc', 'dai', 'busd', 'tusd', 'usdp', 'gusd', 'frax'};

  //获取币的 美元价格
  void getCoinPrice(CoinModel cm) {
    // 使用 unit 作为主要匹配键（与原始实现保持一致）
    // miniName 用于请求，unit 用于匹配响应
    String unit = cm.coin['unit']?.toString().toLowerCase() ?? '';
    String miniName = cm.coin['miniName']?.toString().toLowerCase() ?? '';

    // 稳定币使用 CoinGecko 获取的价格
    final stablecoinKey = _stablecoins.contains(unit) ? unit : (_stablecoins.contains(miniName) ? miniName : null);
    if (stablecoinKey != null) {
      final priceData = _stablecoinPrices[stablecoinKey];
      if (priceData != null) {
        cm.coinPrice = priceData['price'] ?? 1.0;
        cm.percentage = priceData['change'] ?? 0.0;
      } else {
        // 如果 CoinGecko 没有返回数据，使用默认值 1.0
        cm.coinPrice = 1.0;
        cm.percentage = 0.0;
      }
      cm.coin['coinPrice'] = cm.coinPrice;
      cm.coin['percentage'] = cm.percentage;
      cm.value = cm.balanceDoubleAll() * cm.coinPrice;
      return;
    }

    for (var element in _coinMarketInfo) {
      String coinSymbol = element['coin']?.toString().toLowerCase() ?? '';

      // 优先使用 unit 匹配（与原始逻辑一致），然后使用 miniName
      if (coinSymbol == unit || coinSymbol == miniName) {
        // 更新图标
        if (element['image'] != null) {
          cm.coin["icon"] = element['image'];
        }

        // 设置币价
        cm.coinPrice = element['price'] * 1.0;
        // 设置涨跌幅
        cm.percentage = element['price_change_per_24h'] * 1.0;

        // 更新 coin 对象中的价格信息（供其他地方使用）
        cm.coin['coinPrice'] = cm.coinPrice;
        cm.coin['percentage'] = cm.percentage;

        // 重新计算价值 (余额 * 币价)
        cm.value = cm.balanceDoubleAll() * cm.coinPrice;
        break;
      }
    }
  }
  //获取币的 美元价格
  Map<String,dynamic>? getCoinPriceWithUnit(String unit) {
    String keyStr = unit.toLowerCase();

    // 稳定币使用 CoinGecko 获取的价格
    if (_stablecoins.contains(keyStr)) {
      final priceData = _stablecoinPrices[keyStr];
      return {
        'icon': null,
        'coinPrice': priceData?['price'] ?? 1.0,
        'percentage': priceData?['change'] ?? 0.0,
      };
    }

    for (var element in _coinMarketInfo) {
      if (element['coin'].toString().toLowerCase() == keyStr) {
        Map<String,dynamic> rMap={};
        rMap["icon"] = element['image'];
        //设置币价
        final price = Decimal.parse(element['price'].toString()).toDouble();
        final percentage = Decimal.parse(element['price_change_per_24h'].toString()).toDouble();
        rMap['coinPrice'] = price;
        rMap['percentage'] = percentage;
        debugPrint('WalletActionProvider: getCoinPriceWithUnit($unit) -> price=\$$price, change=$percentage%');
        return rMap;
      }
    }
    debugPrint('WalletActionProvider: getCoinPriceWithUnit($unit) -> NOT FOUND in ${_coinMarketInfo.length} items');
    return null;
  }
  //获取币的 全部信息
  Map<String,dynamic>? getCoinPriceWithUnitAll(String unit) {
    String keyStr = unit.toLowerCase();
    for (var element in _coinMarketInfo) {
      if (element['coin'].toString().toLowerCase() == keyStr) {
        return element;
      }
    }
    return null;
  }
  //获取币的基本信息
  Future<dynamic> getCoinsBaseInfo(String coinName)async{
    Map<String,dynamic> m=await MarketApi().getWalletCoinsBaseInfo(coinName);
    if(m['error']){
      return null;
    }else{
      return m['data'];
    }
  }

  void setNetworkIndex(int value){
    if(walletInfo.networkIndex==value)return;
    walletInfo.networkIndex=value;
    if(walletInfo.networkIndex==-1){
      buildCoinModelInfo();
    }else{
      buildCoinModelInfoWithCoin();
    }
    saveWalletInfo(walletInfo, walletIndex);
  }
  //修改面部数据绑定钱包
  void setWalletFaceBinding(int? setIndex,{bool faceBinding=true}){
    if(faceBinding){
      int cancelIndex=walletInfoLsit.indexWhere((e)=>e.faceBinding==true);
      if(cancelIndex !=-1){
        WalletInfo wi=walletInfoLsit[cancelIndex];
        wi.faceBinding=false;
      }
    }
    setIndex ??= walletIndex;
    WalletInfo wiSet=walletInfoLsit[setIndex];
    wiSet.faceBinding=faceBinding;
    saveWalletInfoAll();
  }

  //refresh 是否刷新
  Future<void> initCoinInfo({bool refresh=true})async{
    if(refresh){
      setBalanceTotal(0);
    }
    refreshWalletCoinInfo(refresh:refresh);
  }
  //刷新钱包中币的余额与当前价格
  Future<void> refreshWalletCoinInfo({bool refresh=true}) async {
    if(refresh){
      _load = Load.refresh;
      notifyListeners();
    }
    await getCoinInfo();
    if(refresh){
      _load = Load.finish;
      notifyListeners();
    }
  }
//重新加载当前钱包的 某个 coin
  Future<void> reBuildCoin(WalletInfo wInfo,String coinType)async{
    _walletInfoLsit[walletIndex]=wInfo;
    saveWalletInfo(walletInfo, walletIndex);
    int cIndex = _coinModels.indexWhere((element){
      if(element.coin['coinType']==coinType){
        return true;
      }
      return false;
    });
    _coinModels[cIndex].coin=walletMap[coinType]['baseInfo'];
    _coinModels[cIndex].pathIndex=walletMap[coinType]['pathIndex'];
    _coinModels[cIndex].addrType=walletMap[coinType]['addrType'];
    _coinModels[cIndex].address=null;

    int clIndex= coinList.indexWhere((element){
      if(element.coin['coinType']==coinType && element.coin['isContract']==false){
        return true;
      }
      return false;
    });
    if(clIndex !=-1){
      coinList[clIndex]=_coinModels[cIndex];
      coinList[clIndex].buildWallet();
      coinList[clIndex].getBalanceDefault();
      if(coinList[clIndex].tokens.isNotEmpty){
        List<String> tKeys=coinList[clIndex].tokens.keys.toList();
        for(int i=0;i<coinList[clIndex].tokens.length;i++){}
        for(String tkey in tKeys){
          Map<String,dynamic> token=coinList[clIndex].tokens[tkey];
          int tIndex=coinList.indexWhere((element){
            if(element.coin['coinType']==coinType && element.coin['contract']==token['contract']){
              return true;
            }
            return false;
          });
          if(tIndex != -1){
            coinList[tIndex]=buildTokenCoinModel(coinList[clIndex], token);
          }

        }
      }
    }
    //getBalance_main();
    addCoinRefreshMap();
    notifyListeners();
  }
  //添加主链币
  Future<void> addWalletChain(Map<String,dynamic> chainMap)async{
    Map<String,dynamic>? cMap=walletMap[chainMap['baseInfo']['mKey']];
    if(cMap != null){
      int index=_coinModels.indexWhere((element) {
        if(element.coin['coinType']==chainMap['baseInfo']['coinType']){
          return true;
        }
        return false;
      });
      _coinModels[index].showList=true;
      coinList.add(_coinModels[index]);
      getCoinPrice(coinList.last);
      coinList.last.getBalanceDefault();
      cMap['showList']=chainMap['showList'];
      walletMap[chainMap['baseInfo']['mKey']]=cMap;
    }
    else{
      CoinModel cm = CoinModel.fromMap(chainMap['baseInfo']);
      cm.showList=chainMap['showList'];
      cm.isTest=chainMap['isTest'];
      cm.custom=chainMap['baseInfo']['custom']??false;
      cm.addrType=chainMap['addrType'];
      cm.pathIndex=chainMap['pathIndex'] ?? 0;
      if(cm.isTest){
        Map<dynamic,dynamic> tokens=chainMap['testnets'][0]['testnetContract'];
        if(tokens.isNotEmpty){
          cm.tokens=walletMap[chainMap['testnets']['testnetContract']];
        }
      }else{
        Map<dynamic,dynamic> tokens=chainMap['mainnets'];
        if(tokens.isNotEmpty){
          cm.tokens=chainMap['mainnets'];
        }
      }
      _coinModels.add(cm);
      coinList.add(cm);
      getCoinPrice(cm);
      cm.getBalanceDefault();
      walletMap[chainMap['baseInfo']['mKey']]=chainMap;
    }
    notifyListeners();
    await saveWalletInfo(walletInfo, walletIndex);
  }
  //将币从当前钱包中移除
  //mKey 币的 map key值
  void removeWalletChain(String mKey,String unit){
    int tokenCount=walletMap[mKey]['mainnets'].length;
    if(tokenCount==0){
      walletMap.remove(mKey);
      for(int i=0;i<_coinModels.length;i++){
        CoinModel cm=_coinModels[i];
        if(cm.coin['mKey']==mKey){
          _coinModels.removeAt(i);
          break;
        }
      }
    }else{
      walletMap[mKey]['showList']=false;
    }
    for(int i=0;i<coinList.length;i++){
      CoinModel cm=coinList[i];
      if(cm.coin['mKey']==mKey){
        coinList.removeAt(i);
        break;
      }
    }

    saveWalletInfo(walletInfo, walletIndex);
    notifyListeners();
  }
  //添加代币
  void addWalletChainToken(Map<String,dynamic> token){
    String symbolStr=token['coinType'].toString().toUpperCase();
    Map<dynamic,dynamic>t;
    if(walletMap[symbolStr]['isTest']){
      t= walletMap[symbolStr]['testnets'][0]['testnetContract'];
      if(t.isEmpty){
        walletMap[symbolStr]['testnets'][0]['testnetContract']={
          '${token['mKey']}':token,
        };
      }else{
        Map<String,dynamic>tokens= walletMap[symbolStr]['testnets'][0]['testnetContract'];
        final t=tokens[token['mKey']];
        if(t == null){
          tokens[token['mKey']]=token;
        }else{
          return;
        }
      }
    }
    else{
      t= walletMap[symbolStr]['mainnets'];
      if(t.isEmpty){
        walletMap[symbolStr]['mainnets']={
          '${token['mKey']}':token,
        };
      }else{
        Map<String,dynamic> tokens= walletMap[symbolStr]['mainnets'];
        final t=tokens[token['mKey']];
        if(t == null){
          tokens[token['mKey']]=token;
        }else{
          return;
        }
      }
    }
    saveWalletInfo(walletInfo, walletIndex);

    int coinIndex =_coinModels.indexWhere((element){
      if(element.coin['coinType']==token['coinType']){
        return true;
      }
      return false;
    });
    CoinModel mm=_coinModels[coinIndex];
    CoinModel cm=CoinModel.fromMap(token);
    cm.pathIndex=mm.pathIndex;
    cm.isTest=mm.isTest;
    cm.addrType=mm.addrType;
    cm.address=mm.address;
    cm.addressType=mm.addressType;
    cm.mainCoinIcon=mm.coin['icon'];
    coinList.add(cm);
    notifyListeners();
  }
  //将代币从当前钱包中移除
  void removeWalletChainToken(Map<String,dynamic> token,{String? symbol,String? miniName}){
    String symbolStr;
    if(symbol==null){
      symbolStr=token['symbol'].toUpperCase();
    }else{
      symbolStr=symbol.toUpperCase();
    }
    Map<String,dynamic>tokens;
    if(walletMap[symbolStr]['isTest']){
      tokens= walletMap[symbolStr]['testnets'][0]['testnetContract'];
    }else{
      tokens= walletMap[symbolStr]['mainnets'];
    }
    tokens.remove(token['contract'].toString().toUpperCase());
    saveWalletInfo(walletInfo, walletIndex);
    for(CoinModel cm in coinList){
      if(cm.coin['coinType']==symbolStr){
        if(cm.coin['mKey']==token['contract'].toString().toUpperCase()){
          coinList.remove(cm);
          //removeAt(i);
          break;
        }
      }
    }
    notifyListeners();
  }

  //添加一个导入钱包
  Future<bool> addImportWalletInfo(WalletInfo info) async {
    //if( haveOne(info))return false;
    try{
      // 检查 walletName 是否为 null
      if (info.walletName == null || info.walletName!.isEmpty) {
        debugPrint('WalletActionProvider: Cannot add import wallet - walletName is null or empty');
        return false;
      }
      final walletNameUpper = info.walletName!.toUpperCase();
      final chainMapWallet = walletMap[walletNameUpper];
      if (chainMapWallet == null) {
        debugPrint('WalletActionProvider: Cannot add import wallet - chain config not found for $walletNameUpper');
        return false;
      }
      List<String> chainMapWalletKeys=chainMapWallet.keys.toList();
      Map<String,dynamic> chainMap={};
      for(String key in chainMapWalletKeys){
        chainMap[key]=chainMapWallet[key];
      }
      chainMap['baseInfo']['isTest']=false;
      chainMap['baseInfo']['mainnets']={};
      chainMap['baseInfo']['balance']="0";
      chainMap['baseInfo']['balance_test']="0";
      chainMap['baseInfo']['canEdit']=false;
      info.coinInfo= {
        walletNameUpper:chainMap,
      };
      //walletInfo.importWallets.add(info);
      await saveWalletInfo(info, walletInfoLsit.length,isNewWallet: true);
      initWallet();
      return true;
    }catch(e){
      return false;
    }

  }

  //计算余额
  void calculateBalanceWidthCoinModel(){
    double tBalance=0.0;
    for(int i=0;i<coinList.length;i++){
      tBalance +=coinList[i].value;
    }
    setBalanceTotal(tBalance);
    //getTokens_top();
  }
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel)async{
    //获取coin 的地址
    // 如果地址为 null，说明该链的地址生成失败，跳过余额获取
    if (coinModel.address == null) {
      debugPrint('WalletActionProvider: Skipping balance fetch for ${coinModel.coin['miniName']} - address is null');
      coinModel.loadError = true;
      return true; // 返回 true 表示有错误
    }
    String address = coinModel.address.toString();
    if(coinModel.coin['coinType']==CoinType.BCH.name){
      address=getAddress(coinModel.coin['coinType'],addrType: 'legacy');
    }
    //合约地址
    String contract= "";
    if(coinModel.coin['isContract']==false){
    }else{
      //获取 合约地址
      if(coinModel.isTest){
        contract=coinModel.coin['contract_test'];
      }else{
        contract=coinModel.coin['contract'];
      }
    }
    if(coinModel.coin['isContract'] && coinModel.coin['coinType']==CoinType.ALGO.name){
      return await getBalanceTokenAlgoWithCoinModel(coinModel);
    }
    /*String rpc;
    if(coinModel.isTest){
      rpc=coinModel.coin['service_test'];
    }else{
      rpc=coinModel.coin['service'];
    }*/

    //获取 coin 的余额
    MessageModel mm=await tokenViewApi.getBalance(
        coinModel.coin['blockchainType'],
        coinModel.coin['coinType'],
        address,
        contract: contract,
        isTest: coinModel.isTest ,
      rpc: coinModel.coin['coinType']==CoinType.N.name?coinModel.coin['service_test']:null,
      //coinModel.custom?coinModel.isTest?coinModel.coin['service_test']:coinModel.coin['service']:null
      //"http://5.161.252.59:8545"
      //coinModel.custom?coinModel.isTest?coinModel.coin['service_test']:coinModel.coin['service']:null
    ) ?? MessageModel.error();
    if(mm.error){
      // 网络请求失败，使用缓存的余额数据
      debugPrint('WalletActionProvider: Balance fetch failed for ${coinModel.coin['miniName']}, using cached balance');
      
      // 尝试从市场数据更新价格信息
      Map<String,dynamic>? coinInfo=getCoinPriceWithUnit(coinModel.coin['unit'].toString());
      if(coinInfo != null){
        coinModel.coin['percentage']=coinInfo['percentage'];
        coinModel.coin['coinPrice']=coinModel.isTest?0.0:coinInfo['coinPrice'];
        coinModel.coin['icon']=coinInfo['icon'];
      }
      
      _safeUpdateWalletMap(coinModel);
      coinModel.getBalanceDefault();
      // 不设置 loadError，因为我们已经使用了缓存数据
      coinModel.loadError = false;
      return true;
    }
    else{
      BigInt balance=BigInt.zero;
      if(coinModel.coin['coinType']==CoinType.ALGO.name){
        balance=mm.data['balance'];
        coinModel.other=AlgoModel.fromMinBalance(mm.data['minBalance']);
      }else if(coinModel.coin['coinType']==CoinType.XRP.name){
        balance=mm.data['balance'];
        coinModel.other=XrpModel(mm.data['sequence'],mm.data['account'],mm.data['ownerCount']);
      }else{
        balance=mm.data;
      }
      Map<String,dynamic>? coinInfo=getCoinPriceWithUnit(coinModel.coin['unit'].toString());
      if(coinInfo != null){
        coinModel.coin['percentage']=coinInfo['percentage'];
        coinModel.coin['coinPrice']=coinModel.isTest?0.0:coinInfo['coinPrice'];
        coinModel.coin['icon']=coinInfo['icon'];
        //baseInfo['name']=coinInfo['name'];
      }
      if(coinModel.isTest){
        coinModel.coin['balance_test']=balance.toString();
      }else{
        coinModel.coin['balance']=balance.toString();
      }
      _safeUpdateWalletMap(coinModel);
      coinModel.getBalanceDefault();
      return false;
    }
  }
  //获取algo 链 代币
  Future<bool> getBalanceTokenAlgoWithCoinModel(CoinModel coinModel)async{
    // 检查 address 是否为 null
    if (coinModel.address == null) {
      debugPrint('WalletActionProvider: Skipping ALGO token balance fetch for ${coinModel.coin['miniName']} - address is null');
      coinModel.loadError = true;
      return true;
    }

    //获取 合约地址
    String contract="";
    if(coinModel.isTest){
      contract=coinModel.coin['contract_test'];
    }else{
      contract=coinModel.coin['contract'];
    }
    CoinModel? chainCoinModel=getCoinModelWithCoinType(coinModel.coin['coinType']);
    if(chainCoinModel==null){
      coinModel.isRefresh=false;
      coinModel.loadError=true;
      notifyListeners();
      return true;
    }
    BigInt balance=BigInt.zero;
    MessageModel rBalance=await tokenViewApi.getBalance(BlockchainType.Algorand.name, coinModel.coin['coinType'], coinModel.address.toString(),contract: contract,isTest: coinModel.isTest) ?? MessageModel.error();
    if(rBalance.error){
      coinModel.isRefresh=false;
      coinModel.loadError=true;
      notifyListeners();
      return true;
    }else{
      balance=rBalance.data['balance'];
      coinModel.other=AlgoModel.fromCode(rBalance.data['code']);
    }
    Map<String,dynamic>? coinInfo=getCoinPriceWithUnit(coinModel.coin['unit'].toString());
    if(coinInfo != null){
      coinModel.coin['percentage']=coinInfo['percentage'];
      coinModel.coin['coinPrice']=coinModel.isTest?0.0:coinInfo['coinPrice'];
      coinModel.coin['icon']=coinInfo['icon'];
    }
    if(coinModel.isTest){
      coinModel.coin['balance_test']=balance.toString();
    }else{
      coinModel.coin['balance']=balance.toString();
    }

    _safeUpdateWalletMap(coinModel);
    coinModel.getBalanceDefault();
    return false;
  }


  void addCoinRefreshMap(){
    if(coinRefreshMap[walletIndex] !=null)return;
    List<CoinModel> rList=[];
    for(int i=0;i<coinList.length;i++){
      // 跳过聚合代币（AggregatedCoinModel），它们有自己的余额获取逻辑
      if (coinList[i] is AggregatedCoinModel) {
        continue;
      }
      // 跳过 address 为 null 的代币（不支持的链）
      if (coinList[i].address == null) {
        debugPrint('WalletActionProvider: Skipping ${coinList[i].coin['miniName']} in refresh - address is null');
        coinList[i].loadError = true; // 标记为加载错误
        continue;
      }
      rList.add(coinList[i]);
    }
    coinRefreshMap[walletIndex]={
      "coinList":rList,
    };
    loadBalance=Load.loading;
    notifyListeners();
    coinRefresh(walletIndex);
  }
  /// coinType:币类型，contract:合约地址，isTest:是否时测试
  Future<void> refreshCoinBalance(String coinType,{String contract=""})async{
    int cmIndex=coinList.indexWhere((element) {
      if(element.coin['coinType']==coinType ){
        if(contract==""){
          return true;
        }else{
          String eContract=element.isTest?element.coin['contract_test']:element.coin['contract'];
          if(eContract==contract){
            return true;
          }
          return false;
        }
      }
      return false;
    });
    if(cmIndex != -1){
      await coinList[cmIndex].getBalance();
      notifyListeners();
    }
  }

  void removeConRefreshMap(int index){
    loadBalance=Load.finish;
    notifyListeners();
    coinRefreshMap.remove(index);
  }
  Future<void> coinRefresh(int index)async{
    try{
      if(coinRefreshMap[index]!=null){
        if(coinRefreshMap[index]["coinList"] !=null && coinRefreshMap[index]["coinList"].length !=0){
          final currentCoin = coinRefreshMap[index]["coinList"].first;
          currentCoin.isRefresh=true;
          notifyListeners();

          try {
            await getBalanceWithCoinModel(currentCoin);
          } catch (e) {
            debugPrint('WalletActionProvider: Error refreshing ${currentCoin.coin['miniName']}: $e');
          }

          // 网络临时失败时不显示错误图标，因为已经使用了缓存数据
          // 只有在完全无法获取数据时才显示错误
          currentCoin.loadError = false;
          currentCoin.isRefresh=false;
          notifyListeners();
          coinRefreshMap[index]["coinList"].removeAt(0);
          coinRefresh(index);
        }
        else{
          saveWalletInfo(walletInfo, walletIndex);
          calculateBalanceWidthCoinModel();
          removeConRefreshMap(index);
        }
      }
    } catch (e) {
      debugPrint('WalletActionProvider: Critical error in coinRefresh: $e');
      // 继续处理下一个代币，避免整个刷新流程中断
      if(coinRefreshMap[index] != null &&
         coinRefreshMap[index]["coinList"] != null &&
         coinRefreshMap[index]["coinList"].length > 0) {
        coinRefreshMap[index]["coinList"].removeAt(0);
        coinRefresh(index);
      } else {
        removeConRefreshMap(index);
      }
    }
  }
}
