import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../blocs/conversation/conversation_bloc.dart';
import '../../blocs/conversation/conversation_event.dart';
import '../../blocs/conversation/conversation_state.dart';
import '../../widgets/common/common_widgets.dart';

/// 隐藏聊天列表页面
class HiddenChatsPage extends StatefulWidget {
  /// 点击会话回调（进入聊天）
  final void Function(ConversationEntity conversation)? onConversationTap;

  const HiddenChatsPage({
    super.key,
    this.onConversationTap,
  });

  @override
  State<HiddenChatsPage> createState() => _HiddenChatsPageState();
}

class _HiddenChatsPageState extends State<HiddenChatsPage> {
  @override
  void initState() {
    super.initState();
    // 加载隐藏的会话
    context.read<ConversationBloc>().add(const LoadHiddenConversations());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: l10n?.settingsHiddenChats ?? 'Hidden Chats',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, state) {
          if (state.isLoadingHidden) {
            return N42Loading(message: l10n?.commonLoading ?? 'Loading...');
          }

          if (state.hiddenConversations.isEmpty) {
            return N42EmptyState.noData(
              title: l10n?.settingsNoHiddenChats ?? 'No hidden chats',
              description: l10n?.settingsNoHiddenChatsDescription ??
                  'Chats you hide will appear here',
            );
          }

          return ListView.builder(
            itemCount: state.hiddenConversations.length,
            itemBuilder: (context, index) {
              final conversation = state.hiddenConversations[index];
              return _buildConversationTile(context, conversation, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    ConversationEntity conversation,
    bool isDark,
  ) {
    final l10n = S.of(context);

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: ListTile(
        leading: N42Avatar(
          imageUrl: conversation.avatarUrl,
          name: conversation.name,
          size: 48,
        ),
        title: Text(
          conversation.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: conversation.lastMessage != null
            ? Text(
                conversation.lastMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              )
            : null,
        trailing: TextButton(
          onPressed: () => _unhideChat(context, conversation),
          child: Text(
            l10n?.settingsUnhideChat ?? 'Unhide',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ),
        onTap: () => widget.onConversationTap?.call(conversation),
        onLongPress: () => _showOptions(context, conversation),
      ),
    );
  }

  void _unhideChat(BuildContext context, ConversationEntity conversation) {
    context.read<ConversationBloc>().add(SetConversationHidden(
          conversationId: conversation.id,
          hidden: false,
        ));
  }

  void _showOptions(BuildContext context, ConversationEntity conversation) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖动指示器
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 取消隐藏
              ListTile(
                leading: Icon(
                  Icons.visibility_outlined,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                title: Text(
                  l10n?.settingsUnhideChat ?? 'Unhide',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _unhideChat(context, conversation);
                },
              ),

              // 进入聊天
              ListTile(
                leading: Icon(
                  Icons.chat_outlined,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                title: Text(
                  l10n?.commonChat ?? 'Chat',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onConversationTap?.call(conversation);
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
