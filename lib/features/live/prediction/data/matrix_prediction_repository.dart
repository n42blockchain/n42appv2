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
/// 余额为本地 play-money 视角（每房初始 [initialBalance]，仅演示）。
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

  /// roomId -> 最近一次 Matrix 流已回显的事件。创建市场成功后，
  /// SDK 可能延迟到下一次 sync 才把本机自发消息推给 watchMessages；
  /// 保留这份服务端观测态，与 [_pendingCreates] 合并重放，避免 UI
  /// 在已发送成功后仍长时间显示“开预测”。
  final Map<String, List<PredEvent>> _observedEvents = {};

  /// 已被 Matrix sendEvent 确认、但本地 timeline 尚未回显的 create。
  /// marketId 本身全局唯一；服务端同 id create 到达后立即移除。
  /// 这里不在发送前写入，因此网络/权限失败不会伪造市场。
  final Map<String, Map<String, PredEvent>> _pendingCreates = {};

  /// roomId -> 当前活跃的"持续关注者"数（`watchMarkets`/`watchMarket`/
  /// `watchPosition` 的活跃订阅数）。归零时才真正取消该房间的订阅、释放
  /// `_latest` 态——此前只在整个仓库 `dispose()` 时统一清理，访问过的房间
  /// 越多订阅越积越多，是技术债；一次性动作（buy/sell/quoteBuy/createMarket/
  /// `_sendAction`）不参与计数，只确保订阅存在，避免被无关的持续关注者提前
  /// 释放。见 [_releaseWatcher]。
  final Map<String, int> _watcherCounts = {};

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
    _latest.clear();
    _observedEvents.clear();
    _pendingCreates.clear();
    _watcherCounts.clear();
    if (!_changes.isClosed) _changes.close();
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(null);
  }

  // marketId 内嵌 roomId，便于仅有 marketId 的 watchMarket/watchPosition 反解房间
  // （仅用于路由/订阅提示，字符串本身不可信——真正的信任边界与校验在
  // `PredictionReplay.trustedRoomId`，见该类文档"房间归属鉴权"）。
  // 形如 `<roomId>~<随机后缀>`；Matrix room id 不含 '~'，分隔安全。
  static String _roomIdOf(String marketId) =>
      PredictionReplay.roomIdFromMarketId(marketId);

  /// 确保订阅该房事件流以维护重放态。`trustedRoomId: roomId` 传入本仓库
  /// **实际物理订阅**的房间——重放引擎据此拒绝 marketId 房间前缀与之不符的
  /// 伪造/串房 create 事件（见 `PredictionReplay` 类文档）。
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
      _observedEvents[roomId] = parsed;
      final observedCreateIds = parsed
          .where((event) => event.action == 'create')
          .map((event) => event.marketId)
          .toSet();
      _pendingCreates[roomId]?.removeWhere(
        (marketId, _) => observedCreateIds.contains(marketId),
      );
      if (_pendingCreates[roomId]?.isEmpty == true) {
        _pendingCreates.remove(roomId);
      }
      _rebuildRoom(roomId);
    });
  }

  void _rebuildRoom(String roomId) {
    final merged = <PredEvent>[
      ...?_observedEvents[roomId],
      ...?_pendingCreates[roomId]?.values,
    ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _latest[roomId] = PredictionReplay(
      initialBalance: initialBalance,
      trustedRoomId: roomId,
    )..replay(merged);
    _emit();
  }

  /// 登记一个持续关注者（进入某个 watch* 流时调用）。
  void _registerWatcher(String roomId) {
    _watcherCounts[roomId] = (_watcherCounts[roomId] ?? 0) + 1;
  }

  /// 释放一个持续关注者（watch* 流被取消订阅时，经 `finally` 调用）。计数
  /// 归零才真正取消该房间订阅、清理重放态；未归零说明还有其他 watch* 流
  /// 依赖同一房间，不能提前释放。
  void _releaseWatcher(String roomId) {
    final n = (_watcherCounts[roomId] ?? 0) - 1;
    if (n > 0) {
      _watcherCounts[roomId] = n;
      return;
    }
    _watcherCounts.remove(roomId);
    _subs.remove(roomId)?.cancel();
    _latest.remove(roomId);
    _observedEvents.remove(roomId);
    _pendingCreates.remove(roomId);
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
    _registerWatcher(roomId);
    try {
      yield _marketsFor(roomId);
      yield* _changes.stream.map((_) => _marketsFor(roomId));
    } finally {
      _releaseWatcher(roomId);
    }
  }

  List<PredictionMarket> _marketsFor(String roomId) =>
      _replayFor(roomId)?.marketsFor(roomId, now: DateTime.now()) ??
      const <PredictionMarket>[];

  @override
  Stream<PredictionMarket> watchMarket(String marketId) async* {
    final roomId = _roomIdOf(marketId);
    _ensureRoom(roomId);
    _registerWatcher(roomId);
    try {
      final initial = _replayFor(roomId)?.market(marketId, now: DateTime.now());
      if (initial != null) yield initial;
      yield* _changes.stream
          .map((_) => _replayFor(roomId)?.market(marketId, now: DateTime.now()))
          .where((m) => m != null)
          .cast<PredictionMarket>();
    } finally {
      _releaseWatcher(roomId);
    }
  }

  @override
  Stream<UserPosition> watchPosition(String marketId) async* {
    final roomId = _roomIdOf(marketId);
    _ensureRoom(roomId);
    _registerWatcher(roomId);
    try {
      yield _positionFor(marketId);
      yield* _changes.stream.map((_) => _positionFor(marketId));
    } finally {
      _releaseWatcher(roomId);
    }
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
    if (!PredictionLimits.hasValidCreateInput(
      question: question,
      outcomeLabels: outcomeLabels,
    )) {
      throw const PredictionException(PredictionError.tooFewOutcomes);
    }
    _ensureRoom(roomId);
    final id =
        '$roomId~${DateTime.now().millisecondsSinceEpoch}${_rand.nextInt(1 << 20)}';
    final payload = <String, dynamic>{
      't': 'pred',
      'a': 'create',
      'm': id,
      'room': roomId,
      'q': question.trim(),
      'o': outcomeLabels.map((label) => label.trim()).toList(),
      if (closesAt != null) 'close': closesAt.millisecondsSinceEpoch,
    };
    await _chat.sendEvent(roomId, payload);

    // sendEvent 已返回才纳入本地重放；不在网络往返前伪造。
    // 真实 Matrix 事件回显时 _ensureRoom 会按 marketId 去重并移除。
    final sender = _me;
    if (sender != null && sender.isNotEmpty) {
      final pending = PredEvent.tryParse(
        sender: sender,
        timestamp: DateTime.now(),
        data: payload,
      );
      if (pending != null) {
        (_pendingCreates[roomId] ??= {})[id] = pending;
        _rebuildRoom(roomId);
      }
    }

    // 乐观返回（开放、均价）；返回的前提仍是 Matrix 发送成功。
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
  Future<void> closeMarket(String marketId) => _sendAction(marketId, 'close');

  @override
  Future<void> resolveMarket(String marketId, String winningOutcomeId) {
    final i = _outcomeIndex(winningOutcomeId);
    if (i < 0) {
      throw const PredictionException(PredictionError.invalidOutcome);
    }
    return _sendAction(marketId, 'resolve', extra: {'i': i});
  }

  @override
  Future<void> cancelMarket(String marketId) => _sendAction(marketId, 'cancel');

  /// 发送 resolve/cancel/close 这类 resolver 专属动作。先做客户端即时预检
  /// （非 resolver 或非法状态转移立刻报错，不浪费一次网络往返，且行为对齐
  /// [MockPredictionRepository] 的显式报错，而非让用户以为操作静默生效）；
  /// 真正的强制鉴权与状态机守护仍在 [PredictionReplay] 重放层——即使这里的
  /// 预检被绕过（如直接调 repo 方法），伪造/非法事件仍会被所有客户端一致
  /// 丢弃，不会改变市场状态。
  Future<void> _sendAction(
    String marketId,
    String action, {
    Map<String, dynamic> extra = const {},
  }) async {
    final roomId = _roomIdOf(marketId);
    final replay = _replayFor(roomId);
    final resolverId = replay?.resolverOf(marketId);
    if (resolverId == null) {
      throw const PredictionException(PredictionError.marketNotFound);
    }
    if (_me == null || _me != resolverId) {
      throw const PredictionException(PredictionError.notResolver);
    }
    final status = replay!.market(marketId, now: DateTime.now())?.status;
    switch (action) {
      case 'close':
        if (status == MarketStatus.closed) return; // 幂等
        if (status != MarketStatus.open) {
          throw const PredictionException(PredictionError.invalidState);
        }
      case 'resolve':
        if (status == MarketStatus.resolved) return; // 幂等
        if (status == MarketStatus.cancelled) {
          throw const PredictionException(PredictionError.invalidState);
        }
      case 'cancel':
        if (status == MarketStatus.cancelled) return; // 幂等
        if (status == MarketStatus.resolved) {
          throw const PredictionException(PredictionError.invalidState);
        }
    }
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
    if (!PredictionLimits.isFinitePositive(collateralIn)) {
      throw const PredictionException(PredictionError.amountTooLow);
    }
    final r = _replayFor(roomId);
    final i = _outcomeIndex(outcomeId);
    if (i < 0) throw const PredictionException(PredictionError.invalidOutcome);
    final q = r?.quoteBuy(marketId, i, collateralIn, now: DateTime.now());
    if (q == null) {
      final market = r?.market(marketId, now: DateTime.now());
      throw PredictionException(
        market == null
            ? PredictionError.marketNotFound
            : market.isOpen
            ? PredictionError.invalidOutcome
            : PredictionError.marketClosed,
      );
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
    if (!PredictionLimits.isFinitePositive(collateralIn)) {
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
    final i = _outcomeIndex(outcomeId);
    if (i < 0 || market.outcomeById(outcomeId) == null) {
      throw const PredictionException(PredictionError.invalidOutcome);
    }
    if (minShares != null && !PredictionLimits.isFinitePositive(minShares)) {
      throw const PredictionException(PredictionError.slippage);
    }
    final quote = r?.quoteBuy(marketId, i, collateralIn, now: DateTime.now());
    if (quote == null) {
      throw const PredictionException(PredictionError.marketClosed);
    }
    if (minShares != null && quote.shares + 1e-9 < minShares) {
      throw const PredictionException(PredictionError.slippage);
    }
    await _chat.sendEvent(roomId, {
      't': 'pred',
      'a': 'buy',
      'm': marketId,
      'i': i,
      'c': collateralIn,
      'min': ?minShares,
    });
  }

  @override
  Future<void> sell({
    required String marketId,
    required String outcomeId,
    required double shares,
    double? minCollateral,
  }) async {
    if (!PredictionLimits.isFinitePositive(shares)) {
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
    if (i < 0 || market.outcomeById(outcomeId) == null) {
      throw const PredictionException(PredictionError.invalidOutcome);
    }
    if (minCollateral != null &&
        !PredictionLimits.isFinitePositive(minCollateral)) {
      throw const PredictionException(PredictionError.slippage);
    }
    final proceeds = r?.quoteSell(marketId, i, shares, now: DateTime.now());
    if (proceeds == null) {
      throw const PredictionException(PredictionError.marketClosed);
    }
    if (minCollateral != null && proceeds + 1e-9 < minCollateral) {
      throw const PredictionException(PredictionError.slippage);
    }
    await _chat.sendEvent(roomId, {
      't': 'pred',
      'a': 'sell',
      'm': marketId,
      'i': i,
      's': shares,
      'min_out': ?minCollateral,
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
