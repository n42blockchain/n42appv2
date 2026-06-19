import 'package:n42_chat/n42_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:n42_wallet/core/utils/app_logger.dart';

const String _chatDataPurgePendingKey = 'n42_chat_purge_pending';

Future<void> logoutFromChatCompat() async {
  if (!N42Chat.isInitialized || !N42Chat.isLoggedIn) {
    return;
  }
  await N42Chat.logout();
}

Future<void> purgeCancelledChatSessionCompat() async {
  try {
    await _markChatDataPurgePending();

    await logoutFromChatCompat();
  } catch (e) {
    AppLogger.w(
      'ChatLogoutCompat',
      'purgeCancelledChatSession logout fallback: $e',
    );
  }

  try {
    await N42Chat.purgeLocalData();
    await clearPendingCancelledChatDataPurgeCompat();
  } catch (e) {
    AppLogger.w(
      'ChatLogoutCompat',
      'purgeCancelledChatSession secure storage cleanup failed: $e',
    );
  }
}

Future<void> purgePendingCancelledChatDataCompat() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final shouldPurge = prefs.getBool(_chatDataPurgePendingKey) ?? false;
    if (!shouldPurge) {
      return;
    }

    await N42Chat.purgeLocalData();
    await prefs.remove(_chatDataPurgePendingKey);
  } catch (e) {
    AppLogger.w('ChatLogoutCompat', 'purgePendingCancelledChatData failed: $e');
  }
}

Future<void> clearPendingCancelledChatDataPurgeCompat() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatDataPurgePendingKey);
  } catch (e) {
    AppLogger.w(
      'ChatLogoutCompat',
      'clearPendingCancelledChatDataPurge failed: $e',
    );
  }
}

Future<void> _markChatDataPurgePending() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_chatDataPurgePendingKey, true);
}
