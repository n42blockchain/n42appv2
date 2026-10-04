import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/design_system/widgets/app_button.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/mining_output_pk.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/mining_output_tip.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  Future<void> mount(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(wrapForTest(child));
    await tester.pumpAndSettle();
  }

  testWidgets('export safety guidance continues to password setup', (
    tester,
  ) async {
    const validator = {'publicKey': 'fixture-public-key'};
    await mount(tester, const MiningOutputTip(value: validator));
    final context = tester.element(find.byType(MiningOutputTip));

    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_91), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_92), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_93), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_94), findsOneWidget);

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.byType(MiningOutputPk), findsOneWidget);
    expect(
      tester.widget<MiningOutputPk>(find.byType(MiningOutputPk)).value,
      validator,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('password length validation prevents export work', (
    tester,
  ) async {
    await mount(tester, const MiningOutputPk(value: {'publicKey': 'fixture'}));
    final context = tester.element(find.byType(MiningOutputPk));
    final fields = find.byType(TextField);

    await tester.enterText(fields.at(0), 'short');
    await tester.enterText(fields.at(1), 'short');
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.text(S.of(context).g_mining_key_98(8)), findsWidgets);
    expect(find.text(S.of(context).g_mining_key_100), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirmation mismatch stays on password form', (tester) async {
    await mount(tester, const MiningOutputPk(value: {'publicKey': 'fixture'}));
    final context = tester.element(find.byType(MiningOutputPk));
    final fields = find.byType(TextField);

    await tester.enterText(fields.at(0), 'password');
    await tester.enterText(fields.at(1), 'different');
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.text(S.of(context).g_key_passwords_not_match), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_100), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('visibility control reveals and re-obscures both fields', (
    tester,
  ) async {
    await mount(tester, const MiningOutputPk());
    final fields = find.byType(TextField);

    expect(tester.widget<TextField>(fields.at(0)).obscureText, isTrue);
    expect(tester.widget<TextField>(fields.at(1)).obscureText, isTrue);
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(fields.at(0)).obscureText, isFalse);
    expect(tester.widget<TextField>(fields.at(1)).obscureText, isFalse);
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(fields.at(0)).obscureText, isTrue);
    expect(tester.widget<TextField>(fields.at(1)).obscureText, isTrue);
    expect(tester.takeException(), isNull);
  });
}
