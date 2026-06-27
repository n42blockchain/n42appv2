import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/matrix_utils.dart' as mx_utils;
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/remark_service.dart';
import '../../../core/services/url_preview_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/payment_request_status_utils.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/entities/message_reaction_entity.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../widgets/chat/message_status_indicator.dart' as indicator;
import '../../widgets/chat/chat_widgets.dart';
import '../../widgets/chat/contact_card_message_widget.dart';
import '../../widgets/chat/url_preview_widget.dart';
import '../../../core/services/ai_service.dart';
import '../../widgets/chat/message_reaction_bar.dart';
import '../../widgets/chat/edit_history_sheet.dart';
import '../../widgets/chat/thread_indicator.dart';
import '../../widgets/chat/code_block_message_widget.dart';
import 'message_item_helpers.dart';
import '../../../core/utils/debug_log.dart';

/// 消息列表项
class MessageItem extends StatelessWidget {
  static final _urlRegex = RegExp(r'https?://\S+');
  static final _nameRegex = RegExp(r'^(Name[：:]|联系人[：:]|Contact[：:])');
  static final _idRegex = RegExp(r'^ID[：:]');
  static final _avatarRegex = RegExp(r'^(头像[：:]|Avatar[：:])');

  /// 消息实体
  final MessageEntity message;

  /// 是否高亮显示（搜索结果）
  final bool isHighlighted;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 头像点击回调
  final VoidCallback? onAvatarTap;

  /// 头像双击回调（拍一拍）
  final VoidCallback? onAvatarDoubleTap;

  /// 重发回调
  final VoidCallback? onResend;

  /// 是否是群聊消息
  final bool isGroupChat;

  /// 是否显示发送者名称
  final bool showSenderName;

  /// 当前用户ID（用于表情回应高亮）
  final String? currentUserId;

  /// 表情回应点击回调
  final void Function(String emoji)? onReactionTap;

  /// 投票回调 (pollEventId, optionId, currentVotes, maxSelections)
  final void Function(
    String pollEventId,
    String optionId,
    List<String> currentVotes,
    int maxSelections,
  )?
  onPollVote;

  /// 结束投票回调
  final void Function(String pollEventId)? onEndPoll;

  /// 红包点击回调
  final void Function(MessageEntity message)? onRedPacketTap;

  /// 名片点击回调
  final void Function(String contactId, String contactName, String? avatarUrl)?
  onContactCardTap;

  /// 回拨通话回调
  final void Function(MessageEntity message)? onCallBack;

  /// 引用块点击回调 - 用于跳转到被引用的消息
  final void Function(String messageId)? onReplyQuoteTap;

  /// 线程点击回调 - 用于导航到线程详情页
  final void Function(MessageEntity message)? onThreadTap;

  /// 消息文本字体大小（用户自定义）
  final double? messageFontSize;

  /// 是否展示链接预览与链接摘要
  final bool showLinkPreview;

  const MessageItem({
    super.key,
    required this.message,
    this.isHighlighted = false,
    this.onTap,
    this.onLongPress,
    this.onAvatarTap,
    this.onAvatarDoubleTap,
    this.onResend,
    this.isGroupChat = false,
    this.showSenderName = false,
    this.currentUserId,
    this.onReactionTap,
    this.onPollVote,
    this.onEndPoll,
    this.onRedPacketTap,
    this.onContactCardTap,
    this.onCallBack,
    this.onReplyQuoteTap,
    this.onThreadTap,
    this.messageFontSize,
    this.showLinkPreview = true,
  });

  @override
  Widget build(BuildContext context) {
    // 系统消息
    if (message.type == MessageType.system ||
        message.type == MessageType.notice) {
      return SystemMessageWidget(message: message.content);
    }

    // 通话消息 - 微信风格
    if (message.type == MessageType.voiceCall ||
        message.type == MessageType.videoCall) {
      return _buildCallMessage(context);
    }

    // 已撤回的消息 - 显示微信风格的撤回提示
    if (message.type == MessageType.redacted) {
      return RecalledMessageWidget(
        isFromMe: message.isFromMe,
        onReEdit: null, // 服务器撤回的消息无法重新编辑
      );
    }

    // 普通消息
    return _buildMessageBubble(context);
  }

  /// 获取发送者显示名称（优先使用备注名）
  String _getSenderDisplayName(BuildContext context) {
    if (message.isFromMe) {
      return message.senderName;
    }

    // 使用 RemarkService 获取备注名
    return RemarkService.instance.getDisplayName(
      message.senderId,
      message.senderName,
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    final status = _mapStatus(message.status);
    final isDark = context.isDarkMode;
    final displayName = _getSenderDisplayName(context);

    // 是否显示发送者名称（群聊中非自己的消息）
    final shouldShowSenderName =
        isGroupChat && !message.isFromMe && showSenderName;

    // 图片、视频、红包、转账消息不需要气泡背景（微信风格）
    final noBubbleMessage =
        message.type == MessageType.image ||
        message.type == MessageType.video ||
        message.type == MessageType.redPacket ||
        message.type == MessageType.transfer ||
        message.type == MessageType.paymentRequest;

    // 红包和转账消息有自己的点击处理，不需要外层的 onTap
    final hasOwnTapHandler =
        message.type == MessageType.redPacket ||
        message.type == MessageType.transfer ||
        message.type == MessageType.paymentRequest;

    Widget bubble = MessageBubble(
      isSelf: message.isFromMe,
      status: status,
      timestamp: message.timestamp,
      showTimestamp: false,
      avatarUrl: message.senderAvatarUrl,
      avatarName: displayName,
      onTap: hasOwnTapHandler ? null : onTap,
      onLongPress: onLongPress,
      onAvatarTap: onAvatarTap,
      onAvatarDoubleTap: onAvatarDoubleTap,
      onResend: onResend,
      // 图片/视频/红包/转账消息不需要气泡背景
      noBubble: noBubbleMessage,
      child: _buildMessageContent(context),
    );

    // 如果需要显示发送者名称，添加名称标签
    if (shouldShowSenderName) {
      bubble = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 60, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: isDark
                          ? const Color(0xFF999999)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (message.isBotMessage) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BOT',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          bubble,
        ],
      );
    }

    // 高亮显示搜索结果
    if (isHighlighted) {
      bubble = Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: bubble,
      );
    }

    // 阅后即焚倒计时覆盖层
    if (message.isSelfDestructing) {
      if (message.isDestructionStarted) {
        bubble = SelfDestructOverlay(message: message, child: bubble);
      } else {
        // 未开始倒计时的消息显示 timer 图标提示
        bubble = Column(
          crossAxisAlignment: message.isFromMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            bubble,
            Padding(
              padding: EdgeInsets.only(
                left: message.isFromMe ? 0 : 56,
                right: message.isFromMe ? 56 : 0,
                top: 2,
              ),
              child: SelfDestructPendingIcon(
                durationSeconds: message.selfDestructAfter!,
              ),
            ),
          ],
        );
      }
    }

    // 定时发送消息标记
    if (message.isScheduled && !message.isScheduledTimeReached) {
      bubble = Column(
        crossAxisAlignment: message.isFromMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          bubble,
          Padding(
            padding: EdgeInsets.only(
              left: message.isFromMe ? 0 : 56,
              right: message.isFromMe ? 56 : 0,
              top: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 12, color: AppColors.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${S.of(context)?.scheduledMessageLabel ?? 'Scheduled'} ${_formatScheduledTime(message.scheduledAt!)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // 如果有表情回应，显示在消息下方
    if (message.reactions.isNotEmpty) {
      return Column(
        crossAxisAlignment: message.isFromMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [bubble, _buildReactionBar(context)],
      );
    }

    return bubble;
  }

  /// 构建表情回应栏
  Widget _buildReactionBar(BuildContext context) {
    // 转换 MessageReaction 到 MessageReactionEntity
    final reactionEntities = message.reactions.map((r) {
      return MessageReactionEntity(
        emoji: r.key,
        userIds: r.userIds,
        aggregateCount: r.aggregateCount,
      );
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: message.isFromMe ? 0 : 56, // 头像宽度 + 间距
        right: message.isFromMe ? 56 : 0,
        top: 4,
      ),
      child: MessageReactionBar(
        reactions: reactionEntities,
        currentUserId: currentUserId ?? '',
        onReactionTap: onReactionTap,
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final isDark = context.isDarkMode;

    Widget content;
    switch (message.type) {
      case MessageType.text:
        content = _buildTextMessage(isDark, context);
        break;
      case MessageType.image:
        content = _buildImageMessage();
        break;
      case MessageType.sticker:
        content = _buildStickerMessage();
        break;
      case MessageType.codeBlock:
        content = CodeBlockMessageWidget(raw: message.content);
        break;
      case MessageType.voice:
      case MessageType.audio:
        content = _buildVoiceMessage(context);
        break;
      case MessageType.video:
        content = _buildVideoMessage(context);
        break;
      case MessageType.file:
        content = _buildFileMessage(isDark);
        break;
      case MessageType.location:
        content = _buildLocationMessage(isDark, context);
        break;
      case MessageType.transfer:
        content = _buildTransferMessage();
        break;
      case MessageType.tip:
        content = _buildTipMessage();
        break;
      case MessageType.paymentRequest:
        content = _buildPaymentRequestMessage(context);
        break;
      case MessageType.redPacket:
        content = _buildRedPacketMessage(context);
        break;
      case MessageType.poll:
        content = _buildPollMessage(isDark, context);
        break;
      case MessageType.music:
        content = _buildMusicMessage(isDark, context);
        break;
      case MessageType.contactCard:
        content = _buildContactCardWidget(context);
        break;
      case MessageType.encrypted:
        content = _buildEncryptedMessage(isDark);
        break;
      default:
        content = _buildTextMessage(isDark, context);
    }

    // 如果有回复，添加回复引用块
    if (message.hasReply && message.replyToContent != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildReplyQuote(isDark, context),
          const SizedBox(height: 4),
          content,
        ],
      );
    }

    // 如果是线程根消息，在内容下方显示线程指示器
    if (message.isThreadRoot) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          ThreadIndicator(
            message: message,
            onTap: () => onThreadTap?.call(message),
          ),
        ],
      );
    }

    return content;
  }

  /// 构建回复引用块
  Widget _buildReplyQuote(bool isDark, BuildContext context) {
    final bgColor = message.isFromMe
        ? Colors.black.withValues(alpha: 0.1)
        : (isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05));

    final textColor = message.isFromMe
        ? AppColors.sentText(isDark).withValues(alpha: 0.8)
        : context.textSecondary;

    // 包装 GestureDetector 以支持点击跳转到原消息
    return GestureDetector(
      onTap: () {
        if (message.replyToId != null && onReplyQuoteTap != null) {
          onReplyQuoteTap!(message.replyToId!);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: const Border(
            left: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.replyToSender != null)
              Text(
                message.replyToSender!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            Text(
              message.replyToContent ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, height: 1.35, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextMessage(bool isDark, BuildContext context) {
    // 检测是否是名片消息
    if (_isContactCardMessage(message.content)) {
      return _buildContactCardMessage(isDark, context);
    }

    // 微信中绿色气泡的文字是黑色，灰色气泡的文字也是黑色
    // 深色模式下，对方的灰色气泡文字是白色
    final textColor = message.isFromMe
        ? AppColors.sentText(isDark) // 黑色
        : (isDark ? AppColors.textPrimaryDark : AppColors.messageTextReceived);

    final textWidget = _buildRichTextWithAddresses(
      message.content,
      textColor,
      context,
    );

    // 检测消息中的 URL，用于显示预览
    final urlMatch = _urlRegex.firstMatch(message.content);

    // 如果消息被编辑过，在文字下方显示 "已编辑" 标签
    if (message.isEdited) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          textWidget,
          const SizedBox(height: 2),
          GestureDetector(
            onTap: () => _showEditHistory(context),
            child: Text(
              S.of(context)?.chatEdited ?? 'Edited',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                height: 1.3,
                color: message.isFromMe
                    ? AppColors.sentText(isDark).withValues(alpha: 0.5)
                    : context.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          if (urlMatch != null && showLinkPreview)
            UrlPreviewWidget(
              url: urlMatch.group(0)!,
              previewService: getIt<UrlPreviewService>(),
            ),
          if (urlMatch != null &&
              showLinkPreview &&
              getIt.isRegistered<AiService>())
            AiLinkSummaryWrapper(url: urlMatch.group(0)!),
        ],
      );
    }

    // 如果有 URL，在文本下方显示 URL 预览
    if (urlMatch != null && showLinkPreview) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          textWidget,
          UrlPreviewWidget(
            url: urlMatch.group(0)!,
            previewService: getIt<UrlPreviewService>(),
          ),
          if (getIt.isRegistered<AiService>())
            AiLinkSummaryWrapper(url: urlMatch.group(0)!),
        ],
      );
    }

    return textWidget;
  }

  /// 显示编辑历史
  void _showEditHistory(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          EditHistorySheet(roomId: message.roomId, messageId: message.id),
    );
  }

  /// 检测是否是名片消息
  bool _isContactCardMessage(String content) {
    // 检查多种可能的名片消息格式
    // 支持不同语言的本地化标题
    if (content.startsWith('[')) {
      final firstLine = content.split('\n').first.toLowerCase();
      return firstLine.contains('名片') ||
          firstLine.contains('contact') ||
          firstLine.contains('card') ||
          firstLine.contains('personal');
    }
    return false;
  }

  /// 解析名片消息内容
  Map<String, String>? _parseContactCard(String content) {
    try {
      final lines = content.split('\n');
      if (lines.length < 3) return null;

      String? contactName;
      String? contactId;
      String? contactAvatar;

      for (final line in lines) {
        // 支持普通冒号 : 和全角冒号 ：
        // 新格式使用 "Name:" 前缀
        // 同时支持旧格式的 "联系人" 和 "Contact"
        if (line.startsWith('Name:') ||
            line.startsWith('Name：') ||
            line.startsWith('联系人：') ||
            line.startsWith('联系人:') ||
            line.startsWith('Contact：') ||
            line.startsWith('Contact:')) {
          contactName = line.replaceFirst(_nameRegex, '').trim();
        } else if (line.startsWith('ID：') || line.startsWith('ID:')) {
          contactId = line.replaceFirst(_idRegex, '').trim();
        } else if (line.startsWith('头像：') ||
            line.startsWith('头像:') ||
            line.startsWith('Avatar：') ||
            line.startsWith('Avatar:')) {
          contactAvatar = line.replaceFirst(_avatarRegex, '').trim();
        }
      }

      if (contactName != null && contactId != null) {
        return {
          'name': contactName,
          'id': contactId,
          if (contactAvatar != null && contactAvatar.isNotEmpty)
            'avatar': contactAvatar,
        };
      }
    } catch (e) {
      debugLog('Parse contact card error: $e');
    }
    return null;
  }

  /// 构建名片消息（使用 ContactCardMessageWidget）
  /// 用于 MessageType.contactCard 类型消息
  Widget _buildContactCardWidget(BuildContext context) {
    // 优先从多行格式解析（兼容旧格式）
    final cardInfo = _parseContactCard(message.content);

    String contactId;
    String displayName;
    String? avatarUrl;

    if (cardInfo != null) {
      contactId = cardInfo['id'] ?? '';
      displayName =
          cardInfo['name'] ??
          (S.of(context)?.chatUnknownContact ?? 'Unknown Contact');
      avatarUrl = cardInfo['avatar'];
    } else {
      // 从 body 格式 "[Contact Card] displayName" 中解析
      final body = message.content;
      if (body.startsWith('[Contact Card] ')) {
        displayName = body.substring('[Contact Card] '.length).trim();
      } else if (body.startsWith('[')) {
        // 其他本地化格式，尝试提取 ] 之后的内容
        final bracketEnd = body.indexOf(']');
        displayName = bracketEnd >= 0 && bracketEnd < body.length - 1
            ? body.substring(bracketEnd + 1).trim()
            : body;
      } else {
        displayName = body.isNotEmpty
            ? body
            : (S.of(context)?.chatUnknownContact ?? 'Unknown Contact');
      }
      contactId = '';
      avatarUrl = null;
    }

    return ContactCardMessageWidget(
      userId: contactId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      isFromMe: message.isFromMe,
      onTap: () {
        if (contactId.isNotEmpty && onContactCardTap != null) {
          onContactCardTap!(contactId, displayName, avatarUrl);
        }
      },
    );
  }

  /// 构建名片消息（微信风格）
  Widget _buildContactCardMessage(bool isDark, BuildContext context) {
    final cardInfo = _parseContactCard(message.content);
    final contactName =
        cardInfo?['name'] ??
        (S.of(context)?.chatUnknownContact ?? 'Unknown Contact');
    final contactId = cardInfo?['id'] ?? '';
    final contactAvatar = cardInfo?['avatar'];

    return GestureDetector(
      onTap: () {
        if (contactId.isNotEmpty && onContactCardTap != null) {
          onContactCardTap!(contactId, contactName, contactAvatar);
        }
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: message.isFromMe
              ? AppColors.selfBubble(isDark)
              : (isDark ? AppColors.bubbleOtherDark : AppColors.bubbleOther),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 名片内容
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // 头像 - 如果有头像URL则显示网络图片，否则显示首字母
                  _buildContactAvatar(contactName, contactAvatar),
                  const SizedBox(width: 10),
                  // 名称
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contactName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                            color: message.isFromMe
                                ? AppColors.sentText(isDark)
                                : (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.messageTextReceived),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${contactId.length > 12 ? '${contactId.substring(0, 12)}...' : contactId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color: message.isFromMe
                                ? AppColors.sentText(
                                    isDark,
                                  ).withValues(alpha: 0.6)
                                : context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 底部分隔线和标签
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: message.isFromMe
                        ? Colors.black.withValues(alpha: 0.1)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05)),
                    width: 0.5,
                  ),
                ),
              ),
              child: Text(
                S.of(context)?.chatPersonalCard ?? 'Contact Card',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.3,
                  color: message.isFromMe
                      ? AppColors.sentText(isDark).withValues(alpha: 0.5)
                      : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textTertiary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 根据名称生成颜色
  Color _getColorFromName(String name) {
    return AppColorPalettes.getAvatarColor(name);
  }

  /// 构建联系人头像（名片消息用）
  Widget _buildContactAvatar(String name, String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      // 有头像URL，显示网络图片
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          avatarUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // 加载失败时显示首字母
            return _buildAvatarPlaceholder(name);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildAvatarPlaceholder(name);
          },
        ),
      );
    }
    // 无头像URL，显示首字母
    return _buildAvatarPlaceholder(name);
  }

  /// 构建头像占位符（首字母）
  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _getColorFromName(name),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildImageMessage() {
    final metadata = message.metadata;
    // 优先使用 httpUrl，如果没有则使用 mediaUrl
    final imageUrl = metadata?.httpUrl ?? metadata?.mediaUrl ?? '';

    return ImageMessageWidget(
      imageUrl: imageUrl,
      thumbnailUrl: metadata?.thumbnailUrl,
      width: metadata?.width,
      height: metadata?.height,
      onTap: onTap,
      isViewOnce: message.isSelfDestructing,
      isExpired: message.isExpired,
      isViewed: message.isDestructionStarted && !message.isExpired,
      isFromMe: message.isFromMe,
    );
  }

  Widget _buildStickerMessage() {
    final metadata = message.metadata;
    final url = metadata?.httpUrl ?? metadata?.mediaUrl ?? '';
    final mimeType = metadata?.mimeType ?? '';
    const double size = 120;

    Widget fallback() => Text(
          message.content.isNotEmpty ? message.content : '🙂',
          style: const TextStyle(fontSize: 40),
        );

    // 无有效媒体 URL（未上传/解析失败）时回退显示 body 文本
    if (!url.startsWith('http')) {
      return fallback();
    }

    final client = getIt.isRegistered<MatrixClientManager>()
        ? getIt<MatrixClientManager>().client
        : null;
    final headers = mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
      url,
      client: client,
    );

    final lower = url.toLowerCase();
    final isLottie = mimeType.contains('lottie') ||
        mimeType.contains('json') ||
        lower.endsWith('.json');
    final isSvg = mimeType.contains('svg') || lower.endsWith('.svg');
    return SizedBox(
      width: size,
      height: size,
      child: isLottie
          ? Lottie.network(
              url,
              headers: headers,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (_, _, _) => fallback(),
            )
          : isSvg
              ? SvgPicture.network(
                  url,
                  headers: headers,
                  fit: BoxFit.contain,
                  placeholderBuilder: (_) => fallback(),
                )
              : Image.network(
                  url,
                  fit: BoxFit.contain,
                  headers: headers,
                  errorBuilder: (_, _, _) => fallback(),
                ),
    );
  }

  Widget _buildVoiceMessage(BuildContext context) {
    final metadata = message.metadata;
    // 转换毫秒到秒
    final durationSec = ((metadata?.duration ?? 0) / 1000).round();
    // 优先使用 httpUrl
    final voiceUrl = metadata?.httpUrl ?? metadata?.mediaUrl;
    final transcriptionStatus =
        metadata?.transcriptionStatus ?? TranscriptionStatus.none;

    return VoiceMessageWidget(
      duration: durationSec > 0 ? durationSec : 1,
      isSelf: message.isFromMe,
      voiceUrl: voiceUrl,
      convertedText: metadata?.transcription,
      isTranscribing: transcriptionStatus == TranscriptionStatus.transcribing,
      transcriptionFailed: transcriptionStatus == TranscriptionStatus.failed,
      encryptKey: metadata?.encryptKey,
      encryptIv: metadata?.encryptIv,
      encryptSha256: metadata?.encryptSha256,
      onRequestTranscription: voiceUrl != null
          ? () => _requestVoiceToText(context)
          : null,
    );
  }

  void _requestVoiceToText(BuildContext context) {
    final locale = Localizations.localeOf(context);
    context.read<ChatBloc>().add(
      TranscribeVoiceMessage(
        messageId: message.id,
        language: locale.toLanguageTag(),
      ),
    );
  }

  Widget _buildVideoMessage(BuildContext context) {
    final metadata = message.metadata;
    final thumbnailUrl = metadata?.thumbnailUrl;
    final durationMs = metadata?.duration;
    final fileSize = metadata?.size;
    final s = S.of(context);

    // View Once 视频消息（接收方）
    if (message.isSelfDestructing && !message.isFromMe) {
      if (message.isExpired || message.isDestructionStarted) {
        // 已过期或已查看
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 200,
            height: 120,
            color: AppColors.placeholder,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    message.isExpired ? Icons.timer_off : Icons.visibility,
                    color: AppColors.textTertiary,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.isExpired
                        ? (s?.chatViewOnceExpired ?? 'Expired')
                        : (s?.chatViewOnceViewed ?? 'Viewed'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // 未查看 — 模糊蒙版
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[400]!, Colors.grey[600]!],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s?.chatViewOnceVideo ?? 'View Once Video',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s?.chatViewOnceTap ?? 'Tap to view',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 视频缩略图或占位图
            if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
              ImageMessageWidget(imageUrl: thumbnailUrl, onTap: onTap)
            else
              // 无缩略图时显示渐变背景和视频图标
              Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey[800]!, Colors.grey[900]!],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context)?.chatVideoTitle ?? 'Video',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    if (fileSize != null)
                      Text(
                        _formatFileSize(fileSize),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                  ],
                ),
              ),
            // 播放按钮
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
            ),
            // 时长标签
            if (durationMs != null)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration((durationMs / 1000).round()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            // 视频图标标识（左上角）
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            // View Once 标记（发送方）
            if (message.isSelfDestructing && message.isFromMe)
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, size: 12, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(
                        s?.chatViewOnce ?? 'View Once',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1.3,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Widget _buildFileMessage(bool isDark) {
    final metadata = message.metadata;
    final filename = metadata?.fileName ?? message.content;
    final size = metadata?.size;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.insert_drive_file,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: message.isFromMe
                        ? AppColors.sentText(isDark)
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.messageTextReceived),
                  ),
                ),
                if (size != null)
                  Text(
                    _formatFileSize(size),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: message.isFromMe
                          ? AppColors.textSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMessage(bool isDark, BuildContext context) {
    final metadata = message.metadata;
    final latitude = metadata?.latitude;
    final longitude = metadata?.longitude;

    // 解析位置名称
    String locationName = message.content;
    if (locationName.isEmpty ||
        locationName.startsWith('geo:') ||
        locationName.contains('Location was shared')) {
      locationName = S.of(context)?.chatMyLocation ?? 'My Location';
    }

    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 地图预览区域 - OSM 静态瓦片
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFE8EEF0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // OSM 瓦片地图
                if (latitude != null && longitude != null)
                  Positioned.fill(
                    child: Image.network(
                      _osmTileUrl(latitude, longitude, 15),
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, st) => const Center(
                        child: Icon(
                          Icons.map,
                          size: 32,
                          color: Color(0xFFB0BEC5),
                        ),
                      ),
                    ),
                  ),
                // 中心位置标记
                Center(
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 28,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 位置信息区域
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: message.isFromMe
                  ? AppColors.messageSent
                  : (isDark
                        ? AppColors.messageReceivedDark
                        : AppColors.messageReceived),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // 位置图标
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                // 位置文字
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          color: message.isFromMe
                              ? AppColors.sentText(isDark)
                              : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.messageTextReceived),
                        ),
                      ),
                      if (latitude != null && longitude != null)
                        Text(
                          '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.3,
                            color: message.isFromMe
                                ? AppColors.sentText(
                                    isDark,
                                  ).withValues(alpha: 0.7)
                                : AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 打赏消息（渐变气泡）
  Widget _buildTipMessage() {
    final metadata = message.metadata;
    final amount = metadata?.amount ?? '0';
    final token = metadata?.token ?? '';
    final note = message.content.trim();
    final confirmed = (metadata?.txHash ?? '').isNotEmpty;
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFF9A56)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('💝', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Tip · $amount $token',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              note,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            confirmed ? 'On-chain ✓' : 'Sent',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferMessage() {
    final metadata = message.metadata;
    final amount = metadata?.amount ?? '0';
    final currency = metadata?.token ?? 'ETH';
    final status = metadata?.transferStatus ?? 'pending';

    TransferMessageStatus transferStatus;
    switch (status) {
      case 'completed':
      case 'received':
        transferStatus = TransferMessageStatus.completed;
        break;
      case 'failed':
        transferStatus = TransferMessageStatus.failed;
        break;
      case 'cancelled':
      case 'refunded':
        transferStatus = TransferMessageStatus.cancelled;
        break;
      case 'expired':
        transferStatus = TransferMessageStatus.expired;
        break;
      default:
        transferStatus = TransferMessageStatus.pending;
    }

    return TransferMessageWidget(
      amount: amount,
      currency: currency,
      status: transferStatus,
      note: message.content,
      isSelf: message.isFromMe,
      onTap: onTap,
    );
  }

  Widget _buildPaymentRequestMessage(BuildContext context) {
    final metadata = message.metadata;
    final amount = metadata?.amount ?? '0';
    final currency = metadata?.token ?? 'ETH';
    final status = switch (resolvePaymentRequestStatus(metadata)) {
      PaymentRequestLifecycleStatus.paid => PaymentRequestMessageStatus.paid,
      PaymentRequestLifecycleStatus.expired =>
        PaymentRequestMessageStatus.expired,
      PaymentRequestLifecycleStatus.pending =>
        PaymentRequestMessageStatus.pending,
    };

    return PaymentRequestMessageWidget(
      amount: amount,
      currency: currency,
      status: status,
      note: message.content,
      isSelf: message.isFromMe,
      onTap: onTap,
    );
  }

  Widget _buildRedPacketMessage(BuildContext context) {
    final metadata = message.metadata;
    final status = metadata?.transferStatus ?? 'pending';

    RedPacketStatus redPacketStatus;
    switch (status) {
      case 'opened':
        redPacketStatus = RedPacketStatus.opened;
        break;
      case 'expired':
        redPacketStatus = RedPacketStatus.expired;
        break;
      case 'empty':
        redPacketStatus = RedPacketStatus.empty;
        break;
      default:
        redPacketStatus = RedPacketStatus.pending;
    }

    return RedPacketMessageWidget(
      note: message.content.isNotEmpty
          ? message.content
          : (S.of(context)?.chatDefaultRedPacketGreeting ?? 'Best wishes'),
      status: redPacketStatus,
      isSelf: message.isFromMe,
      onTap: () => onRedPacketTap?.call(message),
    );
  }

  Widget _buildMusicMessage(bool isDark, BuildContext context) {
    final metadata = message.metadata;
    final title =
        metadata?.musicTitle ??
        (S.of(context)?.chatUnknownSong ?? 'Unknown Song');
    final artist =
        metadata?.musicArtist ??
        (S.of(context)?.chatUnknownArtist ?? 'Unknown Artist');
    final cover = metadata?.musicCover;
    final url = metadata?.musicUrl;

    return GestureDetector(
      onTap: () {
        if (url != null && url.isNotEmpty) {
          onTap?.call();
        }
      },
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isFromMe
              ? AppColors.messageSent
              : (isDark
                    ? AppColors.messageReceivedDark
                    : AppColors.messageReceived),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 专辑封面
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: cover != null && cover.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        cover,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.music_note,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.music_note,
                      size: 24,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(width: 12),
            // 歌曲信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: message.isFromMe
                          ? AppColors.sentText(isDark)
                          : context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: message.isFromMe
                          ? AppColors.sentText(isDark).withValues(alpha: 0.7)
                          : context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // 播放图标
            const Icon(
              Icons.play_circle_filled,
              size: 32,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollMessage(bool isDark, BuildContext context) {
    final metadata = message.metadata;
    final question = metadata?.pollQuestion ?? message.content;
    final options = metadata?.pollOptions ?? [];
    final optionIds = metadata?.pollOptionIds ?? [];
    final myVotes = metadata?.myVotes ?? [];
    final voteCounts = metadata?.voteCounts ?? {};
    final totalVoters = metadata?.totalVoters ?? 0;
    final maxSelections = metadata?.maxSelections ?? 1;
    final pollEnded = metadata?.pollEnded ?? false;

    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: message.isFromMe
            ? AppColors.messageSent
            : (isDark
                  ? AppColors.messageReceivedDark
                  : AppColors.messageReceived),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 投票标题
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.poll, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      maxSelections == 1
                          ? (S.of(context)?.chatSingleChoice ?? 'Single')
                          : (S.of(context)?.chatMultiChoice ?? 'Multi'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.3,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (pollEnded)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    S.of(context)?.chatEnded ?? 'Ended',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, height: 1.3, color: context.textTertiary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // 问题
          Text(
            question,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: message.isFromMe
                  ? AppColors.sentText(isDark)
                  : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.messageTextReceived),
            ),
          ),
          const SizedBox(height: 12),

          // 选项
          ...List.generate(options.length, (index) {
            final optionText = options[index];
            final optionId = index < optionIds.length
                ? optionIds[index]
                : '$index';
            final isSelected = myVotes.contains(optionId);
            final voteCount = voteCounts[optionId] ?? 0;
            final percentage = totalVoters > 0
                ? (voteCount / totalVoters * 100)
                : 0.0;

            // 检查是否可以投票或更改投票
            // 1. 投票已结束，不能投票
            // 2. 单选时，可以点击其他选项更改投票
            // 3. 多选时，可以取消已选项或选择新选项（未达最大值时）
            final canChangeVote =
                !pollEnded &&
                (isSelected || // 可以取消已选的
                    myVotes.length < maxSelections || // 可以添加新选择
                    (maxSelections == 1 && myVotes.isNotEmpty) // 单选可以更改
                    );

            return GestureDetector(
              onTap: canChangeVote
                  ? () => onPollVote?.call(
                      message.id,
                      optionId,
                      myVotes,
                      maxSelections,
                    )
                  : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.inputBgOf(isDark),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            optionText,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              color: context.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            size: 18,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                    if (totalVoters > 0) ...[
                      const SizedBox(height: 6),
                      // 投票进度条
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: isDark
                              ? Colors.grey[700]
                              : Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isSelected ? AppColors.primary : Colors.grey,
                          ),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        S
                                .of(context)
                                ?.chatPollVotesFormat(
                                  voteCount,
                                  percentage.toStringAsFixed(0),
                                ) ??
                            '$voteCount votes (${percentage.toStringAsFixed(0)}%)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),

          // 底部统计
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context)?.chatPollParticipantsFormat(totalVoters) ??
                    '$totalVoters participants',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.3,
                  color: AppColors.textSecondary,
                ),
              ),
              if (!pollEnded && message.isFromMe)
                GestureDetector(
                  onTap: () => onEndPoll?.call(message.id),
                  child: Text(
                    S.of(context)?.chatEndPollButton ?? 'End Poll',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEncryptedMessage(bool isDark) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock, size: 16, color: AppColors.textSecondary),
        SizedBox(width: 4),
        Text(
          '[加密消息]',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            height: 1.3,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// 构建通话消息（微信风格）
  Widget _buildCallMessage(BuildContext context) {
    final isDark = context.isDarkMode;
    final metadata = message.metadata;
    final isVideo = message.type == MessageType.videoCall;
    final isMissed = metadata?.isMissedCall ?? false;
    final callDuration = metadata?.callDuration;
    final displayName = _getSenderDisplayName(context);

    // 构建通话状态文本（微信风格）
    String callText;
    if (isMissed) {
      // 未接来电
      callText = message.isFromMe
          ? (S.of(context)?.chatCallNotAnswered ?? '对方未接听')
          : (isVideo
                ? (S.of(context)?.chatMissedVideoCall ?? '未接视频通话')
                : (S.of(context)?.chatMissedVoiceCall ?? '未接语音通话'));
    } else if (callDuration != null && callDuration > 0) {
      // 成功通话 - 微信风格："通话时长 00:55"
      final minutes = callDuration ~/ 60;
      final seconds = callDuration % 60;
      final durationStr =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      callText =
          '${S.of(context)?.chatCallDurationLabel ?? '通话时长'} $durationStr';
    } else {
      // 已取消
      callText = isVideo
          ? (S.of(context)?.chatVideoCallCancelled ?? '视频通话已取消')
          : (S.of(context)?.chatVoiceCallCancelled ?? '语音通话已取消');
    }

    // 未接来电显示红色
    final textColor = isMissed && !message.isFromMe
        ? AppColors.error
        : (message.isFromMe
              ? AppColors.sentText(isDark)
              : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.messageTextReceived));

    final iconColor = isMissed && !message.isFromMe
        ? AppColors.error
        : context.textSecondary;

    return MessageBubble(
      isSelf: message.isFromMe,
      status: _mapStatus(message.status),
      timestamp: message.timestamp,
      showTimestamp: false,
      avatarUrl: message.senderAvatarUrl,
      avatarName: displayName,
      onAvatarTap: onAvatarTap,
      onAvatarDoubleTap: onAvatarDoubleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 通话图标
          Icon(
            isVideo ? Icons.videocam : Icons.phone,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          // 通话文本
          Flexible(
            child: Text(
              callText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, height: 1.3, color: textColor),
            ),
          ),
          // 未接来电显示回拨按钮
          if (isMissed && !message.isFromMe && onCallBack != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onCallBack?.call(message),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVideo ? Icons.videocam : Icons.phone,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      S.of(context)?.chatCallBack ?? '回拨',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  indicator.MessageStatus _mapStatus(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return indicator.MessageStatus.sending;
      case MessageStatus.sent:
        return indicator.MessageStatus.sent;
      case MessageStatus.delivered:
        return indicator.MessageStatus.delivered;
      case MessageStatus.read:
        return indicator.MessageStatus.read;
      case MessageStatus.failed:
        return indicator.MessageStatus.failed;
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatScheduledTime(DateTime scheduledAt) {
    final now = DateTime.now();
    final isToday =
        scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
    final isTomorrow =
        scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day + 1;

    final timeStr =
        '${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';

    if (isToday) return timeStr;
    if (isTomorrow) return 'Tomorrow $timeStr';
    return '${scheduledAt.month}/${scheduledAt.day} $timeStr';
  }

  /// 根据经纬度和 zoom 生成 OSM 瓦片 URL
  static String _osmTileUrl(double lat, double lng, int zoom) {
    final x = ((lng + 180) / 360 * (1 << zoom)).floor();
    final latRad = lat * math.pi / 180;
    final y =
        ((1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
                2 *
                (1 << zoom))
            .floor();
    return 'https://tile.openstreetmap.org/$zoom/$x/$y.png';
  }

  // ============================================
  // 地址检测
  // ============================================

  /// 匹配 0x 地址（40位十六进制）和 ENS 域名（*.eth）
  static final _addressRegex = RegExp(
    r'(0x[a-fA-F0-9]{40})|([a-zA-Z0-9][\w.-]*\.eth)\b',
  );

  /// 构建包含可点击地址的富文本
  Widget _buildRichTextWithAddresses(
    String text,
    Color textColor,
    BuildContext context,
  ) {
    final matches = _addressRegex.allMatches(text).toList();
    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: messageFontSize ?? 16,
          color: textColor,
          height: 1.4,
        ),
      );
    }

    final spans = <InlineSpan>[];
    var lastEnd = 0;

    for (final match in matches) {
      // 添加匹配前的普通文本
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      // 添加可点击的地址 span
      final addr = match.group(0)!;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: () => _showAddressActions(context, addr),
            child: Text(
              addr,
              style: TextStyle(
                fontSize: messageFontSize ?? 16,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary.withValues(alpha: 0.5),
                height: 1.4,
              ),
            ),
          ),
        ),
      );

      lastEnd = match.end;
    }

    // 添加最后一段普通文本
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: messageFontSize ?? 16,
          color: textColor,
          height: 1.4,
        ),
        children: spans,
      ),
    );
  }

  /// 显示地址操作选项
  void _showAddressActions(BuildContext context, String address) {
    final l10n = S.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                address.length > 20
                    ? '${address.substring(0, 10)}...${address.substring(address.length - 8)}'
                    : address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(l10n?.addressCopyAction ?? 'Copy Address'),
              onTap: () {
                Navigator.pop(ctx);
                // 复制到剪贴板
                final data = ClipboardData(text: address);
                Clipboard.setData(data);
              },
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: Text(l10n?.addressSendMessage ?? 'Send Message'),
              onTap: () {
                Navigator.pop(ctx);
                // 跳转到通过钱包地址添加好友页
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
