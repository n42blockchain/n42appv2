import 'dart:async';

import '../../services/live_chat_service.dart';
import 'gift_catalog.dart';

/// 一条已过**确定性重放校验**的礼物账目条目。
class GiftLedgerEntry {
  const GiftLedgerEntry({
    required this.event,
    required this.roomId,
    required this.price,
    required this.valid,
  });

  /// 原始礼物事件（含 senderId/senderName/timestamp，供动画层还原展示）。
  final LiveEvent event;

  /// 事件所属房间（用于按房间聚合主播收益）。
  final String roomId;

  /// 单价，权威来自 [giftById]（忽略事件载荷自带价格，防伪造低价）。
  final int price;

  /// 是否有效——按发送者**跨全部已知房间、按时间线顺序**运行的余额校验判定；
  /// 超出该发送者 [LiveGiftEconomy.initialCoins] 累计余额的礼物一律判无效：
  /// 不计入任何人的收益/花费统计，也不会触发 [GiftOverlay] 动画。
  ///
  /// 这是本经济系统唯一的防伪造边界：任何人都能绕过送礼 UI 直接广播 gift 事件
  /// （Matrix 无法阻止已加入房间者广播消息），但由于**所有客户端都对同一份事件
  /// 日志跑同一套确定性重放**，伪造者发送的超额部分会被所有观察者一致判无效，
  /// 无法通过伪造事件把自己刷成"送礼大户"或让主播收益虚高。
  final bool valid;
}

/// 直播礼物**内部金币经济**（TikTok 式 play-money，事件溯源 + 确定性重放）。
///
/// - **金币余额是全局钱包**（跨直播间统一，不按房间隔离）：初始 [initialCoins]
///   + 本地充值 − 本人在**全部已知房间**内经重放判定为有效的送礼花费。
/// - **主播收益**（某房间）= 该房间内被判定有效的礼物金额总和。
/// - 送礼前本地校验余额（UX 提示，非安全边界），再广播 gift 事件；真正防止超额
///   的边界是上面 [GiftLedgerEntry.valid] 描述的确定性重放——即便本地校验因网络
///   延迟被绕过（连续快速点击），重放引擎会按真实时间线顺序把超出余额的部分
///   判无效，不会被计入任何收益/花费统计。
///
/// 真实充值/提现（上链）是后续接缝：[recharge] 现为本地展示性 mock（只影响本端
/// 显示的余额数字，不参与跨端可验证的重放校验——私有充值天然无法被他人验证，
/// 这是"无权威账本"play-money 架构的固有限制，接钱包后由真实代币购买金币替换）。
class LiveGiftEconomy {
  LiveGiftEconomy(this._chat, {this.initialCoins = 1000});

  final LiveChatService _chat;

  /// 每个用户的全局初始余额（重放校验的统一基线，对所有发送者一视同仁）。
  final int initialCoins;

  final Map<String, StreamSubscription<List<LiveEvent>>> _subs = {};

  /// roomId -> 该房间的原始礼物事件（未经校验），由 watchEvents 回调维护。
  final Map<String, List<LiveEvent>> _giftsByRoom = {};

  /// 全部已知房间合并、按时间线排序、跑过重放校验后的账目（每次任一房间
  /// 事件更新即整体重算——规模有限，简单可靠优先于增量优化）。
  List<GiftLedgerEntry> _ledger = const [];

  /// 本地累计充值（仅影响本端显示的余额数字，见类文档）。
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
      _giftsByRoom[roomId] = events.where((e) => e.kind == 'gift').toList();
      _recomputeLedger();
      _emit();
    });
  }

  void _recomputeLedger() {
    _ledger = replay(_giftsByRoom, initialCoins: initialCoins);
  }

  /// **纯函数版重放**（可单测、无需真实 Matrix 后端）：合并多房间礼物事件、
  /// 按时间线升序排序，对每个发送者独立跑一条"余额从 [initialCoins] 起、
  /// 逐笔扣减"的确定性重放；任何客户端用同一份事件日志重算都会得到完全相同
  /// 的 valid 判定（跨端一致，无需服务端仲裁）。[LiveGiftEconomy] 内部调用本
  /// 方法维护 [_ledger]。
  static List<GiftLedgerEntry> replay(
    Map<String, List<LiveEvent>> giftsByRoom, {
    required int initialCoins,
  }) {
    final all = <({LiveEvent event, String roomId, int price})>[];
    giftsByRoom.forEach((roomId, events) {
      for (final e in events) {
        final gift = giftById(e.data['g'] as String? ?? '');
        if (gift == null) continue; // 未知礼物：忽略而非按固定价计（防跨版本不一致）
        all.add((event: e, roomId: roomId, price: gift.coinPrice));
      }
    });
    all.sort((a, b) => a.event.timestamp.compareTo(b.event.timestamp));

    final runningBalance = <String, int>{};
    final ledger = <GiftLedgerEntry>[];
    for (final entry in all) {
      final sender = entry.event.senderId;
      final balance = runningBalance.putIfAbsent(sender, () => initialCoins);
      final valid = balance >= entry.price;
      if (valid) runningBalance[sender] = balance - entry.price;
      ledger.add(
        GiftLedgerEntry(
          event: entry.event,
          roomId: entry.roomId,
          price: entry.price,
          valid: valid,
        ),
      );
    }
    return ledger;
  }

  /// 我的全局金币余额（含本地充值）。传入 roomId 只为确保该房间被追踪订阅，
  /// 返回值与房间无关——余额是跨直播间统一的钱包，不是每房间各自重置。
  Stream<int> watchMyCoins(String roomId) async* {
    _ensureRoom(roomId);
    yield _coins();
    yield* _changes.stream.map((_) => _coins());
  }

  int _coins() {
    final me = _me;
    final spent = _ledger
        .where((g) => g.valid && g.event.senderId == me)
        .fold<int>(0, (s, g) => s + g.price);
    return initialCoins + _recharged - spent;
  }

  /// 主播某房间的礼物收益（金币）：该房间内被判定有效的礼物金额总和。
  Stream<int> watchEarnings(String roomId) async* {
    _ensureRoom(roomId);
    yield _earningsFor(roomId);
    yield* _changes.stream.map((_) => _earningsFor(roomId));
  }

  int _earningsFor(String roomId) => _ledger
      .where((g) => g.valid && g.roomId == roomId)
      .fold<int>(0, (s, g) => s + g.price);

  /// 本地充值金币（仅影响本端显示的余额数字，见类文档"固有限制"）。
  void recharge(int coins) {
    if (coins <= 0) return;
    _recharged += coins;
    _emit();
  }

  /// 送出礼物：本地余额校验（UX 提示）后广播 gift 事件。真正的防超额边界是
  /// [GiftLedgerEntry.valid] 的确定性重放——本地校验即便被网络延迟绕过、连续
  /// 发出超过余额的多笔礼物，多出的部分仍会被所有端一致判无效。
  Future<void> sendGift(String roomId, String giftId) async {
    _ensureRoom(roomId);
    final gift = giftById(giftId);
    if (gift == null) {
      // 理论不可达——giftId 恒来自本端 kLiveGifts（礼物面板）；防御性拒绝
      // 而非放行一份无法定价的礼物。
      throw const GiftInsufficientCoins();
    }
    if (_coins() < gift.coinPrice) {
      throw const GiftInsufficientCoins();
    }
    await _chat.sendEvent(roomId, {'t': 'gift', 'g': giftId});
  }

  /// 新到达的**已通过重放校验**的礼物事件（供 [GiftOverlay] 播动画）。伪造/
  /// 超额送礼会被判无效，不会出现在此流——不播动画、不计入收益。首帧已存在
  /// 的历史有效礼物视为已消费，不重放（避免进房时补放一堆旧礼物）。
  Stream<LiveEvent> watchNewValidGifts(String roomId) async* {
    _ensureRoom(roomId);
    final seen = <String>{};
    for (final g in _validGiftsForRoom(roomId)) {
      seen.add(g.event.id);
    }
    await for (final _ in _changes.stream) {
      for (final g in _validGiftsForRoom(roomId)) {
        if (seen.add(g.event.id)) yield g.event;
      }
    }
  }

  List<GiftLedgerEntry> _validGiftsForRoom(String roomId) =>
      _ledger.where((g) => g.valid && g.roomId == roomId).toList();
}

/// 金币不足。
class GiftInsufficientCoins implements Exception {
  const GiftInsufficientCoins();
  @override
  String toString() => 'GiftInsufficientCoins';
}
