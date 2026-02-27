part of 'mining_v2_provider.dart';

// ============================================================================
// Beacon Validator, Withdrawal History & Chart Data
//
// Manages beacon-chain validator state polling, mining withdrawal queries,
// 7-day histogram computation, and the [FullNodeEntity] view-model.
// ============================================================================

mixin _MiningBeaconMixin on _MiningStateMixin {
  // ==================== Full Node Entity ====================

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

  // ==================== Load Mining Data ====================

  @override
  Future<void> loadMiningData() async {
    endBeaconValidatorTimer();
    endCheckTxHash();

    if (depositsEnable == true) {
      getMiningWithdrawalsDaily();
      getBeaconValidator();
    } else {
      _stopStatusPolling();
      taskList = [];
      balanceInBeacon = 0;
      inactivityScore = [0, 0, 0];
      miningTotalRevenue = 0;
      inactivityScorePercentage = "0";
      inactivityTitle = "";
      yesterdayCycleRewardsValue = 0;
      todayCycleRewardsValue = 0;
      barChartValues = [0, 0, 0, 0, 0, 0, 0];
      barChartAlertMessageList = [];
      barChartTitle = [];
      isLoading7DayData = false;
      isShowDefaultBar = true;
      showRedemption = false;
      showRedemption2 = false;
      exitDepositLoad = Load.finish;
      depositLoad = Load.finish;

      endWithdrawalTimer();
    }
  }

  // ==================== Status Polling ====================

  /// Start periodic beacon-validator polling every [kMiningStatusIntervalSeconds] seconds.
  void _startStatusPolling() {
    statusPollTimer?.cancel();
    statusPollTimer = Timer.periodic(
      const Duration(seconds: kMiningStatusIntervalSeconds),
      (_) => getBeaconValidator(),
    );
  }

  // ==================== Beacon Validator Timer ====================

  @override
  void starBeaconValidatorTimer({int waitSeconds = kBeaconValidatorWaitSeconds}) {
    if (beaconValidatorTimer != null) return;
    beaconValidatorTimer = Timer(Duration(seconds: waitSeconds), () {
      getBeaconValidator();
      endBeaconValidatorTimer();
    });
  }

  @override
  void endBeaconValidatorTimer() {
    if (beaconValidatorTimer != null) {
      beaconValidatorTimer!.cancel();
      beaconValidatorTimer = null;
    }
  }

  // ==================== Beacon Validator Query ====================

  @override
  Future<void> getBeaconValidator() async {
    MessageModel rmm = await mining.getBeaconValidator(miningKeypart?['publicKey'] ?? "");
    if (rmm.error == false) {
      inactivityScore = [0, 0, 0];
      balanceInBeacon = toEther(
        (rmm.data?['balance_in_beacon'] ?? 0).toString(),
        9,
      ).toDouble();

      int iscore = rmm.data?['inactivity_score'] ?? 0;
      debugPrint('iscore:$iscore');
      iscore = iscore > kMaxInactivityScore ? kMaxInactivityScore : iscore;
      double isp = ((iscore / kMaxInactivityScore) * 100);
      inactivityScorePercentage = isp.toStringAsFixed(2);

      if (isp <= kLowRiskThreshold) {
        inactivityTitle = S.current.g_mining_key_84; // "Low Risk"
      } else if (isp <= kModerateRiskThreshold) {
        inactivityTitle = S.current.g_mining_key_85; // "Moderately Risk"
      } else {
        inactivityTitle = S.current.g_mining_key_87; // "High Risk"
      }

      // 高风险预警：inactivity score 超过 66% 时弹 Toast（每次冷启动只弹一次）
      if (isp > kModerateRiskThreshold && !inactivityWarningShown) {
        inactivityWarningShown = true;
        ToastUtils.show(S.current.g_mining_inactivity_warning);
      }

      if (iscore != 0) {
        for (int i = 0; i < 3; i++) {
          if (iscore - (i + 1) * kInactivityScoreSegmentSize <= 0) {
            inactivityScore[i] =
                (iscore - (i) * kInactivityScoreSegmentSize) / kInactivityScoreSegmentSize;
            break;
          } else {
            inactivityScore[i] = 1;
          }
        }
      }

      // ---------- activation ----------
      int timestamp = rmm.data['activation_timestamp'];
      if (timestamp == 0) {
        activationTime = null;
        showRedemption = false;
        starBeaconValidatorTimer();
      } else {
        activationTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        final int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final int readyTimestamp = timestamp + kMiningCycleSeconds;
        if (readyTimestamp > currentTimestamp) {
          showRedemption = false;
          final int waitSeconds = readyTimestamp - currentTimestamp;
          starBeaconValidatorTimer(waitSeconds: waitSeconds);
        } else {
          showRedemption = true;
        }
      }

      // ---------- exit ----------
      int eTimestamp = rmm.data['exit_timestamp'];
      exitTimestamp = eTimestamp;
      if (eTimestamp == 0) {
        showRedemption2 = true;
        if (showRedemption) {
          _startStatusPolling();
        } else {
          starBeaconValidatorTimer();
        }
      } else {
        showRedemption2 = false;
        _stopStatusPolling();
        depositsEnable = false;
        miningStatus = false;
        loadMiningData();
        notifyListeners();
        setMiningData(miningKeypart!, false, redeem: true);
      }
      notifyListeners();
    }
  }

  // ==================== Withdrawal Data ====================

  @override
  void startWithdrawalTimer() {
    withdrawalTimer?.cancel();
    withdrawalTimer = Timer.periodic(
      const Duration(seconds: kWithdrawalRefreshIntervalSeconds),
      (timer) async {
        getMiningWithdrawalsDaily();
      },
    );
  }

  @override
  void endWithdrawalTimer() {
    if (withdrawalTimer != null) {
      withdrawalTimer!.cancel();
      withdrawalTimer = null;
    }
  }

  @override
  Future<void> getMiningWithdrawalsDaily() async {
    if (isLoading7DayData) return;
    final DateTime today = DateTime.now();
    final DateTime tomorrow = today.add(const Duration(days: 1));
    final DateTime yesterday = today.add(const Duration(days: -1));
    final List<String> tomorrowStr = _getTimeFormat(tomorrow);
    isLoading7DayData = true;
    notifyListeners();

    try {
      MessageModel rmm = await mining.getMiningWithdrawalsDaily(
        tomorrowStr[0],
        address ?? "",
      );
      if (rmm.error == false) {
        // Each valid mining cycle takes kMiningCycleSeconds (128 seconds)
        taskList = rmm.data;
        final List<String> todayStr = _getTimeFormat(today);
        final List<String> yesterdayStr = _getTimeFormat(yesterday);

        int tIndex = taskList.indexWhere((e) => e.day == todayStr[0]);
        int yIndex = taskList.indexWhere((e) => e.day == yesterdayStr[0]);

        todayCycleRewardsValue = tIndex != -1
            ? toEther(taskList[tIndex].totalAmount ?? '0', 18).toDouble()
            : 0;
        yesterdayCycleRewardsValue = yIndex != -1
            ? toEther(taskList[yIndex].totalAmount ?? '0', 18).toDouble()
            : 0;

        _get7DaysValue(today);
        startWithdrawalTimer();
      }

      MessageModel rmms = await mining.getMiningWithdrawalsDailySummary(address ?? "");
      if (rmms.error == false) {
        miningTotalRevenue = toEther(rmms.data, 18).toDouble();
      }
    } catch (e, st) {
      debugPrint('[Mining] getMiningWithdrawalsDaily: $e\n$st');
    } finally {
      isLoading7DayData = false;
      notifyListeners();
    }
  }

  // ==================== 7-Day Chart ====================

  List<String> _getTimeFormat(DateTime date) {
    final String year = date.year.toString();
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return ["$year-$month-$day", "$day/$month"];
  }

  void _get7DaysValue(DateTime date) {
    for (int i = 0; i < kMiningHistoryDays; i++) {
      DateTime d1 = date.add(Duration(days: -(6 - i)));
      final List<String> d1Str = _getTimeFormat(d1);
      barChartTitle.add(d1Str[1]);

      int tIndex = taskList.indexWhere((e) => e.day == d1Str[0]);
      if (tIndex != -1) {
        barChartValues[i] = (taskList[tIndex].count ?? 0).toDouble();
        barChartValues2[i] = taskList[tIndex].totalAmount ?? "0";
      } else {
        barChartValues[i] = 0;
        barChartValues2[i] = "0";
      }
    }
    _generateBarTipData();
    isShowDefaultBar = false;
  }

  void _generateBarTipData() {
    if (barChartValues.isEmpty || barChartValues.length != kMiningHistoryDays) return;

    barChartAlertMessageList = [];
    for (int i = 0; i < barChartValues.length; i++) {
      final normalStyle = TextStyle(
        fontSize: ScreenUtil().setSp(20),
        color: AppThemeUtils.getColorByKey(
          AppGlobals.appContext,
          AppThemeKeys.mainWhiteColor.name,
        ),
      );
      final boldStyle = TextStyle(
        fontSize: ScreenUtil().setSp(22),
        color: AppThemeUtils.getColorByKey(
          AppGlobals.appContext,
          AppThemeKeys.mainWhiteColor.name,
        ),
        fontWeight: FontWeight.bold,
      );

      barChartAlertMessageList.add(
        AlertMessageGroup(
          titles: [
            S.current.g_mining_key_23,
            "${barChartValues[i].toInt()}",
            S.current.g_mining_key_13,
            "${toEther(barChartValues2[i], 16)} ${CoinType.N.name}",
          ],
          styles: [normalStyle, boldStyle, normalStyle, boldStyle],
        ),
      );
    }
  }
}
