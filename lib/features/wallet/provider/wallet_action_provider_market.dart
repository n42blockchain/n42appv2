part of 'wallet_action_provider.dart';

/// Market prices, balance fetching, coin refresh, and stablecoin pricing.
extension WalletActionProviderMarket on WalletActionProvider {
  /// 从 CoinGecko 获取稳定币价格
  Future<void> _fetchStablecoinPrices() async {
    // 检查缓存是否有效
    if (_stablecoinPricesFetchTime != null &&
        DateTime.now().difference(_stablecoinPricesFetchTime!) <
            WalletActionProvider._stablecoinCacheDuration &&
        _stablecoinPrices.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('WalletActionProvider: Using cached stablecoin prices');
      }
      return;
    }

    try {
      final geckoIds = WalletActionProvider._stablecoinGeckoIds.values.join(
        ',',
      );
      final baseUrl =
          AppConfig.apiUrl['coinGeckoApi'] ??
          'https://api.coingecko.com/api/v3';
      // 同时请求 cny 报价，用于推导 USD→CNY 汇率
      final url =
          '$baseUrl/simple/price?ids=$geckoIds&vs_currencies=usd,cny&include_24hr_change=true';

      final response = await ExternalHttp.get(
        url,
      ).timeout(const Duration(seconds: 8), onTimeout: () => null);

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

            final price = parseMarketDouble(rawPrice, 1.0);
            final change = parseMarketDouble(rawChange, 0.0);

            // 验证价格在合理范围内
            if (price >= WalletActionProvider._stablecoinMinPrice &&
                price <= WalletActionProvider._stablecoinMaxPrice) {
              newPrices[symbol] = {'price': price, 'change': change};
            } else {
              newPrices[symbol] = {'price': 1.0, 'change': 0.0};
              if (kDebugMode) {
                debugPrint(
                  'WalletActionProvider: Stablecoin $symbol price out of range ($price), using default 1.0',
                );
              }
            }

            // 利用 USDT 的 CNY 报价推导 USD→CNY 汇率
            // USDT_cny / USDT_usd ≈ 汇率（USDT 近似锚定 $1）
            if (symbol == 'usdt') {
              final cnyPrice = parseMarketDouble(coinData['cny'], 0.0);
              if (cnyPrice > 5.0 && cnyPrice < 12.0 && price > 0) {
                _usdToCnyRate = cnyPrice / price;
                if (kDebugMode) {
                  debugPrint(
                    'WalletActionProvider: USD→CNY rate updated: $_usdToCnyRate',
                  );
                }
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
        debugPrint(
          'WalletActionProvider: Failed to fetch stablecoin prices: $e',
        );
        debugPrint('WalletActionProvider: Stack trace: $stackTrace');
      }
      // 失败时保留之前的缓存和汇率，不重置
    }
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
    final marketDataFresh =
        _coinMarketInfoFetchTime != null &&
        now.difference(_coinMarketInfoFetchTime!) <
            WalletActionProvider._marketInfoMinInterval &&
        _coinMarketInfo.isNotEmpty;

    if (!marketDataFresh) {
      //查询coins中的币种信息
      var list = await MarketApi().getWalletCoinsInfo(coinSelectPriceKeys);
      if (list['error'] == true) {
        if (kDebugMode) {
          debugPrint(
            'WalletActionProvider: getCoinInfo failed: ${list['data']}',
          );
        }
        // 静默失败：保留旧缓存价格，不打扰用户（仅首次无数据时才 Toast）
        if (_coinMarketInfo.isEmpty) {
          ToastUtils.show(S.current.g_key_5);
        }
      } else {
        final data = list['data'];
        final marketItems = extractMarketCoinItems(data);
        if (marketItems.isNotEmpty) {
          _coinMarketInfo = marketItems;
          _coinMarketInfoFetchTime = now;
          if (kDebugMode) {
            debugPrint(
              'WalletActionProvider: Loaded ${_coinMarketInfo.length} coins market info',
            );
          }
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint(
          'WalletActionProvider: Market data fresh (${now.difference(_coinMarketInfoFetchTime!).inSeconds}s old), skip fetch',
        );
      }
    }

    // 无论是否重新拉取，都用最新缓存重算价格和总余额
    for (CoinModel cm in coinList) {
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
        cm.coinPrice = parseMarketDouble(element['price'], 0.0);
        cm.percentage = parseMarketDouble(element['price_change_per_24h'], 0.0);
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
  Map<String, dynamic>? getCoinPriceWithUnit(String unit) {
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
      final price = parseMarketDouble(element['price'], 0.0);
      final percentage = parseMarketDouble(
        element['price_change_per_24h'],
        0.0,
      );
      if (kDebugMode) {
        debugPrint(
          'WalletActionProvider: getCoinPriceWithUnit($unit) -> price=\$$price, change=$percentage%',
        );
      }
      return {
        'icon': element['image'],
        'coinPrice': price,
        'percentage': percentage,
      };
    }
    if (kDebugMode) {
      debugPrint(
        'WalletActionProvider: getCoinPriceWithUnit($unit) -> NOT FOUND in ${_coinMarketInfo.length} items',
      );
    }
    return null;
  }

  //获取币的 全部信息
  Map<String, dynamic>? getCoinPriceWithUnitAll(String unit) {
    final keyStr = unit.toLowerCase();
    for (final element in _coinMarketInfo) {
      if (element['coin'].toString().toLowerCase() == keyStr) {
        return element;
      }
    }
    return null;
  }

  //获取币的基本信息
  Future<dynamic> getCoinsBaseInfo(String coinName) async {
    final m = await MarketApi().getWalletCoinsBaseInfo(coinName);
    if (m['error']) return null;
    return m['data'];
  }

  //refresh 是否刷新
  Future<void> initCoinInfo({bool refresh = true}) async {
    if (refresh) {
      setBalanceTotal(0);
    }
    refreshWalletCoinInfo(refresh: refresh);
  }

  //刷新钱包中币的余额与当前价格
  Future<void> refreshWalletCoinInfo({bool refresh = true}) async {
    if (refresh) {
      _load = Load.refresh;
      this.refresh();
    }
    await getCoinInfo();
    if (refresh) {
      _load = Load.finish;
      this.refresh();
    }
  }

  Future<bool> getBalanceTokenAlgoWithCoinModel(CoinModel coinModel) async {
    // address is guaranteed non-null by getBalanceWithCoinModel
    if (getCoinModelWithCoinType(coinModel.coin['coinType']) == null) {
      coinModel.loadError = true;
      refresh();
      return true;
    }

    final contract = coinModel.isTest
        ? coinModel.coin['contract_test']
        : coinModel.coin['contract'];

    final rBalance =
        await tokenViewApi.getBalance(
          BlockchainType.Algorand.name,
          coinModel.coin['coinType'],
          coinModel.address.toString(),
          contract: contract,
          isTest: coinModel.isTest,
        ) ??
        MessageModel.error();

    if (rBalance.error) {
      coinModel.loadError = true;
      refresh();
      return true;
    }

    coinModel.other = AlgoModel.fromCode(rBalance.data['code']);
    _applyMarketPrice(coinModel);

    final balanceKey = coinModel.isTest ? 'balance_test' : 'balance';
    coinModel.coin[balanceKey] = (rBalance.data['balance'] as BigInt)
        .toString();
    _safeUpdateWalletMap(coinModel);
    applyCachedBalance(coinModel);
    return false;
  }

  void addCoinRefreshMap() {
    if (coinRefreshMap.containsKey(walletIndex)) return;

    for (final cm in coinList) {
      if (cm is! AggregatedCoinModel && cm.address == null) cm.loadError = true;
    }

    coinRefreshMap[walletIndex] = coinList
        .where((cm) => cm is! AggregatedCoinModel && cm.address != null)
        .toList()
        .cast<CoinModel>();

    loadBalance = Load.loading;
    refresh();
    coinRefresh(walletIndex);
  }

  Future<void> refreshCoinBalance(
    String coinType, {
    String contract = "",
  }) async {
    final idx = coinList.indexWhere((e) {
      if (e.coin['coinType'] != coinType) return false;
      if (contract.isEmpty) return true;
      final c = e.isTest ? e.coin['contract_test'] : e.coin['contract'];
      return c == contract;
    });
    if (idx != -1) {
      await fetchCoinBalance(coinList[idx], this);
      refresh();
    }
  }

  void removeConRefreshMap(int index) {
    loadBalance = Load.finish;
    coinRefreshMap.remove(index);
    refresh();
  }

  Future<void> coinRefresh(int index) async {
    final queue = coinRefreshMap[index];
    if (queue == null) return;

    while (coinRefreshMap.containsKey(index) && queue.isNotEmpty) {
      final coin = queue.removeAt(0);
      coin.isRefresh = true;
      refresh();

      try {
        await getBalanceWithCoinModel(coin);
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            'WalletActionProvider: Error refreshing ${coin.coin['miniName']}: $e',
          );
        }
      }

      // 网络临时失败时用缓存数据，不显示错误图标
      coin.loadError = false;
      coin.isRefresh = false;
      refresh();
    }

    if (coinRefreshMap.containsKey(index)) {
      saveWalletInfo(walletInfo, walletIndex);
      calculateBalanceWidthCoinModel();
      removeConRefreshMap(index);
    }
    // 若 !containsKey，说明钱包已切换，由 setWalletIndex 负责清理
  }
}
