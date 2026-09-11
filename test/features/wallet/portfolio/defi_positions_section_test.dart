import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/api_hub/datasources/debank_datasource.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/defi_positions_section.dart';
import '../../../helpers/widget_test_helpers.dart';

DeFiPortfolio portfolio(String name, {int count = 1}) => DeFiPortfolio(
  protocols: List.generate(
    count,
    (i) => ProtocolPosition(
      id: '$i',
      name: '$name $i',
      chain: 'eth',
      totalUsdValue: 1,
      positions: [],
    ),
  ),
  totalUsdValue: count.toDouble(),
  lendingValue: 0,
  lpValue: 0,
  stakingValue: 0,
  rewardsValue: 0,
);

void main() {
  testWidgets('view all reveals protocols after the tenth and can collapse', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        SingleChildScrollView(
          child: DeFiPositionsSection(
            walletAddress: 'alice',
            loadPortfolio: (_) async => portfolio('Protocol', count: 11),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Protocol 10'), findsNothing);
    await tester.ensureVisible(find.byKey(const ValueKey('defi_view_all')));
    await tester.tap(find.byKey(const ValueKey('defi_view_all')));
    await tester.pumpAndSettle();
    expect(find.text('Protocol 10'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('defi_view_all')));
    await tester.tap(find.byKey(const ValueKey('defi_view_all')));
    await tester.pumpAndSettle();
    expect(find.text('Protocol 10'), findsNothing);
  });

  testWidgets('failure offers retry instead of appearing as zero holdings', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      wrapForTest(
        DeFiPositionsSection(
          walletAddress: 'alice',
          loadPortfolio: (_) async {
            if (++calls == 1) throw StateError('offline');
            return portfolio('Recovered');
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(find.text('Recovered 0'), findsOneWidget);
  });

  testWidgets('late response cannot overwrite another wallet', (tester) async {
    final alice = Completer<DeFiPortfolio>();
    final bob = Completer<DeFiPortfolio>();
    Future<DeFiPortfolio> load(String address) =>
        address == 'alice' ? alice.future : bob.future;
    await tester.pumpWidget(
      wrapForTest(
        DeFiPositionsSection(walletAddress: 'alice', loadPortfolio: load),
      ),
    );
    await tester.pump();
    await tester.pumpWidget(
      wrapForTest(
        DeFiPositionsSection(walletAddress: 'bob', loadPortfolio: load),
      ),
    );
    bob.complete(portfolio('Bob'));
    await tester.pumpAndSettle();
    alice.complete(portfolio('Alice'));
    await tester.pumpAndSettle();
    expect(find.text('Bob 0'), findsOneWidget);
    expect(find.text('Alice 0'), findsNothing);
  });
}
