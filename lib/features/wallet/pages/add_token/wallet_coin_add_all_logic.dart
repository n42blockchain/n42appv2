part of 'wallet_coin_add_all.dart';

/// Business logic methods for [_WalletCoinAddAllState].
///
/// Contains: coin/token CRUD operations, search, address validation,
/// contract lookup, import, and navigation helpers.
extension _WalletCoinAddAllLogic on _WalletCoinAddAllState {
  void setNetworkIndex(int value, String name) {
    if (importType == 0) {
      if (value == networkIndex) return;
      setState(() {
        networkIndex = value;
        networkName = name;
      });
      seachCoin();
    } else {
      if (value == networkIndexToken) return;
      setState(() {
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

  /*添加主链币
  showList 是否显示在列表中
  * */
  Future<void> addCoin(Map<String, dynamic> chainMap, {bool showList = true}) async {
    try {
      setState(() {
        chainMap['edit'] = true;
      });
      Map<String, dynamic>? chainInfoMap =
      netChains[chainMap['coin_name'].toString().toUpperCase()];
      chainInfoMap ??= dealChain(chainMap);
      if (chainInfoMap == null) {
        ToastUtils.show(S.of(context).g_key_3);
        setState(() {
          chainMap['edit'] = false;
        });
      } else {
        WalletActionProvider wap = ref.read(wapBridgeProvider);
        chainInfoMap['showList'] = showList;
        /*if(showList){
          wap.coinSortAdd1();
          chainInfoMap['sort']= wap.coinSort["sortIndex"];
        }else{
          chainInfoMap['sort']=0;
        }*/
        addSymbol =
        '$addSymbol,${chainMap['coin_name'].toString().toLowerCase()}';
        await wap.addWalletChain(chainInfoMap);
        chains = wap.walletMap;
        setState(() {
          chainMap['isAdd'] = true;
          chainMap['edit'] = false;
        });
      }
    } catch (e) {
      ToastUtils.show(e.toString());
      setState(() {
        chainMap['edit'] = false;
      });
    } finally {
      isEdit = true;
    }
  }

  Future<void> addCoinToken(Map<String, dynamic> coinMap) async {
    try {
      if (coinMap['edit'] == true) return;
      setState(() {
        coinMap['edit'] = true;
      });
      String symbolStr = coinMap['symbol'].toString().toUpperCase();
      Map<String, dynamic>? chain = chains![symbolStr];
      if (chain == null) {
        Map<String, dynamic>? cIndex = await coinlist.firstWhere((element) {
          if (element['contract'] == "") {
            if (element['coin_name'].toString().toUpperCase() == symbolStr) {
              return true;
            }
          }
          return false;
        });
        if (cIndex != null) {
          await addCoin(cIndex, showList: false);
        }
      }
      if (!mounted) return;
      chain = chains![symbolStr];
      WalletActionProvider wap = ref.read(wapBridgeProvider);
      String baseTokenStr = json.encode(chain!['baseInfo']);
      Map<String, dynamic> baseToken = json.decode(baseTokenStr);
      baseToken['isContract'] = true;
      baseToken['contract'] = coinMap['contract'].toString();
      baseToken['contract_test'] = "";
      baseToken['balance'] = "0";
      baseToken['balance_test'] = "0";
      baseToken['coinPrice'] = 0.0;
      baseToken['percentage'] = 0.0;
      baseToken['icon'] = coinMap['icon'];
      baseToken['name'] = coinMap['fullname'];
      baseToken['miniName'] = coinMap['coin_name'].toString();
      baseToken['mKey'] = coinMap['contract'].toString().toUpperCase();
      baseToken['unit'] = coinMap['coin_name'].toString();
      baseToken['customer'] = false; //是否时用户自定义添加
      baseToken['decimals'] = coinMap['decimals'];
      baseToken['canEdit']=true;
      addSymbol = '$addSymbol,${coinMap['coin_name'].toString()}';
      wap.addWalletChainToken(baseToken);
      setState(() {
        coinMap['isAdd'] = true;
        coinMap['edit'] = false;
      });
    } catch (e) {
      ToastUtils.show(e.toString());
      setState(() {
        coinMap['edit'] = false;
      });
    } finally {
      isEdit = true;
    }
  }

  Future<void> removeCoin(Map<String, dynamic> chainMap) async {
    try {
      if (chainMap['edit'] == true) return;
      setState(() {
        chainMap['edit'] = true;
      });
      WalletActionProvider wap = ref.read(wapBridgeProvider);
      Map<String, dynamic> walletMap = wap.walletMap;
      List<String> walletMapKeys = walletMap.keys.toList();
      int keyIndex = -1;
      for (int i = 0; i < walletMapKeys.length; i++) {
        String key = walletMapKeys[i].toUpperCase();
        String removeKey = chainMap['coin_name'].toString().toUpperCase();
        if (removeKey == key) {
          keyIndex = i;
          break;
        }
      }

      if (keyIndex != -1) {
        String unit = chainMap['coin_name'].toString().toLowerCase();
        if (chainMap['unit'] != "") {
          unit = chainMap['unit'].toString().toLowerCase();
        }
        addSymbol =
            addSymbol.replaceFirst(',${chainMap['coin_name'].toString()}', '');
        wap.removeWalletChain(walletMapKeys[keyIndex], unit);
        chainMap['isAdd'] = false;
      } else {
        ToastUtils.show(S.of(context).g_key_1);
      }
      setState(() {
        chainMap['edit'] = false;
      });
    } catch (e) {
      ToastUtils.show(e.toString());
      setState(() {
        chainMap['edit'] = false;
      });
    } finally {
      isEdit = true;
    }
  }

  Future<void> removeCoinToken(Map<String, dynamic> coinMap) async {
    try {
      if (coinMap['edit'] == true) return;
      setState(() {
        coinMap['edit'] = true;
      });
      String symbolStr = coinMap['symbol'].toString();
      WalletActionProvider wap = ref.read(wapBridgeProvider);
      if (wap.walletMap[symbolStr.toUpperCase()]['mainnets'].length == 0) {
        setState(() {
          coinMap['isAdd'] = false;
          coinMap['edit'] = false;
        });
        return;
      }
      addSymbol = addSymbol.replaceFirst(',${coinMap['coin_name']}', '');
      wap.removeWalletChainToken(coinMap);
      setState(() {
        coinMap['isAdd'] = false;
        coinMap['edit'] = false;
      });
    } catch (e) {
      ToastUtils.show(e.toString());
      setState(() {
        coinMap['edit'] = false;
      });
    } finally {
      isEdit = true;
    }
  }

//查询方法
  Future<void> seachCoin() async {
    if (inputEditingController.text != "" || networkIndex != -1) {
      try {
        coinlistSeach = [];
        String inputStr = inputEditingController.text.toLowerCase();
        /*if (inputStr == "ast") {
          inputStr = "  ";
        }
        if (inputStr == "ast") {
          inputStr = "ast";
        }*/
        for (Map<String, dynamic> m in coinlist) {
          if (networkName != "" && networkName != m['chain_name']) {
            continue;
          }
          String symbolStr = m['coin_name'].toString().toLowerCase();
          int fullnameIndex = m['fullname'].toString().toLowerCase().indexOf(inputStr);
          int symbolIndex = symbolStr.indexOf(inputStr);
          if (symbolIndex != -1 || fullnameIndex != -1) {
            coinlistSeach.add(m);
          }
        }
      } catch (e) {
        ToastUtils.show(e.toString());
      }
    }
    setState(() {});
  }

  //检查转账地址是否正确
  Future<bool> addressCheck(String addr) async {
    if (addr == "") {
      tokenErrorMessage = S.of(context).g_key_41;
      return false;
    } else {
      List<String> cKeys = chainsToken.keys.toList();
      String coinType =
      chainsToken[cKeys[networkIndexToken]]["baseInfo"]['coinType'];
      bool check = await Trustdart().validateAddress(coinType, addr);
      if (check) {
        tokenErrorMessage = "";
        return true;
      } else {
        tokenErrorMessage = S.current.g_key_t_50;
        return false;
      }
    }
  }

  void scanQR() async {
    String? scanValue = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ScanPage()));
    if (scanValue != null) {
      tokenEditingController.text = scanValue;
      addressCheck(scanValue);
      setState(() {});
    }
  }

  // ── 合约地址自动校验 ──────────────────────────────────────────

  /// 用户输入合约地址时触发（带 800ms 防抖）。
  void _onContractAddressChanged(String value) {
    _contractDebounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() { _contractState = ''; _contractHint = ''; });
      return;
    }
    _contractDebounce = Timer(const Duration(milliseconds: 800), () {
      _lookupContractInfo(value.trim());
    });
  }

  /// 查询合约信息：先从本地 coinlist 匹配，再尝试链上 eth_call。
  Future<void> _lookupContractInfo(String address) async {
    if (!mounted) return;

    // 1. 地址格式校验
    final List<String> cKeys = chainsToken.keys.toList();
    if (cKeys.isEmpty) return;
    final coinType = chainsToken[cKeys[networkIndexToken]]['baseInfo']['coinType'] as String;
    final validAddr = await Trustdart().validateAddress(coinType, address);
    if (!validAddr) {
      setState(() { _contractState = 'error'; _contractHint = ''; });
      return;
    }

    setState(() { _contractState = 'loading'; _contractHint = ''; });

    // 2. 从 coinlist 匹配（已知代币，无需链上查询）
    final chainMiniName = chainsToken[cKeys[networkIndexToken]]['baseInfo']['miniName']
        .toString().toUpperCase();
    final knownIdx = coinlist.indexWhere((e) {
      if ((e['contract'] ?? '').toString().isEmpty) return false;
      if (e['coin_name'].toString().toUpperCase() != chainMiniName &&
          (e['symbol'] ?? '').toString().toUpperCase() != chainMiniName) {
        // 允许按合约地址匹配，不限链
      }
      return e['contract'].toString().toLowerCase() == address.toLowerCase();
    });

    if (knownIdx != -1) {
      final found = coinlist[knownIdx];
      final sym = found['coin_name']?.toString() ?? '';
      final dec = found['decimals']?.toString() ?? '18';
      final name = found['fullname']?.toString() ?? sym;
      if (mounted) {
        symbolEditingController.text = sym;
        decimalEditingController.text = dec;
        setState(() {
          _contractState = 'found';
          _contractHint = '$name · $dec decimals';
          symbolErrorMessage = '';
          decimalErrorMessage = '';
        });
      }
      return;
    }

    // 3. 链上查询（仅支持 EVM 链）
    final blockchainType = chainsToken[cKeys[networkIndexToken]]['baseInfo']['blockchainType'];
    if (blockchainType == 'Ethereum') {
      final rpcUrl = chainsToken[cKeys[networkIndexToken]]['baseInfo']['service']?.toString() ?? '';
      if (rpcUrl.isNotEmpty) {
        final info = await EthAPI.getErc20TokenInfo(address, rpcUrl);
        if (!mounted) return;
        if (info != null) {
          symbolEditingController.text = info.symbol;
          decimalEditingController.text = info.decimals.toString();
          setState(() {
            _contractState = 'found';
            _contractHint = '${info.name.isNotEmpty ? info.name : info.symbol} · ${info.decimals} decimals';
            symbolErrorMessage = '';
            decimalErrorMessage = '';
          });
          return;
        }
      }
    }

    // 4. 未找到 → 提示用户手动填写
    if (mounted) {
      setState(() { _contractState = 'notFound'; _contractHint = ''; });
    }
  }

  Future<void> importButton() async {
    bool c = await checkTokenInput();
    if (c == false) return;
    setState(() {
      load = Load.loading;
    });
    String tokenAddress = tokenEditingController.text;
    Map<String, dynamic> chain =
    chainsToken[chainsToken.keys.toList()[networkIndexToken]];
    String symbolStr = chain['baseInfo']['miniName'].toString().toUpperCase();
    int cIndex = coinlist.indexWhere((element) {
      if (element['contract'] == "") return false;
      if (element['coin_name'].toString().toUpperCase() != symbolStr) {
        return false;
      }
      if (element['contract'].toString().toLowerCase() ==
          tokenAddress.toLowerCase()) {
        return true;
      }
      return false;
    });
    if (cIndex != -1) {
      if (coinlist[cIndex]['isAdd']) {
        ToastUtils.show("Already exists");
      } else {
        await addCoinToken(coinlist[cIndex]);
        ToastUtils.show("Successfully added");
      }
      setState(() {
        load = Load.finish;
      });
      return;
    }
    Map? token;
    if (chain['isTest']) {
      token =
      chain['testnets'][0]['testnetContract'][tokenAddress.toUpperCase()];
    } else {
      token = chain['mainnets'][tokenAddress.toUpperCase()];
    }
    if (token != null) {
      ToastUtils.show("Already exists");
      setState(() {
        load = Load.finish;
      });
      return;
    }
    if (!mounted) return;
    WalletActionProvider wap = ref.read(wapBridgeProvider);
    String baseTokenStr = json.encode(chain['baseInfo']);
    Map<String, dynamic> baseToken = json.decode(baseTokenStr);
    baseToken['isContract'] = true;
    baseToken['contract'] = tokenAddress;
    baseToken['contract_test'] = "";
    baseToken['balance'] = "0";
    baseToken['balance_test'] = "0";
    baseToken['coinPrice'] = 0.0;
    baseToken['percentage'] = 0.0;
    baseToken['icon'] = "";
    baseToken['name'] = symbolEditingController.text;
    baseToken['miniName'] = symbolEditingController.text;
    baseToken['mKey'] = tokenAddress.toUpperCase();
    baseToken['unit'] = symbolEditingController.text;
    baseToken['decimals'] = int.parse(decimalEditingController.text);
    baseToken['customer'] = true; //是否是用户自定义添加
    baseToken['canEdit']=true;
    addSymbol = '$addSymbol,${symbolEditingController.text}';
    wap.addWalletChainToken(baseToken);
    init();
    ToastUtils.show("Successfully added");
    setState(() {
      load = Load.finish;
    });
  }

  Future<void> removeCustomerCoinToken(Map<String, dynamic> coinMap) async {
    try {
      if (coinMap['edit'] == true) return;
      setState(() {
        coinMap['edit'] = true;
      });
      String symbolStr = coinMap['coinType'].toString();
      WalletActionProvider wap = ref.read(wapBridgeProvider);
      if (wap.walletMap[symbolStr.toUpperCase()]['isTest']) {
        if (wap
            .walletMap[symbolStr.toUpperCase()]['testnets'][0]
        ['testnetContract']
            .length ==
            0) {
          setState(() {
            coinMap['edit'] = false;
          });
          return;
        }
      } else {
        if (wap.walletMap[symbolStr.toUpperCase()]['mainnets'].length == 0) {
          setState(() {
            coinMap['edit'] = false;
          });
          return;
        }
      }

      addSymbol = addSymbol.replaceFirst(',${coinMap['miniName']}', '');
      ref.read(wapBridgeProvider).removeWalletChainToken(coinMap,
          symbol: coinMap['coinType'], miniName: coinMap['miniName']);
      setState(() {
        coinMap['edit'] = false;
      });
      init();
    } catch (e) {
      ToastUtils.show(e.toString());
      setState(() {
        coinMap['edit'] = false;
      });
    } finally {
      isEdit = true;
    }
  }

  Future<bool> checkTokenInput() async {
    bool cOK = await addressCheck(tokenEditingController.text);
    if (cOK == false) return false;
    String symbol = symbolEditingController.text;
    if (symbol == "") {
      symbolErrorMessage = S.current.g_key_41;
      return false;
    }
    if (symbol.length > 10) {
      symbolErrorMessage = S.current.g_token_m_key_1(10);
      return false;
    }
    symbolErrorMessage = "";
    String decimals = decimalEditingController.text;
    if (decimals == "") {
      decimalErrorMessage = S.current.g_key_41;
      return false;
    }
    bool dOK = regular.regularNums(decimals);
    if (dOK == false) {
      decimalErrorMessage = S.current.g_token_m_key_2;
      return false;
    }
    int decimalsInt = int.parse(decimals);
    if (decimalsInt >= 0 && decimalsInt <= 18) {
      decimalErrorMessage = "";
    } else {
      decimalErrorMessage = S.current.g_token_m_key_2;
      return false;
    }
    return true;
  }

  //关闭键盘
  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<bool> _pageBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, isEdit ? true : false);
    } else {
      SystemNavigator.pop();
    }
    return Future.value(false);
  }
}
