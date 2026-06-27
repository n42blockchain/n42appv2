import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/repositories/conversation_repository.dart';
import '../../../core/utils/debug_log.dart';
import '../../../core/theme/app_colors.dart';

/// 转发消息对话框
class ForwardMessageSheet extends StatefulWidget {
  final MessageEntity message;
  final bool isDark;
  final void Function(String conversationId) onForwardToChat;

  const ForwardMessageSheet({
    super.key,
    required this.message,
    required this.isDark,
    required this.onForwardToChat,
  });

  @override
  State<ForwardMessageSheet> createState() => _ForwardMessageSheetState();
}

class _ForwardMessageSheetState extends State<ForwardMessageSheet> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<ConversationEntity> _conversations = [];
  bool _isLoading = true;
  bool _isForwarding = false; // 防止重复点击

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final repository = getIt<IConversationRepository>();
      final conversations = await repository.getConversations();
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugLog('Error loading conversations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(widget.isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 拖动条
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  S.of(context)?.chatSelectForwardTargetTitle ?? 'Select Forward Target',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryOf(widget.isDark),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.of(context)?.chatSearchHint ?? 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.inputBgOf(widget.isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // 消息预览
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.inputBgOf(widget.isDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getMessageIcon(widget.message.type),
                  size: 20,
                  color: AppColors.textSecondaryOf(widget.isDark),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getMessagePreview(widget.message),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryOf(widget.isDark),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // 最近会话列表
          Expanded(
            child: _buildRecentChats(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentChats() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredChats = _searchQuery.isEmpty
        ? _conversations
        : _conversations.where((chat) => 
            chat.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    if (filteredChats.isEmpty) {
      return Center(
        child: Text(
          _conversations.isEmpty
              ? (S.of(context)?.chatNoForwardableChat ?? 'No chats available for forwarding')
              : (S.of(context)?.chatNoMatchingChat ?? 'No matching chats found'),
          style: TextStyle(
            color: AppColors.textTertiaryOf(widget.isDark),
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        final isGroup = chat.type == ConversationType.group;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.placeholderOf(widget.isDark),
            backgroundImage: chat.avatarUrl != null && chat.avatarUrl!.isNotEmpty
                ? NetworkImage(chat.avatarUrl!)
                : null,
            child: chat.avatarUrl == null || chat.avatarUrl!.isEmpty
                ? Icon(
                    isGroup ? Icons.group : Icons.person,
                    color: AppColors.textSecondaryOf(widget.isDark),
                  )
                : null,
          ),
          title: Text(
            chat.name,
            style: TextStyle(
              color: AppColors.textPrimaryOf(widget.isDark),
            ),
          ),
          subtitle: chat.lastMessage != null
              ? Text(
                  chat.lastMessage!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiaryOf(widget.isDark),
                  ),
                )
              : null,
          onTap: _isForwarding ? null : () {
            if (_isForwarding) return;
            setState(() => _isForwarding = true);
            widget.onForwardToChat(chat.id);
          },
        );
      },
    );
  }
  
  IconData _getMessageIcon(MessageType type) {
    switch (type) {
      case MessageType.text:
        return Icons.chat_bubble_outline;
      case MessageType.image:
        return Icons.image;
      case MessageType.audio:
        return Icons.mic;
      case MessageType.video:
        return Icons.videocam;
      case MessageType.file:
        return Icons.insert_drive_file;
      case MessageType.location:
        return Icons.location_on;
      default:
        return Icons.chat_bubble_outline;
    }
  }
  
  String _getMessagePreview(MessageEntity message) {
    switch (message.type) {
      case MessageType.text:
        return message.content;
      case MessageType.image:
        return S.of(context)?.commonImage ?? '[Image]';
      case MessageType.audio:
        return S.of(context)?.chatVoice ?? '[Voice]';
      case MessageType.video:
        return S.of(context)?.chatVideo ?? '[Video]';
      case MessageType.file:
        return '${S.of(context)?.commonFile ?? '[File]'} ${message.metadata?.fileName ?? ''}';
      case MessageType.location:
        return '${S.of(context)?.chatLocation ?? '[Location]'} ${message.content}';
      case MessageType.music:
        return '[Music] ${message.metadata?.musicTitle ?? ''}';
      default:
        return S.of(context)?.chatUnknownMessage ?? '[Message]';
    }
  }
}
