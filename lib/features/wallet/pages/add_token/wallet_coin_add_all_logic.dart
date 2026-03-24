part of 'wallet_coin_add_all.dart';

/// Business logic methods for [_WalletCoinAddAllState].
///
/// Contains: coin/token CRUD operations, search, address validation,
/// contract lookup, import, and navigation helpers.
extension _WalletCoinAddAllLogic on _WalletCoinAddAllState {
  Map<String, dynamic>? _currentTokenBaseInfo() {
    final cKeys = chainsToken.keys.toList();
    if (cKeys.isEmpty) return null;
    if (networkIndexToken < 0 || networkIndexToken >= cKeys.length) return null;
    final chain = chainsToken[cKeys[networkIndexToken]];
    return (chain['baseInfo'] as Map?)?.cast<String, dynamic>();
  }

  void setNetworkIndex(int value, String name) {
    if (importType == 0) {
      if (value == networkIndex) return;
      updateView(() {
        networkIndex = value;
        networkName = name;
      });
      seachCoin();
    } else {
      if (value == networkIndexToken) return;
      updateView(() {
        networkIndexToken = value;
        networkNameToken = name;
      });
      setChainsTokenWithNetwork();
    }
  }

  void init() {
    chains = ref.read(wapBridgeProvider).walletMap;
    setChainsToken();
  }

  /// 添加主链币。[showList] 控制是否显示在列表中。
  Future<void> addCoin(Map<String, dynamic> chainMap, {bool showList = true}) async {
    try {
      updateView(() => chainMap['edit'] = true);
      Map<String, dynamic>? chainInfoMap =
          netChains[chainMap['coin_name'].toString().toUpperCase()];
        chainInfoMap ??= dealChain(chainMap);
      if (chainInfoMap == null) {
        ToastUtils.show(S.of(context).g_key_3);
        updateView(() => chainMap['edit'] = false);
      } else {
        final wap = ref.read(wapBridgeProvider);
        chainInfoMap['showList'] = showList;
        addSymbol = '$addSymbol,${chainMap['coin_name'].toString().toLowerCase()}';
        await wap.addWalletChain(chainInfoMap);
        chains = wap.walletMap;
        updateView(() {
          chainMap['isAdd'] = true;
          chainMap['edit'] = false;
        });
      }
    } catch (e) {
      ToastUtils.show(e.toString());
      updateView(() => chainMap['edit'] = false);
    } finally {
      isEdit = true;
    }
  }

  Future<void> addCoinToken(Map<String, dynamic> coinMap) async {
    try {
      if (coinMap['edit'] == true) return;
      updateView(() => coinMap['edit'] = true);
      final symbolStr = coinMap['symbol'].toString().toUpperCase();
      Map<String, dynamic>? chain = chains![symbolStr];
      if (chain == null) {
        final cIndex = coinlist.firstWhere(
          (e) => e['contract'] == "" && e['coin_name'].toString().toUpperCase() == symbolStr,
          orElse: () => null,
        );
        if (cIndex != null) await addCoin(cIndex, showList: false);
      }
      if (!mounted) return;
      chain = chains![symbolStr];
      if (chain == null) {
        ToastUtils.show('Missing parent chain configuration');
        updateView(() => coinMap['edit'] = false);
        return;
      }
      final wap = ref.read(wapBridgeProvider);
      final baseToken = _cloneBaseInfo(chain);
      baseToken['contract'] = coinMap['contract'].toString();
      baseToken['icon'] = coinMap['icon'];
      baseToken['name'] = coinMap['fullname'];
      baseToken['miniName'] = coinMap['coin_name'].toString();
      baseToken['mKey'] = coinMap['contract'].toString().toUpperCase();
      baseToken['unit'] = coinMap['coin_name'].toString();
      baseToken['customer'] = false; // 非用户自定义添加
      baseToken['decimals'] = coinMap['decimals'];
      addSymbol = '$addSymbol,${coinMap['coin_name'].toString()}';
      wap.addWalletChainToken(baseToken);
      updateView(() {
        coinMap['isAdd'] = true;
        coinMap['edit'] = false;
      });
    } catch (e) {
      ToastUtils.show(e.toString());
      updateView(() => coinMap['edit'] = false);
    } finally {
      isEdit = true;
    }
  }

  Future<void> removeCoin(Map<String, dynamic> chainMap) async {
    try {
      if (chainMap['edit'] == true) return;
      updateView(() => chainMap['edit'] = true);
      final wap = ref.read(wapBridgeProvider);
      final walletMapKeys = wap.walletMap.keys.toList();
      final removeKey = chainMap['coin_name'].toString().toUpperCase();
      final keyIndex = walletMapKeys.indexWhere((k) => k.toUpperCase() == removeKey);

      if (keyIndex != -1) {
        final unit = (chainMap['unit'] != "")
            ? chainMap['unit'].toString().toLowerCase()
            : chainMap['coin_name'].toString().toLowerCase();
        addSymbol = addSymbol.replaceFirst(',${chainMap['coin_name'].toString()}', '');
        wap.removeWalletChain(walletMapKeys[keyIndex], unit);
        chainMap['isAdd'] = false;
      } else {
        ToastUtils.show(S.of(context).g_key_1);
      }
      updateView(() => chainMap['edit'] = false);
    } catch (e) {
      ToastUtils.show(e.toString());
      updateView(() => chainMap['edit'] = false);
    } finally {
      isEdit = true;
    }
  }

  Future<void> removeCoinToken(Map<String, dynamic> coinMap) async {
    try {
      if (coinMap['edit'] == true) return;
      updateView(() => coinMap['edit'] = true);
      final symbolStr = coinMap['symbol'].toString();
      final wap = ref.read(wapBridgeProvider);
      if (wap.walletMap[symbolStr.toUpperCase()]['mainnets'].length == 0) {
        updateView(() {
          coinMap['isAdd'] = false;
          coinMap['edit'] = false;
        });
        return;
      }
      addSymbol = addSymbol.replaceFirst(',${coinMap['coin_name']}', '');
      wap.removeWalletChainToken(coinMap);
      updateView(() {
        coinMap['isAdd'] = false;
        coinMap['edit'] = false;
      });
    } catch (e) {
      ToastUtils.show(e.toString());
      updateView(() => coinMap['edit'] = false);
    } finally {
      isEdit = true;
    }
  }

  Future<void> seachCoin() async {
    if (inputEditingController.text.isNotEmpty || networkIndex != -1) {
      try {
        coinlistSeach = [];
        final inputStr = inputEditingController.text.toLowerCase();
        for (final m in coinlist) {
          if (networkName != "" && networkName != m['chain_name']) continue;
          final symbol = m['coin_name'].toString().toLowerCase();
          final fullname = m['fullname'].toString().toLowerCase();
          if (symbol.contains(inputStr) || fullname.contains(inputStr)) {
            coinlistSeach.add(m);
          }
        }
      } catch (e) {
        ToastUtils.show(e.toString());
      }
    }
    updateView();
  }

  Future<bool> addressCheck(String addr) async {
    if (addr.isEmpty) {
      tokenErrorMessage = S.of(context).g_key_41;
      return false;
    }
    final baseInfo = _currentTokenBaseInfo();
    final coinType = baseInfo?['coinType']?.toString() ?? '';
    if (coinType.isEmpty) {
      tokenErrorMessage = 'Invalid chain configuration';
      return false;
    }
    final check = await Trustdart().validateAddress(coinType, addr);
    tokenErrorMessage = check ? "" : S.current.g_key_t_50;
    return check;
  }

  void scanQR() async {
    String? scanValue = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ScanPage()));
    if (scanValue != null) {
      tokenEditingController.text = scanValue;
      addressCheck(scanValue);
      updateView();
    }
  }

  // ── 合约地址自动校验 ──────────────────────────────────────────

  /// 用户输入合约地址时触发（带 800ms 防抖）。
  void _onContractAddressChanged(String value) {
    _contractDebounce?.cancel();
    if (value.trim().isEmpty) {
      updateView(() {
        _contractState = '';
        _contractHint = '';
      });
      return;
    }
    _contractDebounce = Timer(const Duration(milliseconds: 800), () {
      _lookupContractInfo(value.trim());
    });
  }

  /// 查询合约信息：先从本地 coinlist 匹配，再尝试链上 eth_call。
  Future<void> _lookupContractInfo(String address) async {
    if (!mounted) return;
    final baseInfo = _currentTokenBaseInfo();
    final coinType = baseInfo?['coinType']?.toString() ?? '';
    if (baseInfo == null || coinType.isEmpty) {
      updateView(() {
        _contractState = 'error';
        _contractHint = '';
      });
      return;
    }

    // 1. 地址格式校验
    if (!await Trustdart().validateAddress(coinType, address)) {
      updateView(() {
        _contractState = 'error';
        _contractHint = '';
      });
      return;
    }
    updateView(() {
      _contractState = 'loading';
      _contractHint = '';
    });

    // 2. 从 coinlist 匹配（已知代币，无需链上查询）
    final knownIdx = coinlist.indexWhere((e) {
      if ((e['contract'] ?? '').toString().isEmpty) return false;
      return e['contract'].toString().toLowerCase() == address.toLowerCase();
    });
    if (knownIdx != -1) {
      _applyFoundToken(coinlist[knownIdx]);
      return;
    }

    // 3. 链上查询（仅支持 EVM 链）
    if (baseInfo['blockchainType']?.toString() == 'Ethereum') {
      final rpcUrl = baseInfo['service']?.toString() ?? '';
      if (rpcUrl.isNotEmpty) {
        final info = await EthAPI.getErc20TokenInfo(address, rpcUrl);
        if (!mounted) return;
        if (info != null) {
          symbolEditingController.text = info.symbol;
          decimalEditingController.text = info.decimals.toString();
          final displayName = info.name.isNotEmpty ? info.name : info.symbol;
          updateView(() {
            _contractState = 'found';
            _contractHint = '$displayName · ${info.decimals} decimals';
            symbolErrorMessage = '';
            decimalErrorMessage = '';
          });
          return;
        }
      }
    }

    // 4. 未找到
    if (mounted) {
      updateView(() {
        _contractState = 'notFound';
        _contractHint = '';
      });
    }
  }

  /// 从 coinlist 匹配结果填充表单字段。
  void _applyFoundToken(Map<String, dynamic> found) {
    if (!mounted) return;
    final sym = found['coin_name']?.toString() ?? '';
    final dec = found['decimals']?.toString() ?? '18';
    final name = found['fullname']?.toString() ?? sym;
    symbolEditingController.text = sym;
    decimalEditingController.text = dec;
    updateView(() {
      _contractState = 'found';
      _contractHint = '$name · $dec decimals';
      symbolErrorMessage = '';
      decimalErrorMessage = '';
    });
  }

  Future<void> importButton() async {
    if (!await checkTokenInput()) return;
    updateView(() => load = Load.loading);
    final tokenAddress = tokenEditingController.text;
    final cKeys = chainsToken.keys.toList();
    if (networkIndexToken < 0 || networkIndexToken >= cKeys.length) {
      ToastUtils.show('Invalid chain configuration');
      updateView(() => load = Load.finish);
      return;
    }
    final chain =
        (chainsToken[cKeys[networkIndexToken]] as Map?)?.cast<String, dynamic>();
    final baseInfo = (chain?['baseInfo'] as Map?)?.cast<String, dynamic>();
    final symbolStr =
        (baseInfo?['miniName'] ?? baseInfo?['coinType'] ?? '').toString().toUpperCase();
    if (chain == null || baseInfo == null || symbolStr.isEmpty) {
      ToastUtils.show('Invalid chain configuration');
      updateView(() => load = Load.finish);
      return;
    }

    // 检查 coinlist 中是否已存在
    final cIndex = coinlist.indexWhere((e) =>
        e['contract'] != "" &&
        e['coin_name'].toString().toUpperCase() == symbolStr &&
        e['contract'].toString().toLowerCase() == tokenAddress.toLowerCase());
    if (cIndex != -1) {
      if (coinlist[cIndex]['isAdd']) {
        ToastUtils.show("Already exists");
      } else {
        await addCoinToken(coinlist[cIndex]);
        ToastUtils.show("Successfully added");
      }
      updateView(() => load = Load.finish);
      return;
    }

    // 检查钱包中是否已存在
    final token = chain['isTest']
        ? chain['testnets'][0]['testnetContract'][tokenAddress.toUpperCase()]
        : chain['mainnets'][tokenAddress.toUpperCase()];
    if (token != null) {
      ToastUtils.show("Already exists");
      updateView(() => load = Load.finish);
      return;
    }
    if (!mounted) return;

    final wap = ref.read(wapBridgeProvider);
    final baseToken = _cloneBaseInfo(chain);
    baseToken['contract'] = tokenAddress;
    baseToken['icon'] = "";
    baseToken['name'] = symbolEditingController.text;
    baseToken['miniName'] = symbolEditingController.text;
    baseToken['mKey'] = tokenAddress.toUpperCase();
    baseToken['unit'] = symbolEditingController.text;
    baseToken['decimals'] = int.parse(decimalEditingController.text);
    baseToken['customer'] = true; // 用户自定义添加
    addSymbol = '$addSymbol,${symbolEditingController.text}';
    wap.addWalletChainToken(baseToken);
    init();
    ToastUtils.show("Successfully added");
    updateView(() => load = Load.finish);
  }

  Future<void> removeCustomerCoinToken(Map<String, dynamic> coinMap) async {
    try {
      if (coinMap['edit'] == true) return;
      updateView(() => coinMap['edit'] = true);
      final symbolStr = coinMap['coinType'].toString().toUpperCase();
      final wap = ref.read(wapBridgeProvider);
      final chainData = wap.walletMap[symbolStr];
      final hasTokens = chainData['isTest']
          ? (chainData['testnets'][0]['testnetContract'].length > 0)
          : (chainData['mainnets'].length > 0);
      if (!hasTokens) {
        updateView(() => coinMap['edit'] = false);
        return;
      }
      addSymbol = addSymbol.replaceFirst(',${coinMap['miniName']}', '');
      wap.removeWalletChainToken(coinMap,
          symbol: coinMap['coinType'], miniName: coinMap['miniName']);
      updateView(() => coinMap['edit'] = false);
      init();
    } catch (e) {
      ToastUtils.show(e.toString());
      updateView(() => coinMap['edit'] = false);
    } finally {
      isEdit = true;
    }
  }

  Future<bool> checkTokenInput() async {
    if (!await addressCheck(tokenEditingController.text)) return false;
    final symbol = symbolEditingController.text;
    if (symbol.isEmpty) { symbolErrorMessage = S.current.g_key_41; return false; }
    if (symbol.length > 10) { symbolErrorMessage = S.current.g_token_m_key_1(10); return false; }
    symbolErrorMessage = "";
    final decimals = decimalEditingController.text;
    if (decimals.isEmpty) { decimalErrorMessage = S.current.g_key_41; return false; }
    if (!regular.regularNums(decimals)) { decimalErrorMessage = S.current.g_token_m_key_2; return false; }
    final decimalsInt = int.parse(decimals);
    if (decimalsInt < 0 || decimalsInt > 18) { decimalErrorMessage = S.current.g_token_m_key_2; return false; }
    decimalErrorMessage = "";
    return true;
  }

  void closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<bool> _pageBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, isEdit);
    } else {
      SystemNavigator.pop();
    }
    return Future.value(false);
  }

  /// 深拷贝 chain baseInfo 并设置 token 公共默认值。
  Map<String, dynamic> _cloneBaseInfo(Map<String, dynamic> chain) {
    final baseInfo = (chain['baseInfo'] as Map?)?.cast<String, dynamic>() ?? const {};
    final baseToken = json.decode(json.encode(baseInfo)) as Map<String, dynamic>;
    baseToken['isContract'] = true;
    baseToken['contract_test'] = "";
    baseToken['balance'] = "0";
    baseToken['balance_test'] = "0";
    baseToken['coinPrice'] = 0.0;
    baseToken['percentage'] = 0.0;
    baseToken['canEdit'] = true;
    return baseToken;
  }
}
