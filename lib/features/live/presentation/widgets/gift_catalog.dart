/// 一种直播礼物（TikTok 式金币计价；金币为 play-money 内部账本）。
class LiveGift {
  const LiveGift({
    required this.id,
    required this.emoji,
    required this.label,
    required this.coinPrice,
  });

  /// 稳定标识（随事件广播，跨端据此还原 emoji/文案/价格）。
  final String id;

  /// 礼物表情（动画主体）。
  final String emoji;

  /// 展示名（礼物面板与"送出"提示用）。
  final String label;

  /// 金币单价。**价格由本目录权威推导**（各端共享同一目录），不信任事件载荷里的
  /// 价格，杜绝送礼方伪造低价；收益/扣费均按此计算。
  final int coinPrice;
}

/// 内置礼物目录（金币计价）。金币 = 内部 play-money 账本；真实充值/提现后续接钱包。
const List<LiveGift> kLiveGifts = [
  LiveGift(id: 'rose', emoji: '🌹', label: '玫瑰', coinPrice: 1),
  LiveGift(id: 'like', emoji: '👍', label: '点赞', coinPrice: 1),
  LiveGift(id: 'beer', emoji: '🍺', label: '干杯', coinPrice: 2),
  LiveGift(id: 'rocket', emoji: '🚀', label: '火箭', coinPrice: 10),
  LiveGift(id: 'diamond', emoji: '💎', label: '钻石', coinPrice: 50),
  LiveGift(id: 'crown', emoji: '👑', label: '皇冠', coinPrice: 99),
];

/// 按 id 取礼物；未知 id 回退一个通用礼物盒（价 1），保证跨端前向兼容（对端新增
/// 礼物时旧端不至于崩，仍能显示"送出礼物"且不至于把价当 0）。
LiveGift giftById(String id) {
  for (final g in kLiveGifts) {
    if (g.id == id) return g;
  }
  return const LiveGift(id: 'gift', emoji: '🎁', label: '礼物', coinPrice: 1);
}
