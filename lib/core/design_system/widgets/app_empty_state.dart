import 'package:flutter/material.dart';

import '../app_color_tokens.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// 统一空 / 错误状态：图标 + 标题 + 可选说明 + 可选操作。居中。
///
/// 见 `docs/DESIGN_SYSTEM.md` §2.5——禁止白屏无反馈。
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;

  /// 可选操作（通常是一个 AppButton）。
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.space12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: c.textTertiary),
            SizedBox(height: AppSpacing.space6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headline.copyWith(color: c.textPrimary),
            ),
            if (message != null) ...[
              SizedBox(height: AppSpacing.space4),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(color: c.textSecondary),
              ),
            ],
            if (action != null) ...[
              SizedBox(height: AppSpacing.space8),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
