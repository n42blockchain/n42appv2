import 'dart:async';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/miningV2/api/mining_api.dart';
import 'package:n42appv2/src/miningV2/api/mining_web3.dart';
import 'package:n42appv2/src/miningV2/models/mining_withdrawals_daily.dart';
import 'package:n42appv2/src/miningV2/provider/mining_web_socket_bridge.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/src/widgets/chart_histogram.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:provider/provider.dart';

class MiningV2Provider extends ChangeNotifier {
  MiningApi? mining;
  MiningApi get Mining{
    mining ??= MiningApi.init();
    return mining!;
  }
  MiningWeb3? web3;
  MiningWeb3 get Web3{
    web3 ??= MiningWeb3.init(privateKey??"");
    return web3!;
  }
  //是否已经质押
  bool? depositsEnable;
  bool miningStatus = false;

  setDepositsEnable(bool? flag) {
    depositsEnable = flag??false;
    notifyListeners();
  }

  setMiningStatus(bool status) {
    miningStatus = status;
    notifyListeners();
  }

  String walletName="";
  String? address;

  resetData() {
    mining=null;
    web3=null;
    depositsEnable = false;
    miningStatus = false;
    walletName="";
    address=null;
    notifyListeners();
  }

  // ============================================
  // Wallet List Management (via WalletActionProvider)
  // ============================================
  
  /// Get all wallets that support N chain (for mining)
  List<MiningWalletInfo> get miningWalletList {
    try {
      WalletActionProvider wap = Provider.of<WalletActionProvider>(AppGlobals.appContext, listen: false);
      List<MiningWalletInfo> result = [];
      
      for (int i = 0; i < wap.walletInfoLsit.length; i++) {
        WalletInfo wInfo = wap.walletInfoLsit[i];
        // Only include wallets that support N chain
        if (wInfo.coinInfo?[CoinType.N.name] != null) {
          result.add(MiningWalletInfo(
            index: i,
            name: wInfo.walletName ?? 'Account${i + 1}',
            address: wInfo.coinInfo?[CoinType.N.name]?['address'] ?? '',
            isMainWallet: wInfo.mainWallet,
            hasCoinN: true,
          ));
        }
      }
      return result;
    } catch (e) {
      debugPrint('miningWalletList error: $e');
      return [];
    }
  }

  /// Current selected mining wallet index
  int get currentMiningWalletIndex {
    try {
      WalletActionProvider wap = Provider.of<WalletActionProvider>(AppGlobals.appContext, listen: false);
      return wap.walletMiningIndex;
    } catch (e) {
      return -1;
    }
  }

  /// Set mining wallet by index
  Future<void> setMiningWalletByIndex(int index) async {
    // This triggers the event via WalletActionProvider
    // We need to use the event bus to communicate this
    eventBus.fire(EventPublic(EventPublicType.selectMiningWallet, intValue: index));
    notifyListeners();
  }





  /// 抱团挖矿/质押NFT/质押N
  /// 新增：FUJI NFT 质押
  Future<void> checkAddressMiningStatus() async {
    try {
      WalletActionProvider wap = Provider.of<WalletActionProvider>(AppGlobals.appContext, listen: false);
      if (wap.walletInfoLsit.isEmpty) return;
      
      final miningIndex = wap.walletMiningIndex;
      if (miningIndex < 0 || miningIndex >= wap.walletInfoLsit.length) return;
      
      WalletInfo wInfo = wap.walletInfoLsit[miningIndex];
      Map<String, dynamic>? cInfo = wInfo.coinInfo?[CoinType.N.name];
      if (cInfo == null) return;
      
      Map<String, dynamic> pathMap = cInfo['baseInfo']['path'];
      var rm = await Trustdart().generateAddress(
          CoinType.N.name,
          getPathWithIndex(pathMap[cInfo['addrType']], cInfo['pathIndex']),
          cInfo['addrType'],
          mnemonic: wInfo.mnemonic ?? "",
          pk: wInfo.privateKey ?? ""
      );
      address = rm[cInfo['addrType']];
      await getWalletPrivateKey();
      
      // Get wallet name from WalletActionProvider
      walletName = wInfo.walletName ?? "";
      
      if (address == null) return;

      await getMiningData();
      if (depositsEnable == true) {
        connectWebSocket(wsUrl: 'ws://5.161.252.59:8546/',validatorPrivateKey:miningKeypart?['privateKey']??"",validatorPubkey:miningKeypart?['publicKey']??"",);
        //runMining();
      }
      // Note: getNprice requires price service, skipping for now
      loadMiningData();
      
      // 获取钱包中 N 币余额
      await getWalletNBalance(address??"",cInfo);
    } catch (err) {
      setDepositsEnable(false);
      debugPrint("checkAddressMiningStatus err：${err.toString()}");
    } finally {
      notifyListeners();
    }
  }
  Future<void> loadMiningData() async {
    endBeaconValidatorTimer();
    endCheckTxHash();
    if(depositsEnable==true){
      getMiningWithdrawalsDaily();
      getBeaconValidator();
    }else{
      taskList=[];
      balanceInBeacon=0;
      inactivityScore=[0,0,0,0];
      miningTotalRevenue=0;
      inactivityScorePercentage="0";
      inactivityTitle="";
      //昨天挖矿时间
      yesterdayCycleRewardsValue=0;
      todayCycleRewardsValue=0;
      barchartValues = [0, 0, 0, 0, 0, 0, 0];
      barchartAlertMessageList = [];
      barchartTitle=[];
      isLoading7DayData=false;
      isShowDefaultBar=true;
      showRedemption=false;
      showRedemption2=false;
      exitDepositLoad=Load.finish;
      depositLoad=Load.finish;

      endWithdrawalTimer();
    }
  }
  Future<void> getNprice(WalletActionProvider wap) async {
    Map<String,dynamic>? coinInfo=wap.getCoinPriceWithUnit(CoinType.N.name);
    nPrice=coinInfo?['coinPrice']??0;
  }
  
  /// 钱包中 N 币的可用余额（未质押时显示）
  double walletNBalance = 0;
  
  /// 获取钱包中 N 币余额
  Future<void> getWalletNBalance(String add,Map coinInfo,) async {
    try {
      MessageModel rmm=await TokenViewApi().getBalance(BlockchainType.Ethereum.name, CoinType.N.name, add,isTest: coinInfo['isTest'],rpc: coinInfo['isTest']?coinInfo['baseInfo']['service_test']:coinInfo['baseInfo']['service']);
      if(rmm.error==false){
        walletNBalance=toEther(rmm.data.toString(), coinInfo['baseInfo']['decimals']).toDouble();
      }
      /*final walletActionProvider = Provider.of<WalletActionProvider>(AppGlobals.appContext, listen: false);
      
      // 在 coinList 中查找 N 币
      for (var coin in walletActionProvider.coinList) {
        if (coin.coin['coinType'] == CoinType.N.name && coin.coin['isContract'] == false) {
          walletNBalance = coin.balanceDoubleAll();
          debugPrint('MiningV2Provider: Wallet N balance = $walletNBalance');
          notifyListeners();
          return;
        }
      }
      
      // 如果在 coinList 中没找到，尝试从 coinModels 中查找
      for (var coin in walletActionProvider.coinModels) {
        if (coin.coin['coinType'] == CoinType.N.name) {
          walletNBalance = coin.balanceDoubleAll();
          debugPrint('MiningV2Provider: Wallet N balance from coinModels = $walletNBalance');
          notifyListeners();
          return;
        }
      }*/
      
      debugPrint('MiningV2Provider: N coin not found in wallet');
    } catch (e) {
      debugPrint('MiningV2Provider: Error getting wallet N balance: $e');
    }
  }
  ///错误信息
  String errorMessage="";
  ///质押操作返回的交易hash
  String depositTxHash="";
  setDepositTxHash(String txHash){
    depositTxHash=txHash;
    startCheckDepositTxHash(depositTxHash);
  }
  ///质押操作返回的交易hash
  String exitDepositTxHash="";
  setExitDepositTxHash(String txHash){
    exitDepositTxHash=txHash;
    startCheckExitDepositTxHash(exitDepositTxHash);
  }
  ///获取keypart
  Map<String,dynamic>? miningKeypart;
  Map<String,dynamic>? miningData;
  bool redeem=false;
  setMiningData(Map<String,dynamic> keypart,bool isMining,{bool redeem=false})async{
    miningData ??= {};
    miningData![address!]={
      'isMining':isMining,
      'keypart':keypart,
      'redeem':redeem,
    };
    SPUtil().setMiningData(miningData!);
  }
  /// Import mining data with wallet creation
  /// 
  /// TODO: This method still uses WalletActionProvider for wallet creation.
  /// Needs to be refactored to use IWalletService when wallet creation
  /// functionality is added to the service interface.
  Future<MessageModel> setMiningDataImport(Map<String,dynamic> value,String password) async {
    // NOTE: Keep using WalletActionProvider for wallet creation operations
    // This will be migrated when IWalletService supports wallet creation
    WalletActionProvider wap=Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false);
    int index=wap.walletInfoLsit.indexWhere((test){
      if(test.privateKey==value['privateKey']){
        return true;
      }
      if(test.mnemonic==value['mnemonicWords']){
        return true;
      }
      return false;
    });
    String importAddress="";
    WalletInfo wInfo;
    //导入钱包
    if(index ==-1){
      if(value['mnemonicWords'] !=""){
        bool checkMnemonic = await Trustdart().checkMnemonic(value['mnemonicWords']);
        if (checkMnemonic == false) {
          //助记词输入错误
          MessageModel rmm = MessageModel.error();
          rmm.data=S.current.w_key_12;
          return rmm ;
        }else{
          wInfo = WalletInfo(
            mnemonic: value['mnemonicWords'],
          );
        }
        wInfo.password=password;
      }else{
        wInfo = WalletInfo(
          privateKey: value['privateKey'],
        );
        wInfo.password='';
      }
      wInfo.walletName="Account${wap.walletInfoLsit.length+1}";
      wInfo.walletUuid=wap.UserUUID;
      wInfo.coinInfo=chainUrlMap;
      wInfo.timestamp = "${DateTime.now().millisecondsSinceEpoch}";
    }else{
      wInfo = wap.walletInfoLsit[index];
    }

    Map<String,dynamic> cInfo = wInfo.coinInfo?[CoinType.N.name];
    Map<String, dynamic> pathMap = cInfo['baseInfo']['path'];
    var rmAddress = await Trustdart().generateAddress(
        CoinType.N.name,
        getPathWithIndex(pathMap[cInfo['addrType']], cInfo['pathIndex']),
        cInfo['addrType'],
        mnemonic: wInfo.mnemonic??"",
        pk: wInfo.privateKey??""
    );
    importAddress = rmAddress[cInfo['addrType']];
    if(index ==-1){
      await wap.addWalletInfo(wInfo);
    }
    miningData ??= {};
    if(miningData?[importAddress] == null){
      miningData![importAddress]={
        'isMining':value['isMining'],
        'keypart':value['validator'],
        'redeem':false,
      };
      SPUtil().setMiningData(miningData!);
      if(index ==-1){
        wap.setWalletMiningIndex(wap.walletInfoLsit.length-1);
      }else{
        wap.setWalletMiningIndex(index);
      }
      MessageModel rmm = MessageModel();
      return rmm;
    }else{
      MessageModel rmm = MessageModel.error();
      //"验证者已经存在";
      rmm.data=S.current.g_mining_key_83;
      return rmm;
    }
  }
  Future<void> getMiningData() async {
    miningData=await SPUtil().getMiningData();
    depositsEnable=miningData?[address!]?['isMining']??false;
    miningKeypart=miningData?[address!]?['keypart']??{};
    redeem=miningData?[address!]?['redeem']??false;
  }

  //质押
  Load depositLoad=Load.finish;
  Future<void> createDepositUnsignedTx(int amount,Map<String,dynamic> encrypteData) async {
    try{
      depositLoad=Load.loading;
      notifyListeners();
      miningKeypart=encrypteData['validator'];
      String? rData=await Mining.createDepositUnsignedTx(
        miningKeypart?['privateKey']??"",
        address??"",
        DataUtils().bigIntToHex(ethToWeiString('$amount', 18)),
      );
      if(rData !=null){
        MessageModel sendMM=await Web3.sendDepositTransaction(jsonDecode(rData));
        if(sendMM.error==false){
          setDepositTxHash(sendMM.data);
          errorMessage="";
        }else{
          errorMessage=sendMM.data;
          depositLoad=Load.finish;
        }
        notifyListeners();
      }else{
        errorMessage="Error!";
        depositLoad=Load.finish;
      }
    }catch(e){
      ToastUtils.show(e.toString());
      depositLoad=Load.finish;
      notifyListeners();
    }

  }
  void startCheckDepositTxHash(String txHash){
    _timer=Timer.periodic(const Duration(seconds: 5), (timer) async {
      if(await checkTxHash(txHash)==false){
        endCheckTxHash();
        //depositsEnable=true;
        depositLoad=Load.finish;
        notifyListeners();
        setMiningData(miningKeypart!, true);
        eventBus.fire(EventPublic(EventPublicType.miningFullNode));
        checkAddressMiningStatus();
      }
    });
  }
  Load exitDepositLoad=Load.finish;
  Future<void> createExitDepositUnsignedTx() async {
    exitDepositLoad=Load.loading;
    notifyListeners();
    String? feeWeiInHexTx=await miningCreateGetExitFeeUnsignedTx();
    if(feeWeiInHexTx ==null){
      errorMessage="‘miningCreateGetExitFeeUnsignedTx’ method error！";
      exitDepositLoad=Load.finish;
      notifyListeners();
      return;
    }
    MessageModel feeMM=await Web3.exitDepositRowCall(feeWeiInHexTx);
    if(feeMM.error) {
      errorMessage=feeMM.data;
      exitDepositLoad=Load.finish;
      notifyListeners();
      return;
    }
    final exitSignDataStr=await miningCreateExitUnsignedTx(feeMM.data);
    MessageModel sendMM=await Web3.sendExitDepositTransaction(jsonDecode(exitSignDataStr??'{}'));
    if(sendMM.error==false){
      setExitDepositTxHash(sendMM.data);
      errorMessage="";
    }else{
      errorMessage=sendMM.data;
      exitDepositLoad=Load.finish;
    }
    notifyListeners();
  }
  void startCheckExitDepositTxHash(String txHash){
    _timer=Timer.periodic(const Duration(seconds: 5), (timer) async {
      if(await checkTxHash(txHash)==false){
        exitDepositLoad=Load.finish;
        redeem=true;
        notifyListeners();
        endCheckTxHash();
        setMiningData(miningKeypart!, true,redeem: true);
        getBeaconValidator();
      }
    });
  }
  void endCheckTxHash(){
    if(_timer !=null){
      _timer!.cancel();
      _timer=null;
    }
  }
  Future<bool> checkTxHash(String txHash) async {
    MessageModel rmm = await Web3.getTransactionReceipt(txHash);
    return rmm.error;
  }
  Future<void> runMining() async {
    String? rData=await Mining.runClent(
      miningKeypart?['privateKey']??"",
    );
    if(rData !=null){
      if(rData == "Client started"){
        //setMiningData();
        //start();
        //isRun=true;
        miningStatus=true;
        errorMessage="";
      }else{
        miningStatus=false;
        errorMessage=rData;
      }
    }else{
      errorMessage='Running the "runClent" method failed!';//"运行“runClent”方法失败！";
    }
    notifyListeners();
  }
  Timer? _timer;
  void start() {
    // 每隔30秒执行一次
    if(_timer !=null){
      if(_timer!.isActive){
        return;
      }
    }
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      //await getBalance(addList: true);
    });
  }
  Future<String?> miningCreateGetExitFeeUnsignedTx() async {
    String? rData = await Mining.miningCreateGetExitFeeUnsignedTx();
    return rData;
  }
  Future<String?> miningCreateExitUnsignedTx(String feeWeiInHex) async {
    String? rData = await Mining.miningCreateExitUnsignedTx(feeWeiInHex,miningKeypart?['publicKey']??"");
    return rData;
  }

  String? privateKey;
  Future<void> getWalletPrivateKey() async {
    try {
      WalletActionProvider wap = Provider.of<WalletActionProvider>(AppGlobals.appContext, listen: false);
      if (wap.walletInfoLsit.isEmpty) {
        errorMessage = "Wallet not available!";
        notifyListeners();
        return;
      }
      
      final miningIndex = wap.walletMiningIndex;
      if (miningIndex < 0 || miningIndex >= wap.walletInfoLsit.length) {
        errorMessage = "Mining wallet index invalid!";
        notifyListeners();
        return;
      }
      
      WalletInfo wInfo = wap.walletInfoLsit[miningIndex];
      String? pk = wInfo.privateKey;
      
      if (pk == null || pk.isEmpty) {
        // Try to generate from mnemonic
        Map<String, dynamic>? nCoinInfo = wInfo.coinInfo?[CoinType.N.name];
        final mnemonic = wInfo.mnemonic;
        
        if (nCoinInfo != null && mnemonic != null && mnemonic.isNotEmpty) {
          Map<String, dynamic> pathMap = nCoinInfo['baseInfo']['path'];
          privateKey = await Trustdart().getPrivateKey(
            mnemonic,
            CoinType.N.name,
            getPathWithIndex(pathMap['legacy'], nCoinInfo['pathIndex']),
          );
        }
      } else {
        privateKey = pk;
      }
      
      if (privateKey == null) {
        errorMessage = "PrivateKey not found!";
        notifyListeners();
      }
    } catch (e) {
      errorMessage = "Error getting private key: $e";
      notifyListeners();
    }
  }
  List<MiningWithdrawalsDaily> taskList=[];
  //总收益
  double miningTotalRevenue=0;
  //今天挖矿时间
  double todayCycleRewardsValue=0;
  //昨天挖矿时间
  double yesterdayCycleRewardsValue=0;
  double nPrice=0;
  List<double> barchartValues = [0, 0, 0, 0, 0, 0, 0];
  List<String> barchartValues2 = ["0", "0", "0", "0", "0", "0", "0"];
  List<AlertMessageGroup> barchartAlertMessageList = [];
  List<String> barchartTitle=[];
  bool isLoading7DayData=false;
  bool isShowDefaultBar=true;

  Timer? withdrawalTimer;
  void startWithdrawalTimer(){
    if(withdrawalTimer !=null){
      if(withdrawalTimer!.isActive){
        return;
      }
    }
    withdrawalTimer = Timer.periodic(const Duration(seconds: 128), (timer) async {
      getMiningWithdrawalsDaily();
    });
  }
  void endWithdrawalTimer(){
    if(withdrawalTimer !=null){
      if(withdrawalTimer!.isActive){
        withdrawalTimer!.cancel();
        withdrawalTimer=null;
      }
    }
  }
  Future<void> getMiningWithdrawalsDaily() async {
    if(isLoading7DayData)return;
    final DateTime today = DateTime.now();//今天
    final DateTime tomorrow =today.add(const Duration(days: 1));//后天
    final DateTime yesterday=today.add(const Duration(days: -1));//昨天
    final List<String> tomorrowStr = getTimeFormat(tomorrow);
    isLoading7DayData=true;
    notifyListeners();
    MessageModel rmm= await Mining.getMiningWithdrawalsDaily(tomorrowStr[0], address??"");
    if(rmm.error==false){
        //有效挖矿1次时间是128秒
        taskList=rmm.data;
        final List<String> todayStr = getTimeFormat(today);
        final List<String> yesterdayStr = getTimeFormat(yesterday);
        int tIndex=taskList.indexWhere((e)=>e.day==todayStr[0]);
        int yIndex=taskList.indexWhere((e)=>e.day==yesterdayStr[0]);
        if(tIndex !=-1){
          todayCycleRewardsValue=toEther(taskList[tIndex].totalAmount??'0', 18).toDouble();
        }else{
          todayCycleRewardsValue=0;
        }
        if(yIndex !=-1){
          yesterdayCycleRewardsValue=toEther(taskList[yIndex].totalAmount??'0', 18).toDouble();
        }else{
          yesterdayCycleRewardsValue=0;
        }
        get7DaysValue(today);
        startWithdrawalTimer();
    }
    MessageModel rmms=await Mining.getMiningWithdrawalsDailySummary(address??"");
    if(rmms.error==false){
      miningTotalRevenue=toEther(rmms.data, 18).toDouble();
    }
    isLoading7DayData=false;
    notifyListeners();
  }
  List<String> getTimeFormat(DateTime date){
    final String year = date.year.toString();
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return ["$year-$month-$day","$day/$month"];
  }
  /// 将秒数转换为时分秒格式的字符串，并补齐两位
  List<String> formatElapsedTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    // 使用padLeft方法补齐两位
    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return [hoursStr, minutesStr, secondsStr];
  }
  void get7DaysValue(DateTime date){
    for(int i=0;i<7;i++){
      DateTime d1=date.add(Duration(days: -(6-i)));
      final List<String> d1Str = getTimeFormat(d1);
      barchartTitle.add(d1Str[1]);
      int tIndex=taskList.indexWhere((e)=>e.day==d1Str[0]);
      if(tIndex !=-1){
        barchartValues[i]=(taskList[tIndex].count??0).toDouble();
        barchartValues2[i]=taskList[tIndex].totalAmount??"0";
      }else{
        barchartValues[i]=0;
        barchartValues2[i]="0";
      }
    }
    generateBarTipData();
    isShowDefaultBar=false;
  }
  //生成图标点击事件展示数据
  void generateBarTipData() {
    if (barchartValues.isNotEmpty && barchartValues.length == 7) {
      barchartAlertMessageList = [];
      //计算奖励
      //final stackAstNum = Provider.of<MiningProvider>(context,listen: false).depositsNum;
      for (int i=0;i<barchartValues.length;i++) {
        //计算时间
        //int times = (element * 8).toInt();
        //final timeData = formatElapsedTime(times);
        //final value = computeRewardsValueByTaskNum(element.toInt(), stackAstNum);
        // debugPrint("奖励值：$value");
        barchartAlertMessageList.add(
          AlertMessageGroup(
            titles: [
              S.current.g_mining_key_23,
              "${barchartValues[i].toInt()}",
              S.current.g_mining_key_13,
              "${toEther(barchartValues2[i], 16)} ${CoinType.N.name}",
            ],
            styles: [
              TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: AppThemeUtils.getColorByKey(
                    AppGlobals.appContext, AppThemeKeys.mainWhiteColor.name),
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                    AppGlobals.appContext, AppThemeKeys.mainWhiteColor.name),
                fontWeight: FontWeight.bold,
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: AppThemeUtils.getColorByKey(
                    AppGlobals.appContext, AppThemeKeys.mainWhiteColor.name),
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                    AppGlobals.appContext, AppThemeKeys.mainWhiteColor.name),
                fontWeight: FontWeight.bold,
              ),

            ],
          ),
        );
      }
    }
  }
  double balanceInBeacon=0;
  List<double> inactivityScore=[0,0,0];
  String inactivityScorePercentage="0";
  String inactivityTitle="";
  bool showRedemption=false;//质押成功的过度状态
  bool showRedemption2=false;//解除质押成功后的过度状态
  Timer? beaconValidatorTimer;
  starBeaconValidatorTimer({int waitSeconds=200}){
    if(beaconValidatorTimer !=null)return;
    beaconValidatorTimer=Timer(Duration(seconds: waitSeconds),(){
      getBeaconValidator();
      endBeaconValidatorTimer();
    });
  }
  endBeaconValidatorTimer(){
    if(beaconValidatorTimer !=null){
      beaconValidatorTimer!.cancel();
      beaconValidatorTimer=null;
    }
  }
  Future<void> getBeaconValidator() async {
    MessageModel rmm=await Mining.getBeaconValidator(miningKeypart?['publicKey']??"");
    if(rmm.error ==false){
      inactivityScore=[0,0,0];
      balanceInBeacon=toEther((rmm.data?['balance_in_beacon']??0).toString(), 9).toDouble();
      int iscore=rmm.data?['inactivity_score']??0;
      debugPrint('iscore:$iscore');
      iscore=iscore>2700?2700:iscore;
      double isp=((iscore/2700)*100);
      inactivityScorePercentage=isp.toStringAsFixed(2);
      if(isp<=33.33){
        inactivityTitle=S.current.g_mining_key_84;//"Low Risk";
      }else if(isp<=66.66){
        inactivityTitle=S.current.g_mining_key_85;//"Moderately Risk";
      }
      else{
        inactivityTitle=S.current.g_mining_key_87;//"High Risk";
      }
      if(iscore!=0){
        for(int i=0;i<3;i++){
          if(iscore-(i+1)*900<=0){
            inactivityScore[i]=(iscore-(i)*900)/900;
            break;
          }else{
            inactivityScore[i]=1;
          }
        }
      }
      int timestamp=rmm.data['activation_timestamp'];
      if(timestamp==0){
        showRedemption=false;
        starBeaconValidatorTimer();
      }else{
        final int currentTimestamp=DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final int readyTimestamp=timestamp+128;
        if(readyTimestamp>currentTimestamp){
          showRedemption=false;
          final int waitSeconds=readyTimestamp-currentTimestamp;
          starBeaconValidatorTimer(waitSeconds: waitSeconds);
        }else{
          showRedemption=true;
        }
      }
      int eTimestamp=rmm.data['exit_timestamp'];
      if(eTimestamp==0){
        showRedemption2=true;
        starBeaconValidatorTimer();
      }else{
        showRedemption2=false;
        depositsEnable=false;
        miningStatus=false;
        loadMiningData();
        notifyListeners();
        setMiningData(miningKeypart!, false,redeem: true);
      }
      notifyListeners();
    }
  }



  // ================= WebSocket 相关 =================
  NativeWebSocketBridge? _wsBridge;
  StreamSubscription<String>? _wsSubscription;

  /// WebSocket 连接状态
  bool wsConnected = false;

  /// 初始化 WebSocket
  void initWebSocket() {
    _wsBridge ??= NativeWebSocketBridge();
  }

  /// 连接 / 切换 WebSocket（首连 + 切钱包共用）
  Future<void> connectWebSocket({
    required String wsUrl,
    required String validatorPubkey,
    required String validatorPrivateKey,
  }) async {
    try {
      initWebSocket();

      // ⭐ 只初始化一次监听
      _wsSubscription ??= _wsBridge!.messages.listen(
        handleWebSocketMessage,
        onError: (e) {
          debugPrint('WS stream error: $e');
          wsConnected = false;
          miningStatus = false;
          notifyListeners();
        },
      );

      // ⭐ 不要先 disconnect
      await _wsBridge!.connect(
        wsUrl: wsUrl,
        validatorPubkey: validatorPubkey,
        validatorPrivateKey: validatorPrivateKey,
      );

      // 注意：这里只表示“已请求连接”
      wsConnected = true;
      miningStatus = true;
      notifyListeners();

    } catch (e) {
      wsConnected = false;
      miningStatus = false;
      debugPrint('WebSocket connect error: $e');
      notifyListeners();
    }
  }


  /// 用户主动断开（退出挖矿 / 登出）
  Future<void> disconnectWebSocket() async {
    try {
      await _wsBridge?.disconnect(); // stopService
    } catch (e) {
      debugPrint('WebSocket disconnect error: $e');
    }

    _wsSubscription?.cancel();
    _wsSubscription = null;

    wsConnected = false;
    miningStatus = false;
    notifyListeners();
  }


  void handleWebSocketMessage(String message) {
    debugPrint('Received WS: $message');

    switch (message) {
      case 'WebSocket connected':
        wsConnected = true;
        miningStatus = true;
        notifyListeners();
        break;

      case 'onFailure':
      case 'onClosed':
        wsConnected = false;
        miningStatus = false;
        notifyListeners();
        break;

      default:
      // TODO: 正常业务消息解析
        break;
    }
  }


  @override
  void dispose() {
    _wsSubscription?.cancel();
    _wsBridge?.disconnect();
    super.dispose();
  }
}

/// Mining-specific wallet info
/// 
/// Used for displaying wallet list in mining UI
class MiningWalletInfo {
  final int index;
  final String name;
  final String address;
  final bool isMainWallet;
  final bool hasCoinN;

  MiningWalletInfo({
    required this.index,
    required this.name,
    required this.address,
    required this.isMainWallet,
    required this.hasCoinN,
  });
}