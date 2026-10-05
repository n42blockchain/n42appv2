import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/mining_import.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(wrapForTest(const MiningImport()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('empty encrypted data is rejected before import starts', (
    tester,
  ) async {
    await mount(tester);

    await tester.tap(
      find.text(
        S.of(tester.element(find.byType(MiningImport))).g_token_m_key_9,
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MiningImport));
    expect(find.text(S.of(context).g_mining_key_105), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_106), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('password must contain exactly eight characters', (tester) async {
    await mount(tester);
    await tester.enterText(find.byType(TextField).first, '{"version":"1"}');
    await tester.enterText(find.byType(TextField).last, 'short');

    final context = tester.element(find.byType(MiningImport));
    await tester.tap(find.text(S.of(context).g_token_m_key_9));
    await tester.pumpAndSettle();

    // The length hint remains beside the inline validation error.
    expect(find.text(S.of(context).g_mining_key_98(8)), findsNWidgets(2));
    expect(find.text(S.of(context).g_mining_key_105), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'malformed encrypted data reports an error and restores the form',
    (tester) async {
      await mount(tester);
      await tester.enterText(find.byType(TextField).first, '{malformed');
      await tester.enterText(find.byType(TextField).last, 'password');

      final context = tester.element(find.byType(MiningImport));
      await tester.tap(find.text(S.of(context).g_token_m_key_9));
      await tester.pumpAndSettle();

      expect(find.text(S.of(context).g_mining_key_107), findsOneWidget);
      expect(find.text(S.of(context).g_mining_key_113), findsNothing);
      expect(find.text(S.of(context).g_token_m_key_9), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
