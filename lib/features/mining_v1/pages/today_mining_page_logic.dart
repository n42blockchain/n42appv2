part of 'today_mining_page.dart';

/// Business logic mixin for [_TodayMiningPageState].
///
/// Declares all shared state fields and contains data loading, timer
/// management, mining status, staking queries, and reward computation.
mixin _LogicMixin on State<TodayMiningPage> {
  late final DataUtils dataUtils = DataUtils();

  String astAddress = '';
  int pageSize = 5;
  List<dynamic> taskList = [];
  bool isLoadingTaskList = false;
  int currDepositsOfValue = 0;
  bool isCanUnlock = false;
  String? lockTimeStr;
  double last24HValue = 0;
  double totalValue = 0;
  int currMiningTime = 0;
  List<String> currentMiningTimes = ["00", "00", "00"];
  List<String> lastCycleMiningTimes = ["00", "00", "00"];
  double lastCycleRewardsValue = 0;
  Timer? _timer;
  double astPrice = 0;
  Load miningStartLoad = Load.finish;
  StreamSubscription? eventBusFn;

  void initEventBus() {
    eventBusFn = eventBus.on().listen((event) {
      if (event is EventPublic &&
          event.type == EventPublicType.refreshMiningData) {
        initData(forcedRefresh: true);
      }
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (globalMiningV1.miningType == null) {
        return;
      }
      await getMiningStatus();

      if (globalMiningV1.miningStatus == false) {
        return;
      }

      getCurrentMiningTimeByBlockApi();
    });
  }

  void disposeLogic() {
    _timer?.cancel();
    eventBusFn?.cancel();
  }

  Future<void> initData({bool forcedRefresh = false}) async {
    astAddress = globalMiningV1.address ?? "";
    final ms = await SPUtil().getMiningStautus();
    final mValue = ms?[astAddress]?['miningValue'];

    if (globalMiningV1.miningType == MiningType.N) {
      if (mValue == null) {
        await computerMaxY(astAddress);
      } else {
        final key = AppConfig.isMainChainMining
            ? MiningType.N.name.toLowerCase()
            : '${MiningType.N.name.toLowerCase()}test';
        await computerMaxY(astAddress, value: mValue[key] ?? 0);
      }
    }

    getMiningTaskList(astAddress);
    getMiningStatus();
    await getAstPrice();
    getCurrentMiningTimeByBlockApi();
    totalValueData();
  }

  Future<void> totalValueData() async {
    Decimal value1 = await getTotalValue(astAddress);
    Decimal value2 = await getAccountRewardUnpaid(astAddress);
    totalValue = 0;
    totalValue = value1.toDouble() + value2.toDouble();
    globalMiningV1.setMiningIncome(totalValue);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getAstPrice() async {
    try {
      final data = globalWapAdapter.getCoinPriceWithUnit(CoinType.N.name);
      if (data != null) {
        astPrice = data["coinPrice"];
        return;
      }
      final list = await MarketApi().getWalletCoinsInfo('n');
      if (list['error']) return;
      final price = extractAstPriceFromMarketPayload(list['data']);
      if (price > 0) astPrice = price;
    } catch (err) {
      AppLogger.w('TodayMining', 'getAstPrice err: $err');
    }
  }

  Future<void> get24hour(String astAddress) async {
    try {
      final revenue24Data = await MiningApi.revenue24(astAddress);
      if (revenue24Data != null) {
        final String total = revenue24Data["result"]['total'];
        if (total.isNotEmpty) {
          final value = hexToInt(total);
          last24HValue = toEther("$value", 18).toDouble();
        }
      }
      if (mounted) setState(() {});
    } catch (err) {
      AppLogger.w('TodayMining', 'get24hour err: $err');
    }
  }

  Future<void> getCurrentMiningTime(String astAddress) async {
    try {
      final data24 = await MiningApi.getCurrentMiningTime(astAddress);
      final String? total = data24?["result"]?['totalBlocks'];
      if (total != null && total.isNotEmpty) {
        final BigInt value = hexToInt(total);
        currMiningTime = (value * BigInt.from(8)).toInt();
        if (currMiningTime != 0) {
          currentMiningTimes = formatElapsedTime(currMiningTime);
        }
      } else {
        currMiningTime = 0;
      }
      if (mounted) setState(() {});
    } catch (err) {
      AppLogger.w('TodayMining', 'getCurrentMiningTime err: $err');
    }
  }

  List<String> formatElapsedTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return [hours, minutes, secs];
  }

  Future<void> getLastCycleMiningTime(String astAddress) async {
    try {
      final data = await MiningApi.getLastCycleMiningTime(astAddress);
      if (data == null) {
        lastCycleMiningTimes = ["00", "00", "00"];
        if (mounted) setState(() {});
        return;
      }

      final String? total = data["result"]?['totalBlocks'];
      if (total == null || total.isEmpty) {
        lastCycleMiningTimes = ["00", "00", "00"];
        return;
      }

      final BigInt value = hexToInt(total);
      if (value != BigInt.zero) {
        computeRewardsValueByTaskNum(value.toInt());
      }

      final int nums = (value * BigInt.from(8)).toInt();
      lastCycleMiningTimes = nums != 0
          ? formatElapsedTime(nums)
          : ["00", "00", "00"];
    } catch (err) {
      AppLogger.w('TodayMining', 'getLastCycleMiningTime err: $err');
    }
  }

  void computeRewardsValueByTaskNum(int value) {
    final (int cap, double rate) = switch (currDepositsOfValue) {
      50 => (500, 0.000025),
      100 => (100, 0.000333333333333334),
      _ => (100, 0.002083333333333334),
    };
    lastCycleRewardsValue = value >= cap ? cap * rate : value * rate;
  }

  Future<Decimal> getTotalValue(String address) async {
    try {
      final totalData = await MiningApi.getTotalMiningValue(address);
      if (totalData["result"] != null) {
        return toEther("${BigInt.tryParse(totalData["result"]["total"])}", 18);
      }
      return Decimal.zero;
    } catch (err) {
      AppLogger.w('TodayMining', 'getTotalValue err: $err');
      return Decimal.zero;
    }
  }

  Future<Decimal> getAccountRewardUnpaid(String address) async {
    try {
      final totalData = await MiningApi.getAccountRewardUnpaid(address);
      if (totalData["result"] != null) {
        return toEther("${BigInt.tryParse(totalData["result"])}", 18);
      }
      return Decimal.zero;
    } catch (err) {
      AppLogger.w('TodayMining', 'getAccountRewardUnpaid err: $err');
      return Decimal.zero;
    }
  }

  Future<void> getLockTime(String address) async {
    try {
      final lockTime = await MiningApi.lockTime(address);
      isCanUnlock =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 >
          int.parse("${lockTime[0]}");
      lockTimeStr = dataUtils.getTimeByTimeStamp(
        "${lockTime[0]}",
        format: "dd/MM/yyyy",
      );
      if (mounted) setState(() {});
    } catch (err) {
      AppLogger.w('TodayMining', 'getLockTime err: $err');
    }
  }

  Future<void> getMiningStatus() async {
    try {
      final data = await MiningPluginUtils.status();
      // plugin 返回 null（调用失败）时应视为"未运行"，而非旧逻辑的误判"运行中"
      final bool isRunning = data?["data"] == "started";
      globalMiningV1.setMiningStatus(isRunning);
      if (!isRunning) MiningUtils.startMining();
    } catch (e) {
      AppLogger.w('TodayMining', 'getMiningStatus failed: $e');
    }
  }

  Future<void> computerMaxY(String astAddress, {int? value}) async {
    try {
      if (value != null) {
        currDepositsOfValue = value;
      } else {
        final depositsOfResponse = await MiningApi.depositsOf(astAddress);
        if (depositsOfResponse != null && depositsOfResponse is List) {
          currDepositsOfValue = toEther(
            "${depositsOfResponse[0]}",
            18,
          ).toDouble().toInt();
          final key = AppConfig.isMainChainMining ? "n" : "ntest";
          setMiningValue(key, currDepositsOfValue);
        } else {
          currDepositsOfValue = 0;
        }
      }
      globalMiningV1.setDepositsNum(currDepositsOfValue);
      if (mounted) setState(() {});
    } catch (err) {
      AppLogger.w('TodayMining', 'computerMaxY err: $err');
    }
  }

  Future<void> getMiningTaskList(String astAddress) async {
    try {
      setState(() => isLoadingTaskList = true);
      final data = await MiningApi.getMiningTaskList(
        astAddress,
        null,
        pageSize: pageSize,
      );
      if (data != null) {
        taskList = data["result"]["minedBlocks"] ?? [];
        if (taskList.isNotEmpty && taskList.length >= pageSize) {
          taskList.add(null);
        }
      } else {
        taskList = [];
      }
    } catch (err) {
      taskList = [];
      AppLogger.w('TodayMining', 'getMiningTaskList err: $err');
    } finally {
      isLoadingTaskList = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> getCurrentMiningTimeByBlockApi() async {
    try {
      final list = await MiningApi.getMiningBarChartData(astAddress);
      final lastEpochNum = await MiningApi.getLastEpochNum();
      final currentEpochNum = lastEpochNum + 1;
      if (list != null) {
        final items = list["items"];
        if (items != null && items is List) {
          _handleCurrentMiningTime(items, currentEpochNum);
          _handleYesterdayMiningTime(items, lastEpochNum);
        }
      }
    } catch (err) {
      AppLogger.w('TodayMining', 'getCurrentMiningTimeByBlockApi err: $err');
      getCurrentMiningTime(astAddress);
      getLastCycleMiningTime(astAddress);
    }
  }

  void _handleCurrentMiningTime(List items, int currentEpochNum) {
    final item = items.firstWhere(
      (e) => e["epoch"] == currentEpochNum,
      orElse: () => -1,
    );
    if (item == -1) {
      getCurrentMiningTime(astAddress);
      return;
    }
    currMiningTime = item["verify_count"] * 8;
    if (currMiningTime != 0) {
      currentMiningTimes = formatElapsedTime(currMiningTime);
      if (mounted) setState(() {});
    }
  }

  void _handleYesterdayMiningTime(List items, int lastEpochNum) {
    final item = items.firstWhere(
      (e) => e["epoch"] == lastEpochNum,
      orElse: () => -1,
    );
    if (item == -1) {
      getLastCycleMiningTime(astAddress);
      return;
    }
    final verifyCount = item["verify_count"];
    final timeSeconds = (verifyCount * 8).clamp(0, 86400);
    if (timeSeconds != 0) {
      lastCycleMiningTimes = formatElapsedTime(timeSeconds);
      computeRewardsValueByTaskNum(verifyCount);
      if (mounted) setState(() {});
    }
  }

  Future<void> setMiningValue(String key, dynamic value) async {
    SPUtil().setMiningStatus_child(astAddress, key, value);
  }
}
