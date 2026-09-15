import 'dart:async';
import 'dart:ui';

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// Executes the Dart browser controller against a deterministic native boundary.
class BrowserPlatformFake extends WebViewPlatform {
  final controllers = <BrowserControllerFake>[];
  Completer<void>? channelGate;

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    final controller = BrowserControllerFake(params)..channelGate = channelGate;
    controllers.add(controller);
    return controller;
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => BrowserNavigationFake(params);
}

class BrowserControllerFake extends PlatformWebViewController {
  BrowserControllerFake(super.params) : super.implementation();
  final calls = <String>[];
  final scripts = <String>[];
  final loads = <Uri>[];
  final channels = <String, JavaScriptChannelParams>{};
  BrowserNavigationFake? navigation;
  Completer<void>? channelGate;
  Future<String?> Function() title = () async => 'Fixture title';
  Future<bool> Function() back = () async => false;
  Future<bool> Function() forward = () async => false;
  Object? scriptError;

  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async =>
      calls.add('mode:${mode.name}');
  @override
  Future<void> setBackgroundColor(Color color) async => calls.add('background');
  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate delegate,
  ) async {
    navigation = delegate as BrowserNavigationFake;
    calls.add('navigation');
  }

  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async {
    if (params.name == 'N42Wallet') await channelGate?.future;
    channels[params.name] = params;
    calls.add('channel:${params.name}');
  }

  @override
  Future<void> setUserAgent(String? userAgent) async => calls.add('userAgent');
  @override
  Future<void> setOnConsoleMessage(
    void Function(JavaScriptConsoleMessage) callback,
  ) async => calls.add('console');
  @override
  Future<void> clearLocalStorage() async => calls.add('clearLocalStorage');
  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    calls.add('load');
    loads.add(params.uri);
  }

  @override
  Future<void> runJavaScript(String script) async {
    if (scriptError != null) throw scriptError!;
    scripts.add(script);
  }

  @override
  Future<String?> getTitle() => title();
  @override
  Future<bool> canGoBack() => back();
  @override
  Future<bool> canGoForward() => forward();
  @override
  Future<String?> currentUrl() async => loads.lastOrNull?.toString();
}

class BrowserNavigationFake extends PlatformNavigationDelegate {
  BrowserNavigationFake(super.params) : super.implementation();
  PageEventCallback? started;
  PageEventCallback? finished;
  ProgressCallback? progress;
  UrlChangeCallback? urlChanged;
  WebResourceErrorCallback? resourceError;
  NavigationRequestCallback? request;
  HttpResponseErrorCallback? httpError;

  @override
  Future<void> setOnPageStarted(PageEventCallback callback) async =>
      started = callback;
  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async =>
      finished = callback;
  @override
  Future<void> setOnProgress(ProgressCallback callback) async =>
      progress = callback;
  @override
  Future<void> setOnUrlChange(UrlChangeCallback callback) async =>
      urlChanged = callback;
  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback callback) async =>
      resourceError = callback;
  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback callback,
  ) async => request = callback;
  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback callback) async =>
      httpError = callback;
}
