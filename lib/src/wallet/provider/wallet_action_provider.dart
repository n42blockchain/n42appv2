import 'dart:convert';
import 'dart:math';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/miningV2/provider/mining_v2_provider.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/market_api.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:decimal/decimal.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:provider/provider.dart';

class WalletActionProvider extends ChangeNotifier{
  //刷新coin 余额
  Map<int,dynamic> coinRefreshMap={};
  String defaultWalletUUID="AstranetWallet";
  String get UserUUID{
    if(AppGlobals.userInfo==null){
      return defaultWalletUUID;
    }else{
      return AppGlobals.userInfo?.uuid??"";
    }
  }
  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi{
    if(_tokenViewApi==null){
      _tokenViewApi=TokenViewApi();
    }
    return _tokenViewApi!;
  }
  //bool existWallet = false; //是否存在钱包
  Load _load = Load.finish; //当前状态
  Load get load => _load;
  Load loadBalance = Load.finish;
  bool buildwallet=false;
  //数字格式化实例
  final NumberFormat _oCcy = NumberFormat("#,##0.00", "en_US");

  //钱包列表
  List<WalletInfo> _walletInfoLsit = [];
  List<WalletInfo> get walletInfoLsit => _walletInfoLsit;
  WalletInfo get walletInfo{
    return _walletInfoLsit[walletIndex];
  }
  //获取用户设置的钱包名字
  String get WalletName {
    if (_walletInfoLsit.isEmpty) return "";
    return walletInfo.walletName??"";
  }
  int walletIndex=-1;//钱包索引
  setWalletIndex(int index)async{
    if(index==walletIndex)return;
    removeConRefreshMap(walletIndex);
    walletIndex=index;
    await saveWalletInfo(walletInfoLsit[walletIndex], walletIndex);

    await init_wallet(initCoinInfo: true);
    notifyListeners();

  }
  int walletMiningIndex=-1;//钱包挖矿索引
  setWalletMiningIndex(int index)async{
    if(index==walletMiningIndex)return;
    walletMiningIndex=index;
    await saveWalletInfo(walletInfoLsit[walletIndex], walletIndex);
    eventBus.fire(EventPublic(EventPublicType.selectMiningWallet,
        intValue: walletMiningIndex));
  }
  Map<String,String>? _publicKeyAndPrivateKeyPair;//_walletInfoLsit所有钱包N的公钥私钥对
  Future<Map<String,String>> publicKeyAndPrivateKeyPair() async{
    if(_publicKeyAndPrivateKeyPair==null){
      await getPublicKeyAndPrivateKeyPair_N();
    }
    return _publicKeyAndPrivateKeyPair!;
  }
  //当前钱包数据
  Map<String,dynamic> get walletMap{
    return walletInfo.coinInfo!;
  }
  List<CoinModel> _coinModels = [];
  List<CoinModel> get coinModels => _coinModels;
  //首页 显示的币列表
  List<CoinModel> coinList=[];
  //钱包所有币种余额
  //可用余额，美刀
  double _balanceTotal = 0.0;
  double get balanceTotal => _balanceTotal;
  setBalanceTotal(double price) {
    //if(existWallet==false)return;
    _balanceTotal = price;
    notifyListeners();
  }
  //获取外国余额，美刀形式
  getBalanceTotal() {
    return _oCcy.format(_balanceTotal);
  }
//市场上 币的信息，价格、涨跌幅、名称、名称缩写、icon地址
  List<dynamic> _coinMarketInfo = [];
  //币的地址 集合
  Map<String, dynamic> _addrsss = {};
  Map<String, dynamic> get address => _addrsss;
  //根据 key 获取 币的地址
  getAddress(String coinKey,{String addrType='legacy'}) {
    Map<Object?, Object?>? addrs = _addrsss[coinKey];
    return addrs?[addrType];
  }
  getMainWalletAddress_async(String coinKey,{String addrType='legacy'}) async{
    int index=walletInfoLsit.indexWhere((e)=>e.mainWallet==true);
    if(index==-1)return "";
    Map<String,dynamic> nCoinInfo=walletInfoLsit[index].coinInfo![coinKey];
    if(nCoinInfo ==null)return "";
    Map<String, dynamic> pathMap = nCoinInfo['baseInfo']['path'];
    Map<Object?, Object?> rm=await Trustdart().generateAddress(
      coinKey,
      getPathWithIndex(pathMap[addrType], nCoinInfo['pathIndex']),
      addrType,
      mnemonic: walletInfoLsit[index].mnemonic??"",
      pk:walletInfoLsit[index].privateKey??"",
    );
    return rm[addrType];
  }
  //输入的是小写的coinKey
  getAddress_coinKey_lowerCase(String coinKey, String contract) {
    CoinModel? returnCM = null;
    if (contract == "") {
      for (CoinModel cm in _coinModels) {
        String cmCoinType = cm.coin['coinType'].toString().toLowerCase();
        if (cmCoinType == coinKey) {
          returnCM = cm;
          break;
        }
      }
    } else {
      contract = contract.toLowerCase();
      //Map<String,dynamic> walletMap=walletMap;
      if(walletMap[coinKey.toUpperCase()]['mainnets'].length!=0){
        Map<String,dynamic> mainnets=walletMap[coinKey.toUpperCase()]['mainnets'];
        List<String> mKeys=mainnets.keys.toList();
        for(String key in mKeys){
          Map<String,dynamic> coin=mainnets[key];
          if(contract.toLowerCase()==coin['contract'].toString().toLowerCase()){
            returnCM=CoinModel.fromMap(mainnets[key]);
            break;
          }
        }
      }
    }
    return returnCM;
  }
  //添加币到 集合中
  setAddress(String key, Map<String, dynamic> value) {
    _addrsss[key] = value;
  }
  //返回 coinType 的主链 coinmodel
  getCoinModelWithCoinType(String coinType){
    CoinModel? rCoinModel;
    int index=_coinModels.indexWhere((element){
      if(element.coin['coinType']==coinType){
        return true;
      }
      return false;
    });
    if(index !=-1){
      rCoinModel=_coinModels[index];
    }
    return rCoinModel;
  }
//返回对应symbol 的coinmodel 列表
  getCoinModelWithSymbols({String symbols="ETH,BNB,TRX,OKT"}){
    List<String> symbolList=symbols.split(",");
    List<CoinModel> cList=[];
    for(String symbol in symbolList){
      int index=coinModels.indexWhere((element) {
        if(element.coin['coinType']==symbol){
          return true;
        }
        return false;
      });
      if(index !=-1){
        cList.add(coinModels[index]);
      }
    }
    return cList;
  }

  init_wallet({bool initCoinInfo=false})async{
    if(buildwallet==true)return;
    buildwallet=true;
    await getWalletInfo();
    //导入的钱包
    //await initImportWallet();
    await buildCoinModel();
    buildwallet=false;
    notifyListeners();
    if(initCoinInfo){
      ///发送一个event事件 对挖矿进行初始化
      eventBus.fire(EventPublic(EventPublicType.selectWallet,
          intValue: walletIndex,stringValue: "wallet"));
      init_coinInfo();
    }
  }
  //读取钱包信息
  getWalletInfo() async {
    //if (walletInfoLsit.isNotEmpty) return;
    //await checkWalletInfo();
    Map<String, dynamic>? walletAll=await SPUtil().getWalletInfo();
    if (walletAll == null){
      await createWallet();
    }else{
      Map<String, dynamic>? walletUser=walletAll[UserUUID];
      if(walletUser !=null){
        walletIndex=walletAll[UserUUID]?['index'];
        if(walletAll[UserUUID]?['miningIndex']==null || walletAll[UserUUID]?['miningIndex']==-1){
          walletMiningIndex=walletIndex;
        }else{
          walletMiningIndex=walletAll[UserUUID]?['miningIndex'];
        }
        List<dynamic> walletInfos =
            walletAll[UserUUID]?["wallet"]??[]; //await SPUtils.getWalletInfo();
        _walletInfoLsit=[];
        //await getCoinSort();//获取当前钱包币的排序缓存
        for (int i = 0; i < walletInfos.length; i++) {
          _walletInfoLsit.add(WalletInfo.fromJson(walletInfos[i]));
        }
        //await getPublicKeyAndPrivateKeyPair_N();
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
          //await getPublicKeyAndPrivateKeyPair_N();
          walletAll[UserUUID]=walletDefault;
          walletAll.remove("AstranetWallet");
          await SPUtil().setWalletInfo(walletAll);
          //saveWalletInfo(walletInfo, walletIndex,isNewWallet: true);
        }else{
          await createWallet();
        }
      }
    }
    _load = Load.finish;
    notifyListeners();
  }
  //构建 币模型
  buildCoinModel() async {
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
      _coinModels.add(cm);
    }
    notifyListeners();
    await buildCoinModelInfo();
    Provider.of<TransactionRecordItemProvider>(AppGlobals.appContext,listen: false).selectUndoneTr();
  }
  buildCoinModelInfo() async {
    coinList=[];
    for (int i = 0; i < _coinModels.length; i++) {
      CoinModel mm = _coinModels[i];
      await mm.buildWallet();
      mm.getBalance_default();
      if(mm.showList){
        coinList.add(mm);
      }
      List<String> tokenKeys=mm.tokens.keys.toList();
      for(String key in tokenKeys){
        Map<String,dynamic> token=mm.tokens[key];
        CoinModel cm=buildTokenCoinModel(mm,token);
        coinList.add(cm);
        //setTokenBalanceTotal(tokenBalanceTotal+cm.value);
      }
      notifyListeners();
    }
    //coinSort_Assets();
    calculateBalance_widthCoinModel();
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
    cm.getBalance_default();
    return cm;
  }
  //加载指定network的币
  buildCoinModelInfo_withCoin() async {
    coinList=[];
    if(walletInfo.networkIndex==-1){
      for (int i = 0; i < _coinModels.length; i++) {
        CoinModel mm = _coinModels[i];
        await mm.buildWallet();
        if(mm.showList){
          mm.getBalance_default();
          coinList.add(mm);
        }
        List<String> tokenKeys=mm.tokens.keys.toList();
        for(String key in tokenKeys){
          CoinModel cm=buildTokenCoinModel(mm,mm.tokens[key]);
          coinList.add(cm);
        }
        notifyListeners();
      }
    }
    else{
      CoinModel mm = _coinModels[walletInfo.networkIndex];
      if(mm.showList){
        mm.getBalance_default();
        coinList.add(mm);
      }
      List<String> tokenKeys=mm.tokens.keys.toList();
      for(String key in tokenKeys){
        CoinModel cm=buildTokenCoinModel(mm,mm.tokens[key]);
        coinList.add(cm);
      }
    }
    coinSort_Assets();
    notifyListeners();
    calculateBalance_widthCoinModel();
    addCoinRefreshMap();
  }
  //币列表排序
  setCoinSort_assets(String type){
    if(type=="assets"){
      if(walletInfo.coinSort['assets'] == 0){
        walletInfo.coinSort['assets']=1;
      }else if(walletInfo.coinSort['assets'] == 1){
        walletInfo.coinSort['assets']=0;
      }else{
        walletInfo.coinSort['assets']=1;
      }
      walletInfo.coinSort['name']=-1;
    }else{
      if(walletInfo.coinSort['name'] == 0){
        walletInfo.coinSort['name']=1;
      }else if(walletInfo.coinSort['name'] == 1){
        walletInfo.coinSort['name']=0;
      }else{
        walletInfo.coinSort['name']=1;
      }
      walletInfo.coinSort['assets']=-1;
    }

    //setCoinSort();
    coinSort_Assets();
    notifyListeners();
  }
  //排序type all\keystore\main
  coinSort_Assets(){
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
    /*if(walletInfo.coinSort['assets']==-1 && walletInfo.coinSort['name']==-1){
      int index=coinList.indexWhere((e){
        if(e.coin['coinType']==CoinType.N.name){
          if(e.coin['mKey']=="0XE062FD6F7B483A648AB9F84AD2BA76F9DEB0A550"){
            return true;
          }
        }
        return false;
      });
      if(index !=-1){
        CoinModel cm=coinList[index];
        coinList.removeAt(index);
        coinList.insert(coinList.length,cm);
      }
    }*/
  }
  sortString(String aName,String bName){
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
  //设置主钱包
  setMainWallet(int wIndex){
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
      saveWalletInfo_All();
      eventBus.fire(EventPublic(EventPublicType.selectWallet,
          intValue: -1,stringValue: "mainwallet"));
      MessageModel rmm=MessageModel();
      return rmm;
    }
  }
  //保存钱包修改到SPUtil
  //isNewWallet，是否是添加新钱包
  saveWalletInfo(WalletInfo newWalletInfo,int wIndex,{bool isNewWallet=false}) async{
    try{
      SPUtil sPUtils=SPUtil();
      Map<String, dynamic>? walletAll = await sPUtils.getWalletInfo();
      if (walletAll == null) {
        Map<String,dynamic> wallet=newWalletInfo.toJson();
        await sPUtils.setWalletInfo({
          UserUUID: {
            "index":0,
            "miningIndex":0,
            "wallet":[wallet],
          }
        });
      } else {
        Map<String,dynamic>? userWallets=walletAll[UserUUID];
        if(userWallets==null){
          walletAll[UserUUID] = {
            "index":0,
            "miningIndex":0,
            "wallet":[newWalletInfo.toJson()],
          };
        }else{
          if(isNewWallet){
            List<dynamic> wallet=userWallets!['wallet'];
            wallet.add(newWalletInfo.toJson());
            //userWallets['wallet']=wallet;
          }else{
            userWallets['wallet'][wIndex]=newWalletInfo.toJson();
          }
          userWallets['index']=wIndex;
          userWallets['miningIndex']=walletMiningIndex;
          walletAll[UserUUID]=userWallets;
        }
        await sPUtils.setWalletInfo(walletAll);
      }
    }catch(e){
      //ToastUtils.show3(e.toString());
    }
  }
  //保存钱包数据
  saveWalletInfo_All()async{
    SPUtil sPUtils=SPUtil();
    Map<String, dynamic>? walletAll = await sPUtils.getWalletInfo();
    if (walletAll != null) {
      walletAll[UserUUID]['wallet']=walletInfoLsit.map((e) => e.toJson()).toList();
      walletAll[UserUUID]['index']=walletIndex;
      walletAll[UserUUID]['miningIndex']=walletMiningIndex;
      await sPUtils.setWalletInfo(walletAll);
    }
  }
  //保存币的排序缓存
  saveCoinSort()async{
    saveWalletInfo(walletInfo,walletIndex);
  }
  //创建钱包
  createWallet()async{
    WalletInfo wInfo=WalletInfo(
      walletName: "",
      password: "",
      UUID: UserUUID,
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
  addWalletInfo(WalletInfo info) async {
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
      init_wallet(initCoinInfo: true);
      //await getPublicKeyAndPrivateKeyPair_N();
      notifyListeners();
    }catch(e){
      ToastUtils.show(e.toString());
    }

  }
  ///删除一个钱包
  deleteWalletInfo({WalletInfo? info}) async{
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
      var miningData=Provider.of<MiningV2Provider>(AppGlobals.appContext,listen: false).miningData?[miningAddress];
      if(miningData !=null){
        if(miningData['isMining']==true){
          MessageModel rmm=MessageModel.error();
          rmm.data="The validator's wallet cannot be deleted!";//"验证者钱包，无法删除！";
          return rmm;
        }
      }
      if(rIndex<walletIndex){
        walletIndex--;
        _walletInfoLsit.remove(info);
        //setWalletIndex(walletIndex);
      }else{
        _walletInfoLsit.remove(info);
      }
      saveWalletInfo_All();
      return null;
    }
    notifyListeners();
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
  getPublicKeyAndPrivateKeyPair_N()async{
    _publicKeyAndPrivateKeyPair={};
    Trustdart trustdart=Trustdart();
    for(WalletInfo wInfo in walletInfoLsit){
      if(wInfo.mainWallet==false){
        continue;
      }
      String path=getPathWithIndex(wInfo.coinInfo![CoinType.N.name]['baseInfo']['path'][wInfo.coinInfo![CoinType.N.name]['addrType']], wInfo.coinInfo![CoinType.N.name]['pathIndex']);
      String privateKeyStr=await trustdart.getPrivateKeyAndPublicKeyPair(
        CoinType.N.name,
        path,
        mnemonic: wInfo.mnemonic??"",
        pk: wInfo.privateKey??"",
      );
      Map<dynamic,dynamic> pkPair=json.decode(privateKeyStr);
      final pubKey = bytesToHex(base64Decode(pkPair['publicKey'].toString()));//hexUtils.uint8ToHex(base64Decode(pkPair['publicKey'].toString()));
      final privateKey = bytesToHex(base64Decode(pkPair['privateKey'].toString()));//hexUtils.uint8ToHex(base64Decode(pkPair['privateKey'].toString()));
      _publicKeyAndPrivateKeyPair![pubKey] = privateKey;
    }
  }
  getPrivateKeyWithPublicKey(String publicKey){
    return _publicKeyAndPrivateKeyPair?[publicKey]??null;
  }
  ///获取钱包 币的基本数据，成功后初始化主页币列表
  getCoinInfo() async {
    //钱包币列表，默认查询币种的当前价格等基本信息
    String coinSelectPriceKeys="";
    for(CoinModel cm in coinList){
      coinSelectPriceKeys+="${cm.coin['miniName'].toString().toLowerCase()},";
    }
    debugPrint('WalletActionProvider: Getting coin info for: $coinSelectPriceKeys');
    
    //查询coins中的币种信息
    var list = await MarketApi().getWalletCoinsInfo(coinSelectPriceKeys);
    //判断查询是否成功
    if (list['error'] == true) {
      //查询失败，设置当前操作状态为error，并设置错误信息
      debugPrint('WalletActionProvider: getCoinInfo failed: ${list['data']}');
      ToastUtils.show(S.current.g_key_5);
      notifyListeners();
    } else {
      //查询成功，将币的信息赋值到_coinslist
      final data = list['data'];
      if (data != null && data['data'] != null) {
        _coinMarketInfo = data['data'];
        debugPrint('WalletActionProvider: Loaded ${_coinMarketInfo.length} coins market info');
        // 遍历并设置每个币的价格
        for(CoinModel cm in coinList){
          getCoinPrice(cm);
        }
      } else {
        debugPrint('WalletActionProvider: No market data in response');
      }
    }
    //getBalance_main();
    addCoinRefreshMap();
  }
  //获取币的 美元价格
  getCoinPrice(CoinModel cm) {
    String keyStr = cm.coin['unit'].toString().toLowerCase();
    /*if (keyStr == 'zeta') {
      keyStr = 'eos';
    }*/
    for (var element in _coinMarketInfo) {
      if (element['coin'].toString().toLowerCase() == keyStr) {
        /*if(keyStr=="eos"){
        } else {
          cm.coin["icon"] = element['image'];
        }*/
        cm.coin["icon"] = element['image'];
        //设置币价
        cm.coinPrice = element['price'] * 1.0;
        //设置涨跌幅
        cm.percentage = element['price_change_per_24h'] * 1.0;

        break;
      }
    }
  }
  //获取币的 美元价格
  Map<String,dynamic>? getCoinPriceWithUnit(String unit) {
    String keyStr = unit.toLowerCase();
    for (var element in _coinMarketInfo) {
      if (element['coin'].toString().toLowerCase() == keyStr) {
        Map<String,dynamic> rMap={};
        rMap["icon"] = element['image'];
        //设置币价
        rMap['coinPrice']=Decimal.parse(element['price'].toString()).toDouble();
        rMap['percentage']=Decimal.parse(element['price_change_per_24h'].toString()).toDouble();
        return rMap;
      }
    }
    return null;
  }
  //获取币的 全部信息
  Map<String,dynamic>? getCoinPriceWithUnit_all(String unit) {
    String keyStr = unit.toLowerCase();
    for (var element in _coinMarketInfo) {
      if (element['coin'].toString().toLowerCase() == keyStr) {
        return element;
      }
    }
    return null;
  }
  //获取币的基本信息
  getCoinsBaseInfo(String coinName)async{
    Map<String,dynamic> m=await MarketApi().getWalletCoinsBaseInfo(coinName);
    if(m['error']){
      return null;
    }else{
      return m['data'];
    }
  }

  setNetworkIndex(int value){
    if(walletInfo.networkIndex==value)return;
    walletInfo.networkIndex=value;
    if(walletInfo.networkIndex==-1){
      buildCoinModelInfo();
    }else{
      buildCoinModelInfo_withCoin();
    }
    saveWalletInfo(walletInfo, walletIndex);
  }
  //修改面部数据绑定钱包
  setWalletFaceBinding(int? setIndex,{bool faceBinding=true}){
    if(faceBinding){
      int cancelIndex=walletInfoLsit.indexWhere((e)=>e.faceBinding==true);
      if(cancelIndex !=-1){
        WalletInfo wi=walletInfoLsit[cancelIndex];
        wi.faceBinding=false;
      }
    }
    if(setIndex==null){
      setIndex=walletIndex;
    }
    WalletInfo wi_set=walletInfoLsit[setIndex];
    wi_set.faceBinding=faceBinding;
    saveWalletInfo_All();
  }

  //refresh 是否刷新
  init_coinInfo({bool refresh=true})async{
    if(refresh){
      setBalanceTotal(0);
    }
    refreshWalletCoinInfo(refresh:refresh);
  }
  //刷新钱包中币的余额与当前价格
  refreshWalletCoinInfo({bool refresh=true}) async {
    if(refresh){
      _load = Load.refresh;
      notifyListeners();
    }
    await getCoinInfo();
    if(refresh){
      _load = Load.finish;
      notifyListeners();
    }
  }
//重新加载当前钱包的 某个 coin
  reBuildCoin(WalletInfo wInfo,String coinType)async{
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
      coinList[clIndex].buildWallet();
      coinList[clIndex].getBalance_default();
      if(coinList[clIndex].tokens.length !=0){
        List<String> tKeys=coinList[clIndex].tokens.keys.toList();
        for(int i=0;i<coinList[clIndex].tokens.length;i++){}
        for(String tkey in tKeys){
          Map<String,dynamic> token=coinList[clIndex].tokens[tkey];
          int tIndex=await coinList.indexWhere((element){
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
    notifyListeners();
  }
  //添加主链币
  addWalletChain(Map<String,dynamic> chainMap)async{
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
      coinList.last.getBalance_default();
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
      cm.getBalance_default();
      walletMap[chainMap['baseInfo']['mKey']]=chainMap;
    }
    notifyListeners();
    await saveWalletInfo(walletInfo, walletIndex);
  }
  //将币从当前钱包中移除
  //mKey 币的 map key值
  removeWalletChain(String mKey,String unit){
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

    saveWalletInfo(walletInfo, walletIndex);
    notifyListeners();
  }
  //添加代币
  addWalletChain_token(Map<String,dynamic> token){
    String symbolStr=token['coinType'].toString().toUpperCase();
    Map<dynamic,dynamic>t;
    if(walletMap[symbolStr]['isTest']){
      t= walletMap[symbolStr]['testnets'][0]['testnetContract'];
      if(t.length==0){
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
      if(t.length==0){
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
    notifyListeners();
  }
  //将代币从当前钱包中移除
  removeWalletChain_token(Map<String,dynamic> token,{String? symbol,String? miniName}){
    String symbolStr;
    if(symbol==null){
      symbolStr=token['symbol'].toUpperCase();
    }else{
      symbolStr=symbol.toUpperCase();
    }
    String miniNameStr;
    if(miniName==null){
      miniNameStr=token['coin_name'].toLowerCase();
    }else{
      miniNameStr=miniName.toLowerCase();
    }
    Map<String,dynamic>tokens;
    if(walletMap[symbolStr]['isTest']){
      tokens= walletMap[symbolStr]['testnets'][0]['testnetContract'];
    }else{
      tokens= walletMap[symbolStr]['mainnets'];
    }
    tokens.remove(token['contract'].toString().toUpperCase());
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
    notifyListeners();
  }

  //添加一个导入钱包
  Future<bool> addImportWalletInfo(WalletInfo info) async {
    //if( haveOne(info))return false;
    try{
      Map<String,dynamic> chainMap_wallet=walletMap[info.walletName!.toUpperCase()];
      List<String> chainMap_wallet_keys=chainMap_wallet.keys.toList();
      Map<String,dynamic> chainMap={};
      for(String key in chainMap_wallet_keys){
        chainMap[key]=chainMap_wallet[key];
      }
      chainMap['baseInfo']['isTest']=false;
      chainMap['baseInfo']['mainnets']={};
      chainMap['baseInfo']['balance']="0";
      chainMap['baseInfo']['balance_test']="0";
      chainMap['baseInfo']['canEdit']=false;
      info.coinInfo= {
        info.walletName!.toUpperCase():chainMap,
      };
      //walletInfo.importWallets.add(info);
      await saveWalletInfo(info, walletInfoLsit.length,isNewWallet: true);
      init_wallet();
      return true;
    }catch(e){
      return false;
    }

  }

  //计算余额
  calculateBalance_widthCoinModel(){
    double tBalance=0.0;
    for(int i=0;i<coinList.length;i++){
      tBalance +=coinList[i].value;
    }
    setBalanceTotal(tBalance);
    //getTokens_top();
  }
  getBalance_withCoinModel(CoinModel coinModel)async{
    //获取coin 的地址
    String address=coinModel.address;
    if(coinModel.coin['coinType']==CoinType.BCH.name){
      address=getAddress(coinModel.coin['coinType'],addrType: 'legacy');
    }
    //合约地址
    String contract= "";
    if(coinModel.coin['isContract']==false){
    }else{
      //获取 合约地址
      if(coinModel.isTest){
        contract=coinModel.coin['contract_test'];
      }else{
        contract=coinModel.coin['contract'];
      }
    }
    if(coinModel.coin['isContract'] && coinModel.coin['coinType']==CoinType.ALGO.name){
      return await getBalance_token_algo_withCoinModel(coinModel);
    }
    /*String rpc;
    if(coinModel.isTest){
      rpc=coinModel.coin['service_test'];
    }else{
      rpc=coinModel.coin['service'];
    }*/

    //获取 coin 的余额
    MessageModel mm=await tokenViewApi.getBalance(
        coinModel.coin['blockchainType'],
        coinModel.coin['coinType'],
        address,
        contract: contract,
        isTest: coinModel.isTest ,
      rpc: coinModel.coin['coinType']==CoinType.N.name?coinModel.coin['service_test']:null,
      //coinModel.custom?coinModel.isTest?coinModel.coin['service_test']:coinModel.coin['service']:null
      //"http://5.161.252.59:8545"
      //coinModel.custom?coinModel.isTest?coinModel.coin['service_test']:coinModel.coin['service']:null
    );
    if(mm.error){
      //coinModel.isRefresh=false;
      //coinModel.loadError=true;
      //notifyListeners();
      BigInt balance=BigInt.zero;
      if(coinModel.isTest){
        balance=BigInt.parse(coinModel.coin['balance_test']);
      }else{
        balance=BigInt.parse(coinModel.coin['balance']);
      }
      Map<String,dynamic>? coinInfo=getCoinPriceWithUnit(coinModel.coin['unit'].toString());
      if(coinInfo != null){
        coinModel.coin['percentage']=coinInfo['percentage'];
        coinModel.coin['coinPrice']=coinModel.isTest?0.0:coinInfo['coinPrice'];
        coinModel.coin['icon']=coinInfo['icon'];
        //baseInfo['name']=coinInfo['name'];
      }
      if(coinModel.coin['isContract']==false){
        walletMap[coinModel.coin['coinType']]['baseInfo']=coinModel.coin;
      }else{
        if(coinModel.isTest){
          walletMap[coinModel.coin['coinType']]['testnets'][0]['testnetContract'][coinModel.coin['mKey']]=coinModel.coin;
        }else{
          walletMap[coinModel.coin['coinType']]['mainnets'][coinModel.coin['mKey']]=coinModel.coin;
        }
      }
      coinModel.getBalance_default();
      return true;
    }
    else{
      BigInt balance=BigInt.zero;
      if(coinModel.coin['coinType']==CoinType.ALGO.name){
        balance=mm.data['balance'];
        coinModel.other=AlgoModel.fromMinBalance(mm.data['minBalance']);
      }else if(coinModel.coin['coinType']==CoinType.XRP.name){
        balance=mm.data['balance'];
        coinModel.other=XrpModel(mm.data['sequence'],mm.data['account'],mm.data['ownerCount']);
      }else{
        balance=mm.data;
      }
      Map<String,dynamic>? coinInfo=getCoinPriceWithUnit(coinModel.coin['unit'].toString());
      if(coinInfo != null){
        coinModel.coin['percentage']=coinInfo['percentage'];
        coinModel.coin['coinPrice']=coinModel.isTest?0.0:coinInfo['coinPrice'];
        coinModel.coin['icon']=coinInfo['icon'];
        //baseInfo['name']=coinInfo['name'];
      }
      if(coinModel.isTest){
        coinModel.coin['balance_test']=balance.toString();
      }else{
        coinModel.coin['balance']=balance.toString();
      }
      if(coinModel.coin['isContract']==false){
        walletMap[coinModel.coin['coinType']]['baseInfo']=coinModel.coin;
      }else{
        if(coinModel.isTest){
          walletMap[coinModel.coin['coinType']]['testnets'][0]['testnetContract'][coinModel.coin['mKey']]=coinModel.coin;
        }else{
          walletMap[coinModel.coin['coinType']]['mainnets'][coinModel.coin['mKey']]=coinModel.coin;
        }
      }
      coinModel.getBalance_default();
      return false;
    }
  }
  //获取algo 链 代币
  getBalance_token_algo_withCoinModel(CoinModel coinModel)async{
    //获取 合约地址
    String contract="";
    if(coinModel.isTest){
      contract=coinModel.coin['contract_test'];
    }else{
      contract=coinModel.coin['contract'];
    }
    CoinModel? chainCoinModel=getCoinModelWithCoinType(coinModel.coin['coinType']);
    if(chainCoinModel==null){
      coinModel.isRefresh=false;
      coinModel.loadError=true;
      notifyListeners();
      return true;
    }
    BigInt balance=BigInt.zero;
    MessageModel rBalance=await tokenViewApi.getBalance(BlockchainType.Algorand.name, coinModel.coin['coinType'], coinModel.address,contract: contract,isTest: coinModel.isTest);
    if(rBalance.error){
      coinModel.isRefresh=false;
      coinModel.loadError=true;
      notifyListeners();
      return true;
    }else{
      balance=rBalance.data['balance'];
      coinModel.other=AlgoModel.fromCode(rBalance.data['code']);
    }
    Map<String,dynamic>? coinInfo=getCoinPriceWithUnit(coinModel.coin['unit'].toString());
    if(coinInfo != null){
      coinModel.coin['percentage']=coinInfo['percentage'];
      coinModel.coin['coinPrice']=coinModel.isTest?0.0:coinInfo['coinPrice'];
      coinModel.coin['icon']=coinInfo['icon'];
    }
    if(coinModel.isTest){
      coinModel.coin['balance_test']=balance.toString();
    }else{
      coinModel.coin['balance']=balance.toString();
    }

    if(coinModel.coin['isContract']==false){
      walletMap[coinModel.coin['coinType']]['baseInfo']=coinModel.coin;
    }else{
      if(coinModel.isTest){
        walletMap[coinModel.coin['coinType']]['testnets'][0]['testnetContract'][coinModel.coin['mKey']]=coinModel.coin;
      }else{
        walletMap[coinModel.coin['coinType']]['mainnets'][coinModel.coin['mKey']]=coinModel.coin;
      }
    }
    coinModel.getBalance_default();
    return false;
  }


  addCoinRefreshMap(){
    if(coinRefreshMap[walletIndex] !=null)return;
    List<CoinModel> rList=[];
    for(int i=0;i<coinList.length;i++){
      rList.add(coinList[i]);
    }
    coinRefreshMap[walletIndex]={
      "coinList":rList,
    };
    loadBalance=Load.loading;
    notifyListeners();
    coinRefresh(walletIndex);
  }
  /// coinType:币类型，contract:合约地址，isTest:是否时测试
  refreshCoinBalance(String coinType,{String contract=""})async{
    int cmIndex=coinList.indexWhere((element) {
      if(element.coin['coinType']==coinType ){
        if(contract==""){
          return true;
        }else{
          String eContract=element.isTest?element.coin['contract_test']:element.coin['contract'];
          if(eContract==contract){
            return true;
          }
          return false;
        }
      }
      return false;
    });
    if(cmIndex != -1){
      await coinList[cmIndex].getBalance();
      notifyListeners();
    }
  }

  removeConRefreshMap(int index){
    loadBalance=Load.finish;
    notifyListeners();
    coinRefreshMap.remove(index);
  }
  coinRefresh(int index)async{
    try{
      if(coinRefreshMap[index]!=null){
        if(coinRefreshMap[index]["coinList"] !=null && coinRefreshMap[index]["coinList"].length !=0){
          coinRefreshMap[index]["coinList"].first.isRefresh=true;
          notifyListeners();
          bool r=await getBalance_withCoinModel(coinRefreshMap[index]["coinList"].first);
          if(r){
            coinRefreshMap[index]["coinList"].first.loadError=true;
            notifyListeners();
          }else{
            coinRefreshMap[index]["coinList"].first.loadError=false;
            notifyListeners();
          }
          coinRefreshMap[index]["coinList"].first.isRefresh=false;
          notifyListeners();
          coinRefreshMap[index]["coinList"].removeAt(0);
          coinRefresh(index);
        }
        else{
          saveWalletInfo(walletInfo, walletIndex);
          calculateBalance_widthCoinModel();
          removeConRefreshMap(index);
        }
      }
    }catch(e){};
  }
}
