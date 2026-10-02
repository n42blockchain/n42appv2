import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/api/browser_api.dart';
import 'package:n42_wallet/features/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/browser/presentation/providers/browser_providers.dart';
import 'package:n42_wallet/features/browser/provider/browser_provider.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../../helpers/browser_platform_fake.dart';
import '../../helpers/widget_test_helpers.dart';

class _Wallet extends Fake implements LegacyWalletActionProviderAdapter {
  @override
  List<CoinModel> coinModels = [];
  @override
  int walletIndex = 0;
}

class _BrowserApi extends Fake implements BrowserApi {
  final deleted = <String>[];

  @override
  Future<List<BrowserCollectionModel>> selectBrowserCollectionUrl(
    String url,
  ) async => [];

  @override
  Future<int> insertBrowserHistory(String url, {String? title}) async => 1;

  @override
  Future<int> deleteBrowserCollectionUrl(String url) async {
    deleted.add(url);
    return 1;
  }
}

class _Browser extends BrowserProvider {
  final api = _BrowserApi();

  @override
  BrowserApi get browserApi => api;
}

class _WalletConnect extends WalletConnectProvider {
  @override
  Future<void> connectInit() async {}
}

class _BrowserPagePlatformFake extends BrowserPlatformFake {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    final controller = _BrowserPageControllerFake(params)
      ..channelGate = channelGate;
    controllers.add(controller);
    return controller;
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _BrowserPageWidgetFake(params);
}

class _BrowserPageControllerFake extends BrowserControllerFake {
  _BrowserPageControllerFake(super.params);

  @override
  Future<void> reload() async => calls.add('reload');

  @override
  Future<void> goBack() async => calls.add('goBack');

  @override
  Future<void> goForward() async => calls.add('goForward');
}

class _BrowserPageWidgetFake extends PlatformWebViewWidget {
  _BrowserPageWidgetFake(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const ColoredBox(color: Colors.white);
}

Finder _asset(String assetName) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == 'assets/browser/$assetName',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Browser browser;
  late _WalletConnect walletConnect;
  late BrowserPlatformFake platform;
  WebViewPlatform? previousPlatform;
  const toast = MethodChannel('PonnamKarthik/fluttertoast');

  setUpAll(() => globalWapAdapter = _Wallet());

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    previousPlatform = WebViewPlatform.instance;
    platform = _BrowserPagePlatformFake();
    WebViewPlatform.instance = platform;
    browser = _Browser();
    walletConnect = _WalletConnect();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toast, (_) async => true);
  });

  tearDown(() {
    WebViewPlatform.instance = previousPlatform ?? BrowserPlatformFake();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toast, null);
  });

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      wrapForTest(
        const BrowserPage('https://first.example.test'),
        overrides: [
          browserNotifierProvider.overrideWith((ref) => browser),
          wcpBridgeProvider.overrideWith((ref) => walletConnect),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('address bar submits a normalized URL and loading progress', (
    tester,
  ) async {
    await open(tester);
    expect(browser.wvcList, hasLength(1));
    expect(find.byType(WebViewWidget), findsOneWidget);
    expect(browser.titleEditingController!.text, 'https://first.example.test');

    final controller = platform.controllers.single;
    controller.navigation!.started!('https://first.example.test');
    controller.navigation!.progress!(45);
    await tester.pump();
    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, .45);

    await tester.enterText(find.byType(TextField).first, 'example.org/path');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(controller.loads.last.toString(), 'https://example.org/path');
    expect(browser.wInfoList.single['openUrl'], 'https://example.org/path');

    controller.back = () async => true;
    controller.forward = () async => true;
    browser
      ..canBack = true
      ..canForward = true
      ..notifyListeners();
    await tester.pump();
    await tester.tap(_asset('refresh.png'));
    await tester.pump();
    await tester.tap(_asset('arrow-left.png'));
    await tester.pump();
    await tester.tap(_asset('arrow-right.png'));
    await tester.pump();
    expect(controller.calls, containsAll(['reload', 'goBack', 'goForward']));

    await tester.tap(_asset('setting.png'));
    await tester.pumpAndSettle();
    expect(find.byType(Switch), findsOneWidget);
    await tester.tap(find.byIcon(Icons.cleaning_services_sharp));
    await tester.pump();
    expect(controller.calls, contains('clearLocalStorage'));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('tab count opens previews and Done returns to the selected tab', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(Dismissible), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byType(WebViewWidget), findsOneWidget);
    expect(browser.showWList, isFalse);
    expect(browser.wListIndex, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tab toolbar adds a tab and Close all keeps one fresh tab', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(_asset('add.png').first);
    await tester.pumpAndSettle();
    expect(browser.wvcList, hasLength(2));
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    expect(find.byType(Dismissible), findsNWidgets(2));

    final addImages = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == 'assets/browser/add.png',
    );
    expect(addImages, findsNWidgets(2));
    await tester.tap(addImages.last);
    await tester.pumpAndSettle();
    expect(browser.wvcList, hasLength(3));
    expect(browser.wInfoList, hasLength(3));
    expect(browser.showWList, isFalse);
    expect(browser.wListIndex, 2);

    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close all'));
    await tester.pumpAndSettle();
    expect(browser.wvcList, hasLength(1));
    expect(browser.wInfoList, hasLength(1));
    expect(browser.wListIndex, 0);
    expect(browser.showWList, isFalse);
    expect(find.byType(WebViewWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bookmark toolbar opens the form and removes a saved URL', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(_asset('star_border.png'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
    expect(
      (tester.widget<TextField>(find.byType(TextField).at(1)).controller!).text,
      'https://first.example.test',
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    browser
      ..collect = true
      ..notifyListeners();
    await tester.pump();
    await tester.tap(_asset('star.png'));
    await tester.pumpAndSettle();
    expect(browser.api.deleted, ['https://first.example.test']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('connected WalletConnect session shows its toolbar action', (
    tester,
  ) async {
    walletConnect.walletConnectState = WalletConnectState.connect;
    await open(tester);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/wallet/WalletConnect.png',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
