// ignore_for_file: invalid_use_of_protected_member
part of 'chat_page.dart';

/// AppBar 构建相关方法
extension _ChatPageAppBarMethods on _ChatPageState {
  PreferredSizeWidget _buildAppBar() {
    // 多选模式下显示特殊的工具栏
    if (_isMultiSelectMode) {
      return _buildMultiSelectAppBar();
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
                        color: context.textPrimary,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.conversation.type == ConversationType.group)
                Text(
                  chatState.isChannel
                      ? '${widget.conversation.memberCount} ${S.of(context)?.channelSubscribers ?? 'subscribers'}'
                      : (S.of(context)?.commonMemberCount(widget.conversation.memberCount) ?? '${widget.conversation.memberCount} members'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: context.textSecondary,
                    fontSize: 12,
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
          tooltip: S.of(context)?.commonSearch ?? 'Search',
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: widget.onMorePressed ?? _openChatSettings,
          tooltip: S.of(context)?.commonMore ?? 'More',
        ),
      ],
    );
  }

  /// 构建多选模式下的 AppBar
  PreferredSizeWidget _buildMultiSelectAppBar() {
    final fgColor = context.textPrimary;
    return AppBar(
      backgroundColor: context.surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(AppIcons.close, color: fgColor),
        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        onPressed: _exitMultiSelectMode,
      ),
      title: Text(
        _selectedMessageIds.isEmpty
            ? (S.of(context)?.chatSelectMessages ?? 'Select messages')
            : (S.of(context)?.chatSelectedCount(_selectedMessageIds.length) ??
                'Selected ${_selectedMessageIds.length}'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.headlineSmall.copyWith(color: fgColor),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: _selectAllMessages,
          child: Text(
            S.of(context)?.chatSelectAll ?? 'Select All',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
          ),
        ),
      ],
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
