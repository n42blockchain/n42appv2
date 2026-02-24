part of 'wallet_coin_add_all.dart';

/// Chain/token data processing methods for [_WalletCoinAddAllState].
///
/// Contains: setChainsToken, setChainsTokenWithNetwork, checkSymbol,
/// dealChain, coinDeal, getChainList, _extractPopularTokens.
extension _WalletCoinAddAllData on _WalletCoinAddAllState {
  void setChainsToken() {
    chainsToken = {};
    if (chains != null) {
      List<String> cKeys = chains!.keys.toList();
      for (String key in cKeys) {
        Map<String, dynamic> chain = chains![key];
        if (chain['baseInfo']["blockchainType"] !=
            BlockchainType.Bitcoin.name &&
            chain['baseInfo']["blockchainType"] !=
                BlockchainType.Algorand.name &&
            chain['baseInfo']["coinType"] != CoinType.N.name) {
          chainsToken[key] = chain;
        }
      }
    }
    setChainsTokenWithNetwork();
  }

  void setChainsTokenWithNetwork() {
    List<String> cKeys = chainsToken.keys.toList();
    if (cKeys.isNotEmpty) {
      networkNameToken =
      chainsToken[cKeys[networkIndexToken]]["baseInfo"]['name'];
    }else{
      return;
    }
    Map<String, dynamic> chainMap = chainsToken[cKeys[networkIndexToken]];
    dynamic mainnets;
    if (chainMap['isTest']) {
      mainnets = chainMap['testnets'][0]['testnetContract'];
    } else {
      mainnets = chainMap['mainnets'];
    }
    coinlistToken = [];
    if (mainnets.length != 0) {
      List<String> mainnetKeys =
      (mainnets as Map<String, dynamic>).keys.toList();
      for (String key in mainnetKeys) {
        Map<String, dynamic> mainnet = mainnets[key];
        if (mainnet['customer'] != null && mainnet['customer'] == true) {
          mainnet["edit"] = false;
          coinlistToken.add(mainnet);
        }
      }
    }
  }

  //检查主链币，或者代币是否已经添加
  bool checkSymbol(String contract, String symbol) {
    Map<String, dynamic>? chain = chains![symbol.toUpperCase()];
    if (chain == null) {
      return false;
    } else {
      if (contract == "") {
        if (chain['showList']) {
          return true;
        } else {
          return false;
        }
      } else {
        final coin = chain['mainnets'][contract];
        if (coin == null) {
          return false;
        } else {
          return true;
        }
      }
    }
  }

  //处理主链币的数据
  Map<String, dynamic>? dealChain(
      Map<String, dynamic> chainMap,
      ) {
    String blockchainType = "";
    String coinType = "";
    String symbol = chainMap['coin_name'].toString();
    String unit = chainMap['unit'].toString();
    int ctIndex= CoinType.values.indexWhere((element) => element.name.toLowerCase() == symbol.toLowerCase() ? true : false);
    if(ctIndex ==-1)return null;
    /*CoinType? ct = CoinType.values.firstWhere((element) =>
        element.name.toLowerCase() == symbol.toLowerCase() ? true : false);
    if (ct == null) return null;*/
    CoinType ct=CoinType.values[ctIndex];
    coinType = ct.name;
    BlockchainType bct = BlockchainType.values.firstWhere((element) =>
    element.name.toLowerCase() ==
        chainMap['class_name'].toString().toLowerCase()
        ? true
        : false);
    blockchainType = bct.name;
    Map<String, dynamic> path = {};

    List<dynamic>? derivation = json.decode(chainMap['derivation']);
    if (derivation == null) return null;
    String addrType = "legacy";

    for (Map<dynamic, dynamic> p in derivation) {
      if (bct == BlockchainType.Ethereum) {
        path[addrType] = p['path'];
      } else if (bct == BlockchainType.Tron) {
        path[addrType] = p['path'];
      } else if (bct == BlockchainType.Solana) {
        String? pName = p['name'];
        if (pName == null) {
          path[addrType] = p['path'];
        }
      } else if (bct == BlockchainType.Bitcoin) {
        String pPath = p['path'];
        if (ct.name == "BCH") {
          path["segwit"] = pPath;
        } else {
          int pIndex = pPath.indexOf("44");
          if (pIndex >= 0) {
            path['legacy'] = pPath;
          } else {
            pIndex = pPath.indexOf("84");
            if (pIndex >= 0) {
              path['segwit'] = pPath;
            }
          }
        }
      }
    }
    String testNetUrl = chainMap['test_net_url'];
    String mainNetUrl = chainMap['main_net_url'];
    int mainChainId = chainMap['main_chain_id'];
    int testChainId = chainMap['test_chain_id'];
    String rules = chainMap['rules'];
    bool supportTest = true;
    if (bct == BlockchainType.Bitcoin) {
      supportTest = false;
      if (path.length == 1) {
        addrType = path.keys.first;
      } else {
        addrType = "segwit";
      }
    } else {
      if (testNetUrl == "") {
        supportTest = false;
      }
    }
    String fullname = chainMap['fullname'];
    String icon="https://api-wallet.walletamaze.com/market/v1/r/coinImage/$fullname.png";

    if(fullname=="LoveCoin"){
      icon=chainMap['icon'];
    }else if(fullname=="Base"){
      icon="${AppConfig.apiUrl['walletamazeBrowser']}/static/${chainMap['coin_name']}.png";
    }
    Map<String, dynamic> chainInfoMap = {
      "isTest": coinType == "ZETA" ? true : false, //是否是正式链
      "supportTest": supportTest, //是否支持测试地址
      "addrType": addrType, //地址类型
      "pathIndex": 0, //path具体的账号节点
      "pathList": [0], //path数量
      "baseInfo": {
        "blockchainType": blockchainType,
        "coinType": coinType,
        //"icon": "https://api-wallet.walletamaze.com/market/v1/r/coinImage/${coinType.toLowerCase()}.png",
        "icon":icon,
        //"https://api-wallet.walletamaze.com/market/v1/r/coinImage/${chainMap['fullname']}.png",
        "name": chainMap['fullname'],
        "miniName": coinType,
        "unit": unit == "" ? symbol : unit,
        "decimals": chainMap['decimals'],
        "balance": "0",
        "balance_test": "0",
        "coinPrice": 0.0,
        "percentage": 0.0,
        "isContract": false,
        "mKey": coinType,
        "path": path,
        "service": mainNetUrl,
        "service_test": testNetUrl,
        "chainId": mainChainId,
        "chainId_test": testChainId,
        "contract": "",
        "contract_test": "",
        "canEdit": widget.coinType==null?true:false,
        "rules": rules,
      },
      "mainnetChainID": mainChainId,
      "testnetChainID": testChainId,
      "testnetIndex": 0, //当前选择的测试网络 索引值
      "testnets": [
        {
          "testnetWS": "",
          "testnetRPC": testNetUrl,
          "testnetChainID": testChainId,
          "testnetContract": {}
        },
      ],
      "mainnets": {},
      "mainnetContract": {},
      "testnetContract": {}
    };
    return chainInfoMap;
  }

  Future<void> getChainList() async {
    setState(() {
      load = Load.loading;
    });
    TokenViewApi tokenViewApi=TokenViewApi();
    MessageModel coinsData = await tokenViewApi.getChainListAll();
    if (coinsData.error) {
      ToastUtils.show(coinsData.data);
    } else {
      if (!mounted) return;
      coinlist = [];
      List<dynamic> returnData = coinsData.data;
      Map<String, dynamic> chains =
          ref.read(wapBridgeProvider).walletMap;
      coinDeal(returnData, chains);
      // 从全量列表中提取热门代币（仅带合约地址的代币条目）
      _extractPopularTokens();
    }
    setState(() {
      load = Load.finish;
    });
    if (inputEditingController.text != "") {
      seachCoin();
    }
  }

  /// 从 [coinlist] 中提取热门代币，去重（同一 symbol 只保留各链一条）。
  void _extractPopularTokens() {
    final seen = <String>{};
    _popularTokens = coinlist.where((item) {
      final sym = (item['coin_name'] ?? '').toString().toUpperCase();
      final contract = (item['contract'] ?? '').toString();
      if (!_WalletCoinAddAllState._popularSymbolSet.contains(sym)) return false;
      if (contract.isEmpty) return false; // 排除主链币（只保留代币条目）
      final key = '$sym:${(item["chain_name"] ?? "").toString()}';
      return seen.add(key); // 去重
    }).toList();
  }

  //链 币 数据处理
  void coinDeal(List<dynamic> returnData, Map<String, dynamic> chains,
      {String rules = "", String chainName = "", String symbol = ""}) {
    for (Map<String, dynamic> r in returnData) {
      if (chainName == "") {
        if(widget.coinType !=null){
          if(widget.coinType != r['coin_name'].toString().toUpperCase()){
            continue;
          }
        }
        Map<String, dynamic>? chain = dealChain(r);
        if (chain != null) {
          netChains[r['coin_name'].toString().toUpperCase()] = chain;
        }
      }
      else {
        if (r['contract'] == "") {
          continue;
        }
        r['chain_name'] = chainName;
      }
      if (rules != "") {
        r['rules'] = rules;
      }

      if (symbol != "") {
        r['symbol'] = symbol;
      }
      String checkStr = symbol;
      if (chainName == "") {
        checkStr = r['coin_name'].toString();
      }
      r['isAdd'] =
          checkSymbol(r['contract'].toString().toUpperCase(), checkStr);
      r['edit'] = false;
      if (r['isAdd']) {
        Map<String, dynamic>? chainMap = chains[checkStr.toUpperCase()];
        if (chainMap == null) {
          r['canEdit'] = false;
        } else {
          if (chainName != "") {
            r['canEdit'] = true;
          } else {
            r['canEdit'] = chainMap['baseInfo']['canEdit'];
          }
        }
      } else {
        r['canEdit'] = true;
      }
      if (r['isAdd']) {
        coinlist.insert(0, r);
      } else {
        coinlist.add(r);
      }
      List<dynamic>? coins = r['coins'];
      if (coins != null) {
        coinDeal(coins, chains,
            rules: r['rules'],
            chainName: r['chain_name'],
            symbol: r['coin_name']);
      }
    }
  }
}
