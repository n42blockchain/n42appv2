import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

/// AI 链接摘要卡片
///
/// 显示在 URL 预览下方，提供链接内容的 AI 摘要
class AiLinkSummaryCard extends StatefulWidget {
  /// 摘要文本
  final String? summary;

  /// 是否正在加载
  final bool isLoading;

  /// 生成摘要回调
  final VoidCallback? onGenerate;

  /// URL
  final String url;

  const AiLinkSummaryCard({
    super.key,
    this.summary,
    this.isLoading = false,
    this.onGenerate,
    required this.url,
  });

  @override
  State<AiLinkSummaryCard> createState() => _AiLinkSummaryCardState();
}

class _AiLinkSummaryCardState extends State<AiLinkSummaryCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    // 尚未生成摘要 → 显示触发按钮
    if (widget.summary == null && !widget.isLoading) {
      return _buildTriggerButton(isDark, l10n: l10n);
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n?.aiLinkSummary ?? 'AI Summary',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ],
            ),
          ),

          if (_isExpanded) ...[
            const SizedBox(height: 6),
            if (widget.isLoading)
              Row(
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.aiLinkSummaryAnalyzing ?? 'Analyzing...',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              )
            else
              SelectableText(
                widget.summary ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.4,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTriggerButton(bool isDark, {S? l10n}) {
    return GestureDetector(
      onTap: widget.onGenerate,
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 12, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              l10n?.aiLinkSummary ?? 'AI Summary',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
