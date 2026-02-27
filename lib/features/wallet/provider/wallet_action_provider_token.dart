part of 'wallet_action_provider.dart';

/// Token & chain management: build coin models, add/remove chains/tokens,
/// and coin list operations.
extension WalletActionProviderToken on WalletActionProvider {

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
      cm.walletAccess=this;
      _coinModels.add(cm);
    }
    _applyChainOrder();
    refresh();
    await buildCoinModelInfo();
    globalTripInstance.selectUndoneTr();
  }

  /// 按 walletInfo.chainOrder 重排 _coinModels。
  /// chainOrder 为空时直接返回（维持 walletMap 键顺序）。
  /// 不在 chainOrder 中的链追加到末尾（兼容自动添加的新链）。
  void _applyChainOrder() {
    if (walletInfo.chainOrder.isEmpty) return;
    final ordered = <CoinModel>[];
    final remaining = List<CoinModel>.from(_coinModels);
    for (final coinType in walletInfo.chainOrder) {
      final idx = remaining.indexWhere((cm) => cm.coin['coinType'] == coinType);
      if (idx != -1) {
        ordered.add(remaining.removeAt(idx));
      }
    }
    // 不在 chainOrder 中的新链追加到末尾
    ordered.addAll(remaining);
    _coinModels = ordered;
  }

  /// 拖拽重排链顺序并持久化。
  void reorderChain(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _coinModels.removeAt(oldIndex);
    _coinModels.insert(newIndex, item);
    walletInfo.chainOrder = _coinModels
        .map((m) => m.coin['coinType'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    buildCoinModelInfo();
    saveCoinSort();
  }

  /// 切换链的显示/隐藏状态。
  void toggleChainVisibility(CoinModel cm) {
    final coinType = cm.coin['coinType'] as String?;
    if (coinType == null) return;
    cm.showList = !cm.showList;
    // 同步到 walletMap
    if (walletMap.containsKey(coinType)) {
      walletMap[coinType]['showList'] = cm.showList;
    }
    buildCoinModelInfo();
    saveWalletInfo(walletInfo, walletIndex);
  }

  Future<void> buildCoinModelInfo() async {
    coinList=[];
    _aggregatedCoins = [];
    int ethIndex = -1; // 记录 ETH 的位置，用于后续插入聚合代币

    for (int i = 0; i < _coinModels.length; i++) {
      CoinModel mm = _coinModels[i];
      await mm.buildWallet(walletAccess: this);
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
      refresh();
    }

    // 在所有代币添加完成后，插入聚合代币
    await _insertAggregatedTokensAt(0); // 先插入，后面会排序

    // 同步置顶状态并应用优先级排序
    _syncPinnedState();
    _applyPriorityOrder();
    _elevatePinnedToTop(); // 置顶优先于优先级链

    calculateBalanceWidthCoinModel();
    saveCoinSort();
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
    cm.walletAccess=this;
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
        await mm.buildWallet(walletAccess: this);
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
        refresh();
      }

      // 在所有代币添加完成后，插入聚合代币
      await _insertAggregatedTokensAt(0);

      // 同步置顶状态并应用优先级排序
      _syncPinnedState();
      _applyPriorityOrder();
      _elevatePinnedToTop();
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
      _syncPinnedState();
    }
    // 排序时保持优先级（如果有自定义排序，之后会覆盖）
    if (walletInfo.coinSort['assets'] == -1 && walletInfo.coinSort['name'] == -1) {
      _applyPriorityOrder();
      _elevatePinnedToTop();
    } else {
      coinSortAssets(); // coinSortAssets 内部已调用 _elevatePinnedToTop
    }
    refresh();
    calculateBalanceWidthCoinModel();
    addCoinRefreshMap();
  }

  //保存币的排序缓存
  Future<void> saveCoinSort()async{
    saveWalletInfo(walletInfo,walletIndex);
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
      coinList[clIndex].buildWallet(walletAccess: this);
      coinList[clIndex].getBalanceDefault();
      if(coinList[clIndex].tokens.isNotEmpty){
        List<String> tKeys=coinList[clIndex].tokens.keys.toList();
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
    refresh();
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
    refresh();
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

    // 清理该链及其所有合约代币的置顶记录（避免残留 stale key）
    walletInfo.pinnedCoins.removeWhere(
      (key) => key == unit || key.startsWith('${unit}_'),
    );
    _lastSyncFingerprint = ''; // 使缓存失效，下次强制重同步

    saveWalletInfo(walletInfo, walletIndex);
    refresh();
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
    refresh();
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

    // 清理该合约代币对应的置顶记录
    final tokenMiniName = (miniName ?? token['miniName']?.toString() ?? '').toUpperCase();
    if (tokenMiniName.isNotEmpty) {
      walletInfo.pinnedCoins.remove('${symbolStr}_$tokenMiniName');
      _lastSyncFingerprint = ''; // 使缓存失效，下次强制重同步
    }

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
    refresh();
  }
}
