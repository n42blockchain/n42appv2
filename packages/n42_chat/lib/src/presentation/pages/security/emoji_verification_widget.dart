import 'package:flutter/material.dart';
import 'package:matrix/encryption/utils/key_verification.dart' as kv;

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';

/// SAS Emoji 验证展示组件
///
/// 显示 7 个 emoji 符号供用户与对方设备对比确认
class EmojiVerificationWidget extends StatelessWidget {
  /// Matrix SDK 返回的 SAS emoji 列表
  final List<kv.KeyVerificationEmoji> emojis;

  const EmojiVerificationWidget({
    super.key,
    required this.emojis,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 提示文字
        Text(
          S.of(context)?.securityCompareEmoji ?? 'Compare the emoji on both devices',
          style: TextStyle(
            fontSize: 15,
            color: context.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Emoji 网格展示
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 16,
          children: emojis.map((emoji) => _buildEmojiItem(context, emoji, isDark)).toList(),
        ),
      ],
    );
  }

  Widget _buildEmojiItem(BuildContext context, kv.KeyVerificationEmoji emoji, bool isDark) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji 符号
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Emoji 名称
          Text(
            emoji.name,
            style: TextStyle(
              fontSize: 11,
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// SAS 数字验证展示组件
///
/// 当 emoji 不可用时显示 3 个数字供对比
class NumberVerificationWidget extends StatelessWidget {
  /// 3 个验证数字
  final List<int> numbers;

  const NumberVerificationWidget({
    super.key,
    required this.numbers,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.of(context)?.securityCompareNumbers ?? 'Compare the numbers on both devices',
          style: TextStyle(
            fontSize: 15,
            color: context.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: numbers.map((number) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                number.toString().padLeft(4, '0'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: context.textPrimary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
