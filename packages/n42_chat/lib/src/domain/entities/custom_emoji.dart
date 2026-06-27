import 'package:equatable/equatable.dart';

/// 自定义（动画）emoji
///
/// 对齐 Telegram Premium / Discord 服务器 emoji：用 `:shortcode:` 形式内联在
/// 文本中，渲染时替换为随包分发的动画（Lottie）或静态（SVG）小图，按字号缩放。
///
/// 内置集合复用已打包的 Noto 动画 Lottie 资源（[BuiltinCustomEmojis]）。
class CustomEmoji extends Equatable {
  /// 短代码（不含冒号），如 `fire`
  final String shortcode;

  /// 资源路径（assets/...，Lottie .json 或 SVG .svg）
  final String asset;

  /// 是否为动画（Lottie）
  final bool animated;

  /// 兜底 Unicode emoji（资源缺失/未知端渲染用）
  final String fallback;

  const CustomEmoji({
    required this.shortcode,
    required this.asset,
    required this.animated,
    required this.fallback,
  });

  @override
  List<Object?> get props => [shortcode, asset, animated, fallback];
}

/// 内置动画 emoji 集合（Noto Animated Emoji，Lottie，Apache-2.0）
///
/// 资源位于 `assets/stickers/lottie/<码点>.json`，与动画贴纸包共用素材。
class BuiltinCustomEmojis {
  BuiltinCustomEmojis._();

  static const String _dir = 'assets/stickers/lottie';

  static CustomEmoji _a(String code, String shortcode, String fallback) {
    return CustomEmoji(
      shortcode: shortcode,
      asset: '$_dir/$code.json',
      animated: true,
      fallback: fallback,
    );
  }

  /// 全部内置动画 emoji（主短代码）
  static final List<CustomEmoji> all = [
    _a('1F600', 'grinning', '😀'),
    _a('1F602', 'joy', '😂'),
    _a('1F609', 'wink', '😉'),
    _a('1F60D', 'heart_eyes', '😍'),
    _a('1F60E', 'sunglasses', '😎'),
    _a('1F914', 'thinking', '🤔'),
    _a('1F622', 'cry', '😢'),
    _a('1F620', 'angry', '😠'),
    _a('1F44D', 'thumbsup', '👍'),
    _a('1F44E', 'thumbsdown', '👎'),
    _a('2764', 'heart', '❤️'),
    _a('1F44F', 'clap', '👏'),
    _a('1F525', 'fire', '🔥'),
    _a('1F389', 'tada', '🎉'),
    _a('1F44C', 'ok_hand', '👌'),
    _a('1F680', 'rocket', '🚀'),
  ];

  /// 短代码别名 → 主短代码（让常见写法都能命中）
  static const Map<String, String> _aliases = {
    'laughing': 'joy',
    'lol': 'joy',
    'smile': 'grinning',
    'grin': 'grinning',
    'cool': 'sunglasses',
    'think': 'thinking',
    'cry': 'cry',
    'sob': 'cry',
    'mad': 'angry',
    'rage': 'angry',
    '+1': 'thumbsup',
    'like': 'thumbsup',
    '-1': 'thumbsdown',
    'love': 'heart_eyes',
    'clapping': 'clap',
    'flame': 'fire',
    'lit': 'fire',
    'party': 'tada',
    'celebrate': 'tada',
    'ok': 'ok_hand',
    'launch': 'rocket',
  };

  static Map<String, CustomEmoji>? _byShortcode;

  static Map<String, CustomEmoji> get _index {
    final cached = _byShortcode;
    if (cached != null) return cached;
    final map = <String, CustomEmoji>{};
    for (final e in all) {
      map[e.shortcode] = e;
    }
    _aliases.forEach((alias, target) {
      final primary = map[target];
      if (primary != null) map[alias] = primary;
    });
    _byShortcode = map;
    return map;
  }

  /// 按短代码查找（含别名）；未知返回 null
  static CustomEmoji? lookup(String shortcode) =>
      _index[shortcode.toLowerCase()];

  /// 是否存在该短代码
  static bool has(String shortcode) => _index.containsKey(shortcode.toLowerCase());

  /// 按前缀搜索短代码（用于输入联想），按主短代码去重，最多 [limit] 个
  static List<CustomEmoji> search(String query, {int limit = 12}) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return List<CustomEmoji>.from(all.take(limit));

    final seen = <String>{};
    final prefix = <CustomEmoji>[];
    final contains = <CustomEmoji>[];
    _index.forEach((code, emoji) {
      if (code == q || code.startsWith(q)) {
        if (seen.add(emoji.shortcode)) prefix.add(emoji);
      } else if (code.contains(q)) {
        if (seen.add(emoji.shortcode)) contains.add(emoji);
      }
    });
    return [...prefix, ...contains].take(limit).toList();
  }
}
