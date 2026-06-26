import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

/// AI 摘要气泡组件
///
/// 在聊天中显示 AI 生成的消息摘要
/// 支持折叠/展开
class AiSummaryBubble extends StatefulWidget {
  /// 摘要文本
  final String summary;

  /// 摘要的消息数量
  final int messageCount;

  /// 是否正在加载
  final bool isLoading;

  /// 关闭回调
  final VoidCallback? onDismiss;

  const AiSummaryBubble({
    super.key,
    required this.summary,
    this.messageCount = 0,
    this.isLoading = false,
    this.onDismiss,
  });

  @override
  State<AiSummaryBubble> createState() => _AiSummaryBubbleState();
}

class _AiSummaryBubbleState extends State<AiSummaryBubble> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.messageCount > 0
                          ? (l10n?.aiSummarizeUnread(widget.messageCount) ?? 'AI Summary (${widget.messageCount} messages)')
                          : (l10n?.aiSummarize ?? 'AI Summary'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (widget.onDismiss != null)
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // 摘要内容
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: widget.isLoading
                  ? _buildLoading()
                  : SelectableText(
                      widget.summary,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.5,
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    final l10n = S.of(context);
    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n?.aiSummarizeLoading ?? 'Generating summary...',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

/// AI 摘要触发按钮
///
/// 在聊天中未读分割线处显示
class AiSummarizeButton extends StatelessWidget {
  /// 未读消息数量
  final int unreadCount;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否正在加载
  final bool isLoading;

  const AiSummarizeButton({
    super.key,
    required this.unreadCount,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              isLoading
                  ? (l10n?.aiSummarizeLoading ?? 'Summarizing...')
                  : (l10n?.aiSummarizeUnread(unreadCount) ?? 'AI Summarize $unreadCount messages'),
              style: const TextStyle(
                fontSize: 12,
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
