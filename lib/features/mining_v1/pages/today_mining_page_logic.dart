part of 'today_mining_page.dart';

/// Business logic mixin for [_TodayMiningPageState].
///
/// Declares all shared state fields and contains data loading, timer
/// management, mining status, staking queries, and reward computation.
mixin _LogicMixin on State<TodayMiningPage> {
  DataUtils? _dataUtils;
  DataUtils get dataUtils {
    if (_dataUtils == null) {
      _dataUtils = DataUtils();
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

  //Last Cycle's Mining Time
  List<String> lastCycleMiningTimes = ["00", "00", "00"];

  //上一轮因该发放的奖励
  double lastCycleRewardsValue = 0;

  ///定时器 间隔15s监测挖矿状态
  Timer? _timer;

  double astPrice = 0;

  Load miningStartLoad = Load.finish;

  var eventBusFn;

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

      //更新时间
      getCurrentMiningTimeByBlockApi();
    });
  }

  void disposeLogic() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    eventBusFn.cancel();
  }

  initData({bool forcedRefresh = false}) async {
    astAddress = globalMiningV1.address ?? "";
    Map<String, dynamic>? ms = await SPUtil().getMiningStautus();
    Map<String, dynamic>? mValue;
    if (ms != null) {
      mValue = ms[astAddress]?['miningValue'];
    }
    if (mValue == null) {
      if (globalMiningV1.miningType == MiningType.N) {
        await computerMaxY(astAddress);
      }
    } else {
      if (globalMiningV1.miningType == MiningType.N) {
        int value;
        if (AppConfig.isMainChainMining) {
          value = ms?[astAddress]?['miningValue']
                  ?[MiningType.N.name.toLowerCase()] ??
              0;
        } else {
          value = ms?[astAddress]?['miningValue']
                  ?['${MiningType.N.name.toLowerCase()}test'] ??
              0;
        }
        await computerMaxY(astAddress, value: value);
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
    Decimal value2 = await getAccountRewardUnpaid(astAddress);
    totalValue = 0;
    totalValue = value1.toDouble() + value2.toDouble();
    globalMiningV1.setMiningIncome(totalValue);
    if (mounted) {
      setState(() {});
    }
  }

  getAstPrice() async {
    try {
      final data =
          globalWapAdapter.getCoinPriceWithUnit(CoinType.N.name);
      if (data != null) {
        astPrice = data["coinPrice"];
        debugPrint("astPrice:$astPrice");
      } else {
        var list = await MarketApi().getWalletCoinsInfo('n');
        if (list['error']) {
        } else {
          //查询成功，将币的信息赋值到_coinslist
          List<dynamic> nInfo = list['data']['data'];
          if (nInfo.length != 0) {
            astPrice =
                Decimal.parse(nInfo[0]['price'].toString()).toDouble();
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
        if (total != null && total.isNotEmpty) {
          BigInt value = hexToInt(total);
          //_hexUtils.hexToBigInt(total) ?? BigInt.zero;
          // debugPrint("getCurrentMining value :${value.toString()}");
          BigInt result = value * BigInt.from(8);
          // debugPrint("getCurrentMining result :${result.toString()}");
          currMiningTime = result.toInt();
          if (currMiningTime != 0) {
            currentMiningTimes = formatElapsedTime(currMiningTime);
          }
        } else {
          currMiningTime = 0;
        }
      } else {
        currMiningTime = 0;
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
        if (total != null && total.isNotEmpty) {
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
          } else {
            lastCycleMiningTimes == ["00", "00", "00"];
          }
        } else {
          lastCycleMiningTimes == ["00", "00", "00"];
        }
      } else {
        lastCycleMiningTimes == ["00", "00", "00"];
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
        final value =
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
  computerMaxY(String astAddress, {int? value}) async {
    try {
      if (value == null) {
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
          if (AppConfig.isMainChainMining) {
            setMiningValue("n", currDepositsOfValue);
          } else {
            setMiningValue("ntest", currDepositsOfValue);
          }
        } else {
          currDepositsOfValue = 0;
          globalMiningV1.setDepositsNum(currDepositsOfValue);
        }
      } else {
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
    var item = items.firstWhere(
        (element) => element["epoch"] == lastEpochNum,
        orElse: () => -1);
    if (item != -1) {
      final verifyCount = item["verify_count"];
      int timeSeconds = verifyCount * 8;
      if (timeSeconds > 86400) {
        timeSeconds = 86400;
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

  setMiningValue(String key, dynamic value) async {
    SPUtil().setMiningStatus_child(astAddress, key, value);
  }
}
