import 'debug_log_impl_stub.dart'
    if (dart.library.ui) 'debug_log_impl_flutter.dart'
    as impl;

/// Debug-only logging utility.
///
/// All output is suppressed in release builds via [kDebugMode] guard.
/// Use this instead of bare `debugPrint()` to prevent leaking sensitive
/// information (user IDs, room IDs, tokens) in production logs.
///
/// ```dart
/// import 'core/utils/debug_log.dart';
/// debugLog('MyClass: something happened');
/// ```
void debugLog(String message) {
  impl.debugLog(message);
}

/// 推送日志统一前缀。日志中的 `tag` 用于 grep（如 `INIT_OK`、`REG_FAIL`）。
void pushLog(String tag, String message) {
  impl.debugLog('[PUSH_$tag] $message');
}

/// 创建带固定前缀的日志函数。统一各域日志格式，便于 grep。
///
/// ```dart
/// final authLog = taggedLog('AuthRepository');
/// authLog('login: ok');  // 输出 'AuthRepository: login: ok'
/// ```
void Function(String) taggedLog(String tag) =>
    (String message) => impl.debugLog('$tag: $message');

/// 各域常用 tag 实例。新增前先确认 ≥5 处 `debugLog('Foo: ...')` 用法。
final void Function(String) authLog = taggedLog('AuthRepository');
final void Function(String) prefsLog = taggedLog('Preferences');
final void Function(String) secureLog = taggedLog('SecureStorage');
final void Function(String) mcmLog = taggedLog('MatrixClientManager');
final void Function(String) msgLog = taggedLog('MatrixMessageDataSource');
