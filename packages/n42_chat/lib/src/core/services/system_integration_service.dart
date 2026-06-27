import 'package:flutter/services.dart';

import '../utils/debug_log.dart';

/// 系统级集成服务
///
/// 经 MethodChannel `n42.chat/system_integration` 桥接各平台系统能力：
/// - iOS：Live Activities / 锁屏 Widget
/// - Android：Conversation Bubbles / 快捷方式 / 持续通知
/// - Desktop：系统托盘角标 / 窗口闪烁
///
/// **Dart 侧完整**；原生 handler（Kotlin/Swift/桌面）按平台另行实现。**未实现时
/// 所有调用经 [_safeInvoke] 捕获 `MissingPluginException` 优雅 no-op**——不抛错、
/// 不误导为可用，原生接好即生效。
class SystemIntegrationService {
  static const MethodChannel _channel =
      MethodChannel('n42.chat/system_integration');

  Future<T?> _safeInvoke<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      // 原生 handler 未实现：优雅降级
      return null;
    } catch (e) {
      debugLog('SystemIntegrationService.$method failed: $e');
      return null;
    }
  }

  /// 更新进行中活动（iOS Live Activity / Android 持续通知）——通话、上传等
  Future<void> updateLiveActivity({
    required String id,
    required String title,
    String? body,
    Map<String, dynamic>? data,
  }) =>
      _safeInvoke<void>('updateLiveActivity', {
        'id': id,
        'title': title,
        'body': body,
        'data': data,
      });

  /// 结束进行中活动
  Future<void> endLiveActivity(String id) =>
      _safeInvoke<void>('endLiveActivity', {'id': id});

  /// 以会话气泡弹出（Android Conversation Bubble）
  Future<void> showConversationBubble({
    required String roomId,
    required String title,
    String? avatarUrl,
  }) =>
      _safeInvoke<void>('showConversationBubble', {
        'roomId': roomId,
        'title': title,
        'avatarUrl': avatarUrl,
      });

  /// 设置 App 动态快捷方式（Android Shortcuts / iOS Quick Actions）
  Future<void> setDynamicShortcuts(List<Map<String, dynamic>> shortcuts) =>
      _safeInvoke<void>('setDynamicShortcuts', {'shortcuts': shortcuts});

  /// 桌面系统托盘未读角标
  Future<void> setTrayBadge(int count) =>
      _safeInvoke<void>('setTrayBadge', {'count': count});

  /// 桌面窗口闪烁提示（来新消息时）
  Future<void> flashWindow() => _safeInvoke<void>('flashWindow');

  /// 查询某能力是否被当前平台原生支持（默认 false）
  Future<bool> isSupported(String capability) async =>
      (await _safeInvoke<bool>('isSupported', {'capability': capability})) ??
      false;
}
