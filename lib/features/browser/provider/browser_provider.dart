import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import 'package:n42_wallet/features/browser/api/browser_api.dart';
import 'package:n42_wallet/features/browser/pages/browser_collection.dart';
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
      url = AppConfig.apiUrl['walletamazeBrowser']!;
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
    // All callbacks look up their tab index dynamically via _indexOfController
    // to avoid stale closure captures of wListIndex.
    final wvc = webViewController;

    webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            final idx = _indexOfController(wvc);
            if (idx < 0) return;
            wInfoList[idx]['progress'] = progress * 0.01;
            _safeNotify();
          },
          onPageStarted: (String url) {
            final idx = _indexOfController(wvc);
            if (idx < 0) return;
            debugPrint('Page started loading: $url');
            wInfoList[idx]['load'] = true;
            // Re-inject on every navigation so SPAs don't lose the interceptor.
            _injectWcClipboardScript(wvc);
            _safeNotify();
          },
          onPageFinished: (String url) async {
            final idx = _indexOfController(wvc);
            if (idx < 0) return;
            wInfoList[idx]['load'] = false;
            wInfoList[idx]['progress'] = 0;
            // Inject again after full load in case onPageStarted fired too early.
            await _injectWcClipboardScript(wvc);
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
            debugPrint('HTTP error: ${error.response?.statusCode}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterWcClipboard',
        onMessageReceived: (JavaScriptMessage message) {
          if (kDebugMode) {
            final preview = message.message.length > 80
                ? '${message.message.substring(0, 80)}…'
                : message.message;
            debugPrint('[Browser] JS clipboard intercept: $preview');
          }
          _tryHandleWalletConnect(message.message);
        },
      )
      // Use a desktop user agent so DApps (e.g. Uniswap/@reown/appkit) present
      // the QR-code flow instead of the mobile deep-link flow, which fails
      // inside a WebView because wc:// cannot be handled by an external wallet.
      ..setUserAgent(
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) '
        'Version/17.0 Safari/605.1.15',
      )
      ..setOnConsoleMessage((JavaScriptConsoleMessage msg) {
        if (kDebugMode) {
          debugPrint('[DApp][${msg.level.name}] ${msg.message}');
        }
      });

    // Clear localStorage via the native WebKit data store BEFORE loading the
    // page so stale WalletConnect sessions (which may carry invalid "null"
    // addresses from a previous pairing) are gone before any page JS runs.
    // Both operations are queued on the same platform channel in FIFO order,
    // so clearLocalStorage is guaranteed to complete first.
    unawaited(webViewController.clearLocalStorage());
    unawaited(webViewController.loadRequest(Uri.parse(url)));

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
    _safeNotify();
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
  // FlutterWcClipboard is already registered as a global by the framework;
  // we patch its postMessage to hold a direct reference to the native handler
  // so it keeps working after webkit is hidden.
  if (!window.__flutterWebkitHidden) {
    window.__flutterWebkitHidden = true;
    try {
      if (window.webkit && window.webkit.messageHandlers) {
        var _nativeHandler = window.webkit.messageHandlers['FlutterWcClipboard'];
        if (window.FlutterWcClipboard && _nativeHandler) {
          window.FlutterWcClipboard.postMessage = function(msg) {
            _nativeHandler.postMessage([String(msg)]);
          };
        }
        Object.defineProperty(window, 'webkit', { get: function() { return undefined; }, configurable: true });
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
      if (kDebugMode) debugPrint('[Browser] WC clipboard script inject error: $e');
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
