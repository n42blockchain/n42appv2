import 'dart:async';
import 'dart:io';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/utils/responsive_utils.dart';
import 'package:n42_wallet/features/auth/data/models/device_login_info.dart';
import 'package:n42_wallet/features/mining_v1/pages/mining_home_page.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/device_login_dialog.dart';
import 'package:n42_wallet/features/home/home_draw_page.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_background.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_today_v2.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page.dart';
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
import 'package:n42_wallet/features/earn/pages/earn_page.dart';

part 'home_page_navigation.dart';

/// Home Page - Migrated to Riverpod
///
/// Uses ConsumerStatefulWidget with WidgetsBindingObserver for:
/// - Home tab index via homeTabIndexProvider
/// - App lifecycle management
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
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
      useV2 ? const MiningTodayV2() : const MiningHomePage(),
      if (Platform.isAndroid) const EarnPage(),
      // 行情页（四合一：热门/搜索/自选/新闻）。2026-05-14 曾被误换成纯
      // NewsPage（提交名'restore news localization'却换掉了整页），导致
      // 多内容行情从底部 tab 消失——2026-07-03 恢复。News 功能由页内
      // News tab 覆盖。
      const MarketPage(),
    ];
  }

  /// 跳转到聊天页面（使用 N42Chat 插件）
  void _navigateToChat() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => N42Chat.chatWidget()));
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
      await deviceLoginDialog(context, info);
    } finally {
      _isDeviceLoginDialogShowing = false;
    }
  }

  Future<void> initData() async {
    showTermsOfService = await SPUtil().getShowTermsOfService();
    if (!mounted) return;
    setState(() {});
    if (AppGlobals.userInfo == null) return;

    AppGlobals.login(AppGlobals.userInfo!);

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
    final homeCurrentIndex = ref.watch(homeTabIndexProvider);
    final pages = _buildPages();
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
                  buildNavigationRail(safeIndex),
                  Expanded(
                    child: IndexedStack(index: safeIndex, children: pages),
                  ),
                ],
              )
            else ...[
              // 手机 / iPad 竖屏：保持原有底部导航
              IndexedStack(index: safeIndex, children: pages),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: buildBottomNavBar(context),
              ),
            ],
            if (showTermsOfService == false)
              Positioned.fill(
                child: TermsOfServiceWidget(
                  '${AppConfig.apiUrl['n42Browser']}/static/terms_of_use.html',
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      MiningBackground().backgroundEnd();
    }
  }
}
