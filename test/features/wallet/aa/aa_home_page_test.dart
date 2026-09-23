import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_home_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets(
    'unsupported owner address disables AA actions with explanation',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        wrapForTest(const AAHomePage(walletAddress: 'not-an-evm-address')),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(S.current.g_key_bridge_chain_not_supported),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text(S.current.g_key_48));
      await tester.tap(find.text(S.current.g_key_48));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    },
  );

  testWidgets('supported owner with no smart accounts sees onboarding steps', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        AAHomePage(
          walletAddress: '0x1111111111111111111111111111111111111111',
          accountInfo: AAAccountInfo(smartAccounts: {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(S.current.g_key_aa_no_accounts), findsOneWidget);
    expect(find.text(S.current.g_key_aa_onboard_step1), findsOneWidget);
    expect(find.text(S.current.g_key_aa_onboard_step2), findsOneWidget);
    expect(find.text(S.current.g_key_aa_onboard_step3), findsOneWidget);
    expect(find.text(S.current.g_key_aa_create_account), findsOneWidget);
  });
}
