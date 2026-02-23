import 'dart:async';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/utils/responsive_utils.dart';
import 'package:n42_wallet/data/models/device_login_info.dart';
import 'package:n42_wallet/features/login/pages/change_password_page.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/device_login_dialog.dart';
import 'package:n42_wallet/features/home/home_draw_page.dart';
import 'package:n42_wallet/features/home/unlock.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_background.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_today_v2.dart';
import 'package:n42_wallet/features/mining_v1/pages/mining_index.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page.dart';
import 'package:n42_wallet/features/earn/pages/earn_page.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42_wallet/features/widgets/terms_of_service_widget.dart';
import 'package:n42_wallet/features/home/api/version_api.dart';
import 'package:n42_wallet/features/home/widgets/check_version_alert.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  final GlobalKey _tabSix = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool? showTermsOfService;
  StreamSubscription? _deviceLoginSubscription;
  bool _isDeviceLoginDialogShowing = false;
  
  /// Build pages list (不包含 Chat，Chat 作为独立页面跳转)
  List<Widget> _buildPages() {
    final useV2 = ref.watch(miningUseV2Provider);
    return [
      const WalletPage(),
      useV2 ? const MiningTodayV2() : const MiningIndex(),
      const EarnPage(),
      const MarketPage(),
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

    final lockState = ref.read(screenLockProvider);
    final hasLock =
        lockState.isLocked || lockState.faceEnabled || lockState.gestureEnabled;

    if (hasLock) {
      // 检查跨进程持久化的后台时间戳，判断是否真正超时
      // 场景：OS 将应用在后台杀死后冷重启，此时 didChangeAppLifecycleState
      // 不会再触发，但我们在 hidden/paused 时已经持久化了 pausedAt。
      final storedPausedAt = await SPUtil().getPausedAt();
      bool shouldLock;
      if (storedPausedAt != null) {
        final elapsed =
            DateTime.now().millisecondsSinceEpoch ~/ 1000 - storedPausedAt;
        // elapsed < 0 说明系统时间被调后了，保守处理：触发锁屏
        shouldLock = elapsed < 0 || elapsed >= lockState.lockTimeSeconds;
      } else {
        // 没有持久化时间戳（首次启动 / 上次正常退出）→ 触发锁屏
        shouldLock = true;
      }
      // 无论是否锁屏，清理旧时间戳，避免下次冷启动使用过期数据
      await SPUtil().clearPausedAt();
      pausedTime = 0;

      if (shouldLock) {
        Timer(const Duration(milliseconds: 500), () async {
          if (!mounted) return;
          final rData = await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const Unlock()));
          if (rData == true && mounted) {
            AppGlobals.login(AppGlobals.userInfo!);
          }
        });
      } else {
        AppGlobals.login(AppGlobals.userInfo!);
      }
    } else {
      AppGlobals.login(AppGlobals.userInfo!);
    }

    // 启动后延迟 2 秒检查版本更新，避免阻塞主界面渲染
    Future.delayed(const Duration(seconds: 2), _checkVersionOnStartup);
  }

  /// 冷启动版本检查。
  /// - 强制更新（isForce=true）：弹出不可关闭的对话框，用户必须更新才能继续使用。
  /// - 可选更新：静默（不弹窗），让用户在 About 页面主动查看。
  Future<void> _checkVersionOnStartup() async {
    if (!AppConfig.isOpenAppUpdate || !mounted) return;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final versionInfo = await VersionApi().getVersionInfo();
      if (versionInfo == null || !mounted) return;

      final serverCode = versionInfo.versionCode;
      final localCode = int.tryParse(packageInfo.buildNumber) ?? 0;
      if (serverCode == null || serverCode <= localCode) return;

      // 仅在强制更新时主动弹窗；可选更新让用户自行去 About 页查看
      if (versionInfo.isForce != true) return;

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false, // 强制更新不允许点外部关闭
        builder: (_) => CheckVersionAlert(
          newVersion: versionInfo.versionName ?? '',
          updateTitle: versionInfo.updateTitle ?? '',
          introduction: versionInfo.updateContent ?? '',
          isForce: 1,
          downloadUrl: versionInfo.downloadUrl,
        ),
      );
    } catch (_) {
      // 版本检查失败绝不 crash App
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
        if (index < 4) {
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
          icon: Image.asset("assets/home/tabbar/news.png", width: 22, height: 22, color: unselectedColor),
          selectedIcon: Image.asset("assets/home/tabbar/news.png", width: 22, height: 22, color: selectedColor),
          label: const Text('Market'),
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
              _tabTwo, 5,
              fixedIconSize: isWide ? iconSize : null,
              fixedFontSize: isWide ? fontSize : null),
          _buildBottomItem(
              S.of(context).g_home_key3, 1, "assets/home/setting/mining.png",
              _tabThree, 5,
              fixedIconSize: isWide ? iconSize : null,
              fixedFontSize: isWide ? fontSize : null),
          _buildBottomItem(
              'Earn', 2, "assets/home/tabbar/earn.png",
              _tabFour, 5,
              fixedIconSize: isWide ? iconSize : null,
              fixedFontSize: isWide ? fontSize : null),
          _buildBottomItem(
              'Market', 3, "assets/home/tabbar/news.png",
              _tabSix, 5,
              fixedIconSize: isWide ? iconSize : null,
              fixedFontSize: isWide ? fontSize : null),
          _buildChatBottomItem(
              S.of(context).g_key_squad, "assets/home/tabbar/chat.png",
              _tabFive, 5,
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

  // ── 后台计时 ──────────────────────────────────────────────────────────────
  //
  // pausedTime：内存中的后台开始时间戳（秒），应用正常在前后台切换时使用。
  // SPUtil.setPausedAt：持久化版本，跨进程重启后仍可读取（应对 OS 杀进程场景）。
  //
  // 记录时机：hidden（iOS 在被杀前的最后事件）+ paused（Android / iOS 正常后台）。
  // 清除时机：resumed（前台恢复后清除，无论是否触发锁屏）。
  int pausedTime = 0;

  /// 记录进入后台时间戳（内存 + 持久化双写）。
  void _recordPausedTimestamp() {
    final lockState = ref.read(screenLockProvider);
    if (!lockState.isLocked &&
        !lockState.faceEnabled &&
        !lockState.gestureEnabled) {
      return;
    }
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    pausedTime = ts;
    // 持久化：应对 OS 在后台杀死进程后冷重启的场景
    // 使用 unawaited 写法，避免阻塞 lifecycle callback
    SPUtil().setPausedAt(ts);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    final lockState = ref.read(screenLockProvider);

    switch (state) {
      case AppLifecycleState.resumed:
        MiningBackground().backgroundEnd();

        if (!lockState.isLocked &&
            !lockState.faceEnabled &&
            !lockState.gestureEnabled) {
          // 无锁屏配置 → 清理可能遗留的时间戳并退出
          pausedTime = 0;
          await SPUtil().clearPausedAt();
          break;
        }

        // 优先使用内存时间戳；若为 0（进程重启场景），读取持久化值
        int effectivePausedTime = pausedTime;
        if (effectivePausedTime == 0) {
          final stored = await SPUtil().getPausedAt();
          effectivePausedTime = stored ?? 0;
        }

        // 清理时间戳（无论是否触发锁屏，避免下次误判）
        pausedTime = 0;
        await SPUtil().clearPausedAt();

        if (effectivePausedTime == 0) break; // 没有有效的后台起始时间

        final resumedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final elapsed = resumedAt - effectivePausedTime;
        // elapsed < 0：系统时钟被往前调了 → 保守处理，触发锁屏
        if ((elapsed < 0 || elapsed >= lockState.lockTimeSeconds) &&
            AppGlobals.userInfo != null &&
            mounted) {
          await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const Unlock()));
        }
        break;

      case AppLifecycleState.inactive:
        // inactive 在 iOS 通知栏下拉、接听电话时也会触发，
        // 不在此记录时间戳，避免误触发。
        break;

      case AppLifecycleState.hidden:
        // iOS：hidden 在 paused 之前触发，是 OS 杀进程前的最后状态。
        // 在此记录时间戳，确保即使进程被杀也留有记录。
        _recordPausedTimestamp();
        break;

      case AppLifecycleState.paused:
        // Android & iOS 正常后台：在此再次写入（覆盖 hidden 的值，时间更精确）。
        _recordPausedTimestamp();
        break;

      case AppLifecycleState.detached:
        break;
    }
  }
}
