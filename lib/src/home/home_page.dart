import 'dart:async';

import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/core/utils/responsive_utils.dart';
import 'package:n42appv2/data/models/device_login_info.dart';
import 'package:n42appv2/src/login/pages/change_password_page.dart';
import 'package:n42appv2/src/widgets/dialog_widget/device_login_dialog.dart';
import 'package:n42appv2/src/home/home_draw_page.dart';
import 'package:n42appv2/src/home/unlock.dart';
import 'package:n42appv2/src/miningV2/pages/mining_background.dart';
import 'package:n42appv2/src/miningV2/pages/mining_today_v2.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/pages/wallet_page.dart';
import 'package:n42appv2/src/earn/pages/earn_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42appv2/src/widgets/terms_of_service_widget.dart';

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
  final GlobalKey _tabTwo = GlobalKey();
  final GlobalKey _tabThree = GlobalKey();
  final GlobalKey _tabFour = GlobalKey();
  final GlobalKey _tabFive = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool? showTermsOfService;
  StreamSubscription? _deviceLoginSubscription;
  bool _isDeviceLoginDialogShowing = false;
  
  /// Build pages list (不包含 Chat，Chat 作为独立页面跳转)
  List<Widget> _buildPages() {
    return [
      const WalletPage(),
      const MiningTodayV2(),
      const EarnPage(),
    ];
  }

  /// 跳转到聊天页面（使用 N42Chat 插件）
  void _navigateToChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => N42Chat.chatWidget(),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenDeviceLogin();
    initData();
  }

  void _listenDeviceLogin() {
    _deviceLoginSubscription = eventBus.on<EventPublic>().listen((event) {
      if (event.type == EventPublicType.deviceLoginDetected &&
          event.param is DeviceLoginInfo &&
          !_isDeviceLoginDialogShowing &&
          mounted) {
        _showDeviceLoginDialog(event.param as DeviceLoginInfo);
      }
    });
  }

  Future<void> _showDeviceLoginDialog(DeviceLoginInfo info) async {
    _isDeviceLoginDialogShowing = true;
    try {
      final result = await deviceLoginDialog(context, info);
      if (result == true && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
        );
      }
    } finally {
      _isDeviceLoginDialogShowing = false;
    }
  }
  Future<void> initData() async {
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
    _deviceLoginSubscription?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Watch home tab index from Riverpod
    final homeCurrentIndex = ref.watch(homeTabIndexProvider);
    final pages = _buildPages();

    // 限制 index 在有效范围内
    final safeIndex = homeCurrentIndex.clamp(0, pages.length - 1);

    final useSideNav = ResponsiveUtils.useSideNavigation(context);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            if (useSideNav)
              // iPad 横屏：使用 NavigationRail + 内容区域
              Row(
                children: [
                  _buildNavigationRail(safeIndex),
                  Expanded(
                    child: IndexedStack(
                      index: safeIndex,
                      children: pages,
                    ),
                  ),
                ],
              )
            else ...[
              // 手机 / iPad 竖屏：保持原有底部导航
              IndexedStack(
                index: safeIndex,
                children: pages,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomNavBar(context),
              ),
            ],
            if(showTermsOfService==false)
              Positioned.fill(
                child: TermsOfServiceWidget(
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

  /// iPad 横屏侧边导航栏
  Widget _buildNavigationRail(int currentIndex) {
    final selectedColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final unselectedColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);

    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index < 3) {
          ref.read(homeTabIndexProvider.notifier).state = index;
        } else {
          _navigateToChat();
        }
      },
      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      selectedIconTheme: IconThemeData(color: selectedColor),
      unselectedIconTheme: IconThemeData(color: unselectedColor),
      labelType: NavigationRailLabelType.all,
      leading: InkWell(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Image.asset(
            "assets/img/menu.png",
            width: 24,
            color: selectedColor,
          ),
        ),
      ),
      destinations: [
        NavigationRailDestination(
          icon: Image.asset("assets/home/tabbar/wallet.png", width: 22, height: 22, color: unselectedColor),
          selectedIcon: Image.asset("assets/home/tabbar/wallet.png", width: 22, height: 22, color: selectedColor),
          label: Text(S.of(context).g_key_6),
        ),
        NavigationRailDestination(
          icon: Image.asset("assets/home/setting/mining.png", width: 22, height: 22, color: unselectedColor),
          selectedIcon: Image.asset("assets/home/setting/mining.png", width: 22, height: 22, color: selectedColor),
          label: Text(S.of(context).g_home_key3),
        ),
        NavigationRailDestination(
          icon: Image.asset("assets/home/tabbar/earn.png", width: 22, height: 22, color: unselectedColor),
          selectedIcon: Image.asset("assets/home/tabbar/earn.png", width: 22, height: 22, color: selectedColor),
          label: const Text('Earn'),
        ),
        NavigationRailDestination(
          icon: Image.asset("assets/home/tabbar/chat.png", width: 22, height: 22, color: unselectedColor),
          selectedIcon: Image.asset("assets/home/tabbar/chat.png", width: 22, height: 22, color: selectedColor),
          label: Text(S.of(context).g_key_squad),
        ),
      ],
    );
  }

  /// 底部导航栏（手机和 iPad 竖屏）
  Widget _buildBottomNavBar(BuildContext context) {
    final isWide = ResponsiveUtils.isTablet(context);
    // iPad 竖屏：使用固定高度，不依赖 ScreenUtil
    final barHeight = isWide ? 56.0 : ScreenUtil().setWidth(100.0);
    final iconSize = isWide ? 22.0 : ScreenUtil().setWidth(36.0);
    final fontSize = isWide ? 11.0 : ScreenUtil().setSp(20.0);
    final borderWidth = isWide ? 0.5 : ScreenUtil().setWidth(1.0);

    return Container(
      width: double.infinity,
      height: barHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
              width: borderWidth,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name)),
        ),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBottomItem(
              S.of(context).g_key_6, 0, "assets/home/tabbar/wallet.png",
              _tabTwo, 4,
              fixedIconSize: isWide ? iconSize : null,
              fixedFontSize: isWide ? fontSize : null),
          _buildBottomItem(
              S.of(context).g_home_key3, 1, "assets/home/setting/mining.png",
              _tabThree, 4,
              fixedIconSize: isWide ? iconSize : null,
              fixedFontSize: isWide ? fontSize : null),
          _buildBottomItem(
              'Earn', 2, "assets/home/tabbar/earn.png",
              _tabFour, 4,
              fixedIconSize: isWide ? iconSize : null,
              fixedFontSize: isWide ? fontSize : null),
          _buildChatBottomItem(
              S.of(context).g_key_squad, "assets/home/tabbar/chat.png",
              _tabFive, 4,
              fixedIconSize: isWide ? iconSize : null,
              fixedFontSize: isWide ? fontSize : null),
        ],
      ),
    );
  }

  /// 构建聊天 Tab（点击跳转到独立页面）
  Widget _buildChatBottomItem(String title, String imagePath, GlobalKey key, int pagesLength,
      {double? fixedIconSize, double? fixedFontSize}) {
    double width = MediaQuery.of(context).size.width / pagesLength;
    final iSize = fixedIconSize ?? ScreenUtil().setWidth(36.0);
    final fSize = fixedFontSize ?? ScreenUtil().setSp(20.0);

    // 聊天 tab 始终显示未选中状态（因为它是跳转而不是切换）
    Widget child = Image.asset(
      imagePath,
      width: iSize,
      height: iSize,
      fit: BoxFit.cover,
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
    );

    return InkWell(
      onTap: _navigateToChat,
      child: SizedBox(
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
                fontSize: fSize,
                height: 1.5,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomItem(String title, int index, String imagePath, GlobalKey key, int pagesLength,
      {double? fixedIconSize, double? fixedFontSize}) {
    double width = MediaQuery.of(context).size.width / pagesLength;
    // Use Riverpod homeTabIndexProvider
    final currentIndex = ref.watch(homeTabIndexProvider);
    final iSize = fixedIconSize ?? ScreenUtil().setWidth(36.0);
    final fSize = fixedFontSize ?? ScreenUtil().setSp(20.0);

    Widget child = Image.asset(
      imagePath,
      width: iSize,
      height: iSize,
      fit: BoxFit.cover,
      color: currentIndex == index
          ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
          : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
    );
    return InkWell(
      onTap: () {
        // Use Riverpod homeTabIndexProvider
        if (index == currentIndex) return;
        ref.read(homeTabIndexProvider.notifier).state = index;
      },
      child: SizedBox(
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
                fontSize: fSize,
                height: 1.5,
                color: currentIndex == index
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
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    
    // Use Riverpod screenLockProvider
    final lockState = ref.read(screenLockProvider);
    
    switch (state) {
      case AppLifecycleState.resumed:
        MiningBackground().backgroundEnd();

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
