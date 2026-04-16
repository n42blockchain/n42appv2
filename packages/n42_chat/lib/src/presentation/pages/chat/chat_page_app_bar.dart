// ignore_for_file: invalid_use_of_protected_member
part of 'chat_page.dart';

/// AppBar 构建相关方法
extension _ChatPageAppBarMethods on _ChatPageState {
  PreferredSizeWidget _buildAppBar(bool isDark) {
    // 多选模式下显示特殊的工具栏
    if (_isMultiSelectMode) {
      return _buildMultiSelectAppBar(isDark);
    }

    // 检测桥接平台
    final bridgePlatform =
        BridgeDetectionUtils.detectFromConversation(widget.conversation);

    return N42AppBar(
      titleWidget: BlocBuilder<ChatBloc, ChatState>(
        buildWhen: (prev, curr) => prev.isChannel != curr.isChannel,
        builder: (context, chatState) {
          return Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (chatState.isChannel)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.campaign,
                        size: 18,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                  // 桥接平台小图标
                  if (bridgePlatform != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        BridgePlatformRegistry.getInfo(bridgePlatform).icon,
                        size: 16,
                        color: BridgePlatformRegistry.getInfo(bridgePlatform).brandColor,
                      ),
                    ),
                  Flexible(
                    child: Text(
                      _getDisplayName(),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (widget.conversation.type == ConversationType.group)
                Text(
                  chatState.isChannel
                      ? '${widget.conversation.memberCount} ${S.of(context)?.channelSubscribers ?? 'subscribers'}'
                      : (S.of(context)?.commonMemberCount(widget.conversation.memberCount) ?? '${widget.conversation.memberCount} members'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          );
        },
      ),
      showBackButton: widget.onBack != null,
      onBackPressed: widget.onBack ?? () => Navigator.of(context).pop(),
      actions: [
        // 私聊显示通话按钮
        if (!widget.conversation.isGroup) ...[
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: _startVoiceCall,
            tooltip: S.of(context)?.commonVoiceCall ?? 'Voice Call',
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: _startVideoCall,
            tooltip: S.of(context)?.chatVideoCall ?? 'Video Call',
          ),
        ],
        // 群聊：话题按钮（如果有子频道）
        if (widget.conversation.isGroup)
          IconButton(
            icon: const Icon(Icons.forum_outlined),
            tooltip: S.of(context)?.groupTopics ?? 'Topics',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GroupTopicsPage(
                    roomId: widget.conversation.id,
                  ),
                ),
              );
            },
          ),
        if (getIt.isRegistered<IAiRepository>())
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            onPressed: () {
              if (_inputController.text.trim().isNotEmpty) {
                _showAiRewriteBar();
              } else {
                _openAiAssistant();
              }
            },
            tooltip: S.of(context)?.aiAssistant ?? 'AI Assistant',
          ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _toggleSearch,
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: widget.onMorePressed ?? _openChatSettings,
        ),
      ],
    );
  }

  /// 构建多选模式下的 AppBar
  PreferredSizeWidget _buildMultiSelectAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      leading: IconButton(
        icon: Icon(
          Icons.close,
          color: isDark ? Colors.white : Colors.black,
        ),
        onPressed: _exitMultiSelectMode,
      ),
      title: Text(
        _selectedMessageIds.isEmpty
            ? (S.of(context)?.chatSelectMessages ?? 'Select messages')
            : (S.of(context)?.chatSelectedCount(_selectedMessageIds.length) ?? 'Selected ${_selectedMessageIds.length}'),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        // 全选按钮
        TextButton(
          onPressed: _selectAllMessages,
          child: Text(
            S.of(context)?.chatSelectAll ?? 'Select All',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ),
      ],
      elevation: 0.5,
    );
  }

  /// 全选消息
  void _selectAllMessages() {
    final state = context.read<ChatBloc>().state;
    setState(() {
      if (_selectedMessageIds.length == state.messages.length) {
        // 如果全部已选中，则取消全选
        _selectedMessageIds.clear();
      } else {
        // 全选
        _selectedMessageIds.clear();
        for (final message in state.messages) {
          _selectedMessageIds.add(message.id);
        }
      }
    });
  }
}
