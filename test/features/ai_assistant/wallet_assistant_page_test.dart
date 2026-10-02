import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/ai_assistant/domain/wallet_snapshot.dart';
import 'package:n42_wallet/features/ai_assistant/presentation/wallet_assistant_page.dart';

import '../../helpers/widget_test_helpers.dart';

const _snapshot = WalletSnapshot(
  totalUsd: 1234.5,
  chainName: 'Ethereum',
  gasGwei: 12,
  assets: [
    WalletAsset(symbol: 'ETH', balance: '0.5', usdValue: 1200),
    WalletAsset(symbol: 'USDC', balance: '34.5', usdValue: 34.5),
  ],
);

Future<void> _pumpAssistant(
  WidgetTester tester,
  WalletSnapshot snapshot,
) async {
  await tester.pumpWidget(wrapForTest(WalletAssistantPage(snapshot: snapshot)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows snapshot context and a read-only introduction', (
    tester,
  ) async {
    await _pumpAssistant(tester, _snapshot);

    expect(find.byKey(const ValueKey('wallet_assistant_page')), findsOneWidget);
    expect(find.text('\$1234.50'), findsOneWidget);
    expect(find.text('Ethereum / ETH / USDC'), findsOneWidget);
    expect(find.text('Read-only'), findsOneWidget);
    expect(
      find.text(
        'Wallet snapshot loaded. Total value: \$1234.50. Top assets: ETH, USDC.',
      ),
      findsOneWidget,
    );
    expect(find.byType(ActionChip), findsNWidgets(3));
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('prompt chips return deterministic wallet answers', (
    tester,
  ) async {
    await _pumpAssistant(tester, _snapshot);

    await tester.tap(find.widgetWithText(ActionChip, 'Balance'));
    await tester.pumpAndSettle();
    expect(find.text('Your balances:\n0.5 ETH\n34.5 USDC'), findsOneWidget);

    await tester.tap(find.widgetWithText(ActionChip, 'Portfolio'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Total value: \$1234.50\nETH: 0.5 (\$1200.00)\nUSDC: 34.5 (\$34.50)',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(ActionChip, 'Help'));
    await tester.pumpAndSettle();
    expect(find.textContaining('I only read and suggest'), findsOneWidget);
  });

  testWidgets('composer ignores blank input and sends trimmed questions', (
    tester,
  ) async {
    await _pumpAssistant(tester, _snapshot);

    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining('Your balances:'), findsNothing);

    await tester.enterText(find.byType(TextField), '  balance  ');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '  balance  ',
    );
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Your balances:\n0.5 ETH\n34.5 USDC'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
  });

  testWidgets('empty snapshots show empty-state answers and unknown fallback', (
    tester,
  ) async {
    await _pumpAssistant(tester, const WalletSnapshot(totalUsd: 0, assets: []));

    expect(
      find.text(
        'Wallet snapshot loaded. Total value: \$0.00. No visible assets found.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(ActionChip, 'Balance'));
    await tester.pumpAndSettle();
    expect(find.text('No assets found on this wallet.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'tell me a joke');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining('AI chat is unavailable'), findsOneWidget);
  });
}
