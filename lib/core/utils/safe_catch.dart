import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// 安全的异步异常捕获工具
///
/// 替代 `catch (_) { return null; }` 模式，确保所有异常都被记录。
/// 遵循"失败可观测"原则：每个 catch 必须恢复、上报或重抛。
///
/// [report] 控制是否上报到 Crashlytics。对于预期中的失败
/// （网络超时、数据缺失等）设为 false 以避免噪音。
Future<T?> safeCatch<T>(
  Future<T> Function() action, {
  required String context,
  T? fallback,
  bool report = true,
}) async {
  try {
    return await action();
  } catch (e, s) {
    _log(context, e, s, report: report);
    return fallback;
  }
}

/// 同步版本
T? safeCatchSync<T>(
  T Function() action, {
  required String context,
  T? fallback,
  bool report = true,
}) {
  try {
    return action();
  } catch (e, s) {
    _log(context, e, s, report: report);
    return fallback;
  }
}

void _log(String context, Object e, StackTrace s, {required bool report}) {
  if (kDebugMode) {
    debugPrint('[$context] $e');
  }
  if (report) {
    FirebaseCrashlytics.instance.recordError(
      e,
      s,
      reason: context,
      fatal: false,
    );
  }
}
