part of 'app_push_utils.dart';

/// Push notification navigation routing.
///
/// Extracted from [AppPushUtils] to keep each file under 500 lines.
/// Contains [_handleMessage] and related navigation helpers.
extension _PushNavigation on AppPushUtils {
  ///对消息统一处理
  static void handleMessage(Map<String, dynamic> data) {
    final ctx = AppGlobals.navigatorKey.currentContext;
    if (ctx == null) {
      debugPrint(
        '[AppPushUtils] _handleMessage: navigator context unavailable, skipping',
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

    switch (type) {
      case 'transfer':
      case 'normal_transaction_failed':
        _navigateToTxBrowser(ctx, data);

      case 'tell_friends':
      case 'Tell Friends #1_normal':
      case 'Tell Friends #2_normal':
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => SettingShare()));

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

      case 'AboutSettings_normal':
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => AboutApp()));

      case 'SettingsProfile_normal':
        if (AppGlobals.userInfo != null) {
          Navigator.push(
            ctx,
            MaterialPageRoute(builder: (_) => PersonalSetting()),
          );
        }

      default:
        debugPrint("未知消息类型，无法处理");
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
    debugPrint('Legacy chat notification tapped - routing to n42_chat');
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => N42Chat.chatWidget()),
    );
  }

  /// 解析交易数据并跳转到浏览器查看交易详情
  static void _navigateToTxBrowser(
    BuildContext ctx,
    Map<String, dynamic> data,
  ) {
    Map<String, dynamic> txContent = {};
    try {
      txContent = json.decode(data['data']);
    } catch (_) {
      // JSON 解析失败时使用空 map，安全忽略
    }
    String? isTestStr = txContent['network'];
    bool? isTest;
    if (isTestStr != null) {
      isTest = isTestStr == "test";
    }
    final String bUri = getSafeBrowserTxHashUrl(
      txContent['coin'],
      txContent['hash'],
      isTest: isTest,
    );
    if (bUri.isEmpty) return;
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => BrowserPage(bUri)));
  }

}
