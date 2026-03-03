import 'dart:math';

/// 启动页随机文字内容模型
///
/// 13 种语言，3 句主题：
///   A: "Who Creates OWNS"            ↔ "耕者有其田"
///   B: "Private Sovereignty Matters"  ↔ "自己的事，最好自己说了算"
///   C: "Blockchain Won't Forget"      ↔ "上链得永生"
///
/// 每次启动只显示一种语言，不混排。
class SplashVariant {
  /// 主文字前的小标签（如 "Who Creates"、"Private"）
  final String? topLabel;

  /// 主体大字（如 "OWNS"、"Sovereignty"、"Blockchain"）
  final String mainText;

  /// 主文字后的小标签（如 "Matters"、"Won't Forget"）
  final String? midLabel;

  const SplashVariant({
    this.topLabel,
    required this.mainText,
    this.midLabel,
  });
}

// ---------------------------------------------------------------------------
// Pool 1 — 英文 + 中文，共 6 条，出现概率 50%
// 每条只显示一种语言，不混排
// ---------------------------------------------------------------------------

const List<SplashVariant> _poolCnEn = [
  // ── English ──
  SplashVariant(topLabel: 'Who Creates', mainText: 'OWNS'),
  SplashVariant(topLabel: 'Private', mainText: 'Sovereignty', midLabel: 'Matters'),
  SplashVariant(mainText: 'Blockchain', midLabel: "Won't Forget"),

  // ── 中文 ──
  SplashVariant(mainText: '耕者有其田'),
  SplashVariant(mainText: '自己的事，最好自己说了算'),
  SplashVariant(mainText: '上链得永生'),
];

// ---------------------------------------------------------------------------
// Pool 2 — 其他 11 种语言，每语言 3 句，共 33 条，出现概率 50%
// 日 / 韩 / 西 / 法 / 德 / 葡 / 俄 / 阿 / 泰 / 印地 / 越
// ---------------------------------------------------------------------------

const List<SplashVariant> _poolOther = [
  // ── 日本語 ──────────────────────────────────────────────────────────────
  SplashVariant(topLabel: '作る者が', mainText: '所有する'),
  SplashVariant(topLabel: 'プライベートな', mainText: '主権が', midLabel: '重要'),
  SplashVariant(mainText: 'ブロックチェーンは', midLabel: '忘れない'),

  // ── 한국어 ──────────────────────────────────────────────────────────────
  SplashVariant(topLabel: '창조하는 자가', mainText: '소유한다'),
  SplashVariant(topLabel: '개인', mainText: '주권이', midLabel: '중요합니다'),
  SplashVariant(mainText: '블록체인은', midLabel: '잊지 않는다'),

  // ── Español ─────────────────────────────────────────────────────────────
  SplashVariant(topLabel: 'Quien Crea', mainText: 'Posee'),
  SplashVariant(topLabel: 'Soberanía', mainText: 'Privada', midLabel: 'Importa'),
  SplashVariant(mainText: 'Blockchain', midLabel: 'No Olvida'),

  // ── Français ────────────────────────────────────────────────────────────
  SplashVariant(topLabel: 'Qui Crée', mainText: 'Possède'),
  SplashVariant(topLabel: 'La Souveraineté', mainText: 'Privée', midLabel: 'Compte'),
  SplashVariant(topLabel: 'La Blockchain', mainText: "N'oublie Pas"),

  // ── Deutsch ─────────────────────────────────────────────────────────────
  SplashVariant(topLabel: 'Wer Erschafft', mainText: 'Besitzt'),
  SplashVariant(topLabel: 'Private', mainText: 'Souveränität', midLabel: 'Zählt'),
  SplashVariant(mainText: 'Blockchain', midLabel: 'Vergisst Nicht'),

  // ── Português ───────────────────────────────────────────────────────────
  SplashVariant(topLabel: 'Quem Cria', mainText: 'Possui'),
  SplashVariant(topLabel: 'Soberania', mainText: 'Privada', midLabel: 'Importa'),
  SplashVariant(mainText: 'Blockchain', midLabel: 'Não Esquece'),

  // ── Русский ─────────────────────────────────────────────────────────────
  SplashVariant(topLabel: 'Кто Создаёт', mainText: 'Владеет'),
  SplashVariant(topLabel: 'Личный', mainText: 'Суверенитет', midLabel: 'Важен'),
  SplashVariant(mainText: 'Блокчейн', midLabel: 'Не Забудет'),

  // ── العربية ─────────────────────────────────────────────────────────────
  SplashVariant(topLabel: 'من يخلق', mainText: 'يملك'),
  SplashVariant(topLabel: 'السيادة', mainText: 'الخاصة', midLabel: 'مهمة'),
  SplashVariant(mainText: 'البلوكشين', midLabel: 'لا ينسى'),

  // ── ภาษาไทย ─────────────────────────────────────────────────────────────
  SplashVariant(topLabel: 'ผู้สร้าง', mainText: 'เป็นเจ้าของ'),
  SplashVariant(topLabel: 'อธิปไตย', mainText: 'ส่วนตัว', midLabel: 'สำคัญ'),
  SplashVariant(mainText: 'บล็อกเชน', midLabel: 'ไม่ลืม'),

  // ── हिंदी ────────────────────────────────────────────────────────────────
  SplashVariant(topLabel: 'जो बनाता है', mainText: 'वो पाता है'),
  SplashVariant(topLabel: 'निजी', mainText: 'संप्रभुता', midLabel: 'मायने रखती है'),
  SplashVariant(mainText: 'ब्लॉकचेन', midLabel: 'नहीं भूलेगा'),

  // ── Tiếng Việt ──────────────────────────────────────────────────────────
  SplashVariant(topLabel: 'Người Tạo Ra', mainText: 'Sở Hữu'),
  SplashVariant(topLabel: 'Chủ Quyền', mainText: 'Cá Nhân', midLabel: 'Quan Trọng'),
  SplashVariant(mainText: 'Blockchain', midLabel: 'Không Quên'),
];

// ---------------------------------------------------------------------------
// 随机选取：中英文 50%，其他 11 种语言 50%
//
// Pool1: 6 条 × 权重 11 = 66
// Pool2: 33 条 × 权重 2  = 66
// 总权重 132，各池命中概率 50%。
// ---------------------------------------------------------------------------

SplashVariant pickRandomVariant() {
  const int cnEnWeight = 11;
  const int pool2Weight = 2;
  const int totalCnEn = 6 * cnEnWeight;          // 66
  const int totalOther = 33 * pool2Weight;        // 66
  const int totalWeight = totalCnEn + totalOther; // 132

  final slot = Random().nextInt(totalWeight);
  if (slot < totalCnEn) {
    return _poolCnEn[slot ~/ cnEnWeight];
  } else {
    return _poolOther[(slot - totalCnEn) ~/ pool2Weight];
  }
}
