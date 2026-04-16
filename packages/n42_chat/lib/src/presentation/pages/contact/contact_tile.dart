import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/contact_entity.dart';
import '../../widgets/common/common_widgets.dart';

/// 联系人列表项
class ContactTile extends StatelessWidget {
  final ContactEntity contact;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showOnlineStatus;
  final Widget? trailing;

  const ContactTile({
    super.key,
    required this.contact,
    this.onTap,
    this.onLongPress,
    this.showOnlineStatus = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 头像
              Stack(
                children: [
                  N42Avatar(
                    imageUrl: contact.avatarUrl,
                    name: contact.effectiveDisplayName,
                    size: 44,
                  ),
                  // 在线状态指示器
                  if (showOnlineStatus && contact.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.surfaceDark : AppColors.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // 名称和状态
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 显示名称
                    Text(
                      contact.effectiveDisplayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // 状态消息或最后活跃时间
                    if (contact.statusMessage?.isNotEmpty == true ||
                        (!contact.isOnline && contact.formattedLastActive.isNotEmpty))
                      const SizedBox(height: 4),

                    if (contact.statusMessage?.isNotEmpty == true)
                      Text(
                        contact.statusMessage!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else if (!contact.isOnline &&
                        contact.formattedLastActive.isNotEmpty)
                      Text(
                        contact.formattedLastActive,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // 右侧附加内容
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// 简单联系人列表项（仅头像和名称）
class SimpleContactTile extends StatelessWidget {
  final ContactEntity contact;
  final VoidCallback? onTap;
  final bool selected;

  const SimpleContactTile({
    super.key,
    required this.contact,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Material(
      color: selected
          ? (isDark ? AppColors.primaryDark.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1))
          : (isDark ? AppColors.surfaceDark : AppColors.surface),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              N42Avatar(
                imageUrl: contact.avatarUrl,
                name: contact.effectiveDisplayName,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  contact.effectiveDisplayName,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

