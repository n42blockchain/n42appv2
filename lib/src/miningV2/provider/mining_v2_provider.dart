import 'dart:async';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/features/mining/domain/entities/mining_entity.dart';
import 'package:n42appv2/core/config/app_config.dart';
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
import 'package:n42appv2/core/providers/legacy_wallet_adapter.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/src/widgets/chart_histogram.dart';
import 'package:n42appv2/generated/l10n.dart';

// ==================== Mining Constants ====================
// These constants define the timing and threshold values for mining operations

/// Duration of one valid mining cycle in seconds
/// This is the block time for the N chain beacon consensus
const int kMiningCycleSeconds = 128;

/// Maximum inactivity score before penalties apply
/// When score reaches this value, validator is considered at high risk
const int kMaxInactivityScore = 2700;

/// Interval for checking transaction confirmation status
const int kTxConfirmCheckIntervalSeconds = 5;

/// Interval for refreshing mining withdrawal data
const int kWithdrawalRefreshIntervalSeconds = 128;

/// Default wait time for beacon validator status check
const int kBeaconValidatorWaitSeconds = 200;

/// Interval for periodic mining status updates
const int kMiningStatusIntervalSeconds = 30;

/// Risk level thresholds (percentage of max inactivity score)
const double kLowRiskThreshold = 33.33;
const double kModerateRiskThreshold = 66.66;

/// Inactivity score segment size (for UI display)
const int kInactivityScoreSegmentSize = 900;

/// Number of days for mining history chart
const int kMiningHistoryDays = 7;

class MiningV2Provider extends ChangeNotifier {
  MiningApi? _mining;
  MiningApi get mining{
    _mining ??= MiningApi.init();
    return _mining!;
  }
  MiningWeb3? _web3;
  MiningWeb3 get web3{
    _web3 ??= MiningWeb3.init(privateKey??"");
    return _web3!;
  }
  //是否已经质押
  bool? depositsEnable;
  bool miningStatus = false;

  void setDepositsEnable(bool? flag) {
    depositsEnable = flag??false;
    notifyListeners();
  }

  void setMiningStatus(bool status) {
    miningStatus = status;
    notifyListeners();
  }

  String walletName="";
  String? address;

  void resetData() {
    _mining=null;
    _web3=null;
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
      WalletActionProvider wap = globalWapAdapter;
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
      WalletActionProvider wap = globalWapAdapter;
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
    _inactivityWarningShown = false; // 每次冷启动重置，允许重新检测
    try {
      WalletActionProvider wap = globalWapAdapter;
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
        connectWebSocket(wsUrl: AppConfig.miningWebSocketUrl,validatorPrivateKey:miningKeypart?['privateKey']??"",validatorPubkey:miningKeypart?['publicKey']??"",);
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
      _stopStatusPolling();
      taskList=[];
      balanceInBeacon=0;
      inactivityScore=[0,0,0];
      miningTotalRevenue=0;
      inactivityScorePercentage="0";
      inactivityTitle="";
      //昨天挖矿时间
      yesterdayCycleRewardsValue=0;
      todayCycleRewardsValue=0;
      barChartValues = [0, 0, 0, 0, 0, 0, 0];
      barChartAlertMessageList = [];
      barChartTitle=[];
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
      MessageModel rmm=await TokenViewApi().getBalance(BlockchainType.Ethereum.name, CoinType.N.name, add,isTest: coinInfo['isTest'],rpc: coinInfo['isTest']?coinInfo['baseInfo']['service_test']:coinInfo['baseInfo']['service']) ?? MessageModel.error();
      if(rmm.error==false){
        walletNBalance=toEther(rmm.data.toString(), coinInfo['baseInfo']['decimals']).toDouble();
      }
      debugPrint('MiningV2Provider: N coin not found in wallet');
    } catch (e) {
      debugPrint('MiningV2Provider: Error getting wallet N balance: $e');
    }
  }
  ///错误信息
  String errorMessage="";
  ///质押操作返回的交易hash
  String depositTxHash="";
  void setDepositTxHash(String txHash) {
    depositTxHash=txHash;
    startCheckDepositTxHash(depositTxHash);
  }
  ///质押操作返回的交易hash
  String exitDepositTxHash="";
  void setExitDepositTxHash(String txHash) {
    exitDepositTxHash=txHash;
    startCheckExitDepositTxHash(exitDepositTxHash);
  }
  ///获取keypart
  Map<String,dynamic>? miningKeypart;
  Map<String,dynamic>? miningData;
  bool redeem=false;
  Future<void> setMiningData(Map<String,dynamic> keypart, bool isMining, {bool redeem = false}) async {
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
    WalletActionProvider wap=globalWapAdapter;
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
      wInfo.walletUuid=wap.userUUID;
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
      String? rData=await mining.createDepositUnsignedTx(
        miningKeypart?['privateKey']??"",
        address??"",
        DataUtils().bigIntToHex(ethToWeiString('$amount', 18)),
      );
      if(rData !=null){
        MessageModel sendMM=await web3.sendDepositTransaction(jsonDecode(rData));
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
    _timer?.cancel();
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
    MessageModel feeMM=await web3.exitDepositRowCall(feeWeiInHexTx);
    if(feeMM.error) {
      errorMessage=feeMM.data;
      exitDepositLoad=Load.finish;
      notifyListeners();
      return;
    }
    final exitSignDataStr=await miningCreateExitUnsignedTx(feeMM.data);
    MessageModel sendMM=await web3.sendExitDepositTransaction(jsonDecode(exitSignDataStr??'{}'));
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
    _timer?.cancel();
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
    MessageModel rmm = await web3.getTransactionReceipt(txHash);
    return rmm.error;
  }
  Future<void> runMining() async {
    String? rData=await mining.runClient(
      miningKeypart?['privateKey']??"",
    );
    if(rData !=null){
      if(rData == "Client started"){
        miningStatus=true;
        errorMessage="";
      }else{
        miningStatus=false;
        errorMessage=rData;
      }
    }else{
      errorMessage='Running the "runClient" method failed!';//"运行“runClient”方法失败！";
    }
    notifyListeners();
  }
  Timer? _timer;
  Future<String?> miningCreateGetExitFeeUnsignedTx() async {
    String? rData = await mining.miningCreateGetExitFeeUnsignedTx();
    return rData;
  }
  Future<String?> miningCreateExitUnsignedTx(String feeWeiInHex) async {
    String? rData = await mining.miningCreateExitUnsignedTx(feeWeiInHex,miningKeypart?['publicKey']??"");
    return rData;
  }

  String? privateKey;
  Future<void> getWalletPrivateKey() async {
    try {
      WalletActionProvider wap = globalWapAdapter;
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
  List<double> barChartValues = [0, 0, 0, 0, 0, 0, 0];
  List<String> barChartValues2 = ["0", "0", "0", "0", "0", "0", "0"];
  List<AlertMessageGroup> barChartAlertMessageList = [];
  List<String> barChartTitle=[];
  bool isLoading7DayData=false;
  bool isShowDefaultBar=true;

  Timer? withdrawalTimer;
  void startWithdrawalTimer(){
    withdrawalTimer?.cancel();
    withdrawalTimer = Timer.periodic(const Duration(seconds: kWithdrawalRefreshIntervalSeconds), (timer) async {
      getMiningWithdrawalsDaily();
    });
  }
  void endWithdrawalTimer(){
    if(withdrawalTimer !=null){
      withdrawalTimer!.cancel();
      withdrawalTimer=null;
    }
  }
  Future<void> getMiningWithdrawalsDaily() async {
    if(isLoading7DayData)return;
    final DateTime today = DateTime.now();
    final DateTime tomorrow =today.add(const Duration(days: 1));
    final DateTime yesterday=today.add(const Duration(days: -1));
    final List<String> tomorrowStr = getTimeFormat(tomorrow);
    isLoading7DayData=true;
    notifyListeners();
    try {
      MessageModel rmm= await mining.getMiningWithdrawalsDaily(tomorrowStr[0], address??"");
      if(rmm.error==false){
          // Each valid mining cycle takes kMiningCycleSeconds (128 seconds)
          // This is the consensus block time for the N chain beacon
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
      MessageModel rmms=await mining.getMiningWithdrawalsDailySummary(address??"");
      if(rmms.error==false){
        miningTotalRevenue=toEther(rmms.data, 18).toDouble();
      }
    } catch (e, st) {
      debugPrint('[Mining] getMiningWithdrawalsDaily: $e\n$st');
    } finally {
      isLoading7DayData=false;
      notifyListeners();
    }
  }
  List<String> getTimeFormat(DateTime date){
    final String year = date.year.toString();
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return ["$year-$month-$day","$day/$month"];
  }
  void get7DaysValue(DateTime date) {
    for(int i=0;i<7;i++){
      DateTime d1=date.add(Duration(days: -(6-i)));
      final List<String> d1Str = getTimeFormat(d1);
      barChartTitle.add(d1Str[1]);
      int tIndex=taskList.indexWhere((e)=>e.day==d1Str[0]);
      if(tIndex !=-1){
        barChartValues[i]=(taskList[tIndex].count??0).toDouble();
        barChartValues2[i]=taskList[tIndex].totalAmount??"0";
      }else{
        barChartValues[i]=0;
        barChartValues2[i]="0";
      }
    }
    generateBarTipData();
    isShowDefaultBar=false;
  }
  void generateBarTipData() {
    if (barChartValues.isNotEmpty && barChartValues.length == 7) {
      barChartAlertMessageList = [];
      for (int i=0;i<barChartValues.length;i++) {
        barChartAlertMessageList.add(
          AlertMessageGroup(
            titles: [
              S.current.g_mining_key_23,
              "${barChartValues[i].toInt()}",
              S.current.g_mining_key_13,
              "${toEther(barChartValues2[i], 16)} ${CoinType.N.name}",
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
  bool _inactivityWarningShown=false; // 每次冷启动只弹一次高风险 Toast
  bool showRedemption=false;//质押成功的过度状态
  bool showRedemption2=false;//解除质押成功后的过度状态

  /// Cached activation timestamp from beacon (unix seconds, 0 = not yet activated)
  DateTime? activationTime;

  /// Cached exit timestamp from beacon (unix seconds, 0 = not exited)
  int exitTimestamp = 0;

  /// Builds a [FullNodeEntity] from the cached beacon state.
  /// Returns null if not staked or pubkey is unavailable.
  FullNodeEntity? get fullNodeEntity {
    if (depositsEnable != true) return null;
    final pubKey = miningKeypart?['publicKey'] ?? '';
    if (pubKey.isEmpty) return null;
    NodeStatus status;
    if (!showRedemption2 && exitTimestamp != 0) {
      status = NodeStatus.offline;
    } else if (showRedemption) {
      status = miningStatus ? NodeStatus.online : NodeStatus.offline;
    } else {
      status = NodeStatus.syncing;
    }
    final inactivityPct = double.tryParse(inactivityScorePercentage) ?? 0.0;
    return FullNodeEntity(
      id: pubKey,
      name: 'Beacon Validator',
      status: status,
      uptimePercentage: (100.0 - inactivityPct).clamp(0.0, 100.0),
      totalRewards: miningTotalRevenue,
      activatedAt: activationTime ?? DateTime.now(),
      expiresAt: exitTimestamp > 0
          ? DateTime.fromMillisecondsSinceEpoch(exitTimestamp * 1000)
          : null,
    );
  }

  /// Periodic poll timer for beacon validator status when node is active
  Timer? _statusPollTimer;

  /// Start periodic beacon-validator polling every [kMiningStatusIntervalSeconds] seconds.
  void _startStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(
      const Duration(seconds: kMiningStatusIntervalSeconds),
      (_) => getBeaconValidator(),
    );
  }

  /// Stop periodic beacon-validator polling.
  void _stopStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = null;
  }

  Timer? beaconValidatorTimer;
  void starBeaconValidatorTimer({int waitSeconds = kBeaconValidatorWaitSeconds}) {
    if(beaconValidatorTimer !=null)return;
    beaconValidatorTimer=Timer(Duration(seconds: waitSeconds),(){
      getBeaconValidator();
      endBeaconValidatorTimer();
    });
  }
  void endBeaconValidatorTimer() {
    if(beaconValidatorTimer !=null){
      beaconValidatorTimer!.cancel();
      beaconValidatorTimer=null;
    }
  }
  Future<void> getBeaconValidator() async {
    MessageModel rmm=await mining.getBeaconValidator(miningKeypart?['publicKey']??"");
    if(rmm.error ==false){
      inactivityScore=[0,0,0];
      balanceInBeacon=toEther((rmm.data?['balance_in_beacon']??0).toString(), 9).toDouble();
      int iscore=rmm.data?['inactivity_score']??0;
      debugPrint('iscore:$iscore');
      iscore=iscore>kMaxInactivityScore?kMaxInactivityScore:iscore;
      double isp=((iscore/kMaxInactivityScore)*100);
      inactivityScorePercentage=isp.toStringAsFixed(2);
      if(isp<=kLowRiskThreshold){
        inactivityTitle=S.current.g_mining_key_84;//"Low Risk";
      }else if(isp<=kModerateRiskThreshold){
        inactivityTitle=S.current.g_mining_key_85;//"Moderately Risk";
      }
      else{
        inactivityTitle=S.current.g_mining_key_87;//"High Risk";
      }
      // 高风险预警：inactivity score 超过 66% 时弹 Toast（每次冷启动只弹一次）
      if (isp > kModerateRiskThreshold && !_inactivityWarningShown) {
        _inactivityWarningShown = true;
        ToastUtils.show(S.current.g_mining_inactivity_warning);
      }
      if(iscore!=0){
        for(int i=0;i<3;i++){
          if(iscore-(i+1)*kInactivityScoreSegmentSize<=0){
            inactivityScore[i]=(iscore-(i)*kInactivityScoreSegmentSize)/kInactivityScoreSegmentSize;
            break;
          }else{
            inactivityScore[i]=1;
          }
        }
      }
      int timestamp=rmm.data['activation_timestamp'];
      if(timestamp==0){
        activationTime = null;
        showRedemption=false;
        starBeaconValidatorTimer();
      }else{
        activationTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        final int currentTimestamp=DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final int readyTimestamp=timestamp+kMiningCycleSeconds;
        if(readyTimestamp>currentTimestamp){
          showRedemption=false;
          final int waitSeconds=readyTimestamp-currentTimestamp;
          starBeaconValidatorTimer(waitSeconds: waitSeconds);
        }else{
          showRedemption=true;
        }
      }
      int eTimestamp=rmm.data['exit_timestamp'];
      exitTimestamp = eTimestamp;
      if(eTimestamp==0){
        showRedemption2=true;
        if (showRedemption) {
          // Node is fully active: switch to periodic polling at kMiningStatusIntervalSeconds
          _startStatusPolling();
        } else {
          // Still pending activation: keep one-shot timer approach
          starBeaconValidatorTimer();
        }
      }else{
        showRedemption2=false;
        _stopStatusPolling();
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

  /// WebSocket 连接状态枚举
  WebSocketState _wsState = WebSocketState.disconnected;
  WebSocketState get wsState => _wsState;

  /// 重连相关
  int _wsReconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  Timer? _wsReconnectTimer;
  String? _lastWsUrl;
  String? _lastValidatorPubkey;
  String? _lastValidatorPrivateKey;

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
    // Store connection params for reconnection
    _lastWsUrl = wsUrl;
    _lastValidatorPubkey = validatorPubkey;
    _lastValidatorPrivateKey = validatorPrivateKey;

    // Cancel any pending reconnect
    _wsReconnectTimer?.cancel();
    _wsReconnectTimer = null;

    try {
      _wsState = WebSocketState.connecting;
      notifyListeners();

      initWebSocket();

      // Cancel existing subscription before creating new one
      await _wsSubscription?.cancel();
      _wsSubscription = null;

      // Create new subscription for this connection
      _wsSubscription = _wsBridge!.messages.listen(
        handleWebSocketMessage,
        onError: (e) {
          debugPrint('WS stream error: $e');
          _handleConnectionLost();
        },
        onDone: () {
          debugPrint('WS stream done');
          _handleConnectionLost();
        },
      );

      await _wsBridge!.connect(
        wsUrl: wsUrl,
        validatorPubkey: validatorPubkey,
        validatorPrivateKey: validatorPrivateKey,
      );

      // Connection successful
      _wsState = WebSocketState.connected;
      wsConnected = true;
      miningStatus = true;
      _wsReconnectAttempts = 0;
      notifyListeners();

    } catch (e) {
      debugPrint('WebSocket connect error: $e');
      _handleConnectionLost();
    }
  }

  /// Handle connection lost - attempt reconnection
  void _handleConnectionLost() {
    _wsState = WebSocketState.disconnected;
    wsConnected = false;
    miningStatus = false;
    notifyListeners();

    // Attempt auto-reconnection if we have connection params
    if (_lastWsUrl != null && _wsReconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection with exponential backoff
  void _scheduleReconnect() {
    if (_wsReconnectTimer != null) return;

    _wsReconnectAttempts++;
    final delay = Duration(seconds: _wsReconnectAttempts * 5);
    debugPrint('WS: Scheduling reconnect attempt $_wsReconnectAttempts in ${delay.inSeconds}s');

    _wsState = WebSocketState.reconnecting;
    notifyListeners();

    _wsReconnectTimer = Timer(delay, () async {
      _wsReconnectTimer = null;
      if (_lastWsUrl != null &&
          _lastValidatorPubkey != null &&
          _lastValidatorPrivateKey != null) {
        await connectWebSocket(
          wsUrl: _lastWsUrl!,
          validatorPubkey: _lastValidatorPubkey!,
          validatorPrivateKey: _lastValidatorPrivateKey!,
        );
      }
    });
  }

  /// 用户主动断开（退出挖矿 / 登出）
  Future<void> disconnectWebSocket() async {
    // Cancel any pending reconnect
    _wsReconnectTimer?.cancel();
    _wsReconnectTimer = null;
    _wsReconnectAttempts = 0;

    // Clear stored connection params
    _lastWsUrl = null;
    _lastValidatorPubkey = null;
    _lastValidatorPrivateKey = null;

    try {
      await _wsBridge?.disconnect();
    } catch (e) {
      debugPrint('WebSocket disconnect error: $e');
    }

    _wsSubscription?.cancel();
    _wsSubscription = null;

    _wsState = WebSocketState.disconnected;
    wsConnected = false;
    miningStatus = false;
    notifyListeners();
  }


  void handleWebSocketMessage(String message) {
    debugPrint('Received WS: $message');

    switch (message) {
      case 'WebSocket connected':
        _wsState = WebSocketState.connected;
        wsConnected = true;
        miningStatus = true;
        _wsReconnectAttempts = 0;
        notifyListeners();
        getBeaconValidator(); // immediately refresh beacon status on connect/reconnect
        break;

      case 'onFailure':
      case 'onClosed':
        _handleConnectionLost();
        break;

      default:
        // Normal business message handling
        break;
    }
  }


  @override
  void dispose() {
    // Clean up all timers to prevent memory leaks
    endCheckTxHash();
    endWithdrawalTimer();
    endBeaconValidatorTimer();
    _stopStatusPolling();

    // Clean up reconnect timer
    _wsReconnectTimer?.cancel();
    _wsReconnectTimer = null;

    // Clean up WebSocket resources
    _wsSubscription?.cancel();
    _wsSubscription = null;
    _wsBridge?.disconnect();
    _wsBridge = null;

    super.dispose();
  }
}

/// WebSocket connection state
enum WebSocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
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