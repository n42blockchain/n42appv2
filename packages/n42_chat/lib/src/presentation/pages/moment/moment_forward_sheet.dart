import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/entities/moment_entity.dart';
import '../../../domain/repositories/message_repository.dart';
import '../../blocs/conversation/conversation_bloc.dart';
import '../../widgets/common/n42_avatar.dart';
import '../../../core/utils/debug_log.dart';

/// 转发朋友圈动态到聊天的底部弹窗
class MomentForwardSheet extends StatefulWidget {
  final MomentEntity moment;

  const MomentForwardSheet({
    super.key,
    required this.moment,
  });

  /// 显示转发弹窗
  static Future<void> show(BuildContext context, MomentEntity moment) {
    // 尝试获取 ConversationBloc
    ConversationBloc? conversationBloc;
    try {
      conversationBloc = context.read<ConversationBloc>();
    } catch (e) {
      debugLog('Error: $e');
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final sheet = MomentForwardSheet(moment: moment);
        if (conversationBloc != null) {
          return BlocProvider.value(
            value: conversationBloc,
            child: sheet,
          );
        }
        return sheet;
      },
    );
  }

  @override
  State<MomentForwardSheet> createState() => _MomentForwardSheetState();
}

class _MomentForwardSheetState extends State<MomentForwardSheet> {
  String _searchQuery = '';

  List<ConversationEntity> _getConversations() {
    try {
      final state = context.read<ConversationBloc>().state;
      return [...state.pinnedConversations, ...state.normalConversations];
    } catch (_) {
      return [];
    }
  }

  List<ConversationEntity> get _filteredConversations {
    final conversations = _getConversations();
    if (_searchQuery.isEmpty) return conversations;
    final query = _searchQuery.toLowerCase();
    return conversations.where((c) {
      return c.name.toLowerCase().contains(query);
    }).toList();
  }

  String _buildForwardText() {
    final s = S.of(context);
    final content = widget.moment.hasContent
        ? widget.moment.content!
        : (widget.moment.hasMedia ? '[Media]' : '');
    final userName = widget.moment.userName;
    return s?.momentForwardContent('$userName: $content') ??
        '[Moment] $userName: $content';
  }

  Future<void> _forwardTo(ConversationEntity conversation) async {
    final s = S.of(context);
    final commentController = TextEditingController();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s?.momentForwardTo ?? 'Forward to'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 目标会话
            Row(
              children: [
                N42Avatar(
                  name: conversation.name,
                  imageUrl: conversation.avatarUrl,
                  size: 36,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    conversation.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 转发内容预览
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _buildForwardText(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: context.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 附言输入
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: s?.momentAddComment ?? 'Add a comment...',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s?.commonSend ?? 'Send'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final messageRepo = getIt<IMessageRepository>();
        var text = _buildForwardText();
        if (commentController.text.trim().isNotEmpty) {
          text = '${commentController.text.trim()}\n\n$text';
        }
        await messageRepo.sendTextMessage(conversation.id, text);

        if (mounted && navigator.mounted && navigator.canPop()) {
          navigator.pop();
        }
        if (messenger.mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(s?.momentForwardSuccess ?? 'Forwarded successfully'),
            ),
          );
        }
      } catch (e) {
        if (messenger.mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                s?.commonRetry ?? 'Forward failed, please try again',
              ),
            ),
          );
        }
      }
    }

    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final s = S.of(context);
    final conversations = _filteredConversations;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // 顶部拖拽指示器
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 标题
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  s?.momentForwardTo ?? 'Forward to',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),

              // 搜索框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: s?.momentSelectFriends ?? 'Search',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 会话列表
              Expanded(
                child: conversations.isEmpty
                    ? Center(
                        child: Text(
                          s?.momentNoConversations ?? 'No conversations',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final conv = conversations[index];
                          return ListTile(
                            leading: N42Avatar(
                              name: conv.name,
                              imageUrl: conv.avatarUrl,
                              size: 44,
                            ),
                            title: Text(
                              conv.name,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            subtitle: conv.lastMessage != null
                                ? Text(
                                    conv.lastMessage!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  )
                                : null,
                            onTap: () => _forwardTo(conv),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
