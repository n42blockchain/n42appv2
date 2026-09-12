import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/a11y_l10n.dart';
import '../../../domain/entities/message_entity.dart';
import 'message_reaction_bar.dart';

/// 快速表情列表（类似微信/WhatsApp/Element）
const List<String> _quickReactions = ['😀', '🎁', '❤️', '👍', '😂', '😮'];

/// 微信风格的消息长按菜单
///
/// 完美复刻微信的消息操作菜单，包括：
/// - 气泡上方/下方的弹出菜单
/// - 表情快速回应栏（类似WhatsApp/Element）
/// - 两行图标按钮布局
/// - 撤回确认对话框
class WeChatMessageMenu extends StatelessWidget {
  final MessageEntity message;
  final Offset position;
  final Size messageSize;
  final VoidCallback onDismiss;

  // 状态
  final bool isFavorited;
  final bool isPinned;
  final bool canPin;

  // 回调函数
  final VoidCallback? onCopy;
  final VoidCallback? onForward;
  final VoidCallback? onFavorite;
  final VoidCallback? onRecall;
  final VoidCallback? onMultiSelect;
  final VoidCallback? onQuote;
  final VoidCallback? onRemind;
  final VoidCallback? onSearch;
  final VoidCallback? onDelete; // 删除发送失败的消息
  final VoidCallback? onResend; // 重新发送失败的消息
  final VoidCallback? onSave; // 保存图片/视频
  final VoidCallback? onPin; // 置顶消息
  final VoidCallback? onUnpin; // 取消置顶
  final VoidCallback? onTranslate; // 翻译消息
  final VoidCallback? onViewEditHistory; // 查看编辑历史
  final VoidCallback? onReplyInThread; // 在线程中回复
  final VoidCallback? onEdit; // 编辑消息
  final VoidCallback? onReport; // 举报消息
  final VoidCallback? onRemindMe; // 设为待办提醒
  final VoidCallback? onReadingMode; // 长文阅读模式
  final VoidCallback? onSpeak; // 朗读（TTS）
  final VoidCallback? onExtractText; // 图片文字提取
  final VoidCallback? onTranslateImage; // 图片翻译

  /// 表情回应回调
  final void Function(String emoji)? onReaction;

  const WeChatMessageMenu({
    super.key,
    required this.message,
    required this.position,
    required this.messageSize,
    required this.onDismiss,
    this.isFavorited = false,
    this.isPinned = false,
    this.canPin = false,
    this.onCopy,
    this.onForward,
    this.onFavorite,
    this.onRecall,
    this.onMultiSelect,
    this.onQuote,
    this.onRemind,
    this.onSearch,
    this.onDelete,
    this.onResend,
    this.onSave,
    this.onPin,
    this.onUnpin,
    this.onTranslate,
    this.onViewEditHistory,
    this.onReplyInThread,
    this.onEdit,
    this.onReport,
    this.onRemindMe,
    this.onReadingMode,
    this.onSpeak,
    this.onExtractText,
    this.onTranslateImage,
    this.onReaction,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 动态宽度：贴近微信/WhatsApp 占屏比，留 12px 边距
    final menuWidth = (screenWidth - 24.0).clamp(0.0, 360.0);
    final left = _calculateLeft(context, menuWidth);
    final top = _calculateTop(context);
    final media = MediaQuery.of(context);
    final availableHeight =
        media.size.height - media.viewInsets.bottom - media.padding.bottom;

    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Container(color: Colors.black.withValues(alpha: 0.45)),
            Positioned(
              left: left,
              top: top,
              width: menuWidth,
              // Expanded actions remain scrollable above the keyboard.
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: (availableHeight - top - 12).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
                child: SingleChildScrollView(
                  child: _buildMenuContent(context, menuWidth),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateLeft(BuildContext context, double menuWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    double left = (screenWidth - menuWidth) / 2;
    if (position.dx < screenWidth / 3) {
      left = 12;
    } else if (position.dx > screenWidth * 2 / 3) {
      left = screenWidth - menuWidth - 12;
    }
    if (left < 12) left = 12;
    if (left + menuWidth > screenWidth - 12) {
      left = screenWidth - menuWidth - 12;
    }
    return left;
  }

  double _calculateTop(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Estimate the compact card; expanded content scrolls within bounds.
    const menuHeight = 270.0;
    const padding = 8.0;

    final availableHeight = screenHeight - keyboardHeight - bottomPadding;

    double top = position.dy - menuHeight - padding;
    if (top < topPadding + 60) {
      top = position.dy + messageSize.height + padding;
    }
    if (top + menuHeight > availableHeight - 20) {
      top = position.dy - menuHeight - padding;
      if (top < topPadding + 60) {
        top = (topPadding + 60 + availableHeight - menuHeight) / 2;
      }
    }
    // 小屏 + 键盘展开时 availableHeight-menuHeight-20 可能 < 下界（top+20），
    // 直接 clamp 会因 lowerLimit>upperLimit 抛 ArgumentError（长按即崩）。
    // 用 math.max 保证上界 ≥ 下界；此时菜单由外层 ConstrainedBox 限高+滚动。
    final lower = topPadding + 20;
    final upper = math.max(lower, availableHeight - menuHeight - 20);
    top = top.clamp(lower, upper);
    return top;
  }

  Widget _buildMenuContent(BuildContext context, double menuWidth) {
    final s = S.of(context);
    final persistent = !message.isSelfDestructing;
    final text = message.type == MessageType.text;
    final image = message.type == MessageType.image;
    final actions = <_MenuAction>[];
    void add(
      String id,
      IconData icon,
      String label,
      VoidCallback? callback, {
      bool allowed = true,
    }) {
      if (!allowed || callback == null) return;
      actions.add(
        _MenuAction(id, icon, label, () {
          onDismiss();
          callback();
        }),
      );
    }

    add(
      'quote',
      Icons.reply_outlined,
      s?.commonQuote ?? 'Quote',
      onQuote,
      allowed: persistent,
    );
    add(
      'copy',
      Icons.content_copy_outlined,
      s?.chatCopy ?? 'Copy',
      onCopy,
      allowed: persistent && text,
    );
    add(
      'save',
      Icons.download_outlined,
      s?.commonSave ?? 'Save',
      onSave,
      allowed: persistent && (image || message.type == MessageType.video),
    );
    add(
      'forward',
      Icons.shortcut_outlined,
      s?.commonForward ?? 'Forward',
      onForward,
      allowed: persistent,
    );
    add(
      'thread',
      Icons.forum_outlined,
      s?.threadReplyInThread ?? 'Thread',
      onReplyInThread,
      allowed: persistent,
    );
    add(
      'edit',
      Icons.edit_outlined,
      s?.commonEdit ?? 'Edit',
      onEdit,
      allowed: message.isFromMe && text,
    );
    add(
      'resend',
      Icons.refresh,
      s?.settingsResend ?? 'Resend',
      onResend,
      allowed: message.isFromMe && message.status == MessageStatus.failed,
    );
    add(
      'favorite',
      isFavorited ? Icons.star : Icons.star_border_outlined,
      isFavorited
          ? (s?.commonUnfavorite ?? 'Unfav')
          : (s?.commonFavorite ?? 'Fav'),
      onFavorite,
      allowed: persistent,
    );
    add(
      'select',
      Icons.checklist_outlined,
      s?.chatSelectMessages ?? 'Select',
      onMultiSelect,
    );
    add(
      'translate',
      Icons.translate,
      s?.commonTranslate ?? 'Translate',
      onTranslate,
      allowed: persistent && text,
    );
    add(
      'extract',
      Icons.text_snippet_outlined,
      A11yL10n.of(context).extractText,
      onExtractText,
      allowed: persistent && image,
    );
    add(
      'translate-image',
      Icons.translate,
      A11yL10n.of(context).translateImage,
      onTranslateImage,
      allowed: persistent && image,
    );
    add(
      'speak',
      Icons.volume_up,
      s?.chatReadAloud ?? 'Read Aloud',
      onSpeak,
      allowed: persistent && text,
    );
    add(
      'reading',
      Icons.menu_book_outlined,
      s?.chatReadingMode ?? 'Reading mode',
      onReadingMode,
      allowed: persistent,
    );
    add(
      'history',
      Icons.history,
      s?.chatEditHistory ?? 'History',
      onViewEditHistory,
      allowed: persistent && message.isEdited,
    );
    add(
      'pin',
      isPinned ? Icons.push_pin : Icons.push_pin_outlined,
      isPinned
          ? (s?.conversationUnpin ?? 'Unpin')
          : (s?.conversationPin ?? 'Pin'),
      isPinned ? onUnpin : onPin,
      allowed: canPin && persistent,
    );
    add(
      'remind-me',
      Icons.alarm_add_outlined,
      s?.commonRemind ?? 'Remind',
      onRemindMe,
      allowed: persistent,
    );
    add(
      'remind',
      Icons.notifications_outlined,
      s?.commonRemind ?? 'Remind',
      onRemind,
      allowed: persistent,
    );
    add(
      'search',
      Icons.search,
      s?.commonSearch ?? 'Search',
      onSearch,
      allowed: persistent,
    );
    add(
      'recall',
      Icons.undo_outlined,
      s?.chatRecall ?? 'Recall',
      onRecall,
      allowed: message.isFromMe && message.status != MessageStatus.failed,
    );
    add('delete', Icons.delete_outline, s?.commonDelete ?? 'Delete', onDelete);
    add(
      'report',
      Icons.flag_outlined,
      s?.chatReportMessage ?? 'Report',
      onReport,
      allowed: !message.isFromMe,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onReaction != null) ...[
          _buildReactionBar(),
          const SizedBox(height: 8),
        ],
        _CompactActionCard(actions: actions),
      ],
    );
  }

  /// 构建表情快速回应栏（WhatsApp 风格独立胶囊）
  Widget _buildReactionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ..._quickReactions
              .take(5)
              .map((emoji) => Expanded(child: _buildReactionItem(emoji))),
          // 更多表情按钮
          Expanded(child: _buildMoreReactionButton()),
        ],
      ),
    );
  }

  /// 构建单个表情项
  Widget _buildReactionItem(String emoji) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onDismiss();
          onReaction?.call(emoji);
        },
        borderRadius: BorderRadius.circular(24),
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 26)),
        ),
      ),
    );
  }

  /// 构建更多表情按钮
  Widget _buildMoreReactionButton() {
    return Builder(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Semantics(
          button: true,
          label: A11yL10n.of(context).moreReactions,
          excludeSemantics: true,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              // 先关闭当前菜单
              onDismiss();
              // 显示完整表情选择器
              showModalBottomSheet<void>(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (ctx) => FullReactionPicker(
                  onReactionSelected: (emoji) {
                    onReaction?.call(emoji);
                  },
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.add, color: Colors.white70, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuAction {
  final String id;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuAction(this.id, this.icon, this.label, this.onTap);
}

class _CompactActionCard extends StatefulWidget {
  final List<_MenuAction> actions;
  const _CompactActionCard({required this.actions});

  @override
  State<_CompactActionCard> createState() => _CompactActionCardState();
}

class _CompactActionCardState extends State<_CompactActionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final actions = widget.actions;
    final hasMore = actions.length > 8;
    final visible = hasMore && !_expanded ? actions.take(7).toList() : actions;
    return Material(
      color: const Color(0xFF2C2C2E),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
            final columns = scale > 1.4 ? 3 : 4;
            final width = constraints.maxWidth / columns;
            return Wrap(
              children: [
                for (final action in visible)
                  _button(
                    action.id,
                    action.icon,
                    action.label,
                    action.onTap,
                    width,
                  ),
                if (hasMore)
                  _button(
                    'more',
                    _expanded ? Icons.expand_less : Icons.more_horiz,
                    _expanded
                        ? MaterialLocalizations.of(context).expandedIconTapHint
                        : (S.of(context)?.commonMore ?? 'More'),
                    () => setState(() => _expanded = !_expanded),
                    width,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _button(
    String id,
    IconData icon,
    String label,
    VoidCallback onTap,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Tooltip(
        message: label,
        child: InkWell(
          key: ValueKey('message-action-$id'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 显示微信风格的撤回确认对话框
Future<bool> showRecallConfirmDialog(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _RecallConfirmSheet(),
  );
  return result ?? false;
}

/// 微信风格的撤回确认底部弹窗
class _RecallConfirmSheet extends StatelessWidget {
  const _RecallConfirmSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = AppColors.surfaceOf(isDark);
    final separatorColor = AppColors.dividerOf(isDark);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 主要内容
            Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      S.of(context)?.commonRecallThisMessage ??
                          'Recall this message?',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textTertiary,
                      ),
                    ),
                  ),

                  // 分隔线
                  Container(height: 0.5, color: separatorColor),

                  // 撤回按钮
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, true),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                          S.of(context)?.chatRecall ?? 'Recall',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFFFF3B30), // iOS red
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 取消按钮
            Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context, false),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      S.of(context)?.commonCancel ?? 'Cancel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: isDark ? Colors.white : const Color(0xFF007AFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// WeChat-style recalled message widget
class RecalledMessageWidget extends StatelessWidget {
  final bool isFromMe;
  final VoidCallback? onReEdit;

  const RecalledMessageWidget({super.key, this.isFromMe = true, this.onReEdit});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = context.textTertiary;
    final s = S.of(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              isFromMe
                  ? (s?.commonYouRecalledMessage ?? 'You recalled a message')
                  : (s?.commonMessageRecalled ?? 'Message recalled'),
              style: TextStyle(fontSize: 12, color: textColor),
            ),
            if (isFromMe && onReEdit != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onReEdit,
                child: Text(
                  s?.commonReEdit ?? 'Re-edit',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF57A5FF)
                        : const Color(0xFF576B95),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 消息菜单助手类
class MessageMenuHelper {
  /// 显示微信风格的消息菜单
  static void showMenu({
    required BuildContext context,
    required MessageEntity message,
    required GlobalKey messageKey,
    VoidCallback? onCopy,
    VoidCallback? onForward,
    VoidCallback? onFavorite,
    VoidCallback? onRecall,
    VoidCallback? onMultiSelect,
    VoidCallback? onQuote,
    VoidCallback? onRemind,
    VoidCallback? onSearch,
    VoidCallback? onDelete,
    VoidCallback? onResend,
    VoidCallback? onSave,
    VoidCallback? onTranslate,
    VoidCallback? onReplyInThread,
    void Function(String emoji)? onReaction,
    bool isFavorited = false,
  }) {
    // 获取消息气泡的位置和大小
    final RenderBox? renderBox =
        messageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // 震动反馈
    HapticFeedback.mediumImpact();

    // 显示菜单
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (ctx) => WeChatMessageMenu(
        message: message,
        position: position,
        messageSize: size,
        isFavorited: isFavorited,
        onDismiss: () => overlayEntry.remove(),
        onCopy: onCopy,
        onForward: onForward,
        onFavorite: onFavorite,
        onRecall: onRecall,
        onMultiSelect: onMultiSelect,
        onQuote: onQuote,
        onRemind: onRemind,
        onSearch: onSearch,
        onDelete: onDelete,
        onResend: onResend,
        onSave: onSave,
        onTranslate: onTranslate,
        onReplyInThread: onReplyInThread,
        onReaction: onReaction,
      ),
    );

    overlay.insert(overlayEntry);
  }

  /// 复制文本消息
  static void copyMessage(BuildContext context, MessageEntity message) {
    if (message.type == MessageType.text) {
      Clipboard.setData(ClipboardData(text: message.content));
      _showToast(context, S.of(context)?.chatCopied ?? 'Copied');
    }
  }

  /// 显示轻提示
  static void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
