import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/debug_log.dart';

/// 系统级集成服务。
///
/// 统一管理各平台原生系统级特性的注册与调用：
/// - **iOS**: ShareExtension / Live Activities / Lock Screen Widgets / Focus Filters
/// - **Android**: Notification Bubbles / QuickShare / Shortcuts / Widgets
/// - **Desktop**: 系统托盘 / 窗口管理 / 全局快捷键
///
/// 通过 MethodChannel 桥接原生代码。宿主需在各平台的 native 工程中
/// 实现对应 handler。
class SystemIntegrationService {
  static const _channel = MethodChannel('com.n42.chat/system_integration');

  /// 注册快捷方式（Android App Shortcuts / iOS Quick Actions）。
  Future<void> registerShortcuts(List<AppShortcut> shortcuts) async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('registerShortcuts', {
        'shortcuts': shortcuts.map((s) => s.toMap()).toList(),
      });
    } catch (e) {
      debugLog('SystemIntegration: registerShortcuts failed - $e');
    }
  }

  /// 更新未读消息角标数。
  Future<void> updateBadgeCount(int count) async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('updateBadgeCount', {'count': count});
    } catch (e) {
      debugLog('SystemIntegration: updateBadgeCount failed - $e');
    }
  }

  /// 启用/禁用 Android Notification Bubbles。
  Future<void> enableBubbles(bool enabled) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('enableBubbles', {'enabled': enabled});
    } catch (e) {
      debugLog('SystemIntegration: enableBubbles failed - $e');
    }
  }

  /// 更新 iOS Live Activity（通话中显示、传输进度等）。
  Future<void> updateLiveActivity({
    required String activityId,
    required Map<String, dynamic> contentState,
  }) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('updateLiveActivity', {
        'activityId': activityId,
        'contentState': contentState,
      });
    } catch (e) {
      debugLog('SystemIntegration: updateLiveActivity failed - $e');
    }
  }

  /// 启动 iOS Live Activity（如通话中状态）。
  Future<String?> startLiveActivity({
    required String type,
    required Map<String, dynamic> attributes,
    required Map<String, dynamic> contentState,
  }) async {
    if (!Platform.isIOS) return null;
    try {
      final result = await _channel.invokeMethod<String>('startLiveActivity', {
        'type': type,
        'attributes': attributes,
        'contentState': contentState,
      });
      return result;
    } catch (e) {
      debugLog('SystemIntegration: startLiveActivity failed - $e');
      return null;
    }
  }

  /// 结束 iOS Live Activity。
  Future<void> endLiveActivity(String activityId) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('endLiveActivity', {
        'activityId': activityId,
      });
    } catch (e) {
      debugLog('SystemIntegration: endLiveActivity failed - $e');
    }
  }

  /// 注册 Android QuickShare 目标。
  Future<void> registerQuickShareTarget({
    required String category,
    required String label,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('registerQuickShareTarget', {
        'category': category,
        'label': label,
      });
    } catch (e) {
      debugLog('SystemIntegration: registerQuickShareTarget failed - $e');
    }
  }

  /// 桌面端：设置系统托盘菜单。
  Future<void> setupSystemTray({
    required String tooltip,
    required List<TrayMenuItem> menuItems,
  }) async {
    if (Platform.isAndroid || Platform.isIOS) return;
    try {
      await _channel.invokeMethod('setupSystemTray', {
        'tooltip': tooltip,
        'menuItems': menuItems.map((m) => m.toMap()).toList(),
      });
    } catch (e) {
      debugLog('SystemIntegration: setupSystemTray failed - $e');
    }
  }

  /// 桌面端：窗口闪烁提示新消息。
  Future<void> flashWindow() async {
    if (Platform.isAndroid || Platform.isIOS) return;
    try {
      await _channel.invokeMethod('flashWindow');
    } catch (e) {
      debugLog('SystemIntegration: flashWindow failed - $e');
    }
  }
}

/// App 快捷方式。
class AppShortcut {
  const AppShortcut({
    required this.id,
    required this.shortLabel,
    this.longLabel,
    this.iconName,
    required this.action,
  });

  final String id;
  final String shortLabel;
  final String? longLabel;
  final String? iconName;
  final String action;

  Map<String, dynamic> toMap() => {
        'id': id,
        'shortLabel': shortLabel,
        'longLabel': longLabel,
        'iconName': iconName,
        'action': action,
      };
}

/// 系统托盘菜单项。
class TrayMenuItem {
  const TrayMenuItem({
    required this.label,
    this.action,
    this.isSeparator = false,
  });

  final String label;
  final String? action;
  final bool isSeparator;

  Map<String, dynamic> toMap() => {
        'label': label,
        'action': action,
        'isSeparator': isSeparator,
      };
}
