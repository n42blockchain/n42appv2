import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/debug_log.dart';

/// 截图防护服务
///
/// Android: 通过 FLAG_SECURE 阻止截图和录屏。
/// iOS: 通过 MethodChannel 调用原生代码设置隐私保护覆盖层，
///       并监听 UIApplicationUserDidTakeScreenshotNotification。
class ScreenshotProtectionService {
  static const _prefKey = 'screenshot_protection_enabled';
  static const _channel = MethodChannel('ai.n42.www/window_flags');

  static ScreenshotProtectionService? _instance;

  static ScreenshotProtectionService get instance {
    _instance ??= ScreenshotProtectionService._();
    return _instance!;
  }

  ScreenshotProtectionService._();

  bool _globalEnabled = false;

  /// 全局截图防护是否开启（用户设置）
  bool get isGlobalEnabled => _globalEnabled;

  /// 读取持久化设置，并在 Android 上同步应用
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _globalEnabled = prefs.getBool(_prefKey) ?? false;
    if (_globalEnabled) {
      await _applyFlag(true);
    }
  }

  /// 更改用户设置并持久化
  Future<void> setEnabled(bool enabled) async {
    if (_globalEnabled == enabled) return;
    _globalEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
    await _applyFlag(enabled);
  }

  /// 为当前会话临时启用（不修改用户设置），用于 E2E 聊天进入时
  Future<void> enableForSession() async {
    if (!_globalEnabled) {
      await _applyFlag(true);
    }
  }

  /// 退出临时会话后恢复到用户设置状态
  Future<void> restoreDefault() async {
    await _applyFlag(_globalEnabled);
  }

  Future<void> _applyFlag(bool enable) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod<void>('setFlagSecure', enable);
      } catch (e) {
        debugLog('ScreenshotProtectionService: Failed to apply FLAG_SECURE: $e');
      }
    } else if (Platform.isIOS) {
      try {
        await _channel.invokeMethod<void>('setScreenProtection', enable);
      } catch (e) {
        debugLog('ScreenshotProtectionService: Failed to apply iOS screen protection: $e');
      }
    }
  }
}
