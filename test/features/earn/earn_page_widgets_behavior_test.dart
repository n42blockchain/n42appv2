import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/earn/pages/earn_page.dart';
import 'package:n42_wallet/features/earn/pages/earn_page_widgets.dart';
import 'package:n42_wallet/features/earn/provider/earn_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

class _WidgetsHarness extends EarnPage {
  const _WidgetsHarness({required this.earnState, this.onTap});

  final EarnState earnState;
  final VoidCallback? onTap;

  @override
  ConsumerState<EarnPage> createState() => _WidgetsHarnessState();
}

class _WidgetsHarnessState extends ConsumerState<EarnPage>
    with EarnPageWidgetsMixin {
  @override
  Widget build(BuildContext context) {
    final harness = widget as _WidgetsHarness;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildEarningsCard(context, harness.earnState),
            SizedBox(
              height: 150,
              child: buildFeatureCard(
                context,
                title: 'Stake',
                subtitle: 'Earn from your assets',
                icon: Icons.savings,
                gradientColors: const [Colors.blue, Colors.purple],
                badge: harness.earnState.apyLoading ? null : 'NEW',
                onTap: harness.onTap,
              ),
            ),
            Row(
              children: [
                buildToolItem(
                  context,
                  icon: Icons.swap_horiz,
                  label: 'Swap',
                  color: Colors.teal,
                  onTap: harness.onTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpHarness(
    WidgetTester tester,
    EarnState state, {
    VoidCallback? onTap,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(_WidgetsHarness(earnState: state, onTap: onTap)),
    );
  }

  testWidgets('earnings card shows loading states without stale balances', (
    tester,
  ) async {
    await pumpHarness(
      tester,
      const EarnState(apyLoading: true, positionsLoading: true),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text(S.current.g_key_earn_loading_apy), findsNothing);
    expect(find.text('...'), findsNWidgets(3));
    expect(find.text('NEW'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'earnings card displays APY, balances, feature badge and actions',
    (tester) async {
      var taps = 0;
      await pumpHarness(
        tester,
        const EarnState(ethApy: 3.25, solApy: 6.75, atomApy: 9.15),
        onTap: () => taps++,
      );

      expect(find.text('up to 9.2% APY'), findsOneWidget);
      expect(find.text('\$0.00'), findsNWidgets(3));
      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('Earn from your assets'), findsOneWidget);
      await tester.tap(find.text('Stake'));
      await tester.tap(find.text('Swap'));

      expect(taps, 2);
      expect(tester.takeException(), isNull);
    },
  );
}
