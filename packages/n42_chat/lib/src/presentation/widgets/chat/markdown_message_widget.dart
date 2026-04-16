import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/message_markdown_utils.dart';

/// Markdown 消息渲染组件
///
/// 当消息内容包含 Markdown 语法时使用此组件渲染
/// 否则回退为普通文本
class MarkdownMessageWidget extends StatelessWidget {
  final String text;
  final bool isSelf;
  final double fontSize;

  const MarkdownMessageWidget({
    super.key,
    required this.text,
    required this.isSelf,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final displayText = sanitizeMarkdownDisplayText(text);
    final textColor = isSelf
        ? AppColors.sentText(isDark)
        : (isDark ? AppColors.textPrimaryDark : AppColors.messageTextReceived);

    final linkColor = isSelf ? Colors.blue[800]! : Colors.blue;

    return MarkdownBody(
      data: displayText,
      selectable: false,
      softLineBreak: true,
      onTapLink: (text, href, title) {
        if (href == null) return;
        final uri = Uri.tryParse(href);
        if (uri == null) return;
        // Only allow http/https to prevent malicious protocol attacks
        if (uri.scheme == 'http' || uri.scheme == 'https') {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      syntaxHighlighter: _ChatCodeSyntaxHighlighter(
        baseStyle: TextStyle(
          fontSize: fontSize - 1,
          color: textColor,
          fontFamily: 'monospace',
          height: 1.45,
        ),
        keywordColor: isDark
            ? const Color(0xFF8AB4F8)
            : const Color(0xFF1A73E8),
        stringColor: isDark ? const Color(0xFFF28B82) : const Color(0xFFC5221F),
        commentColor: isDark
            ? const Color(0xFF81C995)
            : const Color(0xFF188038),
        literalColor: isDark
            ? const Color(0xFFFDD663)
            : const Color(0xFFB06000),
      ),
      styleSheet: MarkdownStyleSheet(
        // 基础文字样式
        p: TextStyle(fontSize: fontSize, color: textColor, height: 1.4),
        // 标题
        h1: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        h2: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        h3: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        h4: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        h5: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        h6: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        // 内联代码
        code: TextStyle(
          fontSize: fontSize - 1,
          color: textColor,
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
          fontFamily: 'monospace',
        ),
        // 代码块
        codeblockDecoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        // 引用块
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: textColor.withValues(alpha: 0.4), width: 3),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: 12),
        // 链接
        a: TextStyle(color: linkColor, decoration: TextDecoration.underline),
        // 删除线
        del: TextStyle(
          color: textColor.withValues(alpha: 0.6),
          decoration: TextDecoration.lineThrough,
        ),
        // 分隔线
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: textColor.withValues(alpha: 0.2), width: 1),
          ),
        ),
        // 列表
        listBullet: TextStyle(fontSize: fontSize, color: textColor),
        // 表格
        tableHead: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        tableBody: TextStyle(color: textColor),
        tableBorder: TableBorder.all(
          color: textColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
    );
  }
}

class _ChatCodeSyntaxHighlighter extends SyntaxHighlighter {
  static final RegExp _commentPattern = RegExp(
    r'//.*$|/\*[\s\S]*?\*/|#.*$',
    multiLine: true,
  );
  static final RegExp _stringPattern = RegExp(
    '\'(?:\\\\.|[^\'\\\\])*\'|"(?:\\\\.|[^"\\\\])*"',
    multiLine: true,
  );
  static final RegExp _numberPattern = RegExp(r'\b\d+(?:\.\d+)?\b');
  static final RegExp _keywordPattern = RegExp(
    r'\b(?:abstract|as|assert|async|await|break|case|catch|class|const|continue|def|default|do|else|enum|export|extends|false|final|finally|fn|for|from|function|if|implements|import|in|interface|let|new|null|private|protected|public|return|static|struct|super|switch|this|throw|true|try|typedef|var|void|while|with|yield)\b',
  );

  final TextStyle baseStyle;
  final Color keywordColor;
  final Color stringColor;
  final Color commentColor;
  final Color literalColor;

  _ChatCodeSyntaxHighlighter({
    required this.baseStyle,
    required this.keywordColor,
    required this.stringColor,
    required this.commentColor,
    required this.literalColor,
  });

  @override
  TextSpan format(String source) {
    final spans = <InlineSpan>[];
    final highlights = <_HighlightSpan>[
      ..._buildSpans(
        source,
        _commentPattern,
        baseStyle.copyWith(color: commentColor),
      ),
      ..._buildSpans(
        source,
        _stringPattern,
        baseStyle.copyWith(color: stringColor),
      ),
      ..._buildSpans(
        source,
        _numberPattern,
        baseStyle.copyWith(color: literalColor),
      ),
      ..._buildSpans(
        source,
        _keywordPattern,
        baseStyle.copyWith(color: keywordColor, fontWeight: FontWeight.w600),
      ),
    ]..sort((a, b) => a.start.compareTo(b.start));

    var cursor = 0;
    for (final highlight in highlights) {
      if (highlight.start < cursor) {
        continue;
      }
      if (highlight.start > cursor) {
        spans.add(
          TextSpan(
            text: source.substring(cursor, highlight.start),
            style: baseStyle,
          ),
        );
      }
      spans.add(
        TextSpan(
          text: source.substring(highlight.start, highlight.end),
          style: highlight.style,
        ),
      );
      cursor = highlight.end;
    }

    if (cursor < source.length) {
      spans.add(TextSpan(text: source.substring(cursor), style: baseStyle));
    }

    return TextSpan(style: baseStyle, children: spans);
  }

  List<_HighlightSpan> _buildSpans(
    String source,
    RegExp pattern,
    TextStyle style,
  ) {
    return pattern.allMatches(source).map((match) {
      return _HighlightSpan(match.start, match.end, style);
    }).toList();
  }
}

class _HighlightSpan {
  final int start;
  final int end;
  final TextStyle style;

  const _HighlightSpan(this.start, this.end, this.style);
}
