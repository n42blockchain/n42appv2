import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/design_system/app_touch.dart';
import 'package:n42_wallet/core/platform/adaptive_viewport.dart';

Future<({double raw88, double target, double scaled100})> _measure(
  WidgetTester tester,
  double width,
) async {
  late double raw88;
  late double target;
  late double scaled100;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, 640)),
      child: AdaptiveScreenUtil(
        builder: (context, _) {
          raw88 = ScreenUtil().setWidth(88);
          target = AppTouch.target;
          scaled100 = AppTouch.scaled(100);
          return const SizedBox();
        },
      ),
    ),
  );
  return (raw88: raw88, target: target, scaled100: scaled100);
}

void main() {
  testWidgets('320pt-wide screens keep the 44pt minimum', (tester) async {
    final m = await _measure(tester, 320);
    expect(m.raw88, closeTo(37.5, 0.1));
    expect(m.target, 44);
    expect(m.scaled100, 44);
  });

  testWidgets('375pt and wider are unchanged', (tester) async {
    for (final width in [375.0, 430.0]) {
      final m = await _measure(tester, width);
      expect(m.target, closeTo(44, 0.1));
      expect(m.target, m.raw88);
      expect(m.scaled100, closeTo(50, 0.1));
    }
  });
}
