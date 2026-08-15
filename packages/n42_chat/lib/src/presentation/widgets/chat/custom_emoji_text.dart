import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../../../core/utils/custom_emoji_parser.dart';
import '../../../domain/entities/custom_emoji.dart';

/// 行内自定义 emoji 小图（Lottie 动画 / SVG 静态，按字号缩放）
class CustomEmojiInline extends StatelessWidget {
  final CustomEmoji emoji;
  final double size;

  const CustomEmojiInline({
    super.key,
    required this.emoji,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Text(emoji.fallback, style: TextStyle(fontSize: size * 0.9));
    return SizedBox(
      width: size,
      height: size,
      child: emoji.animated
          ? Lottie.asset(
              emoji.asset,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (_, _, _) => fallback,
            )
          : SvgPicture.asset(
              emoji.asset,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => fallback,
            ),
    );
  }
}

/// 支持 `:shortcode:` 内联自定义 emoji 的文本
///
/// 文本中已知短代码替换为 [CustomEmojiInline]，未知短代码与普通文本原样显示。
/// 不含已知 emoji 时退化为普通 [Text]，零额外开销。
class CustomEmojiText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CustomEmojiText({
    super.key,
    required this.text,
    this.style,
  });

  /// 把含 `:shortcode:` 的文本拆成 spans：命中内置动画 emoji 的段落渲染为
  /// 内联 Lottie（[CustomEmojiInline]），其余保持文本。供本 widget 与
  /// 消息气泡真实渲染链（message_item 的地址富文本路径）共用，避免两处
  /// 各自实现解析逻辑。
  static List<InlineSpan> spansFor(String text, {required double emojiSize}) {
    final tokens = CustomEmojiParser.parse(text);
    return tokens.map<InlineSpan>((token) {
      if (token.isEmoji) {
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: CustomEmojiInline(emoji: token.emoji!, size: emojiSize),
          ),
        );
      }
      return TextSpan(text: token.text);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!CustomEmojiParser.hasKnownEmoji(text)) {
      return Text(text, style: style);
    }

    final fontSize = style?.fontSize ?? 16;
    final emojiSize = fontSize * 1.35;

    return Text.rich(
      TextSpan(style: style, children: spansFor(text, emojiSize: emojiSize)),
    );
  }
}
