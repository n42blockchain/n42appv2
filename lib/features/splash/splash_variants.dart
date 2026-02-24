import 'dart:math';

/// 启动页随机文字内容模型
///
/// 三个主题固定对应关系：
///   A: "Who Creates OWNS"       ↔ "耕者有其田"
///   B: "Private Sovereignty Matters" ↔ "自己的事，最好自己说了算"
///   C: "Blockchain Won't Forget"  ↔ "上链得永生"
///
/// 其他语言均翻译自英文原句，不另造内容。
class SplashVariant {
  /// 主文字前的小标签（如 "Who Creates"、"Private"）
  final String? topLabel;

  /// 主体大字（如 "OWNS"、"Sovereignty"、"Blockchain"）
  final String mainText;

  /// 主文字后的小标签（如 "Matters"、"Won't Forget"）
  final String? midLabel;

  /// 副标题（仅 EN/ZH 变体携带，其他语言不加）
  final String? subText;

  /// 副标题是否加大字间距（"耕 者 有 其 田" / "上 链 得 永 生" 类型）
  final bool subTextSpaced;

  const SplashVariant({
    this.topLabel,
    required this.mainText,
    this.midLabel,
    this.subText,
    this.subTextSpaced = false,
  });
}

// ---------------------------------------------------------------------------
// Pool 1 — 英文 + 中文，共 6 条，出现概率 50%
// EN 变体携带中文副标题（照片原设计）；ZH 变体以照片原文作主体大字
// ---------------------------------------------------------------------------

const List<SplashVariant> _poolCnEn = [
  // ── 英文 3 条 ──
  SplashVariant(
    topLabel: 'Who Creates',
    mainText: 'OWNS',
    subText: '耕 者 有 其 田',
    subTextSpaced: true,
  ),
  SplashVariant(
    topLabel: 'Private',
    mainText: 'Sovereignty',
    midLabel: 'Matters',
    subText: '自己的事，最好自己说了算',
  ),
  SplashVariant(
    mainText: 'Blockchain',
    midLabel: "Won't Forget",
    subText: '上 链 得 永 生',
    subTextSpaced: true,
  ),

  // ── 中文 3 条（照片原文作主体大字）──
  SplashVariant(
    mainText: '耕者有其田',
  ),
  SplashVariant(
    mainText: '自己的事，最好自己说了算',
  ),
  SplashVariant(
    mainText: '上链得永生',
  ),
];

// ---------------------------------------------------------------------------
// Pool 2 — 其他 10 种语言，每语言翻译 3 句英文原句，共 30 条，出现概率 50%
// 顺序：日 / 韩 / 西 / 法 / 德 / 葡 / 俄 / 阿 / 泰 / 印地
// ---------------------------------------------------------------------------

const List<SplashVariant> _poolOther = [
  // ── 日本語 ──────────────────────────────────────────────────────────────
  // A: Who Creates OWNS
  SplashVariant(topLabel: '作る者が', mainText: '所有する'),
  // B: Private Sovereignty Matters
  SplashVariant(topLabel: 'プライベートな', mainText: '主権が', midLabel: '重要'),
  // C: Blockchain Won't Forget
  SplashVariant(mainText: 'ブロックチェーンは', midLabel: '忘れない'),

  // ── 한국어 ──────────────────────────────────────────────────────────────
  // A
  SplashVariant(topLabel: '창조하는 자가', mainText: '소유한다'),
  // B
  SplashVariant(topLabel: '개인', mainText: '주권이', midLabel: '중요합니다'),
  // C
  SplashVariant(mainText: '블록체인은', midLabel: '잊지 않는다'),

  // ── Español ─────────────────────────────────────────────────────────────
  // A
  SplashVariant(topLabel: 'Quien Crea', mainText: 'Posee'),
  // B
  SplashVariant(topLabel: 'Soberanía', mainText: 'Privada', midLabel: 'Importa'),
  // C
  SplashVariant(mainText: 'Blockchain', midLabel: 'No Olvida'),

  // ── Français ────────────────────────────────────────────────────────────
  // A
  SplashVariant(topLabel: 'Qui Crée', mainText: 'Possède'),
  // B
  SplashVariant(topLabel: 'La Souveraineté', mainText: 'Privée', midLabel: 'Compte'),
  // C
  SplashVariant(topLabel: 'La Blockchain', mainText: "N'oublie Pas"),

  // ── Deutsch ─────────────────────────────────────────────────────────────
  // A
  SplashVariant(topLabel: 'Wer Erschafft', mainText: 'Besitzt'),
  // B
  SplashVariant(topLabel: 'Private', mainText: 'Souveränität', midLabel: 'Zählt'),
  // C
  SplashVariant(mainText: 'Blockchain', midLabel: 'Vergisst Nicht'),

  // ── Português ───────────────────────────────────────────────────────────
  // A
  SplashVariant(topLabel: 'Quem Cria', mainText: 'Possui'),
  // B
  SplashVariant(topLabel: 'Soberania', mainText: 'Privada', midLabel: 'Importa'),
  // C
  SplashVariant(mainText: 'Blockchain', midLabel: 'Não Esquece'),

  // ── Русский ─────────────────────────────────────────────────────────────
  // A
  SplashVariant(topLabel: 'Кто Создаёт', mainText: 'Владеет'),
  // B
  SplashVariant(topLabel: 'Личный', mainText: 'Суверенитет', midLabel: 'Важен'),
  // C
  SplashVariant(mainText: 'Блокчейн', midLabel: 'Не Забудет'),

  // ── العربية ─────────────────────────────────────────────────────────────
  // A
  SplashVariant(topLabel: 'من يخلق', mainText: 'يملك'),
  // B
  SplashVariant(topLabel: 'السيادة', mainText: 'الخاصة', midLabel: 'مهمة'),
  // C
  SplashVariant(mainText: 'البلوكشين', midLabel: 'لا ينسى'),

  // ── ภาษาไทย ─────────────────────────────────────────────────────────────
  // A
  SplashVariant(topLabel: 'ผู้สร้าง', mainText: 'เป็นเจ้าของ'),
  // B
  SplashVariant(topLabel: 'อธิปไตย', mainText: 'ส่วนตัว', midLabel: 'สำคัญ'),
  // C
  SplashVariant(mainText: 'บล็อกเชน', midLabel: 'ไม่ลืม'),

  // ── हिंदी ────────────────────────────────────────────────────────────────
  // A
  SplashVariant(topLabel: 'जो बनाता है', mainText: 'वो पाता है'),
  // B
  SplashVariant(topLabel: 'निजी', mainText: 'संप्रभुता', midLabel: 'मायने रखती है'),
  // C
  SplashVariant(mainText: 'ब्लॉकचेन', midLabel: 'नहीं भूलेगा'),
];

// ---------------------------------------------------------------------------
// 随机选取：中英文 50%，其他语言 50%
//
// 算法：两池各 30 权重单元。
//   Pool1: 6 条 × 权重 5 = 30
//   Pool2: 30 条 × 权重 1 = 30
// 总权重 60，均匀随机，各池命中概率 50%。
// ---------------------------------------------------------------------------

SplashVariant pickRandomVariant() {
  const int cnEnWeight = 5;
  const int totalCnEn = 6 * cnEnWeight; // 30
  const int totalOther = 30;            // 30
  const int totalWeight = totalCnEn + totalOther; // 60

  final slot = Random().nextInt(totalWeight);
  if (slot < totalCnEn) {
    return _poolCnEn[slot ~/ cnEnWeight];
  } else {
    return _poolOther[slot - totalCnEn];
  }
}
