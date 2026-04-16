import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/services/remark_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/bridge_detection_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../integration/bridge/bridge_platform.dart';
import '../../widgets/common/common_widgets.dart';

/// 会话列表项（仿微信）
class ConversationTile extends StatelessWidget {
  /// 会话数据
  final ConversationEntity conversation;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 是否被选中（iPad 分屏模式下高亮当前会话）
  final bool isSelected;

  /// 是否已锁定（显示锁图标）
  final bool isLocked;

  const ConversationTile({
    super.key,
    required this.conversation,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isLocked = false,
  });
  
  /// 获取显示名称（私聊时优先使用备注名）
  String _getDisplayName() {
    // 群聊直接使用会话名称
    if (conversation.type == ConversationType.group) {
      return conversation.name;
    }
    
    // 私聊：直接使用 conversation.directUserId 获取备注名
    final otherUserId = conversation.directUserId;
    if (otherUserId != null) {
      return RemarkService.instance.getDisplayName(otherUserId, conversation.name);
    }
    
    return conversation.name;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final Color bgColor;
    if (isSelected) {
      bgColor = isDark ? const Color(0xFF2A3A50) : const Color(0xFFE3EFFD);
    } else if (conversation.isPinned) {
      bgColor = isDark ? const Color(0xFF252525) : const Color(0xFFF5F5F5);
    } else {
      bgColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: bgColor,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // 头像（带未读红点）
                  _buildAvatar(isDark),
                  const SizedBox(width: 14),

                  // 内容
                  Expanded(
                    child: _buildContent(context, isDark),
                  ),
                ],
              ),
            ),
          ),
        ),
        // 分割线（左边距与头像对齐）
        Container(
          margin: const EdgeInsets.only(left: 80),
          height: 0.5,
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
      ],
    );
  }

  Widget _buildAvatar(bool isDark) {
    Widget avatarWidget;

    // 三人及以上群聊：使用九宫格头像
    if (conversation.type == ConversationType.group &&
        conversation.memberAvatarUrls != null &&
        conversation.memberAvatarUrls!.length >= 3) {
      final avatarKey = conversation.memberAvatarUrls!
          .map((url) => url ?? 'null')
          .join('_');
      avatarWidget = N42GroupAvatar(
        key: ValueKey('group_${conversation.id}_$avatarKey'),
        memberAvatars: conversation.memberAvatarUrls!,
        memberNames: conversation.memberNames,
        size: 50,
        borderRadius: 12,
      );
    } else {
      // 私聊或两人群聊：使用普通头像
      avatarWidget = N42Avatar(
        imageUrl: conversation.avatarUrl,
        name: conversation.name,
        size: 50,
        borderRadius: 12,
      );
    }

    // 检测桥接平台
    final bridgePlatform =
        BridgeDetectionUtils.detectFromConversation(conversation);

    final hasUnread = conversation.unreadCount > 0;
    final hasBridge = bridgePlatform != null;

    if (!hasUnread && !hasBridge) return avatarWidget;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarWidget,
        // 未读红点
        if (hasUnread)
          Positioned(
            top: -4,
            right: -4,
            child: _buildUnreadBadge(),
          ),
        // 桥接平台 badge
        if (hasBridge)
          Positioned(
            bottom: -2,
            right: -2,
            child: _BridgeBadge(platform: bridgePlatform),
          ),
      ],
    );
  }

  Widget _buildUnreadBadge() {
    // 免打扰时显示灰色小圆点（无边框）
    if (conversation.isMuted) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF888888),
          shape: BoxShape.circle,
        ),
      );
    }
    
    // 未读数 > 99 显示 99+
    final count = conversation.unreadCount;
    final text = count > 99 ? '99+' : '$count';
    
    // 根据数字位数调整宽度
    final minWidth = text.length > 2 ? 26.0 : (text.length > 1 ? 20.0 : 18.0);
    
    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: 18,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.badge,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    final displayName = _getDisplayName();
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行：名称 + 时间
        Row(
          children: [
            // 名称
            Expanded(
              child: Row(
                children: [
                  // 聊天锁标识
                  if (isLocked)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  // 加密标识
                  if (conversation.isEncrypted)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.lock,
                        size: 14,
                        color: AppColors.encrypted,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 时间
            if (conversation.lastMessageTime != null)
              Text(
                N42DateUtils.formatConversationTime(
                    conversation.lastMessageTime!),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : AppColors.textTertiary,
                ),
              ),
          ],
        ),

        const SizedBox(height: 4),

        // 副标题行：消息内容 + 免打扰图标
        Row(
          children: [
            // 草稿标识
            if (conversation.draft != null && conversation.draft!.isNotEmpty)
              const Text(
                '[草稿] ',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.error,
                ),
              ),

            // 最后消息
            Expanded(
              child: Text(
                _getLastMessageText(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : AppColors.textSecondary,
                ),
              ),
            ),

            // 免打扰图标（在右侧）
            if (conversation.isMuted)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.notifications_off,
                  size: 16,
                  color: isDark ? Colors.white24 : AppColors.muted,
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _getLastMessageText() {
    // 草稿
    if (conversation.draft != null && conversation.draft!.isNotEmpty) {
      return conversation.draft!;
    }

    // 最后消息
    if (conversation.lastMessage == null || conversation.lastMessage!.isEmpty) {
      return '';
    }

    // 群聊显示发送者名称
    if (conversation.type == ConversationType.group &&
        conversation.lastMessageSenderName != null) {
      return '${conversation.lastMessageSenderName}: ${conversation.lastMessage}';
    }

    return conversation.lastMessage!;
  }
}

/// 桥接平台小图标 badge（16x16 圆形，白底 + 平台 brand color 图标）
class _BridgeBadge extends StatelessWidget {
  final BridgePlatform platform;

  const _BridgeBadge({required this.platform});

  @override
  Widget build(BuildContext context) {
    final info = BridgePlatformRegistry.getInfo(platform);
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          info.icon,
          size: 11,
          color: info.brandColor,
        ),
      ),
    );
  }
}
