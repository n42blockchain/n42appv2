import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/story_entity.dart';
import 'story_ring.dart';

/// Story 横向滚动栏
///
/// 显示在聊天列表顶部，用于展示用户的 Story 列表：
/// - 第一项固定为"我的 Story"，带有添加按钮
/// - 后续按用户分组显示，未读 Story 优先排序
///
/// 使用示例：
/// ```dart
/// StoryBar(
///   userStories: stories,
///   myStory: myStories,
///   myAvatarUrl: currentUser.avatarUrl,
///   myName: currentUser.displayName,
///   onMyStoryTap: () => viewMyStories(),
///   onUserStoryTap: (user) => viewUserStories(user),
///   onAddStory: () => createNewStory(),
/// )
/// ```
class StoryBar extends StatelessWidget {
  /// 其他用户的 Story 列表
  final List<UserStories> userStories;

  /// 我的 Story（可选）
  final UserStories? myStory;

  /// 我的头像 URL
  final String? myAvatarUrl;

  /// 我的名称
  final String? myName;

  /// 点击"我的 Story"回调
  final VoidCallback? onMyStoryTap;

  /// 点击用户 Story 回调
  final void Function(UserStories userStory)? onUserStoryTap;

  /// 点击添加 Story 按钮回调
  final VoidCallback? onAddStory;

  /// 栏高度
  final double height;

  /// 头像大小
  final double avatarSize;

  /// 水平内边距
  final double horizontalPadding;

  /// 项目间距
  final double itemSpacing;

  const StoryBar({
    super.key,
    required this.userStories,
    this.myStory,
    this.myAvatarUrl,
    this.myName,
    this.onMyStoryTap,
    this.onUserStoryTap,
    this.onAddStory,
    this.height = 100,
    this.avatarSize = 56,
    this.horizontalPadding = 12,
    this.itemSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: context.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: (height - (avatarSize + 10) - 24) / 2, // +10 = ring空间, 24 = 间距6 + 文本高度~18
        ),
        itemCount: userStories.length + 1, // +1 for "My Story"
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildMyStoryItem(context);
          }
          final userStory = userStories[index - 1];
          return _buildUserStoryItem(context, userStory);
        },
      ),
    );
  }

  /// 构建"我的 Story"项
  Widget _buildMyStoryItem(BuildContext context) {
    final hasMyStory = myStory != null && myStory!.stories.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(right: itemSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头像与添加按钮
          GestureDetector(
            onTap: hasMyStory ? onMyStoryTap : onAddStory,
            child: SizedBox(
              width: avatarSize + 10, // 额外空间给圆环
              height: avatarSize + 10,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 头像（带或不带圆环）
                  if (hasMyStory)
                    StoryRing(
                      imageUrl: myAvatarUrl,
                      name: myName,
                      size: avatarSize,
                      hasUnviewed: false, // 自己的 Story 不显示未读状态
                      storyCount: myStory!.storyCount,
                    )
                  else
                    Center(
                      child: _MyStoryAvatar(
                        imageUrl: myAvatarUrl,
                        name: myName,
                        size: avatarSize,
                      ),
                    ),
                  // 添加按钮
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: onAddStory,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.surfaceColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // 名称
          SizedBox(
            width: avatarSize + 10,
            child: Text(
              S.of(context)?.storyMyStory ?? 'My Story',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: context.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建用户 Story 项
  Widget _buildUserStoryItem(BuildContext context, UserStories userStory) {
    return Padding(
      padding: EdgeInsets.only(right: itemSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头像圆环
          StoryRing(
            imageUrl: userStory.avatarUrl,
            name: userStory.userName,
            size: avatarSize,
            hasUnviewed: userStory.hasUnviewed,
            storyCount: userStory.storyCount,
            onTap: () => onUserStoryTap?.call(userStory),
          ),
          const SizedBox(height: 6),
          // 名称
          SizedBox(
            width: avatarSize + 10,
            child: Text(
              _getDisplayName(userStory.userName),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: userStory.hasUnviewed
                    ? context.textPrimary
                    : context.textSecondary,
                fontWeight:
                    userStory.hasUnviewed ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取显示名称（提取简短名称）
  String _getDisplayName(String name) {
    // 如果名称包含 @ 或 : ，提取用户名部分
    if (name.startsWith('@')) {
      final colonIndex = name.indexOf(':');
      if (colonIndex > 0) {
        return name.substring(1, colonIndex);
      }
      return name.substring(1);
    }
    return name;
  }
}

/// 没有 Story 时的头像样式
class _MyStoryAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;

  const _MyStoryAvatar({
    this.imageUrl,
    this.name,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.dividerColor,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildPlaceholder(context),
              )
            : _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    if (name != null && name!.isNotEmpty) {
      final initials = _getInitials(name!);
      return Container(
        color: AppColorPalettes.getAvatarColor(name!),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Container(
      color: isDarkMode ? AppColors.surfaceDark : AppColors.placeholder,
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Colors.white.withValues(alpha: 0.8),
      ),
    );
  }

  static final RegExp _nonWordCjkPattern = RegExp(r'[^\w\u4e00-\u9fa5]');
  static final RegExp _whitespacePattern = RegExp(r'\s+');

  String _getInitials(String name) {
    final cleanName =
        name.replaceAll(_nonWordCjkPattern, '').trim();
    if (cleanName.isEmpty) return '';

    final parts = cleanName.split(_whitespacePattern);
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return cleanName.substring(0, 1).toUpperCase();
  }
}
