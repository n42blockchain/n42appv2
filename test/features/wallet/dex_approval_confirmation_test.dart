import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_approval_confirmation.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_security_verification.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets(
    'approval displays the spender and amount and cancel stops authentication',
    (tester) async {
      bool? result;
      await tester.pumpWidget(
        wrapForTest(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await confirmDexApproval(
                context,
                tokenSymbol: 'USDC',
                tokenAddress: '0xToken',
                spender: '0xSpender',
                chain: 'ETH',
                amountLabel: '12.50',
              ),
              child: const Text('Approve'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();
      expect(find.text('0xSpender'), findsOneWidget);
      expect(find.text('0xToken'), findsOneWidget);
      expect(find.text('12.50 USDC · ETH'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
      expect(find.byType(WalletSecurityVerification), findsNothing);
    },
  );
}
