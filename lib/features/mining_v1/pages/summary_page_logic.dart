part of 'summary_page.dart';

/// Business logic mixin for SummaryPage.
/// Handles data loading, reward calculations, lock time, and unstaking.
mixin _SummaryPageLogicMixin on State<SummaryPage> {
  Load load = Load.finish;

  DataUtils? _dataUtils;
  DataUtils get dataUtils => _dataUtils ??= DataUtils();

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
  dynamic eventBusFn;

  Future<void> initData({bool forcedRefresh = false}) async {
    astAddress = globalMiningV1.address ?? "";
    if (globalMiningV1.miningType == MiningType.N) {
      getLockTime(astAddress ?? '');
    }

    totalValueData();
    getRewardsList();
    miningBarchartData();
  }

  Future<void> totalValueData() async {
    await getAstPrice();
    await getTotalValue(astAddress ?? '');
    await getAccountRewardUnpaid(astAddress ?? '');
    totalValue = 0;
    totalValue = rewardsReceived + accumulatedRewards;
    globalMiningV1.setMiningIncome(totalValue);
    if (mounted) {
      setState(() {});
    }
  }

  //七天挖矿数据
  Future<void> miningBarchartData() async {
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
  String formatElapsedTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return "$hoursStr:$minutesStr:$secondsStr";
  }

  //生成图标点击事件展示数据
  void generateBarTipData() {
    if (barValues.length != 7) return;

    final subtitleStyle = TextStyle(
      fontSize: ScreenUtil().setSp(20),
      color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.itemSubtitleTextColor.name),
    );
    final boldStyle = TextStyle(
      fontSize: ScreenUtil().setSp(22),
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
    final spacerStyle = TextStyle(
      fontSize: ScreenUtil().setSp(10),
      color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.itemTextColor.name),
    );
    final repeatedStyles = [
      subtitleStyle, boldStyle, spacerStyle,
      subtitleStyle, boldStyle, spacerStyle,
      subtitleStyle, boldStyle,
    ];

    alertMessageList = [];
    final stackAstNum = globalMiningV1.depositsNum;
    for (final element in barValues) {
      final timeData = formatElapsedTime((element * 8).toInt());
      final value =
          computeRewardsValueByTaskNum(element.toInt(), stackAstNum);
      alertMessageList.add(
        AlertMessageGroup(
          titles: [
            S.of(context).g_mining_key_23,
            timeData,
            "",
            S.of(context).g_mining_key_24,
            "${dataUtils.formatNum(value, 4)} ${CoinType.N.name}",
          ],
          styles: repeatedStyles,
        ),
      );
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

  int getMaxRewardIndex() {
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
  Future<void> getLockTime(String address) async {
    try {
      final lockTime = await MiningApi.lockTime(address);
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
      DateTime currentDateTime = format.parse(lockTime);

      // 1 FUJI NFT 质押90天
      // 2 AST/miningNFT 质押都是一年365
      int desDays = 365;
      if (globalMiningV1.miningType == MiningType.FUJI_NFT) {
        desDays = 90;
      }

      DateTime? oneYearAgo = currentDateTime.subtract(Duration(days: desDays));
      String formattedOneYearAgo =
          "${oneYearAgo.day.toString().padLeft(2, '0')}/"
          "${oneYearAgo.month.toString().padLeft(2, '0')}/"
          "${oneYearAgo.year} ${oneYearAgo.hour.toString().padLeft(2, '0')}:"
          "${oneYearAgo.minute.toString().padLeft(2, '0')}";
      return formattedOneYearAgo;
    } catch (err) {
      debugPrint("err: ${err.toString()}");
      return '';
    }
  }

  //已经发放奖励
  Future<void> getTotalValue(String address) async {
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
  Future<void> getAccountRewardUnpaid(String address) async {
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

  Future<void> getAstPrice() async {
    final data =
    globalWapAdapter.getCoinPriceWithUnit(CoinType.N.name);
    if (data != null) {
      astPrice = data["coinPrice"];
      debugPrint("astPrice:$astPrice");
    }
  }

  Future<void> getRewardsList() async {
    try {
      final data = await MiningApi.getAllRewardsList(astAddress ?? '');
      rewardsList = data?["result"]?["data"] as List<dynamic>? ?? [];
    } catch (err) {
      rewardsList = [];
      debugPrint("err:${err.toString()}");
    } finally {
      if (mounted) setState(() {});
    }
  }

  ///解除质押
  void unLockAstMining() {
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
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: Text(S.current.g_key_78),
                onPressed: () async {
                  try {
                    setState(() {
                      load = Load.loading;
                    });

                    dynamic data;
                    String miningValueKey = "";
                    MiningProvider mp = globalMiningV1;
                    if (mp.miningType == MiningType.N) {
                      miningValueKey = MiningType.N.name.toLowerCase();
                      data = await MiningApi.unlock();
                    }
                    if (AppConfig.isMainChainMining == false) {
                      miningValueKey = '${miningValueKey}test';
                    }
                    debugPrint("unlock data：$data");
                    if (data != null) {
                      mp.setMiningType(null);
                      mp.setMiningStatus(false);
                      MiningUtils.stopMining();
                      SPUtil sPUtils = SPUtil();
                      Map<String, dynamic>? ms =
                          await sPUtils.getMiningStautus();
                      if (ms != null) {
                        ms[astAddress ?? ""]?["miningType"] = null;
                        ms[astAddress ?? ""]?["miningValue"][miningValueKey] =
                            null;
                        sPUtils.setMiningStatus(
                            astAddress ?? "", ms[astAddress ?? ""]);
                      }
                      ToastUtils.show(
                          "Release the pledge and stop mining");
                      setState(() {
                        isCanUnlock = false;
                        lockTimeStr = null;
                      });
                    }
                  } catch (err) {
                    debugPrint("err:${err.toString()}");
                  } finally {
                    if (mounted) {
                      Navigator.of(dialogContext).pop();
                      setState(() {
                        load = Load.finish;
                      });
                    }
                    eventBus.fire(
                        EventPublic(EventPublicType.refreshMiningData));
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }
}
