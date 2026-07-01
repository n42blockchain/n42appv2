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

/// 按 id 取礼物；未知 id 返回 `null`。
///
/// **不回退到任意固定价格**：若回退价与目录后续新增的真实价格不同，同一批
/// Matrix 事件会被"认识该礼物"的新版本客户端算出一个收益/花费数字，被"不
/// 认识"的旧版本客户端算出另一个数字——两者都在跑同一套确定性重放却得到
/// 不同结果，破坏跨版本一致性。未知礼物**一律忽略**（不计入收益/花费、不播
/// 动画）才是安全的：旧客户端的数字只会"暂时偏低/不完整"，绝不会"算错"。
LiveGift? giftById(String id) {
  for (final g in kLiveGifts) {
    if (g.id == id) return g;
  }
  return null;
}
