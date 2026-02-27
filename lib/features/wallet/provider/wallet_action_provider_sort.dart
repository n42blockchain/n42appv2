part of 'wallet_action_provider.dart';

/// Coin list sorting, priority ordering, pinning, and aggregated token insertion.
extension WalletActionProviderSort on WalletActionProvider {

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
        refresh();
      });
    }

    // 添加聚合代币到列表（后续由 _applyPriorityOrder 排序）
    if (toAdd.isNotEmpty) {
      coinList.addAll(toAdd);
    }
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
      walletInfo.coinSort['change']=-1;
    }else if(type=="name"){
      if(walletInfo.coinSort['name'] == 0){
        walletInfo.coinSort['name']=1;
      }else if(walletInfo.coinSort['name'] == 1){
        walletInfo.coinSort['name']=0;
      }else{
        walletInfo.coinSort['name']=1;
      }
      walletInfo.coinSort['assets']=-1;
      walletInfo.coinSort['change']=-1;
    }else if(type=="change"){
      // change 循环：-1→0→1→-1（-1=不排序, 0=降序, 1=升序）
      final cur = walletInfo.coinSort['change'] ?? -1;
      if(cur == -1){
        walletInfo.coinSort['change']=0;
      }else if(cur == 0){
        walletInfo.coinSort['change']=1;
      }else{
        walletInfo.coinSort['change']=-1;
      }
      walletInfo.coinSort['assets']=-1;
      walletInfo.coinSort['name']=-1;
    }

    coinSortAssets();
    refresh();
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
    final changeSort = walletInfo.coinSort['change'] ?? -1;
    if(changeSort == 0){
      // 按 24h 涨跌幅降序（涨幅最大在前）
      coinList.sort((a, b) => (b.percentage as double).compareTo(a.percentage as double));
    }else if(changeSort == 1){
      // 按 24h 涨跌幅升序（涨幅最小在前）
      coinList.sort((a, b) => (a.percentage as double).compareTo(b.percentage as double));
    }
    // 任何排序后，置顶代币始终在最前面
    _elevatePinnedToTop();
  }

  // ── 代币置顶 ─────────────────────────────────────────────────────────────

  /// 生成代币置顶的唯一标识 key。
  /// 主链币：coinType；合约代币：coinType_miniName（避免碰撞）。
  String _coinPinKey(CoinModel cm) {
    final coinType = cm.coin['coinType'] as String? ?? '';
    final miniName = cm.coin['miniName'] as String? ?? '';
    if (coinType.isEmpty) return '__invalid__';
    if (cm.coin['isContract'] == true) return '${coinType}_$miniName';
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
        if (c is CoinModel) c.isPinned = false;
      }
      return;
    }
    final pinnedSet = Set<String>.from(walletInfo.pinnedCoins);
    for (final c in coinList) {
      if (c is CoinModel) {
        c.isPinned = pinnedSet.contains(_coinPinKey(c));
      }
    }
  }

  /// 将已置顶的代币提升到 coinList 前端，各组内部顺序不变（稳定）。
  void _elevatePinnedToTop() {
    if (walletInfo.pinnedCoins.isEmpty || coinList.isEmpty) return;
    final pinned = <dynamic>[];
    final others = <dynamic>[];
    for (final c in coinList) {
      if (c is CoinModel && c.isPinned) {
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
    if (cm.coin['isAggregated'] == true) return;
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
    final isDefaultSort = walletInfo.coinSort['assets'] == -1 && walletInfo.coinSort['name'] == -1;
    if (isDefaultSort) {
      _applyPriorityOrder();
      _elevatePinnedToTop();
    } else {
      coinSortAssets();
    }
    saveCoinSort(); // 持久化（内部调用 saveWalletInfo）
    refresh();
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
}
