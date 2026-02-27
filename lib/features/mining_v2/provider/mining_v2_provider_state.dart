part of 'mining_v2_provider.dart';

// ============================================================================
// Mining State Fields
//
// All mutable state for [MiningV2Provider] is declared here so that every
// feature-mixin (actions, beacon, websocket) can read and write shared state
// through the `on _MiningStateMixin` constraint.
//
// Methods that are *implemented* in other mixins but *called across* mixins
// have default (no-op) stubs here; the real implementations override them.
// ============================================================================

mixin _MiningStateMixin on ChangeNotifier {
  // -------------------- lazy service accessors --------------------

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

  // -------------------- core state --------------------

  /// Whether the current address has an active deposit (stake).
  bool? depositsEnable;

  /// Whether the mining client is currently running.
  bool miningStatus = false;

  void setDepositsEnable(bool? flag) {
    depositsEnable = flag ?? false;
    notifyListeners();
  }

  void setMiningStatus(bool status) {
    miningStatus = status;
    notifyListeners();
  }

  // -------------------- wallet identity --------------------

  String walletName = "";
  String? address;
  String? privateKey;

  // -------------------- error / tx hash --------------------

  /// Last error message from mining operations.
  String errorMessage = "";

  /// Deposit tx hash returned from staking.
  String depositTxHash = "";

  /// Exit-deposit tx hash returned from un-staking.
  String exitDepositTxHash = "";

  // -------------------- mining key / data --------------------

  Map<String, dynamic>? miningKeypart;
  Map<String, dynamic>? miningData;
  bool redeem = false;

  // -------------------- balance --------------------

  /// Wallet N-coin available balance (shown when not staked).
  double walletNBalance = 0;

  /// N token price in fiat.
  double nPrice = 0;

  // -------------------- deposit / exit loading --------------------

  Load depositLoad = Load.finish;
  Load exitDepositLoad = Load.finish;

  // -------------------- withdrawal / chart --------------------

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

  // -------------------- beacon validator --------------------

  double balanceInBeacon = 0;
  List<double> inactivityScore = [0, 0, 0];
  String inactivityScorePercentage = "0";
  String inactivityTitle = "";
  bool inactivityWarningShown = false;
  bool showRedemption = false;
  bool showRedemption2 = false;

  /// Cached activation timestamp from beacon (null = not yet activated).
  DateTime? activationTime;

  /// Cached exit timestamp from beacon (unix seconds, 0 = not exited).
  int exitTimestamp = 0;

  // -------------------- timers --------------------

  Timer? txCheckTimer;
  Timer? withdrawalTimer;
  Timer? beaconValidatorTimer;
  Timer? statusPollTimer;

  // -------------------- websocket --------------------

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

  // ====================================================================
  // Cross-mixin method stubs
  //
  // These are overridden by feature mixins. Default implementations are
  // no-ops so that the code compiles regardless of mixin ordering.
  // ====================================================================

  /// Override in _MiningBeaconMixin
  Future<void> loadMiningData() async {}

  /// Override in _MiningBeaconMixin
  Future<void> getBeaconValidator() async {}

  /// Override in _MiningBeaconMixin
  Future<void> getMiningWithdrawalsDaily() async {}

  /// Override in _MiningBeaconMixin
  void startWithdrawalTimer() {}

  /// Override in _MiningBeaconMixin
  void endWithdrawalTimer() {}

  /// Override in _MiningBeaconMixin
  void starBeaconValidatorTimer({int waitSeconds = kBeaconValidatorWaitSeconds}) {}

  /// Override in _MiningBeaconMixin
  void endBeaconValidatorTimer() {}

  /// Override in _MiningWebSocketMixin
  Future<void> connectWebSocket({
    required String wsUrl,
    required String validatorPubkey,
    required String validatorPrivateKey,
  }) async {}

  /// Override in _MiningWebSocketMixin
  Future<void> disconnectWebSocket() async {}

  /// Override in _MiningWebSocketMixin
  void handleWebSocketMessage(String message) {}

  /// Override in _MiningActionsMixin
  void endCheckTxHash() {}

  /// Override in _MiningActionsMixin
  void startCheckDepositTxHash(String txHash) {}

  /// Override in _MiningActionsMixin
  void startCheckExitDepositTxHash(String txHash) {}

  /// Override in _MiningActionsMixin / main class
  Future<void> checkAddressMiningStatus() async {}

  /// Override in _MiningActionsMixin
  Future<void> setMiningData(
    Map<String, dynamic> keypart,
    bool isMining, {
    bool redeem = false,
  }) async {}

  // -------------------- reset --------------------

  void resetData() {
    _mining = null;
    _web3 = null;
    depositsEnable = false;
    miningStatus = false;
    walletName = "";
    address = null;
    notifyListeners();
  }

  // -------------------- dispose helpers --------------------

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
