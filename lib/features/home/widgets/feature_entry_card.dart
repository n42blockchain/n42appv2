// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// 功能入口卡片样式
enum FeatureCardStyle {
  /// 大卡片（横向铺满）
  large,

  /// 中等卡片（一行2个）
  medium,

  /// 小卡片（一行3-4个）
  small,

  /// 图标样式（仅图标+文字）
  icon,
}

/// 功能入口卡片
///
/// 用于在各页面展示功能入口，支持多种样式。样式取自设计令牌
/// （见 `docs/DESIGN_SYSTEM.md`）：字号 `AppTypography`、间距 `AppSpacing`、
/// 圆角 `AppRadius`、颜色 `AppColorTokens`。
class FeatureEntryCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? badge;
  final String? tag;
  final Color? tagColor;
  final FeatureCardStyle style;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isNew;
  final bool isHot;

  const FeatureEntryCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.badge,
    this.tag,
    this.tagColor,
    this.style = FeatureCardStyle.medium,
    this.onTap,
    this.trailing,
    this.isNew = false,
    this.isHot = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case FeatureCardStyle.large:
        return _buildLargeCard(context);
      case FeatureCardStyle.medium:
        return _buildMediumCard(context);
      case FeatureCardStyle.small:
        return _buildSmallCard(context);
      case FeatureCardStyle.icon:
        return _buildIconCard(context);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Shared helpers
  // ────────────────────────────────────────────────────────────────────────

  /// 可点卡片包装：Material + InkWell 提供按压态，splash 裁到圆角。
  Widget _tappable({required BorderRadius radius, required Widget child}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: radius, child: child),
    );
  }

  /// Resolve icon color, falling back to brand.
  Color _resolvedIconColor(BuildContext context) =>
      iconColor ?? AppColorTokens.of(context).brand;

  /// Rounded-square icon container reused across medium / small / icon styles.
  Widget _buildIconBox(
    BuildContext context, {
    required double size,
    required double iconSize,
    required BorderRadius radius,
    Color? bgColor,
    Color? fgColor,
  }) {
    final color = fgColor ?? _resolvedIconColor(context);
    return Container(
      width: ScreenUtil().setWidth(size),
      height: ScreenUtil().setWidth(size),
      decoration: BoxDecoration(
        color: bgColor ?? color.withAlpha(30),
        borderRadius: radius,
      ),
      child: Icon(icon, color: color, size: ScreenUtil().setWidth(iconSize)),
    );
  }

  /// NEW / HOT badge (only rendered when [isNew] or [isHot] is true).
  Widget? _buildStatusBadge(BuildContext context) {
    if (!isNew && !isHot) return null;
    final c = AppColorTokens.of(context);
    return _buildBadge(isNew ? 'NEW' : 'HOT', isNew ? c.success : c.warning);
  }

  // ────────────────────────────────────────────────────────────────────────
  // Card variants
  // ────────────────────────────────────────────────────────────────────────

  /// 大卡片样式 - 适合主要功能展示（品牌渐变底，前景固定白）
  Widget _buildLargeCard(BuildContext context) {
    final bgColor = backgroundColor ?? AppColorTokens.of(context).brand;

    return _tappable(
      radius: AppRadius.brXl,
      child: Ink(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.space6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, bgColor.withAlpha(180)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.brXl,
          boxShadow: [
            BoxShadow(
              color: bgColor.withAlpha(50),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildIconBox(
              context,
              size: 64,
              iconSize: 36,
              radius: AppRadius.brMd,
              bgColor: Colors.white24,
              fgColor: Colors.white,
            ),
            SizedBox(width: AppSpacing.space6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.headline.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      if (_buildStatusBadge(context) case final badge?) ...[
                        SizedBox(width: AppSpacing.space2),
                        badge,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.space2),
                    Text(
                      subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: ScreenUtil().setWidth(24),
                ),
          ],
        ),
      ),
    );
  }

  /// 中等卡片样式 - 适合一行2个的布局
  Widget _buildMediumCard(BuildContext context) {
    final c = AppColorTokens.of(context);
    final bgColor = backgroundColor ?? c.bgSurface;
    final statusBadge = _buildStatusBadge(context);

    return _tappable(
      radius: AppRadius.brXl,
      child: Ink(
        padding: EdgeInsets.all(AppSpacing.space6),
        decoration: BoxDecoration(color: bgColor, borderRadius: AppRadius.brXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconBox(
                  context,
                  size: 48,
                  iconSize: 28,
                  radius: AppRadius.brMd,
                ),
                if (tag != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                      vertical: AppSpacing.space2,
                    ),
                    decoration: BoxDecoration(
                      color: (tagColor ?? c.success).withAlpha(30),
                      borderRadius: AppRadius.brSm,
                    ),
                    child: Text(
                      tag!,
                      style: AppTypography.captionSm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tagColor ?? c.success,
                      ),
                    ),
                  ),
                ?statusBadge,
              ],
            ),
            SizedBox(height: AppSpacing.space4),
            Text(
              title,
              style: AppTypography.bodyStrong.copyWith(color: c.textPrimary),
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.space2),
              Text(
                subtitle!,
                style: AppTypography.caption.copyWith(color: c.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 小卡片样式 - 适合一行3-4个的布局
  Widget _buildSmallCard(BuildContext context) {
    final c = AppColorTokens.of(context);
    return _tappable(
      radius: AppRadius.brLg,
      child: Ink(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.space4,
          horizontal: AppSpacing.space4,
        ),
        decoration: BoxDecoration(
          color: c.bgSurface,
          borderRadius: AppRadius.brLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildIconBox(
                  context,
                  size: 48,
                  iconSize: 28,
                  radius: AppRadius.brMd,
                ),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.space2,
                        vertical: AppSpacing.space2,
                      ),
                      decoration: BoxDecoration(
                        color: c.danger,
                        borderRadius: AppRadius.brSm,
                      ),
                      child: Text(
                        badge!,
                        style: AppTypography.captionSm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.space2),
            Text(
              title,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: c.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 图标卡片样式 - 最紧凑的样式
  Widget _buildIconCard(BuildContext context) {
    final c = AppColorTokens.of(context);
    return _tappable(
      radius: AppRadius.brMd,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.space2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconBox(
              context,
              size: 56,
              iconSize: 32,
              radius: AppRadius.brLg,
            ),
            SizedBox(height: AppSpacing.space2),
            Text(
              title,
              style: AppTypography.caption.copyWith(color: c.textPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.brSm),
      child: Text(
        text,
        style: AppTypography.captionSm.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 功能入口网格布局
class FeatureEntryGrid extends StatelessWidget {
  final List<FeatureEntryCard> items;
  final int crossAxisCount;
  final double spacing;

  const FeatureEntryGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: ScreenUtil().setWidth(spacing),
        crossAxisSpacing: ScreenUtil().setWidth(spacing),
        childAspectRatio: crossAxisCount == 2 ? 1.1 : 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}
