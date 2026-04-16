import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// 平台检测工具类
///
/// 提供跨平台的平台检测功能
class PlatformUtils {
  PlatformUtils._();

  /// 是否是 Web 平台
  static bool get isWeb => kIsWeb;

  /// 是否是移动平台（iOS 或 Android）
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  /// 是否是桌面平台（macOS、Windows 或 Linux）
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  /// 是否是 iOS
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// 是否是 Android
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// 是否是 macOS
  static bool get isMacOS {
    if (kIsWeb) return false;
    return Platform.isMacOS;
  }

  /// 是否是 Windows
  static bool get isWindows {
    if (kIsWeb) return false;
    return Platform.isWindows;
  }

  /// 是否是 Linux
  static bool get isLinux {
    if (kIsWeb) return false;
    return Platform.isLinux;
  }

  /// 获取平台名称
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// 获取平台类型
  static PlatformType get platformType {
    if (kIsWeb) return PlatformType.web;
    if (Platform.isIOS) return PlatformType.ios;
    if (Platform.isAndroid) return PlatformType.android;
    if (Platform.isMacOS) return PlatformType.macos;
    if (Platform.isWindows) return PlatformType.windows;
    if (Platform.isLinux) return PlatformType.linux;
    return PlatformType.unknown;
  }

  /// 是否支持系统托盘（桌面平台）
  static bool get supportsSystemTray => isDesktop;

  /// 是否支持多窗口
  static bool get supportsMultiWindow => isDesktop;

  /// 是否支持原生通知
  static bool get supportsNativeNotifications => !isWeb;

  /// 是否支持文件系统访问
  static bool get supportsFileSystem => !isWeb;

  /// 是否支持后台服务
  static bool get supportsBackgroundService => isMobile;

  /// 是否支持 CallKit（iOS 来电界面）
  static bool get supportsCallKit => isIOS;

  /// 是否支持 ConnectionService（Android 来电界面）
  static bool get supportsConnectionService => isAndroid;

  /// 是否支持生物识别
  static bool get supportsBiometrics => isMobile || isMacOS;

  /// 是否支持 WebRTC
  static bool get supportsWebRTC => true; // 所有平台都支持

  /// 是否支持推送通知
  static bool get supportsPushNotifications => isMobile;

  /// 是否需要响应式布局（大屏幕）
  static bool get needsResponsiveLayout => isDesktop || isWeb;
}

/// 平台类型枚举
enum PlatformType {
  web,
  ios,
  android,
  macos,
  windows,
  linux,
  unknown,
}
