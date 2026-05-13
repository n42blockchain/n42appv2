// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// 全局日志工具。Release 模式下 d/i/w 全部 noop；e 仍上报 Crashlytics。
///
/// - [AppLogger.d] 调试日志（开发期 debug 信息）
/// - [AppLogger.i] 信息日志（关键节点：启动、登录、链切换等）
/// - [AppLogger.w] 警告（可恢复异常、非预期分支）
/// - [AppLogger.e] 错误（带 stack，默认上报 Crashlytics）
///
/// 与 [safeCatch] 互补：被动捕获走 safeCatch，主动埋点走 AppLogger。
class AppLogger {
  AppLogger._();

  /// 调试日志。仅 debug 模式输出。
  static void d(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  /// 信息日志。debug 模式输出。
  static void i(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] INFO: $message');
    }
  }

  /// 警告日志。debug 模式输出，可选上报 Crashlytics 作为 non-fatal。
  static void w(String tag, String message, {bool report = false}) {
    if (kDebugMode) {
      debugPrint('[$tag] WARN: $message');
    }
    if (report && !kDebugMode) {
      FirebaseCrashlytics.instance.log('[$tag] WARN: $message');
    }
  }

  /// 错误日志。debug 模式打印 + stack，默认上报 Crashlytics non-fatal。
  static void e(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool report = true,
  }) {
    if (kDebugMode) {
      debugPrint('[$tag] ERROR: $message ${error ?? ''}');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
    if (report) {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: '[$tag] $message',
        fatal: false,
      );
    }
  }
}
