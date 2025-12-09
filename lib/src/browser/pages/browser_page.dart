import 'package:n42appv2/src/browser/pages/browser_collection_list.dart';
import 'package:n42appv2/src/browser/pages/browser_setting.dart';
import 'package:n42appv2/src/browser/provider/browser_provider.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet_connect/pages/wallet_connect_page.dart';
//import 'package:n42appv2/src/wallet_connect/pages/wallet_connect_page.dart';
//import 'package:n42appv2/src/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/loading.dart';
import 'package:n42appv2/src/widgets/prompt_widget.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:n42appv2/src/widgets/textField_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserPage extends StatefulWidget {
  String openUrl;
  BrowserPage(this.openUrl,{super.key});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  BrowserProvider? _browserProvider;
  bool _inited = false;

  @override
  void initState() {
    super.initState();
    // 延迟到首帧后再初始化，避免在构建阶段触发通知
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _browserProvider = Provider.of<BrowserProvider>(context, listen: false);
      if (!_inited) {
        _inited = true;
        walletConnect();
      }
    });
  }

  @override
  void dispose() {
    // 使用缓存引用，避免在已卸载状态下通过 context 查找祖先
    _browserProvider?.connectDAPPCallBack = null;
    _browserProvider?.browser_dispose();
    super.dispose();
  }
  walletConnect(){
    final bp = _browserProvider ?? Provider.of<BrowserProvider>(context, listen: false);
    bp.connectDAPPCallBack=(String url,bool connect){
      if(connect){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletConnectPage(url)));
      }else{
        showAlertWidget_connectDapp(url);
      }
    };
    bp.browser_init();
    bp.addUrl(widget.openUrl);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: listWebViewWidget(),
        ),
      ),
    );
  }
  listWebViewWidget(){
    return Consumer<BrowserProvider>(builder: (context,bValue,child){
      return Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: ScreenUtil().setWidth(100.0),
            padding: EdgeInsets.only(top:ScreenUtil().setWidth(10.0),right: ScreenUtil().setWidth(20.0)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: TextFieldStyle2(
                    context,
                    controller: bValue.titleEditingController,
                    focusNode: bValue.titleFocusNode,
                    height: ScreenUtil().setWidth(80.0),
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setWidth(26.0),
                      fontWeight: bValue.titleFocusNode?.hasFocus??false?FontWeight.bold:FontWeight.normal,
                    ),
                    leftWidget: Container(
                      width: ScreenUtil().setWidth(30.0),
                      height: ScreenUtil().setWidth(30.0),
                      margin: EdgeInsets.only(right:ScreenUtil().setWidth(15.0)),
                      child: Image.asset(
                        "assets/browser/search.png",
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                        width: ScreenUtil().setWidth(30.0),
                        height: ScreenUtil().setWidth(30.0),
                      ),
                    ),
                    maxLines: 1,
                    boxShadow:BoxShadow(
                      color: Color(0xff101828).withAlpha((0 * 255).round()),  //底色,阴影颜色
                      offset: Offset(0, 0), //阴影位置,从什么位置开始
                      blurRadius: ScreenUtil().setWidth(0),  // 阴影模糊层度
                      spreadRadius: 0, ),
                    onEditingComplete: (){
                      bValue.loadRequest();
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(10.0),),
                InkWell(
                  onTap: (){
                    bValue.wList_add();
                  },
                  child: Container(
                    height: ScreenUtil().setWidth(60.0),
                    width: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(10.0)),
                    child: Image.asset(
                      "assets/browser/add.png",
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      width: ScreenUtil().setWidth(40.0),
                      height: ScreenUtil().setWidth(40.0),
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    bValue.setShowWList(true);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0)),
                    height: ScreenUtil().setWidth(40),
                    width: ScreenUtil().setWidth(40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12.0)),
                      border: Border.all(width:ScreenUtil().setWidth(2.0),color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),),
                    ),
                    child: Text(
                      "${bValue.wList.length}",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(20.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                  ),
                ),
                /*if(bValue.wListIndex !=-1)
                  Visibility(
                    visible: bValue.wInfoList[bValue.wListIndex]['load']??false,
                    child: SizedBox(
                      width: ScreenUtil().setWidth(40.0),
                      height: ScreenUtil().setWidth(40.0),
                      child: CircularProgressIndicator(
                        value: (bValue.wInfoList[bValue.wListIndex]['progress']??0).toDouble(),
                        backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBorderColor.name),
                        valueColor: AlwaysStoppedAnimation<Color>(AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)),
                      ),
                    ),
                  ),
                */
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: webViewWidget(bValue),
          ),
          if(bValue.showWList==false && bValue.wListIndex !=-1)
            if(bValue.wInfoList?[bValue.wListIndex]?['load']??false)
            LinearProgressIndicator(
              value: bValue.wInfoList[bValue.wListIndex]['progress']??0,
              backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor3.name),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),),
          if(bValue.showWList==false)
            Container(
              alignment: Alignment.center,
              height: ScreenUtil().setWidth(100.0),
              child: Row(
                children: [
                  Expanded(child: InkWell(
                    onTap: ()async{
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: ScreenUtil().setWidth(80.0),
                      width: ScreenUtil().setWidth(60.0),
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0),vertical: ScreenUtil().setWidth(20.0)),
                      child: Image.asset(
                        "assets/browser/close.png",
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        width: ScreenUtil().setWidth(40.0),
                        height: ScreenUtil().setWidth(40.0),
                      ),
                    ),
                  ),),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: ()async{
                        WebViewController wv=bValue.wvcList[bValue.wListIndex];
                        await wv!.reload();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: ScreenUtil().setWidth(80.0),
                        width: ScreenUtil().setWidth(60.0),
                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0),vertical: ScreenUtil().setWidth(20.0)),
                        child: Image.asset(
                          "assets/browser/refresh.png",
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          width: ScreenUtil().setWidth(40.0),
                          height: ScreenUtil().setWidth(40.0),
                        ),
                      ),
                    ),),
                  if(bValue.canBack)
                    Expanded(child: InkWell(
                      onTap: ()async{
                        WebViewController wv=bValue.wvcList[bValue.wListIndex];
                        bool back=await wv!.canGoBack();
                        if (back){
                          await wv!.goBack();
                        }else{
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: ScreenUtil().setWidth(80.0),
                        width: ScreenUtil().setWidth(60.0),
                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0),vertical: ScreenUtil().setWidth(20.0)),
                        child: Image.asset(
                          "assets/browser/arrow-left.png",
                          color: AppThemeUtils.getColorByKey(context, bValue.canBack?AppThemeKeys.mainTextColor.name:AppThemeKeys.itemBorderColor.name),
                          width: ScreenUtil().setWidth(40.0),
                          height: ScreenUtil().setWidth(40.0),
                        ),
                      ),
                    ),),
                  if(bValue.canForward)
                    Expanded(child: InkWell(
                      onTap: ()async{
                        WebViewController wv=bValue.wvcList[bValue.wListIndex];
                        bool forward=await wv!.canGoForward();
                        if (forward){
                          await wv!.goForward();
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: ScreenUtil().setWidth(80.0),
                        width: ScreenUtil().setWidth(60.0),
                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0),vertical: ScreenUtil().setWidth(20.0)),
                        child: Image.asset(
                          "assets/browser/arrow-right.png",
                          color: AppThemeUtils.getColorByKey(context, bValue.canForward?AppThemeKeys.mainTextColor.name:AppThemeKeys.itemBorderColor.name),
                          width: ScreenUtil().setWidth(40.0),
                          height: ScreenUtil().setWidth(40.0),
                        ),
                      ),
                    ),),
                  Expanded(child: InkWell(
                    onTap: ()async{
                      if(bValue.collect){
                        bValue.deleteBrowserCollection_url();
                      }else{
                        bValue.addBrowserCollection(context);
                      }
                    },
                    child: Container(
                      height: ScreenUtil().setWidth(80.0),
                      width: ScreenUtil().setWidth(60.0),
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0),vertical: ScreenUtil().setWidth(20.0)),
                      child: Image.asset(
                        "assets/browser/${bValue.collect?"star":"star_border"}.png",
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        width: ScreenUtil().setWidth(40.0),
                        height: ScreenUtil().setWidth(40.0),
                      ),
                    ),
                  ),),
                  Expanded(child: InkWell(
                    onTap: ()async{
                      String? url=await Navigator.push(context, MaterialPageRoute(builder: (context)=>BrowserCollectionList()));
                      if(url !=null){
                        WebViewController wv=bValue.wvcList[bValue.wListIndex];
                        wv!.loadRequest(Uri.parse(url));
                      }
                    },
                    child: Container(
                      height: ScreenUtil().setWidth(80.0),
                      width: ScreenUtil().setWidth(60.0),
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0),vertical: ScreenUtil().setWidth(20.0)),
                      child: Image.asset(
                        "assets/browser/note.png",
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        width: ScreenUtil().setWidth(40.0),
                        height: ScreenUtil().setWidth(40.0),
                      ),
                    ),
                  ),),
                  Expanded(child: InkWell(
                    onTap: ()async{
                      WebViewController wv=bValue.wvcList[bValue.wListIndex];
                      await Navigator.push(context, MaterialPageRoute(builder: (context)=>BrowserSetting(webViewController: wv,)));
                      bValue.getBrowserSetting();
                    },
                    child: Container(
                      height: ScreenUtil().setWidth(80.0),
                      width: ScreenUtil().setWidth(60.0),
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0),vertical: ScreenUtil().setWidth(20.0)),
                      child: Image.asset(
                        "assets/browser/setting.png",
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        width: ScreenUtil().setWidth(40.0),
                        height: ScreenUtil().setWidth(40.0),
                      ),
                    ),
                  ),),
                  /*
                  Consumer<WalletConnectProvider>(builder: (context,wc,child){
                    if(wc.walletConnectState!=WalletConnectState.disconnect && wc.dAppTopic !=null){
                      return Expanded(child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletConnectPage("")));
                        },
                        child: Container(
                          height: ScreenUtil().setWidth(80.0),
                          alignment: Alignment.center,
                          child: Container(
                            width: ScreenUtil().setWidth(60.0),
                            height: ScreenUtil().setWidth(60.0),
                            padding: EdgeInsets.all(ScreenUtil().setWidth(4)),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(60))
                            ),
                            child: ImageNetWork(imageUrl: wc.metadata!.icons.length==0?"":wc.metadata!.icons[0]??"",),
                          ),

                        ),
                      ),);
                    }else{
                      return SizedBox();
                    }
                  }),
                  */
                ],
              ),
            ),
          if(bValue.showWList)
            Container(
              alignment: Alignment.center,
              height: ScreenUtil().setWidth(100.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: ()async{
                        bValue.cleanWList();
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: ScreenUtil().setWidth(80.0),
                        margin: EdgeInsets.only(left: ScreenUtil().setSp(30.0)),
                        child: Text(
                          S.of(context).g_browser_key16,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(26.0),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: ()async{
                        bValue.wList_add();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: ScreenUtil().setWidth(80.0),
                        width: ScreenUtil().setWidth(60.0),
                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0),vertical: ScreenUtil().setWidth(20.0)),
                        child: Image.asset(
                          "assets/browser/add.png",
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          width: ScreenUtil().setWidth(40.0),
                          height: ScreenUtil().setWidth(40.0),
                        ),
                      ),
                    ),),
                  Expanded(
                    child: InkWell(
                      onTap: ()async{
                        bValue.setShowWList(false);
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        height: ScreenUtil().setWidth(80.0),
                        margin: EdgeInsets.only(right: ScreenUtil().setSp(30.0)),
                        child: Text(
                          S.of(context).g_browser_key17,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(26.0),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
        ],
      );
    });
  }
  webViewWidget(BrowserProvider bValue){
    if(bValue.showWList){
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        itemCount: bValue.wList.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: ScreenUtil().setWidth(30),
          mainAxisSpacing: ScreenUtil().setWidth(30),
        ),
        itemBuilder: (context,int index){
          return AspectRatio(
            aspectRatio: 0.8,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30.0)),
                border: Border.all(
                  width: ScreenUtil().setWidth(2.0),
                  color: AppThemeUtils.getColorByKey(context, index==bValue.wListIndex?AppThemeKeys.mainBlueColor.name:AppThemeKeys.itemLineColor.name),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30.0)),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: bValue.wList[index],
                    ),
                  ),
                  Positioned.fill(
                    child: InkWell(
                      onTap: (){
                        bValue.wList_show(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30.0)),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.transparentBgColor.name),
                        ),
                        clipBehavior: Clip.hardEdge,

                        child: Column(
                          children: [
                            Container(
                              height: ScreenUtil().setWidth(50.0),
                              width: double.infinity,
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
                                      child: Text(
                                        bValue.wInfoList[index]['title']??"",
                                        style: TextStyle(
                                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                          fontSize: ScreenUtil().setSp(20.0),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                    flex: 1,
                                  ),
                                  InkWell(
                                    onTap: (){
                                      bValue.wList_delete(index);
                                    },
                                    child: Container(
                                      width: ScreenUtil().setWidth(40.0),
                                      height: ScreenUtil().setWidth(40.0),
                                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(15.0)),
                                      padding: EdgeInsets.all( ScreenUtil().setWidth(5.0)),
                                      child: Image.asset(
                                        "assets/browser/close.png",
                                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                        width: ScreenUtil().setWidth(30.0),
                                        height: ScreenUtil().setWidth(30.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    }
    else{
      if(bValue.wListIndex==-1){
        //return Loading();
        return EmptyView();
      }
      /*if(bValue.wInfoList[bValue.wListIndex]['load']==null){
        return Loading();
        //return EmptyView();
      }*/
      return bValue.wList[bValue.wListIndex];
    }
  }
  showAlertWidget_connectDapp(String uri){
    SheetBottom(context, S.of(context).g_browser_key14, Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: ScreenUtil().setWidth(30)),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Uri",
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              IconButton(
                onPressed: (){
                  ToastUtils.init(context);
                  Clipboard.setData(ClipboardData(
                      text: uri));
                  //toast 已经复制
                  ToastUtils.showFtToast(child:SuccessViewV1(S.of(context).copy),duration: 3);
                },
                icon: Icon(Icons.copy,color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(30)),
          alignment: Alignment.centerLeft,
          child: Text(
            uri,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
        ),
        Container(
          height: ScreenUtil().setWidth(88),
          child: Row(
            children: [
              Expanded(child: ButtonStyle1(context, (){
                Navigator.pop(context);
              }, S.of(context).g_key_79),),
              SizedBox(width: ScreenUtil().setWidth(30),),
              Expanded(child: ButtonStyle2(context, ()async{
                //await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletConnectPage(uri)));
                Navigator.pop(context);
              }, S.of(context).g_key_78),),
            ],
          ),
        ),
      ],
    ));
  }
}
