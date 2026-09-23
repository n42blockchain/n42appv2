import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/aa/paymaster_select_page.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/paymaster_option_card.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('unsupported chain offers self-pay and returns it on confirm', (
    tester,
  ) async {
    PaymasterOption? result;
    await _pumpPage(tester, onResult: (option) => result = option);

    expect(find.text(S.current.g_key_aa_pay_with_eth), findsNWidgets(2));
    expect(find.text(S.current.g_key_aa_sponsored), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.text(S.current.g_key_78));

    expect(result?.type, PaymasterType.none);
  });

  testWidgets('unavailable sponsorship cannot replace self-pay selection', (
    tester,
  ) async {
    PaymasterOption? result;
    await _pumpPage(tester, onResult: (option) => result = option);

    final sponsoredCard = find.ancestor(
      of: find.text(S.current.g_key_aa_sponsored).first,
      matching: find.byType(PaymasterOptionCard),
    );
    await tester.tap(sponsoredCard);
    await tester.tap(find.text(S.current.g_key_78));

    expect(result?.type, PaymasterType.none);
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required ValueChanged<PaymasterOption> onResult,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    wrapForTest(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push<PaymasterOption>(
                      MaterialPageRoute(
                        builder: (_) => const PaymasterSelectPage(
                          currentOption: PaymasterOption.none,
                          chainId: 99999999,
                          chainSymbol: 'UNSUPPORTED',
                        ),
                      ),
                    )
                    .then((result) {
                      if (result != null) onResult(result);
                    });
              },
              child: const Text('Open paymaster'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open paymaster'));
  await tester.pumpAndSettle();
}
