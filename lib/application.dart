import 'package:flutter/material.dart';

import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/data/models/user_info.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/main.dart' show globalProviderContainer;
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';

import 'package:n42_wallet/core/security/secure_storage.dart';

/// Legacy Application class - 已部分迁移到 Riverpod
///
/// 保留此类以兼容旧代码，新代码应使用 AppGlobals 和 Riverpod
@Deprecated('Use AppGlobals and Riverpod providers instead')
class Application {
  // ignore: non_constant_identifier_names
  static late BuildContext AppContext;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  static UserInfo? userInfo;
  static int currentId = 0;

  /// 用户登录
  static Future<void> login(UserInfo info) async {
    userInfo = info;
    globalProviderContainer
        .read(currentUserProvider.notifier)
        .setUser(SharedUserInfo.fromLegacyUserInfo(info));
    globalProviderContainer.invalidate(walletListProvider);
    globalWapAdapter.initWallet(shouldInitCoinInfo: true);
    globalWcpInstance.cleanDataLogout();
  }

  /// 用户退出
  static Future<void> logout() async {
    try {
      await Future.wait([
        SPUtil().saveUserInfo(null),
        SecureStorage().clearUserData(),
      ]);
      userInfo = null;
      globalProviderContainer.read(currentUserProvider.notifier).clearUser();
      globalProviderContainer.invalidate(walletListProvider);
      globalWapAdapter.initWallet();
      globalWcpInstance.cleanDataLogout();
    } catch (err) {
      assert(() {
        debugPrint('Logout error: $err');
        return true;
      }());
    }
  }
}
