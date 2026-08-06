part of 'mining_v2_provider.dart';

mixin _MiningStateMixin on ChangeNotifier {
  MiningApi? _mining;
  MiningApi get mining {
    _mining ??= MiningApi.init();
    return _mining!;
  }

  MiningWeb3? _web3;
  MiningWeb3 get web3 {
    _web3 ??= MiningWeb3.init(privateKey ?? "");
    return _web3!;
  }

  bool? depositsEnable;

  bool miningStatus = false;

  void setDepositsEnable(bool? flag) {
    depositsEnable = flag ?? false;
    notifyListeners();
  }

  void setMiningStatus(bool status) {
    miningStatus = status;
    notifyListeners();
  }

  String walletName = "";
  String? address;
  String? privateKey;

  String errorMessage = "";
  String depositTxHash = "";
  String exitDepositTxHash = "";

  Map<String, dynamic>? miningKeypart;
  Map<String, dynamic>? miningData;
  bool redeem = false;

  double walletNBalance = 0;
  double nPrice = 0;

  Load depositLoad = Load.finish;
  Load exitDepositLoad = Load.finish;

  List<MiningWithdrawalsDaily> taskList = [];
  double miningTotalRevenue = 0;
  double todayCycleRewardsValue = 0;
  double yesterdayCycleRewardsValue = 0;
  List<double> barChartValues = [0, 0, 0, 0, 0, 0, 0];
  List<String> barChartValues2 = ["0", "0", "0", "0", "0", "0", "0"];
  List<AlertMessageGroup> barChartAlertMessageList = [];
  List<String> barChartTitle = [];
  bool isLoading7DayData = false;
  bool isShowDefaultBar = true;

  double balanceInBeacon = 0;
  List<double> inactivityScore = [0, 0, 0];
  String inactivityScorePercentage = "0";
  String inactivityTitle = "";
  bool inactivityWarningShown = false;
  bool showRedemption = false;
  bool showRedemption2 = false;

  DateTime? activationTime;
  int exitTimestamp = 0;

  Timer? txCheckTimer;
  Timer? withdrawalTimer;
  Timer? beaconValidatorTimer;
  Timer? statusPollTimer;

  NativeWebSocketBridge? wsBridge;
  StreamSubscription<String>? wsSubscription;
  bool wsConnected = false;
  WebSocketState wsStateValue = WebSocketState.disconnected;
  WebSocketState get wsState => wsStateValue;

  int wsReconnectAttempts = 0;
  Timer? wsReconnectTimer;
  String? lastWsUrl;
  String? lastValidatorPubkey;
  String? lastValidatorPrivateKey;

  // Cross-mixin stubs (overridden by feature mixins)
  Future<void> loadMiningData() async {}
  Future<void> getBeaconValidator() async {}
  Future<void> getMiningWithdrawalsDaily() async {}
  void startWithdrawalTimer() {}
  void endWithdrawalTimer() {}
  void starBeaconValidatorTimer({
    int waitSeconds = kBeaconValidatorWaitSeconds,
  }) {}
  void endBeaconValidatorTimer() {}
  Future<void> connectWebSocket({
    required String wsUrl,
    required String validatorPubkey,
    required String validatorPrivateKey,
  }) async {}
  Future<void> disconnectWebSocket() async {}
  void handleWebSocketMessage(String message) {}
  void endCheckTxHash() {}
  void startCheckDepositTxHash(String txHash) {}
  void startCheckExitDepositTxHash(String txHash) {}
  Future<void> checkAddressMiningStatus() async {}
  Future<void> setMiningData(
    Map<String, dynamic> keypart,
    bool isMining, {
    bool redeem = false,
  }) async {}

  /// 仅测试用：注入 MiningApi 替身（生产代码禁止调用）
  @visibleForTesting
  set debugMiningApi(MiningApi? api) => _mining = api;

  void resetData() {
    _mining = null;
    _web3 = null;
    depositsEnable = false;
    miningStatus = false;
    walletName = "";
    address = null;
    // 换钱包/重置时必须一并清掉旧钱包的密钥与挖矿数据：
    // 唯一调用方 mining_today_v2_logic.initDataWallet 在 resetData 后
    // 会经 checkAddressMiningStatus → getWalletPrivateKey/getMiningData
    // 重新派生这三个字段；若不清空，外部一旦忘记重设，web3 getter 会
    // 用旧私钥重建客户端（资金安全问题）。
    privateKey = null;
    miningKeypart = null;
    miningData = null;
    notifyListeners();
  }

  void disposeState() {
    endCheckTxHash();
    endWithdrawalTimer();
    endBeaconValidatorTimer();
    _stopStatusPolling();

    wsReconnectTimer?.cancel();
    wsReconnectTimer = null;

    wsSubscription?.cancel();
    wsSubscription = null;
    wsBridge?.disconnect();
    wsBridge = null;
  }

  void _stopStatusPolling() {
    statusPollTimer?.cancel();
    statusPollTimer = null;
  }
}
