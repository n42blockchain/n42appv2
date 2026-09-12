import 'package:shared_preferences/shared_preferences.dart';

/// Reject unsuccessful platform writes and refresh the optimistic plugin cache.
Future<void> saveStringPreference(
  SharedPreferences preferences,
  String key,
  String value,
) async {
  try {
    if (!await preferences.setString(key, value)) {
      throw StateError('Preference write was rejected');
    }
  } catch (_) {
    // SharedPreferences updates its memory cache before the platform confirms.
    // Reload durable state; do not retry the write or overwrite a newer value.
    try {
      await preferences.reload();
    } catch (_) {
      // Preserve the original write failure for the caller's error handling.
    }
    rethrow;
  }
}
