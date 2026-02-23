import 'dart:async';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v1/models/mining_type.dart';
import 'package:n42_wallet/features/mining_v1/pages/mining_background.dart';
import 'package:n42_wallet/features/mining_v1/pages/mining_task_list.dart';
import 'package:n42_wallet/features/mining_v1/pages/task_detail_page.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_provider.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_plugin_utils.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_utils.dart';
import 'package:n42_wallet/features/mining_v1/widgets/select_plan.dart';
import 'package:n42_wallet/features/mining_v1/widgets/task_item.dart';
import 'package:n42_wallet/features/mining_v1/widgets/task_value_bar.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/custom_popup_menu_wrap.dart';
import 'package:n42_wallet/features/widgets/detail_refresh_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/loading.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';
import 'package:n42_wallet/generated/l10n.dart';

class TodayMiningPage extends StatefulWidget {
  const TodayMiningPage({super.key});

  @override
  State<TodayMiningPage> createState() => _TodayMiningPageState();
}

class _TodayMiningPageState extends State<TodayMiningPage> {

  DataUtils? _dataUtils;
  DataUtils get dataUtils{
    if(_dataUtils==null){
      _dataUtils=DataUtils();
    }
    return _dataUtils!;
  }
  /*FUJINftMiningRpcApi? fUJINftMiningRpcApi;
  FUJINftMiningRpcApi get _fUJINftMiningRpcApi{
    if(fUJINftMiningRpcApi==null){
      fUJINftMiningRpcApi= FUJINftMiningRpcApi();
    }
    return fUJINftMiningRpcApi!;
  }*/
  String astAddress = '';

  //任务列表分页数据
  int pageSize = 5;
  List<dynamic> taskList = [];
  bool isLoadingTaskList = false;

  //当前质押的ast数量
  int currDepositsOfValue = 0;

  //是否可以解除质押
  bool isCanUnlock = false;
  String? lockTimeStr;

  //最近24小时收益
  double last24HValue = 0;
  double totalValue = 0;

  //当前挖矿时间s
  int currMiningTime = 0;

  //转化成【"00"，'00'，'00' 】数组
  List<String> currentMiningTimes = ["00", "00", "00"];

  //Last Cycle’s Mining Time
  List<String> lastCycleMiningTimes = ["00", "00", "00"];

  //上一轮因该发放的奖励
  double lastCycleRewardsValue = 0;

  ///定时器 间隔15s监测挖矿状态
  Timer? _timer;

  double astPrice = 0;

  Load miningStartLoad=Load.finish;

  var eventBusFn;

  @override
  void initState() {
    super.initState();
    eventBusFn=eventBus.on().listen((event) {
      if (event is EventPublic &&
          event.type == EventPublicType.refreshMiningData) {
        initData(forcedRefresh: true);
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (globalMiningV1.miningType == null) {
        return;
      }
      await getMiningStatus();

      if(globalMiningV1.miningStatus == false){
        return;
      }

      //更新时间
      getCurrentMiningTimeByBlockApi();
    });

    initData();
  }

  initData({bool forcedRefresh = false}) async {
    astAddress = globalMiningV1.address??"";
    Map<String,dynamic>? ms=await SPUtil().getMiningStautus();
    Map<String,dynamic>? mValue;
    if(ms !=null){
      mValue=ms[astAddress]?['miningValue'];
    }
    if(mValue ==null){
      if (globalMiningV1.miningType == MiningType.N) {
        await computerMaxY(astAddress);
      }
    }else{
      if (globalMiningV1.miningType == MiningType.N) {
        int value;
        if(AppConfig.isMainChainMining){
          value=ms?[astAddress]?['miningValue']?[MiningType.N.name.toLowerCase()]??0;
        }else{
          value=ms?[astAddress]?['miningValue']?['${MiningType.N.name.toLowerCase()}test']??0;
        }
        await computerMaxY(astAddress,value:value);
      }
    }

    getMiningTaskList(astAddress);
    getMiningStatus();
    await getAstPrice();
    getCurrentMiningTimeByBlockApi();
    totalValueData();


  }


  totalValueData() async {
    Decimal value1 = await getTotalValue(astAddress);
    Decimal value2= await getAccountRewardUnpaid(astAddress);
    totalValue = 0;
    totalValue = value1.toDouble() + value2.toDouble();
    globalMiningV1.setMiningIncome(totalValue);
    if(mounted){
      setState(() {
      });
    }
  }
  getAstPrice() async {
    try {

      final data =
      globalWapAdapter.getCoinPriceWithUnit(CoinType.N.name);
      if (data != null) {
        astPrice = data["coinPrice"];
        debugPrint("astPrice:$astPrice");
      }else{
        var list = await MarketApi().getWalletCoinsInfo('n');
        if (list['error']) {
        } else {
          //查询成功，将币的信息赋值到_coinslist
          List<dynamic> nInfo = list['data']['data'];
          if(nInfo.length !=0){
            astPrice=Decimal.parse(nInfo[0]['price'].toString()).toDouble();
          }
        }
      }
    } catch (err) {
      //err
    }
  }
  ///获取收益 24/h
  get24hour(String astAddress) async {
    try {
      //最近24h收益
      final revenue24Data = await MiningApi.revenue24(astAddress);
      //{jsonrpc: 2.0, id: 1, result: {address: 0x588639773bc6f163aa262245cda746c120676431, data: [{value: 0, timestamp: 1670467644, blockNumber: 0x1}, {value: 0, timestamp: 1670467684, blockNumber: 0x6}]}}
      debugPrint("24H挖矿收益:$revenue24Data");
      if (revenue24Data != null) {
        String total = revenue24Data["result"]['total'];
        if (total.isNotEmpty) {
          BigInt? value = hexToInt(total);
          //_hexUtils.hexToBigInt(total);
          final astNum = toEther("$value", 18).toDouble();
          last24HValue = astNum;
        }
      }
      if (mounted) {
        setState(() {});
      }
    } catch (err) {
      debugPrint("err:${err.toString()}");
    }
  }
  /// 获取最后一次发放奖励之后 挖矿的总时间
  getCurrentMiningTime(String astAddress) async {
    try {
      final data24 = await MiningApi.getCurrentMiningTime(astAddress);
      debugPrint("getCurrentMining Time :$data24");
      //{jsonrpc: 2.0, id: 1, result: {minedBlocks: [], totalBlocks: 0x0}}
      if (data24 != null) {
        String? total = data24["result"]['totalBlocks'];
        if (total !=null && total.isNotEmpty) {
          BigInt value = hexToInt(total);
              //_hexUtils.hexToBigInt(total) ?? BigInt.zero;
          // debugPrint("getCurrentMining value :${value.toString()}");
          BigInt result = value * BigInt.from(8);
          // debugPrint("getCurrentMining result :${result.toString()}");
          currMiningTime = result.toInt();
          if (currMiningTime != 0) {
            currentMiningTimes = formatElapsedTime(currMiningTime);
          }
        }else{
          currMiningTime=0;
        }
      }else{
        currMiningTime=0;
      }
      if (mounted) {
        setState(() {});
      }
    } catch (err) {
      //err
      debugPrint("err:${err.toString()}");
    }
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
  ///获取最后一次发放奖励时到上一次奖励区间做过多少时间的任务
  ///返回任务数 * 8s 就是时间
  getLastCycleMiningTime(String astAddress) async {
    try {
      final data = await MiningApi.getLastCycleMiningTime(astAddress);
      debugPrint("getLastCycleMiningTime Time :$data");
      //{jsonrpc: 2.0, id: 1, result: {minedBlocks: [], totalBlocks: 0x0}}
      if (data != null) {
        String? total = data["result"]?['totalBlocks'];
        if (total!=null && total.isNotEmpty) {
          BigInt value = hexToInt(total);
              //_hexUtils.hexToBigInt(total) ?? BigInt.zero;
          if (value != BigInt.zero) {
            //根据做任务的个数计算奖励值
            computeRewardsValueByTaskNum(value.toInt());
          }
          BigInt result = value * BigInt.from(8);
          debugPrint("getCurrentMining result :${result.toString()}");
          int nums = result.toInt();
          if (nums != 0) {
            lastCycleMiningTimes = formatElapsedTime(nums);
          }else{
            lastCycleMiningTimes== ["00", "00", "00"];
          }
        }else{
          lastCycleMiningTimes== ["00", "00", "00"];
        }
      }else{
        lastCycleMiningTimes== ["00", "00", "00"];
        if (mounted) {
          setState(() {});
        }
      }
    } catch (err) {
      //err
      debugPrint("err:${err.toString()}");
    }
  }
  ///根据任务个数计算奖励值
  computeRewardsValueByTaskNum(int value) {
    // fuji200RewardPerEpoch 每日最大收益  = 0.025 AST 单个任务奖励： 0.025 / 50 = 0.0005
    // fuji800RewardPerEpoch  每日最大收益 = 0.1 AST    单个任务奖励：0.1 / 50 = 0.002
    // fuji2000RewardPerEpoch 每日最大收益 = 0.333333333333333 AST  单个任务奖励：0.333333333333333 / 50 = 0.0066666666666
    // 每日最大任务数 50


    // AST 和 MiningNFT 质押
    // 50 100 500
    if (currDepositsOfValue == 50) {
      if (value >= 500) {
        lastCycleRewardsValue = 0.0125;
      } else {
        lastCycleRewardsValue = value * 0.000025;
      }
    } else if (currDepositsOfValue == 100) {
      if (value >= 100) {
        lastCycleRewardsValue = 0.0333333333333334;
      } else {
        lastCycleRewardsValue = value * 0.000333333333333334;
      }
    } else {
      if (value >= 100) {
        lastCycleRewardsValue = 0.2083333333333334;
      } else {
        lastCycleRewardsValue = value * 0.002083333333333334;
      }
    }
  }
  getTotalValue(String address) async {
    try {
      final totalData = await MiningApi.getTotalMiningValue(address);
      if (totalData["result"] != null) {
        final value  =
        toEther("${BigInt.tryParse(totalData["result"]["total"])}", 18);

        return value;
      }
      return Decimal.zero;
    } catch (err) {
      debugPrint("err:${err.toString()}");
      return Decimal.zero;
    }
  }
  //未发放金额
  getAccountRewardUnpaid(String address) async {
    try {
      final totalData = await MiningApi.getAccountRewardUnpaid(address);
      if (totalData["result"] != null) {
        final value =
        toEther("${BigInt.tryParse(totalData["result"])}", 18);
        return value;
      }
      return Decimal.zero;
    } catch (err) {
      debugPrint("err:${err.toString()}");
      return Decimal.zero;
    }
  }
  //获取锁仓时间
  getLockTime(String address) async {
    try {
      final lockTime = await MiningApi.lockTime(address);
      debugPrint("lockTime data：$lockTime");
      // isCanUnlock
      isCanUnlock = DateTime.now().millisecondsSinceEpoch ~/ 1000 >
          int.parse("${lockTime[0]}");
      debugPrint("解除质押时间到了:$isCanUnlock");
      lockTimeStr = dataUtils.getTimeByTimeStamp("${lockTime[0]}",
          format: "dd/MM/yyyy");
      debugPrint("锁仓时间:$lockTimeStr");
      if (mounted) {
        setState(() {});
      }
    } catch (err) {
      debugPrint("err : ${err.toString()}");
    }
  }
  getMiningStatus() async {
    try {
      //	"data":"started",//started,stopped
      final data = await MiningPluginUtils.status();
      String? status = data?["data"];
      if (status == "stopped") {
        globalMiningV1.setMiningStatus(false);
        MiningUtils.startMining();
      } else {
        globalMiningV1.setMiningStatus(true);
      }
    } catch (err) {
      // err
    }
  }
  ///获取用户质押数量
  computerMaxY(String astAddress,{int? value}) async {
    try {
      if(value==null){
        // 获取质押金额
        final depositsOfResponse = await MiningApi.depositsOf(astAddress);
        // [10]
        debugPrint("depositsOfResponse: $depositsOfResponse");
        if (depositsOfResponse != null && depositsOfResponse is List) {
          BigInt astNum = depositsOfResponse[0];
          final aNumber = toEther("$astNum", 18).toDouble();
          currDepositsOfValue = aNumber.toInt(); //100000000000000000000
          globalMiningV1.setDepositsNum(currDepositsOfValue);
          debugPrint("当前质押ast数量: $currDepositsOfValue");
          if(AppConfig.isMainChainMining){
            setMiningValue("n",currDepositsOfValue);
          }else{
            setMiningValue("ntest",currDepositsOfValue);
          }
        }else{
          currDepositsOfValue=0;
          globalMiningV1.setDepositsNum(currDepositsOfValue);
        }
      }else{
        currDepositsOfValue = value;
        globalMiningV1.setDepositsNum(currDepositsOfValue);
      }
      if (mounted) {
        setState(() {});
      }
    } catch (err) {
      debugPrint("获取质押信息失败：${err.toString()}");
    }
  }
  ///获取挖矿任务列表
  getMiningTaskList(astAddress) async {
    try {
      setState(() {
        isLoadingTaskList = true;
      });
      final data = await MiningApi.getMiningTaskList(astAddress, null,
          pageSize: pageSize);
      debugPrint("mining task list:$data");
      if (data != null) {
        //{blockNumber: 0x235, timestamp: 1671526039, reward: 0x1}
        taskList = data["result"]["minedBlocks"] ?? [];
        if (taskList.isNotEmpty && taskList.length >= pageSize) {
          taskList.add(null);
        }
      } else {
        taskList = [];
      }
    } catch (err) {
      taskList = [];
      debugPrint("mining task list err:${err.toString()}");
    } finally {
      isLoadingTaskList = false;
      setState(() {});
    }
  }
  //使用区块链浏览器提供的接口查询当天挖矿情况
  void getCurrentMiningTimeByBlockApi() async {
    try {
      final list = await MiningApi.getMiningBarChartData(astAddress);
      final lastEpochNum = await MiningApi.getLastEpochNum();
      final currentEpochNum = lastEpochNum + 1;
      if (list != null) {
        final items = list["items"];
        if (items != null && items is List) {
          handCurrentMiningTime(items, currentEpochNum);
          handYesterDayMiningTime(items, lastEpochNum);
        }
      }
    } catch (err) {
      debugPrint("getCurrentMiningTimeByBlockApi fun err:${err.toString()}");
      //如果区块链浏览器接口挂架 直接从链上获取数据
      getCurrentMiningTime(astAddress);
      getLastCycleMiningTime(astAddress);
    }
  }
  handCurrentMiningTime(List items, int currentEpochNum) {
    var item = items.firstWhere(
            (element) => element["epoch"] == currentEpochNum,
        orElse: () => -1);
    if (item != -1) {
      final verifyCount = item["verify_count"];
      currMiningTime = verifyCount * 8;
      if (currMiningTime != 0) {
        currentMiningTimes = formatElapsedTime(currMiningTime);
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      //区块链没有同步最新数据
      getCurrentMiningTime(astAddress);
    }
  }
  handYesterDayMiningTime(List items, int lastEpochNum) {
    var item = items.firstWhere((element) => element["epoch"] == lastEpochNum,
        orElse: () => -1);
    if (item != -1) {
      final verifyCount = item["verify_count"];
      int timeSeconds = verifyCount * 8;
      if(timeSeconds>86400){
        timeSeconds=86400;
      }
      if (timeSeconds != 0) {
        lastCycleMiningTimes = formatElapsedTime(timeSeconds);
        computeRewardsValueByTaskNum(verifyCount);
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      //区块链没有同步最新数据
      getLastCycleMiningTime(astAddress);
    }
  }
  setMiningValue(String key,dynamic value)async{
    SPUtil().setMiningStatus_child(astAddress,key, value);
  }
  @override
  void dispose() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    super.dispose();
    eventBusFn.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DetailRefreshWidget(
          callback: () async {
            initData();
          },
          childWidget: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30),
              right: ScreenUtil().setWidth(30),
              //bottom: ScreenUtil().setWidth(30),
            ),
            child: ListenableBuilder(
              listenable: globalMiningV1,
              builder: (context, _) {
                final mpValue = globalMiningV1;
                return Column(
                  children: [
                    //没有质押展示 选择plans
                    if (mpValue.miningType == null)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: ScreenUtil().setWidth(18),
                          ),
                          SelectPlan(
                            onTap: null,
                          ),
                          SizedBox(
                            height: ScreenUtil().setWidth(10),
                          ),
                        ],
                      ),
                    miningStatusWidget(mpValue),

                    SizedBox(
                      height: ScreenUtil().setWidth(20),
                    ),
                    dayMiningTimeWidget(mpValue),
                    SizedBox(
                      height: ScreenUtil().setWidth(20),
                    ),
                    backgroundMiningWidget(mpValue),
                    Row(
                      children: [
                        miningDataBroad(S.of(context).g_mining_key_10,
                            "${lastCycleMiningTimes[0]}:${lastCycleMiningTimes[1]}:${lastCycleMiningTimes[2]}",
                            imagePath: "assets/mining/broad_bg_3.png"),
                        SizedBox(
                          width: ScreenUtil().setWidth(20),
                        ),
                        miningDataBroad(
                          // "Last Rewards",
                            S.of(context).g_mining_key_11,
                            "${dataUtils.formatNum(lastCycleRewardsValue, 4)} ${CoinType.N.name}",
                            imagePath: "assets/mining/broad_bg_4.png",
                            tipsText:
                            // "Reward accumulates daily and is only sent to your AST wallet when it reaches ~0.5 AST.",
                            S.of(context).g_mining_key_12,
                            showTips: true),
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(20),
                    ),
                    Row(
                      children: [
                        miningDataBroad(
                          // "Total Rewards:",
                          S.of(context).g_mining_key_13,
                          '${dataUtils.doubleFixed(totalValue, 2)} ${CoinType.N.name}',
                          imagePath: "assets/mining/broad_bg_1.png",
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(20),
                        ),
                        miningDataBroad(S.of(context).g_mining_key_14,
                            "\$${NumberFormat("#,##0.0#", "en_US").format((astPrice * totalValue))}",
                            imagePath: "assets/mining/broad_bg_2.png",
                            tipsText:
                            // "Calculated based on market price of AST * the total AST rewards.",
                            S.of(context).g_mining_key_15,
                            showTips: true),
                      ],
                    ),
                    miningActivityWidget(mpValue),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  yourTierWidget() {
    return Row(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30),
              vertical: ScreenUtil().setWidth(26),
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).g_mining_key38,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(24),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(30),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$currDepositsOfValue ${CoinType.N.name}',
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemTextColor.name),
                        fontSize: ScreenUtil().setSp(32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: ScreenUtil().setWidth(24),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30),
              vertical: ScreenUtil().setWidth(26),
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Tier Value",
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(24),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(30),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${NumberFormat("#,##0.0#", "en_US").format((astPrice * currDepositsOfValue))}",
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemTextColor.name),
                        fontSize: ScreenUtil().setSp(32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  miningStatusWidget(MiningProvider mpValue) {
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(18),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30),
                vertical: ScreenUtil().setWidth(26),
              ),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          // "Mining Status",
                          S.of(context).g_mining_key_5,
                          maxLines: 2,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(24),
                          ),
                        ),
                      ),
                      Container(
                        height: ScreenUtil().setWidth(32),
                        width: ScreenUtil().setWidth(32),
                        margin: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                        padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                        decoration: BoxDecoration(
                          color: mpValue.miningType != null &&
                              mpValue.miningStatus == true
                              ? const Color.fromRGBO(50, 215, 75, 0.2)
                              : const Color.fromRGBO(235, 88, 81, 0.2),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                        ),
                        child: Container(
                          height: ScreenUtil().setWidth(16),
                          width: ScreenUtil().setWidth(16),
                          decoration: BoxDecoration(
                            color: mpValue.miningType != null &&
                                mpValue.miningStatus == true
                                ? const Color(0xff32D74B)
                                : const Color(0xffEB5851),
                            borderRadius:
                            BorderRadius.circular(ScreenUtil().setWidth(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(30),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mpValue.miningType != null &&
                            mpValue.miningStatus == true
                            ? S.current.g_key_193
                            : S.current.g_mining_key_47,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemTextColor.name),
                          fontSize: ScreenUtil().setSp(32),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if(miningStartLoad==Load.loading){
                            return;
                          }
                          if (mpValue.miningType == null) {
                            //未开启挖矿
                            return;
                          }
                          setState(() {
                            miningStartLoad=Load.loading;
                          });
                          if (mpValue.miningStatus == true) {
                            //停止
                            SPUtil().setMiningOpen(false);
                            globalMiningV1
                                .setMiningStatus(false);
                            await MiningUtils.stopMining();
                          } else {
                            //开启
                            SPUtil().setMiningOpen(true);
                            globalMiningV1.setMiningStatus(true);
                            await MiningUtils.startMining();
                          }
                          setState(() {
                            miningStartLoad=Load.finish;
                          });
                        },
                        child: Container(
                          height: ScreenUtil().setWidth(40),
                          width: ScreenUtil().setWidth(40),
                          child: miningStartLoad==Load.finish?Image.asset(
                            "assets/mining/${mpValue.miningType != null && mpValue.miningStatus == true ? 'stop' : 'play'}.png",
                            color: AppThemeUtils.getColorByKey(
                                context,
                                mpValue.miningType != null &&
                                    mpValue.miningStatus == true
                                    ? AppThemeKeys.mainBlueColor.name
                                    : AppThemeKeys.iconTextDisableColor.name),
                            height: ScreenUtil().setWidth(40),
                            width: ScreenUtil().setWidth(40),
                          ):CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(22),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30),
                vertical: ScreenUtil().setWidth(26),
              ),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).g_mining_key38,
                    // "Your Tier",
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(24),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(30),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mpValue.miningType == null ? "0 ${CoinType.N.name}" :'$currDepositsOfValue ${CoinType.N.name}',
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemTextColor.name),
                          fontSize: ScreenUtil().setSp(32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  dayMiningTimeWidget(MiningProvider mpValue) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(18),
        horizontal: ScreenUtil().setWidth(30),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/mining/daily_mining_time.png',
            height: ScreenUtil().setWidth(84),
            width: ScreenUtil().setWidth(84),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
              ),
              child: Text(
                // 'Current Mining Time',
                S.of(context).g_mining_key_8,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          showTimeWidget(currentMiningTimes[0], currentMiningTimes[1],
              currentMiningTimes[2])
        ],
      ),
    );
  }
  nextRewardInWidget() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(18),
        horizontal: ScreenUtil().setWidth(30),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/mining/next_reward_in.png',
            height: ScreenUtil().setWidth(84),
            width: ScreenUtil().setWidth(84),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20),
              ),
              child: Text(
                '24H Reward',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Text(
            "${dataUtils.doubleFixed(last24HValue, 3)}${CoinType.N.name}",
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(26)),
          )
        ],
      ),
    );
  }
  showTimeWidget(String hh, String mm, String ss) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.timeBorderColor.name))),
          padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
          child: Text(
            hh,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(26)),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(12)),
          child: Text(
            ":",
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(26)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.timeBorderColor.name))),
          padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
          child: Text(
            mm,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(26)),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(12)),
          child: Text(
            ":",
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(26)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.timeBorderColor.name))),
          padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
          child: Text(
            ss,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(26)),
          ),
        ),
      ],
    );
  }
  backgroundMiningWidget(MiningProvider mpValue) {
    if (mpValue.depositsEnable == false){
      return SizedBox();
    }
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(18),
        horizontal: ScreenUtil().setWidth(30),
      ),
      margin: EdgeInsets.only(bottom:ScreenUtil().setWidth(20) ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/mining/backgroundmining.png',
            height: ScreenUtil().setWidth(84),
            width: ScreenUtil().setWidth(84),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
              ),
              child: Text(
                // 'Background Mining',
                S.of(context).g_mining_key_9,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          buttonStyle3(
            context,
                () {
              if (mpValue.depositsEnable == true) {
                MiningBackground().background_start();
              }
            },
            S.of(context).g_key_wallet_c4,
            mpValue.depositsEnable == true
                ? const Color(0xffD1E4FE)
                : const Color(0xffEDEFF2),
            mpValue.depositsEnable == true
                ? const Color(0xff1976F9)
                : const Color(0xffBAC2CC),
            height: ScreenUtil().setWidth(55),
            borderRadius: ScreenUtil().setWidth(55),
            fontSize: ScreenUtil().setSp(22),
            paddingV:ScreenUtil().setWidth(12.0),
            paddingH: ScreenUtil().setWidth(32.0),
          ),
        ],
      ),
    );
  }
  miningActivityWidget(MiningProvider mpValue) {
    if (mpValue.depositsEnable == true) {
      return Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(20)),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              // "Mining Activity",
              S.of(context).g_mining_key31,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(40),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ScreenUtil().setWidth(16)),
                  topRight: Radius.circular(ScreenUtil().setWidth(16)),
                ),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TaskValueBar(),
                  isLoadingTaskList
                      ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
                        child: Loading(),
                      ))
                      : taskList.isEmpty
                      ? Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
                          child: EmptyView(),
                        ),
                        SizedBox(
                          height: ScreenUtil().setWidth(120),
                        )
                      ],
                    ),
                  )
                      : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 0),
                        itemBuilder: (context, index) {
                          var item = taskList[index];
                          if (item == null) {
                            return GestureDetector(
                              onTap: () async {
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            MiningTaskList(
                                              address: astAddress,
                                            )));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color:
                                    AppThemeUtils.getColorByKey(
                                        context,
                                        AppThemeKeys
                                            .itemBgColor.name)),
                                child: Center(
                                  child: Text(
                                    "${S.of(context).g_mining_key_49}...",
                                    style: TextStyle(
                                        color: AppThemeUtils
                                            .getColorByKey(
                                            context,
                                            AppThemeKeys
                                                .mainBlueColor.name),
                                        fontSize: ScreenUtil().setSp(30)),
                                  ),
                                ),
                              ),
                            );
                          }

                          return GestureDetector(
                            onTap: () async {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                  builder: (_) => TaskDetailPage(
                                    blockNumber:
                                    "${item["blockNumber"]}",
                                    astValue: dataUtils.formatNum(
                                        toEther(
                                            "${BigInt.tryParse(item["reward"])}",
                                            18).toDouble(),
                                        8),
                                  )));
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(20)),
                              // //{blockNumber: 0x235, timestamp: 1671526039, reward: 0x1}
                              child: TaskItem(
                                taskId:
                                "${BigInt.tryParse(item["blockNumber"])}",
                                astValue: dataUtils.formatNum(
                                    toEther(
                                        "${BigInt.tryParse(item["reward"])}",
                                        18).toDouble(),
                                    8),
                                time: dataUtils.getTimeByTimeStamp(
                                    "${item["timestamp"]}",
                                    format: "dd/MM HH:mm"),
                                status: "success",
                              ),
                            ),
                          );
                        },
                        itemCount: taskList.length,
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(120),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: ScreenUtil().setWidth(120),
    );
  }
  miningDataBroad(String titleText, String value,
      {bool showTips = false, String? imagePath, String? tipsText}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
        padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30), ScreenUtil().setWidth(30),
            ScreenUtil().setWidth(0), ScreenUtil().setWidth(0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      titleText,
                      maxLines: 2,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.ff888888.name),
                          fontSize: ScreenUtil().setSp(22)),
                    ),
                  ),
                  if (showTips)
                    CustomPopupMenuWrap(
                        key: ValueKey(titleText),
                        verticalMargin: ScreenUtil().setWidth(24),
                        defView: Padding(
                          padding: EdgeInsets.only(left: ScreenUtil().setWidth(12)),
                          child: Image.asset(
                            "assets/mining/tips_icon.png",
                            width: ScreenUtil().setWidth(20),
                            fit: BoxFit.cover,
                          ),
                        ),
                        menuItemView: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(50)),
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemBgColor.name),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(100)),
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(28), vertical: ScreenUtil().setWidth(30)),
                          child: Text(
                            tipsText ?? '',
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(24)),
                          ),
                        ))
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(30)),
                ),
                Image.asset(
                  imagePath ?? '',
                  width: ScreenUtil().setWidth(90),
                  height: ScreenUtil().setWidth(90),
                  fit: BoxFit.cover,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
