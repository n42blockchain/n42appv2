import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/app/navigation_wiring.dart';
import 'package:n42_wallet/shared/utils/in_app_browser.dart';

void main() {
  tearDown(InAppBrowser.reset);

  group('InAppBrowser', () {
    test('未注册时 page() 抛 StateError（提示接线缺失）', () {
      expect(() => InAppBrowser.page('https://a.b'), throwsStateError);
    });

    test('注册后 page() 返回构造器产物并透传 url', () {
      String? received;
      InAppBrowser.registerPageBuilder((url) {
        received = url;
        return const SizedBox.shrink();
      });
      final w = InAppBrowser.page('https://example.com');
      expect(w, isA<SizedBox>());
      expect(received, 'https://example.com');
    });

    test('registerHostNavigation 完成站内浏览器接线', () {
      expect(InAppBrowser.isRegistered, isFalse);
      registerHostNavigation();
      expect(InAppBrowser.isRegistered, isTrue);
    });

    testWidgets('open() 推入注册的页面路由', (tester) async {
      InAppBrowser.registerPageBuilder(
        (url) => Scaffold(body: Text('browser:$url')),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => InAppBrowser.open(context, 'https://x.y'),
              child: const Text('go'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('browser:https://x.y'), findsOneWidget);
    });
  });
}
