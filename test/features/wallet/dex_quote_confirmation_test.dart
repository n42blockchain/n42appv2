import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_quote_model.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_quote_validity.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_action_buttons.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_confirm.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_quote_card.dart';
import '../../helpers/widget_test_helpers.dart';

DexQuoteModel quote(String output) => DexQuoteModel(
  orderId: 'same-order',
  tokenInSymbol: 'ETH',
  tokenOutSymbol: 'USDC',
  amountIn: '1',
  amountOut: output,
  minAmountOut: output,
  priceImpact: '0.1%',
  gasEstimate: '0.001 ETH',
  source: 'test',
  calldata: '0x1234',
  routerAddr: '0xrouter',
  chain: 'ETH',
);

void main() {
  testWidgets('quote details wrap on narrow screens with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
          child: SingleChildScrollView(
            child: DexQuoteCard(
              quote: quote('123456789.123456789123456789'),
              secsLeft: 58,
              needsApproval: true,
              exactApprove: true,
              tokenInSymbol: 'USDC',
              onExactApproveChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('123456789.123456789123456789 USDC'), findsOneWidget);
  });

  test(
    'rejects replaced quotes even with reused IDs and rejects exact expiry',
    () {
      final original = quote('100');
      final refreshed = quote('90');
      final now = DateTime.utc(2026, 9, 10);
      expect(
        isCurrentDexQuote(
          confirmed: original,
          current: refreshed,
          expiresAt: now.add(const Duration(seconds: 1)),
          now: now,
        ),
        isFalse,
      );
      expect(
        isCurrentDexQuote(
          confirmed: original,
          current: original,
          expiresAt: now,
          now: now,
        ),
        isFalse,
      );
      expect(
        isCurrentDexQuote(
          confirmed: original,
          current: original,
          expiresAt: now.add(const Duration(seconds: 1)),
          now: now,
        ),
        isTrue,
      );
      expect(
        isCurrentDexQuote(
          confirmed: original,
          current: null,
          expiresAt: null,
          now: now,
        ),
        isFalse,
      );
    },
  );

  testWidgets(
    'confirmation returns the quote that was displayed during a refresh',
    (tester) async {
      final original = quote('100');
      var current = original;
      DexQuoteModel? confirmed;
      late StateSetter update;
      await tester.pumpWidget(
        wrapForTest(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return DexActionButtons(
                quote: current,
                needsApproval: false,
                approveLoad: Load.finish,
                swapLoad: Load.finish,
                tokenInSymbol: 'ETH',
                onApprove: () {},
                onSwapConfirmed: (value) => confirmed = value,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Swap'));
      await tester.pumpAndSettle();
      expect(find.byType(DexSwapConfirm), findsOneWidget);
      update(() => current = quote('90'));
      await tester.pump();
      final confirmContext = tester.element(find.byType(DexSwapConfirm));
      Navigator.of(confirmContext).pop(true);
      await tester.pumpAndSettle();
      expect(identical(confirmed, original), isTrue);
      expect(identical(confirmed, current), isFalse);
    },
  );
}
