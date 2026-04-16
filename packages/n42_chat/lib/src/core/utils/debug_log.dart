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
