import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/a11y_l10n.dart';
import '../../../core/utils/message_markdown_utils.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import 'markdown_message_widget.dart';
import 'custom_emoji_text.dart';
import 'message_status_indicator.dart';
import '../../../core/utils/debug_log.dart';

/// 消息气泡组件
///
/// 支持：
/// - 左侧（接收）/ 右侧（发送）气泡
/// - 多种消息类型（文本、图片、语音、视频、文件、转账等）
/// - 消息状态指示器
/// - 长按菜单
class MessageBubble extends StatelessWidget {
  /// 消息内容Widget
  final Widget child;

  /// 是否是自己发送的消息
  final bool isSelf;

  /// 消息状态
  final MessageStatus status;

  /// 发送时间
  final DateTime? timestamp;

  /// 是否显示时间
  final bool showTimestamp;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 头像URL
  final String? avatarUrl;

  /// 头像名称（用于默认头像）
  final String? avatarName;

  /// 是否显示头像
  final bool showAvatar;

  /// 头像点击回调
  final VoidCallback? onAvatarTap;

  /// 头像双击回调（拍一拍）
  final VoidCallback? onAvatarDoubleTap;

  /// 最大宽度占比
  final double maxWidthFactor;

  /// 气泡颜色
  final Color? bubbleColor;

  /// 重发回调
  final VoidCallback? onResend;

  /// 是否不显示气泡背景（用于图片/视频消息）
  final bool noBubble;

  const MessageBubble({
    super.key,
    required this.child,
    required this.isSelf,
    this.status = MessageStatus.sent,
    this.timestamp,
    this.showTimestamp = false,
    this.onTap,
    this.onLongPress,
    this.avatarUrl,
    this.avatarName,
    this.showAvatar = true,
    this.onAvatarTap,
    this.onAvatarDoubleTap,
    this.maxWidthFactor = 0.7,
    this.bubbleColor,
    this.onResend,
    this.noBubble = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 使用实际可用宽度而非屏幕宽度，以正确处理多选模式
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        // 限制气泡绝对最大宽度为 400px，避免在 iPad 上过宽
        final double maxWidth;
        final calculated = availableWidth * maxWidthFactor;
        maxWidth = calculated > 400 ? 400 : calculated;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: isSelf
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧头像（对方消息）
              if (!isSelf && showAvatar) _buildAvatar(isDark),
              if (!isSelf && showAvatar) const SizedBox(width: 8),

              // 消息内容
              Flexible(
                child: Column(
                  crossAxisAlignment: isSelf
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // 时间戳
                    if (showTimestamp && timestamp != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          _formatTime(timestamp!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),

                    // 气泡 + 状态
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 发送失败图标（自己的消息，在气泡左侧）
                        if (isSelf && status == MessageStatus.failed) ...[
                          _buildFailedIndicator(context),
                          const SizedBox(width: 4),
                        ],

                        // 气泡或无气泡内容 - 使用 Flexible 防止溢出
                        Flexible(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: noBubble
                                ? _buildNoBubbleContent()
                                : _buildBubble(isDark),
                          ),
                        ),

                        // 发送中指示器（自己的消息，在气泡右侧）
                        if (isSelf && status == MessageStatus.sending) ...[
                          const SizedBox(width: 4),
                          _buildSendingIndicator(context),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // 右侧头像（自己的消息）
              if (isSelf && showAvatar) const SizedBox(width: 8),
              if (isSelf && showAvatar) _buildAvatar(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(bool isDark) {
    // 获取认证头（用于需要认证的 Matrix 媒体）
    final accessToken = MatrixClientManager.instance.client?.accessToken;
    final headers = <String, String>{};
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return Semantics(
      label: avatarName?.isNotEmpty == true ? avatarName : null,
      image: true,
      button: onAvatarTap != null,
      excludeSemantics: true,
      child: GestureDetector(
      onTap: onAvatarTap,
      onDoubleTap: onAvatarDoubleTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.placeholder,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                memCacheWidth: 80,
                memCacheHeight: 80,
                httpHeaders: headers,
                placeholder: (context, url) => _buildDefaultAvatar(),
                errorWidget: (context, url, error) {
                  debugLog(
                    'MessageBubble: Failed to load avatar: $url, error: $error',
                  );
                  return _buildDefaultAvatar();
                },
              )
            : _buildDefaultAvatar(),
      ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final initial = avatarName?.isNotEmpty == true
        ? avatarName![0].toUpperCase()
        : '?';
    return Container(
      color: _getColorFromName(avatarName ?? ''),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 无气泡内容（用于图片/视频消息）
  Widget _buildNoBubbleContent() {
    // 如果外部没有设置 onTap 和 onLongPress，直接返回 child
    // 这样让 child 内部的手势可以正常响应（如红包、转账消息）
    if (onTap == null && onLongPress == null) {
      return child;
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.translucent, // 允许子组件也响应点击
      child: child,
    );
  }

  Widget _buildBubble(bool isDark) {
    final bgColor =
        bubbleColor ??
        (isSelf
            ? AppColors.selfBubble(isDark)
            : (isDark ? AppColors.bubbleOtherDark : AppColors.bubbleOther));

    // 微信风格气泡圆角
    final borderRadius = isSelf
        ? const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          );

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: bgColor, borderRadius: borderRadius),
        child: child,
      ),
    );
  }

  Widget _buildSendingIndicator(BuildContext context) {
    return Semantics(
      label: A11yL10n.of(context).sending,
      child: const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildFailedIndicator(BuildContext context) {
    return Semantics(
      button: true,
      label: A11yL10n.of(context).failedToSendTapResend,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onResend,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.priority_high, size: 14, color: Colors.white),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _getColorFromName(String name) {
    return AppColorPalettes.getAvatarColor(name);
  }
}

/// 文本消息气泡
class TextMessageBubble extends StatelessWidget {
  final String text;
  final bool isSelf;
  final MessageStatus status;
  final DateTime? timestamp;
  final bool showTimestamp;
  final VoidCallback? onLongPress;
  final String? avatarUrl;
  final String? avatarName;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onResend;

  const TextMessageBubble({
    super.key,
    required this.text,
    required this.isSelf,
    this.status = MessageStatus.sent,
    this.timestamp,
    this.showTimestamp = false,
    this.onLongPress,
    this.avatarUrl,
    this.avatarName,
    this.onAvatarTap,
    this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isSelf
        ? AppColors.sentText(isDark)
        : (isDark ? AppColors.textPrimaryDark : AppColors.messageTextReceived);

    final useMarkdown = containsMarkdown(text);

    return MessageBubble(
      isSelf: isSelf,
      status: status,
      timestamp: timestamp,
      showTimestamp: showTimestamp,
      onLongPress: onLongPress,
      avatarUrl: avatarUrl,
      avatarName: avatarName,
      onAvatarTap: onAvatarTap,
      onResend: onResend,
      child: useMarkdown
          ? MarkdownMessageWidget(text: text, isSelf: isSelf)
          : CustomEmojiText(
              text: text,
              style: TextStyle(fontSize: 16, color: textColor, height: 1.4),
            ),
    );
  }
}
