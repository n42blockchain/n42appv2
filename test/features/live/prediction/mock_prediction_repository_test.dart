import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/live/prediction/data/mock_prediction_repository.dart';
import 'package:n42_wallet/features/live/prediction/domain/prediction_market.dart';
import 'package:n42_wallet/features/live/prediction/domain/prediction_repository.dart';

void main() {
  late MockPredictionRepository repo;

  setUp(() => repo = MockPredictionRepository(initialBalance: 1000));
  tearDown(() => repo.dispose());

  Future<PredictionMarket> open2() => repo.createMarket(
    roomId: 'room1',
    question: '本局谁赢？',
    outcomeLabels: const ['A', 'B'],
  );

  Future<double> balance() => repo.watchBalance().first;
  Future<PredictionMarket> market(String id) => repo.watchMarket(id).first;
  Future<UserPosition> position(String id) => repo.watchPosition(id).first;

  test('初始价格相等且之和≈1', () async {
    final m = await open2();
    expect(m.outcomes.length, 2);
    expect(m.outcomes[0].price, closeTo(0.5, 1e-6));
    expect(m.outcomes[1].price, closeTo(0.5, 1e-6));
    final sum = m.outcomes.fold<double>(0, (s, o) => s + o.price);
    expect(sum, closeTo(1.0, 1e-6));
  });

  test('买入推高所选结果价格并扣减余额', () async {
    final m = await open2();
    final o0 = m.outcomes[0].id;
    await repo.buy(marketId: m.id, outcomeId: o0, collateralIn: 100);

    expect(await balance(), closeTo(900, 1e-6));
    final after = await market(m.id);
    expect(after.outcomeById(o0)!.price, greaterThan(0.5));
    // 价格仍归一化
    final sum = after.outcomes.fold<double>(0, (s, o) => s + o.price);
    expect(sum, closeTo(1.0, 1e-6));
    // 持仓为正
    expect((await position(m.id)).sharesOf(o0), greaterThan(0));
  });

  test('quote 与实际买入份额一致', () async {
    final m = await open2();
    final o0 = m.outcomes[0].id;
    final q = await repo.quoteBuy(
      marketId: m.id,
      outcomeId: o0,
      collateralIn: 100,
    );
    await repo.buy(marketId: m.id, outcomeId: o0, collateralIn: 100);
    expect((await position(m.id)).sharesOf(o0), closeTo(q.shares, 1e-6));
    expect(q.avgPrice, closeTo(100 / q.shares, 1e-6));
  });

  test('卖出退回代币并减少持仓', () async {
    final m = await open2();
    final o0 = m.outcomes[0].id;
    await repo.buy(marketId: m.id, outcomeId: o0, collateralIn: 100);
    final held = (await position(m.id)).sharesOf(o0);

    await repo.sell(marketId: m.id, outcomeId: o0, shares: held);
    expect((await position(m.id)).sharesOf(o0), closeTo(0, 1e-6));
    // 全额买入后立即全额卖出，应基本回到初始余额（LMSR 往返近似无损）
    expect(await balance(), closeTo(1000, 1e-3));
  });

  test('开奖后赢家份额 1:1 赎回、净赚为正', () async {
    final m = await open2();
    final o0 = m.outcomes[0].id;
    await repo.buy(marketId: m.id, outcomeId: o0, collateralIn: 100);
    final shares = (await position(m.id)).sharesOf(o0);

    await repo.resolveMarket(m.id, o0);
    await repo.redeem(m.id);

    // 余额 = 1000 - 100 + shares（赢家每份额兑 1 代币）
    expect(await balance(), closeTo(900 + shares, 1e-6));
    expect(shares, greaterThan(100)); // 押中应净赚
    expect((await position(m.id)).claimed, isTrue);
  });

  test('押错方赎回得 0', () async {
    final m = await open2();
    final o0 = m.outcomes[0].id;
    final o1 = m.outcomes[1].id;
    await repo.buy(marketId: m.id, outcomeId: o1, collateralIn: 100);

    await repo.resolveMarket(m.id, o0); // o0 获胜，押了 o1
    await repo.redeem(m.id);
    expect(await balance(), closeTo(900, 1e-6)); // 输掉本金
  });

  test('取消市场退回净投入本金', () async {
    final m = await open2();
    final o0 = m.outcomes[0].id;
    await repo.buy(marketId: m.id, outcomeId: o0, collateralIn: 100);

    await repo.cancelMarket(m.id);
    await repo.redeem(m.id);
    expect(await balance(), closeTo(1000, 1e-6));
  });

  test('停盘后无法下注', () async {
    final m = await open2();
    final o0 = m.outcomes[0].id;
    await repo.closeMarket(m.id);
    expect(
      () => repo.buy(marketId: m.id, outcomeId: o0, collateralIn: 10),
      throwsA(isA<PredictionException>()),
    );
  });

  test('余额不足抛错', () async {
    final m = await open2();
    final o0 = m.outcomes[0].id;
    expect(
      () => repo.buy(marketId: m.id, outcomeId: o0, collateralIn: 5000),
      throwsA(isA<PredictionException>()),
    );
  });

  test('过期截止视为停盘，拒绝下注', () async {
    final m = await repo.createMarket(
      roomId: 'room1',
      question: '限时',
      outcomeLabels: const ['A', 'B'],
      closesAt: DateTime.now().subtract(const Duration(seconds: 1)),
    );
    expect((await market(m.id)).status, MarketStatus.closed);
    expect(
      () => repo.buy(
        marketId: m.id,
        outcomeId: m.outcomes[0].id,
        collateralIn: 10,
      ),
      throwsA(isA<PredictionException>()),
    );
  });

  PredictionError? errorOf(Object? e) =>
      e is PredictionException ? e.error : null;

  test('已开奖的市场不能再取消（防双重支付）', () async {
    final m = await open2();
    await repo.resolveMarket(m.id, m.outcomes[0].id);
    await expectLater(
      () => repo.cancelMarket(m.id),
      throwsA(predicate((e) => errorOf(e) == PredictionError.invalidState)),
    );
    // 状态保持 resolved，未被改写为 cancelled
    expect((await market(m.id)).status, MarketStatus.resolved);
  });

  test('已取消的市场不能再开奖', () async {
    final m = await open2();
    await repo.cancelMarket(m.id);
    await expectLater(
      () => repo.resolveMarket(m.id, m.outcomes[0].id),
      throwsA(predicate((e) => errorOf(e) == PredictionError.invalidState)),
    );
    expect((await market(m.id)).status, MarketStatus.cancelled);
  });

  test('终态市场停盘抛非法状态', () async {
    final m = await open2();
    await repo.resolveMarket(m.id, m.outcomes[0].id);
    await expectLater(
      () => repo.closeMarket(m.id),
      throwsA(predicate((e) => errorOf(e) == PredictionError.invalidState)),
    );
  });

  test('重复开奖/重复取消幂等不抛错', () async {
    final m1 = await open2();
    await repo.resolveMarket(m1.id, m1.outcomes[0].id);
    await repo.resolveMarket(m1.id, m1.outcomes[0].id); // 不抛
    expect((await market(m1.id)).status, MarketStatus.resolved);

    final m2 = await open2();
    await repo.cancelMarket(m2.id);
    await repo.cancelMarket(m2.id); // 不抛
    expect((await market(m2.id)).status, MarketStatus.cancelled);
  });

  test('LMSR：同一结果连续买入价格单调上升且始终归一化', () async {
    // 注意：LMSR 为份额边际定价——价格反映各结果累计份额而非投入金额，
    // 在便宜的长尾结果上等额买入会换到更多份额、价格抬升更猛（与平注池不同）。
    // 因此正确不变量是"买某结果会抬高其价格"，而非"投钱多者价更高"。
    final m = await open2();
    final o0 = m.outcomes[0].id;

    await repo.buy(marketId: m.id, outcomeId: o0, collateralIn: 50);
    final p1 = (await market(m.id)).outcomeById(o0)!.price;
    await repo.buy(marketId: m.id, outcomeId: o0, collateralIn: 50);
    final after = await market(m.id);
    final p2 = after.outcomeById(o0)!.price;

    expect(p1, greaterThan(0.5));
    expect(p2, greaterThan(p1));
    final sum = after.outcomes.fold<double>(0, (s, o) => s + o.price);
    expect(sum, closeTo(1.0, 1e-6));
  });
}
