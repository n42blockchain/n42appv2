import 'dart:async';
import 'dart:math';

import '../domain/prediction_market.dart';
import '../domain/prediction_repository.dart';

/// 内存 LMSR 自动做市（AMM）实现，供 MVP 无合约联调全套 UX。
///
/// 定价采用 LMSR（Logarithmic Market Scoring Rule）：结果价格即隐含概率，
/// 各价格之和≈1，随买入移动。开奖后赢家份额 1:1 赎回结算代币、输家归零；
/// 取消则退回净投入本金。单进程内存态——主播创建/开奖与观众下注共享，
/// 适合单机演示。真实资金请用 ChainPredictionRepository 对接托管合约。
class MockPredictionRepository implements PredictionRepository {
  MockPredictionRepository({double initialBalance = 1000}) {
    _balance = initialBalance;
  }

  static const double _liquidity = 50; // LMSR b 参数

  @override
  final CollateralToken collateral = const CollateralToken(symbol: 'tUSDC');

  /// 当前用户标识（真实实现为钱包地址；mock 单用户）。
  String currentUserId = 'me';

  late double _balance;
  int _seq = 0;

  final Map<String, _MarketState> _markets = {};

  // 任一状态变化的广播 tick；各 watch* 以"先发当前快照、再随 tick 重算"模式推送。
  final StreamController<void> _changes = StreamController<void>.broadcast();

  void _emit() {
    if (!_changes.isClosed) _changes.add(null);
  }

  void dispose() {
    _changes.close();
  }

  // ── 流 ──

  @override
  Stream<double> watchBalance() async* {
    yield _balance;
    yield* _changes.stream.map((_) => _balance);
  }

  @override
  Stream<List<PredictionMarket>> watchMarkets(String roomId) async* {
    yield _snapshotForRoom(roomId);
    yield* _changes.stream.map((_) => _snapshotForRoom(roomId));
  }

  @override
  Stream<PredictionMarket> watchMarket(String marketId) async* {
    final initial = _markets[marketId]?.toModel();
    if (initial != null) yield initial;
    yield* _changes.stream
        .map((_) => _markets[marketId]?.toModel())
        .where((m) => m != null)
        .cast<PredictionMarket>();
  }

  @override
  Stream<UserPosition> watchPosition(String marketId) async* {
    yield _positionFor(marketId);
    yield* _changes.stream.map((_) => _positionFor(marketId));
  }

  List<PredictionMarket> _snapshotForRoom(String roomId) {
    final list =
        _markets.values
            .where((m) => m.roomId == roomId)
            .map((m) => m.toModel())
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  UserPosition _positionFor(String marketId) {
    final m = _markets[marketId];
    final shares = m?.positions[currentUserId] ?? const <String, double>{};
    return UserPosition(
      marketId: marketId,
      shares: Map<String, double>.from(shares),
      claimed: m?.claimed[currentUserId] ?? false,
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
      throw StateError('至少需要两个结果');
    }
    final id = 'mkt_${DateTime.now().millisecondsSinceEpoch}_${_seq++}';
    final outcomes = <_OutcomeState>[];
    for (var i = 0; i < outcomeLabels.length; i++) {
      outcomes.add(_OutcomeState(id: 'o$i', label: outcomeLabels[i]));
    }
    _markets[id] = _MarketState(
      id: id,
      roomId: roomId,
      question: question,
      outcomes: outcomes,
      createdAt: DateTime.now(),
      closesAt: closesAt,
      collateral: collateral,
    );
    _emit();
    return _markets[id]!.toModel();
  }

  @override
  Future<void> closeMarket(String marketId) async {
    final m = _require(marketId);
    if (m.status == MarketStatus.open) {
      m.status = MarketStatus.closed;
      _emit();
    }
  }

  @override
  Future<void> resolveMarket(String marketId, String winningOutcomeId) async {
    final m = _require(marketId);
    if (m.status == MarketStatus.resolved) return;
    if (m.outcomes.every((o) => o.id != winningOutcomeId)) {
      throw StateError('无效的结果');
    }
    m.status = MarketStatus.resolved;
    m.resolvedOutcomeId = winningOutcomeId;
    _emit();
  }

  @override
  Future<void> cancelMarket(String marketId) async {
    final m = _require(marketId);
    m.status = MarketStatus.cancelled;
    _emit();
  }

  // ── 观众交易 ──

  @override
  Future<TradeQuote> quoteBuy({
    required String marketId,
    required String outcomeId,
    required double collateralIn,
  }) async {
    final m = _require(marketId);
    final i = m.indexOf(outcomeId);
    final delta = m.solveSharesForCollateral(i, collateralIn);
    final after = m.pricesAfterBuy(i, delta)[i];
    return TradeQuote(
      outcomeId: outcomeId,
      collateralIn: collateralIn,
      shares: delta,
      avgPrice: delta > 0 ? collateralIn / delta : 0,
      priceAfter: after,
    );
  }

  @override
  Future<void> buy({
    required String marketId,
    required String outcomeId,
    required double collateralIn,
    double? minShares,
  }) async {
    final m = _require(marketId);
    if (!m.tradable) throw StateError('已停盘，无法下注');
    if (collateralIn <= 0) throw StateError('金额必须大于 0');
    if (collateralIn > _balance) throw StateError('余额不足');

    final i = m.indexOf(outcomeId);
    final delta = m.solveSharesForCollateral(i, collateralIn);
    if (minShares != null && delta < minShares) {
      throw StateError('滑点超限：预计份额 ${delta.toStringAsFixed(2)} < $minShares');
    }
    m.q[i] += delta;
    _balance -= collateralIn;
    m.addPosition(currentUserId, outcomeId, delta);
    m.netPaid[currentUserId] = (m.netPaid[currentUserId] ?? 0) + collateralIn;
    m.totalVolume += collateralIn;
    _emit();
  }

  @override
  Future<void> sell({
    required String marketId,
    required String outcomeId,
    required double shares,
    double? minCollateral,
  }) async {
    final m = _require(marketId);
    if (!m.tradable) throw StateError('已停盘，无法卖出');
    final held = m.positions[currentUserId]?[outcomeId] ?? 0;
    if (shares <= 0 || shares > held) throw StateError('持仓不足');

    final i = m.indexOf(outcomeId);
    final proceeds = m.proceedsForSell(i, shares);
    if (minCollateral != null && proceeds < minCollateral) {
      throw StateError('滑点超限');
    }
    m.q[i] -= shares;
    _balance += proceeds;
    m.addPosition(currentUserId, outcomeId, -shares);
    m.netPaid[currentUserId] = (m.netPaid[currentUserId] ?? 0) - proceeds;
    m.totalVolume += proceeds;
    _emit();
  }

  @override
  Future<void> redeem(String marketId) async {
    final m = _require(marketId);
    if (m.claimed[currentUserId] == true) return;

    double payout = 0;
    if (m.status == MarketStatus.resolved) {
      final winner = m.resolvedOutcomeId!;
      payout = m.positions[currentUserId]?[winner] ?? 0; // 1 份额 = 1 代币
    } else if (m.status == MarketStatus.cancelled) {
      payout = (m.netPaid[currentUserId] ?? 0).clamp(0, double.infinity);
    } else {
      throw StateError('市场未开奖，无法赎回');
    }

    _balance += payout;
    m.positions[currentUserId] = {};
    m.claimed[currentUserId] = true;
    _emit();
  }

  _MarketState _require(String marketId) {
    final m = _markets[marketId];
    if (m == null) throw StateError('市场不存在');
    return m;
  }
}

/// 单个市场的可变内存态。
class _MarketState {
  _MarketState({
    required this.id,
    required this.roomId,
    required this.question,
    required this.outcomes,
    required this.createdAt,
    required this.collateral,
    this.closesAt,
  }) : q = List<double>.filled(outcomes.length, 0);

  static const double b = MockPredictionRepository._liquidity;

  final String id;
  final String roomId;
  final String question;
  final List<_OutcomeState> outcomes;
  final DateTime createdAt;
  final DateTime? closesAt;
  final CollateralToken collateral;

  /// LMSR 各结果累计份额。
  final List<double> q;
  MarketStatus status = MarketStatus.open;
  String? resolvedOutcomeId;
  double totalVolume = 0;

  /// user -> (outcomeId -> shares)
  final Map<String, Map<String, double>> positions = {};

  /// user -> 净投入本金（用于取消退款）。
  final Map<String, double> netPaid = {};

  /// user -> 是否已赎回。
  final Map<String, bool> claimed = {};

  bool get _expired => closesAt != null && DateTime.now().isAfter(closesAt!);

  bool get tradable => status == MarketStatus.open && !_expired;

  int indexOf(String outcomeId) {
    final i = outcomes.indexWhere((o) => o.id == outcomeId);
    if (i < 0) throw StateError('无效的结果');
    return i;
  }

  void addPosition(String user, String outcomeId, double delta) {
    final map = positions.putIfAbsent(user, () => {});
    map[outcomeId] = (map[outcomeId] ?? 0) + delta;
    if ((map[outcomeId] ?? 0) <= 1e-9) map.remove(outcomeId);
  }

  // ── LMSR 定价 ──

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

  /// 给定预算求可买份额（cost 关于份额单调递增，二分求解）。
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

  /// 卖出份额可得（退还 LMSR 成本差）。
  double proceedsForSell(int i, double shares) {
    final base = _cost(q);
    final q2 = [...q];
    q2[i] -= shares;
    return base - _cost(q2);
  }

  PredictionMarket toModel() {
    final ps = prices();
    return PredictionMarket(
      id: id,
      roomId: roomId,
      question: question,
      outcomes: [
        for (var i = 0; i < outcomes.length; i++)
          MarketOutcome(
            id: outcomes[i].id,
            label: outcomes[i].label,
            price: ps[i],
          ),
      ],
      status: tradable ? MarketStatus.open : _effectiveStatus,
      collateral: collateral,
      createdAt: createdAt,
      closesAt: closesAt,
      resolvedOutcomeId: resolvedOutcomeId,
      totalVolume: totalVolume,
    );
  }

  MarketStatus get _effectiveStatus {
    if (status == MarketStatus.open && _expired) return MarketStatus.closed;
    return status;
  }
}

class _OutcomeState {
  _OutcomeState({required this.id, required this.label});
  final String id;
  final String label;
}
