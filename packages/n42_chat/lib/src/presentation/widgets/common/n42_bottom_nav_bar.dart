import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import 'n42_badge.dart';

/// 微信风格底部导航栏
///
/// 特点：
/// - 4个固定Tab（消息、通讯录、发现、我）
/// - 选中状态高亮
/// - 支持未读徽章
class N42BottomNavBar extends StatelessWidget {
  /// 当前选中索引
  final int currentIndex;

  /// 切换回调
  final ValueChanged<int> onTap;

  /// 消息未读数
  final int messageUnreadCount;

  /// 通讯录未读数
  final int contactUnreadCount;

  /// 发现红点
  final bool showDiscoverDot;

  /// 自定义Tab项
  final List<N42BottomNavItem>? items;

  const N42BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.messageUnreadCount = 0,
    this.contactUnreadCount = 0,
    this.showDiscoverDot = false,
    this.items,
  });

  /// 默认Tab配置 (使用英文，调用者应传入翻译后的 items)
  List<N42BottomNavItem> get defaultItems => [
        N42BottomNavItem(
          icon: Icons.chat_bubble_outline,
          activeIcon: Icons.chat_bubble,
          label: 'Messages',
          badge: messageUnreadCount,
        ),
        N42BottomNavItem(
          icon: Icons.contacts_outlined,
          activeIcon: Icons.contacts,
          label: 'Contacts',
          badge: contactUnreadCount,
        ),
        N42BottomNavItem(
          icon: Icons.explore_outlined,
          activeIcon: Icons.explore,
          label: 'Discover',
          showDot: showDiscoverDot,
        ),
        const N42BottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Me',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final navItems = items ?? defaultItems;

    return Container(
      decoration: BoxDecoration(
        color: context.navBarColor,
        border: Border(
          top: BorderSide(
            color: context.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimensions.bottomNavBarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: List.generate(navItems.length, (index) {
                return Expanded(
                  child: _buildNavItem(
                    context,
                    navItems[index],
                    index,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    N42BottomNavItem item,
    int index,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? AppColors.primary
        : context.textSecondary;

    // InkWell 提供反馈 + 整 cell 命中（带 splashColor / hoverColor）。
    return InkWell(
      onTap: () => onTap(index),
      splashColor: AppColors.primary.withValues(alpha: 0.10),
      highlightColor: AppColors.primary.withValues(alpha: 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          N42Badge(
            count: item.badge,
            dot: item.showDot,
            show: item.badge > 0 || item.showDot,
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              size: AppDimensions.iconSizeBottomNav,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          // 限制 maxLines/省略号——避免长翻译（如俄语）撑破 tab。
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.captionSmall.copyWith(
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部导航栏项配置
class N42BottomNavItem {
  /// 默认图标
  final IconData icon;

  /// 选中图标
  final IconData activeIcon;

  /// 标签文字
  final String label;

  /// 徽章数量
  final int badge;

  /// 是否显示红点
  final bool showDot;

  const N42BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge = 0,
    this.showDot = false,
  });
}

