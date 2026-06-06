import 'package:flutter/material.dart';

import '../app_color_tokens.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// 徽章语义色调。见 `docs/DESIGN_SYSTEM.md` §2.7。
enum AppBadgeTone { neutral, brand, success, warning, danger, info }

/// 状态徽章 / 药丸：胶囊形，色调底（语义色 12% alpha）+ 同色文字，
/// 可选前导状态圆点或图标。
///
/// 用于**显示态**状态指示（在线数、交易状态、计划 / 节点状态等），**非交互**。
/// 替代各 feature 散落自造的 `_buildStatusBadge` / `_buildStatusChip` /
/// `buttonStyle3(onTap:null)` / `_OnlineBadge` 等重复实现（规范 §2.2 禁重复）。
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.tone = AppBadgeTone.neutral,
    this.dot = false,
    this.icon,
    this.leading,
  });

  final String label;
  final AppBadgeTone tone;

  /// 前导状态圆点（与 [icon] / [leading] 互斥，优先级 leading > icon > dot）。
  final bool dot;
  final IconData? icon;

  /// 自定义前导组件（覆盖 [icon] / [dot]）——承接动画 spinner 等「处理中」态。
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    final fg = _foreground(c);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.12),
        borderRadius: AppRadius.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: AppSpacing.space2),
          ] else if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            SizedBox(width: AppSpacing.space2),
          ] else if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            SizedBox(width: AppSpacing.space2),
          ],
          Text(label, style: AppTypography.captionSm.copyWith(color: fg)),
        ],
      ),
    );
  }

  Color _foreground(AppColorTokens c) => switch (tone) {
    AppBadgeTone.neutral => c.textSecondary,
    AppBadgeTone.brand => c.brand,
    AppBadgeTone.success => c.success,
    AppBadgeTone.warning => c.warning,
    AppBadgeTone.danger => c.danger,
    AppBadgeTone.info => c.info,
  };
}
