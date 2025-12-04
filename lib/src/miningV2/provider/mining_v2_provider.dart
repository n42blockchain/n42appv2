import 'dart:async';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/miningV2/api/mining_api.dart';
import 'package:n42appv2/src/miningV2/api/mining_web3.dart';
import 'package:n42appv2/src/miningV2/models/miningWithdrawalsDaily.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/src/utils/event_bus.dart';
import 'package:n42appv2/src/utils/sp_util.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/src/widgets/chart_histogram.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class MiningV2Provider extends ChangeNotifier {
  MiningApi? mining=null;
  MiningApi? get Mining{
    if(mining==null){
      mining=MiningApi.init();
    }
    return mining;
  }
  MiningWeb3? web3=null;
  MiningWeb3? get Web3{
    if(web3==null){
      web3=MiningWeb3.init(privateKey??"");
    }
    return web3;
  }
  //是否已经质押
  bool? depositsEnable=null;
  bool miningStatus = false;

  setDepositsEnable(bool? flag) {
    depositsEnable = flag??false;
    notifyListeners();
  }

  setMiningStatus(bool status) {
    miningStatus = status;
    notifyListeners();
  }

  bool isLoadingMiningDeposits = false;

  setLoadingDeposits(bool flag) {
    isLoadingMiningDeposits = flag;
    notifyListeners();
  }

  int depositsNum = 0;
  double miningIncome = 0;

  setDepositsNum(int num) {
    depositsNum = num;
    notifyListeners();
  }

  setMiningIncome(double num) {
    miningIncome = num;
    notifyListeners();
  }

  int mainChainMining = 0;

  setMiningDev(int num) {
    mainChainMining = num;
    notifyListeners();
  }

  String walletName="";
  String? address=null;

  resetData() {
    mining=null;
    web3=null;
    depositsEnable = false;
    miningStatus = false;
    isLoadingMiningDeposits = false;
    depositsNum = 0;
    miningIncome = 0;
    walletName="";
    address=null;
    notifyListeners();
  }





  /// 抱团挖矿/质押NFT/质押AST
  /// 新增：FUJI NFT 质押
  Future<void> checkAddressMiningStatus() async {
    try {
      WalletActionProvider wap=Provider.of<WalletActionProvider>(Application.AppContext,listen: false);
      Map<String,dynamic> cInfo=wap.walletInfoLsit[wap.walletMiningIndex].coinInfo?[CoinType.N.name];
      WalletInfo info = wap.walletInfoLsit[wap.walletMiningIndex];
      Map<String, dynamic> pathMap = cInfo['baseInfo']['path'];
      var rm=await Trustdart().generateAddress(
          CoinType.N.name,
          getPathWithIndex(pathMap[cInfo['addrType']], cInfo['pathIndex']),
          cInfo['addrType'],
          mnemonic: info.mnemonic??"",
          pk: info.privateKey??""
      );
      address =rm[cInfo['addrType']];
      await getWalletPrivateKey();
      setLoadingDeposits(true);
      walletName=info.walletName??"";
      if (address == null) return;
      await getMiningData();
      if(depositsEnable==true){
        runMining();
      }
      getNprice(wap);
      loadMiningData();
    } catch (err) {
      setDepositsEnable(null);
      debugPrint("checkAddressMiningStatus err：${err.toString()}");
    } finally {
      setLoadingDeposits(false);
      notifyListeners();
    }
  }
  loadMiningData()async {
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
      barchartValues = [0, 0, 0, 0, 0, 0, 0];
      barchartAlertMessageList = [];
      barchartTitle=[];
      isLoading7DayData=false;
      isShowDefaultBar=true;
      showRedemption=false;
      exitDepositLoad=Load.finish;
      depositLoad=Load.finish;

      endWithdrawalTimer();
    }
  }
  getNprice(WalletActionProvider wap)async{
    Map<String,dynamic>? coinInfo=await wap.getCoinPriceWithUnit(CoinType.N.name);
    nPrice=coinInfo?['coinPrice']??0;
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
  Map<String,dynamic>? miningKeypart=null;
  generateBls12381Keypair()async{
    if(miningKeypart !=null){
      if(miningKeypart!['isMining']==true){
        return;
      }
    }
    Map<String,String>? rdata=await Mining?.generateBls12381Keypair();
    if(rdata !=null){
      miningKeypart=rdata;
      //setMiningData(miningKeypart!,depositsEnable);
    }
  }
  Map<String,dynamic>? miningData;
  setMiningData(Map<String,dynamic> keypart,bool isMining)async{
    SPUtil().setMiningData({
      address!:{
        'isMining':isMining,
        'keypart':keypart,
      }
    });
  }
  setMiningData_import(Map<String,dynamic> value)async{
    WalletActionProvider wap=Provider.of<WalletActionProvider>(Application.AppContext,listen: false);
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
        bool checkMnemonic =await Trustdart().checkMnemonic(value['mnemonicWords']);
        if (checkMnemonic == false) {
          //助记词输入错误
          MessageModel rmm=MessageModel.error();
          rmm.data=S.current.w_key_12;
          return rmm ;
        }else{
          wInfo = WalletInfo(
            mnemonic: value['mnemonicWords'],
          );
        }
      }else{
        wInfo = WalletInfo(
          privateKey: value['privateKey'],
        );
      }
      wInfo.walletName="Account${wap.walletInfoLsit.length+1}";
      wInfo.UUID=wap.UserUUID;
      wInfo.password="";
      wInfo.coinInfo=chainUrlMap;
      wInfo.timestamp = "${DateTime.now().millisecondsSinceEpoch}";
    }else{
      wInfo=wap.walletInfoLsit[index];
    }

    Map<String,dynamic> cInfo=wInfo.coinInfo?[CoinType.N.name];
    Map<String, dynamic> pathMap = cInfo['baseInfo']['path'];
    var rmAddress=await Trustdart().generateAddress(
        CoinType.N.name,
        getPathWithIndex(pathMap[cInfo['addrType']], cInfo['pathIndex']),
        cInfo['addrType'],
        mnemonic: wInfo.mnemonic??"",
        pk: wInfo.privateKey??""
    );
    importAddress=rmAddress[cInfo['addrType']];
    if(index ==-1){
      await wap.addWalletInfo(wInfo);
    }

    if(miningData?[importAddress] == null){
      miningData![importAddress]={
        'isMining':true,
        'keypart':value['validator']
      };
      SPUtil().setMiningData(miningData!);
      if(depositsEnable == false){
        if(index ==-1){
          wap.setWalletMiningIndex(wap.walletIndex);
        }else{
          wap.setWalletMiningIndex(index);
        }
      }
      MessageModel rmm=MessageModel();
      return rmm;
    }else{
      MessageModel rmm=MessageModel.error();
      //"验证者已经存在";
      rmm.data=S.current.g_mining_key_83;
      return rmm;
    }
  }
  getMiningData()async{
    miningData=await SPUtil().getMiningData();
    depositsEnable=miningData?[address!]?['isMining']??false;
    miningKeypart=miningData?[address!]?['keypart']??{};
  }

  //质押
  Load depositLoad=Load.finish;
  createDepositUnsignedTx(int amount,Map<String,dynamic> encrypteData)async{
    try{
      depositLoad=Load.loading;
      notifyListeners();
      miningKeypart=encrypteData['validator'];
      String? rData=await Mining?.createDepositUnsignedTx(
        miningKeypart?['privateKey']??"",
        address??"",
        DataUtils().bigIntToHex(ethToWeiString('${amount}', 18)),
      );
      if(rData !=null){
        MessageModel sendMM=await Web3?.sendDepositTransaction(jsonDecode(rData));
        if(sendMM.error==false){
          depositsNum=amount;
          setDepositTxHash(sendMM.data);
          errorMessage="";
        }else{
          errorMessage=sendMM.data;
          depositLoad=Load.finish;
        }
        notifyListeners();
      }
    }catch(e){
      ToastUtils.show(e.toString());
      depositLoad=Load.finish;
      notifyListeners();
    }

  }
  startCheckDepositTxHash(String txHash){
    _timer=Timer.periodic(const Duration(seconds: 5), (timer) async {
      if(await checkTxHash(txHash)==false){
        endCheckTxHash();
        depositsEnable=true;
        depositLoad=Load.finish;
        notifyListeners();
        setMiningData(miningKeypart!, true);
        eventBus.fire(EventPublic(EventPublicType.miningFullNode));
        runMining();
      }
    });
  }
  Load exitDepositLoad=Load.finish;
  createExitDepositUnsignedTx()async{
    exitDepositLoad=Load.loading;
    notifyListeners();
    String? feeWeiInHexTx=await miningCreateGetExitFeeUnsignedTx();
    if(feeWeiInHexTx ==null){
      errorMessage="‘miningCreateGetExitFeeUnsignedTx’ method error！";
      exitDepositLoad=Load.finish;
      notifyListeners();
      return;
    }
    MessageModel feeMM=await Web3?.exitDepositRowCall(feeWeiInHexTx);
    if(feeMM.error) {
      errorMessage=feeMM.data;
      exitDepositLoad=Load.finish;
      notifyListeners();
      return;
    }
    final exitSignDataStr=await miningCreateExitUnsignedTx(feeMM.data);
    MessageModel sendMM=await Web3?.sendExitDepositTransaction(jsonDecode(exitSignDataStr));
    if(sendMM.error==false){
      depositsNum=0;
      setExitDepositTxHash(sendMM.data);
      errorMessage="";
    }else{
      errorMessage=sendMM.data;
      exitDepositLoad=Load.finish;
    }
    notifyListeners();
  }
  startCheckExitDepositTxHash(String txHash){
    _timer=Timer.periodic(const Duration(seconds: 5), (timer) async {
      if(await checkTxHash(txHash)==false){
        endCheckTxHash();
        depositsEnable=false;
        miningStatus=false;
        exitDepositLoad=Load.finish;
        loadMiningData();
        notifyListeners();
        setMiningData(miningKeypart!, false);
      }
    });
  }
  endCheckTxHash(){
    if(_timer !=null){
      _timer!.cancel();
      _timer=null;
    }
  }
  checkTxHash(String txHash)async{
    MessageModel rmm=await Web3?.getTransactionReceipt(txHash);

    return rmm.error;
  }
  runMining()async{
    String? rData=await Mining?.runClent(
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
  Timer? _timer=null;
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
  miningCreateGetExitFeeUnsignedTx()async{
    String? rData=await Mining?.miningCreateGetExitFeeUnsignedTx();
    return rData;
  }
  miningCreateExitUnsignedTx(String feeWeiInHex)async{
    String? rData=await Mining?.miningCreateExitUnsignedTx(feeWeiInHex,miningKeypart?['publicKey']??"");
    return rData;
  }

  String? privateKey=null;
  getWalletPrivateKey()async{
    WalletActionProvider wap=Provider.of<WalletActionProvider>(Application.AppContext,listen: false);
    String? pk=wap.walletInfoLsit[wap.walletMiningIndex].privateKey;
    if(pk==null){
      Map<String,dynamic> nCoinInfo=wap.walletInfoLsit[wap.walletMiningIndex].coinInfo![CoinType.N.name];
      Map<String, dynamic> pathMap = nCoinInfo['baseInfo']['path'];
      privateKey=await Trustdart().getPrivateKey(wap.walletInfoLsit[wap.walletMiningIndex].mnemonic!, CoinType.N.name, getPathWithIndex(pathMap['legacy'], nCoinInfo['pathIndex']),);
    }else{
      privateKey=pk;
    }
    if(privateKey==null){
      errorMessage="PrivateKey not null!";
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
  List<AlertMessageGroup> barchartAlertMessageList = [];
  List<String> barchartTitle=[];
  bool isLoading7DayData=false;
  bool isShowDefaultBar=true;

  Timer? withdrawalTimer=null;
  startWithdrawalTimer(){
    if(withdrawalTimer !=null){
      if(withdrawalTimer!.isActive){
        return;
      }
    }
    withdrawalTimer = Timer.periodic(const Duration(seconds: 128), (timer) async {
      getMiningWithdrawalsDaily();
    });
  }
  endWithdrawalTimer(){
    if(withdrawalTimer !=null){
      if(withdrawalTimer!.isActive){
        withdrawalTimer!.cancel();
        withdrawalTimer=null;
      }
    }
  }
  getMiningWithdrawalsDaily()async{
    if(isLoading7DayData)return;
    final DateTime today = DateTime.now();//今天
    final DateTime tomorrow =today.add(const Duration(days: 1));//后天
    final DateTime yesterday=today.add(const Duration(days: -1));//昨天
    final List<String> tomorrowStr = getTimeFormat(tomorrow);
    isLoading7DayData=true;
    notifyListeners();
    MessageModel? rmm= await Mining?.getMiningWithdrawalsDaily(tomorrowStr[0], address??"");
    if(rmm !=null){
      if(rmm.error==false){
        //有效挖矿1次时间是128秒
        taskList=rmm.data;
        final List<String> todayStr = getTimeFormat(today);
        final List<String> yesterdayStr = getTimeFormat(yesterday);
        int tIndex=taskList.indexWhere((e)=>e.day==todayStr[0]);
        int yIndex=taskList.indexWhere((e)=>e.day==yesterdayStr[0]);
        if(tIndex !=-1){
          todayCycleRewardsValue=toEther(taskList[tIndex].total_amount??'0', 18).toDouble();
        }else{
          todayCycleRewardsValue=0;
        }
        if(yIndex !=-1){
          yesterdayCycleRewardsValue=toEther(taskList[yIndex].total_amount??'0', 18).toDouble();
        }else{
          yesterdayCycleRewardsValue=0;
        }
        get7DaysValue(today);
        startWithdrawalTimer();
      }
    }
    MessageModel? rmms=await Mining?.getMiningWithdrawalsDailySummary(address??"");
    if(rmms !=null){
      if(rmms.error==false){
        miningTotalRevenue=toEther(rmms.data, 18).toDouble();
      }
    }
    isLoading7DayData=false;
    notifyListeners();
  }
  getTimeFormat(DateTime date){
    final String year = date.year.toString();
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return ["$year-$month-$day","$day/$month"];
  }
  /// 将秒数转换为时分秒格式的字符串，并补齐两位
  formatElapsedTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    // 使用padLeft方法补齐两位
    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return [hoursStr, minutesStr, secondsStr];
  }
  get7DaysValue(DateTime date){
    for(int i=0;i<7;i++){
      DateTime d1=date.add(Duration(days: -(6-i)));
      final List<String> d1Str = getTimeFormat(d1);
      barchartTitle.add(d1Str[1]);
      int tIndex=taskList.indexWhere((e)=>e.day==d1Str[0]);
      if(tIndex !=-1){
        barchartValues[i]=(taskList[tIndex].count??0).toDouble();
      }else{
        barchartValues[i]=0;
      }
    }
    generateBarTipData();
    isShowDefaultBar=false;
  }
  //生成图标点击事件展示数据
  generateBarTipData() {
    if (barchartValues.isNotEmpty && barchartValues.length == 7) {
      barchartAlertMessageList = [];
      //计算奖励
      //final stackAstNum = Provider.of<MiningProvider>(context,listen: false).depositsNum;
      for (var element in barchartValues) {
        //计算时间
        int times = (element * 8).toInt();
        final timeData = formatElapsedTime(times);
        //final value = computeRewardsValueByTaskNum(element.toInt(), stackAstNum);
        // debugPrint("奖励值：$value");
        barchartAlertMessageList.add(
          AlertMessageGroup(
            titles: [
              S.current.g_mining_key_23,
              "$timeData",
              "",
              S.current.g_mining_key_24,
              "0N"
              //"${dataUtils.formatNum(value, 4)} ${CoinType.N.name}"
            ],
            styles: [
              TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: AppThemeUtils.getColorByKey(
                    Application.AppContext, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(10),
                color: AppThemeUtils.getColorByKey(
                    Application.AppContext, AppThemeKeys.itemTextColor.name),
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: AppThemeUtils.getColorByKey(
                    Application.AppContext, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(10),
                color: AppThemeUtils.getColorByKey(
                    Application.AppContext, AppThemeKeys.itemTextColor.name),
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: AppThemeUtils.getColorByKey(
                    Application.AppContext, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        );
      }
    }
  }
  double balanceInBeacon=0;
  List<double> inactivityScore=[0,0,0,0];
  String inactivityScorePercentage="0";
  String inactivityTitle="";
  bool showRedemption=false;
  getBeaconValidator()async{
    MessageModel rmm=await Mining?.getBeaconValidator(miningKeypart?['publicKey']??"");
    if(rmm.error ==false){
      inactivityScore=[0,0,0,0];
      balanceInBeacon=toEther((rmm.data?['balance_in_beacon']??0).toString(), 9).toDouble();
      int iscore=rmm.data?['inactivity_score']??0;
      double isp=((iscore/3600)*100);
      inactivityScorePercentage=isp.toStringAsFixed(2);
      if(isp<=25){
        inactivityTitle=S.current.g_mining_key_84;//"Low Risk";
      }else if(isp<=50){
        inactivityTitle=S.current.g_mining_key_85;//"Moderately Low Risk";
      }
      else if(isp<=75){
        inactivityTitle=S.current.g_mining_key_86;//"Moderately High Risk";
      }
      else{
        inactivityTitle=S.current.g_mining_key_87;//"High Risk";
      }
      if(iscore!=0){
        for(int i=0;i<4;i++){
          if(iscore-(i+1)*900<=0){
            inactivityScore[i]=(iscore-(i)*900)/900;
            break;
          }else{
            inactivityScore[i]=1;
          }
        }
      }
      int timestamp=rmm.data['activation_timestamp'];
      final int currentTimestamp=DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final int readyTimestamp=timestamp+640;
      if(readyTimestamp>currentTimestamp){
        showRedemption=false;
        final int waitSeconds=readyTimestamp-currentTimestamp;
        Future.delayed(Duration(seconds: waitSeconds),(){
          getBeaconValidator();
        });
      }else{
        showRedemption=true;
      }
      notifyListeners();
    }
  }
}