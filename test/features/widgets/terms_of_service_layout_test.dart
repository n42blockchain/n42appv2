import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/widgets/terms_of_service_widget.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../../helpers/browser_platform_fake.dart';
import '../../helpers/widget_test_helpers.dart';

const _url = 'https://example.com/terms';

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

_Platform _installPlatform() {
  final previous = WebViewPlatform.instance;
  final platform = _Platform();
  WebViewPlatform.instance = platform;
  if (previous != null) {
    addTearDown(() => WebViewPlatform.instance = previous);
  }
  return platform;
}

Future<BrowserNavigationFake> _pumpTerms(
  WidgetTester tester,
  _Platform platform, {
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(
    WidgetTestWrapper(
      adaptiveViewport: true,
      textScaler: textScaler,
      child: TermsOfServiceWidget(_url, agreeCallBack: () {}),
    ),
  );
  await tester.pump();
  return platform.controllers.single.navigation!;
}

bool _agreeEnabled(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed !=
    null;

void main() {
  testWidgets('agreement label remains inside its button with large text', (
    tester,
  ) async {
    final platform = _installPlatform();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 350);
    addTearDown(tester.view.reset);
    final nav = await _pumpTerms(
      tester,
      platform,
      textScaler: TextScaler.linear(3),
    );
    nav.finished!(_url);
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

  testWidgets('agree stays disabled until the page finishes loading', (
    tester,
  ) async {
    final platform = _installPlatform();
    final nav = await _pumpTerms(tester, platform);

    expect(platform.controllers.single.loads, [Uri.parse(_url)]);
    expect(find.byKey(const ValueKey('terms_loading')), findsOneWidget);
    expect(_agreeEnabled(tester), isFalse);

    nav.finished!(_url);
    await tester.pump();

    expect(find.byKey(const ValueKey('terms_loading')), findsNothing);
    expect(_agreeEnabled(tester), isTrue);
  });

  testWidgets('main-frame error shows retry, which reloads the page', (
    tester,
  ) async {
    final platform = _installPlatform();
    final nav = await _pumpTerms(tester, platform);

    nav.resourceError!(
      const WebResourceError(
        errorCode: -1009,
        description: 'offline',
        isForMainFrame: true,
      ),
    );
    // Android still reports onPageFinished after a failure.
    nav.finished!(_url);
    await tester.pump();

    expect(find.byKey(const ValueKey('terms_failed')), findsOneWidget);
    expect(_agreeEnabled(tester), isFalse);

    await tester.tap(find.byKey(const ValueKey('terms_retry')));
    await tester.pump();

    expect(platform.controllers.single.loads, hasLength(2));
    expect(find.byKey(const ValueKey('terms_loading')), findsOneWidget);

    nav.finished!(_url);
    await tester.pump();
    expect(_agreeEnabled(tester), isTrue);
  });

  testWidgets('subresource errors do not block the terms', (tester) async {
    final platform = _installPlatform();
    final nav = await _pumpTerms(tester, platform);

    nav.resourceError!(
      const WebResourceError(
        errorCode: -1001,
        description: 'font timed out',
        isForMainFrame: false,
      ),
    );
    nav.finished!(_url);
    await tester.pump();

    expect(find.byKey(const ValueKey('terms_failed')), findsNothing);
    expect(_agreeEnabled(tester), isTrue);
  });

  testWidgets('a page that never finishes falls back to retry', (tester) async {
    final platform = _installPlatform();
    await _pumpTerms(tester, platform);

    await tester.pump(const Duration(seconds: 21));

    expect(find.byKey(const ValueKey('terms_failed')), findsOneWidget);
    expect(_agreeEnabled(tester), isFalse);
  });
}
