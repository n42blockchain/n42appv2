import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/main.dart' show globalProviderContainer;
import 'package:n42appv2/shared/domain/entities/wallet_info.dart';
import 'package:n42appv2/src/utils/sp_util.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/data/models/user_info.dart';
import 'package:provider/provider.dart';

/// Legacy Application class - 已部分迁移到 Riverpod
/// 
/// 保留此类以兼容旧代码，新代码应使用 AppGlobals 和 Riverpod
@Deprecated('Use AppGlobals and Riverpod providers instead')
class Application {
  static late BuildContext AppContext;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  static UserInfo? userInfo;
  static int currentId = 0;
  
  /// 用户登录
  static Future login(UserInfo info) async {
    userInfo = info;
    // 更新 Riverpod 状态
    globalProviderContainer.read(currentUserProvider.notifier).setUser(
      SharedUserInfo.fromLegacyUserInfo(info),
    );
    // 刷新钱包列表
    globalProviderContainer.invalidate(walletListProvider);
    // 通过 Legacy Provider 初始化钱包
    Provider.of<WalletActionProvider>(AppContext, listen: false).init_wallet(initCoinInfo: true);
    Provider.of<WalletConnectProvider>(AppContext, listen: false).cleannData_loginout();
  }
  
  /// 用户退出
  static Future logout() async {
    try {
      await SPUtil().saveUserInfo(null);
      Application.userInfo = null;
      // 清除 Riverpod 状态
      globalProviderContainer.read(currentUserProvider.notifier).clearUser();
      globalProviderContainer.invalidate(walletListProvider);
      // 通过 Legacy Provider 清理
      if (!AppContext.mounted) return;
      Provider.of<WalletActionProvider>(AppContext, listen: false).init_wallet();
      Provider.of<WalletConnectProvider>(AppContext, listen: false).cleannData_loginout();
    } catch (err) {
      debugPrint('Logout error: $err');
    }
  }
}