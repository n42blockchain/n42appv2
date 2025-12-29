import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../security/secure_storage.dart';

/// 全局 Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 路由路径常量
abstract class RoutePaths {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String wallet = '/wallet';
  static const String walletDetail = '/wallet/:address';
  static const String walletCreate = '/wallet/create';
  static const String walletImport = '/wallet/import';
  static const String mining = '/mining';
  static const String chat = '/chat';
  static const String chatDetail = '/chat/:conversationId';
  static const String settings = '/settings';
  static const String security = '/settings/security';
  static const String profile = '/profile';
  static const String browser = '/browser';
}

/// 路由名称常量
abstract class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String home = 'home';
  static const String wallet = 'wallet';
  static const String walletDetail = 'walletDetail';
  static const String walletCreate = 'walletCreate';
  static const String walletImport = 'walletImport';
  static const String mining = 'mining';
  static const String chat = 'chat';
  static const String chatDetail = 'chatDetail';
  static const String settings = 'settings';
  static const String security = 'security';
  static const String profile = 'profile';
  static const String browser = 'browser';
}

/// 应用路由配置
/// 
/// 使用 go_router 实现声明式路由
class AppRouter {
  /// 路由实例
  late final GoRouter router;
  
  /// 当前路由路径
  String get currentPath => router.routeInformationProvider.value.uri.path;

  AppRouter() {
    router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: RoutePaths.splash,
      debugLogDiagnostics: true,
      redirect: _handleRedirect,
      routes: _routes,
      errorBuilder: _errorBuilder,
      observers: [AppRouteObserver()],
    );
  }

  /// 路由重定向逻辑
  Future<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final secureStorage = getIt<SecureStorage>();
    final isLoggedIn = await secureStorage.hasCredentials();
    
    final isAuthRoute = state.matchedLocation == RoutePaths.login ||
        state.matchedLocation == RoutePaths.register;
    final isSplashRoute = state.matchedLocation == RoutePaths.splash;

    // Splash 页面不重定向
    if (isSplashRoute) return null;

    // 未登录且不在认证页面，重定向到登录
    if (!isLoggedIn && !isAuthRoute) {
      return RoutePaths.login;
    }

    // 已登录且在认证页面，重定向到首页
    if (isLoggedIn && isAuthRoute) {
      return RoutePaths.home;
    }

    return null;
  }

  /// 路由配置
  List<RouteBase> get _routes => [
    // Splash
    GoRoute(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      builder: (context, state) => const _PlaceholderPage(title: 'Splash'),
    ),
    
    // 认证相关
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      builder: (context, state) => const _PlaceholderPage(title: 'Login'),
    ),
    GoRoute(
      path: RoutePaths.register,
      name: RouteNames.register,
      builder: (context, state) => const _PlaceholderPage(title: 'Register'),
    ),
    
    // 主页（带底部导航）
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _MainShell(navigationShell: navigationShell);
      },
      branches: [
        // 钱包分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.wallet,
              name: RouteNames.wallet,
              builder: (context, state) => 
                  const _PlaceholderPage(title: 'Wallet'),
              routes: [
                GoRoute(
                  path: 'create',
                  name: RouteNames.walletCreate,
                  builder: (context, state) => 
                      const _PlaceholderPage(title: 'Create Wallet'),
                ),
                GoRoute(
                  path: 'import',
                  name: RouteNames.walletImport,
                  builder: (context, state) => 
                      const _PlaceholderPage(title: 'Import Wallet'),
                ),
                GoRoute(
                  path: ':address',
                  name: RouteNames.walletDetail,
                  builder: (context, state) {
                    final address = state.pathParameters['address']!;
                    return _PlaceholderPage(title: 'Wallet: $address');
                  },
                ),
              ],
            ),
          ],
        ),
        
        // 挖矿分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.mining,
              name: RouteNames.mining,
              builder: (context, state) => 
                  const _PlaceholderPage(title: 'Mining'),
            ),
          ],
        ),
        
        // 聊天分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.chat,
              name: RouteNames.chat,
              builder: (context, state) => 
                  const _PlaceholderPage(title: 'Chat'),
              routes: [
                GoRoute(
                  path: ':conversationId',
                  name: RouteNames.chatDetail,
                  builder: (context, state) {
                    final id = state.pathParameters['conversationId']!;
                    return _PlaceholderPage(title: 'Chat: $id');
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    
    // 设置
    GoRoute(
      path: RoutePaths.settings,
      name: RouteNames.settings,
      builder: (context, state) => const _PlaceholderPage(title: 'Settings'),
      routes: [
        GoRoute(
          path: 'security',
          name: RouteNames.security,
          builder: (context, state) => 
              const _PlaceholderPage(title: 'Security'),
        ),
      ],
    ),
    
    // 个人资料
    GoRoute(
      path: RoutePaths.profile,
      name: RouteNames.profile,
      builder: (context, state) => const _PlaceholderPage(title: 'Profile'),
    ),
    
    // 浏览器
    GoRoute(
      path: RoutePaths.browser,
      name: RouteNames.browser,
      builder: (context, state) {
        final url = state.uri.queryParameters['url'];
        return _PlaceholderPage(title: 'Browser: ${url ?? ""}');
      },
    ),
  ];

  /// 错误页面构建器
  Widget _errorBuilder(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('无法找到页面: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 路由观察者
class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('Route pushed: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('Route popped: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    debugPrint('Route replaced: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
  }
}

/// 主页 Shell（带底部导航栏）
class _MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _MainShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: '钱包',
          ),
          NavigationDestination(
            icon: Icon(Icons.flash_on_outlined),
            selectedIcon: Icon(Icons.flash_on),
            label: '挖矿',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: '消息',
          ),
        ],
      ),
    );
  }
}

/// 占位页面（用于演示路由结构）
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text('此页面待迁移'),
          ],
        ),
      ),
    );
  }
}

/// 路由扩展方法
extension GoRouterExtension on BuildContext {
  /// 导航到钱包详情
  void goToWalletDetail(String address) {
    go('${RoutePaths.wallet}/$address');
  }

  /// 导航到聊天详情
  void goToChatDetail(String conversationId) {
    go('${RoutePaths.chat}/$conversationId');
  }

  /// 导航到浏览器
  void goToBrowser(String url) {
    go('${RoutePaths.browser}?url=${Uri.encodeComponent(url)}');
  }

  /// 返回首页并清空栈
  void goHomeAndClear() {
    go(RoutePaths.wallet);
  }
}

