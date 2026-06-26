import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

class AiSmartReplyBar extends StatelessWidget {
  const AiSmartReplyBar({
    super.key,
    required this.suggestions,
    this.isLoading = false,
    this.onSelect,
    this.onRefresh,
    this.onDismiss,
  });

  final List<String> suggestions;
  final bool isLoading;
  final ValueChanged<String>? onSelect;
  final VoidCallback? onRefresh;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final backgroundColor = context.surfaceColor;
    final borderColor = isDark ? Colors.white10 : Colors.black12;
    final titleColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: AppColors.primary.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                S.of(context)?.aiAssistant ?? 'AI Assistant',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Suggested replies',
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  splashRadius: 18,
                  tooltip: S.of(context)?.commonRetry ?? 'Retry',
                  onPressed: onRefresh,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  splashRadius: 18,
                  tooltip: S.of(context)?.commonCancel ?? 'Cancel',
                  onPressed: onDismiss,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          if (isLoading && suggestions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Generating suggestions...',
                style: TextStyle(fontSize: 12, color: subtitleColor),
              ),
            )
          else if (suggestions.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: suggestions
                    .map(
                      (suggestion) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(suggestion),
                          onPressed: onSelect == null
                              ? null
                              : () => onSelect!(suggestion),
                          backgroundColor: AppColors.primary.withValues(
                            alpha: isDark ? 0.16 : 0.10,
                          ),
                          labelStyle: TextStyle(
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 13,
                          ),
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.18),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
