import 'dart:async';
import 'dart:ui';

import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/src/chat/pages/chat_index_page.dart';
import 'package:n42appv2/src/chat/widgets/chat_services.dart';
import 'package:n42appv2/src/home/home_draw_page.dart';
import 'package:n42appv2/src/home/unlock.dart';
import 'package:n42appv2/src/miningV2/pages/mining_background.dart';
import 'package:n42appv2/src/miningV2/pages/mining_today_v2.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/pages/wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42_chat/n42_chat.dart';

/// Home Page - Migrated to Riverpod
/// 
/// Uses ConsumerStatefulWidget with WidgetsBindingObserver for:
/// - Home tab index via homeTabIndexProvider
/// - Screen lock state via screenLockProvider
/// - App lifecycle management
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with WidgetsBindingObserver {
  //final GlobalKey _tabOne = GlobalKey();
  final GlobalKey _tabTwo = GlobalKey();
  final GlobalKey _tabThree = GlobalKey();
  final GlobalKey _tabfour = GlobalKey();
  //final GlobalKey _tabfive = GlobalKey();
  bool? showTermsOfService;
  
  /// Build pages list (不包含 Chat，Chat 作为独立页面跳转)
  List<Widget> _buildPages() {
    return [
      const WalletPage(),
      const MiningTodayV2(),
    ];
  }
  
  /// 跳转到聊天页面
  void _navigateToChat() {
    final useNewChat = ref.read(useNewChatProvider);
    if (useNewChat) {
      // 跳转到新的 N42Chat 模块（全屏，有自己的底部 Tab）
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => N42Chat.chatWidget(),
        ),
      );
    } else {
      // 跳转到旧的聊天页面
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ChatIndexPage(),
        ),
      );
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initData();
  }
  initData() async {
    showTermsOfService = await SPUtil().getShowTermsOfService();
    setState(() {});
    if (AppGlobals.userInfo == null) return;
    
    // Use Riverpod screenLockProvider
    final lockState = ref.read(screenLockProvider);
    
    if (lockState.isLocked || lockState.faceEnabled || lockState.gestureEnabled) {
      Timer(const Duration(milliseconds: 500), () async {
        final rData = await Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Unlock()));
        if (rData == true) {
          AppGlobals.login(AppGlobals.userInfo!);
        }
      });
    } else {
      AppGlobals.login(AppGlobals.userInfo!);
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
    // Watch home tab index from Riverpod
    final homeCurrentIndex = ref.watch(homeTabIndexProvider);
    final pages = _buildPages();
    
    // 限制 index 在有效范围内（只有钱包和挖矿两个页面）
    final safeIndex = homeCurrentIndex.clamp(0, pages.length - 1);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: safeIndex,
              children: pages,
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
                    // 钱包
                    _buildBottomItem(
                        S.of(context).g_key_6,
                        0,
                        "assets/home/tabbar/wallet.png",
                        _tabTwo,
                        3), // 总共3个tab
                    // 挖矿
                    _buildBottomItem(
                        S.of(context).g_home_key3,
                        1,
                        "assets/home/tabbar/earn.png",
                        _tabThree,
                        3),
                    // 聊天 - 点击跳转到独立页面
                    _buildChatBottomItem(
                        S.of(context).g_key_squad,
                        "assets/home/tabbar/chat.png",
                        _tabfour,
                        3),
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

  /// 构建聊天 Tab（点击跳转到独立页面）
  Widget _buildChatBottomItem(String title, String imagePath, GlobalKey key, int pagesLength) {
    double width = MediaQuery.of(context).size.width / pagesLength;
    
    // 聊天 tab 始终显示未选中状态（因为它是跳转而不是切换）
    Widget child = Image.asset(
      imagePath,
      width: ScreenUtil().setWidth(36.0),
      height: ScreenUtil().setWidth(36.0),
      fit: BoxFit.cover,
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
    );
    
    return InkWell(
      onTap: _navigateToChat,
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
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomItem(String title, int index, String imagePath, GlobalKey key, int pagesLength) {
    double width = MediaQuery.of(context).size.width / pagesLength;
    // Use Riverpod homeTabIndexProvider
    final currentIndex = ref.watch(homeTabIndexProvider);
    // 限制在有效范围内
    final safeCurrentIndex = currentIndex.clamp(0, 1);
    
    Widget child;
    child = Image.asset(
      imagePath,
      width: ScreenUtil().setWidth(36.0),
      height: ScreenUtil().setWidth(36.0),
      fit: BoxFit.cover,
      color: safeCurrentIndex == index
          ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
          : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
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
        // Use Riverpod homeTabIndexProvider
        if (index == safeCurrentIndex) return;
        ref.read(homeTabIndexProvider.notifier).state = index;
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
                color: safeCurrentIndex == index
                    ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                    : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int pausedTime = 0; // 记录切到后台的时间戳
  bool _unlockIsPush = false;
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    
    // Use Riverpod screenLockProvider
    final lockState = ref.read(screenLockProvider);
    
    switch (state) {
      case AppLifecycleState.resumed:
        MiningBackground().background_end();
        if (_unlockIsPush == true) return;
        
        if (!lockState.isLocked && !lockState.faceEnabled && !lockState.gestureEnabled) {
          return;
        }

        // 进入应用时不会触发
        // 应用进入前台
        if (pausedTime == 0) return;
        int resumedTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (resumedTime - pausedTime > lockState.lockTimeSeconds) {
          if (AppGlobals.userInfo != null) {
            pausedTime = 0;
            await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Unlock()));
          } else {
            pausedTime = 0;
          }
        }
        break;
      case AppLifecycleState.inactive:
        // 应用处于闲置状态，切换到后台会触发
        break;
      case AppLifecycleState.detached:
        // 页面即将退出
        break;
      case AppLifecycleState.paused:
        // 应用处于不可见状态，后台
        if (_unlockIsPush == true) return;
        
        if (!lockState.isLocked && !lockState.faceEnabled && !lockState.gestureEnabled) {
          return;
        }
        pausedTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }
}
