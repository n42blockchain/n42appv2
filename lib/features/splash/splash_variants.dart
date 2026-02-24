import 'dart:math';

/// 启动页随机文字内容模型
class SplashVariant {
  /// 主文字上方的小标签（可选）
  final String? topLabel;

  /// 主体大字
  final String mainText;

  /// 主文字下方的小标签（可选）
  final String? midLabel;

  /// 副标题（通常带字间距，支持中文/日韩等）
  final String? subText;

  /// 副标题是否加大字间距（中文/日语等表意文字）
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
// 内容池 — 3 个主题，每主题 4 个语言变体，共 12 条
// 每次启动从全部 12 条中随机取一条
// ---------------------------------------------------------------------------

const List<SplashVariant> kSplashVariants = [
  // ── 主题 A：耕者有其田 / 创造即拥有 ────────────────────────────────────────
  SplashVariant(
    topLabel: 'Who Creates',
    mainText: 'OWNS',
    subText: '耕 者 有 其 田',
    subTextSpaced: true,
  ),
  SplashVariant(
    topLabel: '创造者',
    mainText: '拥有',
    subText: '耕 者 有 其 田',
    subTextSpaced: true,
  ),
  SplashVariant(
    topLabel: '創る者が',
    mainText: '所有する',
    subText: '耕す者に 土地あり',
    subTextSpaced: false,
  ),
  SplashVariant(
    mainText: 'Who Creates\nOwns',
    subText: 'Those who till the land own it',
  ),

  // ── 主题 B：私有主权 / 自己的事自己说了算 ───────────────────────────────────
  SplashVariant(
    topLabel: 'Private',
    mainText: 'Sovereignty',
    midLabel: 'Matters',
    subText: '自己的事，最好自己说了算',
  ),
  SplashVariant(
    topLabel: '私有主权',
    mainText: '最重要',
    subText: '自 己 的 事 自 己 说 了 算',
    subTextSpaced: true,
  ),
  SplashVariant(
    topLabel: 'Soberanía',
    mainText: 'Privada',
    midLabel: 'Importa',
    subText: 'Tus datos, tus reglas',
  ),
  SplashVariant(
    topLabel: '프라이빗',
    mainText: '주권이 중요합니다',
    subText: '내 일은 내가 결정한다',
  ),

  // ── 主题 C：上链得永生 / 区块链不遗忘 ──────────────────────────────────────
  SplashVariant(
    mainText: 'Blockchain',
    midLabel: "Won't Forget",
    subText: '上 链 得 永 生',
    subTextSpaced: true,
  ),
  SplashVariant(
    mainText: '区块链',
    midLabel: '永不遗忘',
    subText: '上 链 得 永 生',
    subTextSpaced: true,
  ),
  SplashVariant(
    topLabel: 'La Blockchain',
    mainText: "N'oublie Pas",
    subText: 'Ce qui est ancré dure éternellement',
  ),
  SplashVariant(
    topLabel: 'ブロックチェーン',
    mainText: '忘れない',
    subText: '刻まれた記録は永遠に',
  ),
];

/// 每次调用返回一条随机变体
SplashVariant pickRandomVariant() {
  final index = Random().nextInt(kSplashVariants.length);
  return kSplashVariants[index];
}
