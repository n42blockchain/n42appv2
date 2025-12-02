import 'package:n42appv2/app_config.dart';
import 'package:n42appv2/src/browser/api/browser_api.dart';
import 'package:n42appv2/src/browser/models/browser_collection_model.dart';
import 'package:n42appv2/src/browser/pages/browser_collection.dart';
import 'package:n42appv2/src/utils/event_bus.dart';
import 'package:n42appv2/src/utils/sp_util.dart';
import 'package:flutter/cupertino.dart';
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
    if(_browserApi==null){
      _browserApi=BrowserApi();
    }
    return _browserApi!;
  }
  Map<String,dynamic> browser={
    "connectDApp":false,
  };
  getBrowserSetting()async{
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
  setShowWList(bool value){
    showWList=value;
    notifyListeners();
  }
  String _blockUri="";//需要拦截的地址
  setBlockUri(String value){
    _blockUri=value;
  }

  TextEditingController? titleEditingController;
  FocusNode? titleFocusNode;
  ConnectDAPP? connectDAPPCallBack;

  String openUrl="";
  String nowUrl="";
  bool canBack=false;
  bool canForward=false;
  bool collect=false;
  browser_init(){
    titleEditingController=TextEditingController();
    titleFocusNode=FocusNode();
    titleFocusNode?.addListener(() {
      notifyListeners();
    });
  }
  browser_dispose(){
    titleEditingController?.dispose();
    titleFocusNode?.dispose();
  }
  addUrl(String url){
    String rUrl=checkHttp(url);
    wList_add(url:rUrl);
  }
  wList_add({String url=""}){
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
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    webViewController =
        WebViewController.fromPlatformCreationParams(params);
    webViewController!
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
            getCollection_url(url);
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
        ),
      )
      ..loadRequest(Uri.parse(url));

    // #docregion platform_features
    if (webViewController!.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (webViewController!.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    Widget wv=WebViewWidget(controller: webViewController!);
    wList.add(wv);
    wvcList.add(webViewController);
    wInfoList.add({
      "openUrl":url,
    });
    showWList=false;
    wListIndex=wList.length-1;
    notifyListeners();
  }
  loadRequest({String url=""}){
    if(url==""){
      url=titleEditingController?.text??"";
    }
    if(url=="")return;
    url=checkHttp(url);
    WebViewController wv=wvcList[wListIndex];
    wv!.loadRequest(Uri.parse(url));
    wInfoList[wListIndex]['openUrl']=url;
    //notifyListeners();
  }
  //显示webView
  wList_show(int index){
    wListIndex=index;
    showWList=false;
    titleEditingController?.text=wInfoList[wListIndex]['openUrl'];
    checkCanGo();
    getCollection_url(wInfoList[wListIndex]['openUrl']);
  }
  //删除一个 webView
  wList_delete(int index){
    if(index==0){
      //第一位
      if(wList.length==1){
        //只有一个页面
        wListIndex=-1;
      }
      wList.removeAt(index);
    }else if(index==wListIndex-1){
      //最后一位
      if(wListIndex==index){
        wListIndex--;
      }
      wList.removeAt(index);
    }else{
      wListIndex--;
      wList.removeAt(index);
    }
    if(wListIndex==-1){
      showWList=false;
    }
    notifyListeners();
  }
  //查询收藏缓存 条件 url
  getCollection_url(String url)async{
    List<BrowserCollectionModel> list=await browserApi.selectBrowserCollection_url(url);
    if(list.length ==0){
      collect=false;
    }else{
      collect=true;
    }
    notifyListeners();
  }
  getTitle()async{
    WebViewController wv=wvcList[wListIndex];
    String? t=await wv?.getTitle();
    if(t !=null){
      wInfoList[wListIndex]['title']=t;
      notifyListeners();
    }
  }
  gotoGoogle(){
    WebViewController wv=wvcList[wListIndex];
    String url=wInfoList[wListIndex]['openUrl'];
    wInfoList[wListIndex]['openUrl']="https://www.google.com/search?q=${url}";
    wv?.loadRequest(Uri.parse(openUrl));
  }
  //检查是否可以 上一页，或者下一页
  checkCanGo()async{
    WebViewController wv=wvcList[wListIndex];
    canBack=await wv!.canGoBack();
    canForward=await wv!.canGoForward();
    notifyListeners();
  }
  clearCache(){
    WebViewController wv=wvcList[wListIndex];
    if(wv !=null){
      wv!.clearCache();
    }
  }
  checkUrl(String url){
    if(_blockUri !=""){
      if(_blockUri == url){
        eventBus.fire(EventPublic(EventPublicType.blockUri));
        return false;
      }
    }
    Uri uri=Uri.parse(url);
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
  checkHttp(String url){
    String returnUrl="";
    bool isHttp=isURL(url,);
    if(isHttp){
      int httpIndex=url.indexOf("https://",0);
      if(httpIndex!=0 ){
        httpIndex=url.indexOf("http://",0);
      }
      if(httpIndex!=0){
        returnUrl='https://${url}';
      }else{
        returnUrl=url;
      }
    }else{
      returnUrl="https://www.google.com/search?q=${url}";
    }
    return returnUrl;
  }
  //删除收藏url
  deleteBrowserCollection_url()async{
    await browserApi.deleteBrowserCollection_url(wInfoList[wListIndex]['openUrl']);
    getCollection_url(wInfoList[wListIndex]['openUrl']);
  }
  //添加收藏
  addBrowserCollection(context)async{
    WebViewController wv=wvcList[wListIndex];
    String? currentUrl=await wv!.currentUrl();
    String? title=await wv!.getTitle();
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>BrowserCollection(title==null?"":title!,currentUrl==null?"":currentUrl!,)));
    getCollection_url(wInfoList[wListIndex]['openUrl']);
  }
  cleanWList(){
    showWList=false;
    wListIndex=-1;
    wList=[];
    wvcList=[];
    wInfoList=[];
    notifyListeners();
  }
}