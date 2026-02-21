// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:io';

import 'package:flutter/foundation.dart';

/// 安全违规响应动作
enum SecurityViolationAction {
  warnAndContinue,
  restrictFeatures,
  blockApp,
}

/// 设备安全状态快照
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

/// 安全策略配置
class SecurityPolicyConfig {
  final SecurityViolationAction onRootDetected;
  final SecurityViolationAction onEmulatorDetected;
  final SecurityViolationAction onDebuggerDetected;

  const SecurityPolicyConfig({
    required this.onRootDetected,
    required this.onEmulatorDetected,
    required this.onDebuggerDetected,
  });

  /// 生产环境策略：Root/越狱限制功能，模拟器/调试器阻断应用
  static const SecurityPolicyConfig production = SecurityPolicyConfig(
    onRootDetected: SecurityViolationAction.restrictFeatures,
    onEmulatorDetected: SecurityViolationAction.blockApp,
    onDebuggerDetected: SecurityViolationAction.blockApp,
  );

  /// 开发环境策略：所有违规仅警告，不影响调试流程
  static const SecurityPolicyConfig development = SecurityPolicyConfig(
    onRootDetected: SecurityViolationAction.warnAndContinue,
    onEmulatorDetected: SecurityViolationAction.warnAndContinue,
    onDebuggerDetected: SecurityViolationAction.warnAndContinue,
  );
}

/// 设备安全检测服务
///
/// 在调试/测试模式下所有检测均返回安全值，避免影响开发效率。
/// 在 release 模式下实施基于文件系统的真实完整性检查（无需额外依赖）。
class DeviceSecurityService {
  static DeviceSecurityService? _instance;

  DeviceSecurityService._();

  static DeviceSecurityService get instance {
    _instance ??= DeviceSecurityService._();
    return _instance!;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Root / Jailbreak detection
  // ────────────────────────────────────────────────────────────────────────

  /// 检测设备是否已 Root（Android）或越狱（iOS）。
  ///
  /// 实现策略：
  /// - 调试模式始终返回 `false`（避免在开发设备上被误拦截）
  /// - Release 模式通过文件系统特征判断（无需额外 pub 依赖）
  ///
  /// 注意：文件检测是必要条件判断，可能出现漏报（false negative），
  /// 但不会出现误报（false positive），适合生产安全策略。
  Future<bool> isDeviceCompromised() async {
    if (kDebugMode) return false;
    try {
      if (Platform.isAndroid) return _isAndroidRooted();
      if (Platform.isIOS) return _isIosJailbroken();
    } catch (_) {
      // 文件系统访问异常：保守返回 false，避免误拦截
    }
    return false;
  }

  /// Android Root 检测 — 检查常见 su 二进制和 root 管理器 APK 路径。
  bool _isAndroidRooted() {
    const List<String> rootPaths = [
      // su binary locations
      '/system/xbin/su',
      '/system/bin/su',
      '/data/local/xbin/su',
      '/data/local/bin/su',
      '/sbin/su',
      '/su/bin/su',
      '/system/sd/xbin/su',
      '/system/bin/failsafe/su',
      '/data/local/su',
      // Root management apps
      '/system/app/Superuser.apk',
      '/system/app/SuperSU.apk',
      '/data/app/eu.chainfire.supersu-1.apk',
      '/data/app/eu.chainfire.supersu-2.apk',
      // Magisk (systemless root)
      '/sbin/.magisk',
      '/sbin/.core/mirror',
      '/sbin/.core/img',
    ];
    return rootPaths.any((path) {
      try {
        return File(path).existsSync();
      } catch (_) {
        return false;
      }
    });
  }

  /// iOS 越狱检测 — 检查常见越狱工具和 Cydia 安装路径。
  bool _isIosJailbroken() {
    const List<String> jailbreakPaths = [
      // Package managers
      '/Applications/Cydia.app',
      '/Applications/Sileo.app',
      '/Applications/Zebra.app',
      '/Applications/Installer.app',
      // APT / dpkg infrastructure
      '/private/var/lib/apt',
      '/private/var/lib/cydia',
      '/etc/apt',
      '/usr/libexec/cydia',
      // SSH server (not present on stock iOS)
      '/usr/sbin/sshd',
      '/usr/bin/sshd',
      '/usr/libexec/ssh-keysign',
      // Mobile substrate / Tweak loader
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist',
      '/Library/MobileSubstrate/DynamicLibraries/Veency.plist',
      // LaunchDaemons added by jailbreaks
      '/System/Library/LaunchDaemons/com.ikey.brickhouse.plist',
      '/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist',
      // Bash shell (not present on stock iOS; installed by many jailbreaks)
      '/bin/bash',
      // Stash directories (jailbreak-specific)
      '/private/var/stash',
      '/private/var/tmp/cydia.log',
      '/private/var/mobile/Library/SBSettings/Themes',
    ];
    return jailbreakPaths.any((path) {
      try {
        return File(path).existsSync();
      } catch (_) {
        return false;
      }
    });
  }

  // ────────────────────────────────────────────────────────────────────────
  // Emulator detection
  // ────────────────────────────────────────────────────────────────────────

  /// 检测是否运行在模拟器上。
  ///
  /// 调试模式始终返回 `false`（便于在模拟器中开发）。
  /// Release 模式：iOS 模拟器可通过 Platform.environment 区分；
  /// Android 模拟器检测需要 MethodChannel，此处保守返回 false。
  Future<bool> isRunningOnEmulator() async {
    if (kDebugMode) return false;
    try {
      // iOS Simulator sets SIMULATOR_DEVICE_NAME in its environment.
      // This env var is absent on physical devices.
      if (Platform.isIOS) {
        return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
      }
      // Android: reliable detection requires reading Build.FINGERPRINT or
      // ro.build.characteristics via a MethodChannel.  Without adding a
      // platform channel here, we conservatively return false and rely on
      // root detection to catch most emulator-based attacks.
    } catch (_) {}
    return false;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Debugger detection
  // ────────────────────────────────────────────────────────────────────────

  /// 检测是否有调试器附加。
  ///
  /// 通过 `assert` 语句检测——assert 仅在 debug/test 模式下执行。
  Future<bool> isDebuggerAttached() async {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    return isDebug;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Aggregate
  // ────────────────────────────────────────────────────────────────────────

  /// 获取完整的设备安全状态快照。
  Future<DeviceSecurityStatus> getSecurityStatus() async {
    final isRooted = await isDeviceCompromised();
    final isEmulator = await isRunningOnEmulator();
    final isDebugger = await isDebuggerAttached();

    return DeviceSecurityStatus(
      isRootedOrJailbroken: isRooted,
      isEmulator: isEmulator,
      isDebuggerAttached: isDebugger,
      isSecure: !isRooted && !isEmulator,
    );
  }
}
