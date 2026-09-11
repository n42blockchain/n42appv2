import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/widgets/app_home_top_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  for (final width in [320.0, 390.0, 768.0]) {
    testWidgets('long wallet title does not overlap actions at width $width', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        wrapForTest(
          AppHomeTopBar(
            title:
                'A very long wallet account name that must not cover any actions',
            onLeftImageUri: 'assets/img/menu.png',
            actions: [
              for (var i = 0; i < 3; i++)
                IconButton(
                  key: ValueKey('action_$i'),
                  onPressed: () {},
                  icon: const Icon(Icons.link),
                ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final title = tester.getRect(find.textContaining('A very long'));
      final action = tester.getRect(find.byKey(const ValueKey('action_0')));
      expect(title.right, lessThanOrEqualTo(action.left));
      expect(tester.takeException(), isNull);
    });
  }
}
