part of 'wallet_action_provider.dart';

/// Wallet CRUD operations: create, import, delete, save, find, backup, key management.
extension WalletActionProviderWallet on WalletActionProvider {

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
    refresh();
  }

  Future<void> initWallet({bool shouldInitCoinInfo=false})async{
    if(buildwallet==true)return;
    buildwallet=true;
    try {
      await getWalletInfo();
      // 同步新链到现有钱包
      await _syncNewChains();
      //导入的钱包
      //await initImportWallet();
      await buildCoinModel();
    } finally {
      buildwallet=false;
      refresh();
    }
    if(shouldInitCoinInfo){
      ///发送一个event事件 对挖矿进行初始化
      eventBus.fire(EventPublic(EventPublicType.selectWallet,
          intValue: walletIndex,stringValue: "wallet"));
      initCoinInfo();
    }
    await refreshWalletListNotifier();
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
      refresh();
    }catch(e){
      ToastUtils.show(e.toString());
    }

  }

  /// 添加观察钱包（Watch-only）
  /// [name] 钱包显示名称；[address] 要追踪的 EVM 地址（0x...）
  Future<void> addWatchOnlyWallet(String name, String address) async {
    final wInfo = WalletInfo(
      walletName: name.trim().isEmpty ? 'Watch ${_walletInfoLsit.length + 1}' : name.trim(),
      password: '0', // 非空，避免触发备份提示
      walletUuid: userUUID,
    );
    wInfo.watchOnly = true;
    wInfo.watchAddress = address.trim();
    wInfo.mnemonic = '';
    wInfo.privateKey = '';
    wInfo.coinInfo = chainUrlMap;
    wInfo.mainWallet = false;
    wInfo.timestamp = '${DateTime.now().millisecondsSinceEpoch}';
    await addWalletInfo(wInfo);
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
      // 观察钱包：无私钥/助记词，直接删除，跳过挖矿地址检查
      if (!_walletInfoLsit[rIndex].watchOnly) {
        Map<String,dynamic> cInfo=_walletInfoLsit[rIndex].coinInfo?[CoinType.N.name];
        Map<String, dynamic> pathMap = cInfo['baseInfo']['path'];
        var rmAddress=await Trustdart().generateAddress(
            CoinType.N.name,
            getPathWithIndex(pathMap[cInfo['addrType']], cInfo['pathIndex']),
            cInfo['addrType'],
            mnemonic: _walletInfoLsit[rIndex].mnemonic??"",
            pk: _walletInfoLsit[rIndex].privateKey??""
        );
        String miningAddress=rmAddress[cInfo['addrType']];
        var miningData=globalMiningInstance.miningData?[miningAddress];
        if(miningData !=null){
          if(miningData['isMining']==true){
            MessageModel rmm=MessageModel.error();
            rmm.data="The validator's wallet cannot be deleted!";//"验证者钱包，无法删除！";
            return rmm;
          }
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
      // EDGE-M03: 验证路径配置完整性，防止 addrType 不存在时产生难以追踪的空指针
      final pathMap = nChainConfig['baseInfo']?['path'];
      final addrType = nChainConfig['addrType'] as String?;
      if (pathMap == null || addrType == null || pathMap[addrType] == null) {
        debugPrint('WalletActionProvider: Invalid path config for ${wInfo.walletName}, addrType=$addrType');
        continue;
      }
      try {
        String path=getPathWithIndex(pathMap[addrType], nChainConfig['pathIndex']);
        String privateKeyStr=await trustdart.getPrivateKeyAndPublicKeyPair(
          CoinType.N.name,
          path,
          mnemonic: wInfo.mnemonic??"",
          pk: wInfo.privateKey??"",
        );
        if (privateKeyStr.isEmpty) {
          debugPrint('WalletActionProvider: Empty key pair response for ${wInfo.walletName}');
          continue;
        }
        Map<dynamic,dynamic> pkPair=json.decode(privateKeyStr);
        final pubKey = bytesToHex(base64Decode(pkPair['publicKey'].toString()));
        final privateKey = bytesToHex(base64Decode(pkPair['privateKey'].toString()));
        _publicKeyAndPrivateKeyPair![pubKey] = privateKey;
      } catch (e) {
        debugPrint('WalletActionProvider: Failed to load key pair for ${wInfo.walletName}: $e');
      }
    }
  }

  String? getPrivateKeyWithPublicKey(String publicKey){
    return _publicKeyAndPrivateKeyPair?[publicKey];
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
}
