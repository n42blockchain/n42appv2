// ignore_for_file: invalid_use_of_protected_member
part of 'chat_page.dart';

/// 消息列表构建相关方法
extension _ChatPageMessageListMethods on _ChatPageState {
  Widget _buildMessageList() {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        // 显示错误
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return N42Loading(
            message: S.of(context)?.commonLoading ?? 'Loading...',
          );
        }

        if (state.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEncryptionNotice(),
              const SizedBox(height: 16),
              N42EmptyState.noData(
                title: S.of(context)?.chatNoMessages ?? 'No messages',
                description:
                    S.of(context)?.chatSendFirstMessage ??
                    'Send first message to start chatting',
              ),
            ],
          );
        }

        // 清理不再显示的消息 keys，防止无限增长
        if (_messageKeys.length > state.messages.length + 50) {
          final validIds = state.messages.map((m) => m.id).toSet();
          _messageKeys.removeWhere((id, _) => !validIds.contains(id));
        }

        // 额外项数：输入状态(可选) + 加密提示(1) + 加载更多指示器(可选)
        final typingExtraItems = state.hasTypingUsers ? 1 : 0;
        final extraItems = typingExtraItems + 1 + (state.isLoadingMore ? 1 : 0);

        return ListView.builder(
          controller: _scrollController,
          reverse: true, // 从底部开始显示
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.messages.length + extraItems,
          itemBuilder: (context, index) {
            if (state.hasTypingUsers && index == 0) {
              return TypingIndicator(
                userName: state.typingUsers.length == 1
                    ? state.typingUsers.first
                    : null,
              );
            }

            final messageIndex = index - typingExtraItems;

            // 加载更多指示器（列表顶部，index 最大）
            if (state.isLoadingMore &&
                messageIndex == state.messages.length + 1) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: N42Loading(),
              );
            }

            // 端对端加密提示 + 群聊 AI 摘要（在所有消息之上）
            if (messageIndex == state.messages.length) {
              final isGroup =
                  widget.conversation.type == ConversationType.group;
              final aiAvailable = getIt.isRegistered<AiService>();
              return Column(
                children: [
                  _buildEncryptionNotice(),
                  if (isGroup && aiAvailable) ...[
                    if (_aiSummaryResult != null || _isAiSummarizing)
                      AiSummaryBubble(
                        summary: _aiSummaryResult ?? '',
                        messageCount: state.messages
                            .where((m) => m.type == MessageType.text)
                            .take(50)
                            .length,
                        isLoading: _isAiSummarizing,
                        onDismiss: () => setState(() {
                          _aiSummaryResult = null;
                        }),
                      )
                    else
                      AiSummarizeButton(
                        unreadCount: state.messages
                            .where((m) => m.type == MessageType.text)
                            .take(50)
                            .length,
                        onTap: _summarizeRecentMessages,
                      ),
                  ],
                ],
              );
            }

            final message = state.messages[messageIndex];
            final previousMessage = messageIndex < state.messages.length - 1
                ? state.messages[messageIndex + 1]
                : null;

            // 判断是否显示时间分隔器
            final showTimeSeparator = _shouldShowTimeSeparator(
              message,
              previousMessage,
            );

            // 群聊中判断是否需要显示发送者名称
            // 如果与上一条消息发送者不同，或者时间间隔较大，则显示名称
            final isGroupChat =
                widget.conversation.type == ConversationType.group;
            final showSenderName =
                isGroupChat &&
                !message.isFromMe &&
                (previousMessage == null ||
                    previousMessage.senderId != message.senderId ||
                    _shouldShowTimeSeparator(message, previousMessage));

            // 检查消息是否被撤回：
            // 1. BLoC state 中已是 redacted 类型（服务端确认或乐观更新）
            // 2. 本会话中通过长按菜单撤回的消息（_recalledMessageIds 追踪）
            // 两个条件满足任意一个即显示"已撤回"提示；
            // 长按菜单撤回的消息（最后一条）额外显示"重新编辑"按钮。
            final isRecalled =
                message.type == MessageType.redacted ||
                _recalledMessageIds.contains(message.id);
            if (isRecalled) {
              // 仅对本会话内通过长按菜单撤回的最后一条消息提供"重新编辑"
              final canReEdit =
                  message.isFromMe &&
                  _recalledMessageIds.contains(message.id) &&
                  _lastRecalledContent != null;
              return Column(
                children: [
                  if (showTimeSeparator)
                    TimeSeparator(dateTime: message.timestamp),
                  RecalledMessageWidget(
                    isFromMe: message.isFromMe,
                    onReEdit: canReEdit
                        ? () => _onReEditRecalledMessage()
                        : null,
                  ),
                ],
              );
            }

            // 为消息创建/获取 GlobalKey
            _messageKeys.putIfAbsent(message.id, () => GlobalKey());
            final messageKey = _messageKeys[message.id]!;

            // 翻译状态
            final translatedText = state.translatedMessages[message.id];
            final isTranslatingMsg = state.translatingMessageIds.contains(
              message.id,
            );
            final detectedLang = state.detectedSourceLanguages[message.id];
            final hasTranslation = translatedText != null || isTranslatingMsg;

            return Column(
              children: [
                if (showTimeSeparator)
                  TimeSeparator(dateTime: message.timestamp),
                // 多选模式下显示复选框
                _isMultiSelectMode
                    ? _buildMultiSelectMessageItem(
                        message: message,
                        messageKey: messageKey,
                        isGroupChat: isGroupChat,
                        showSenderName: showSenderName,
                      )
                    : Container(
                        key: messageKey,
                        child: MessageItem(
                          message: message,
                          isHighlighted: message.id == _highlightedMessageId,
                          onTap: () => _onMessageTap(message),
                          onLongPress: () =>
                              _showWeChatMessageMenu(message, messageKey),
                          onAvatarTap: () => _onAvatarTap(message),
                          onAvatarDoubleTap: () => _onAvatarDoubleTap(message),
                          onResend: () => _onResend(message),
                          isGroupChat: isGroupChat,
                          showSenderName: showSenderName,
                          currentUserId: _currentUserId,
                          onReactionTap: (emoji) =>
                              _addReaction(message, emoji),
                          onPollVote:
                              (
                                pollEventId,
                                optionId,
                                currentVotes,
                                maxSelections,
                              ) => _onPollVote(
                                pollEventId,
                                optionId,
                                currentVotes,
                                maxSelections,
                              ),
                          onEndPoll: (pollEventId) => _onEndPoll(pollEventId),
                          onRedPacketTap: _onRedPacketTap,
                          onContactCardTap: _onContactCardTap,
                          onReplyQuoteTap: _scrollToMessage,
                          onThreadTap: _navigateToThread,
                          messageFontSize: _messageFontSize,
                          showLinkPreview: _showLinkPreviews,
                        ),
                      ),
                // 微信风格：翻译结果显示在消息气泡下方
                if (hasTranslation && !_isMultiSelectMode)
                  TranslatedMessageWidget(
                    translatedText: translatedText ?? '',
                    detectedSourceLanguage: detectedLang,
                    isTranslating: isTranslatingMsg,
                    isFromMe: message.isFromMe,
                  ),
                // 智能回复翻译：显示原文
                if (state.smartReplyOriginals.containsKey(message.id) &&
                    message.isFromMe &&
                    !_isMultiSelectMode)
                  TranslatedMessageWidget(
                    translatedText: state.smartReplyOriginals[message.id]!,
                    isFromMe: true,
                    isOriginalDisplay: true,
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// 构建多选模式下的消息项
  Widget _buildMultiSelectMessageItem({
    required MessageEntity message,
    required GlobalKey messageKey,
    required bool isGroupChat,
    required bool showSenderName,
  }) {
    final isRedacted = message.type == MessageType.redacted;
    final isSelected = !isRedacted && _selectedMessageIds.contains(message.id);
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: isRedacted ? null : () => _toggleMessageSelection(message.id),
      child: Container(
        key: messageKey,
        color: isSelected
            ? (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.info.withValues(alpha: 0.1))
            : Colors.transparent,
        child: Row(
          children: [
            // 复选框（已撤回的消息显示禁用状态）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRedacted
                      ? context.dividerColor
                      : (isSelected ? AppColors.primary : Colors.transparent),
                  border: Border.all(
                    // redacted 用 textTertiary（淡，禁用语义）；可选中状态用 textSecondary
                    // 保证未选中圆圈在白底上仍清晰可见。
                    color: isRedacted
                        ? context.textTertiary
                        : (isSelected
                              ? AppColors.primary
                              : context.textSecondary),
                    width: 2,
                  ),
                ),
                child: isRedacted
                    ? Icon(
                        Icons.block,
                        size: 14,
                        color: context.textTertiary,
                      )
                    : (isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null),
              ),
            ),
            // 消息内容
            Expanded(
              child: IgnorePointer(
                child: MessageItem(
                  message: message,
                  isHighlighted: message.id == _highlightedMessageId,
                  onTap: () {},
                  onLongPress: () {},
                  onAvatarTap: () {},
                  onResend: () {},
                  isGroupChat: isGroupChat,
                  showSenderName: showSenderName,
                  currentUserId: _currentUserId,
                  onReactionTap: null, // 多选模式下不响应表情点击
                  onRedPacketTap: null, // 多选模式下不响应红包点击
                  messageFontSize: _messageFontSize,
                  showLinkPreview: _showLinkPreviews,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建端对端加密提示
  Widget _buildEncryptionNotice() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryWithOpacity,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                S.of(context)?.chatEncryptionNotice ??
                    'This chat is end-to-end encrypted. Only you and the recipient can read the messages.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建置顶消息横幅
  Widget _buildPinnedMessageBanner() {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (prev, curr) =>
          prev.pinnedMessages != curr.pinnedMessages ||
          prev.currentPinnedIndex != curr.currentPinnedIndex,
      builder: (context, state) {
        if (state.pinnedMessages.isEmpty) {
          return const SizedBox.shrink();
        }

        final msg = state.currentPinnedMessage;
        if (msg == null) return const SizedBox.shrink();

        final bgColor = context.surfaceColor;
        final textColor = context.textPrimary;
        final secondaryTextColor = context.textSecondary;

        return GestureDetector(
          onTap: () => _scrollToMessage(msg.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(
                bottom: BorderSide(
                  color: context.dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // 置顶图标
                const Icon(Icons.push_pin, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                // 消息内容预览
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.senderName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        _getPinnedMessagePreview(msg),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: textColor),
                      ),
                    ],
                  ),
                ),
                // 多条置顶时显示计数和导航
                if (state.pinnedMessages.length > 1) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      context.read<ChatBloc>().add(
                        const NavigatePinnedMessage(1),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.currentPinnedIndex + 1}/${state.pinnedMessages.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
                // 关闭按钮（如果有权限可以取消置顶）
                if (state.canPinMessages)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 16,
                      color: secondaryTextColor,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      context.read<ChatBloc>().add(UnpinMessage(msg.id));
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 获取置顶消息预览文本
  String _getPinnedMessagePreview(MessageEntity msg) {
    switch (msg.type) {
      case MessageType.text:
        return msg.content;
      case MessageType.image:
        return '[${S.of(context)?.commonImage ?? 'Image'}]';
      case MessageType.video:
        return '[${S.of(context)?.chatVideoTitle ?? 'Video'}]';
      case MessageType.audio:
        return '[${S.of(context)?.chatVoiceMessage ?? 'Voice'}]';
      case MessageType.file:
        return '[${S.of(context)?.commonFile ?? 'File'}] ${msg.metadata?.fileName ?? ''}';
      case MessageType.location:
        return '[${S.of(context)?.chatLocation ?? 'Location'}]';
      default:
        return msg.content.isNotEmpty
            ? msg.content
            : '[${S.of(context)?.chatMessage ?? 'Message'}]';
    }
  }

  Widget _buildReplyPreview() {
    // 预先从父级 context 获取本地化，避免 BlocBuilder 内部 context 语言不正确
    final l10n = S.of(context);

    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (prev, curr) => prev.replyTarget != curr.replyTarget,
      builder: (_, state) {
        if (state.replyTarget == null) {
          return const SizedBox.shrink();
        }

        final replyToText =
            l10n?.chatReplyTo(state.replyTarget!.senderName) ??
            'Reply to ${state.replyTarget!.senderName}';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            border: Border(
              top: BorderSide(
                color: context.dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      replyToText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      state.replyTarget!.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  context.read<ChatBloc>().add(const SetReplyTarget(null));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditPreview() {
    final l10n = S.of(context);

    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (prev, curr) => prev.editingMessage != curr.editingMessage,
      builder: (_, state) {
        if (state.editingMessage == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            border: Border(
              top: BorderSide(
                color: context.dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.commonEdit ?? 'Edit',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      state.editingMessage!.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  context.read<ChatBloc>().add(const SetEditTarget(null));
                  _inputController.clear();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建多选模式底部工具栏
  Widget _buildMultiSelectBottomBar() {
    final hasSelection = _selectedMessageIds.isNotEmpty;

    // 是否有可撤回的消息（自己发的、未被撤回的）
    final stateMessages = context.read<ChatBloc>().state.messages;
    final hasOwnSelection =
        hasSelection &&
        stateMessages.any(
          (m) =>
              _selectedMessageIds.contains(m.id) &&
              m.isFromMe &&
              m.type != MessageType.redacted,
        );

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMultiSelectAction(
            icon: Icons.forward,
            label: S.of(context)?.chatMultiForward ?? 'Forward',
            enabled: hasSelection,
            onTap: hasSelection ? _forwardSelectedMessages : null,
          ),
          _buildMultiSelectAction(
            icon: Icons.star_border,
            label: S.of(context)?.chatCollect ?? 'Collect',
            enabled: hasSelection,
            onTap: hasSelection ? _favoriteSelectedMessages : null,
          ),
          _buildMultiSelectAction(
            icon: Icons.undo,
            label: '撤回',
            enabled: hasOwnSelection,
            onTap: hasOwnSelection ? _recallSelectedMessages : null,
            isDestructive: true,
          ),
          _buildMultiSelectAction(
            icon: Icons.delete_outline,
            label: S.of(context)?.commonDelete ?? 'Delete',
            enabled: hasSelection,
            onTap: hasSelection ? _deleteSelectedMessages : null,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectAction({
    required IconData icon,
    required String label,
    required bool enabled,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final color = !enabled
        ? context.textTertiary
        : isDestructive
        ? AppColors.error
        : context.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
