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
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: context.pageBackground,
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
              return _buildConversationTile(context, conversation);
            },
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    ConversationEntity conversation,
  ) {
    final l10n = S.of(context);

    return Container(
      color: context.surfaceColor,
      child: ListTile(
        leading: N42Avatar(
          imageUrl: conversation.avatarUrl,
          name: conversation.name,
          size: 48,
        ),
        title: Text(
          conversation.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.3,
            color: context.textPrimary,
          ),
        ),
        subtitle: conversation.lastMessage != null
            ? Text(
                conversation.lastMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: context.textSecondary,
                ),
              )
            : null,
        trailing: TextButton(
          onPressed: () => _unhideChat(context, conversation),
          child: Text(
            l10n?.settingsUnhideChat ?? 'Unhide',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.3,
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
    final l10n = S.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
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
                  color: context.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 取消隐藏
              ListTile(
                leading: Icon(
                  Icons.visibility_outlined,
                  color: context.textSecondary,
                ),
                title: Text(
                  l10n?.settingsUnhideChat ?? 'Unhide',
                  style: TextStyle(
                    color: context.textPrimary,
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
                  color: context.textSecondary,
                ),
                title: Text(
                  l10n?.commonChat ?? 'Chat',
                  style: TextStyle(
                    color: context.textPrimary,
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
