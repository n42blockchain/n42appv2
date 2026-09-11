part of 'wallet_action_provider.dart';

/// Coin list sorting, priority ordering, pinning, and aggregated token insertion.
extension WalletActionProviderSort on WalletActionProvider {
  /// 优先级币种列表（按显示顺序）
  static const List<String> _priorityCoins = [
    'N',
    'BTC',
    'ETH',
    'USDT',
    'USDC',
  ];

  /// 应用优先级排序，确保 N, BTC, ETH, USDT, USDC 在列表最前面
  void _applyPriorityOrder() {
    if (coinList.isEmpty) return;

    coinList.sort((a, b) {
      final ai = _priorityCoins.indexOf(_getCoinSymbol(a));
      final bi = _priorityCoins.indexOf(_getCoinSymbol(b));
      // 两个都不是优先币种 → 保持原序
      if (ai == -1 && bi == -1) return 0;
      // 只有一个是优先币种 → 优先币种在前
      if (ai == -1) return 1;
      if (bi == -1) return -1;
      // 两个都是优先币种 → 按优先级排序
      return ai.compareTo(bi);
    });
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
    // 收集 coinList 中所有代币的符号（用于去重）
    final existingTokenSymbols = coinList
        .whereType<CoinModel>()
        .map((c) => c.config.miniName.toUpperCase())
        .where((s) => s.isNotEmpty)
        .toSet();

    // 已存在的聚合代币符号
    final existingAggregatedSymbols = _aggregatedCoins
        .map((c) => c.tokenConfig.symbol)
        .toSet();

    // 创建聚合代币（跳过已存在的）
    final toAdd = <AggregatedCoinModel>[];
    for (final tokenConfig in AggregatedTokens.all) {
      if (existingAggregatedSymbols.contains(tokenConfig.symbol)) continue;
      if (existingTokenSymbols.contains(tokenConfig.symbol.toUpperCase())) {
        continue;
      }

      final aggregatedCoin = AggregatedCoinModel(tokenConfig: tokenConfig);
      if (_aggregateAddresses(aggregatedCoin).isEmpty) continue;
      _aggregatedCoins.add(aggregatedCoin);
      toAdd.add(aggregatedCoin);
    }

    if (toAdd.isNotEmpty) {
      coinList.addAll(toAdd);
      for (final coin in toAdd) {
        getCoinPrice(coin);
      }
      // The model enters the active list before callbacks can notify it.
      refreshAggregatedBalances();
    }
  }

  /// 在 cycle 值之间循环切换：按给定顺序轮转
  int _cycleSortValue(int current, List<int> cycle) {
    final idx = cycle.indexOf(current);
    return cycle[(idx + 1) % cycle.length];
  }

  /// 币列表排序
  void setCoinSortAssets(String type) {
    final sort = walletInfo.coinSort;
    // assets/name: -1→1→0→-1（-1=不排序, 1=升序, 0=降序）
    // change:      -1→0→1→-1（-1=不排序, 0=降序, 1=升序）
    const allFields = ['assets', 'name', 'change'];
    final cycle = (type == 'change') ? [-1, 0, 1] : [-1, 1, 0];

    sort[type] = _cycleSortValue(sort[type] ?? -1, cycle);

    // 重置其他排序字段
    for (final field in allFields) {
      if (field != type) sort[field] = -1;
    }

    coinSortAssets();
    refresh();
  }

  /// 排序 coinList（支持 assets / name / change 三种维度）
  void coinSortAssets() {
    final sort = walletInfo.coinSort;

    // 按资产价值排序
    final assetsSort = sort['assets'] ?? -1;
    if (assetsSort == 0) {
      coinList.sort((a, b) => b.value.compareTo(a.value));
    } else if (assetsSort == 1) {
      coinList.sort((a, b) => a.value.compareTo(b.value));
    }

    // 按名称排序（0=降序, 1=升序）
    final nameSort = sort['name'] ?? -1;
    if (nameSort == 0 || nameSort == 1) {
      coinList.sort((a, b) {
        final aName = (a.coin['miniName'] ?? a.coin['coinType'] ?? '')
            .toString();
        final bName = (b.coin['miniName'] ?? b.coin['coinType'] ?? '')
            .toString();
        return nameSort == 0 ? aName.compareTo(bName) : bName.compareTo(aName);
      });
    }

    // 按 24h 涨跌幅排序（0=降序, 1=升序）
    final changeSort = sort['change'] ?? -1;
    if (changeSort == 0) {
      coinList.sort((a, b) => b.percentage.compareTo(a.percentage));
    } else if (changeSort == 1) {
      coinList.sort((a, b) => a.percentage.compareTo(b.percentage));
    }

    // 任何排序后，置顶代币始终在最前面
    _elevatePinnedToTop();
  }

  // ── 代币置顶 ─────────────────────────────────────────────────────────────

  /// 生成代币置顶的唯一标识 key。
  /// 主链币：coinType；合约代币：coinType_miniName（避免碰撞）。
  String _coinPinKey(CoinModel cm) {
    final coinType = cm.config.coinType;
    final miniName = cm.config.miniName;
    if (coinType.isEmpty) return '__invalid__';
    if (cm.config.isContract) return '${coinType}_$miniName';
    return coinType;
  }

  /// 同步 coinList 中所有 CoinModel 的 isPinned 状态。
  /// 在 coinList 重建完成后、排序前调用。
  /// 使用 fingerprint 缓存：pinnedCoins 与 coinList 长度均未变化时直接跳过。
  void _syncPinnedState() {
    // 使用内容哈希（Object.hashAll），而非 List 的 identity hashCode
    final fp = '${Object.hashAll(walletInfo.pinnedCoins)}|${coinList.length}';
    if (fp == _lastSyncFingerprint) return; // 无变化，跳过
    _lastSyncFingerprint = fp;

    if (walletInfo.pinnedCoins.isEmpty) {
      for (final c in coinList) {
        c.isPinned = false;
      }
      return;
    }
    final pinnedSet = Set<String>.from(walletInfo.pinnedCoins);
    for (final c in coinList) {
      c.isPinned = pinnedSet.contains(_coinPinKey(c));
    }
  }

  /// 将已置顶的代币提升到 coinList 前端，各组内部顺序不变（稳定）。
  void _elevatePinnedToTop() {
    if (walletInfo.pinnedCoins.isEmpty || coinList.isEmpty) return;
    final pinned = <CoinModel>[];
    final others = <CoinModel>[];
    for (final c in coinList) {
      if (c.isPinned) {
        pinned.add(c);
      } else {
        others.add(c);
      }
    }
    if (pinned.isEmpty) return;
    coinList
      ..clear()
      ..addAll(pinned)
      ..addAll(others);
  }

  /// 切换代币置顶状态；持久化并触发重排 + 通知。
  /// 聚合代币（isAggregated）不允许置顶，调用时会被忽略。
  void togglePinCoin(CoinModel cm) {
    if (cm.config.isAggregated) return;
    final key = _coinPinKey(cm);
    if (key == '__invalid__') return; // 无效代币 key，拒绝操作

    if (cm.isPinned) {
      walletInfo.pinnedCoins.remove(key);
      cm.isPinned = false;
    } else {
      if (walletInfo.pinnedCoins.length >= 200) return; // 防止无限增长
      walletInfo.pinnedCoins.add(key);
      cm.isPinned = true;
    }
    // 重新排序（保持当前排序策略），coinSortAssets 内部已调用 _elevatePinnedToTop
    final isDefaultSort =
        walletInfo.coinSort['assets'] == -1 &&
        walletInfo.coinSort['name'] == -1;
    if (isDefaultSort) {
      _applyPriorityOrder();
      _elevatePinnedToTop();
    } else {
      coinSortAssets();
    }
    saveCoinSort(); // 持久化（内部调用 saveWalletInfo）
    refresh();
  }

  /// 字符串字典序比较（等价于 String.compareTo）
  int sortString(String aName, String bName) => aName.compareTo(bName);
}
