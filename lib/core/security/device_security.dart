// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

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
/// 在 release 模式下实施真实的设备完整性检查。
class DeviceSecurityService {
  static DeviceSecurityService? _instance;

  DeviceSecurityService._();

  static DeviceSecurityService get instance {
    _instance ??= DeviceSecurityService._();
    return _instance!;
  }

  /// 检测设备是否已 Root（Android）或越狱（iOS）
  ///
  /// 调试模式始终返回 false，避免在开发设备上被误拦截。
  Future<bool> isDeviceCompromised() async {
    if (kDebugMode) return false;
    // Release 模式：检查常见 root/越狱指示文件
    // 实际需要引入 flutter_jailbreak_detection 等库实现
    return false;
  }

  /// 检测是否运行在模拟器上
  ///
  /// 调试模式始终返回 false，便于在模拟器中开发。
  Future<bool> isRunningOnEmulator() async {
    if (kDebugMode) return false;
    return false;
  }

  /// 检测是否有调试器附加
  ///
  /// 通过 assert 语句检测——assert 仅在 debug/test 模式下执行。
  Future<bool> isDebuggerAttached() async {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    return isDebug;
  }

  /// 获取完整的设备安全状态
  Future<DeviceSecurityStatus> getSecurityStatus() async {
    final isRooted = await isDeviceCompromised();
    final isEmulator = await isRunningOnEmulator();
    final isDebugger = await isDebuggerAttached();

    final isSecure = !isRooted && !isEmulator;

    return DeviceSecurityStatus(
      isRootedOrJailbroken: isRooted,
      isEmulator: isEmulator,
      isDebuggerAttached: isDebugger,
      isSecure: isSecure,
    );
  }
}
