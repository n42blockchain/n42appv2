// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

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
/// 用于在各页面展示功能入口，支持多种样式
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

  /// Resolve icon color, falling back to theme primary blue.
  Color _resolvedIconColor(BuildContext context) =>
      iconColor ??
      AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);

  /// Rounded-square icon container reused across medium / small / icon styles.
  Widget _buildIconBox(
    BuildContext context, {
    required double size,
    required double iconSize,
    required double radius,
    Color? bgColor,
    Color? fgColor,
  }) {
    final color = fgColor ?? _resolvedIconColor(context);
    return Container(
      width: ScreenUtil().setWidth(size),
      height: ScreenUtil().setWidth(size),
      decoration: BoxDecoration(
        color: bgColor ?? color.withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(radius)),
      ),
      child: Icon(icon, color: color, size: ScreenUtil().setWidth(iconSize)),
    );
  }

  /// NEW / HOT badge (only rendered when [isNew] or [isHot] is true).
  Widget? _buildStatusBadge() {
    if (!isNew && !isHot) return null;
    return _buildBadge(
      isNew ? 'NEW' : 'HOT',
      isNew ? Colors.green : Colors.orange,
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // Card variants
  // ────────────────────────────────────────────────────────────────────────

  /// 大卡片样式 - 适合主要功能展示
  Widget _buildLargeCard(BuildContext context) {
    final bgColor =
        backgroundColor ??
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, bgColor.withAlpha(180)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          boxShadow: [
            BoxShadow(
              color: bgColor.withAlpha(50),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 图标
            _buildIconBox(
              context,
              size: 64,
              iconSize: 36,
              radius: 16,
              bgColor: Colors.white24,
              fgColor: Colors.white,
            ),
            SizedBox(width: ScreenUtil().setWidth(20)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (_buildStatusBadge() case final badge?) ...[
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        badge,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: ScreenUtil().setWidth(6)),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
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
    final bgColor =
        backgroundColor ??
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);
    final statusBadge = _buildStatusBadge();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconBox(context, size: 48, iconSize: 28, radius: 12),
                if (tag != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(10),
                      vertical: ScreenUtil().setWidth(4),
                    ),
                    decoration: BoxDecoration(
                      color: (tagColor ?? Colors.green).withAlpha(30),
                      borderRadius: BorderRadius.circular(
                        ScreenUtil().setWidth(8),
                      ),
                    ),
                    child: Text(
                      tag!,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(20),
                        fontWeight: FontWeight.w600,
                        color: tagColor ?? Colors.green,
                      ),
                    ),
                  ),
                if (statusBadge case final badge?) badge,
              ],
            ),

            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              title,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),

            if (subtitle != null) ...[
              SizedBox(height: ScreenUtil().setWidth(4)),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(16),
          horizontal: ScreenUtil().setWidth(12),
        ),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.itemBgColor.name,
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildIconBox(context, size: 48, iconSize: 28, radius: 12),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(6),
                        vertical: ScreenUtil().setWidth(2),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(
                          ScreenUtil().setWidth(8),
                        ),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(16),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(10)),
            Text(
              title,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                fontWeight: FontWeight.w500,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconBox(context, size: 56, iconSize: 32, radius: 14),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            title,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(8),
        vertical: ScreenUtil().setWidth(2),
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(18),
          fontWeight: FontWeight.bold,
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
