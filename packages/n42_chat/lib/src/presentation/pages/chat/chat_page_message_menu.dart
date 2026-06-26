// ignore_for_file: invalid_use_of_protected_member
part of 'chat_page.dart';

/// 消息菜单相关方法（长按菜单、举报、搜索选项）
extension _ChatPageMessageMenuMethods on _ChatPageState {
  void _showMessageMenu(MessageEntity message) {
    // 使用旧的底部菜单作为 fallback
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChatMessageMenuSheet(
        message: message,
        onCopy: () {
          Navigator.pop(ctx);
          _copyMessage(message);
        },
        onReply: () {
          Navigator.pop(ctx);
          context.read<ChatBloc>().add(SetReplyTarget(message));
        },
        onForward:
            (message.type == MessageType.redPacket ||
                message.type == MessageType.transfer ||
                message.type == MessageType.paymentRequest)
            ? null
            : () {
                Navigator.pop(ctx);
                _forwardMessage(message);
              },
        onDelete: message.isFromMe
            ? () {
                Navigator.pop(ctx);
                _recallMessage(message);
              }
            : null,
      ),
    );
  }

  /// 显示微信风格的消息菜单
  void _showWeChatMessageMenu(MessageEntity message, GlobalKey messageKey) {
    // 已撤回的消息不显示菜单
    if (message.type == MessageType.redacted) {
      return;
    }

    // 获取消息气泡的位置和大小
    final RenderBox? renderBox =
        messageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      // fallback 到旧菜单
      _showMessageMenu(message);
      return;
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // 震动反馈
    HapticFeedback.mediumImpact();

    // 显示菜单
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // 获取置顶状态
    final chatState = context.read<ChatBloc>().state;
    final isPinned = chatState.pinnedMessages.any((m) => m.id == message.id);
    final canPin = chatState.canPinMessages;

    overlayEntry = OverlayEntry(
      builder: (ctx) => WeChatMessageMenu(
        message: message,
        position: position,
        messageSize: size,
        isFavorited: _favoritedMessageIds.contains(message.id),
        isPinned: isPinned,
        canPin: canPin,
        onDismiss: () {
          debugLog('Menu dismissed');
          overlayEntry.remove();
        },
        onCopy: () {
          debugLog('Copy clicked');
          _copyMessage(message);
        },
        // 红包、转账和收款请求消息不能转发
        onForward:
            (message.type == MessageType.redPacket ||
                message.type == MessageType.transfer ||
                message.type == MessageType.paymentRequest)
            ? null
            : () {
                debugLog('Forward clicked');
                _forwardMessage(message);
              },
        onFavorite: () {
          debugLog('Favorite clicked');
          _favoriteMessage(message);
        },
        onRecall: () {
          debugLog('Recall clicked');
          _recallMessage(message);
        },
        onMultiSelect: () {
          debugLog('MultiSelect clicked');
          _enterMultiSelectMode();
        },
        onQuote: () {
          debugLog('Quote clicked');
          _quoteMessage(message);
        },
        onRemind: () {
          debugLog('Remind clicked');
          _remindMessage(message);
        },
        onSearch: () {
          debugLog('Search clicked');
          _searchMessage(message);
        },
        onDelete: () {
          debugLog('Delete message locally clicked');
          _deleteMessageLocally(message);
        },
        onResend: () {
          debugLog('Resend clicked');
          _onResend(message);
        },
        onSave: () {
          debugLog('Save clicked');
          _saveMedia(message);
        },
        onReaction: (emoji) {
          debugLog('Reaction clicked: $emoji');
          _addReaction(message, emoji);
        },
        onPin: () {
          debugLog('Pin clicked');
          context.read<ChatBloc>().add(PinMessage(message.id));
        },
        onUnpin: () {
          debugLog('Unpin clicked');
          context.read<ChatBloc>().add(UnpinMessage(message.id));
        },
        onViewEditHistory: message.isEdited
            ? () {
                debugLog('View edit history clicked');
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => EditHistorySheet(
                    roomId: message.roomId,
                    messageId: message.id,
                  ),
                );
              }
            : null,
        onReplyInThread: () {
          debugLog('Reply in thread clicked');
          _navigateToThread(message);
        },
        onEdit: () {
          debugLog('Edit clicked');
          _enterEditMode(message);
        },
        onTranslate:
            (getIt.isRegistered<ITranslationService>() &&
                message.type == MessageType.text)
            ? () {
                debugLog('Translate clicked');
                final chatBloc = context.read<ChatBloc>();
                final targetLang =
                    chatBloc.state.defaultTargetLanguage.isNotEmpty
                    ? chatBloc.state.defaultTargetLanguage
                    : getTargetLanguage(null);
                chatBloc.add(
                  TranslateMessage(
                    messageId: message.id,
                    targetLanguage: targetLang,
                  ),
                );
              }
            : null,
        onReport: message.isFromMe
            ? null
            : () {
                debugLog('Report clicked');
                _showReportDialog(message);
              },
      ),
    );

    overlay.insert(overlayEntry);
  }

  void _showReportDialog(MessageEntity message) {
    final l10n = S.of(context);
    String? selectedReason;
    final reasons = [
      l10n?.chatReportSpam ?? 'Spam',
      l10n?.chatReportHarassment ?? 'Harassment',
      l10n?.chatReportInappropriate ?? 'Inappropriate Content',
      l10n?.chatReportOther ?? 'Other',
    ];
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n?.chatReportMessage ?? 'Report'),
          content: RadioGroup<String>(
            groupValue: selectedReason,
            onChanged: (value) => setDialogState(() => selectedReason = value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: reasons.map((reason) {
                return RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: selectedReason == null
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                      context.read<ChatBloc>().add(
                        ReportMessage(message.id, selectedReason!),
                      );
                    },
              child: Text(l10n?.commonConfirm ?? 'OK'),
            ),
          ],
        ),
      ),
    );
  }

  /// 搜一搜
  void _searchMessage(MessageEntity message) {
    final searchSeed = message.content.trim();
    if (message.type != MessageType.text || searchSeed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.chatOnlyTextSearchable ??
                'Only text messages can be searched',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    unawaited(_openChatHistorySearch(initialQuery: searchSeed));
  }
}
