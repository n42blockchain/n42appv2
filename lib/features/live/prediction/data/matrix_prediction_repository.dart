import 'dart:async';
import 'dart:math';

import '../../services/live_chat_service.dart';
import '../domain/prediction_market.dart';
import '../domain/prediction_repository.dart';
import 'prediction_replay.dart';

/// **多设备**预测市场仓库：经 Matrix 房间 timeline 做事件溯源同步（play-money）。
///
/// 主播/观众的每个动作作为一条事件广播到直播间所在的 Matrix room；各端用
/// [PredictionReplay] 按同一时间线顺序重放，得到一致的价格 / 持仓 / 结算。
/// 余额为本地 play-money 视角（初始 [initialBalance]，无权威节点校验，仅演示）。
///
/// 与 [MockPredictionRepository] 的区别：mock 单进程内存、主播观众看不到彼此；
/// 本实现经 Matrix 真正跨设备同步。真实资金仍须 `ChainPredictionRepository`。
class MatrixPredictionRepository implements PredictionRepository {
  MatrixPredictionRepository(this._chat, {this.initialBalance = 1000});

  final LiveChatService _chat;
  final double initialBalance;

  @override
  final CollateralToken collateral = const CollateralToken(symbol: 'tUSDC');

  /// roomId -> 该房常驻订阅（维护 [_latest] 重放态）。
  final Map<String, StreamSubscription<List<LiveEvent>>> _subs = {};

  /// roomId -> 最新重放态。
  final Map<String, PredictionReplay> _latest = {};

  /// 本地已赎回的市场 -> 入账金额（结算赢利/退本金只在本端赎回时计入余额）。
  final Map<String, double> _redeemed = {};

  /// 任一状态变化的 tick（事件到达 / 本地赎回）；各 watch* 据此重算推送。
  final StreamController<void> _changes = StreamController<void>.broadcast();

  final Random _rand = Random();

  String? get _me => _chat.myUserId;

  void dispose() {
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();
    if (!_changes.isClosed) _changes.close();
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(null);
  }

  // marketId 内嵌 roomId，便于仅有 marketId 的 watchMarket/watchPosition 反解房间。
  // 形如 `<roomId>~<随机后缀>`；Matrix room id 不含 '~'，分隔安全。
  static String _roomIdOf(String marketId) {
    final i = marketId.lastIndexOf('~');
    return i <= 0 ? marketId : marketId.substring(0, i);
  }

  /// 确保订阅该房事件流以维护重放态。
  void _ensureRoom(String roomId) {
    if (roomId.isEmpty || _subs.containsKey(roomId)) return;
    _subs[roomId] = _chat.watchEvents(roomId).listen((events) {
      final parsed = <PredEvent>[];
      for (final e in events) {
        final p = PredEvent.tryParse(
          sender: e.senderId,
          timestamp: e.timestamp,
          data: e.data,
        );
        if (p != null) parsed.add(p);
      }
      _latest[roomId] = PredictionReplay(initialBalance: initialBalance)
        ..replay(parsed);
      _emit();
    });
  }

  PredictionReplay? _replayFor(String roomId) => _latest[roomId];

  static int _outcomeIndex(String outcomeId) =>
      int.tryParse(outcomeId.startsWith('o') ? outcomeId.substring(1) : '') ??
      -1;

  // ── 流 ──

  @override
  Stream<double> watchBalance() async* {
    yield _balance();
    yield* _changes.stream.map((_) => _balance());
  }

  double _balance() {
    final me = _me;
    var b = initialBalance;
    for (final r in _latest.values) {
      b += r.tradeDeltaFor(me);
    }
    for (final v in _redeemed.values) {
      b += v;
    }
    return b;
  }

  @override
  Stream<List<PredictionMarket>> watchMarkets(String roomId) async* {
    _ensureRoom(roomId);
    yield _marketsFor(roomId);
    yield* _changes.stream.map((_) => _marketsFor(roomId));
  }

  List<PredictionMarket> _marketsFor(String roomId) =>
      _replayFor(roomId)?.marketsFor(roomId, now: DateTime.now()) ??
      const <PredictionMarket>[];

  @override
  Stream<PredictionMarket> watchMarket(String marketId) async* {
    final roomId = _roomIdOf(marketId);
    _ensureRoom(roomId);
    final initial = _replayFor(roomId)?.market(marketId, now: DateTime.now());
    if (initial != null) yield initial;
    yield* _changes.stream
        .map((_) => _replayFor(roomId)?.market(marketId, now: DateTime.now()))
        .where((m) => m != null)
        .cast<PredictionMarket>();
  }

  @override
  Stream<UserPosition> watchPosition(String marketId) async* {
    final roomId = _roomIdOf(marketId);
    _ensureRoom(roomId);
    yield _positionFor(marketId);
    yield* _changes.stream.map((_) => _positionFor(marketId));
  }

  UserPosition _positionFor(String marketId) {
    final roomId = _roomIdOf(marketId);
    final base =
        _replayFor(roomId)?.positionFor(marketId, _me) ??
        UserPosition(marketId: marketId, shares: const {});
    // claimed 为本地视角（已赎回），随 _redeemed 反映到"赎回奖金"按钮禁用。
    return UserPosition(
      marketId: marketId,
      shares: base.shares,
      claimed: _redeemed.containsKey(marketId),
    );
  }

  // ── 主播操作 ──

  @override
  Future<PredictionMarket> createMarket({
    required String roomId,
    required String question,
    required List<String> outcomeLabels,
    DateTime? closesAt,
  }) async {
    if (outcomeLabels.length < 2) {
      throw const PredictionException(PredictionError.tooFewOutcomes);
    }
    _ensureRoom(roomId);
    final id =
        '$roomId~${DateTime.now().millisecondsSinceEpoch}${_rand.nextInt(1 << 20)}';
    await _chat.sendEvent(roomId, {
      't': 'pred',
      'a': 'create',
      'm': id,
      'room': roomId,
      'q': question,
      'o': outcomeLabels,
      if (closesAt != null) 'close': closesAt.millisecondsSinceEpoch,
    });
    // 乐观返回（开放、均价）；真实态由事件回显后经流推送。
    final n = outcomeLabels.length;
    return PredictionMarket(
      id: id,
      roomId: roomId,
      question: question,
      outcomes: [
        for (var i = 0; i < n; i++)
          MarketOutcome(id: 'o$i', label: outcomeLabels[i], price: 1 / n),
      ],
      status: MarketStatus.open,
      collateral: collateral,
      createdAt: DateTime.now(),
      closesAt: closesAt,
    );
  }

  @override
  Future<void> closeMarket(String marketId) =>
      _sendAction(marketId, 'close');

  @override
  Future<void> resolveMarket(String marketId, String winningOutcomeId) {
    final i = _outcomeIndex(winningOutcomeId);
    if (i < 0) {
      throw const PredictionException(PredictionError.invalidOutcome);
    }
    return _sendAction(marketId, 'resolve', extra: {'i': i});
  }

  @override
  Future<void> cancelMarket(String marketId) =>
      _sendAction(marketId, 'cancel');

  Future<void> _sendAction(
    String marketId,
    String action, {
    Map<String, dynamic> extra = const {},
  }) async {
    final roomId = _roomIdOf(marketId);
    await _chat.sendEvent(roomId, {
      't': 'pred',
      'a': action,
      'm': marketId,
      ...extra,
    });
  }

  // ── 观众交易 ──

  @override
  Future<TradeQuote> quoteBuy({
    required String marketId,
    required String outcomeId,
    required double collateralIn,
  }) async {
    final roomId = _roomIdOf(marketId);
    _ensureRoom(roomId);
    final r = _replayFor(roomId);
    final i = _outcomeIndex(outcomeId);
    final q = r?.quoteBuy(marketId, i, collateralIn);
    if (q == null) {
      throw const PredictionException(PredictionError.marketNotFound);
    }
    return q;
  }

  @override
  Future<void> buy({
    required String marketId,
    required String outcomeId,
    required double collateralIn,
    double? minShares,
  }) async {
    if (collateralIn <= 0) {
      throw const PredictionException(PredictionError.amountTooLow);
    }
    if (collateralIn > _balance() + 1e-9) {
      throw const PredictionException(PredictionError.insufficientBalance);
    }
    final roomId = _roomIdOf(marketId);
    final r = _replayFor(roomId);
    final market = r?.market(marketId, now: DateTime.now());
    if (market == null) {
      throw const PredictionException(PredictionError.marketNotFound);
    }
    if (!market.isOpen) {
      throw const PredictionException(PredictionError.marketClosed);
    }
    // 注：minShares 滑点保护无法跨端强制（成交份额由各端重放定序后才确定），
    // 此处仅本地尽力预检；play-money 演示可接受。
    final i = _outcomeIndex(outcomeId);
    await _chat.sendEvent(roomId, {
      't': 'pred',
      'a': 'buy',
      'm': marketId,
      'i': i,
      'c': collateralIn,
    });
  }

  @override
  Future<void> sell({
    required String marketId,
    required String outcomeId,
    required double shares,
    double? minCollateral,
  }) async {
    if (shares <= 0) {
      throw const PredictionException(PredictionError.insufficientShares);
    }
    final roomId = _roomIdOf(marketId);
    final r = _replayFor(roomId);
    final held = _positionFor(marketId).sharesOf(outcomeId);
    if (shares > held + 1e-9) {
      throw const PredictionException(PredictionError.insufficientShares);
    }
    final market = r?.market(marketId, now: DateTime.now());
    if (market == null || !market.isOpen) {
      throw const PredictionException(PredictionError.marketClosed);
    }
    final i = _outcomeIndex(outcomeId);
    await _chat.sendEvent(roomId, {
      't': 'pred',
      'a': 'sell',
      'm': marketId,
      'i': i,
      's': shares,
    });
  }

  @override
  Future<void> redeem(String marketId) async {
    if (_redeemed.containsKey(marketId)) return;
    final roomId = _roomIdOf(marketId);
    final r = _replayFor(roomId);
    final market = r?.market(marketId, now: DateTime.now());
    if (r == null || market == null) {
      throw const PredictionException(PredictionError.marketNotFound);
    }
    if (market.status != MarketStatus.resolved &&
        market.status != MarketStatus.cancelled) {
      throw const PredictionException(PredictionError.notResolved);
    }
    // 结算入账只发生在本端（赎回是本地资金动作，无需广播）。
    _redeemed[marketId] = r.redeemableFor(marketId, _me, now: DateTime.now());
    _emit();
  }
}
