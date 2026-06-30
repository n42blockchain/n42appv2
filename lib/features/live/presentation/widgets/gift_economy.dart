import 'dart:async';

import '../../services/live_chat_service.dart';
import 'gift_catalog.dart';

/// 礼物金币账本聚合（纯函数，可单测）：从一段 gift 事件得出主播收益与各用户花费。
/// 单价一律按 [giftById] 权威推导，忽略事件载荷自带价格（防伪造）。
class GiftTally {
  const GiftTally({required this.earnings, required this.spent});

  /// 房间内全部礼物的金币总额（= 主播收益）。
  final int earnings;

  /// userId -> 该用户送出礼物花费的金币。
  final Map<String, int> spent;

  static GiftTally of(List<LiveEvent> events) {
    var earnings = 0;
    final spent = <String, int>{};
    for (final e in events) {
      if (e.kind != 'gift') continue;
      final price = giftById(e.data['g'] as String? ?? 'gift').coinPrice;
      earnings += price;
      spent[e.senderId] = (spent[e.senderId] ?? 0) + price;
    }
    return GiftTally(earnings: earnings, spent: spent);
  }
}

/// 直播礼物**内部金币经济**（TikTok 式 play-money）。
///
/// - 金币余额 = 初始 [initialCoins] + 本地充值 − 我在各房送礼花费（花费经 Matrix
///   gift 事件溯源，跨端一致）。
/// - 主播收益（"钻石"）= 其直播间收到的全部礼物金币总额（同样由事件溯源得出）。
/// - 送礼前本地校验余额，再广播 gift 事件（与视觉礼物同一事件，[GiftOverlay] 照常播动画）。
///
/// 真实充值/提现（上链）是后续接缝：`recharge` 现为本地 mock，接钱包后改为
/// 真实代币购买金币；主播收益提现同理。
class LiveGiftEconomy {
  LiveGiftEconomy(this._chat, {this.initialCoins = 1000});

  final LiveChatService _chat;
  final int initialCoins;

  final Map<String, StreamSubscription<List<LiveEvent>>> _subs = {};
  final Map<String, GiftTally> _latest = {};

  /// 本地累计充值（mock；接钱包后由真实代币购买金币替换）。
  int _recharged = 0;

  final StreamController<void> _changes = StreamController<void>.broadcast();

  String? get _me => _chat.myUserId;

  void dispose() {
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();
    if (!_changes.isClosed) _changes.close();
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(null);
  }

  void _ensureRoom(String roomId) {
    if (roomId.isEmpty || _subs.containsKey(roomId)) return;
    _subs[roomId] = _chat.watchEvents(roomId).listen((events) {
      _latest[roomId] = GiftTally.of(events);
      _emit();
    });
  }

  /// 我在该房的金币余额（含本地充值）。
  Stream<int> watchMyCoins(String roomId) async* {
    _ensureRoom(roomId);
    yield _coins(roomId);
    yield* _changes.stream.map((_) => _coins(roomId));
  }

  int _coins(String roomId) {
    final spent = _latest[roomId]?.spent[_me] ?? 0;
    return initialCoins + _recharged - spent;
  }

  /// 主播该房的礼物收益（金币）。
  Stream<int> watchEarnings(String roomId) async* {
    _ensureRoom(roomId);
    yield _latest[roomId]?.earnings ?? 0;
    yield* _changes.stream.map((_) => _latest[roomId]?.earnings ?? 0);
  }

  /// 本地充值金币（mock）。接钱包后替换为真实代币购买。
  void recharge(int coins) {
    if (coins <= 0) return;
    _recharged += coins;
    _emit();
  }

  /// 送出礼物：先按金币余额本地校验，再经 Matrix 广播 gift 事件（全房动画 + 收益累计）。
  /// 余额不足抛 [GiftInsufficientCoins]。
  Future<void> sendGift(String roomId, String giftId) async {
    _ensureRoom(roomId);
    final price = giftById(giftId).coinPrice;
    if (_coins(roomId) < price) {
      throw const GiftInsufficientCoins();
    }
    await _chat.sendEvent(roomId, {'t': 'gift', 'g': giftId});
  }
}

/// 金币不足。
class GiftInsufficientCoins implements Exception {
  const GiftInsufficientCoins();
  @override
  String toString() => 'GiftInsufficientCoins';
}
