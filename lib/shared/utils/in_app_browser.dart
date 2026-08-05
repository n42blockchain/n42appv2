import 'package:flutter/material.dart';

/// 站内浏览器的导航抽象。
///
/// 解耦点：wallet/news/home 等 feature 打开站内浏览器时不 import
/// `features/browser/pages/browser_page.dart`，而是走这里；真正的页面
/// 构造器由 composition root（`core/app/navigation_wiring.dart`）注册。
/// browser feature 因 DApp 请求处理依赖 wallet，此抽象把
/// wallet→browser 反向边打断，使 wallet↔browser 不再成环。
class InAppBrowser {
  InAppBrowser._();

  static Widget Function(String url)? _pageBuilder;

  /// composition root 注册站内浏览器页面构造器。
  static void registerPageBuilder(Widget Function(String url) builder) {
    _pageBuilder = builder;
  }

  /// 构造站内浏览器页面（供 pushAndClose 等自定义导航辅助使用）。
  static Widget page(String url) {
    final builder = _pageBuilder;
    if (builder == null) {
      throw StateError(
        'InAppBrowser.page: pageBuilder 未注册——'
        'main() 需先调用 registerHostNavigation()',
      );
    }
    return builder(url);
  }

  /// 推入站内浏览器页面。
  static Future<void> open(BuildContext context, String url) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page(url)),
    );
  }

  @visibleForTesting
  static void reset() => _pageBuilder = null;

  @visibleForTesting
  static bool get isRegistered => _pageBuilder != null;
}
