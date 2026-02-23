
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v1/models/mining_type.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_provider.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_utils.dart';
import 'package:n42_wallet/features/mining_v1/widgets/task_item.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/utils/toast_utils.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/chart_histogram.dart';
import 'package:n42_wallet/features/widgets/detail_refresh_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:web3dart/web3dart.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  Load load=Load.finish;
  /*HexUtils? hexUtils;
  HexUtils get _hexUtils{
    if(hexUtils==null){
      hexUtils= HexUtils();
    }
    return hexUtils!;
  }*/
  DataUtils? _dataUtils;
  DataUtils get dataUtils{
    if(_dataUtils==null){
      _dataUtils=DataUtils();
    }
    return _dataUtils!;
  }
  List<dynamic> rewardsList = [];
  String? astAddress;

  //totalValue = rewardsReceived + accumulatedRewards
  double totalValue = 0;

  //已经发放奖励
  double rewardsReceived = 0;

  //未发放奖励
  double accumulatedRewards = 0;

  double astPrice = 0;

  bool isCanUnlock = false;
  String? lockTimeStr;

  List<double> barValues = [0, 0, 0, 0, 0, 0, 0];
  List<int> epochList = [];
  List<AlertMessageGroup> alertMessageList = [];

  bool isLoading7DayData = false;

  //显示默认柱状图
  bool isShowDefaultBar = true;
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

    initData();
  }
  @override
  void dispose() {
    super.dispose();
    eventBusFn.cancel();
  }
  initData({bool forcedRefresh = false}) async {
    astAddress = globalMiningV1.address??"";
    if (globalMiningV1.miningType == null) {
    }
    if (globalMiningV1.miningType == MiningType.N) {
      getLockTime(astAddress ?? '');
    }

    totalValueData();
    getRewardsList();
    miningBarchartData();
  }

  totalValueData() async {
    await getAstPrice();
    await getTotalValue(astAddress ?? '');
    await getAccountRewardUnpaid(astAddress ?? '');
    totalValue = 0;
    totalValue = rewardsReceived + accumulatedRewards;
    globalMiningV1.setMiningIncome(totalValue);
    // debugPrint("累计收益：$totalValue");
    if (mounted) {
      setState(() {});
    }
  }

  //七天挖矿数据
  miningBarchartData() async {
    try {
      setState(() {
        isLoading7DayData = true;
      });
      epochList = await MiningApi.generateRewardsArray();
      debugPrint("epoch list:$epochList");
      if (epochList.isNotEmpty) {
        final list = await MiningApi.getMiningBarChartData(astAddress ?? '',
            currEpochNum: epochList[epochList.length - 1]);
        if (list != null) {
          final items = list["items"];
          if (items != null && items is List) {
            barValues = [];
            for (var element in epochList) {
              final item = items.firstWhere(
                      (value) => value["epoch"] == element,
                  orElse: () => -1);
              if (item != -1) {
                barValues.add((item["verify_count"] as int).toDouble());
              } else {
                barValues.add(0);
              }
            }
          }
        }
      }
    } catch (err) {
      barValues = [];
      debugPrint("miningBarchartData fun err:${err.toString()}");
    } finally {
      //生成图标点击事件展示数据
      generateBarTipData();
      isShowDefaultBar = false;
       debugPrint("barValues:$barValues");
      if (barValues.isEmpty || barValues.length != 7) {
        barValues = [0, 0, 0, 0, 0, 0, 0];
        isShowDefaultBar = true;
      }
      isLoading7DayData = false;
      if (mounted) {
        setState(() {});
      }
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
    return "$hoursStr:$minutesStr:$secondsStr";
  }

  //生成图标点击事件展示数据
  generateBarTipData() {
    if (barValues.isNotEmpty && barValues.length == 7) {
      alertMessageList = [];
      //计算奖励
      final stackAstNum = globalMiningV1.depositsNum;
      for (var element in barValues) {
        //计算时间
        int times = (element * 8).toInt();
        final timeData = formatElapsedTime(times);
        final value =
        computeRewardsValueByTaskNum(element.toInt(), stackAstNum);
        // debugPrint("奖励值：$value");
        alertMessageList.add(
          AlertMessageGroup(
            titles: [
              S.of(context).g_mining_key_23,
              "$timeData",
              // "",
              // "Blocks Mined:",
              // "$element Blocks",
              "",
              S.of(context).g_mining_key_24,
              "${dataUtils.formatNum(value, 4)} ${CoinType.N.name}"
            ],
            styles: [
              TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(10),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemTextColor.name),
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(10),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemTextColor.name),
              ),
              TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
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

  ///根据任务个数计算奖励值
  double computeRewardsValueByTaskNum(int taskNum, int astStackNum) {
    double rewardValue = 0;
    //如果是FUJI NFT质押的
    if (globalMiningV1.miningType == MiningType.FUJI_NFT) {
      if (astStackNum == 2000) {
        rewardValue =
        taskNum >= 50 ? 0.333333333333333 : 0.0066666666666 * taskNum;
      } else if (astStackNum == 800) {
        rewardValue = taskNum >= 50 ? 0.1 : 0.002 * taskNum;
      } else {
        rewardValue = taskNum >= 50 ? 0.025 : 0.0005 * taskNum;
      }
      return rewardValue;
    }

    // 50 100 500
    if (astStackNum == 50) {
      if (taskNum >= 500) {
        rewardValue = 0.0125;
      } else {
        rewardValue = taskNum * 0.000025;
      }
    } else if (astStackNum == 100) {
      if (taskNum >= 100) {
        rewardValue = 0.0333333333333334;
      } else {
        rewardValue = taskNum * 0.000333333333333334;
      }
    } else {
      //500 ast
      if (taskNum >= 100) {
        rewardValue = 0.2083333333333334;
      } else {
        rewardValue = taskNum * 0.002083333333333334;
      }
    }
    return rewardValue;
  }

  getMaxRewardIndex() {
    if (epochList.isEmpty) return -1;
    double maxVerifyCount = 0;
    int maxVerifyCountIndex = -1;
    for (int i = 0; i < barValues.length; i++) {
      if (barValues[i] > maxVerifyCount) {
        maxVerifyCount = barValues[i];
        maxVerifyCountIndex = i;
      }
    }
    return maxVerifyCountIndex;
  }

  List<String> getPast7DaysDate() {
    final now = DateTime.now();
    const oneDay = Duration(days: 1);
    final dates = <String>[];

    for (int i = 7; i >= 1; i--) {
      final date = now.subtract(oneDay * i);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final formattedDate = '$day/$month';
      dates.add(formattedDate);
    }

    return dates;
  }

  //获取锁仓时间
  getLockTime(String address) async {
    try {
      final lockTime = await MiningApi.lockTime(address);
      //final lockDataTime = DateTime.fromMillisecondsSinceEpoch(int.parse("${lockTime[0]}"));
      isCanUnlock = DateTime.now().millisecondsSinceEpoch ~/ 1000 >
          int.parse("${lockTime[0]}");
      lockTimeStr = dataUtils.getTimeByTimeStamp("${lockTime[0]}");
      debugPrint("锁仓时间:$lockTimeStr");
      if (mounted) {
        setState(() {});
      }
    } catch (err) {
      debugPrint("err : ${err.toString()}");
    }
  }

  ///根据解锁时间推算质押时间
  String getYearAgoTime(String lockTime) {
    try {
      DateFormat format = DateFormat("dd/MM/yyyy HH:mm");
      // 将字符串解析为DateTime对象
      DateTime currentDateTime = format.parse(lockTime);

      // 计算一年前的时间
      // 1 FUJI NFT 质押90天
      // 2 AST/miningNFT 质押都是一年365
      int desDays = 365;
      if (globalMiningV1.miningType == MiningType.FUJI_NFT) {
        desDays = 90;
      }

      DateTime? oneYearAgo = currentDateTime.subtract(Duration(days: desDays));
      // 格式化日期时间为指定格式（dd/MM/yyyy HH:mm）
      String formattedOneYearAgo =
          "${oneYearAgo.day.toString().padLeft(2, '0')}/"
          "${oneYearAgo.month.toString().padLeft(2, '0')}/"
          "${oneYearAgo.year} ${oneYearAgo.hour.toString().padLeft(2, '0')}:"
          "${oneYearAgo.minute.toString().padLeft(2, '0')}";
      // print('当前时间: $currentDateTime');
      // print('一年前的时间: $formattedOneYearAgo');
      return formattedOneYearAgo;
    } catch (err) {
      debugPrint("err: ${err.toString()}");
      return '';
    }
  }

  //已经发放奖励
  getTotalValue(String address) async {
    try {
      final totalData = await MiningApi.getTotalMiningValue(address);
      if (totalData["result"] != null) {
        rewardsReceived =
            toEther("${BigInt.tryParse(totalData["result"]["total"])}", 18).toDouble();
      }
    } catch (err) {
      debugPrint("err:${err.toString()}");
    }
  }

  //未发放金额
  getAccountRewardUnpaid(String address) async {
    try {
      final totalData = await MiningApi.getAccountRewardUnpaid(address);
      if (totalData["result"] != null) {
        accumulatedRewards =
            toEther("${BigInt.tryParse(totalData["result"])}", 18).toDouble();
      }
    } catch (err) {
      debugPrint("err:${err.toString()}");
    }
  }

  getAstPrice() async {
    final data =
    globalWapAdapter.getCoinPriceWithUnit(CoinType.N.name);
    if (data != null) {
      astPrice = data["coinPrice"];
      debugPrint("astPrice:$astPrice");
    }
  }

  getRewardsList() async {
    try {
      final data = await MiningApi.getAllRewardsList(astAddress ?? '');
      if (data != null && data["result"] != null) {
        rewardsList = data["result"]["data"] ?? [];
      } else {
        rewardsList = [];
      }
      if (mounted) {
        setState(() {});
      }
    } catch (err) {
      rewardsList = [];
      debugPrint("err:${err.toString()}");
      if (mounted) {
        setState(() {});
      }
    }
  }

  ///解除质押
  unLockAstMining() {
    if (isCanUnlock) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            content: Text(
              S.current.g_mining_key20,
              style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name)),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(S.current.g_key_79),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                },
              ),
              TextButton(
                child: Text(S.current.g_key_78),
                onPressed: () async {
                  try {
                    setState(() {
                      load=Load.loading;
                    });

                    dynamic data;
                    String miningValueKey="";
                    MiningProvider mp=globalMiningV1;
                    if (mp.miningType ==
                        MiningType.N) {
                      miningValueKey=MiningType.N.name.toLowerCase();
                      data = await MiningApi.unlock();
                    }
                    if(AppConfig.isMainChainMining==false){
                      miningValueKey=miningValueKey+'test';
                    }
                    debugPrint("unlock data：$data");
                    if (data != null) {
                      //设置质押状态为false
                      mp.setMiningType(null);
                      mp.setMiningStatus(false);
                      //停止挖矿
                      MiningUtils.stopMining();
                      SPUtil sPUtils=SPUtil();
                      Map<String,dynamic>? ms=await sPUtils.getMiningStautus();
                      if(ms !=null){

                        ms[astAddress??""]?["miningType"]=null;
                        ms[astAddress??""]?["miningValue"][miningValueKey]=null;
                        sPUtils.setMiningStatus(astAddress??"",ms[astAddress??""]);
                      }
                      ToastUtils.show("Release the pledge and stop mining");
                      setState(() {
                        isCanUnlock = false;
                        lockTimeStr = null;
                      });
                    }
                  } catch (err) {
                    debugPrint("err:${err.toString()}");
                  } finally {
                    if (mounted) {
                      Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                      setState(() {
                        load=Load.finish;
                      });
                    }
                    //更新ui
                    eventBus.fire(EventPublic(EventPublicType.refreshMiningData));

                  }
                },
              ),
            ],
          );
        },
      );
    }
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
              bottom: ScreenUtil().setWidth(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: ScreenUtil().setWidth(18),
                ),
                Text(
                  S.of(context).g_mining_key_58,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(44),
                ),
                // 柱状图展示历史7天挖矿数据
                ChartHistogram(
                  isLoading: isLoading7DayData,
                  titleModel: TitleModel(),
                  barChartModel: isShowDefaultBar
                      ? BarChartModel(
                    bgColor: const Color.fromRGBO(25, 118, 249, 0.1),
                    fgColor: const Color.fromRGBO(25, 118, 249, 0.1),
                    fgColorMax: const Color.fromRGBO(25, 118, 249, 0.1),
                    touchColor: const Color.fromRGBO(25, 118, 249, 0.1),
                    width: ScreenUtil().setWidth(20),
                    values: [10, 10, 10, 10, 10, 10, 10],
                  )
                      : BarChartModel(
                    bgColor: const Color.fromRGBO(25, 118, 249, 0.1),
                    fgColor: const Color.fromRGBO(25, 118, 249, 1),
                    fgColorMax: const Color.fromRGBO(50, 215, 75, 1),
                    touchColor: Colors.yellowAccent,
                    width: ScreenUtil().setWidth(20),
                    values: barValues,
                  ),
                  bottomTitle: BottomTitle(
                    titles: getPast7DaysDate(),
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                    // specialIndex: getMaxRewardIndex(),
                    specialStyle: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemTextColor.name),
                      fontWeight: FontWeight.w600,
                    ),
                    space: ScreenUtil().setWidth(36),
                  ),
                  alertMessageGroups: alertMessageList,
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(44),
                ),
                Text(
                  // "Summary",
                  S.current.g_mining_key_19,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(44),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemBgColor.name),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(30), vertical: ScreenUtil().setWidth(44)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // "Total Rewards",
                            S.current.g_mining_key_13,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.ff888888.name),
                              fontSize: ScreenUtil().setSp(26),
                            ),
                          ),
                          Text(
                            '${dataUtils.doubleFixed(totalValue, 4)} ${CoinType.N.name}',
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(26),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(32),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // "Total Value Mined",
                            S.current.g_mining_key_20,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.ff888888.name),
                              fontSize: ScreenUtil().setSp(26),
                            ),
                          ),
                          Text(
                            "\$${NumberFormat("#,##0.0#", "en_US").format((astPrice * totalValue))}",
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(26),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      //未发放奖励
                      SizedBox(
                        height: ScreenUtil().setWidth(32),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // "Accumulated Rewards",
                            S.current.g_mining_key_59,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.ff888888.name),
                              fontSize: ScreenUtil().setSp(26),
                            ),
                          ),
                          Text(
                            '${dataUtils.doubleFixed(accumulatedRewards, 4)} ${CoinType.N.name}',
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(26),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      //已发放奖励
                      SizedBox(
                        height: ScreenUtil().setWidth(32),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // "Rewards received",
                            S.current.g_mining_key_60,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.ff888888.name),
                              fontSize: ScreenUtil().setSp(26),
                            ),
                          ),
                          Text(
                            '${dataUtils.doubleFixed(rewardsReceived, 4)} ${CoinType.N.name}',
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(26),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: ScreenUtil().setWidth(32),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // "Mining Since",
                            S.current.g_mining_key_21,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.ff888888.name),
                              fontSize: ScreenUtil().setSp(26),
                            ),
                          ),
                          Text(
                            lockTimeStr == null
                                ? "00/00/00"
                                : getYearAgoTime(lockTimeStr ?? ''),
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(26),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(32),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // "Unlock date",
                            S.current.g_mining_key7,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.ff888888.name),
                              fontSize: ScreenUtil().setSp(26),
                            ),
                          ),
                          Row(
                            children: [
                              if (!isCanUnlock)
                                Text(
                                  lockTimeStr ?? "00/00/00",
                                  style: TextStyle(
                                      color: AppThemeUtils.getColorByKey(
                                          context, AppThemeKeys.mainTextColor.name),
                                      fontSize: ScreenUtil().setSp(26),
                                      fontWeight: FontWeight.bold),
                                ),
                              if (isCanUnlock)
                                GestureDetector(
                                  onTap: () {
                                    //解除质押
                                    unLockAstMining();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Color(0xffD1E4FE),
                                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(86))),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: ScreenUtil().setWidth(20), vertical: ScreenUtil().setWidth(14)),
                                    child: Text(
                                      // "To unlock",
                                      S.of(context).g_mining_key_50,
                                      style: TextStyle(
                                          color: AppThemeUtils.getColorByKey(
                                              context,
                                              AppThemeKeys.mainBlueColor.name),
                                          fontSize: ScreenUtil().setSp(22),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(44),
                ),
                Text(
                  // "Reward History",
                  S.current.g_mining_key_22,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(44),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ScreenUtil().setWidth(16),
                    ),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemBgColor.name),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: ScreenUtil().setWidth(72),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [
                                Color.fromRGBO(135, 161, 255, 1),
                                Color.fromRGBO(60, 133, 255, 1),
                                Color.fromRGBO(25, 118, 249, 1),
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(ScreenUtil().setWidth(16)),
                              topRight: Radius.circular(ScreenUtil().setWidth(16)),
                            )),
                        child: Row(
                          // mainAxisAlignment:MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(left: ScreenUtil().setWidth(48)),
                                child: Text(
                                  S.of(context).g_key_wallet_k54,
                                  style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(
                                        context, AppThemeKeys.mainWhiteColor.name),
                                    fontSize: ScreenUtil().setSp(30),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                S.of(context).g_key_44,
                                style: TextStyle(
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.mainWhiteColor.name),
                                  fontSize: ScreenUtil().setSp(30),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(right: ScreenUtil().setWidth(48)),
                                child: Text(
                                  S.of(context).g_key_wallet_k25,
                                  style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(
                                        context, AppThemeKeys.mainWhiteColor.name),
                                    fontSize: ScreenUtil().setSp(30),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                            // Text("status"),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          if (rewardsList.isEmpty)
                            Column(
                              children: [
                                SizedBox(
                                  height: ScreenUtil().setWidth(180),
                                ),
                                EmptyView(),
                                SizedBox(
                                  height: ScreenUtil().setWidth(180),
                                )
                              ],
                            ),
                          ListView.builder(
                            shrinkWrap: true,
                            reverse: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            itemBuilder: (context, index) {
                              var item = rewardsList[index];

                              ///{"value":"0x9b9449efc9fac0a","timestamp":"0x64a66f63","blockNumber":"0x10c2a0"},
                              return GestureDetector(
                                onTap: () async {},
                                child: Padding(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                                  // //{blockNumber: 0x235, timestamp: 1671526039, reward: 0x1}
                                  child: TaskItem(
                                    taskId:
                                    "${BigInt.tryParse(item["blockNumber"])}",
                                    astValue:
                                    "${dataUtils.formatNum(toEther("${BigInt.tryParse(item["value"])}", 18).toDouble(), 2)} ${CoinType.N.name}",
                                    time: dataUtils.getTimeByTimeStamp(
                                        "${hexToInt(item["timestamp"])
                                        //_hexUtils.hexToInt(item["timestamp"])
                                        }",
                                        format: "dd/MM/yyyy"),
                                    status: "success",
                                  ),
                                ),
                              );
                            },
                            itemCount: rewardsList.length,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(120),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
