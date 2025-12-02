import 'dart:async';
import 'dart:ui';

import 'package:n42appv2/app_config.dart';
import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/chat/pages/chat_index_page.dart';
import 'package:n42appv2/src/chat/widgets/chat_services.dart';
import 'package:n42appv2/src/home/home_draw_page.dart';
import 'package:n42appv2/src/home/unlock.dart';
import 'package:n42appv2/src/miningV2/pages/mining_background.dart';
import 'package:n42appv2/src/miningV2/pages/mining_today_v2.dart';
import 'package:n42appv2/src/state/public_provider.dart';
import 'package:n42appv2/src/utils/sp_util.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/wallet/pages/wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  List<Widget> _pages=[
    //NewsPage(),
    WalletPage(),
    //MiningHomePage(),
    MiningTodayV2(),
    ChatIndexPage()
  ];
  //final GlobalKey _tabOne = GlobalKey();
  final GlobalKey _tabTwo = GlobalKey();
  final GlobalKey _tabThree = GlobalKey();
  final GlobalKey _tabfour = GlobalKey();
  //final GlobalKey _tabfive = GlobalKey();
  bool? showTermsOfService;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initData();
  }
  initData()async{
    showTermsOfService=await SPUtil().getShowTermsOfService();
    setState(() {});
    if(Application.userInfo==null)return;
    PublicProvider pValue=Provider.of<PublicProvider>(context,listen: false);
    //await pValue.getLockScreenData();
    if (pValue.lockScreenMap['lock'] ||
        pValue.lockScreenMap['face'] ||
        pValue.lockScreenMap['gesture']) {
      Timer(Duration(milliseconds:500),()async{
        final rData=await Navigator.push(context, MaterialPageRoute(builder: (context)=>Unlock()));
        if(rData==true){
          Application.login(Application.userInfo!);
        }
      });
    }else{
      Application.login(Application.userInfo!);
    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    //关闭监听流
    //subscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: context.watch<PublicProvider>().homeCurrentIndex,
              children: _pages,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: ScreenUtil().setWidth(100.0),
                alignment: Alignment.center,
                //padding: EdgeInsets.only(top: ScreenUtil().setWidth(20), bottom: ScreenUtil().setWidth(20)),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        width: ScreenUtil().setWidth(1.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name)),
                  ),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemBgColor.name),
                  // color: Colors.redAccent,
                  /*gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.linearGradient1.name),
                      AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.linearGradient2.name),
                    ],
                  ),*/
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /*_buildBottomItem(
                        S.of(context).g_home_key2,
                        0,
                        "assets/home/tabbar/news.png",
                        _tabOne),*/
                    _buildBottomItem(
                        S.of(context).g_key_6,
                        0,
                        "assets/home/tabbar/wallet.png",
                        _tabTwo),
                    _buildBottomItem(
                        S.of(context).g_home_key3,
                        1,
                        "assets/home/tabbar/earn.png",
                        _tabThree),
                    _buildBottomItem(
                        S.of(context).g_key_squad,
                        2,
                        "assets/home/tabbar/chat.png",
                        _tabfour),
                  ],
                ),
              ),
            ),
            if(showTermsOfService==false)
              Positioned.fill(
                child: ChatServices(
                  '${AppConfig.apiUrl['walletamazeBrowser']}/static/terms_of_use.html',
                  agreeCallBack: () {
                    SPUtil().setShowTermsOfService(true);
                    showTermsOfService = true;
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ),
          ],
        ),
      ),
      // 默认20 不容易触发 这里调整到60
      drawerEdgeDragWidth: ScreenUtil().setWidth(120),
      drawer: const Drawer(
        backgroundColor: Colors.transparent,
        child: HomeDrawPage(),
      ),
    );
  }

  Widget _buildBottomItem(String title, int index, String imagePath, GlobalKey key) {
    double width = MediaQuery.of(context).size.width / _pages.length;
    Widget child;
    child= Image.asset(
      imagePath,
      width: ScreenUtil().setWidth(36.0),
      height: ScreenUtil().setWidth(36.0),
      fit: BoxFit.cover,
      color: context.watch<PublicProvider>().homeCurrentIndex == index
          ? AppThemeUtils.getColorByKey(
          context, AppThemeKeys.mainBlueColor.name)
          : AppThemeUtils.getColorByKey(
          context, AppThemeKeys.mainTextColor.name),
    );
    /*if(index==4){
      child=Consumer(builder: (context,ChatMessageProvider chatModel,child) {
        int unRead=0;
        if(index == 4){
          unRead=chatModel.unReadMessageUUIDs;
          unRead+=chatModel.haveNewFriend;
        }
        return  badges.Badge(
          showBadge: index == 4 && unRead != 0,
          badgeContent: Text('${unRead}',style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor),
              fontSize: ScreenUtil.getInstance().setSp(20)
          ),),
          child: Image.asset(
            imagePath,
            width: ScreenUtil.getInstance().setWidth(36.0),
            height: ScreenUtil.getInstance().setWidth(36.0),
            fit: BoxFit.cover,
            color: curIndex == index
                ? AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor)
                : (Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white),
          ),
        );
      });
    }else{
      child= Image.asset(
        imagePath,
        width: ScreenUtil.getInstance().setWidth(36.0),
        height: ScreenUtil.getInstance().setWidth(36.0),
        fit: BoxFit.cover,
        color: curIndex == index
            ? AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainBlueColor)
            : (Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white),
      );
    }*/
    return InkWell(
      onTap: () {
        PublicProvider value=Provider.of<PublicProvider>(context,listen: false);
        if (index == value.homeCurrentIndex) return;
        value.setHomeCurrentIndex(index);
        /*
        //tab 埋点
        if (index == 2) {
          //nft home page
          AmplitudeUtils.nftHomePageVisited();
        }*/
      },
      child: Container(
        key: key,
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            Text(
              title,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(20.0),
                height: 1.5,
                color: context.watch<PublicProvider>().homeCurrentIndex == index
                    ? AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name)
                    : AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int pausedTime = 0; //记录切到后台的时间戳
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        MiningBackground().background_end();
        PublicProvider pp=Provider.of<PublicProvider>(context,listen: false);
        if (pp.unlockIsPush == true) return;
        //if (Application.isDebug) return;
        if (pp.lockScreenMap['lock'] == false &&
            pp.lockScreenMap['face'] == false &&
            pp.lockScreenMap['gesture'] == false) {
          return;
        }

        //进入应用时不会触发
        //应用进入前台
        if (pausedTime == 0) return;
        int resumedTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (resumedTime - pausedTime >
            pp.lockScreenMap['lockTime']) {
          //print("resumed 前台弹窗");
          //if (inputPWShow == false) {
          if (Application.userInfo !=null) {
            pausedTime = 0;
            //ProviderUtil.publicProvider().setCheckWalletPassword(false);
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Unlock()));
          } else {
            pausedTime = 0;
          }
        }
        break;
      case AppLifecycleState.inactive:
      //应用处于闲置状态，切换到后台会触发
        break;
      case AppLifecycleState.detached:
      //页面即将退出
        break;
      case AppLifecycleState.paused:
        PublicProvider pp=Provider.of<PublicProvider>(context,listen: false);
      //应用处于不可见状态，后台
        if (pp.unlockIsPush == true) return;
        //if (Application.isDebug) return;
        if (pp.lockScreenMap['lock'] == false &&
            pp.lockScreenMap['face'] == false &&
            pp.lockScreenMap['gesture'] == false) {
          return;
        }
        pausedTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }
}
