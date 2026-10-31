import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create/create_two.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../../helpers/widget_test_helpers.dart';

void main() {
  const channel = MethodChannel('trustdart');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'generateMnemonic');
          return 'abandon ability able about above absent absorb abstract absurd abuse access accident';
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );
  for (final scale in [1.0, 1.5, 2.0]) {
    testWidgets('new wallet mnemonic labels fit at text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        wrapForTest(
          CreateTwo(WalletInfo()),
          textScaler: TextScaler.linear(scale),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_key_wallet_c39), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      await tester.ensureVisible(find.text(S.current.g_key_wallet_c44));
      await tester.tap(find.text(S.current.g_key_wallet_c44));
      await tester.pumpAndSettle();
      final word = find.text('accident');
      await tester.ensureVisible(word);
      await tester.pumpAndSettle();
      final paragraph = tester.renderObject<RenderBox>(word);
      final painted = MatrixUtils.transformRect(
        paragraph.getTransformTo(null),
        paragraph.paintBounds,
      );
      final cell = tester.getRect(
        find.ancestor(of: word, matching: find.byType(Container)).first,
      );
      expect(painted.left, greaterThanOrEqualTo(cell.left - 0.01));
      expect(painted.right, lessThanOrEqualTo(cell.right + 0.01));
      expect(painted.top, greaterThanOrEqualTo(cell.top - 0.01));
      expect(painted.bottom, lessThanOrEqualTo(cell.bottom + 0.01));
      expect(tester.takeException(), isNull);
    });
  }
}
