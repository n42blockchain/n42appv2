/// 一种直播礼物（视觉广播，无真实价值）。
class LiveGift {
  const LiveGift({required this.id, required this.emoji, required this.label});

  /// 稳定标识（随事件广播，跨端据此还原 emoji/文案）。
  final String id;

  /// 礼物表情（动画主体）。
  final String emoji;

  /// 展示名（礼物面板与"送出"提示用）。
  final String label;
}

/// 内置礼物目录。仅视觉广播，不涉及任何代币/资金。
const List<LiveGift> kLiveGifts = [
  LiveGift(id: 'rose', emoji: '🌹', label: '玫瑰'),
  LiveGift(id: 'like', emoji: '👍', label: '点赞'),
  LiveGift(id: 'beer', emoji: '🍺', label: '干杯'),
  LiveGift(id: 'rocket', emoji: '🚀', label: '火箭'),
  LiveGift(id: 'diamond', emoji: '💎', label: '钻石'),
  LiveGift(id: 'crown', emoji: '👑', label: '皇冠'),
];

/// 按 id 取礼物；未知 id 回退一个通用礼物盒，保证跨端前向兼容（对端新增礼物
/// 时旧端不至于崩，仍能显示"送出礼物"）。
LiveGift giftById(String id) {
  for (final g in kLiveGifts) {
    if (g.id == id) return g;
  }
  return const LiveGift(id: 'gift', emoji: '🎁', label: '礼物');
}
