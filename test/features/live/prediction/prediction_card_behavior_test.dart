import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/live/prediction/data/mock_prediction_repository.dart';
import 'package:n42_wallet/features/live/prediction/domain/prediction_market.dart';
import 'package:n42_wallet/features/live/prediction/providers/prediction_providers.dart';
import 'package:n42_wallet/features/live/prediction/widgets/prediction_card.dart';
import 'package:n42_wallet/features/live/prediction/widgets/trade_sheet.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

const _roomId = '!prediction-room:m.example';

class _RedeemFailureRepository extends MockPredictionRepository {
  @override
  Future<void> redeem(String marketId) async {
    throw StateError('redemption unavailable');
  }
}

void main() {
  late MockPredictionRepository repository;

  setUp(() => repository = MockPredictionRepository(initialBalance: 1000));
  tearDown(() => repository.dispose());

  Future<PredictionMarket> createMarket({
    DateTime? closesAt,
    String roomId = _roomId,
  }) => repository.createMarket(
    roomId: roomId,
    question: 'Will the launch happen today?',
    outcomeLabels: const ['YES', 'NO'],
    closesAt: closesAt,
  );

  Future<void> mount(WidgetTester tester, {String roomId = _roomId}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Scaffold(body: PredictionCard(roomId: roomId)),
        overrides: [
          predictionRepositoryProvider.overrideWith((ref) => repository),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('an empty room hides the card and a new market appears', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text('Will the launch happen today?'), findsNothing);

    await createMarket();
    await tester.pumpAndSettle();

    expect(find.text('Will the launch happen today?'), findsOneWidget);
    expect(find.text('进行中'), findsOneWidget);
    expect(find.text('YES'), findsOneWidget);
    expect(find.text('NO'), findsOneWidget);
    expect(find.text('50%'), findsNWidgets(2));
    expect(find.text('成交量 0 tUSDC'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an open outcome opens trading and reflects a completed buy', (
    tester,
  ) async {
    final market = await createMarket(
      closesAt: DateTime.now().add(const Duration(minutes: 2)),
    );
    await mount(tester);
    final l10n = S.of(tester.element(find.byType(PredictionCard)));

    expect(find.text('进行中'), findsOneWidget);
    expect(find.textContaining('后截止'), findsOneWidget);
    await tester.tap(find.text('YES'));
    await tester.pumpAndSettle();

    expect(find.byType(TradeSheet), findsOneWidget);
    expect(find.text('Will the launch happen today?'), findsNWidgets(2));
    expect(find.text(l10n.g_pred_balance('1000.00', 'tUSDC')), findsOneWidget);
    expect(find.text(l10n.g_pred_buy), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(l10n.g_pred_buy));
    await tester.pumpAndSettle();
    final position = await repository.watchPosition(market.id).first;
    final shares = position.sharesOf(market.outcomes.first.id);

    expect(shares, greaterThan(0));
    expect(find.byType(TradeSheet), findsNothing);
    expect(find.text('持 ${shares.toStringAsFixed(1)}'), findsOneWidget);
    expect(find.text('成交量 10 tUSDC'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a resolved winner can redeem shares from the card', (
    tester,
  ) async {
    final market = await createMarket();
    await repository.buy(
      marketId: market.id,
      outcomeId: market.outcomes.first.id,
      collateralIn: 20,
    );
    await repository.resolveMarket(market.id, market.outcomes.first.id);
    await mount(tester);
    final position = await repository.watchPosition(market.id).first;
    final shares = position.sharesOf(market.outcomes.first.id);

    expect(find.text('已开奖：YES'), findsOneWidget);
    expect(find.text('持 ${shares.toStringAsFixed(1)}'), findsOneWidget);
    expect(find.text('赎回奖金'), findsOneWidget);
    await tester.tap(find.text('赎回奖金'));
    await tester.pumpAndSettle();

    expect(find.text('赎回奖金'), findsNothing);
    expect(find.text('持 ${shares.toStringAsFixed(1)}'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelled markets refund an existing position only', (
    tester,
  ) async {
    final market = await createMarket();
    await repository.buy(
      marketId: market.id,
      outcomeId: market.outcomes.first.id,
      collateralIn: 20,
    );
    await repository.cancelMarket(market.id);
    await mount(tester);

    expect(find.text('已取消'), findsOneWidget);
    expect(find.text('领取退款'), findsOneWidget);
    await tester.tap(find.text('领取退款'));
    await tester.pumpAndSettle();
    expect(find.text('领取退款'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a cancelled market with no position offers no refund', (
    tester,
  ) async {
    final market = await createMarket();
    await repository.cancelMarket(market.id);
    await mount(tester);

    expect(find.text('已取消'), findsOneWidget);
    expect(find.text('领取退款'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing an open market removes countdown and disables trading', (
    tester,
  ) async {
    final market = await createMarket(
      closesAt: DateTime.now().add(const Duration(minutes: 2)),
    );
    await mount(tester);

    expect(find.text('进行中'), findsOneWidget);
    expect(find.textContaining('后截止'), findsOneWidget);
    await repository.closeMarket(market.id);
    await tester.pumpAndSettle();

    expect(find.text('待开奖'), findsOneWidget);
    expect(find.textContaining('后截止'), findsNothing);
    await tester.tap(find.text('YES'));
    await tester.pumpAndSettle();
    expect(find.byType(TradeSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a locally expired open market waits for resolution', (
    tester,
  ) async {
    await createMarket(
      closesAt: DateTime.now().subtract(const Duration(seconds: 1)),
    );
    await mount(tester);

    expect(find.text('待开奖'), findsOneWidget);
    expect(find.textContaining('后截止'), findsNothing);
    await tester.tap(find.text('YES'));
    await tester.pumpAndSettle();
    expect(find.byType(TradeSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a near deadline countdown uses its warning color', (
    tester,
  ) async {
    await createMarket(
      closesAt: DateTime.now().add(const Duration(seconds: 5)),
    );
    await mount(tester);

    final countdown = find.textContaining('后截止');
    expect(countdown, findsOneWidget);
    expect(
      tester.widget<Text>(countdown).style?.color,
      AppColorTokens.warningOnOverlay,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a repository redeem failure is shown to the viewer', (
    tester,
  ) async {
    repository.dispose();
    repository = _RedeemFailureRepository();
    final market = await createMarket();
    await repository.buy(
      marketId: market.id,
      outcomeId: market.outcomes.first.id,
      collateralIn: 20,
    );
    await repository.resolveMarket(market.id, market.outcomes.first.id);
    await mount(tester);

    await tester.tap(find.text('赎回奖金'));
    await tester.pumpAndSettle();
    expect(find.textContaining('redemption unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
