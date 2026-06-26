import 'package:flutter/material.dart';

import '../app_color_tokens.dart';
import '../app_radius.dart';
import '../app_spacing.dart';

/// 统一卡片：`bgSurface` + `radiusXl` + 标准内距 + 轻边框（深色优先少用阴影）。
///
/// 替代各 feature 自造的 card 容器（见 `docs/DESIGN_SYSTEM.md` §2.2）。
/// 可点时传 [onTap]，自带按压态。
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.bordered = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  /// 是否描边（默认 true；深色下靠 1px 边框分层）。
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    final inner = Padding(
      padding: padding ?? AppSpacing.cardInset,
      child: child,
    );

    final decoration = BoxDecoration(
      color: c.bgSurface,
      borderRadius: AppRadius.brXl,
      border: bordered ? Border.all(color: c.border) : null,
    );

    if (onTap == null) {
      return DecoratedBox(decoration: decoration, child: inner);
    }
    return Material(
      color: c.bgSurface,
      borderRadius: AppRadius.brXl,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.brXl,
            border: bordered ? Border.all(color: c.border) : null,
          ),
          child: inner,
        ),
      ),
    );
  }
}
