import 'dart:convert';

import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/component/pages/scan_page.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';

class WalletCoinAddAll extends ConsumerStatefulWidget {
  final String? coinType;
  final String seachStr;
  const WalletCoinAddAll(this.seachStr,{this.coinType,super.key});

  @override
  ConsumerState<WalletCoinAddAll> createState() => _WalletCoinAddAllState();
}

class _WalletCoinAddAllState extends ConsumerState<WalletCoinAddAll> {
  Regular? _regular;
  Regular get regular{
    _regular ??= Regular();
    return _regular!;
  }
  TextEditingController inputEditingController = TextEditingController();
  TextEditingController tokenEditingController = TextEditingController();
  TextEditingController symbolEditingController = TextEditingController();
  TextEditingController decimalEditingController = TextEditingController();
  FocusNode tokenFocusNode = FocusNode();
  FocusNode symbolFocusNode = FocusNode();
  FocusNode decimalFocusNode = FocusNode();
  int importType = 0; //导入token类型 0，1
  bool showImportWidget = false;
  List<dynamic> coinlist = [];
  List<dynamic> coinlistSeach = [];
  List<dynamic> coinlistToken = [];
  Load load = Load.finish;

  //List<String> symbols=[];
  String addSymbol = ""; //添加的主链币
  bool isEdit = false;
  late Map<String, dynamic> chainsToken;
  Map<String, dynamic>? chains; //现有的主链币
  Map<String, dynamic> netChains = {}; //api获取的主链币
  //int sort=0;//当前列表中最后一个币的sort
  int networkIndex = -1;
  String networkName = "";
  int networkIndexToken = 0;
  String networkNameToken = "";

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

  String tokenErrorMessage = "";
  String symbolErrorMessage = "";
  String decimalErrorMessage = "";

  @override
  void initState() {
    getChainList();
    inputEditingController.text = widget.seachStr;
    init();
    super.initState();
  }

  @override
  void dispose() {
    inputEditingController.dispose();
    tokenEditingController.dispose();
    symbolEditingController.dispose();
    decimalEditingController.dispose();
    tokenFocusNode.dispose();
    symbolFocusNode.dispose();
    decimalFocusNode.dispose();
    super.dispose();
  }

  void init() {
    chains = ref.read(wapBridgeProvider).walletMap;
    setChainsToken();
  }

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
    }
    setState(() {
      load = Load.finish;
    });
    if (inputEditingController.text != "") {
      seachCoin();
    }
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

  void scanQR() async {
    String? scanValue = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ScanPage()));
    if (scanValue != null) {
      tokenEditingController.text = scanValue;
      addressCheck(scanValue);
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pageBack();
      },
      child: Scaffold(
        backgroundColor:
        AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context).g_token_m_key_3,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(32.0),
                ),
              ),
              InkWell(
                onTap: () {
                  showChangeNetwork();
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        importType == 0
                            ? (networkName == ""
                            ? S.of(context).g_token_m_key_4
                            : networkName)
                            : networkNameToken,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainBlueColor.name),
                          fontSize: ScreenUtil().setSp(30.0),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_sharp,
                        size: ScreenUtil().setWidth(40.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
          actions: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(30.0)),
              child: SizedBox(
                height: ScreenUtil().setWidth(40.0),
                width: ScreenUtil().setWidth(40.0),
                child: load == Load.loading
                    ? CircularProgressIndicator()
                    : SizedBox(),
              ),
            )
          ],
        ),
        body: SafeArea(
          child: InkWell(
            onTap: () {
              closeKeyboard();
            },
            child: Column(
              children: [
                tagWidget(),
                Expanded(
                  flex: 1,
                  child: Stack(
                    children: [
                      Positioned(
                        top: ScreenUtil().setWidth(10.0),
                        left: ScreenUtil().setWidth(30.0),
                        right: ScreenUtil().setWidth(30.0),
                        bottom: ScreenUtil().setWidth(36.0),
                        child: Visibility(
                          visible: importType == 0,
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(20.0)),
                                margin: EdgeInsets.symmetric(
                                    vertical: ScreenUtil().setWidth(20.0)),
                                /*constraints: BoxConstraints(
                        minHeight: scr.setWidth(100.0),
                      ),*/
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(ScreenUtil().setWidth(20.0))),
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.itemBgColor.name),
                                ),
                                constraints: BoxConstraints(
                                  minHeight: ScreenUtil().setWidth(100.0),
                                  maxHeight: ScreenUtil().setWidth(100.0),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        controller: inputEditingController,
                                        style: TextStyle(
                                          color: AppThemeUtils.getColorByKey(
                                              context,
                                              AppThemeKeys.mainTextColor.name),
                                          fontSize: ScreenUtil().setWidth(30.0),
                                        ),
                                        textInputAction: TextInputAction.search,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: ScreenUtil().setWidth(26.0)),
                                          isCollapsed: true,
                                          hintText: S.of(context).g_key_163,
                                          hintStyle: TextStyle(
                                            fontSize: ScreenUtil().setWidth(30.0),
                                            color: AppThemeUtils.getColorByKey(
                                                context,
                                                AppThemeKeys
                                                    .itemSubtitleTextColor.name),
                                          ),
                                          border: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                        onChanged: (String value) {},
                                        onSubmitted: (value) {
                                          seachCoin();
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        closeKeyboard();
                                        seachCoin();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: ScreenUtil().setWidth(20.0),
                                        ),
                                        height: ScreenUtil().setWidth(60.0),
                                        decoration: BoxDecoration(
                                          color: AppThemeUtils.getColorByKey(
                                              context,
                                              AppThemeKeys.mainButtonBgColor.name),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  ScreenUtil().setWidth(60.0))),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          S.of(context).search,
                                          style: TextStyle(
                                            fontSize: ScreenUtil().setSp(26.0),
                                            color: AppThemeUtils.getColorByKey(
                                                context,
                                                AppThemeKeys
                                                    .mainButtonTextColor.name),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: coinListWidget(),
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: ScreenUtil().setWidth(10.0),
                        left: ScreenUtil().setWidth(30.0),
                        right: ScreenUtil().setWidth(30.0),
                        bottom: ScreenUtil().setWidth(36.0),
                        child: Visibility(
                          visible: importType == 1,
                          child: coinListTokenWidget(),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tagWidget() {
    return Container(
      height: ScreenUtil().setWidth(100.0),
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: ScreenUtil().setWidth(1.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemBorderColor.name)))),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                if (importType == 0) return;
                setState(() {
                  importType = 0;
                });
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                          width: ScreenUtil().setWidth(2.0),
                          color: importType == 0
                              ? AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainBlueColor.name)
                              : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
                        ))),
                child: Text(
                  S.of(context).search,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context,
                        importType == 0
                            ? AppThemeKeys.mainBlueColor.name
                            : AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setWidth(30.0),
                    fontWeight: importType == 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                if (importType == 1) return;
                setState(() {
                  importType = 1;
                });
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                          width: ScreenUtil().setWidth(2.0),
                          color: importType == 1
                              ? AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainBlueColor.name)
                              : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
                        ))),
                child: Text(
                  S.of(context).g_token_m_key_5,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context,
                        importType == 1
                            ? AppThemeKeys.mainBlueColor.name
                            : AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setWidth(30.0),
                    fontWeight: importType == 1 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget addressWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_token_m_key_6,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(10.0),
            ),
            margin: EdgeInsets.only(
              top: ScreenUtil().setWidth(20.0),
            ),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
            ),
            height: ScreenUtil().setWidth(88.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setWidth(30.0),
                    ),
                    controller: tokenEditingController,
                    focusNode: tokenFocusNode,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: S.of(context).g_key_155,
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
                    ),
                    maxLines: 1,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(symbolFocusNode);
                      addressCheck(tokenEditingController.text);
                      setState(() {});
                    },
                  ),
                ),
                InkWell(
                  onTap: scanQR,
                  child: Container(
                    width: ScreenUtil().setWidth(60.0),
                    height: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(8.0)),
                    child: Image.asset(
                      "assets/wallet/scan.png",
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    ClipboardData? cd =
                    await Clipboard.getData(Clipboard.kTextPlain);
                    if (cd != null) {
                      if (cd.text != null && cd.text != "null") {
                        tokenEditingController.text = cd.text!;
                        addressCheck(cd.text!);
                        setState(() {});
                      }
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
                    height: ScreenUtil().setWidth(60.0),
                    padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
                    decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                      borderRadius: BorderRadius.all(Radius.circular(
                        ScreenUtil().setWidth(60.0),
                      )),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      S.of(context).g_key_166,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainWhiteColor.name),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (tokenErrorMessage != "")
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                tokenErrorMessage,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.errorTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget symbolWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_token_m_key_7,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(28.0),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(30.0),
            right: ScreenUtil().setWidth(10.0),
          ),
          margin: EdgeInsets.only(
            top: ScreenUtil().setWidth(20.0),
          ),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemBgColor.name),
          ),
          height: ScreenUtil().setWidth(88.0),
          child: TextField(
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setWidth(30.0),
            ),
            controller: symbolEditingController,
            focusNode: symbolFocusNode,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: S.of(context).g_token_m_key_7,
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isCollapsed: true,
              contentPadding:
              EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
            ),
            maxLines: 1,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(decimalFocusNode);
            },
          ),
        ),
        if (symbolErrorMessage != "")
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              symbolErrorMessage,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.errorTextColor.name),
                fontSize: ScreenUtil().setSp(24.0),
              ),
            ),
          ),
      ],
    );
  }

  Widget decimalWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_token_m_key_8,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(10.0),
            ),
            margin: EdgeInsets.only(
              top: ScreenUtil().setWidth(20.0),
            ),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
            ),
            height: ScreenUtil().setWidth(88.0),
            child: TextField(
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setWidth(30.0),
              ),
              controller: decimalEditingController,
              focusNode: decimalFocusNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: S.of(context).g_token_m_key_8,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding:
                EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
              ),
              maxLines: 1,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(tokenFocusNode);
              },
            ),
          ),
          if (decimalErrorMessage != "")
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                decimalErrorMessage,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.errorTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget addButtonWidget() {
    return SizedBox(
      height: ScreenUtil().setWidth(88.0),
      width: double.infinity,
      child: buttonStyle6(
        context,
            () {
          setState(() {
            showImportWidget = true;
          });
        },
        S.of(context).g_key_159,
        AppThemeUtils.getColorByKey(
            context,
            load == Load.loading
                ? AppThemeKeys.mainButtonBgColor3.name
                : AppThemeKeys.mainButtonBgColor.name),
        AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainButtonTextColor.name),
        load == Load.loading,
      ),
    );
  }

  Widget importButtonWidget() {
    return SizedBox(
      height: ScreenUtil().setWidth(88.0),
      width: double.infinity,
      child: Row(
        children: [
          if (showImportWidget)
            Expanded(
              flex: 1,
              child: SizedBox(
                height: ScreenUtil().setWidth(88.0),
                //44 / 375 *  MediaQuery.of(context).size.width,
                child: buttonStyle5(
                  context,
                      () {
                    setState(() {
                      showImportWidget = false;
                    });
                  },
                  S.of(context).g_key_79,
                  AppThemeUtils.getColorByKey(
                      context,
                      load == Load.loading
                          ? AppThemeKeys.mainButtonBgColor3.name
                          : AppThemeKeys.mainButtonBgColor.name),
                  AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainButtonTextColor.name),
                ),
              ),
            ),
          if (showImportWidget)
            SizedBox(
              width: ScreenUtil().setWidth(30.0),
            ),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: ScreenUtil().setWidth(88.0),
              //44 / 375 *  MediaQuery.of(context).size.width,
              child: buttonStyle6(
                context,
                    () {
                  importButton();
                },
                S.of(context).g_token_m_key_9,
                AppThemeUtils.getColorByKey(
                    context,
                    load == Load.loading
                        ? AppThemeKeys.mainButtonBgColor3.name
                        : AppThemeKeys.mainButtonBgColor.name),
                AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonTextColor.name),
                load == Load.loading,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget coinListWidget() {
    if (inputEditingController.text == "" && networkIndex == -1) {
      return RefreshIndicator(
        onRefresh: () async {
          if (load == Load.finish) await getChainList();
        },
        backgroundColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainButtonBgColor.name),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainButtonTextColor.name),
        displacement: ScreenUtil().setWidth(72.0),
        child: ListView.builder(
          itemCount: coinlist.length,
          itemBuilder: (context, int index) {
            Map<String, dynamic> rowValue = coinlist[index];
            if(rowValue['unit'] ==null || rowValue['unit'] ==""){
              return coinItem(rowValue);
            }else{
              if(rowValue['unit'].toString().toUpperCase() == rowValue['coin_name'].toString().toUpperCase()){
                return coinItem(rowValue);
              }else{
                return SizedBox();
              }
            }

          },
          /*separatorBuilder: (context, int index) {
            return Divider(
              height: ScreenUtil().setWidth(1.0),
              indent: 0,
              endIndent: 0,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
            );
          },*/
        ),
      );
    } else {
      if (coinlistSeach.isEmpty) return const EmptyView();
      return ListView.builder(
        itemCount: coinlistSeach.length,
        itemBuilder: (context, int index) {
          Map<String, dynamic> rowValue = coinlistSeach[index];
          if(rowValue['unit'] ==null || rowValue['unit'] ==""){
            return coinItem(rowValue);
          }else{
            if(rowValue['unit'].toString().toUpperCase() == rowValue['coin_name'].toString().toUpperCase()){
              return coinItem(rowValue);
            }else{
              return SizedBox();
            }
          }
        },
        /*separatorBuilder: (context, int index) {
          return Divider(
            height: ScreenUtil().setWidth(1.0),
            indent: 0,
            endIndent: 0,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
          );
        },*/
      );
    }
  }

  Widget coinItem(Map<String, dynamic> rowValue) {
    String icon='https://api-wallet.walletamaze.com/market/v1/r/coinImage/${rowValue['fullname']}.png';
    String fullname = rowValue['fullname'];
    if(fullname=="LoveCoin"){
      icon=rowValue['icon'];
    }else if(fullname=="Base"){
      icon="${AppConfig.apiUrl['walletamazeBrowser']}/static/${rowValue['coin_name']}.png";
    }
    String symbol = rowValue['coin_name'].toString();
    Widget imgWidget = ImageNetWork(imageUrl:
        icon,
      placeholder: "assets/img/list_default.png",
    );
    /*if (rowValue['fullname'] == "Amaze Chain") {
      imgWidget = Image.asset('assets/img/ast.png');
      fullname = "AmazeToken";
      symbol = "AST";
    }*/

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: ScreenUtil().setWidth(1.0),color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name)),
        ),
      ),
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(20.0),
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(20.0),
      ),

      //color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: ScreenUtil().setWidth(50.0),
            height: ScreenUtil().setWidth(50.0),
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(30.0)),
            child: imgWidget,
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fullname,
                  style: TextStyle(
                    fontSize: ScreenUtil().setWidth(30.0),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    height: 1.3,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: '$symbol  ',
                    style: TextStyle(
                      fontSize: ScreenUtil().setWidth(26.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text: rowValue['contract'].toString() == ""
                            ? ""
                            : '${rowValue['chain_name'].toString()}(${rowValue['rules'].toString()})',
                        style: TextStyle(
                          fontSize: ScreenUtil().setWidth(26.0),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainButtonBgColor.name),
                          height: 1.3,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (rowValue['edit'])
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(19.0)),
              width: ScreenUtil().setWidth(78.0),
              height: ScreenUtil().setWidth(78.0),
              child: CircularProgressIndicator(),
            ),
          if (rowValue['isAdd'] == false &&
              rowValue['edit'] == false &&
              rowValue['canEdit'] == true)
            InkWell(
              onTap: () {
                if (rowValue['contract'] == "") {
                  addCoin(rowValue);
                } else {
                  addCoinToken(rowValue);
                }
              },
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(19.0)),
                width: ScreenUtil().setWidth(78.0),
                height: ScreenUtil().setWidth(78.0),
                child: Icon(
                  Icons.add,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainButtonBgColor.name),
                ),
              ),
            ),
          if (rowValue['isAdd'] &&
              rowValue['edit'] == false &&
              rowValue['canEdit'] == true)
            InkWell(
              onTap: () {
                if (rowValue['contract'] == "") {
                  removeCoin(rowValue);
                } else {
                  removeCoinToken(rowValue);
                }
              },
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setWidth(80.0),
                child: Icon(
                  Icons.remove,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainButtonBgColor.name),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget coinListTokenWidget() {
    if (coinlistToken.isEmpty || showImportWidget) {
      return importTokenWidget();
    } else {
      return Column(
        children: [
          Expanded(
            flex: 1,
            child: ListView.separated(
              itemCount: coinlistToken.length,
              itemBuilder: (context, int index) {
                Map<String, dynamic> rowValue = coinlistToken[index];
                return coinItemToken(rowValue);
              },
              separatorBuilder: (context, int index) {
                return Divider(
                  height: 1,
                  indent: 0,
                  endIndent: 0,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
                );
              },
            ),
          ),
          addButtonWidget(),
        ],
      );
    }
  }

  Widget coinItemToken(Map<String, dynamic> rowValue) {
    String symbol = rowValue['miniName'].toString();
    return Container(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(20.0),
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(20.0),
      ),
      //color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(30.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                height: 1.3,
              ),
            ),
          ),
          if (rowValue['edit'])
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(19.0)),
              width: ScreenUtil().setWidth(78.0),
              height: ScreenUtil().setWidth(78.0),
              child: CircularProgressIndicator(),
            ),
          if (rowValue['edit'] == false)
            InkWell(
              onTap: () {
                removeCustomerCoinToken(rowValue);
              },
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setWidth(80.0),
                child: Icon(
                  Icons.remove,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainButtonBgColor.name),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget importTokenWidget() {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                  decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.errorBgColor2.name),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0)),
                  ),
                  child: Text(
                    S.of(context).g_token_m_key_10,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(24.0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                addressWidget(),
                symbolWidget(),
                decimalWidget(),
                SizedBox(height: ScreenUtil().setWidth(148),),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: importButtonWidget(),
        ),
      ],
    );
  }

  //切换网络
  void showChangeNetwork() {
    if (load == Load.loading) return;
    List<Widget> childs = [];
    childs.add(Container(
      constraints: BoxConstraints(
        maxHeight: ScreenUtil().setWidth(600.0),
      ),
      child: ListView.separated(
        itemCount: importType == 0 ? netChains.length + 1 : chainsToken.length,
        itemBuilder: (context, int index) {
          bool selected = false;
          Map<String, dynamic>? coinInfo;
          if (importType == 0) {
            if (networkIndex == index - 1) {
              selected = true;
            }
            if (index == 0) {
              return InkWell(
                onTap: () {
                  setNetworkIndex(-1, "");
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(30.0),
                    horizontal: ScreenUtil().setWidth(20.0),
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                          width: ScreenUtil().setWidth(1.0),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemLineColor.name),
                        )),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).g_token_m_key_4,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(30.0),
                            color: AppThemeUtils.getColorByKey(
                                context, "mainTextColor"),
                            fontWeight: FontWeight.bold),
                      ),
                      if (selected)
                        Icon(
                          Icons.check,
                          size: ScreenUtil().setWidth(40.0),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainBlueColor.name),
                        ),
                    ],
                  ),
                ),
              );
            }
            coinInfo = netChains[netChains.keys.toList()[index - 1]];
          } else {
            if (networkIndexToken == index) {
              selected = true;
            }
            coinInfo = netChains[chainsToken.keys.toList()[index]];
          }
          if (coinInfo == null) return Container();
          Widget image;
          String symbolStr = coinInfo['baseInfo']['miniName'];
          String nameStr = coinInfo['baseInfo']['name'];
          if (coinInfo['baseInfo']['miniName'] == CoinType.N.name) {
            image = Image.asset('assets/images/ast.png');
            symbolStr = CoinType.N.name;
            nameStr = "N42";
          } else {
            image = ImageNetWork(imageUrl:
              coinInfo['baseInfo']['icon'],
              placeholder: "assets/img/list_default.png",
            );
          }
          return InkWell(
            onTap: () {
              if (importType == 0) {
                setNetworkIndex(index - 1, coinInfo!['baseInfo']['name']);
              } else {
                setNetworkIndex(index, coinInfo!['baseInfo']['name']);
              }
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(30.0),
                horizontal: ScreenUtil().setWidth(20.0),
              ),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                      width: ScreenUtil().setWidth(1.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemLineColor.name),
                    )),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: ScreenUtil().setWidth(52.0),
                    height: ScreenUtil().setWidth(52.0),
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                    child: image,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          symbolStr,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(30.0),
                              color: AppThemeUtils.getColorByKey(
                                  context, "mainTextColor"),
                              fontWeight: FontWeight.bold),
                        ),
                        Text(nameStr,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(30.0),
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.itemSubtitleTextColor.name),
                            )),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check,
                      size: ScreenUtil().setWidth(40.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                    ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, int index) {
          return Divider(
            endIndent: 0,
            indent: 0,
            height: 0.1,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
          );
        },
      ),
    ));
    sheetBottom(
        context,
        "",
        Column(
          children: childs,
        ));
  }
}
