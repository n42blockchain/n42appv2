import 'dart:ui' show Size;

import 'package:flutter/material.dart'
    show
        AssetImage,
        Dismissible,
        Image,
        InkWell,
        LinearProgressIndicator,
        TextField,
        TextInputAction;
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/api/browser_api.dart';
import 'package:n42_wallet/features/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/browser/presentation/providers/browser_providers.dart';
import 'package:n42_wallet/features/browser/provider/browser_provider.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../../helpers/browser_platform_fake.dart';
import '../../helpers/widget_test_helpers.dart';

class _Wallet extends Fake implements LegacyWalletActionProviderAdapter {
  @override
  List<CoinModel> coinModels = [];
  @override
  int walletIndex = 0;
}

class _BrowserProvider extends BrowserProvider {
  final api = _Bookmarks();

  @override
  BrowserApi get browserApi => api;
}

class _Bookmarks extends Fake implements BrowserApi {
  @override
  Future<List<BrowserCollectionModel>> selectBrowserCollectionUrl(
    String url,
  ) async => [];
}

class _WalletConnectProvider extends WalletConnectProvider {
  @override
  Future<void> connectInit() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const firstUrl = 'https://first.example.test';
  const secondUrl = 'https://second.example.test';
  final wallet = _Wallet();
  late _BrowserProvider browser;
  late _WalletConnectProvider walletConnect;
  late BrowserPlatformFake platform;
  WebViewPlatform? previousPlatform;

  setUpAll(() => globalWapAdapter = wallet);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    previousPlatform = WebViewPlatform.instance;
    platform = BrowserPlatformFake();
    WebViewPlatform.instance = platform;
    browser = _BrowserProvider();
    walletConnect = _WalletConnectProvider();
  });
  tearDown(() {
    WebViewPlatform.instance = previousPlatform ?? BrowserPlatformFake();
  });

  Future<void> pumpBrowser(WidgetTester tester) async {
    tester.view.physicalSize =
        const Size(390, 844) * tester.view.devicePixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      wrapForTest(
        BrowserPage(firstUrl),
        overrides: [
          browserNotifierProvider.overrideWith((ref) => browser),
          wcpBridgeProvider.overrideWith((ref) => walletConnect),
        ],
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Finder toolbarAssetButton(String name) {
    final image = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == 'assets/browser/$name.png',
    );
    return find.ancestor(of: image, matching: find.byType(InkWell)).first;
  }

  testWidgets(
    'tab counter opens the tab grid and selecting a card restores it',
    (tester) async {
      await pumpBrowser(tester);
      expect(browser.wInfoList, hasLength(1));
      expect(browser.wInfoList.single['openUrl'], firstUrl);

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      expect(browser.showWList, isTrue);
      expect(find.text(firstUrl), findsAtLeastNWidgets(1));

      browser.wListAdd(url: secondUrl);
      browser.setShowWList(true);
      await tester.pumpAndSettle();
      expect(browser.wInfoList, hasLength(2));
      expect(find.text(secondUrl), findsAtLeastNWidgets(1));

      await tester.tap(find.byType(Dismissible).first);
      await tester.pumpAndSettle();
      expect(browser.showWList, isFalse);
      expect(browser.wListIndex, 0);
      expect(browser.titleEditingController?.text, firstUrl);
    },
  );

  testWidgets('tab toolbar can close every tab and start a blank tab', (
    tester,
  ) async {
    await pumpBrowser(tester);
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close all'));
    await tester.pumpAndSettle();

    expect(browser.wvcList, hasLength(1));
    expect(browser.wInfoList.single['openUrl'], 'https://www.n42.ai');
    expect(browser.showWList, isFalse);
  });

  testWidgets(
    'address submission normalizes a domain and loads it in the tab',
    (tester) async {
      await pumpBrowser(tester);
      final controller = platform.controllers.single;

      await tester.enterText(find.byType(TextField).first, 'example.org');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();

      expect(controller.loads.map((uri) => uri.toString()), [
        firstUrl,
        'https://example.org',
      ]);
      expect(browser.wInfoList.single['openUrl'], 'https://example.org');
    },
  );

  testWidgets('refresh, back and forward controls act on the active WebView', (
    tester,
  ) async {
    await pumpBrowser(tester);
    final controller = platform.controllers.single;
    controller.back = () async => true;
    controller.forward = () async => true;
    browser
      ..canBack = true
      ..canForward = true
      ..notifyListeners();
    await tester.pump();

    await tester.tap(toolbarAssetButton('refresh'));
    await tester.pumpAndSettle();
    await tester.tap(toolbarAssetButton('arrow-left'));
    await tester.pumpAndSettle();
    await tester.tap(toolbarAssetButton('arrow-right'));
    await tester.pumpAndSettle();

    expect(controller.calls.where((call) => call == 'reload'), hasLength(1));
    expect(controller.calls.where((call) => call == 'back'), hasLength(1));
    expect(controller.calls.where((call) => call == 'forward'), hasLength(1));
  });

  testWidgets('loading progress is visible then clears on a resource error', (
    tester,
  ) async {
    await pumpBrowser(tester);
    final navigation = platform.controllers.single.navigation!;

    navigation.started!(firstUrl);
    navigation.progress!(42);
    await tester.pump();

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, 0.42);

    navigation.resourceError!(
      const WebResourceError(errorCode: -1, description: 'offline'),
    );
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
