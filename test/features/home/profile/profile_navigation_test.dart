import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/home/profile/profile_home_page.dart';
import 'package:n42_wallet/features/home/setting/setting_sys_language.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/wallet_activity_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('history opens the ledger directly without selecting a wallet', (
    tester,
  ) async {
    await tester.pumpWidget(wrapForTest(const ProfileHomePage()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Transaction history'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transaction history'));
    await tester.pumpAndSettle();
    expect(find.byType(WalletActivityPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'language selection applies and USD is an informational setting',
    (tester) async {
      await tester.pumpWidget(wrapForTest(const ProfileHomePage()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Language'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingSysLanguage), findsOneWidget);
      Navigator.of(tester.element(find.byType(SettingSysLanguage))).pop('fr');
      await tester.pumpAndSettle();
      expect(find.text('Français'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('USD'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final currency = tester.widget<ListTile>(
        find.ancestor(of: find.text('USD'), matching: find.byType(ListTile)),
      );
      expect(currency.onTap, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
