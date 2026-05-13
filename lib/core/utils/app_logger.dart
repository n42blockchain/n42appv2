// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// 全局日志工具。
///
/// - [AppLogger.d] 调试日志：仅 debug 模式输出；release 完全 noop
/// - [AppLogger.i] 信息日志：debug 输出 + release 写入 Crashlytics
///   breadcrumb (`log()`)，便于排查 release crash 时回看启动/登录
///   /链切换等关键路径
/// - [AppLogger.w] 警告：debug 输出 + release 写入 Crashlytics
///   breadcrumb。可选 `report: true` 升级为 non-fatal 上报（会显示在
///   Crashlytics 的 non-fatal 列表，而不仅是 crash 时的回看上下文）
/// - [AppLogger.e] 错误：debug 打印 stack + release 默认上报为
///   non-fatal（`recordError`）
///
/// Release 行为说明：
/// - `d` 是开发期噪音（如 byte buffer 中间状态），不应进 Crashlytics
/// - `i/w` 都进 breadcrumb，因为它们标记关键节点 / 异常分支，
///   crash 发生时这些上下文极有价值
/// - 只有 `w(report: true)` 和 `e` 会作为 non-fatal 上报，让事件
///   产生独立的 Crashlytics issue 而不仅是 crash 上下文
///
/// 与 [safeCatch] 互补：被动捕获走 safeCatch，主动埋点走 AppLogger。
class AppLogger {
  AppLogger._();

  /// 调试日志。仅 debug 模式输出，release 完全 noop。
  static void d(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  /// 信息日志。debug 模式输出；release 模式作为 Crashlytics breadcrumb
  /// 写入（不上报为独立 issue），让 crash 发生时能回看到这些关键路径。
  static void i(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] INFO: $message');
      return;
    }
    _safeCrashlyticsCall(
      () => FirebaseCrashlytics.instance.log('[$tag] INFO: $message'),
    );
  }

  /// 警告日志。debug 模式输出；release 模式始终写入 Crashlytics
  /// breadcrumb，并可选 (`report: true`) 升级为 non-fatal 独立上报。
  static void w(String tag, String message, {bool report = false}) {
    if (kDebugMode) {
      debugPrint('[$tag] WARN: $message');
      return;
    }
    _safeCrashlyticsCall(
      () => FirebaseCrashlytics.instance.log('[$tag] WARN: $message'),
    );
    if (report) {
      _safeCrashlyticsCall(
        () => FirebaseCrashlytics.instance.recordError(
          message,
          null,
          reason: '[$tag] WARN',
          fatal: false,
        ),
      );
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
      _safeCrashlyticsCall(
        () => FirebaseCrashlytics.instance.recordError(
          error ?? message,
          stackTrace,
          reason: '[$tag] $message',
          fatal: false,
        ),
      );
    }
  }

  /// Run a Crashlytics call defensively.
  ///
  /// `FirebaseCrashlytics.instance` throws if Firebase isn't initialized
  /// (e.g. during early startup before `Firebase.initializeApp()`, or in
  /// background isolates where Firebase is initialized lazily). The
  /// logger MUST NEVER kill the calling frame because crash reporting
  /// failed — that would turn a recoverable warning into an actual crash.
  static void _safeCrashlyticsCall(void Function() body) {
    try {
      body();
    } catch (_) {
      // Swallow. Crashlytics failures must never propagate from the
      // logger. Intentionally not recursing into AppLogger here.
    }
  }
}
