import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
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
    this.onReaction,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 动态宽度：贴近微信/WhatsApp 占屏比，留 12px 边距
    final menuWidth = (screenWidth - 24.0).clamp(300.0, 420.0);
    final left = _calculateLeft(context, menuWidth);
    final top = _calculateTop(context);

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
              child: _buildMenuContent(context, menuWidth),
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
    if (left + menuWidth > screenWidth - 12) left = screenWidth - menuWidth - 12;
    return left;
  }

  double _calculateTop(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // 表情胶囊(66) + 间距(10) + 卡片两段各2行(2×88+24) ≈ 450
    const menuHeight = 450.0;
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
    top = top.clamp(topPadding + 20, availableHeight - menuHeight - 20);
    return top;
  }

  Widget _buildMenuContent(BuildContext context, double menuWidth) {
    final s = S.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 表情胶囊（WhatsApp 风格：独立圆角胶囊，与操作卡分离）
        _buildReactionBar(),
        const SizedBox(height: 8),
        // 主操作卡片
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 第一组：复制/保存、转发、收藏、撤回/重发、删除、多选
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                child: _buildMenuGrid([
                  if (message.type == MessageType.text)
                    _buildMenuItem(
                      icon: Icons.content_copy_outlined,
                      label: s?.chatCopy ?? 'Copy',
                      onTap: () { onDismiss(); onCopy?.call(); },
                    )
                  else if (message.type == MessageType.image ||
                      message.type == MessageType.video)
                    _buildMenuItem(
                      icon: Icons.download_outlined,
                      label: s?.commonSave ?? 'Save',
                      onTap: () { onDismiss(); onSave?.call(); },
                    ),
                  if (onForward != null)
                    _buildMenuItem(
                      icon: Icons.shortcut_outlined,
                      label: s?.commonForward ?? 'Forward',
                      onTap: () { onDismiss(); onForward?.call(); },
                    ),
                  _buildMenuItem(
                    icon: isFavorited ? Icons.star : Icons.star_border_outlined,
                    label: isFavorited
                        ? (s?.commonUnfavorite ?? 'Unfav')
                        : (s?.commonFavorite ?? 'Fav'),
                    isHighlighted: isFavorited,
                    onTap: () { onDismiss(); onFavorite?.call(); },
                  ),
                  if (message.isFromMe && message.status == MessageStatus.failed)
                    _buildMenuItem(
                      icon: Icons.refresh,
                      label: s?.settingsResend ?? 'Resend',
                      onTap: () { onDismiss(); onResend?.call(); },
                    ),
                  if (message.isFromMe && message.status != MessageStatus.failed)
                    _buildMenuItem(
                      icon: Icons.undo_outlined,
                      label: s?.chatRecall ?? 'Recall',
                      onTap: () { onDismiss(); onRecall?.call(); },
                    ),
                  _buildMenuItem(
                    icon: Icons.delete_outline,
                    label: s?.commonDelete ?? 'Delete',
                    onTap: () { onDismiss(); onDelete?.call(); },
                  ),
                  _buildMenuItem(
                    icon: Icons.checklist_outlined,
                    label: s?.chatSelectMessages ?? 'Select',
                    onTap: () { onDismiss(); onMultiSelect?.call(); },
                  ),
                ]),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                height: 0.5,
                color: Colors.white.withValues(alpha: 0.12),
              ),

              // 第二组：引用、编辑、Thread、翻译、历史、置顶、提醒、搜索、举报
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: _buildMenuGrid([
                  _buildMenuItem(
                    icon: Icons.format_quote_outlined,
                    label: s?.commonQuote ?? 'Quote',
                    onTap: () { onDismiss(); onQuote?.call(); },
                  ),
                  if (message.isFromMe &&
                      message.type == MessageType.text &&
                      onEdit != null)
                    _buildMenuItem(
                      icon: Icons.edit_outlined,
                      label: s?.commonEdit ?? 'Edit',
                      onTap: () { onDismiss(); onEdit?.call(); },
                    ),
                  if (onReplyInThread != null)
                    _buildMenuItem(
                      icon: Icons.forum_outlined,
                      label: s?.threadReplyInThread ?? 'Thread',
                      onTap: () { onDismiss(); onReplyInThread?.call(); },
                    ),
                  if (message.type == MessageType.text && onTranslate != null)
                    _buildMenuItem(
                      icon: Icons.translate,
                      label: s?.commonTranslate ?? 'Translate',
                      onTap: () { onDismiss(); onTranslate?.call(); },
                    ),
                  if (message.isEdited && onViewEditHistory != null)
                    _buildMenuItem(
                      icon: Icons.history,
                      label: s?.chatEditHistory ?? 'History',
                      onTap: () { onDismiss(); onViewEditHistory?.call(); },
                    ),
                  if (canPin)
                    isPinned
                        ? _buildMenuItem(
                            icon: Icons.push_pin,
                            label: s?.conversationUnpin ?? 'Unpin',
                            isHighlighted: true,
                            onTap: () { onDismiss(); onUnpin?.call(); },
                          )
                        : _buildMenuItem(
                            icon: Icons.push_pin_outlined,
                            label: s?.conversationPin ?? 'Pin',
                            onTap: () { onDismiss(); onPin?.call(); },
                          ),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    label: s?.commonRemind ?? 'Remind',
                    onTap: () { onDismiss(); onRemind?.call(); },
                  ),
                  _buildMenuItem(
                    icon: Icons.search,
                    label: s?.commonSearch ?? 'Search',
                    onTap: () { onDismiss(); onSearch?.call(); },
                  ),
                  if (!message.isFromMe && onReport != null)
                    _buildMenuItem(
                      icon: Icons.flag_outlined,
                      label: s?.chatReportMessage ?? 'Report',
                      onTap: () { onDismiss(); onReport?.call(); },
                    ),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 5列等宽网格布局：每行恰好 5 个格子，不足则以空占位补全，
  /// 彻底消除 Wrap 尾行孤立按钮和文字换行问题。
  Widget _buildMenuGrid(List<Widget?> items) {
    const int cols = 5;
    final visible = items.whereType<Widget>().toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    final rows = <Widget>[];
    for (int i = 0; i < visible.length; i += cols) {
      final end = (i + cols).clamp(0, visible.length);
      final rowItems = visible.sublist(i, end);
      rows.add(Row(
        children: [
          ...rowItems.map((w) => Expanded(child: w)),
          // 空占位保证每行等宽对齐
          ...List.generate(
            cols - rowItems.length,
            (_) => const Expanded(child: SizedBox()),
          ),
        ],
      ));
    }
    return Column(children: rows);
  }

  /// 构建表情快速回应栏（WhatsApp 风格独立胶囊）
  Widget _buildReactionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          ..._quickReactions.map((emoji) => _buildReactionItem(emoji)),
          // 更多表情按钮
          _buildMoreReactionButton(),
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
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }

  /// 构建更多表情按钮
  Widget _buildMoreReactionButton() {
    return Builder(
      builder: (context) => Material(
        color: Colors.transparent,
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
            child: const Icon(
              Icons.add,
              color: Colors.white70,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isHighlighted = false,
  }) {
    final color = isHighlighted ? Colors.amber : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.white.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              // FittedBox: 先尝试最多两行；若仍放不下则等比缩小字号，
              // 避免出现截断省略号，也适配多语言较长译文。
              SizedBox(
                height: 32,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: Text(
                    label,
                    style: TextStyle(color: color, fontSize: 12.5),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
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
    final bgColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final separatorColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);
    
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
                      S.of(context)?.commonRecallThisMessage ?? 'Recall this message?',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
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

  const RecalledMessageWidget({
    super.key,
    this.isFromMe = true,
    this.onReEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? Colors.grey[500] : Colors.grey[600];
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
              style: TextStyle(
                fontSize: 12,
                color: textColor,
              ),
            ),
            if (isFromMe && onReEdit != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onReEdit,
                child: Text(
                  s?.commonReEdit ?? 'Re-edit',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF57A5FF) : const Color(0xFF576B95),
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
    final RenderBox? renderBox = messageKey.currentContext?.findRenderObject() as RenderBox?;
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

