// ignore_for_file: invalid_use_of_protected_member

part of 'wallet_coin_add_all.dart';

/// Chain/token data processing methods for [_WalletCoinAddAllState].
///
/// Contains: setChainsToken, setChainsTokenWithNetwork, checkSymbol,
/// dealChain, coinDeal, getChainList, _extractPopularTokens.
extension _WalletCoinAddAllData on _WalletCoinAddAllState {
  String _mapString(
    Map<String, dynamic> map,
    String key, {
    String fallback = '',
  }) {
    final value = map[key];
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  int _mapInt(Map<String, dynamic> map, String key, {int fallback = 0}) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  void setChainsToken() {
    chainsToken = {};
    if (chains != null) {
      for (final entry in chains!.entries) {
        final baseInfo =
            (entry.value['baseInfo'] as Map?)?.cast<String, dynamic>() ??
            const {};
        final blockchainType = _mapString(baseInfo, 'blockchainType');
        final coinType = _mapString(baseInfo, 'coinType');
        if (blockchainType != BlockchainType.Bitcoin.name &&
            blockchainType != BlockchainType.Algorand.name &&
            coinType != CoinType.N.name) {
          chainsToken[entry.key] = entry.value;
        }
      }
    }
    setChainsTokenWithNetwork();
  }

  void setChainsTokenWithNetwork() {
    final cKeys = chainsToken.keys.toList();
    if (cKeys.isEmpty) return;
    if (networkIndexToken < 0 || networkIndexToken >= cKeys.length) {
      networkIndexToken = 0;
    }

    final currentChain =
        (chainsToken[cKeys[networkIndexToken]] as Map?)
            ?.cast<String, dynamic>() ??
        const {};
    final baseInfo =
        (currentChain['baseInfo'] as Map?)?.cast<String, dynamic>() ?? const {};
    networkNameToken = _mapString(baseInfo, 'name');
    final isTest = currentChain['isTest'] == true;
    final testnets = currentChain['testnets'];
    final mainnets =
        isTest &&
            testnets is List &&
            testnets.isNotEmpty &&
            testnets.first is Map
        ? (testnets.first as Map)['testnetContract']
        : currentChain['mainnets'];

    coinlistToken = [];
    if (mainnets is Map<String, dynamic> && mainnets.isNotEmpty) {
      for (final mainnet in mainnets.values) {
        if (mainnet is Map<String, dynamic> && mainnet['customer'] == true) {
          mainnet["edit"] = false;
          coinlistToken.add(mainnet);
        }
      }
    }
  }

  bool checkSymbol(String contract, String symbol) {
    final chain = chains![symbol.toUpperCase()];
    if (chain == null) return false;
    if (contract == "") return chain['showList'] == true;
    final mainnets = chain['mainnets'];
    return mainnets is Map && mainnets[contract] != null;
  }

  Map<String, dynamic>? dealChain(Map<String, dynamic> chainMap) {
    final symbol = _mapString(chainMap, 'coin_name');
    if (symbol.isEmpty) return null;
    final unit = _mapString(chainMap, 'unit');
    final ctIndex = CoinType.values.indexWhere(
      (e) => e.name.toLowerCase() == symbol.toLowerCase(),
    );
    if (ctIndex == -1) return null;
    final ct = CoinType.values[ctIndex];
    final coinType = ct.name;
    final className = _mapString(chainMap, 'class_name');
    final bctIndex = BlockchainType.values.indexWhere(
      (e) => e.name.toLowerCase() == className.toLowerCase(),
    );
    if (bctIndex == -1) return null;
    final bct = BlockchainType.values[bctIndex];
    final blockchainType = bct.name;
    final path = <String, dynamic>{};

    final derivationRaw = chainMap['derivation'];
    if (derivationRaw == null) return null;
    final List<dynamic> derivation;
    try {
      final decoded = json.decode(derivationRaw.toString());
      if (decoded is! List<dynamic>) return null;
      derivation = decoded;
    } catch (_) {
      return null;
    }
    String addrType = "legacy";

    for (final p in derivation) {
      if (p is! Map) continue;
      final pMap = p.cast<String, dynamic>();
      final pPath = _mapString(pMap, 'path');
      if (pPath.isEmpty) continue;
      if (bct == BlockchainType.Ethereum || bct == BlockchainType.Tron) {
        path[addrType] = pPath;
      } else if (bct == BlockchainType.Solana) {
        if (pMap['name'] == null) path[addrType] = pPath;
      } else if (bct == BlockchainType.Bitcoin) {
        if (ct.name == "BCH") {
          path["segwit"] = pPath;
        } else if (pPath.contains("44")) {
          path['legacy'] = pPath;
        } else if (pPath.contains("84")) {
          path['segwit'] = pPath;
        }
      }
    }
    if (path.isEmpty) return null;
    final testNetUrl = _mapString(chainMap, 'test_net_url');
    final mainNetUrl = _mapString(chainMap, 'main_net_url');
    final mainChainId = _mapInt(chainMap, 'main_chain_id');
    final testChainId = _mapInt(chainMap, 'test_chain_id');
    final rules = _mapString(chainMap, 'rules');
    bool supportTest = true;
    if (bct == BlockchainType.Bitcoin) {
      supportTest = false;
      addrType = path.length == 1 ? path.keys.first : "segwit";
    } else if (testNetUrl == "") {
      supportTest = false;
    }
    final fullname = _mapString(chainMap, 'fullname', fallback: symbol);
    final icon = switch (fullname) {
      'LoveCoin' => _mapString(chainMap, 'icon'),
      'Base' =>
        "${AppConfig.apiUrl['n42Browser']}/static/${chainMap['coin_name']}.png",
      _ => "https://api.n42.ai/market/v1/r/coinImage/$fullname.png",
    };
    Map<String, dynamic> chainInfoMap = {
      "isTest": coinType == "ZETA",
      "supportTest": supportTest,
      "addrType": addrType,
      "pathIndex": 0,
      "pathList": [0],
      "baseInfo": {
        "blockchainType": blockchainType,
        "coinType": coinType,
        "icon": icon,
        "name": fullname,
        "miniName": coinType,
        "unit": unit == "" ? symbol : unit,
        "decimals": _mapInt(chainMap, 'decimals', fallback: 18),
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
        "canEdit": widget.coinType == null,
        "rules": rules,
      },
      "mainnetChainID": mainChainId,
      "testnetChainID": testChainId,
      "testnetIndex": 0,
      "testnets": [
        {
          "testnetWS": "",
          "testnetRPC": testNetUrl,
          "testnetChainID": testChainId,
          "testnetContract": {},
        },
      ],
      "mainnets": {},
      "mainnetContract": {},
      "testnetContract": {},
    };
    return chainInfoMap;
  }

  Future<void> getChainList() async {
    updateView(() => load = Load.loading);
    final coinsData = await (widget.tokenViewApi ?? TokenViewApi())
        .getChainListAll();
    if (coinsData.error) {
      ToastUtils.show(coinsData.data);
    } else {
      if (!mounted) return;
      coinlist = [];
      netChains = {};
      final returnData = coinsData.data as List<dynamic>;
      final chains = ref.read(wapBridgeProvider).walletMap;
      coinDeal(returnData, chains);
      // 从全量列表中提取热门代币（仅带合约地址的代币条目）
      _extractPopularTokens();
    }
    updateView(() => load = Load.finish);
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
      if (!_WalletCoinAddAllState._popularSymbolSet.contains(sym)) {
        return false;
      }
      if (contract.isEmpty) return false; // 排除主链币（只保留代币条目）
      final key = '$sym:${(item["chain_name"] ?? "").toString()}';
      return seen.add(key); // 去重
    }).toList();
  }

  void coinDeal(
    List<dynamic> returnData,
    Map<String, dynamic> chains, {
    String rules = "",
    String chainName = "",
    String symbol = "",
  }) {
    for (final item in returnData) {
      if (item is! Map) continue;
      final r = item.cast<String, dynamic>();
      if (chainName == "") {
        if (widget.coinType != null &&
            widget.coinType != r['coin_name'].toString().toUpperCase()) {
          continue;
        }
        final chain = dealChain(r);
        if (chain != null) {
          netChains[r['coin_name'].toString().toUpperCase()] = chain;
        }
      } else {
        if (r['contract'] == "") continue;
        r['chain_name'] = chainName;
      }
      if (rules != "") r['rules'] = rules;
      if (symbol != "") r['symbol'] = symbol;

      final checkStr = chainName == "" ? r['coin_name'].toString() : symbol;
      final isAdd = checkSymbol(
        r['contract'].toString().toUpperCase(),
        checkStr,
      );
      r['isAdd'] = isAdd;
      r['edit'] = false;

      if (isAdd) {
        final chainMap = chains[checkStr.toUpperCase()];
        final baseInfo =
            (chainMap?['baseInfo'] as Map?)?.cast<String, dynamic>() ??
            const {};
        r['canEdit'] = chainMap == null
            ? false
            : (chainName != "" || baseInfo['canEdit'] == true);
        coinlist.insert(0, r);
      } else {
        r['canEdit'] = true;
        coinlist.add(r);
      }

      final coins = r['coins'] as List<dynamic>?;
      if (coins != null) {
        coinDeal(
          coins,
          chains,
          rules: r['rules'],
          chainName: r['chain_name'],
          symbol: r['coin_name'],
        );
      }
    }
  }
}
