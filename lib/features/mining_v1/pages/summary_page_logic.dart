part of 'summary_page.dart';

/// Business logic mixin for SummaryPage.
/// Handles data loading, reward calculations, lock time, and unstaking.
mixin _SummaryPageLogicMixin on State<SummaryPage> {
  Load load = Load.finish;

  DataUtils? _dataUtils;
  DataUtils get dataUtils => _dataUtils ??= DataUtils();

  List<dynamic> rewardsList = [];
  String? astAddress;

  double totalValue = 0;
  double rewardsReceived = 0;
  double accumulatedRewards = 0;

  double astPrice = 0;

  bool isCanUnlock = false;
  String? lockTimeStr;

  List<double> barValues = [0, 0, 0, 0, 0, 0, 0];
  List<int> epochList = [];
  List<AlertMessageGroup> alertMessageList = [];

  bool isLoading7DayData = false;

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

  Future<void> miningBarchartData() async {
    try {
      if (!mounted) return;
      setState(() => isLoading7DayData = true);
      epochList = await MiningApi.generateRewardsArray();
      if (epochList.isNotEmpty) {
        final list = await MiningApi.getMiningBarChartData(
          astAddress ?? '',
          currEpochNum: epochList.last,
        );
        final items = list?["items"];
        if (items != null && items is List) {
          barValues = epochList.map((epoch) {
            final item = items.firstWhere(
              (v) => v["epoch"] == epoch,
              orElse: () => -1,
            );
            return item != -1 ? (item["verify_count"] as int).toDouble() : 0.0;
          }).toList();
        }
      }
    } catch (err) {
      barValues = [];
      AppLogger.w('SummaryPage', 'miningBarchartData err: $err');
    } finally {
      generateBarTipData();
      isShowDefaultBar = barValues.isEmpty || barValues.length != 7;
      if (isShowDefaultBar) {
        barValues = [0, 0, 0, 0, 0, 0, 0];
      }
      isLoading7DayData = false;
      if (mounted) setState(() {});
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

  void generateBarTipData() {
    if (barValues.length != 7) return;

    final subtitleStyle = TextStyle(
      fontSize: ScreenUtil().setSp(20),
      color: AppColorTokens.of(context).textSubtitle,
    );
    final boldStyle = TextStyle(
      fontSize: ScreenUtil().setSp(22),
      color: AppColorTokens.of(context).textPrimary,
      fontWeight: FontWeight.w600,
    );
    final spacerStyle = TextStyle(
      fontSize: ScreenUtil().setSp(10),
      color: AppColorTokens.of(context).textItem,
    );
    final repeatedStyles = [
      subtitleStyle,
      boldStyle,
      spacerStyle,
      subtitleStyle,
      boldStyle,
      spacerStyle,
      subtitleStyle,
      boldStyle,
    ];

    alertMessageList = [];
    final stackAstNum = globalMiningV1.depositsNum;
    for (final element in barValues) {
      final timeData = formatElapsedTime((element * 8).toInt());
      final value = computeRewardsValueByTaskNum(element.toInt(), stackAstNum);
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

  double computeRewardsValueByTaskNum(int taskNum, int astStackNum) {
    final (int cap, double rate) = switch ((
      globalMiningV1.miningType,
      astStackNum,
    )) {
      (MiningType.FUJI_NFT, 2000) => (50, 0.0066666666666),
      (MiningType.FUJI_NFT, 800) => (50, 0.002),
      (MiningType.FUJI_NFT, _) => (50, 0.0005),
      (_, 50) => (500, 0.000025),
      (_, 100) => (100, 0.000333333333333334),
      _ => (100, 0.002083333333333334),
    };
    return taskNum >= cap ? cap * rate : taskNum * rate;
  }

  int getMaxRewardIndex() {
    if (epochList.isEmpty || barValues.isEmpty) return -1;
    int maxIndex = 0;
    for (int i = 1; i < barValues.length; i++) {
      if (barValues[i] > barValues[maxIndex]) maxIndex = i;
    }
    return barValues[maxIndex] > 0 ? maxIndex : -1;
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

  Future<void> getLockTime(String address) async {
    try {
      final lockTime = await MiningApi.lockTime(address);
      isCanUnlock =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 >
          int.parse("${lockTime[0]}");
      lockTimeStr = dataUtils.getTimeByTimeStamp("${lockTime[0]}");
      AppLogger.d('SummaryPage', 'lockTime: $lockTimeStr');
      if (mounted) {
        setState(() {});
      }
    } catch (err) {
      AppLogger.w('SummaryPage', 'err: $err');
    }
  }

  String getYearAgoTime(String lockTime) {
    try {
      final format = DateFormat("dd/MM/yyyy HH:mm");
      final currentDateTime = format.parse(lockTime);
      final desDays = globalMiningV1.miningType == MiningType.FUJI_NFT
          ? 90
          : 365;
      final stakeDate = currentDateTime.subtract(Duration(days: desDays));
      return "${stakeDate.day.toString().padLeft(2, '0')}/"
          "${stakeDate.month.toString().padLeft(2, '0')}/"
          "${stakeDate.year} ${stakeDate.hour.toString().padLeft(2, '0')}:"
          "${stakeDate.minute.toString().padLeft(2, '0')}";
    } catch (err) {
      AppLogger.w('SummaryPage', 'getYearAgoTime err: $err');
      return '';
    }
  }

  Future<void> getTotalValue(String address) async {
    try {
      final totalData = await MiningApi.getTotalMiningValue(address);
      if (totalData["result"] != null) {
        rewardsReceived = toEther(
          "${BigInt.tryParse(totalData["result"]["total"])}",
          18,
        ).toDouble();
      }
    } catch (err) {
      AppLogger.w('SummaryPage', 'err: $err');
    }
  }

  Future<void> getAccountRewardUnpaid(String address) async {
    try {
      final totalData = await MiningApi.getAccountRewardUnpaid(address);
      if (totalData["result"] != null) {
        accumulatedRewards = toEther(
          "${BigInt.tryParse(totalData["result"])}",
          18,
        ).toDouble();
      }
    } catch (err) {
      AppLogger.w('SummaryPage', 'err: $err');
    }
  }

  Future<void> getAstPrice() async {
    final data = globalWapAdapter.getCoinPriceWithUnit(CoinType.N.name);
    if (data != null) {
      astPrice = data["coinPrice"];
      AppLogger.d('SummaryPage', 'astPrice: $astPrice');
    }
  }

  Future<void> getRewardsList() async {
    try {
      final data = await MiningApi.getAllRewardsList(astAddress ?? '');
      rewardsList = data?["result"]?["data"] as List<dynamic>? ?? [];
    } catch (err) {
      rewardsList = [];
      AppLogger.w('SummaryPage', 'err: $err');
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
            content: SingleChildScrollView(
              child: Text(
                S.current.g_mining_key20,
                style: TextStyle(color: AppColorTokens.of(context).textPrimary),
              ),
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
                  final dialogNavigator = Navigator.of(dialogContext);
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
                    AppLogger.d('SummaryPage', 'unlock data: $data');
                    if (data != null) {
                      mp.setMiningType(null);
                      mp.setMiningStatus(false);
                      MiningUtils.stopMining();
                      SPUtil sPUtils = SPUtil();
                      Map<String, dynamic>? ms = await sPUtils
                          .getMiningStautus();
                      if (ms != null) {
                        ms[astAddress ?? ""]?["miningType"] = null;
                        ms[astAddress ?? ""]?["miningValue"][miningValueKey] =
                            null;
                        sPUtils.setMiningStatus(
                          astAddress ?? "",
                          ms[astAddress ?? ""],
                        );
                      }
                      ToastUtils.show("Release the pledge and stop mining");
                      if (!mounted) return;
                      setState(() {
                        isCanUnlock = false;
                        lockTimeStr = null;
                      });
                    }
                  } catch (err) {
                    AppLogger.w('SummaryPage', 'err: $err');
                  } finally {
                    if (mounted) {
                      if (dialogNavigator.mounted && dialogNavigator.canPop()) {
                        dialogNavigator.pop();
                      }
                      setState(() {
                        load = Load.finish;
                      });
                      eventBus.fire(
                        EventPublic(EventPublicType.refreshMiningData),
                      );
                    }
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
