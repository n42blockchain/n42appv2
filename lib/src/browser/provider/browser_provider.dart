import 'package:flutter/foundation.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/browser/api/browser_api.dart';
import 'package:n42appv2/src/browser/models/browser_collection_model.dart';
import 'package:n42appv2/src/browser/pages/browser_collection.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
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

typedef ConnectDAPP = void Function(String url,bool connect);
class BrowserProvider extends ChangeNotifier{
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
  final String _blockUri="";//需要拦截的地址

  TextEditingController? titleEditingController;
  FocusNode? titleFocusNode;
  ConnectDAPP? connectDAPPCallBack;

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
    webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
            wInfoList[wListIndex]['progress']=progress*0.01;
            notifyListeners();
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            wInfoList[wListIndex]['load']=true;
            notifyListeners();
          },
          onPageFinished: (String url) {
            wInfoList[wListIndex]['load']=false;
            wInfoList[wListIndex]['progress']=0;
            browserApi.insertBrowserHistory(url);
            getTitle();
            checkCanGo();
            getCollectionUrl(url);
          },
          onWebResourceError: (WebResourceError error) {
            wInfoList[wListIndex]['load']=false;
            wInfoList[wListIndex]['progress']=0;
            notifyListeners();
          },
          onNavigationRequest: (NavigationRequest request) {
            bool r=checkUrl(request.url);
            if(r==true){
              return NavigationDecision.navigate;
            }else{
              return NavigationDecision.prevent;
            }
          },
          onUrlChange: (UrlChange change) {
            wInfoList[wListIndex]['openUrl']=change.url??"";
            titleEditingController?.text=wInfoList[wListIndex]['openUrl'];
            notifyListeners();
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('HTTP error: ${error.response?.statusCode}');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

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
    titleEditingController?.text=wInfoList[wListIndex]['openUrl'];
    checkCanGo();
    getCollectionUrl(wInfoList[wListIndex]['openUrl']);
  }
  //删除一个 webView
  void wListDelete(int index) {
    // Clear WebViewController navigation delegate before removal
    wvcList[index].setNavigationDelegate(NavigationDelegate());
    wList.removeAt(index);
    wvcList.removeAt(index);
    wInfoList.removeAt(index);
    if(wList.isEmpty){
      wListIndex=-1;
      showWList=false;
    }else if(index < wListIndex){
      wListIndex--;
    }else if(index == wListIndex){
      // 当前页被删除，显示前一个或第一个
      if(wListIndex >= wList.length){
        wListIndex=wList.length-1;
      }
    }
    notifyListeners();
  }
  //查询收藏缓存 条件 url
  Future<void> getCollectionUrl(String url)async{
    List<BrowserCollectionModel> list=await browserApi.selectBrowserCollectionUrl(url);
    if(list.isEmpty){
      collect=false;
    }else{
      collect=true;
    }
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
    if(_blockUri !=""){
      if(_blockUri == url){
        eventBus.fire(EventPublic(EventPublicType.blockUri));
        return false;
      }
    }
    Uri uri=Uri.parse(url);
    // 拦截危险 URL 协议：javascript: 可用于 XSS；data: / blob: 可绕过 CSP；file: 可读本地文件
    const blockedSchemes = {'javascript', 'data', 'blob', 'file'};
    if (blockedSchemes.contains(uri.scheme)) return false;
    if(uri.scheme=="wc"){
      if(url.contains('relay-protocol') && url.contains('symKey')){
        if(connectDAPPCallBack !=null){
          connectDAPPCallBack!(url,browser['connectDApp']);
          return false;
        }
      }
    }else if(uri.scheme=="amazeapp"){
      if (uri.path == "/wc") {
        String param = uri.queryParameters['uri'] ?? "";
        if (param.contains('relay-protocol') && param.contains('symKey')) {
          if(connectDAPPCallBack !=null){
            connectDAPPCallBack!(param,browser['connectDApp']);
            return false;
          }
        }
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
      returnUrl="https://www.google.com/search?q=$url";
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
  void cleanWList() {
    showWList=false;
    wListIndex=-1;
    wList=[];
    wvcList=[];
    wInfoList=[];
    notifyListeners();
  }
}