import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/live/prediction/data/prediction_replay.dart';
import 'package:n42_wallet/features/live/prediction/domain/prediction_market.dart';

void main() {
  final t0 = DateTime.fromMillisecondsSinceEpoch(1000000);
  DateTime at(int sec) => t0.add(Duration(seconds: sec));
  const room = '!room:server';
  const mkt = '!room:server~m1';

  PredEvent create({
    int sec = 0,
    String sender = '@host:server',
    List<String> labels = const ['A', 'B'],
    DateTime? closesAt,
  }) => PredEvent(
    sender: sender,
    timestamp: at(sec),
    action: 'create',
    marketId: mkt,
    roomId: room,
    question: '谁赢？',
    labels: labels,
    closesAt: closesAt,
  );

  PredEvent buy(int sec, String sender, int i, double c) => PredEvent(
    sender: sender,
    timestamp: at(sec),
    action: 'buy',
    marketId: mkt,
    outcomeIndex: i,
    collateral: c,
  );

  PredEvent sell(int sec, String sender, int i, double s) => PredEvent(
    sender: sender,
    timestamp: at(sec),
    action: 'sell',
    marketId: mkt,
    outcomeIndex: i,
    shares: s,
  );

  PredEvent resolve(int sec, int i, {String sender = '@host:server'}) =>
      PredEvent(
        sender: sender,
        timestamp: at(sec),
        action: 'resolve',
        marketId: mkt,
        outcomeIndex: i,
      );

  PredEvent cancel(int sec, {String sender = '@host:server'}) => PredEvent(
    sender: sender,
    timestamp: at(sec),
    action: 'cancel',
    marketId: mkt,
  );

  PredEvent close(int sec, {String sender = '@host:server'}) => PredEvent(
    sender: sender,
    timestamp: at(sec),
    action: 'close',
    marketId: mkt,
  );

  PredictionReplay replayOf(List<PredEvent> events) =>
      PredictionReplay(initialBalance: 1000)..replay(events);

  test('建市后初始价格相等且之和≈1', () {
    final r = replayOf([create()]);
    final m = r.market(mkt, now: at(1))!;
    expect(m.outcomes.length, 2);
    expect(m.outcomes[0].price, closeTo(0.5, 1e-6));
    expect(m.outcomes[1].price, closeTo(0.5, 1e-6));
  });

  test('买入推高所选结果价格、记录持仓与交易净额', () {
    final r = replayOf([create(), buy(1, '@a:server', 0, 100)]);
    final m = r.market(mkt, now: at(2))!;
    expect(m.outcomeById('o0')!.price, greaterThan(0.5));
    final sum = m.outcomes.fold<double>(0, (s, o) => s + o.price);
    expect(sum, closeTo(1.0, 1e-6));
    expect(r.positionFor(mkt, '@a:server').sharesOf('o0'), greaterThan(0));
    // 交易净额为 -100（买入支出）
    expect(r.tradeDeltaFor('@a:server'), closeTo(-100, 1e-6));
  });

  test('确定性：同一事件序列在两端重放得到完全一致状态', () {
    final events = [
      create(),
      buy(1, '@a:server', 0, 80),
      buy(2, '@b:server', 1, 50),
      sell(3, '@a:server', 0, 10),
    ];
    final r1 = replayOf(events);
    final r2 = replayOf([...events]); // 模拟另一端
    final m1 = r1.market(mkt, now: at(9))!;
    final m2 = r2.market(mkt, now: at(9))!;
    for (var i = 0; i < m1.outcomes.length; i++) {
      expect(m1.outcomes[i].price, closeTo(m2.outcomes[i].price, 1e-12));
    }
    expect(
      r1.positionFor(mkt, '@a:server').sharesOf('o0'),
      closeTo(r2.positionFor(mkt, '@a:server').sharesOf('o0'), 1e-12),
    );
  });

  test('多用户持仓互相独立、价格反映双方累计份额', () {
    final r = replayOf([
      create(),
      buy(1, '@a:server', 0, 100),
      buy(2, '@b:server', 1, 100),
    ]);
    expect(r.positionFor(mkt, '@a:server').sharesOf('o0'), greaterThan(0));
    expect(r.positionFor(mkt, '@a:server').sharesOf('o1'), 0);
    expect(r.positionFor(mkt, '@b:server').sharesOf('o1'), greaterThan(0));
    expect(r.positionFor(mkt, '@b:server').sharesOf('o0'), 0);
    // LMSR：等额对买后价格仍归一化（注意"等额≠等份额"，故价格不必回到 0.5）。
    final m = r.market(mkt, now: at(3))!;
    final sum = m.outcomes.fold<double>(0, (s, o) => s + o.price);
    expect(sum, closeTo(1.0, 1e-6));
  });

  test('开奖：赢家可赎回份额(1:1)、输家赎回为 0', () {
    final r = replayOf([
      create(),
      buy(1, '@a:server', 0, 100), // 押 o0
      buy(2, '@b:server', 1, 100), // 押 o1
      resolve(3, 0), // o0 获胜
    ]);
    final winnerShares = r.positionFor(mkt, '@a:server').sharesOf('o0');
    expect(
      r.redeemableFor(mkt, '@a:server', now: at(4)),
      closeTo(winnerShares, 1e-9),
    );
    expect(winnerShares, greaterThan(100)); // 押中净赚
    expect(r.redeemableFor(mkt, '@b:server', now: at(4)), 0);
  });

  test('取消：退回净投入本金', () {
    final r = replayOf([create(), buy(1, '@a:server', 0, 100), cancel(2)]);
    expect(r.redeemableFor(mkt, '@a:server', now: at(3)), closeTo(100, 1e-6));
  });

  test('非建市者伪造开奖被拒——resolver 鉴权（防任意用户操纵结果）', () {
    final r = replayOf([
      create(sender: '@host:server'),
      buy(1, '@attacker:server', 0, 100), // 攻击者押 o0
      resolve(2, 0, sender: '@attacker:server'), // 攻击者伪造开奖让自己赢
    ]);
    // 伪造事件被丢弃：市场仍是 open，未被结算。
    expect(r.market(mkt, now: at(3))!.status, MarketStatus.open);
    expect(r.redeemableFor(mkt, '@attacker:server', now: at(3)), 0);
  });

  test('非建市者伪造取消被拒', () {
    final r = replayOf([
      create(sender: '@host:server'),
      buy(1, '@attacker:server', 0, 100),
      cancel(2, sender: '@attacker:server'),
    ]);
    expect(r.market(mkt, now: at(3))!.status, MarketStatus.open);
  });

  test('非建市者伪造停盘被拒', () {
    final r = replayOf([
      create(sender: '@host:server'),
      close(1, sender: '@intruder:server'),
    ]);
    expect(r.market(mkt, now: at(2))!.status, MarketStatus.open);
  });

  test('建市者本人开奖正常生效（鉴权不误伤合法操作）', () {
    final r = replayOf([
      create(sender: '@host:server'),
      buy(1, '@a:server', 0, 100),
      resolve(2, 0, sender: '@host:server'),
    ]);
    expect(r.market(mkt, now: at(3))!.status, MarketStatus.resolved);
    expect(r.redeemableFor(mkt, '@a:server', now: at(3)), greaterThan(0));
  });

  test('resolverOf 返回建市者身份；市场不存在返回 null', () {
    final r = replayOf([create(sender: '@host:server')]);
    expect(r.resolverOf(mkt), '@host:server');
    expect(r.resolverOf('unknown~market'), isNull);
  });

  test('已取消的市场不能再开奖（终态守护）', () {
    final r = replayOf([
      create(),
      buy(1, '@a:server', 0, 100),
      cancel(2),
      resolve(3, 0), // 应被忽略
    ]);
    expect(r.market(mkt, now: at(4))!.status, MarketStatus.cancelled);
  });

  test('过期截止后的买入事件被丢弃（各端一致）', () {
    final r = replayOf([
      create(closesAt: at(5)),
      buy(10, '@a:server', 0, 100), // 截止后下注
    ]);
    expect(r.positionFor(mkt, '@a:server').sharesOf('o0'), 0);
    expect(r.market(mkt, now: at(11))!.status, MarketStatus.closed);
  });

  test('卖出退回代币并减少持仓（往返近似无损）', () {
    final r = replayOf([create(), buy(1, '@a:server', 0, 100)]);
    final held = r.positionFor(mkt, '@a:server').sharesOf('o0');
    final r2 = replayOf([
      create(),
      buy(1, '@a:server', 0, 100),
      sell(2, '@a:server', 0, held),
    ]);
    expect(r2.positionFor(mkt, '@a:server').sharesOf('o0'), closeTo(0, 1e-6));
    // 全买后全卖，交易净额接近 0
    expect(r2.tradeDeltaFor('@a:server'), closeTo(0, 1e-3));
  });
}
