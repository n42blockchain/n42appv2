import 'dart:math';

import '../domain/prediction_market.dart';

/// 预测市场**事件溯源重放引擎**（纯函数、无 IO，可单测）。
///
/// 多设备一致性的核心：主播/观众的每个动作（建市/买/卖/开奖/取消）都作为一条
/// 有序事件经 Matrix 房间 timeline 广播；各端按**同一时间线顺序**把事件重放进
/// 同一套 LMSR 状态机，于是各端算出完全一致的价格 / 持仓 / 结算。
///
/// 资金口径：play-money（每个用户初始 [initialBalance] tUSDC，本地视角）。
/// 无权威节点校验余额，故不拒绝他人超额下注——仅用于演示。
///
/// **resolver 鉴权**：建市事件的 `sender` 即该市场的 resolver（对齐"主播只能裁定
/// 结果、不能卷款"的信任模型）。resolve/cancel/close 这三个终结性动作只信任
/// resolver 发出的事件——任何非 resolver 伪造的同类事件会被本引擎**丢弃**（不改
/// 变状态）。由于所有客户端都跑同一套确定性重放逻辑，伪造事件在每一端都会被
/// 一致地忽略，无需服务端仲裁即可堵住"任意用户伪造开奖结果套利"这个漏洞。
class PredictionReplay {
  PredictionReplay({this.initialBalance = 1000});

  final double initialBalance;

  /// b 参数：与 mock 保持一致，便于行为对齐。
  static const double _liquidity = 50;

  final Map<String, _MarketState> _markets = {};

  /// 按时间线顺序重放整段事件日志，重建全部市场状态。
  /// 每次事件流更新时整体重放（市场/事件规模有限，简单且天然幂等）。
  void replay(List<PredEvent> events) {
    _markets.clear();
    for (final e in events) {
      _applyOne(e);
    }
  }

  void _applyOne(PredEvent e) {
    switch (e.action) {
      case 'create':
        if (_markets.containsKey(e.marketId)) return; // 重复建市忽略
        final labels = e.labels;
        if (labels == null || labels.length < 2) return;
        _markets[e.marketId] = _MarketState(
          id: e.marketId,
          roomId: e.roomId ?? '',
          question: e.question ?? '',
          labels: labels,
          createdAt: e.timestamp,
          closesAt: e.closesAt,
          resolverId: e.sender,
        );
      case 'buy':
        final m = _markets[e.marketId];
        final i = e.outcomeIndex;
        final c = e.collateral;
        if (m == null || i == null || c == null || c <= 0) return;
        if (!m.tradableAt(e.timestamp)) return;
        if (i < 0 || i >= m.q.length) return;
        final shares = m.solveSharesForCollateral(i, c);
        m.q[i] += shares;
        m.addPosition(e.sender, i, shares);
        m.tradeDelta[e.sender] = (m.tradeDelta[e.sender] ?? 0) - c;
        m.netPaid[e.sender] = (m.netPaid[e.sender] ?? 0) + c;
        m.totalVolume += c;
      case 'sell':
        final m = _markets[e.marketId];
        final i = e.outcomeIndex;
        final s = e.shares;
        if (m == null || i == null || s == null || s <= 0) return;
        if (!m.tradableAt(e.timestamp)) return;
        if (i < 0 || i >= m.q.length) return;
        final held = m.positions[e.sender]?[i] ?? 0;
        if (s > held + 1e-9) return; // 不能卖超过持有
        final proceeds = m.proceedsForSell(i, s);
        m.q[i] -= s;
        m.addPosition(e.sender, i, -s);
        m.tradeDelta[e.sender] = (m.tradeDelta[e.sender] ?? 0) + proceeds;
        m.netPaid[e.sender] = (m.netPaid[e.sender] ?? 0) - proceeds;
        m.totalVolume += proceeds;
      case 'resolve':
        final m = _markets[e.marketId];
        final i = e.outcomeIndex;
        if (m == null || i == null) return;
        if (e.sender != m.resolverId) return; // 鉴权：仅建市者可开奖
        // 状态机守护：终态不可再转移（与 mock 一致）。
        if (m.status == MarketStatus.resolved ||
            m.status == MarketStatus.cancelled) {
          return;
        }
        if (i < 0 || i >= m.q.length) return;
        m.status = MarketStatus.resolved;
        m.resolvedOutcomeId = 'o$i';
      case 'cancel':
        final m = _markets[e.marketId];
        if (m == null) return;
        if (e.sender != m.resolverId) return; // 鉴权：仅建市者可取消
        if (m.status == MarketStatus.resolved ||
            m.status == MarketStatus.cancelled) {
          return;
        }
        m.status = MarketStatus.cancelled;
      case 'close':
        final m = _markets[e.marketId];
        if (m == null || m.status != MarketStatus.open) return;
        if (e.sender != m.resolverId) return; // 鉴权：仅建市者可停盘
        m.status = MarketStatus.closed;
    }
  }

  // ── 读取 ──

  List<PredictionMarket> marketsFor(String roomId, {DateTime? now}) {
    final list =
        _markets.values
            .where((m) => m.roomId == roomId)
            .map((m) => m.toModel(now ?? _nowFallback))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  PredictionMarket? market(String marketId, {DateTime? now}) =>
      _markets[marketId]?.toModel(now ?? _nowFallback);

  /// 该市场的 resolver（建市者）身份；市场不存在返回 null。供仓库层在发送
  /// resolve/cancel/close 前做即时客户端预检（真正的鉴权仍在 [_applyOne]）。
  String? resolverOf(String marketId) => _markets[marketId]?.resolverId;

  /// 买入报价（不改状态）：返回份额 / 均价 / 成交后价；市场不存在或结果非法返回 null。
  TradeQuote? quoteBuy(String marketId, int i, double collateralIn) {
    final m = _markets[marketId];
    if (m == null || i < 0 || i >= m.q.length) return null;
    final shares = m.solveSharesForCollateral(i, collateralIn);
    final after = m.pricesAfterBuy(i, shares)[i];
    return TradeQuote(
      outcomeId: 'o$i',
      collateralIn: collateralIn,
      shares: shares,
      avgPrice: shares > 0 ? collateralIn / shares : 0,
      priceAfter: after,
    );
  }

  UserPosition positionFor(String marketId, String? user) {
    final m = _markets[marketId];
    final shares = <String, double>{};
    if (m != null && user != null) {
      m.positions[user]?.forEach((i, v) {
        if (v > 1e-9) shares['o$i'] = v;
      });
    }
    return UserPosition(marketId: marketId, shares: shares);
  }

  /// 某市场某用户的可赎回结算额（开奖赢家份额 1:1；取消退净投入本金；否则 0）。
  double redeemableFor(String marketId, String? user, {DateTime? now}) {
    final m = _markets[marketId];
    if (m == null || user == null) return 0;
    final status = m.effectiveStatus(now ?? _nowFallback);
    if (status == MarketStatus.resolved) {
      final winnerIdx = int.tryParse(
        (m.resolvedOutcomeId ?? 'o-1').substring(1),
      );
      if (winnerIdx == null) return 0;
      return m.positions[user]?[winnerIdx] ?? 0;
    }
    if (status == MarketStatus.cancelled) {
      return (m.netPaid[user] ?? 0).clamp(0, double.infinity);
    }
    return 0;
  }

  /// 用户在所有市场的交易净额（买为负、卖为正）；余额 = 初始 + 交易净额 + 已赎回。
  double tradeDeltaFor(String? user) {
    if (user == null) return 0;
    var sum = 0.0;
    for (final m in _markets.values) {
      sum += m.tradeDelta[user] ?? 0;
    }
    return sum;
  }

  DateTime get _nowFallback => DateTime.fromMillisecondsSinceEpoch(0);
}

/// 一条已解析的预测事件。
class PredEvent {
  const PredEvent({
    required this.sender,
    required this.timestamp,
    required this.action,
    required this.marketId,
    this.roomId,
    this.question,
    this.labels,
    this.closesAt,
    this.outcomeIndex,
    this.collateral,
    this.shares,
  });

  final String sender;
  final DateTime timestamp;
  final String action; // create / buy / sell / resolve / cancel / close
  final String marketId;
  final String? roomId;
  final String? question;
  final List<String>? labels;
  final DateTime? closesAt;
  final int? outcomeIndex;
  final double? collateral;
  final double? shares;

  /// 从事件载荷 map 解析（非预测事件或字段非法返回 null）。
  static PredEvent? tryParse({
    required String sender,
    required DateTime timestamp,
    required Map<String, dynamic> data,
  }) {
    if (data['t'] != 'pred') return null;
    final action = data['a'];
    final marketId = data['m'];
    if (action is! String || marketId is! String) return null;
    double? toD(Object? v) => v is num ? v.toDouble() : null;
    int? toI(Object? v) => v is num ? v.toInt() : null;
    final closeMs = toI(data['close']);
    return PredEvent(
      sender: sender,
      timestamp: timestamp,
      action: action,
      marketId: marketId,
      roomId: data['room'] as String?,
      question: data['q'] as String?,
      labels: (data['o'] as List?)?.map((e) => '$e').toList(),
      closesAt: closeMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(closeMs),
      outcomeIndex: toI(data['i']),
      collateral: toD(data['c']),
      shares: toD(data['s']),
    );
  }
}

/// 单市场的重放态（含 LMSR 定价；数学对齐 MockPredictionRepository）。
class _MarketState {
  _MarketState({
    required this.id,
    required this.roomId,
    required this.question,
    required this.labels,
    required this.createdAt,
    required this.resolverId,
    this.closesAt,
  }) : q = List<double>.filled(labels.length, 0);

  static const double b = PredictionReplay._liquidity;

  final String id;
  final String roomId;
  final String question;
  final List<String> labels;
  final DateTime createdAt;
  final DateTime? closesAt;

  /// 建市事件的 sender——本市场唯一有权 resolve/cancel/close 的身份。
  final String resolverId;

  final List<double> q;
  MarketStatus status = MarketStatus.open;
  String? resolvedOutcomeId;
  double totalVolume = 0;

  /// user -> (outcomeIndex -> shares)
  final Map<String, Map<int, double>> positions = {};

  /// user -> 净投入本金（取消退款用）。
  final Map<String, double> netPaid = {};

  /// user -> 交易净额（买负卖正，算余额用）。
  final Map<String, double> tradeDelta = {};

  bool _expiredAt(DateTime now) => closesAt != null && now.isAfter(closesAt!);

  bool tradableAt(DateTime now) =>
      status == MarketStatus.open && !_expiredAt(now);

  void addPosition(String user, int i, double delta) {
    final map = positions.putIfAbsent(user, () => {});
    map[i] = (map[i] ?? 0) + delta;
    if ((map[i] ?? 0) <= 1e-9) map.remove(i);
  }

  double _logSumExp(List<double> xs) {
    final m = xs.reduce(max);
    var s = 0.0;
    for (final x in xs) {
      s += exp(x - m);
    }
    return m + log(s);
  }

  double _cost(List<double> qq) =>
      b * _logSumExp(qq.map((x) => x / b).toList());

  List<double> prices() {
    final scaled = q.map((x) => x / b).toList();
    final lse = _logSumExp(scaled);
    return scaled.map((s) => exp(s - lse)).toList();
  }

  List<double> pricesAfterBuy(int i, double delta) {
    final q2 = [...q];
    q2[i] += delta;
    final scaled = q2.map((x) => x / b).toList();
    final lse = _logSumExp(scaled);
    return scaled.map((s) => exp(s - lse)).toList();
  }

  double solveSharesForCollateral(int i, double budget) {
    if (budget <= 0) return 0;
    final base = _cost(q);
    double costOf(double d) {
      final q2 = [...q];
      q2[i] += d;
      return _cost(q2) - base;
    }

    double lo = 0, hi = 1;
    var guard = 0;
    while (costOf(hi) < budget && guard++ < 200) {
      hi *= 2;
    }
    for (var k = 0; k < 60; k++) {
      final mid = (lo + hi) / 2;
      if (costOf(mid) < budget) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return (lo + hi) / 2;
  }

  double proceedsForSell(int i, double shares) {
    final base = _cost(q);
    final q2 = [...q];
    q2[i] -= shares;
    return base - _cost(q2);
  }

  MarketStatus effectiveStatus(DateTime now) {
    if (status == MarketStatus.open && _expiredAt(now)) {
      return MarketStatus.closed;
    }
    return status;
  }

  PredictionMarket toModel(DateTime now) {
    final ps = prices();
    return PredictionMarket(
      id: id,
      roomId: roomId,
      question: question,
      outcomes: [
        for (var i = 0; i < labels.length; i++)
          MarketOutcome(id: 'o$i', label: labels[i], price: ps[i]),
      ],
      status: effectiveStatus(now),
      collateral: const CollateralToken(symbol: 'tUSDC'),
      createdAt: createdAt,
      closesAt: closesAt,
      resolvedOutcomeId: resolvedOutcomeId,
      totalVolume: totalVolume,
    );
  }
}
