part of 'app_push_utils.dart';

/// Push notification navigation routing.
///
/// Extracted from [AppPushUtils] to keep each file under 500 lines.
/// Contains [handleMessage] and related navigation helpers.
///
/// 跳转到具体 feature 页面的推送类型（transfer/分享/关于/个人设置等）由
/// composition root 通过 [PushRouteRegistry] 注册（见
/// `core/app/push_route_wiring.dart`）；本文件只保留无 feature 依赖的
/// 内置分支（legacy chat、device_login、主 tab 切换）。
extension _PushNavigation on AppPushUtils {
  ///对消息统一处理
  static void handleMessage(Map<String, dynamic> data) {
    final ctx = AppGlobals.navigatorKey.currentContext;
    if (ctx == null) {
      AppLogger.w(
        'AppPush',
        '_handleMessage: navigator context unavailable, skipping',
      );
      return;
    }
    final type = data['type'];
    if (_isLegacyChatNotificationType(type)) {
      _navigateToChatHome(ctx, type);
      return;
    }
    if (AppGlobals.userInfo == null) return;
    if (data['type'] == 'device_login') {
      // 点击设备登录通知打开 App 时，通过 EventBus 触发弹窗
      AppPushUtils._handleDeviceLoginNotification(data);
      return;
    }

    // composition root 注册的 feature 页面路由优先
    final handler = PushRouteRegistry.resolve(type);
    if (handler != null) {
      handler(ctx, data);
      return;
    }

    switch (type) {
      case 'News_normal':
      case 'Login_normal':
      case 'Homepage_normal':
      case 'WalletHome #1_normal':
      case 'WalletHome #2_normal':
        Navigator.of(ctx).popUntil((route) => route.isFirst);
        globalProviderContainer
                .read(mainTabSelectIndexProvider.notifier)
                .state =
            0;

      default:
        AppLogger.w('AppPush', 'unknown message type, cannot handle');
    }
  }

  static bool _isLegacyChatNotificationType(Object? type) {
    return type == 'chat' ||
        type == 'ChatHome #1_normal' ||
        type == 'ChatHome #2_normal' ||
        type == 100 ||
        type == 101 ||
        type == 110;
  }

  static void _navigateToChatHome(BuildContext ctx, Object? type) {
    if (type is int) {
      // 清理老 chat 体系遗留的本地通知 ID，避免重复点击。
      flutterLocalNotificationsPlugin.cancel(id: type);
    }
    AppLogger.d(
      'AppPush',
      'legacy chat notification tapped — routing to n42_chat',
    );
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => N42Chat.chatWidget()),
    );
  }
}
