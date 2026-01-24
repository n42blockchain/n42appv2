// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 设备安全检测服务
///
/// 检测设备是否 Root/Jailbreak，以及其他安全风险
class DeviceSecurityService {
  static const MethodChannel _channel = MethodChannel('n42appv2/device_security');
  
  static DeviceSecurityService? _instance;
  static DeviceSecurityService get instance => _instance ??= DeviceSecurityService._();
  
  DeviceSecurityService._();

  /// 是否强制在 Debug 模式下也执行检测
  bool _forceCheckInDebug = false;

  /// 设置是否在 Debug 模式下也执行安全检测
  void setForceCheckInDebug(bool force) {
    _forceCheckInDebug = force;
  }

  /// 检测设备是否被 Root/Jailbreak
  ///
  /// 注意: Debug 模式下默认跳过检测，但会记录日志
  /// 可通过 [setForceCheckInDebug] 强制启用
  Future<bool> isDeviceCompromised() async {
    if (kDebugMode && !_forceCheckInDebug) {
      // 在调试模式下记录警告但不阻止
      debugPrint('⚠️ [DeviceSecurity] Debug mode: Root/Jailbreak check skipped');
      debugPrint('⚠️ [DeviceSecurity] Call setForceCheckInDebug(true) to enable in debug');
      return false;
    }

    try {
      if (Platform.isAndroid) {
        return await _checkAndroidRoot();
      } else if (Platform.isIOS) {
        return await _checkiOSJailbreak();
      }
      return false;
    } catch (e) {
      debugPrint('Device security check failed: $e');
      // 安全起见，检测失败时返回 true（可能被攻击）
      return kReleaseMode;
    }
  }

  /// Android Root 检测
  Future<bool> _checkAndroidRoot() async {
    try {
      // 尝试调用原生方法
      final result = await _channel.invokeMethod<bool>('isRooted');
      if (result == true) return true;
    } catch (_) {
      // 如果原生方法不可用，使用 Dart 检测
    }
    
    // Dart 层面的检测
    return _dartAndroidRootCheck();
  }

  /// Dart 层面的 Android Root 检测
  bool _dartAndroidRootCheck() {
    // 检测常见的 Root 文件路径
    final rootIndicators = [
      '/system/app/Superuser.apk',
      '/sbin/su',
      '/system/bin/su',
      '/system/xbin/su',
      '/data/local/xbin/su',
      '/data/local/bin/su',
      '/system/sd/xbin/su',
      '/system/bin/failsafe/su',
      '/data/local/su',
      '/su/bin/su',
      '/system/xbin/daemonsu',
      '/system/etc/init.d/99telecom',
      '/system/app/Busybox.apk',
      '/data/adb/magisk',
      '/sbin/.magisk',
    ];

    for (final path in rootIndicators) {
      try {
        if (File(path).existsSync()) {
          return true;
        }
      } catch (_) {
        // 忽略权限错误
      }
    }

    // 检测 Root 相关的系统属性
    return _checkBuildTags();
  }

  /// 检测 Build Tags
  bool _checkBuildTags() {
    try {
      // 这需要通过 Platform Channel 实现
      // 这里提供框架，实际实现需要原生代码
      return false;
    } catch (_) {
      return false;
    }
  }

  /// iOS Jailbreak 检测
  Future<bool> _checkiOSJailbreak() async {
    try {
      // 尝试调用原生方法
      final result = await _channel.invokeMethod<bool>('isJailbroken');
      if (result == true) return true;
    } catch (_) {
      // 如果原生方法不可用，使用 Dart 检测
    }
    
    // Dart 层面的检测
    return _dartiOSJailbreakCheck();
  }

  /// Dart 层面的 iOS Jailbreak 检测
  bool _dartiOSJailbreakCheck() {
    // 检测常见的 Jailbreak 文件路径
    final jailbreakIndicators = [
      '/Applications/Cydia.app',
      '/Applications/blackra1n.app',
      '/Applications/FakeCarrier.app',
      '/Applications/Icy.app',
      '/Applications/IntelliScreen.app',
      '/Applications/MxTube.app',
      '/Applications/RockApp.app',
      '/Applications/SBSettings.app',
      '/Applications/WinterBoard.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/Library/MobileSubstrate/DynamicLibraries/Veency.plist',
      '/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist',
      '/private/var/lib/apt/',
      '/private/var/lib/cydia',
      '/private/var/mobile/Library/SBSettings/Themes',
      '/private/var/stash',
      '/private/var/tmp/cydia.log',
      '/System/Library/LaunchDaemons/com.ikey.bbot.plist',
      '/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist',
      '/usr/bin/sshd',
      '/usr/libexec/sftp-server',
      '/usr/sbin/sshd',
      '/etc/apt',
      '/bin/bash',
      '/bin/sh',
      '/var/cache/apt',
      '/var/lib/apt',
      '/var/lib/cydia',
      '/var/log/syslog',
      '/var/tmp/cydia.log',
    ];

    for (final path in jailbreakIndicators) {
      try {
        if (File(path).existsSync()) {
          return true;
        }
      } catch (_) {
        // 忽略权限错误
      }
    }

    // 检测是否可以写入受保护的目录
    return _canWriteToRestrictedPath();
  }

  /// 检测是否可以写入受限路径
  bool _canWriteToRestrictedPath() {
    try {
      final testFile = File('/private/test_jailbreak_detection');
      testFile.writeAsStringSync('test');
      testFile.deleteSync();
      return true; // 如果能写入，说明已越狱
    } catch (_) {
      return false; // 正常情况下应该无法写入
    }
  }

  /// 检测是否在模拟器中运行
  ///
  /// 注意: Debug 模式下默认跳过检测
  /// 可通过 [setForceCheckInDebug] 强制启用
  Future<bool> isRunningOnEmulator() async {
    if (kDebugMode && !_forceCheckInDebug) {
      debugPrint('⚠️ [DeviceSecurity] Debug mode: Emulator check skipped');
      return false;
    }

    try {
      final result = await _channel.invokeMethod<bool>('isEmulator');
      return result ?? false;
    } catch (_) {
      return _dartEmulatorCheck();
    }
  }

  /// Dart 层面的模拟器检测
  bool _dartEmulatorCheck() {
    if (Platform.isAndroid) {
      // 检测常见的模拟器特征
      // 这需要通过 Platform Channel 获取 Build 信息
      return false;
    } else if (Platform.isIOS) {
      // iOS 模拟器通常不会在生产环境中遇到
      return false;
    }
    return false;
  }

  /// 检测是否启用了调试器
  Future<bool> isDebuggerAttached() async {
    try {
      final result = await _channel.invokeMethod<bool>('isDebuggerAttached');
      return result ?? false;
    } catch (_) {
      // assert 在 release 模式下会被移除
      bool isDebug = false;
      assert(() {
        isDebug = true;
        return true;
      }());
      return isDebug;
    }
  }

  /// 获取完整的安全状态报告
  Future<DeviceSecurityStatus> getSecurityStatus() async {
    final isCompromised = await isDeviceCompromised();
    final isEmulator = await isRunningOnEmulator();
    final isDebugged = await isDebuggerAttached();

    return DeviceSecurityStatus(
      isRootedOrJailbroken: isCompromised,
      isEmulator: isEmulator,
      isDebuggerAttached: isDebugged,
      isSecure: !isCompromised && !isEmulator && !isDebugged,
    );
  }
}

/// 设备安全状态
class DeviceSecurityStatus {
  final bool isRootedOrJailbroken;
  final bool isEmulator;
  final bool isDebuggerAttached;
  final bool isSecure;

  const DeviceSecurityStatus({
    required this.isRootedOrJailbroken,
    required this.isEmulator,
    required this.isDebuggerAttached,
    required this.isSecure,
  });

  @override
  String toString() {
    return 'DeviceSecurityStatus('
        'isRootedOrJailbroken: $isRootedOrJailbroken, '
        'isEmulator: $isEmulator, '
        'isDebuggerAttached: $isDebuggerAttached, '
        'isSecure: $isSecure)';
  }
}

/// 安全检查失败时的处理选项
enum SecurityViolationAction {
  /// 允许继续，仅警告
  warnAndContinue,
  /// 限制部分功能
  restrictFeatures,
  /// 阻止应用运行
  blockApp,
}

/// 安全策略配置
class SecurityPolicyConfig {
  /// 检测到 Root/Jailbreak 时的处理
  final SecurityViolationAction onRootDetected;
  
  /// 检测到模拟器时的处理
  final SecurityViolationAction onEmulatorDetected;
  
  /// 检测到调试器时的处理
  final SecurityViolationAction onDebuggerDetected;

  const SecurityPolicyConfig({
    this.onRootDetected = SecurityViolationAction.warnAndContinue,
    this.onEmulatorDetected = SecurityViolationAction.warnAndContinue,
    this.onDebuggerDetected = SecurityViolationAction.warnAndContinue,
  });

  /// 生产环境配置
  static const production = SecurityPolicyConfig(
    onRootDetected: SecurityViolationAction.restrictFeatures,
    onEmulatorDetected: SecurityViolationAction.blockApp,
    onDebuggerDetected: SecurityViolationAction.blockApp,
  );

  /// 开发环境配置
  static const development = SecurityPolicyConfig(
    onRootDetected: SecurityViolationAction.warnAndContinue,
    onEmulatorDetected: SecurityViolationAction.warnAndContinue,
    onDebuggerDetected: SecurityViolationAction.warnAndContinue,
  );
}

