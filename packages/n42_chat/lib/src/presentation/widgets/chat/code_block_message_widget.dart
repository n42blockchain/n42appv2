import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 代码块消息渲染 Widget。
///
/// 无外部 syntax-highlighting 依赖（避免引入 flutter_highlight 造成
/// 包体膨胀），而是使用 monospace 字体 + 语言标签 + 行号即足够的最小可行方案。
/// 未来可在此替换为 `flutter_highlight` 或 WASM 的 Shiki 实现。
class CodeBlockMessageWidget extends StatelessWidget {
  const CodeBlockMessageWidget({
    super.key,
    required this.code,
    this.language,
    this.fileName,
    this.maxLines = 30,
    this.isDark = false,
  });

  final String code;
  final String? language;
  final String? fileName;
  final int maxLines;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lines = code.split('\n');
    final displayLines = lines.take(maxLines).toList();
    final truncated = lines.length > maxLines;

    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final headerColor =
        isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE8E8E8);
    final textColor = isDark ? const Color(0xFFD4D4D4) : const Color(0xFF1F1F1F);
    final lineNumColor =
        isDark ? const Color(0xFF858585) : const Color(0xFF999999);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                if (language != null && language!.isNotEmpty) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      language!,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: lineNumColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (fileName != null && fileName!.isNotEmpty)
                  Expanded(
                    child: Text(
                      fileName!,
                      style: TextStyle(fontSize: 12, color: lineNumColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const Spacer(),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已复制'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Icon(Icons.copy, size: 16, color: lineNumColor),
                ),
              ],
            ),
          ),
          // Code body
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < displayLines.length; i++)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${i + 1}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: lineNumColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          displayLines[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: textColor,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  if (truncated)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '... ${lines.length - maxLines} more lines',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: lineNumColor,
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
}
