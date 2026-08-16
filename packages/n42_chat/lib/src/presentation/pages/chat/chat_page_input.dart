// ignore_for_file: invalid_use_of_protected_member
part of 'chat_page.dart';

/// 输入栏、表情选择器、贴纸选择器、更多面板、录音浮层相关方法
extension _ChatPageInputMethods on _ChatPageState {
  Widget _buildInputBar() {
    // 频道只读模式：非管理员不能在公告频道发言
    final chatState = context.read<ChatBloc>().state;
    if (!chatState.canSendMessages) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.background,
          border: Border(
            top: BorderSide(color: context.dividerColor, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 16,
                color: context.textTertiary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  S.of(context)?.channelReadOnly ??
                      'Only admins can post in this channel',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: context.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ChatInputBar(
      key: _inputBarKey,
      controller: _inputController,
      focusNode: _inputFocusNode,
      onSendText: _sendMessage,
      onSendVoice: _sendVoiceMessage,
      onRecordingStateChanged: _onRecordingStateChanged,
      onChanged: _onInputChanged,
      onVoicePressed: _onVoicePressed,
      onEmojiPressed: _onEmojiPressed,
      onMorePressed: _onMorePressed,
      isMorePanelOpen: _showMorePanel,
      onCameraPressed: () {
        _hideMorePanel();
        _takePhoto();
      },
      onQuickReplyPressed: _onQuickReplyPressed,
      onCommandPoll: _createPoll,
      onScheduledSend: _scheduleComposerText,
    );
  }

  /// 录音状态变化处理
  void _onRecordingStateChanged(
    bool isRecording,
    bool isCancelled,
    Duration duration,
  ) {
    setState(() {
      _isRecording = isRecording;
      _isRecordingCancelled = isCancelled;
      _recordingDuration = duration;
    });
  }

  /// 构建录音浮层
  Widget _buildRecordingOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        // 点击空白区域可以取消录音（作为紧急退出方式）
        onTap: () {
          _inputBarKey.currentState?.cancelRecording();
        },
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 录音指示器
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: _isRecordingCancelled
                        ? AppColors.error
                        : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_isRecordingCancelled
                                    ? AppColors.error
                                    : AppColors.primary)
                                .withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isRecordingCancelled ? Icons.delete : Icons.mic,
                        size: 56,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(_recordingDuration),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // 提示文字
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _isRecordingCancelled
                        ? AppColors.error.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isRecordingCancelled
                        ? (S.of(context)?.chatReleaseToCancel ??
                              'Release to cancel')
                        : (S.of(context)?.chatReleaseToSend ??
                              'Release to send, swipe up to cancel'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isRecordingCancelled
                          ? AppColors.error
                          : Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 取消按钮（紧急退出）
                TextButton.icon(
                  onPressed: () {
                    _inputBarKey.currentState?.cancelRecording();
                  },
                  icon: const Icon(Icons.close, color: Colors.white70),
                  label: Text(
                    S.of(context)?.chatTapToCancel ?? 'Tap to cancel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建贴纸选择器面板
  Widget _buildStickerPicker() {
    return StickerPicker(
      onStickerSelected: _onStickerSelected,
      onStickerLongPressed: _onStickerLongPressed,
      onOpenStore: _openStickerStore,
    );
  }

  /// 阅后即焚定时器提示条
  Widget _buildSelfDestructTimerBar() {
    final seconds = _selfDestructAfter!;
    final label = SelfDestructService.formatDuration(seconds);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${S.of(context)?.chatSelfDestructTimer ?? 'Self-destruct'}: $label',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selfDestructAfter = null),
            child: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// 显示阅后即焚定时器选择器
  Future<void> _showSelfDestructTimerPicker() async {
    final l10n = S.of(context);

    final result = await showModalBottomSheet<int?>(
      context: context,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n?.chatTimerPickerTitle ?? 'Self-destruct Timer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1),
              // 关闭选项
              ListTile(
                leading: Icon(
                  Icons.timer_off_outlined,
                  color: _selfDestructAfter == null ? AppColors.primary : null,
                ),
                title: Text(l10n?.chatTimerOff ?? 'Off'),
                trailing: _selfDestructAfter == null
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, -1),
              ),
              const Divider(height: 1),
              // 预设时间列表
              ...SelfDestructTimer.presets.map(
                (preset) => ListTile(
                  leading: Icon(
                    Icons.timer_outlined,
                    color: _selfDestructAfter == preset.seconds
                        ? AppColors.warning
                        : null,
                  ),
                  title: Text(preset.name),
                  trailing: _selfDestructAfter == preset.seconds
                      ? const Icon(Icons.check, color: AppColors.warning)
                      : null,
                  onTap: () => Navigator.pop(ctx, preset.seconds),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _selfDestructAfter = result == -1 ? null : result;
    });
  }

  /// View Once 提示条
  Widget _buildViewOnceIndicator() {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.timer, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              s?.chatViewOnce ?? 'View Once',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isViewOnce = false;
              });
            },
            child: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMorePanel() {
    final shopApp = MiniAppLauncherHelper.findBuiltInAppById(
      MiniAppLauncherHelper.shopAppId,
    );

    return ChatMorePanel(
      recentMediaLoader: _loadRecentMedia,
      onRecentMediaSend: _sendRecentMediaSelection,
      onManageRecentMediaAccess: _manageRecentMediaAccess,
      maxRecentMediaSelection: _isViewOnce ? 1 : 9,
      onPhotoPressed: () {
        _hideMorePanel();
        _showPhotoPickerOptions();
      },
      onPhotoLongPress: () async {
        _hideMorePanel();
        final scheduledAt = await showScheduledSendPicker(context);
        if (!mounted || scheduledAt == null) {
          return;
        }
        await _showPhotoPickerOptions(scheduledAt: scheduledAt);
      },
      onCameraPressed: () {
        _hideMorePanel();
        _takePhoto();
      },
      onVideoCallPressed: () {
        _hideMorePanel();
        _startVideoCall();
      },
      onLocationPressed: () {
        _hideMorePanel();
        _sendLocation();
      },
      onRedPacketPressed: () {
        _hideMorePanel();
        _sendRedPacket();
      },
      onTransferPressed: () {
        _hideMorePanel();
        _sendTransfer();
      },
      onFilePressed: () {
        _hideMorePanel();
        _pickFile();
      },
      onFileLongPress: () async {
        _hideMorePanel();
        final scheduledAt = await showScheduledSendPicker(context);
        if (!mounted || scheduledAt == null) {
          return;
        }
        await _pickFile(scheduledAt: scheduledAt);
      },
      onContactCardPressed: () {
        _hideMorePanel();
        _sendContactCard();
      },
      onFavoritePressed: () {
        _hideMorePanel();
        _openFavorites();
      },
      onMusicPressed: () {
        _hideMorePanel();
        _shareMusic();
      },
      onCodePressed: () {
        _hideMorePanel();
        _composeCodeBlock();
      },
      onWhiteboardPressed: () {
        _hideMorePanel();
        _openWhiteboard();
      },
      onVideoNotePressed: () {
        _hideMorePanel();
        _recordVideoNote();
      },
      onTipPressed: () {
        _hideMorePanel();
        _sendTip();
      },
      onReceivePressed: () {
        _hideMorePanel();
        _openReceive();
      },
      onShopPressed: () {
        _hideMorePanel();
        _openCommerceHub();
      },
      shopLabel: shopApp?.name,
      onPollPressed: () {
        _hideMorePanel();
        _createPoll();
      },
      onEventPressed: () {
        _hideMorePanel();
        _createEvent();
      },
      onGifPressed: () {
        _hideMorePanel();
        _showGifPicker();
      },
      onStickerPressed: () {
        _hideMorePanel();
        _toggleStickerPicker();
      },
      isViewOnce: _isViewOnce,
      onViewOncePressed: () {
        setState(() {
          _isViewOnce = !_isViewOnce;
        });
      },
      onLiveLocationPressed: () {
        _hideMorePanel();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) =>
                LiveLocationPage(roomId: widget.conversation.id),
          ),
        );
      },
      isFaceBlur: _autoFaceBlur,
      onFaceBlurPressed: _toggleFaceBlur,
      selfDestructAfter: _selfDestructAfter,
      onSelfDestructTimerPressed: () {
        _hideMorePanel();
        _showSelfDestructTimerPicker();
      },
      onScheduledPressed: () {
        _hideMorePanel();
        _openScheduledComposerPicker();
      },
      onAiAssistantPressed: getIt.isRegistered<IAiRepository>()
          ? () {
              _hideMorePanel();
              _openAiAssistant();
            }
          : null,
      onMiniAppsPressed: () {
        _hideMorePanel();
        _openMiniApps();
      },
    );
  }

  void _scheduleComposerText(DateTime scheduledAt) {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final mentionPayload = ChatMentionHelper.buildPayload(
      text: text,
      selections: _composerMentions,
      members: _groupMembers,
    );
    context.read<ChatBloc>().add(
      SendScheduledMessage(
        text: text,
        scheduledAt: scheduledAt,
        mentionedUserIds: mentionPayload.mentionedUserIds,
        mentionsRoom: mentionPayload.mentionsRoom,
      ),
    );
    _clearComposerMentions();
  }

  Future<void> _openScheduledComposerPicker() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a message before scheduling'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final scheduledAt = await showScheduledSendPicker(context);
    if (!mounted || scheduledAt == null) {
      return;
    }

    _scheduleComposerText(scheduledAt);
    _inputController.clear();
    _inputFocusNode.requestFocus();
  }

  void _openMiniApps({MiniAppCategory? initialCategory}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MiniAppMarketPage(
          roomId: widget.conversation.id,
          initialCategory: initialCategory,
        ),
      ),
    );
  }

  void _hideMorePanel() {
    setState(() {
      _showMorePanel = false;
      _showEmojiPicker = false;
      _showStickerPicker = false;
    });
  }

  void _onVoicePressed() {
    // 语音录制由 ChatInputBar 内部处理（长按录音模式）
    // 此回调仅用于接收模式切换通知
  }

  void _onEmojiPressed() {
    // 隐藏键盘
    _inputFocusNode.unfocus();
    // 切换统一表情面板（默认 emoji 分页）
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      _expressionInitialTab = ExpressionTab.emoji;
      _showMorePanel = false;
      _showStickerPicker = false;
    });
  }

  void _onMorePressed() {
    final shouldShowPanel = !_showMorePanel;
    if (shouldShowPanel) _inputFocusNode.unfocus();
    setState(() {
      _showMorePanel = shouldShowPanel;
      _showEmojiPicker = false;
    });
    if (!shouldShowPanel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _inputFocusNode.requestFocus();
      });
    }
  }

  /// 代码块输入对话框 → 发送 n42.code_block 消息
  Future<void> _composeCodeBlock() async {
    final codeController = TextEditingController();
    final langController = TextEditingController();
    final send = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: const Text('Send code'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: langController,
                decoration: const InputDecoration(
                  labelText: 'Language',
                  hintText: 'dart / js / python …',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: codeController,
                minLines: 4,
                maxLines: 12,
                autofocus: true,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Paste code here',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(context)?.commonSend ?? 'Send'),
          ),
        ],
      ),
    );
    if (send == true && mounted && codeController.text.trim().isNotEmpty) {
      final lang = langController.text.trim();
      final fenced = '```$lang\n${codeController.text}\n```';
      context.read<ChatBloc>().add(
        SendCustomMessage(content: fenced, type: MessageType.codeBlock),
      );
    }
    codeController.dispose();
    langController.dispose();
  }

  Widget _buildEmojiPicker() {
    return ExpressionPanel(
      height: 320,
      initialTab: _expressionInitialTab,
      onEmojiSelected: (emoji) {
        // 在当前光标位置插入表情
        final text = _inputController.text;
        final selection = _inputController.selection;

        String newText;
        int newCursorPos;

        if (selection.isValid && selection.isCollapsed) {
          // 有光标位置
          final cursorPos = selection.baseOffset;
          newText =
              text.substring(0, cursorPos) + emoji + text.substring(cursorPos);
          newCursorPos = cursorPos + emoji.length;
        } else if (selection.isValid && !selection.isCollapsed) {
          // 有选中文本，替换选中的文本
          newText =
              text.substring(0, selection.start) +
              emoji +
              text.substring(selection.end);
          newCursorPos = selection.start + emoji.length;
        } else {
          // 没有光标，添加到末尾
          newText = text + emoji;
          newCursorPos = newText.length;
        }

        _inputController.text = newText;
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: newCursorPos),
        );
      },
      onBackspace: () {
        // 删除光标前的字符（包括表情）
        final text = _inputController.text;
        final selection = _inputController.selection;

        if (text.isEmpty) return;

        if (selection.isValid && selection.isCollapsed) {
          final cursorPos = selection.baseOffset;
          if (cursorPos > 0) {
            // 处理 emoji（可能是多个代码单元）
            final beforeCursor = text.substring(0, cursorPos);
            final runes = beforeCursor.runes.toList();
            if (runes.isNotEmpty) {
              runes.removeLast();
              final newBeforeCursor = String.fromCharCodes(runes);
              final newText = newBeforeCursor + text.substring(cursorPos);
              _inputController.text = newText;
              _inputController.selection = TextSelection.fromPosition(
                TextPosition(offset: newBeforeCursor.length),
              );
            }
          }
        } else if (selection.isValid && !selection.isCollapsed) {
          // 有选中文本，删除选中的文本
          final newText =
              text.substring(0, selection.start) +
              text.substring(selection.end);
          _inputController.text = newText;
          _inputController.selection = TextSelection.fromPosition(
            TextPosition(offset: selection.start),
          );
        }
      },
      onSend: _inputController.text.isNotEmpty
          ? () {
              _sendMessage(_inputController.text);
              setState(() {
                _showEmojiPicker = false;
              });
            }
          : null,
      onStickerSelected: _onStickerSelected,
      onStickerLongPressed: _onStickerLongPressed,
      onOpenStickerStore: _openStickerStore,
      onGifSelected: _onGifSelectedInline,
    );
  }

  /// 构建 @ 提醒成员选择器
  Widget _buildMentionPicker() {
    final isDark = context.isDarkMode;
    final bgColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final subtextColor = context.textSecondary;
    final borderColor = context.dividerColor;

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: FutureBuilder<List<ChatMentionMember>>(
        future: _groupMembersFuture ??= _loadGroupMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final members = snapshot.data ?? [];
          final suggestions = ChatMentionHelper.buildSuggestions(
            members: members,
            currentUserId: _currentUserId,
            query: _mentionSearchQuery,
          );

          if (suggestions.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _mentionSearchQuery.isEmpty
                    ? (S.of(context)?.chatNoMembers ?? 'No members')
                    : (S.of(context)?.chatMemberNotFound ?? 'Member not found'),
                style: TextStyle(color: subtextColor),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              final name = suggestion.displayName;
              final avatarUrl = suggestion.avatarUrl;
              final isRoomMention = suggestion.mentionsRoom;

              return InkWell(
                onTap: () => _onMentionSuggestionSelected(suggestion),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderColor, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isRoomMention
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.placeholderOf(isDark),
                        backgroundImage: !isRoomMention && avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: isRoomMention
                            ? const Icon(
                                Icons.alternate_email,
                                size: 18,
                                color: AppColors.primary,
                              )
                            : (avatarUrl.isEmpty
                                  ? Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : null),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                height: 1.3,
                              ),
                            ),
                            if (suggestion.subtitle != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  suggestion.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: subtextColor,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onQuickReplyPressed() {
    showQuickReplySheet(
      context: context,
      onSelect: (content) {
        _sendMessage(content);
      },
      onManage: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => QuickRepliesPage(
              storageDataSource: getIt<PreferencesDataSource>(),
            ),
          ),
        );
      },
      storageDataSource: getIt<PreferencesDataSource>(),
      smartReplyLoader: getIt.isRegistered<AiService>()
          ? _loadAiSmartReplies
          : null,
    );
  }
}
