import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/live_chat_service.dart';
import 'gift_economy.dart';

/// 礼物金币经济单例（per app）。主播/观众共用，跨端态经 Matrix 事件溯源。
final giftEconomyProvider = Provider<LiveGiftEconomy>((ref) {
  final economy = LiveGiftEconomy(LiveChatService());
  ref.onDispose(economy.dispose);
  return economy;
});

/// 我在某房的金币余额。
final myCoinsProvider = StreamProvider.family<int, String>((ref, roomId) {
  return ref.watch(giftEconomyProvider).watchMyCoins(roomId);
});

/// 主播某房的礼物收益（金币）。
final giftEarningsProvider = StreamProvider.family<int, String>((ref, roomId) {
  return ref.watch(giftEconomyProvider).watchEarnings(roomId);
});
