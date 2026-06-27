import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

import '../../../core/theme/app_colors.dart';

/// 代码块消息（`n42.code_block`）
///
/// 渲染带语言标注 + 行号 + 一键复制的代码块。消息 body 用 markdown 围栏
/// ```` ```lang\ncode\n``` ```` 编码语言（非 N42 客户端回退为代码围栏文本）。
class CodeBlockMessageWidget extends StatelessWidget {
  /// 原始消息 body（可能含 ``` 围栏）
  final String raw;

  const CodeBlockMessageWidget({super.key, required this.raw});

  /// 常用语言别名归一
  static const Map<String, String> _aliases = {
    'js': 'javascript',
    'ts': 'typescript',
    'py': 'python',
    'sh': 'bash',
    'shell': 'bash',
    'yml': 'yaml',
    'rs': 'rust',
    'kt': 'kotlin',
    'objc': 'objectivec',
    'c++': 'cpp',
    'cs': 'csharp',
    'md': 'markdown',
  };

  /// flutter_highlight 默认注册的常用语言子集（不在内则传 null 走自动检测，避免抛错）
  static const Set<String> _known = {
    'dart', 'javascript', 'typescript', 'python', 'java', 'kotlin', 'swift',
    'go', 'rust', 'cpp', 'c', 'csharp', 'php', 'ruby', 'bash', 'json', 'yaml',
    'xml', 'html', 'css', 'scss', 'sql', 'markdown', 'objectivec', 'scala',
    'lua', 'perl', 'r', 'matlab', 'dockerfile', 'ini', 'makefile', 'graphql',
    'solidity', 'plaintext',
  };

  /// 从 body 解析 (language, code)
  static ({String language, String code}) parse(String raw) {
    final text = raw.trimRight();
    final fence = RegExp(r'^```([\w+#.-]*)\n([\s\S]*?)\n?```$');
    final m = fence.firstMatch(text.trim());
    if (m != null) {
      var lang = (m.group(1) ?? '').trim().toLowerCase();
      lang = _aliases[lang] ?? lang;
      final code = m.group(2) ?? '';
      return (language: lang.isEmpty ? 'plaintext' : lang, code: code);
    }
    return (language: 'plaintext', code: raw);
  }

  /// 仅对已注册语言着色，未知语言返回 null（HighlightView 自动检测、不抛错）
  static String? _highlightLang(String lang) =>
      (lang == 'plaintext' || !_known.contains(lang)) ? null : lang;

  @override
  Widget build(BuildContext context) {
    final parsed = parse(raw);
    final lines = parsed.code.split('\n');
    const codeStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 12.5,
      height: 1.45,
    );

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: const Color(0xFF282C34), // atom-one-dark 背景
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部：语言徽章 + 复制
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
            color: Colors.white.withValues(alpha: 0.04),
            child: Row(
              children: [
                Text(
                  parsed.language.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => _copy(context, parsed.code),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.6)),
                        const SizedBox(width: 3),
                        Text(
                          'Copy',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 代码体：行号 gutter + 横向可滚动高亮
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 行号
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 1; i <= lines.length; i++)
                          Text(
                            '$i',
                            style: codeStyle.copyWith(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 代码（横向滚动）
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: HighlightView(
                        parsed.code,
                        language: _highlightLang(parsed.language),
                        theme: atomOneDarkTheme,
                        padding: const EdgeInsets.fromLTRB(0, 10, 12, 10),
                        textStyle: codeStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Code copied'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
