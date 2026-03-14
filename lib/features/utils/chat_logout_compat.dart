import 'package:flutter/foundation.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    debugPrint('purgeCancelledChatSessionCompat logout fallback: $e');
  }

  try {
    await N42Chat.purgeLocalData();
  } catch (e) {
    debugPrint(
      'purgeCancelledChatSessionCompat secure storage cleanup failed: $e',
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
    debugPrint('purgePendingCancelledChatDataCompat failed: $e');
  }
}

Future<void> clearPendingCancelledChatDataPurgeCompat() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatDataPurgePendingKey);
  } catch (e) {
    debugPrint('clearPendingCancelledChatDataPurgeCompat failed: $e');
  }
}

Future<void> _markChatDataPurgePending() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_chatDataPurgePendingKey, true);
}
