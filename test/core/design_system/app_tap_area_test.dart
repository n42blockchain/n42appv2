import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/platform/adaptive_viewport.dart';

Widget _wrap(double width, Widget child) => MediaQuery(
  data: MediaQueryData(size: Size(width, 640)),
  child: AdaptiveScreenUtil(
    builder: (context, _) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  ),
);

void main() {
  for (final width in [320.0, 375.0]) {
    testWidgets('small icon gets a 44pt hit area at ${width}pt', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          width,
          AppTapArea(
            onTap: () => taps++,
            tooltip: 'Close',
            child: const Icon(Icons.close, size: 16),
          ),
        ),
      );
      final area = tester.getSize(find.byType(InkWell));
      expect(area.width, greaterThanOrEqualTo(44));
      expect(area.height, greaterThanOrEqualTo(44));
      expect(tester.getSize(find.byIcon(Icons.close)), const Size(16, 16));
      // A tap near the edge of the area, outside the 16pt icon, still hits.
      final rect = tester.getRect(find.byType(InkWell));
      await tester.tapAt(rect.topLeft + const Offset(2, 2));
      expect(taps, 1);
    });
  }

  testWidgets('tooltip doubles as the screen-reader label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        375,
        AppTapArea(
          onTap: () {},
          tooltip: 'Close',
          child: const Icon(Icons.close, size: 16),
        ),
      ),
    );
    expect(
      find.semantics.byPredicate(
        (node) =>
            node.tooltip == 'Close' &&
            node.getSemanticsData().hasAction(SemanticsAction.tap),
      ),
      findsOne,
    );
    handle.dispose();
  });

  testWidgets('semanticLabel labels an icon without a tooltip', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        375,
        AppTapArea(
          onTap: () {},
          semanticLabel: 'Copy address',
          child: const Icon(Icons.copy, size: 16),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Copy address')),
      matchesSemantics(
        label: 'Copy address',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });
}
