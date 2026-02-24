import 'dart:math';

/// 启动页随机文字内容模型
class SplashVariant {
  /// 主文字上方的小标签（可选）
  final String? topLabel;

  /// 主体大字
  final String mainText;

  /// 主文字下方的小标签（可选）
  final String? midLabel;

  /// 副标题（支持中文/日韩等）
  final String? subText;

  /// 副标题是否加大字间距（单字表意文字，如"耕 者 有 其 田"）
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
// Pool 1 — 中文 + 英文，共 6 条（3 EN + 3 ZH），出现概率 50%
// ---------------------------------------------------------------------------

const List<SplashVariant> _poolCnEn = [
  // ── 英文 ──
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

  // ── 中文（主体大字使用照片原文） ──
  SplashVariant(
    topLabel: '谁创造',
    mainText: '耕者有其田',
  ),
  SplashVariant(
    topLabel: '自己的事',
    mainText: '最好自己说了算',
    subText: '自己的事，最好自己说了算',
  ),
  SplashVariant(
    topLabel: '区块链',
    mainText: '上链得永生',
  ),
];

// ---------------------------------------------------------------------------
// Pool 2 — 其他 10 种语言，每语言 3 条（×3 主题 = 30 条），出现概率 50%
// ---------------------------------------------------------------------------

const List<SplashVariant> _poolOther = [
  // ── 日本語 ──────────────────────────────────────────────────────────────
  SplashVariant(
    topLabel: '創る者が',
    mainText: '所有する',
    subText: '耕す者に土地あり',
  ),
  SplashVariant(
    topLabel: 'プライベート',
    mainText: '主権',
    midLabel: 'が重要',
    subText: '自分のことは自分で決める',
  ),
  SplashVariant(
    mainText: 'ブロックチェーン',
    midLabel: '忘れない',
    subText: '刻まれた記録は永遠に',
  ),

  // ── 한국어 ──────────────────────────────────────────────────────────────
  SplashVariant(
    topLabel: '창조하는 자가',
    mainText: '소유한다',
    subText: '경작하는 자가 땅을 가진다',
  ),
  SplashVariant(
    topLabel: '프라이빗',
    mainText: '주권이 중요합니다',
    subText: '내 일은 내가 결정한다',
  ),
  SplashVariant(
    mainText: '블록체인은',
    midLabel: '잊지 않는다',
    subText: '체인에 올리면 영원히 남는다',
  ),

  // ── Español ─────────────────────────────────────────────────────────────
  SplashVariant(
    topLabel: 'Quien Crea',
    mainText: 'Posee',
    subText: 'El que labra la tierra, la posee',
  ),
  SplashVariant(
    topLabel: 'Soberanía',
    mainText: 'Privada',
    midLabel: 'Importa',
    subText: 'Tus datos, tus reglas',
  ),
  SplashVariant(
    mainText: 'Blockchain',
    midLabel: 'No Olvida',
    subText: 'Lo que está en la cadena, permanece',
  ),

  // ── Français ────────────────────────────────────────────────────────────
  SplashVariant(
    topLabel: 'Qui Crée',
    mainText: 'Possède',
    subText: 'Celui qui cultive possède la terre',
  ),
  SplashVariant(
    topLabel: 'Souveraineté',
    mainText: 'Privée',
    midLabel: 'Essentielle',
    subText: 'Tes données, tes règles',
  ),
  SplashVariant(
    topLabel: 'La Blockchain',
    mainText: "N'oublie Pas",
    subText: 'Ce qui est ancré dure éternellement',
  ),

  // ── Deutsch ─────────────────────────────────────────────────────────────
  SplashVariant(
    topLabel: 'Wer erschafft',
    mainText: 'besitzt',
    subText: 'Wer das Land bestellt, dem gehört es',
  ),
  SplashVariant(
    topLabel: 'Private',
    mainText: 'Souveränität',
    midLabel: 'Zählt',
    subText: 'Deine Daten, deine Regeln',
  ),
  SplashVariant(
    mainText: 'Blockchain',
    midLabel: 'vergisst nicht',
    subText: 'Was verkettet ist, bleibt für immer',
  ),

  // ── Português ───────────────────────────────────────────────────────────
  SplashVariant(
    topLabel: 'Quem Cria',
    mainText: 'Possui',
    subText: 'Quem lavra a terra, a possui',
  ),
  SplashVariant(
    topLabel: 'Soberania',
    mainText: 'Privada',
    midLabel: 'Importa',
    subText: 'Seus dados, suas regras',
  ),
  SplashVariant(
    mainText: 'Blockchain',
    midLabel: 'Não Esquece',
    subText: 'O que está na cadeia, permanece',
  ),

  // ── Русский ─────────────────────────────────────────────────────────────
  SplashVariant(
    topLabel: 'Кто создаёт',
    mainText: 'Тот владеет',
    subText: 'Кто обрабатывает, тот владеет',
  ),
  SplashVariant(
    topLabel: 'Частный',
    mainText: 'Суверенитет',
    midLabel: 'Важен',
    subText: 'Твои данные — твои правила',
  ),
  SplashVariant(
    mainText: 'Блокчейн',
    midLabel: 'Не Забудет',
    subText: 'Что записано, то останется навечно',
  ),

  // ── العربية ─────────────────────────────────────────────────────────────
  SplashVariant(
    topLabel: 'من يخلق',
    mainText: 'يملك',
    subText: 'من يزرع يحصد',
  ),
  SplashVariant(
    topLabel: 'السيادة',
    mainText: 'الخاصة',
    midLabel: 'تهم',
    subText: 'بياناتك، قواعدك',
  ),
  SplashVariant(
    mainText: 'البلوكشين',
    midLabel: 'لا ينسى',
    subText: 'ما يُسجَّل يبقى للأبد',
  ),

  // ── ภาษาไทย ─────────────────────────────────────────────────────────────
  SplashVariant(
    topLabel: 'ผู้สร้าง',
    mainText: 'เป็นเจ้าของ',
    subText: 'ผู้ไถนาเป็นเจ้าของที่ดิน',
  ),
  SplashVariant(
    topLabel: 'อธิปไตย',
    mainText: 'ส่วนตัว',
    midLabel: 'สำคัญ',
    subText: 'ข้อมูลของคุณ กฎของคุณ',
  ),
  SplashVariant(
    mainText: 'บล็อกเชน',
    midLabel: 'ไม่ลืม',
    subText: 'สิ่งที่บันทึกไว้จะอยู่ตลอดไป',
  ),

  // ── हिंदी ────────────────────────────────────────────────────────────────
  SplashVariant(
    topLabel: 'जो बनाता है',
    mainText: 'वो पाता है',
    subText: 'जो खेत जोते वो खेत पाए',
  ),
  SplashVariant(
    topLabel: 'निजी',
    mainText: 'संप्रभुता',
    midLabel: 'मायने रखती है',
    subText: 'तुम्हारा डेटा, तुम्हारे नियम',
  ),
  SplashVariant(
    mainText: 'ब्लॉकचेन',
    midLabel: 'नहीं भूलेगा',
    subText: 'जो अंकित हो जाए वो अमर है',
  ),
];

// ---------------------------------------------------------------------------
// 随机选取：中英文 50%，其他语言 50%
// ---------------------------------------------------------------------------

/// 每次调用返回一条随机变体
///
/// 算法：先以 50/50 概率决定从哪个池中选，再从该池中均匀随机取一条。
/// 实现：将两个池拼接，前半段（6条）和后半段（30条）各占总权重的一半。
///
/// 权重 = poolSize_other / poolSize_cnEn = 30/6 = 5 → 给每条 CN/EN 赋权 5，
/// 每条 Other 赋权 1，总权重 = 6×5 + 30×1 = 60，各池各占 50%。
SplashVariant pickRandomVariant() {
  // 总槽位：每条 CN/EN 等效 5 票，每条 Other 等效 1 票
  // 总权重 = 6×5 + 30×1 = 60，CN/EN 占 30/60 = 50%
  const int cnEnWeight = 5;    // 使每条 CN/EN 命中率 = Other 的 5 倍
  const int totalCnEn = 6 * cnEnWeight; // 6 条 × 5 = 30
  const int totalOther = 30;            // 30 条 × 1 = 30
  const int totalWeight = totalCnEn + totalOther; // 60

  final rng = Random();
  final slot = rng.nextInt(totalWeight); // [0, 59]

  if (slot < totalCnEn) {
    // 命中 CN/EN 池
    return _poolCnEn[slot ~/ cnEnWeight];
  } else {
    // 命中 Other 池
    return _poolOther[slot - totalCnEn];
  }
}
