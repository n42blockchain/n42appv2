import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/earn/pages/earn_page.dart';
import 'package:n42_wallet/features/earn/pages/earn_page_logic.dart';
import 'package:n42_wallet/features/earn/pages/earn_page_products.dart';
import 'package:n42_wallet/features/earn/pages/earn_page_sections.dart';
import 'package:n42_wallet/features/earn/pages/earn_page_widgets.dart';
import 'package:n42_wallet/features/earn/provider/earn_provider.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

class _ProductsHarness extends EarnPage {
  const _ProductsHarness({required this.earnState});

  final EarnState earnState;

  @override
  ConsumerState<EarnPage> createState() => _ProductsHarnessState();
}

class _ProductsHarnessState extends ConsumerState<EarnPage>
    with
        EarnPageLogicMixin,
        EarnPageWidgetsMixin,
        EarnPageSectionsMixin,
        EarnPageProductsMixin {
  @override
  Widget build(BuildContext context) {
    final state = (widget as _ProductsHarness).earnState;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildActiveProducts(context, state),
            buildRecommendedProducts(context, state),
          ],
        ),
      ),
    );
  }
}

StakingPosition _position({
  required String id,
  required String name,
  required StakingChainType chainType,
  required String symbol,
  required BigInt stakedAmount,
  BigInt? pendingRewards,
  StakingPositionStatus status = StakingPositionStatus.active,
}) => StakingPosition(
  id: id,
  protocol: StakingProtocol(
    id: id,
    name: name,
    description: '$name staking',
    chainType: chainType,
    chainSymbol: symbol,
    logoUri: '',
    apy: 4.0,
    minStakeAmount: 0,
    unbondingPeriodDays: 21,
  ),
  stakedAmount: stakedAmount,
  rewardsEarned: BigInt.zero,
  pendingRewards: pendingRewards ?? BigInt.zero,
  stakedAt: DateTime(2026, 1, 1),
  status: status,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpProducts(WidgetTester tester, EarnState state) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrapForTest(_ProductsHarness(earnState: state)));
  }

  testWidgets('shows loading instead of the empty state while positions load', (
    tester,
  ) async {
    await pumpProducts(tester, const EarnState(positionsLoading: true));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(S.current.g_key_earn_no_positions), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the empty position guide after loading completes', (
    tester,
  ) async {
    await pumpProducts(tester, const EarnState());

    expect(find.text(S.current.g_key_earn_no_positions), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'shows active and unbonding balances with the correct APY states',
    (tester) async {
      final active = _position(
        id: 'eth-active',
        name: 'Lido position',
        chainType: StakingChainType.ethereum,
        symbol: 'ETH',
        stakedAmount: BigInt.parse('1500000000000000000'),
        pendingRewards: BigInt.parse('50000000000000000'),
      );
      final unbonding = _position(
        id: 'atom-unbonding',
        name: 'Cosmos position',
        chainType: StakingChainType.cosmos,
        symbol: 'ATOM',
        stakedAmount: BigInt.from(1250000),
        status: StakingPositionStatus.unbonding,
      );
      final completed = _position(
        id: 'dot-completed',
        name: 'Completed position',
        chainType: StakingChainType.polkadot,
        symbol: 'DOT',
        stakedAmount: BigInt.from(10000000000),
        status: StakingPositionStatus.completed,
      );
      await pumpProducts(
        tester,
        EarnState(
          activePositions: [active, unbonding, completed],
          ethApy: 5.26,
          solApy: 8.2,
          apyLoading: false,
        ),
      );

      expect(find.text('Lido position'), findsOneWidget);
      expect(find.text('1.5 ETH'), findsOneWidget);
      expect(find.text('+0.05 ETH'), findsOneWidget);
      expect(find.text('5.3% APY'), findsOneWidget);
      expect(find.text('Unbonding'), findsOneWidget);
      expect(find.text('Cosmos position'), findsOneWidget);
      expect(find.text('1.25 ATOM'), findsOneWidget);
      expect(find.text('~5.3% APY'), findsOneWidget);
      expect(find.text('~8.2% APY'), findsOneWidget);
      expect(find.text('Completed position'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('recommended products use placeholders while APYs load', (
    tester,
  ) async {
    await pumpProducts(tester, const EarnState(apyLoading: true));

    expect(find.text('...'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
