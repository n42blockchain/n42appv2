import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/security/phishing_detector.dart';
import 'package:n42appv2/core/utils/js_escape_utils.dart';
import 'package:n42appv2/src/browser/api/browser_api.dart';
import 'package:n42appv2/src/browser/handler/dapp_request_handler.dart';
import 'package:n42appv2/src/browser/js/ethereum_provider.dart';
import 'package:n42appv2/src/browser/pages/browser_collection.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/core/providers/legacy_wallet_adapter.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

typedef ConnectDAPP = void Function(String url, bool connect);

/// Callback invoked when a navigation is blocked as phishing.
///
/// [url] is the blocked URL.
/// [proceed] is a callback that the UI may invoke if the user chooses
/// "Proceed Anyway"; it whitelists the URL for this session and retries.
typedef PhishingWarning = void Function(String url, VoidCallback proceed);

class BrowserProvider extends ChangeNotifier {
  BrowserProvider(){
    getBrowserSetting();
  }
  BrowserApi? _browserApi;
  BrowserApi get browserApi{
    _browserApi ??= BrowserApi();
    return _browserApi!;
  }
  Map<String,dynamic> browser={
    "connectDApp":false,
  };
  Future<void> getBrowserSetting()async{
    Map<String,dynamic>? b=await SPUtil().getBrowserSetting();
    if(b !=null){
      browser=b;
    }
  }

  List<Widget> wList=[];
  List<WebViewController> wvcList=[];
  List<Map<String,dynamic>> wInfoList=[];
  int wListIndex=-1;
  bool showWList=false;
  void setShowWList(bool value){
    showWList=value;
    notifyListeners();
  }
  /// URL to block from navigation. Empty string means no blocking.
  final String _blockUri = "";

  TextEditingController? titleEditingController;
  FocusNode? titleFocusNode;
  ConnectDAPP? connectDAPPCallBack;

  /// Set by [BrowserPage] to display a phishing warning dialog.
  /// Cleared in [BrowserPage.dispose] to prevent stale context usage.
  PhishingWarning? phishingCallBack;

  /// DApp request handler for EIP-1193 provider
  DAppRequestHandler? _dappHandler;
  DAppRequestHandler? get dappHandler => _dappHandler;

  /// Initialize the DApp handler with EVM chains from the wallet
  void initDAppHandler() {
    try {
      final cms = globalWapAdapter.coinModels;
      final ethCoins = cms.where((cm) =>
          cm.coin['blockchainType'] == BlockchainType.Ethereum.name).toList();
      if (ethCoins.isNotEmpty) {
        _dappHandler = DAppRequestHandler(ethCoinModels: ethCoins);
      }
    } catch (e) {
      debugPrint('[Browser] initDAppHandler error: $e');
    }
  }

  bool canBack=false;
  bool canForward=false;
  bool collect=false;
  void browserInit() {
    titleEditingController=TextEditingController();
    titleFocusNode=FocusNode();
    titleFocusNode?.addListener(() {
      notifyListeners();
    });
  }
  void browserDispose() {
    titleEditingController?.dispose();
    titleFocusNode?.dispose();
  }
  void addUrl(String url) {
    String rUrl=checkHttp(url);
    wListAdd(url:rUrl);
  }

  /// Look up the current index of [controller] in the tab list.
  /// Returns -1 if the tab has been closed.
  int _indexOfController(WebViewController controller) {
    return wvcList.indexOf(controller);
  }

  void wListAdd({String url=""}) {
    if(url==""){
      url=AppConfig.apiUrl['walletamazeBrowser']!;
    }
    titleEditingController?.text=url;
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

    webViewController =
        WebViewController.fromPlatformCreationParams(params);

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
            wInfoList[idx]['progress']=progress*0.01;
            notifyListeners();
          },
          onPageStarted: (String url) {
            final idx = _indexOfController(wvc);
            if (idx < 0) return;
            debugPrint('Page started loading: $url');
            wInfoList[idx]['load']=true;
            _injectProviderScript(wvc);
            notifyListeners();
          },
          onPageFinished: (String url) async {
            final idx = _indexOfController(wvc);
            if (idx < 0) return;
            wInfoList[idx]['load']=false;
            wInfoList[idx]['progress']=0;
            _injectProviderScript(wvc);
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
            notifyListeners();
          },
          onWebResourceError: (WebResourceError error) {
            final idx = _indexOfController(wvc);
            if (idx < 0) return;
            wInfoList[idx]['load']=false;
            wInfoList[idx]['progress']=0;
            notifyListeners();
          },
          onNavigationRequest: (NavigationRequest request) {
            return checkUrl(request.url)
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
          onUrlChange: (UrlChange change) {
            final idx = _indexOfController(wvc);
            if (idx < 0) return;
            wInfoList[idx]['openUrl']=change.url??"";
            // Only update URL bar if this is the active tab
            if (idx == wListIndex) {
              titleEditingController?.text=wInfoList[idx]['openUrl'];
            }
            notifyListeners();
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('HTTP error: ${error.response?.statusCode}');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    // Add DApp JavaScript channel for EIP-1193 communication
    if (_dappHandler != null) {
      webViewController.addJavaScriptChannel(
        'N42Wallet',
        onMessageReceived: (JavaScriptMessage message) {
          _handleDAppMessage(message, webViewController);
        },
      );
    }

    // #docregion platform_features
    if (webViewController.platform is AndroidWebViewController) {
      final androidController = webViewController.platform as AndroidWebViewController;
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
    Widget wv=WebViewWidget(controller: webViewController);
    wList.add(wv);
    wvcList.add(webViewController);
    wInfoList.add({
      "openUrl":url,
    });
    showWList=false;
    wListIndex=wList.length-1;
    notifyListeners();
  }
  void loadRequest({String url=""}) {
    if(url==""){
      url=titleEditingController?.text??"";
    }
    if(url=="")return;
    url=checkHttp(url);
    WebViewController wv=wvcList[wListIndex];
    wv.loadRequest(Uri.parse(url));
    wInfoList[wListIndex]['openUrl']=url;
    //notifyListeners();
  }
  //显示webView
  void wListShow(int index) {
    wListIndex=index;
    showWList=false;
    titleEditingController?.text=wInfoList[wListIndex]['openUrl'] ?? '';
    // Notify immediately so the UI switches tab right away
    notifyListeners();
    // Then async-update navigation and bookmark state
    checkCanGo();
    getCollectionUrl(wInfoList[wListIndex]['openUrl'] ?? '');
  }
  //删除一个 webView
  void wListDelete(int index) {
    // Clear WebViewController navigation delegate before removal
    wvcList[index].setNavigationDelegate(NavigationDelegate());
    wList.removeAt(index);
    wvcList.removeAt(index);
    wInfoList.removeAt(index);
    if(wList.isEmpty){
      wListAdd();
      return;
    }else if(index < wListIndex){
      wListIndex--;
    }else if(index == wListIndex){
      // 当前页被删除，显示前一个或第一个
      if(wListIndex >= wList.length){
        wListIndex=wList.length-1;
      }
    }
    // Sync URL bar and navigation state with the new current tab
    if (wListIndex >= 0 && wListIndex < wInfoList.length) {
      titleEditingController?.text = wInfoList[wListIndex]['openUrl'] ?? '';
      checkCanGo();
      getCollectionUrl(wInfoList[wListIndex]['openUrl'] ?? '');
    }
    notifyListeners();
  }
  /// Check whether the given URL is in the bookmarks collection.
  Future<void> getCollectionUrl(String url) async {
    final list = await browserApi.selectBrowserCollectionUrl(url);
    collect = list.isNotEmpty;
    notifyListeners();
  }
  Future<void> getTitle()async{
    WebViewController wv=wvcList[wListIndex];
    String? t=await wv.getTitle();
    if(t !=null){
      wInfoList[wListIndex]['title']=t;
      notifyListeners();
    }
  }
  //检查是否可以 上一页，或者下一页
  Future<void> checkCanGo()async{
    WebViewController wv=wvcList[wListIndex];
    canBack=await wv.canGoBack();
    canForward=await wv.canGoForward();
    notifyListeners();
  }
  bool checkUrl(String url) {
    if (_blockUri != "") {
      if (_blockUri == url) {
        eventBus.fire(EventPublic(EventPublicType.blockUri));
        return false;
      }
    }
    final uri = Uri.parse(url);
    // 拦截危险 URL 协议：javascript: 可用于 XSS；data: / blob: 可绕过 CSP；file: 可读本地文件
    const blockedSchemes = {'javascript', 'data', 'blob', 'file'};
    if (blockedSchemes.contains(uri.scheme)) return false;

    if (uri.scheme == "wc") {
      if (url.contains('relay-protocol') && url.contains('symKey')) {
        if (connectDAPPCallBack != null) {
          connectDAPPCallBack!(url, browser['connectDApp']);
          return false;
        }
      }
    } else if (uri.scheme == "amazeapp") {
      if (uri.path == "/wc") {
        final param = uri.queryParameters['uri'] ?? "";
        if (param.contains('relay-protocol') && param.contains('symKey')) {
          if (connectDAPPCallBack != null) {
            connectDAPPCallBack!(param, browser['connectDApp']);
            return false;
          }
        }
      }
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
    String returnUrl="";
    bool isHttp=isURL(url,);
    if(isHttp){
      int httpIndex=url.indexOf("https://",0);
      if(httpIndex!=0 ){
        httpIndex=url.indexOf("http://",0);
      }
      if(httpIndex!=0){
        returnUrl='https://$url';
      }else{
        returnUrl=url;
      }
    }else{
      returnUrl="https://www.google.com/search?q=${Uri.encodeQueryComponent(url)}";
    }
    return returnUrl;
  }
  //删除收藏url
  Future<void> deleteBrowserCollectionUrl()async{
    await browserApi.deleteBrowserCollectionUrl(wInfoList[wListIndex]['openUrl']);
    getCollectionUrl(wInfoList[wListIndex]['openUrl']);
  }
  //添加收藏
  Future<void> addBrowserCollection(BuildContext context) async {
    WebViewController wv=wvcList[wListIndex];
    String? currentUrl=await wv.currentUrl();
    String? title=await wv.getTitle();
    if (!context.mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>BrowserCollection(title ?? "",currentUrl ?? "",)));
    getCollectionUrl(wInfoList[wListIndex]['openUrl']);
  }
  /// Handle incoming DApp JSON-RPC messages from the JavaScript channel.
  ///
  /// The [controller] reference is captured at channel creation time,
  /// so it always points to the correct WebView regardless of tab switching.
  Future<void> _handleDAppMessage(
      JavaScriptMessage message, WebViewController controller) async {
    if (_dappHandler == null) return;
    try {
      final data = json.decode(message.message) as Map<String, dynamic>;
      final id = data['id'];
      if (id == null) return;
      final method = data['method'] as String;
      final params = (data['params'] as List<dynamic>?) ?? [];

      try {
        final result = await _dappHandler!.handleRequest(method, params);

        // If chain was switched, notify the JS side
        if (method == 'wallet_switchEthereumChain' ||
            method == 'wallet_addEthereumChain') {
          final newChainHex = JsEscapeUtils.escapeJs(_dappHandler!.chainIdHex);
          final newAddr = JsEscapeUtils.escapeJs(_dappHandler!.address);
          controller.runJavaScript(
              'window.ethereum._n42SetChain("$newChainHex");'
              'window.ethereum._n42SetAccounts(["$newAddr"]);');
        }

        // Serialize result safely — handles null, strings, numbers, lists, maps
        final resultStr = JsEscapeUtils.escapeJs(json.encode(result));
        controller.runJavaScript(
            'window.ethereum._n42Cb($id, "$resultStr", null);');
      } catch (e) {
        // Build a proper EIP-1193 error object {code, message}
        final Map<String, dynamic> errObj;
        if (e is Map) {
          errObj = {'code': e['code'] ?? -32603, 'message': e['message'] ?? e.toString()};
        } else {
          errObj = {'code': -32603, 'message': e.toString()};
        }
        final errorStr = JsEscapeUtils.escapeJs(json.encode(errObj));
        controller.runJavaScript(
            'window.ethereum._n42Cb($id, null, "$errorStr");');
      }
    } catch (e) {
      debugPrint('[Browser] DApp message parse error: $e');
    }
  }

  /// Inject the EIP-1193 provider script into the given WebView controller.
  /// Idempotent — safe to call multiple times (the JS IIFE guards with `_isN42`).
  void _injectProviderScript(WebViewController controller) {
    if (_dappHandler == null) return;
    try {
      final script = EthereumProviderJs.buildProviderScript(
        _dappHandler!.chainIdHex,
        [_dappHandler!.address],
      );
      controller.runJavaScript(script);
    } catch (e) {
      debugPrint('[Browser] Provider injection error: $e');
    }
  }

  void cleanWList() {
    // Clear all navigation delegates before disposal
    for (final wvc in wvcList) {
      wvc.setNavigationDelegate(NavigationDelegate());
    }
    showWList=false;
    wList=[];
    wvcList=[];
    wInfoList=[];
    _dappHandler?.dispose();
    _dappHandler=null;
    // Create a fresh default tab instead of leaving empty
    wListIndex=-1;
    wListAdd();
  }
}