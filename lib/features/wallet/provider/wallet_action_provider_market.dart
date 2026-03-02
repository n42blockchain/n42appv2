part of 'wallet_action_provider.dart';

/// Market prices, balance fetching, coin refresh, and stablecoin pricing.
extension WalletActionProviderMarket on WalletActionProvider {

  /// 从 CoinGecko 获取稳定币价格
  Future<void> _fetchStablecoinPrices() async {
    // 检查缓存是否有效
    if (_stablecoinPricesFetchTime != null &&
        DateTime.now().difference(_stablecoinPricesFetchTime!) < WalletActionProvider._stablecoinCacheDuration &&
        _stablecoinPrices.isNotEmpty) {
      if (kDebugMode) debugPrint('WalletActionProvider: Using cached stablecoin prices');
      return;
    }

    try {
      final geckoIds = WalletActionProvider._stablecoinGeckoIds.values.join(',');
      final baseUrl = AppConfig.apiUrl['coinGeckoApi'] ?? 'https://api.coingecko.com/api/v3';
      // 同时请求 cny 报价，用于推导 USD→CNY 汇率
      final url = '$baseUrl/simple/price?ids=$geckoIds&vs_currencies=usd,cny&include_24hr_change=true';

      final response = await ExternalHttp.get(url)
          .timeout(const Duration(seconds: 8), onTimeout: () => null);

      if (response != null && response is Map) {
        final newPrices = <String, Map<String, double>>{};
        // 将 CoinGecko ID 映射回 symbol
        for (final entry in WalletActionProvider._stablecoinGeckoIds.entries) {
          final symbol = entry.key;
          final geckoId = entry.value;
          final coinData = response[geckoId];
          if (coinData != null && coinData is Map) {
            final rawPrice = coinData['usd'];
            final rawChange = coinData['usd_24h_change'];

            final price = _parseDouble(rawPrice, 1.0);
            final change = _parseDouble(rawChange, 0.0);

            // 验证价格在合理范围内
            if (price >= WalletActionProvider._stablecoinMinPrice && price <= WalletActionProvider._stablecoinMaxPrice) {
              newPrices[symbol] = {'price': price, 'change': change};
            } else {
              newPrices[symbol] = {'price': 1.0, 'change': 0.0};
              if (kDebugMode) debugPrint('WalletActionProvider: Stablecoin $symbol price out of range ($price), using default 1.0');
            }

            // 利用 USDT 的 CNY 报价推导 USD→CNY 汇率
            // USDT_cny / USDT_usd ≈ 汇率（USDT 近似锚定 $1）
            if (symbol == 'usdt') {
              final cnyPrice = _parseDouble(coinData['cny'], 0.0);
              if (cnyPrice > 5.0 && cnyPrice < 12.0 && price > 0) {
                _usdToCnyRate = cnyPrice / price;
                if (kDebugMode) debugPrint('WalletActionProvider: USD→CNY rate updated: $_usdToCnyRate');
              }
            }
          }
        }

        if (newPrices.isNotEmpty) {
          _stablecoinPrices = newPrices;
          _stablecoinPricesFetchTime = DateTime.now();
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('WalletActionProvider: Failed to fetch stablecoin prices: $e');
        debugPrint('WalletActionProvider: Stack trace: $stackTrace');
      }
      // 失败时保留之前的缓存和汇率，不重置
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
    final coinSelectPriceKeys = coinList
        .map((cm) => cm.coin['miniName'].toString().toLowerCase())
        .join(',');

    // 先获取稳定币价格（从 CoinGecko，含 CNY 汇率推导，有 5 分钟缓存）
    await _fetchStablecoinPrices();

    // 市场数据防重复请求：30s 内已有新鲜数据则跳过网络请求，直接用缓存重算总余额
    final now = DateTime.now();
    final marketDataFresh = _coinMarketInfoFetchTime != null &&
        now.difference(_coinMarketInfoFetchTime!) < WalletActionProvider._marketInfoMinInterval &&
        _coinMarketInfo.isNotEmpty;

    if (!marketDataFresh) {
      //查询coins中的币种信息
      var list = await MarketApi().getWalletCoinsInfo(coinSelectPriceKeys);
      if (list['error'] == true) {
        if (kDebugMode) debugPrint('WalletActionProvider: getCoinInfo failed: ${list['data']}');
        // 静默失败：保留旧缓存价格，不打扰用户（仅首次无数据时才 Toast）
        if (_coinMarketInfo.isEmpty) {
          ToastUtils.show(S.current.g_key_5);
        }
      } else {
        final data = list['data'];
        if (data != null && data['data'] != null) {
          _coinMarketInfo = data['data'];
          _coinMarketInfoFetchTime = now;
          if (kDebugMode) debugPrint('WalletActionProvider: Loaded ${_coinMarketInfo.length} coins market info');
        }
      }
    } else {
      if (kDebugMode) debugPrint('WalletActionProvider: Market data fresh (${now.difference(_coinMarketInfoFetchTime!).inSeconds}s old), skip fetch');
    }

    // 无论是否重新拉取，都用最新缓存重算价格和总余额
    for(CoinModel cm in coinList){
      getCoinPrice(cm);
    }
    calculateBalanceWidthCoinModel();
    // 记录本次成功更新时间（用于 UI 展示"更新于 X 分钟前"）
    _priceLastUpdated = now;
    refresh();

    addCoinRefreshMap();
  }

  //获取币的 美元价格
  void getCoinPrice(CoinModel cm) {
    // 使用 unit 作为主要匹配键（与原始实现保持一致）
    // miniName 用于请求，unit 用于匹配响应
    final unit = cm.coin['unit']?.toString().toLowerCase() ?? '';
    final miniName = cm.coin['miniName']?.toString().toLowerCase() ?? '';

    // 稳定币使用 CoinGecko 获取的价格
    final stablecoinKey = WalletActionProvider._stablecoins.contains(unit)
        ? unit
        : WalletActionProvider._stablecoins.contains(miniName)
            ? miniName
            : null;
    if (stablecoinKey != null) {
      final priceData = _stablecoinPrices[stablecoinKey];
      cm.coinPrice = priceData?['price'] ?? 1.0;
      cm.percentage = priceData?['change'] ?? 0.0;
      _syncCoinPriceFields(cm);
      return;
    }

    for (final element in _coinMarketInfo) {
      final coinSymbol = element['coin']?.toString().toLowerCase() ?? '';

      // 优先使用 unit 匹配（与原始逻辑一致），然后使用 miniName
      if (coinSymbol == unit || coinSymbol == miniName) {
        if (element['image'] != null) {
          cm.coin["icon"] = element['image'];
        }
        cm.coinPrice = element['price'] * 1.0;
        cm.percentage = element['price_change_per_24h'] * 1.0;
        _syncCoinPriceFields(cm);
        break;
      }
    }
  }

  /// 将 coinPrice/percentage 同步到 coin Map 并重算 value
  void _syncCoinPriceFields(CoinModel cm) {
    cm.coin['coinPrice'] = cm.coinPrice;
    cm.coin['percentage'] = cm.percentage;
    cm.value = cm.balanceDoubleAll() * cm.coinPrice;
  }

  //获取币的 美元价格
  Map<String,dynamic>? getCoinPriceWithUnit(String unit) {
    final keyStr = unit.toLowerCase();

    // 稳定币使用 CoinGecko 获取的价格
    if (WalletActionProvider._stablecoins.contains(keyStr)) {
      final priceData = _stablecoinPrices[keyStr];
      return {
        'icon': null,
        'coinPrice': priceData?['price'] ?? 1.0,
        'percentage': priceData?['change'] ?? 0.0,
      };
    }

    for (final element in _coinMarketInfo) {
      if (element['coin'].toString().toLowerCase() != keyStr) continue;
      final price = Decimal.parse(element['price'].toString()).toDouble();
      final percentage = Decimal.parse(element['price_change_per_24h'].toString()).toDouble();
      if (kDebugMode) debugPrint('WalletActionProvider: getCoinPriceWithUnit($unit) -> price=\$$price, change=$percentage%');
      return {
        'icon': element['image'],
        'coinPrice': price,
        'percentage': percentage,
      };
    }
    if (kDebugMode) debugPrint('WalletActionProvider: getCoinPriceWithUnit($unit) -> NOT FOUND in ${_coinMarketInfo.length} items');
    return null;
  }

  //获取币的 全部信息
  Map<String,dynamic>? getCoinPriceWithUnitAll(String unit) {
    final keyStr = unit.toLowerCase();
    for (final element in _coinMarketInfo) {
      if (element['coin'].toString().toLowerCase() == keyStr) {
        return element;
      }
    }
    return null;
  }

  //获取币的基本信息
  Future<dynamic> getCoinsBaseInfo(String coinName)async{
    final m = await MarketApi().getWalletCoinsBaseInfo(coinName);
    if(m['error']) return null;
    return m['data'];
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
      this.refresh();
    }
    await getCoinInfo();
    if(refresh){
      _load = Load.finish;
      this.refresh();
    }
  }

  //获取algo 链 代币
  Future<bool> getBalanceTokenAlgoWithCoinModel(CoinModel coinModel)async{
    // 检查 address 是否为 null
    if (coinModel.address == null) {
      if (kDebugMode) debugPrint('WalletActionProvider: Skipping ALGO token balance fetch for ${coinModel.coin['miniName']} - address is null');
      coinModel.loadError = true;
      return true;
    }

    //获取 合约地址
    final contract = coinModel.isTest ? coinModel.coin['contract_test'] : coinModel.coin['contract'];
    final chainCoinModel = getCoinModelWithCoinType(coinModel.coin['coinType']);
    if(chainCoinModel==null){
      coinModel.isRefresh=false;
      coinModel.loadError=true;
      refresh();
      return true;
    }

    final rBalance = await tokenViewApi.getBalance(BlockchainType.Algorand.name, coinModel.coin['coinType'], coinModel.address.toString(),contract: contract,isTest: coinModel.isTest) ?? MessageModel.error();
    if(rBalance.error){
      coinModel.isRefresh=false;
      coinModel.loadError=true;
      refresh();
      return true;
    }

    final balance = rBalance.data['balance'] as BigInt;
    coinModel.other=AlgoModel.fromCode(rBalance.data['code']);

    final coinInfo = getCoinPriceWithUnit(coinModel.coin['unit'].toString());
    if(coinInfo != null){
      coinModel.coin['percentage']=coinInfo['percentage'];
      coinModel.coin['coinPrice']=coinModel.isTest?0.0:coinInfo['coinPrice'];
      coinModel.coin['icon']=coinInfo['icon'];
    }

    final balanceKey = coinModel.isTest ? 'balance_test' : 'balance';
    coinModel.coin[balanceKey] = balance.toString();

    _safeUpdateWalletMap(coinModel);
    coinModel.getBalanceDefault();
    return false;
  }

  void addCoinRefreshMap(){
    if(coinRefreshMap[walletIndex] !=null)return;

    // 标记不支持的代币为加载错误
    for (final cm in coinList) {
      if (cm is! AggregatedCoinModel && cm.address == null) {
        if (kDebugMode) debugPrint('WalletActionProvider: Skipping ${cm.coin['miniName']} in refresh - address is null');
        cm.loadError = true;
      }
    }

    final rList = coinList
        .where((cm) => cm is! AggregatedCoinModel && cm.address != null)
        .toList();

    coinRefreshMap[walletIndex]={
      "coinList":rList,
    };
    loadBalance=Load.loading;
    refresh();
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
      await coinList[cmIndex].getBalance(walletAccess: this);
      refresh();
    }
  }

  void removeConRefreshMap(int index){
    loadBalance=Load.finish;
    refresh();
    coinRefreshMap.remove(index);
  }

  Future<void> coinRefresh(int index)async{
    try{
      if(coinRefreshMap[index]!=null){
        if(coinRefreshMap[index]["coinList"] !=null && coinRefreshMap[index]["coinList"].length !=0){
          final currentCoin = coinRefreshMap[index]["coinList"].first;
          currentCoin.isRefresh=true;
          refresh();

          try {
            await getBalanceWithCoinModel(currentCoin);
          } catch (e) {
            if (kDebugMode) debugPrint('WalletActionProvider: Error refreshing ${currentCoin.coin['miniName']}: $e');
          }

          // 网络临时失败时不显示错误图标，因为已经使用了缓存数据
          // 只有在完全无法获取数据时才显示错误
          currentCoin.loadError = false;
          currentCoin.isRefresh=false;
          refresh();
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
      if (kDebugMode) debugPrint('WalletActionProvider: Critical error in coinRefresh: $e');
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
