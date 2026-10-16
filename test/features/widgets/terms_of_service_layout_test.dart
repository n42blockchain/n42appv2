import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/widgets/terms_of_service_widget.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../../helpers/browser_platform_fake.dart';
import '../../helpers/widget_test_helpers.dart';

class _Platform extends BrowserPlatformFake {
  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _WebView(params);
}

class _WebView extends PlatformWebViewWidget {
  _WebView(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

void main() {
  testWidgets('agreement label remains inside its button with large text', (
    tester,
  ) async {
    final previous = WebViewPlatform.instance;
    WebViewPlatform.instance = _Platform();
    if (previous != null) {
      addTearDown(() => WebViewPlatform.instance = previous);
    }
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 350);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      WidgetTestWrapper(
        adaptiveViewport: true,
        textScaler: TextScaler.linear(3),
        child: TermsOfServiceWidget('https://example.com/terms'),
      ),
    );
    await tester.pumpAndSettle();
    final label = tester.getRect(find.text('Agree'));
    final button = tester.getRect(find.byType(FilledButton));
    expect(button.height, greaterThan(44));
    expect(label.top, greaterThanOrEqualTo(button.top));
    expect(label.bottom, lessThanOrEqualTo(button.bottom));
    expect(button.bottom, lessThanOrEqualTo(350));
    expect(
      tester.getRect(find.byIcon(Icons.keyboard_arrow_down)).bottom,
      lessThan(button.top),
    );
    expect(tester.takeException(), isNull);
  });
}
