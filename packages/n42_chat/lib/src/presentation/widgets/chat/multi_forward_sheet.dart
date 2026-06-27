import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/repositories/conversation_repository.dart';
import '../../../core/utils/debug_log.dart';

class MultiForwardSheet extends StatefulWidget {
  final int selectedCount;
  final bool isDark;

  const MultiForwardSheet({
    super.key,
    required this.selectedCount,
    required this.isDark,
  });

  @override
  State<MultiForwardSheet> createState() => _MultiForwardSheetState();
}

class _MultiForwardSheetState extends State<MultiForwardSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<ConversationEntity> _conversations = [];
  List<ConversationEntity> _filteredConversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    try {
      final repository = getIt<IConversationRepository>();
      final conversations = await repository.getConversations();
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _filteredConversations = conversations;
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

  void _filterConversations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredConversations = _conversations;
      } else {
        _filteredConversations = _conversations.where((c) {
          return c.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.surfaceOf(widget.isDark);
    final textColor = AppColors.textPrimaryOf(widget.isDark);
    final subtextColor = AppColors.textSecondaryOf(widget.isDark);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 拖拽指示器
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
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: textColor),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '选择转发对象',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '已选择 ${widget.selectedCount} 条消息',
                        style: TextStyle(
                          fontSize: 12,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48), // 平衡布局
              ],
            ),
          ),
          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterConversations,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: S.of(context)?.chatSearchContactsOrGroups ?? 'Search contacts or groups',
                hintStyle: TextStyle(color: subtextColor),
                prefixIcon: Icon(Icons.search, color: subtextColor),
                filled: true,
                fillColor: widget.isDark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // 会话列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredConversations.isEmpty
                    ? Center(
                        child: Text(
                          _conversations.isEmpty ? '没有可转发的会话' : '未找到匹配的会话',
                          style: TextStyle(color: subtextColor),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredConversations.length,
                        itemBuilder: (context, index) {
                          final chat = _filteredConversations[index];
                          final isGroup = chat.type == ConversationType.group;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getColorFromName(chat.name),
                              backgroundImage: chat.avatarUrl != null && chat.avatarUrl!.isNotEmpty
                                  ? NetworkImage(chat.avatarUrl!)
                                  : null,
                              child: chat.avatarUrl == null || chat.avatarUrl!.isEmpty
                                  ? Icon(
                                      isGroup ? Icons.group : Icons.person,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            title: Text(
                              chat.name,
                              style: TextStyle(color: textColor),
                            ),
                            subtitle: chat.lastMessage != null
                                ? Text(
                                    chat.lastMessage!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subtextColor,
                                    ),
                                  )
                                : null,
                            trailing: Icon(
                              Icons.chevron_right,
                              color: subtextColor,
                            ),
                            onTap: () => Navigator.pop(context, chat.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String name) {
    return AppColorPalettes.getAvatarColor(name);
  }
}

/// 图片查看器页面
