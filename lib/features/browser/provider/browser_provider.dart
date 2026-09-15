import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/security/dapp_security_service.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import 'package:n42_wallet/features/browser/api/browser_api.dart';
import 'package:n42_wallet/features/browser/handler/dapp_request_handler.dart';
import 'package:n42_wallet/features/browser/js/ethereum_provider.dart';
import 'package:n42_wallet/features/browser/pages/browser_collection.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/shared/utils/wallet_connect_uri.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

typedef ConnectDAPP = void Function(String url);

/// 一个浏览器标签的稳定身份 + 当前 URL。
///
/// JS channel 与导航回调直接捕获它，所以「请求来自哪个页面」不依赖
/// `wvcList.indexOf(controller)`：provider 重建、标签增删、或页面在
/// controller 入列前就开始发消息（`loadRequest` 与 `wvcList.add` 之间的
/// 竞态）都不会让请求失去 origin 归属而被误拒。
class _BrowserTab {
  _BrowserTab(this.url);

  /// 该标签当前加载的 URL，由 onPageStarted / onUrlChange 持续更新。
  String url;

  /// Invalidates pending replies when the document changes, including reloads
  /// of the same URL and navigating away and back while approval is pending.
  int documentRevision = 0;
}

/// Callback to show a DApp signing/transaction confirmation sheet.
/// Returns `true` if the user approved, `false` if rejected.
/// Set by [BrowserPage]; funnels to the shared [DAppSigningSheet].
typedef DAppSigningApproval =
    Future<bool> Function({
      required String origin,
      required String method,
      required Map<String, dynamic> details,
    });

/// Callback invoked when a navigation is blocked as phishing.
///
/// [url] is the blocked URL.
/// [proceed] is a callback that the UI may invoke if the user chooses
/// "Proceed Anyway"; it whitelists the URL for this session and retries.
typedef PhishingWarning = void Function(String url, VoidCallback proceed);

class BrowserProvider extends ChangeNotifier {
  BrowserProvider() {
    getBrowserSetting();
  }

  late final BrowserApi browserApi = BrowserApi();
  Map<String, dynamic> browser = {};
  bool _isDisposed = false;

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> getBrowserSetting() async {
    final b = await SPUtil().getBrowserSetting();
    if (_isDisposed) return;
    if (b != null) {
      browser = {...browser, ...b};
      _safeNotify();
    }
  }

  List<WebViewController> wvcList = [];
  List<Map<String, dynamic>> wInfoList = [];
  int wListIndex = -1;
  bool showWList = false;

  void setShowWList(bool value) {
    showWList = value;
    _safeNotify();
  }

  TextEditingController? titleEditingController;
  FocusNode? titleFocusNode;
  ConnectDAPP? connectDAPPCallBack;

  /// Set by [BrowserPage] to show the DApp signing confirmation sheet for
  /// injected-provider (EIP-1193) requests.
  DAppSigningApproval? onSigningRequest;

  /// Lazily-built EIP-1193 request handler for the injected `window.ethereum`.
  /// Rebuilt whenever the wallet's EVM coin models change (address/chain).
  DAppRequestHandler? _dappHandler;

  /// Build/refresh the injected-provider request handler from the wallet's
  /// current EVM coin models. Returns null if no EVM account exists.
  DAppRequestHandler? _ensureDappHandler() {
    final evm = globalWapAdapter.coinModels
        .where((cm) => cm.config.coinType == CoinType.ETH.name)
        .toList();
    if (evm.isEmpty) {
      _dappHandler?.dispose();
      _dappHandler = null;
      return null;
    }
    // Wallet switches can replace every model while preserving the count.
    // Compare the actual models so a new request cannot use the old account.
    if (_dappHandler == null || !listEquals(_dappHandler!.ethCoinModels, evm)) {
      _dappHandler?.dispose();
      final handler = DAppRequestHandler(ethCoinModels: evm);
      handler.onSigningRequest =
          ({
            required String origin,
            required String method,
            required Map<String, dynamic> details,
          }) async {
            final cb = onSigningRequest;
            if (cb == null) return false;
            return cb(origin: origin, method: method, details: details);
          };
      _dappHandler = handler;
    }
    return _dappHandler;
  }

  /// Shortcut: URL of the currently active tab, or empty string
  String get _currentUrl {
    if (wListIndex < 0 || wListIndex >= wInfoList.length) return '';
    return wInfoList[wListIndex]['openUrl'] as String? ?? '';
  }

  /// Shortcut: WebViewController of the currently active tab
  WebViewController get _currentController {
    if (wListIndex < 0 || wListIndex >= wvcList.length) {
      throw StateError(
        'Invalid browser tab index: $wListIndex (tabs: ${wvcList.length})',
      );
    }
    return wvcList[wListIndex];
  }

  /// Set by [BrowserPage] to display a phishing warning dialog.
  /// Cleared in [BrowserPage.dispose] to prevent stale context usage.
  PhishingWarning? phishingCallBack;

  bool canBack = false;
  bool canForward = false;
  bool collect = false;
  int _collectionRequestId = 0;
  int _navigationStateRequestId = 0;
  int _titleRequestId = 0;

  void browserInit() {
    titleEditingController = TextEditingController();
    titleFocusNode = FocusNode();
    titleFocusNode?.addListener(_safeNotify);
  }

  void browserDispose() {
    titleEditingController?.dispose();
    titleFocusNode?.dispose();
    titleEditingController = null;
    titleFocusNode = null;
  }

  void addUrl(String url) {
    final rUrl = checkHttp(url);
    wListAdd(url: rUrl);
  }

  /// Look up the current index of [controller] in the tab list.
  /// Returns -1 if the tab has been closed.
  int _indexOfController(WebViewController controller) {
    return wvcList.indexOf(controller);
  }

  void wListAdd({String url = ""}) {
    if (url == "") {
      url = AppConfig.apiUrl['n42Browser']!;
    }
    titleEditingController?.text = url;
    late WebViewController webViewController;
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        limitsNavigationsToAppBoundDomains: false,
      );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    webViewController = WebViewController.fromPlatformCreationParams(params);

    // Capture the controller reference for use in navigation callbacks.
    // UI 状态（title/progress/openUrl）仍按 _indexOfController 动态查表，
    // 避免闭包捕获过期的 wListIndex；而 origin 归属改用下面的 tab 句柄，
    // 不受列表增删/重建影响。
    final wvc = webViewController;
    final tab = _BrowserTab(url);

    final navigationDelegate = _buildNavigationDelegate(wvc, tab);
    final channels = <String, void Function(JavaScriptMessage)>{
      'FlutterWcClipboard': (JavaScriptMessage message) {
        if (kDebugMode) {
          final preview = message.message.length > 80
              ? '${message.message.substring(0, 80)}…'
              : message.message;
          AppLogger.d('Browser', 'JS clipboard intercept: $preview');
        }
        _tryHandleWalletConnect(message.message);
      },
      // Injected EIP-1193 provider bridge: window.ethereum.request(...) →
      // N42Wallet.postMessage(json) → here → DAppRequestHandler → callback
      // into JS via window.ethereum._n42Cb(...). This is the direct
      // connect/sign/send path, complementing the WalletConnect QR flow.
      'N42Wallet': (JavaScriptMessage message) {
        _handleProviderMessage(wvc, tab, message.message);
      },
    };

    // #docregion platform_features
    if (webViewController.platform is AndroidWebViewController) {
      final androidController =
          webViewController.platform as AndroidWebViewController;
      if (kDebugMode) {
        AndroidWebViewController.enableDebugging(true);
      }
      androidController.setMediaPlaybackRequiresUserGesture(false);
      // Use compatibility mode instead of alwaysAllow to prevent MITM injection
      // of malicious HTTP resources into HTTPS DApp pages
      androidController.setMixedContentMode(MixedContentMode.compatibilityMode);
      // Enable wide viewport for better page rendering
      androidController.setUseWideViewPort(true);
    }

    wvcList.add(webViewController);
    wInfoList.add({"openUrl": url});
    showWList = false;
    wListIndex = wvcList.length - 1;

    // 配置与首次加载必须串行 await——见 _setUpAndLoad 的说明。
    unawaited(
      _setUpAndLoad(
        webViewController,
        url,
        navigationDelegate: navigationDelegate,
        channels: channels,
      ),
    );
    _safeNotify();
  }

  /// 按顺序完成 WebView 配置，**全部就绪后**才发起首次加载。
  ///
  /// 这一步必须串行 await，不能用 `..` 级联：iOS(WKWebView) 的
  /// `addJavaScriptChannel` 是靠注入一段 `atDocumentStart` 的 `WKUserScript`
  /// （`window.X = webkit.messageHandlers.X;`）来暴露 channel 的，内部需要
  /// 多次平台往返（getUserContentController → addUserScript +
  /// addScriptMessageHandler），而 `loadRequest` 只需一次。级联不等待时
  /// loadRequest 会抢跑，页面加载时 user script 尚未注册，`window.N42Wallet`
  /// 就是 undefined——注入的 provider 调 `N42Wallet.postMessage` 直接抛异常，
  /// DApp 只看到 "-32603 Native bridge unavailable"，请求根本进不了 Dart。
  /// （`window.ethereum` 却仍在，因为它走 runJavaScript，不受 document-start
  /// 时机限制——这正是该故障看起来像"路由问题"的原因。）
  Future<void> _setUpAndLoad(
    WebViewController wvc,
    String url, {
    required NavigationDelegate navigationDelegate,
    required Map<String, void Function(JavaScriptMessage)> channels,
  }) async {
    try {
      await wvc.setJavaScriptMode(JavaScriptMode.unrestricted);
      await wvc.setBackgroundColor(const Color(0x00000000));
      await wvc.setNavigationDelegate(navigationDelegate);
      for (final entry in channels.entries) {
        await wvc.addJavaScriptChannel(
          entry.key,
          onMessageReceived: entry.value,
        );
      }
      // Use a desktop user agent so DApps (e.g. Uniswap/@reown/appkit) present
      // the QR-code flow instead of the mobile deep-link flow, which fails
      // inside a WebView because wc:// cannot be handled by an external wallet.
      await wvc.setUserAgent(
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) '
        'Version/17.0 Safari/605.1.15',
      );
      await wvc.setOnConsoleMessage((JavaScriptConsoleMessage msg) {
        AppLogger.d('DApp', '[${msg.level.name}] ${msg.message}');
      });
      // Clear localStorage via the native WebKit data store BEFORE loading the
      // page so stale WalletConnect sessions (which may carry invalid "null"
      // addresses from a previous pairing) are gone before any page JS runs.
      await wvc.clearLocalStorage();
    } catch (e) {
      AppLogger.e('Browser', 'WebView setup failed: $e');
    }
    await wvc.loadRequest(Uri.parse(url));
  }

  /// 该标签的导航回调。UI 状态按 `_indexOfController` 动态查表（避免闭包
  /// 捕获过期的 wListIndex），origin 归属则写入 [tab] 句柄。
  NavigationDelegate _buildNavigationDelegate(
    WebViewController wvc,
    _BrowserTab tab,
  ) {
    return NavigationDelegate(
      onProgress: (int progress) {
        final idx = _indexOfController(wvc);
        if (idx < 0) return;
        wInfoList[idx]['progress'] = progress * 0.01;
        _safeNotify();
      },
      onPageStarted: (String url) {
        AppLogger.d('Browser', 'page started loading: $url');
        // origin 归属先于一切更新，且不依赖标签是否已入列。
        tab.documentRevision++;
        tab.url = url;
        // 注入按 controller 进行，不需要列表索引——此前 idx<0 时会整个
        // 跳过注入，页面就彻底拿不到 window.ethereum。
        _injectWcClipboardScript(wvc);
        // Inject the EIP-1193 provider as early as possible so DApps that
        // probe window.ethereum at document-start find it.
        _injectEthereumProvider(wvc, url);
        final idx = _indexOfController(wvc);
        if (idx < 0) return;
        wInfoList[idx]['load'] = true;
        _safeNotify();
      },
      onPageFinished: (String url) async {
        tab.url = url;
        // Inject again after full load in case onPageStarted fired too early.
        await _injectWcClipboardScript(wvc);
        await _injectEthereumProvider(wvc, url);
        final idx = _indexOfController(wvc);
        if (idx < 0) return;
        wInfoList[idx]['load'] = false;
        wInfoList[idx]['progress'] = 0;
        // Fetch title for this tab
        final t = await wvc.getTitle();
        if (t != null) {
          final idx2 = _indexOfController(wvc);
          if (idx2 >= 0) wInfoList[idx2]['title'] = t;
        }
        final idx3 = _indexOfController(wvc);
        if (idx3 < 0) return;
        final pageTitle = wInfoList[idx3]['title'] as String?;
        browserApi.insertBrowserHistory(url, title: pageTitle);
        // Only update navigation state if this is the active tab
        if (idx3 == wListIndex) {
          checkCanGo();
          getCollectionUrl(url);
        }
        _safeNotify();
      },
      onWebResourceError: (WebResourceError error) {
        final idx = _indexOfController(wvc);
        if (idx < 0) return;
        wInfoList[idx]['load'] = false;
        wInfoList[idx]['progress'] = 0;
        _safeNotify();
      },
      onNavigationRequest: (NavigationRequest request) {
        return checkUrl(request.url)
            ? NavigationDecision.navigate
            : NavigationDecision.prevent;
      },
      onUrlChange: (UrlChange change) {
        // Same-origin SPA history updates keep the same document. Full loads
        // are invalidated by onPageStarted, including same-URL reloads.
        if (change.url != null &&
            _originOf(change.url!) != _originOf(tab.url)) {
          tab.documentRevision++;
        }
        tab.url = change.url ?? tab.url;
        final idx = _indexOfController(wvc);
        if (idx < 0) return;
        wInfoList[idx]['openUrl'] = change.url ?? "";
        // Only update URL bar if this is the active tab
        if (idx == wListIndex) {
          titleEditingController?.text = wInfoList[idx]['openUrl'];
        }
        _safeNotify();
      },
      onHttpError: (HttpResponseError error) {
        AppLogger.w('Browser', 'HTTP error: ${error.response?.statusCode}');
      },
    );
  }

  void loadRequest({String url = ""}) {
    if (url == "") url = titleEditingController?.text ?? "";
    if (url == "") return;
    url = checkHttp(url);
    _currentController.loadRequest(Uri.parse(url));
    wInfoList[wListIndex]['openUrl'] = url;
  }

  void wListShow(int index) {
    wListIndex = index;
    showWList = false;
    titleEditingController?.text = _currentUrl;
    // Notify immediately so the UI switches tab right away
    _safeNotify();
    // Then async-update navigation and bookmark state
    checkCanGo();
    getCollectionUrl(_currentUrl);
  }

  void wListDelete(int index) {
    // Clear WebViewController navigation delegate before removal
    wvcList[index].setNavigationDelegate(NavigationDelegate());
    wvcList.removeAt(index);
    wInfoList.removeAt(index);
    if (wvcList.isEmpty) {
      wListAdd();
      return;
    }
    if (index < wListIndex) {
      wListIndex--;
    } else if (index == wListIndex && wListIndex >= wvcList.length) {
      wListIndex = wvcList.length - 1;
    }
    // Sync URL bar and navigation state with the new current tab
    if (wListIndex >= 0 && wListIndex < wInfoList.length) {
      titleEditingController?.text = _currentUrl;
      checkCanGo();
      getCollectionUrl(_currentUrl);
    }
    _safeNotify();
  }

  /// Check whether the given URL is in the bookmarks collection.
  Future<void> getCollectionUrl(String url) async {
    final requestId = ++_collectionRequestId;
    final list = await browserApi.selectBrowserCollectionUrl(url);
    if (_isDisposed) return;
    if (requestId != _collectionRequestId) return;
    if (url != _currentUrl) return;
    collect = list.isNotEmpty;
    _safeNotify();
  }

  Future<void> getTitle() async {
    final index = wListIndex;
    if (index < 0 || index >= wvcList.length || index >= wInfoList.length) {
      return;
    }
    final controller = wvcList[index];
    final requestId = ++_titleRequestId;
    final t = await controller.getTitle();
    if (_isDisposed) return;
    if (requestId != _titleRequestId) return;
    if (index != wListIndex || index >= wInfoList.length) return;
    if (!identical(controller, wvcList[index])) return;
    if (t != null) {
      wInfoList[index]['title'] = t;
      _safeNotify();
    }
  }

  Future<void> checkCanGo() async {
    final index = wListIndex;
    if (index < 0 || index >= wvcList.length) return;
    final controller = wvcList[index];
    final requestId = ++_navigationStateRequestId;
    final canGoBack = await controller.canGoBack();
    final canGoForward = await controller.canGoForward();
    if (_isDisposed) return;
    if (requestId != _navigationStateRequestId) return;
    if (index != wListIndex || index >= wvcList.length) return;
    if (!identical(controller, wvcList[index])) return;
    canBack = canGoBack;
    canForward = canGoForward;
    _safeNotify();
  }

  /// Last WC URI dispatched to [connectDAPPCallBack].  Used to deduplicate
  /// rapid-fire events from both the JS channel and the clipboard poller.
  /// Reset by [BrowserPage] when the WalletConnect sheet closes so that
  /// the same URI can be reused on a retry attempt.
  String? lastDispatchedWcUri;

  /// Try to handle a WalletConnect URI; returns true if handled.
  bool _tryHandleWalletConnect(String wcUri) {
    final normalizedWcUri = normalizeWalletConnectUriString(wcUri);
    if (normalizedWcUri == null) return false;
    // Deduplicate: the JS channel may fire multiple times for the same URI
    // (copy event + clipboard.writeText both firing).
    if (normalizedWcUri == lastDispatchedWcUri) return true;
    if (connectDAPPCallBack == null) return false;
    lastDispatchedWcUri = normalizedWcUri;
    connectDAPPCallBack!(normalizedWcUri);
    return true;
  }

  /// JavaScript injected into every page to intercept clipboard writes.
  /// The FlutterWcClipboard channel is registered on each WebViewController
  /// via [addJavaScriptChannels] so it is always available on window.
  static const _wcClipboardInterceptScript = r'''
(function() {
  // ── Clear stale WalletConnect localStorage ───────────────────────────────
  // A previous session may have stored an invalid ("null") address. Purge all
  // WalletConnect / @reown/appkit keys so the DApp starts a fresh pairing.
  if (!window.__flutterWcStorageCleared) {
    window.__flutterWcStorageCleared = true;
    try {
      var toRemove = [];
      for (var i = 0; i < localStorage.length; i++) {
        var k = localStorage.key(i);
        if (k && (
          k.indexOf('wc@') === 0 ||
          k.indexOf('@walletconnect') === 0 ||
          k.indexOf('W3M') !== -1 ||
          k.indexOf('@w3m') !== -1 ||
          k.indexOf(':core:') !== -1 ||
          k.indexOf('walletconnect') !== -1
        )) {
          toRemove.push(k);
        }
      }
      for (var j = 0; j < toRemove.length; j++) {
        try { localStorage.removeItem(toRemove[j]); } catch(e2) {}
      }
    } catch(e) {}
  }

  // ── iOS WebView masking ──────────────────────────────────────────────────
  // @reown/appkit and similar DApp SDKs check window.webkit.messageHandlers
  // to detect a mobile WebView, then fall back to deep-link mode (wc://) which
  // fails inside a WebView. We hide webkit ONCE per page load so DApps treat
  // this as a standard desktop browser and show the QR-code flow instead.
  // 隐藏 webkit 之前，必须把每个 channel 固定成一个独立的包装对象。
  //
  // ⚠️ 关键陷阱：iOS 上 window.X 是 atDocumentStart 的 WKUserScript 注入的
  // 别名，`window.X === webkit.messageHandlers.X`——**同一个对象**。因此绝不
  // 能写成 window.X.postMessage = function(m){ handler.postMessage(m); }：
  // 那等于把该对象自己的 postMessage 换成一个调用自身的函数，形成无限递归、
  // 栈溢出，调用方只会看到 "Native bridge unavailable"，请求根本到不了 Dart。
  // 正确做法是先取出原生 postMessage「函数本身」，再挂到一个新对象上，并以
  // 原 handler 作为 receiver 调用。
  if (!window.__flutterWebkitHidden) {
    window.__flutterWebkitHidden = true;
    try {
      if (window.webkit && window.webkit.messageHandlers) {
        var _mh = window.webkit.messageHandlers;
        var _pin = function(name) {
          var handler = _mh[name];
          if (!handler || typeof handler.postMessage !== 'function') return false;
          var rawPost = handler.postMessage;
          window[name] = {
            postMessage: function(msg) {
              // 传字符串,与 Android 及未隐藏 webkit 时的别名行为保持一致。
              // 传数组会让 Dart 侧 message.body.toString() 得到 "[...]",
              // JSON 解析失败(provider)或 wc: 前缀判断失败(剪贴板)。
              rawPost.call(handler, String(msg));
            }
          };
          return true;
        };
        _pin('FlutterWcClipboard');
        // provider 桥同样要固定,否则隐藏 webkit 后 connect/sign/send 全废。
        // 注意这一步也顺带兜住了「别名 user script 尚未注册」的情况——直接
        // 从 messageHandlers 取 handler 建立 window.N42Wallet。
        var _n42Pinned = _pin('N42Wallet');
        // 隐藏 webkit 只为让 DApp 走 QR 流程(而非在 WebView 里必然失败的
        // wc:// deep-link)。若 provider 桥没能固定住,隐藏 webkit 会连
        // messageHandlers 兜底一起断掉,钱包彻底不可用——那就宁可不隐藏。
        if (_n42Pinned) {
          Object.defineProperty(window, 'webkit', { get: function() { return undefined; }, configurable: true });
        }
      }
    } catch(e) {}
    // Report as a non-touch desktop device (prevents touch-based mobile detection)
    try {
      Object.defineProperty(navigator, 'maxTouchPoints', { get: function() { return 0; }, configurable: true });
    } catch(e) {}
  }

  if (window.__flutterWcInterceptorInstalled) return;
  window.__flutterWcInterceptorInstalled = true;

  function _send(text) {
    try { FlutterWcClipboard.postMessage(String(text)); } catch(e) {}
  }

  // 1. Intercept navigator.clipboard.writeText (async Clipboard API)
  if (navigator.clipboard && navigator.clipboard.writeText) {
    var _orig = navigator.clipboard.writeText.bind(navigator.clipboard);
    navigator.clipboard.writeText = function(text) {
      _send(text);
      return _orig(text);
    };
  }

  // 2. Intercept document.execCommand('copy') (legacy sync copy)
  var _origExec = document.execCommand.bind(document);
  document.execCommand = function(cmd) {
    var result = _origExec.apply(document, arguments);
    if (String(cmd).toLowerCase() === 'copy' && result) {
      try {
        var sel = window.getSelection ? window.getSelection().toString() : '';
        if (sel) _send(sel);
      } catch(e) {}
    }
    return result;
  };

  // 3. Listen for the native copy event as a final fallback
  document.addEventListener('copy', function(e) {
    try {
      var text = window.getSelection ? window.getSelection().toString() : '';
      if (text) _send(text);
    } catch(e) {}
  }, true);
})();
''';

  /// Inject the clipboard-intercept script into [wvc].
  Future<void> _injectWcClipboardScript(WebViewController wvc) async {
    try {
      await wvc.runJavaScript(_wcClipboardInterceptScript);
    } catch (e) {
      AppLogger.w('Browser', 'WC clipboard script inject error: $e');
    }
  }

  /// Connection approval exposes only the account shown in the prompt.
  final Map<String, Set<String>> _connectedAccounts = {};

  bool _isAccountConnected(String origin, String address) =>
      _connectedAccounts[origin]?.contains(address.toLowerCase()) ?? false;

  /// Inject the EIP-1193 `window.ethereum` provider into [wvc]. The address
  /// is only seeded for origins the user has connected; other pages get an
  /// empty account list. No-op when there is no EVM account.
  Future<void> _injectEthereumProvider(
    WebViewController wvc,
    String url,
  ) async {
    final handler = _ensureDappHandler();
    if (handler == null) return;
    try {
      final connected = _isAccountConnected(_originOf(url), handler.address);
      final script = EthereumProviderJs.buildProviderScript(
        handler.chainIdHex,
        connected ? [handler.address] : const [],
      );
      await wvc.runJavaScript(script);
    } catch (e) {
      AppLogger.w('Browser', 'ethereum provider inject error: $e');
    }
  }

  /// Handle one `N42Wallet.postMessage(json)` from the injected provider:
  /// route to [DAppRequestHandler] and resolve/reject the JS Promise via
  /// `window.ethereum._n42Cb(id, resultJson, errorJson)`.
  Future<void> _handleProviderMessage(
    WebViewController wvc,
    _BrowserTab tab,
    String raw,
  ) async {
    int? id;
    final revision = tab.documentRevision;
    bool isCurrentDocument() =>
        !_isDisposed &&
        _indexOfController(wvc) >= 0 &&
        tab.documentRevision == revision;
    if (!isCurrentDocument()) return;
    try {
      final msg = json.decode(raw) as Map<String, dynamic>;
      id = msg['id'] as int?;
      final method = msg['method'] as String? ?? '';
      final params = (msg['params'] as List<dynamic>?) ?? const [];
      if (id == null) return;

      final handler = _ensureDappHandler();
      if (handler == null) {
        AppLogger.w('Browser', 'provider request $method: no EVM account');
        await _rejectProvider(wvc, id, -32603, 'No EVM account available');
        return;
      }
      final requestAddress = handler.address;
      final requestChain = handler.chainIdHex;
      final requestWalletIndex = globalWapAdapter.walletIndex;
      bool isCurrentWallet() =>
          globalWapAdapter.walletIndex == requestWalletIndex &&
          identical(_ensureDappHandler(), handler) &&
          handler.address == requestAddress &&
          handler.chainIdHex == requestChain;

      // Origin/安全检查基于发起请求的标签，而不是当前活跃标签——后台标签的
      // JS 仍在运行，否则恶意后台页可借前台可信页的 origin 弹签名框、并绕过
      // 对自身 origin 的钓鱼拦截。归属取自标签句柄（不是 wvcList 查表），
      // 因此标签增删/provider 重建都不会让请求失去归属。
      final requestUrl = tab.url;
      final origin = _originOf(requestUrl);
      if (_isSensitiveMethod(method)) {
        final sec = DAppSecurityService.check(requestUrl);
        if (sec.level == DAppSecurityLevel.blocked) {
          await _rejectProvider(
            wvc,
            id,
            4001,
            'Blocked: ${sec.reason ?? 'known phishing site'}',
          );
          return;
        }
      }

      // 账户暴露走按 origin 的连接授权（MetaMask 语义）：未经用户批准的
      // 站点拿不到地址，eth_requestAccounts 首次调用弹连接确认。
      switch (method) {
        case 'eth_accounts':
          await _resolveProvider(
            wvc,
            id,
            _isAccountConnected(origin, handler.address)
                ? [handler.address]
                : const [],
          );
          return;
        case 'eth_coinbase':
          await _resolveProvider(
            wvc,
            id,
            _isAccountConnected(origin, handler.address)
                ? handler.address
                : null,
          );
          return;
        case 'eth_requestAccounts':
          if (!_isAccountConnected(origin, handler.address)) {
            final cb = onSigningRequest;
            if (cb == null) {
              // 回调未接线时若静默拒绝，DApp 只会看到"连接失败"而用户什么
              // 都没看到——留痕以便定位。
              AppLogger.e(
                'Browser',
                'eth_requestAccounts from $origin but no approval UI wired',
              );
              await _rejectProvider(wvc, id, 4001, 'User rejected');
              return;
            }
            AppLogger.i('Browser', 'connect request from $origin');
            final approved = await cb(
              origin: origin,
              method: 'eth_requestAccounts',
              details: {
                'address': handler.address,
                'chainId': handler.chainIdHex,
              },
            );
            if (!isCurrentDocument()) return;
            if (!isCurrentWallet()) {
              await _rejectProvider(
                wvc,
                id,
                4001,
                'Wallet changed; retry the request',
              );
              return;
            }
            if (!approved) {
              AppLogger.i('Browser', 'connect rejected for $origin');
              await _rejectProvider(wvc, id, 4001, 'User rejected');
              return;
            }
            (_connectedAccounts[origin] ??= {}).add(
              requestAddress.toLowerCase(),
            );
            AppLogger.i('Browser', 'connect approved for $origin');
          }
          // Push the now-exposed account into the page's provider so
          // selectedAddress/eth_accounts fast-paths see it too.
          try {
            await wvc.runJavaScript(
              'window.ethereum && window.ethereum._n42SetAccounts('
              '${json.encode([handler.address])})',
            );
          } catch (_) {}
          if (!isCurrentDocument()) return;
          await _resolveProvider(wvc, id, [handler.address]);
          return;
      }

      final result = await handler.handleRequest(
        method,
        params,
        origin: origin,
        isRequestActive: () => isCurrentDocument() && isCurrentWallet(),
      );
      if (!isCurrentDocument()) return;
      await _resolveProvider(wvc, id, result);
    } catch (e) {
      if (id == null || !isCurrentDocument()) return;
      // Normalize thrown JSON-RPC error maps and generic errors.
      int code = -32603;
      String message = e.toString();
      if (e is Map) {
        code = (e['code'] as int?) ?? code;
        message = e['message']?.toString() ?? message;
      }
      await _rejectProvider(wvc, id, code, message);
    }
  }

  static const Set<String> _sensitiveMethods = {
    'eth_sendTransaction',
    'eth_signTransaction',
    'personal_sign',
    'eth_sign',
    'eth_signTypedData',
    'eth_signTypedData_v3',
    'eth_signTypedData_v4',
  };

  bool _isSensitiveMethod(String method) => _sensitiveMethods.contains(method);

  String _originOf(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return url.isEmpty ? 'DApp' : url;
    if (uri.scheme == 'http' || uri.scheme == 'https') return uri.origin;
    return '${uri.scheme}://${uri.host}';
  }

  Future<void> _resolveProvider(
    WebViewController wvc,
    int id,
    dynamic result,
  ) async {
    final resultJson = json.encode(result);
    try {
      await wvc.runJavaScript(
        'window.ethereum && window.ethereum._n42Cb('
        '$id, ${json.encode(resultJson)}, null)',
      );
    } catch (e) {
      AppLogger.w('Browser', 'provider resolve error: $e');
    }
  }

  Future<void> _rejectProvider(
    WebViewController wvc,
    int id,
    int code,
    String message,
  ) async {
    final errJson = json.encode({'code': code, 'message': message});
    try {
      await wvc.runJavaScript(
        'window.ethereum && window.ethereum._n42Cb('
        '$id, null, ${json.encode(errJson)})',
      );
    } catch (e) {
      AppLogger.w('Browser', 'provider reject error: $e');
    }
  }

  bool checkUrl(String url) {
    if (_tryHandleWalletConnect(url)) {
      return false;
    }

    final uri = Uri.parse(url);
    // 拦截危险 URL 协议：javascript: 可用于 XSS；data: / blob: 可绕过 CSP；file: 可读本地文件
    const blockedSchemes = {'javascript', 'data', 'blob', 'file'};
    if (blockedSchemes.contains(uri.scheme)) return false;

    if (uri.scheme == "wc") {
      if (_tryHandleWalletConnect(url)) return false;
    } else if (uri.scheme == "amazeapp" && uri.path == "/wc") {
      final param = uri.queryParameters['uri'] ?? "";
      if (_tryHandleWalletConnect(param)) return false;
    }

    // ── Phishing detection (http / https only) ────────────────────────────
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      final result = PhishingDetector.instance.checkUrl(url);
      if (result == PhishingCheckResult.phishing) {
        phishingCallBack?.call(url, () {
          PhishingDetector.instance.allowForSession(url);
          final idx = wListIndex;
          if (idx >= 0 && idx < wvcList.length) {
            wvcList[idx].loadRequest(Uri.parse(url));
          }
        });
        return false;
      }
    }

    return true;
  }

  String checkHttp(String url) {
    if (!isURL(url)) {
      return "https://www.google.com/search?q=${Uri.encodeQueryComponent(url)}";
    }
    final hasScheme = url.startsWith("https://") || url.startsWith("http://");
    return hasScheme ? url : 'https://$url';
  }

  Future<void> deleteBrowserCollectionUrl() async {
    final url = _currentUrl;
    await browserApi.deleteBrowserCollectionUrl(url);
    getCollectionUrl(url);
  }

  Future<void> addBrowserCollection(BuildContext context) async {
    final currentUrl = await _currentController.currentUrl();
    final title = await _currentController.getTitle();
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrowserCollection(title ?? "", currentUrl ?? ""),
      ),
    );
    if (!context.mounted) return;
    getCollectionUrl(_currentUrl);
  }

  void cleanWList() {
    // Clear all navigation delegates before disposal
    for (final wvc in wvcList) {
      wvc.setNavigationDelegate(NavigationDelegate());
    }
    showWList = false;
    wvcList = [];
    wInfoList = [];
    wListIndex = -1;
    wListAdd();
  }

  @override
  void dispose() {
    _isDisposed = true;
    browserDispose();
    for (final wvc in wvcList) {
      wvc.setNavigationDelegate(NavigationDelegate());
    }
    wvcList = [];
    wInfoList = [];
    super.dispose();
  }
}
