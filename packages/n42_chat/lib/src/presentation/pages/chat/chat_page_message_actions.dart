// ignore_for_file: invalid_use_of_protected_member
part of 'chat_page.dart';

/// 消息操作相关方法（复制、转发、撤回、收藏、删除、多选操作、表情回应等）
extension _ChatPageMessageActionsMethods on _ChatPageState {
  /// 复制消息
  void _copyMessage(MessageEntity message) {
    final String textToCopy;

    switch (message.type) {
      case MessageType.text:
        textToCopy = message.content;
      case MessageType.location:
        textToCopy = message.content; // 位置描述
      default:
        // 对于其他类型的消息，复制消息类型描述
        textToCopy = _getMessageTypeDescription(message.type);
    }

    if (textToCopy.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: textToCopy));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)?.chatCopied ?? 'Copied'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getMessageTypeDescription(MessageType type) {
    switch (type) {
      case MessageType.image:
        return S.of(context)?.commonImage ?? '[Image]';
      case MessageType.audio:
        return S.of(context)?.chatVoice ?? '[Voice]';
      case MessageType.video:
        return S.of(context)?.chatVideo ?? '[Video]';
      case MessageType.file:
        return S.of(context)?.commonFile ?? '[File]';
      case MessageType.location:
        return S.of(context)?.chatLocation ?? '[Location]';
      case MessageType.transfer:
        return S.of(context)?.commonTransfer ?? '[Transfer]';
      case MessageType.paymentRequest:
        return '[Payment Request]';
      case MessageType.music:
        return '[Music]';
      default:
        return '';
    }
  }

  /// 转发消息
  void _forwardMessage(MessageEntity message) {
    _showForwardDialog(message);
  }

  /// 显示转发对话框
  Future<void> _showForwardDialog(MessageEntity message) async {
    final isDark = context.isDarkMode;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ForwardMessageSheet(
        message: message,
        isDark: isDark,
        onForwardToChat: (conversationId) {
          Navigator.pop(ctx);
          _doForwardMessage(message, conversationId);
        },
      ),
    );
  }

  /// 执行转发
  Future<void> _doForwardMessage(
    MessageEntity message,
    String targetRoomId,
  ) async {
    debugLog(
      'Forward message: ${message.id} from ${widget.conversation.id} to $targetRoomId',
    );
    debugLog('Message type: ${message.type}, content: ${message.content}');

    // 直接使用简单转发，避免重复发送问题
    // （之前的 repository.forwardMessage 可能发送成功但返回 null，导致 fallback 再次发送）
    try {
      await _simpleForwardMessage(message, targetRoomId);
    } catch (e) {
      debugLog('Forward message error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatForwardFailed(e.toString()) ??
                  'Forward failed: $e',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 简单转发消息（作为备用方案）
  /// 对于媒体消息，下载后重新发送以确保正确转发
  Future<void> _simpleForwardMessage(
    MessageEntity message,
    String targetRoomId,
  ) async {
    final messageRepository = getIt<IMessageRepository>();

    try {
      switch (message.type) {
        case MessageType.text:
          await messageRepository.sendTextMessage(
            targetRoomId,
            message.content,
          );
          break;

        case MessageType.image:
          // 优先使用直接转发 mxc URL 的方式（Matrix SDK 推荐方式）
          final mediaUrl = message.metadata?.mediaUrl;
          if (mediaUrl != null) {
            debugLog(
              'Forward image: Using direct mxc URL forward (recommended)',
            );
            final result = await messageRepository.forwardMediaMessage(
              targetRoomId,
              mxcUrl: mediaUrl,
              msgType: 'm.image',
              filename: message.content.isNotEmpty
                  ? message.content
                  : 'image.jpg',
              mimeType: message.metadata?.mimeType,
              width: message.metadata?.width,
              height: message.metadata?.height,
              size: message.metadata?.size,
              thumbnailUrl: message.metadata?.thumbnailUrl,
            );
            if (result == null) {
              // 直接转发失败，尝试下载后重新上传
              debugLog(
                'Forward image: Direct forward failed, trying download and re-upload',
              );
              final imageBytes = await messageRepository.downloadMedia(
                mediaUrl,
              );
              if (imageBytes != null) {
                await messageRepository.sendImageMessage(
                  targetRoomId,
                  imageBytes: imageBytes,
                  filename: message.content.isNotEmpty
                      ? message.content
                      : 'image.jpg',
                  mimeType: message.metadata?.mimeType,
                );
              } else {
                // 两种方法都失败，抛出异常
                throw Exception(
                  'Image forward failed: Cannot download original image',
                );
              }
            }
          } else {
            throw Exception('Image forward failed: Missing image URL');
          }
          break;

        case MessageType.video:
          // 优先使用直接转发 mxc URL 的方式
          final videoUrl = message.metadata?.mediaUrl;
          if (videoUrl != null) {
            debugLog(
              'Forward video: Using direct mxc URL forward (recommended)',
            );
            final result = await messageRepository.forwardMediaMessage(
              targetRoomId,
              mxcUrl: videoUrl,
              msgType: 'm.video',
              filename: message.content.isNotEmpty
                  ? message.content
                  : 'video.mp4',
              mimeType: message.metadata?.mimeType,
              width: message.metadata?.width,
              height: message.metadata?.height,
              size: message.metadata?.size,
              duration: message.metadata?.duration,
              thumbnailUrl: message.metadata?.thumbnailUrl,
            );
            if (result == null) {
              // 直接转发失败，尝试下载后重新上传
              debugLog(
                'Forward video: Direct forward failed, trying download and re-upload',
              );
              final videoBytes = await messageRepository.downloadMedia(
                videoUrl,
              );
              if (videoBytes != null) {
                await messageRepository.sendVideoMessage(
                  targetRoomId,
                  videoBytes: videoBytes,
                  filename: message.content.isNotEmpty
                      ? message.content
                      : 'video.mp4',
                  mimeType: message.metadata?.mimeType,
                );
              } else {
                throw Exception(
                  'Video forward failed: Cannot download original video',
                );
              }
            }
          } else {
            throw Exception('Video forward failed: Missing video URL');
          }
          break;

        case MessageType.audio:
          // 优先使用直接转发 mxc URL 的方式
          final audioUrl = message.metadata?.mediaUrl;
          if (audioUrl != null) {
            debugLog(
              'Forward audio: Using direct mxc URL forward (recommended)',
            );
            final result = await messageRepository.forwardMediaMessage(
              targetRoomId,
              mxcUrl: audioUrl,
              msgType: 'm.audio',
              filename: message.content.isNotEmpty
                  ? message.content
                  : 'audio.m4a',
              mimeType: message.metadata?.mimeType,
              size: message.metadata?.size,
              duration: message.metadata?.duration,
            );
            if (result == null) {
              // 直接转发失败，尝试下载后重新上传
              debugLog(
                'Forward audio: Direct forward failed, trying download and re-upload',
              );
              final audioBytes = await messageRepository.downloadMedia(
                audioUrl,
              );
              if (audioBytes != null) {
                await messageRepository.sendVoiceMessage(
                  targetRoomId,
                  audioBytes: audioBytes,
                  filename: message.content.isNotEmpty
                      ? message.content
                      : 'audio.m4a',
                  duration: message.metadata?.duration ?? 0,
                  mimeType: message.metadata?.mimeType,
                );
              } else {
                throw Exception(
                  'Voice forward failed: Cannot download original voice',
                );
              }
            }
          } else {
            throw Exception('Voice forward failed: Missing voice URL');
          }
          break;

        case MessageType.file:
          // 下载文件并重新发送
          final fileUrl = message.metadata?.mediaUrl;
          final httpUrl = message.metadata?.httpUrl;
          final fileName = message.metadata?.fileName ?? message.content;
          final originalSize = message.metadata?.size;
          debugLog(
            'Forward file: mediaUrl=$fileUrl, httpUrl=$httpUrl, fileName=$fileName, originalSize=$originalSize',
          );

          // 尝试使用 mediaUrl 或 httpUrl 下载
          Uint8List? fileBytes;
          if (fileUrl != null && fileUrl.isNotEmpty) {
            debugLog('Downloading file from mxc URL: $fileUrl');
            fileBytes = await messageRepository.downloadMedia(fileUrl);
            debugLog(
              'Download result from mxc: ${fileBytes?.length ?? 0} bytes',
            );
          }

          if (fileBytes == null && httpUrl != null && httpUrl.isNotEmpty) {
            debugLog('Fallback: downloading from HTTP URL: $httpUrl');
            try {
              // Matrix 1.11+ 需要认证的媒体访问，需要添加 Authorization header
              final headers =
                  mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
                    httpUrl,
                    client: getIt<MatrixClientManager>().client,
                  );
              final response = await http.get(
                Uri.parse(httpUrl),
                headers: headers,
              );
              if (response.statusCode == 200) {
                fileBytes = response.bodyBytes;
                debugLog(
                  'Download result from http: ${fileBytes.length} bytes',
                );
              } else {
                debugLog(
                  'HTTP download failed with status: ${response.statusCode}',
                );
              }
            } catch (e) {
              debugLog('HTTP download failed: $e');
            }
          }

          if (fileBytes != null && fileBytes.isNotEmpty) {
            debugLog('File downloaded successfully, size: ${fileBytes.length}');
            // 验证文件大小是否正确
            if (originalSize != null && fileBytes.length != originalSize) {
              debugLog(
                'Warning: Downloaded file size (${fileBytes.length}) differs from original ($originalSize)',
              );
            }
            await messageRepository.sendFileMessage(
              targetRoomId,
              fileBytes: fileBytes,
              filename: fileName,
              mimeType: message.metadata?.mimeType,
            );
          } else {
            debugLog('File download failed, cannot forward file');
            // 不再发送文本替代，而是抛出异常让用户知道转发失败
            throw Exception('Unable to download file for forwarding');
          }
          break;

        case MessageType.location:
          // 转发位置消息
          final lat = message.metadata?.latitude;
          final lon = message.metadata?.longitude;
          if (lat != null && lon != null) {
            await messageRepository.sendLocationMessage(
              targetRoomId,
              latitude: lat,
              longitude: lon,
              description: message.content,
            );
          } else {
            throw Exception('Location forward failed: Missing location info');
          }
          break;

        case MessageType.poll:
          // 转发投票消息 - 发送投票快照（包含投票结果，不可再投票）
          final question = message.metadata?.pollQuestion;
          final options = message.metadata?.pollOptions;
          final optionIds = message.metadata?.pollOptionIds;
          final maxSelections = message.metadata?.maxSelections ?? 1;

          if (question != null && options != null && options.isNotEmpty) {
            // 主动获取最新的投票聚合数据，确保转发的投票包含最新结果
            var voteCounts = message.metadata?.voteCounts ?? <String, int>{};
            var totalVoters = message.metadata?.totalVoters ?? 0;

            try {
              final aggregations = await messageRepository.getPollAggregations(
                message.roomId,
                message.id,
              );
              if (aggregations != null) {
                voteCounts =
                    (aggregations['voteCounts'] as Map<String, dynamic>?)
                        ?.cast<String, int>() ??
                    voteCounts;
                totalVoters =
                    aggregations['totalVoters'] as int? ?? totalVoters;
                debugLog(
                  'Forward poll: fetched latest aggregations - voteCounts=$voteCounts, totalVoters=$totalVoters',
                );
              }
            } catch (e) {
              debugLog(
                'Forward poll: failed to fetch aggregations, using cached data: $e',
              );
            }

            debugLog(
              'Forward poll snapshot: question=$question, options=$options, voteCounts=$voteCounts',
            );

            // 确保有optionIds，如果没有则生成
            final effectiveOptionIds =
                optionIds ?? List.generate(options.length, (i) => 'option_$i');

            await messageRepository.sendForwardedPollSnapshot(
              targetRoomId,
              question: question,
              options: options,
              optionIds: effectiveOptionIds,
              voteCounts: voteCounts,
              totalVoters: totalVoters,
              maxSelections: maxSelections,
            );
          } else {
            throw Exception('Poll forward failed: Missing poll info');
          }
          break;

        case MessageType.music:
          // 转发音乐分享消息
          final title = message.metadata?.musicTitle;
          final artist = message.metadata?.musicArtist;
          final url = message.metadata?.musicUrl;
          final cover = message.metadata?.musicCover;

          if (title != null) {
            await messageRepository.sendCustomMessage(
              targetRoomId,
              msgType: 'n42.music',
              content: '🎵 $title - ${artist ?? ''}',
              additionalData: {
                'title': title,
                'artist': artist ?? '',
                'url': url ?? '',
                'cover': cover ?? '',
              },
            );
          } else {
            throw Exception('Music forward failed: Missing music info');
          }
          break;

        default:
          // 未知类型消息，直接发送文本内容
          await messageRepository.sendTextMessage(
            targetRoomId,
            message.content,
          );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatMessageForwarded ?? 'Message forwarded',
            ),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugLog('Simple forward error: $e');
      // 重新抛出异常，让上层处理
      rethrow;
    }
  }

  /// 收藏消息
  void _favoriteMessage(MessageEntity message) {
    final actionBloc = getIt<MessageActionBloc>();

    if (_favoritedMessageIds.contains(message.id)) {
      actionBloc.add(action_event.UnsaveMessage(message.id));
      setState(() => _favoritedMessageIds.remove(message.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)?.chatUnfavorited ?? 'Unfavorited'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      actionBloc.add(action_event.SaveMessage(message));
      setState(() => _favoritedMessageIds.add(message.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)?.chatFavorited ?? 'Favorited'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 收藏选中的消息
  void _favoriteSelectedMessages() {
    if (_selectedMessageIds.isEmpty) return;

    setState(() {
      _favoritedMessageIds.addAll(_selectedMessageIds);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          S.of(context)?.chatCollectMessages(_selectedMessageIds.length) ??
              'Collected ${_selectedMessageIds.length} messages',
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    _exitMultiSelectMode();
  }

  /// 添加或移除表情回应
  void _addReaction(MessageEntity message, String emoji) {
    // 检查当前用户是否已经对这个表情做出了回应
    final existingReaction = message.reactions
        .where((r) => r.key == emoji)
        .firstOrNull;
    final isRemoving = existingReaction != null && existingReaction.isMe;

    debugLog(
      '${isRemoving ? "Removing" : "Adding"} reaction $emoji to message ${message.id}',
    );

    // 通过 ChatBloc 发送表情回应（toggle 逻辑在 bloc 中处理）
    context.read<ChatBloc>().add(
      AddReaction(messageId: message.id, emoji: emoji),
    );

    // 显示反馈 - 根据是添加还是移除显示不同消息
    final feedbackText = isRemoving
        ? (S.of(context)?.chatReactionRemoved ?? 'Reaction removed')
        : (S.of(context)?.chatReactionAdded ?? 'Reaction added');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(feedbackText),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 本地删除消息（仅从本地移除，对方仍可见）
  Future<void> _deleteMessageLocally(MessageEntity message) async {
    // 显示确认对话框
    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) return;

    if (!mounted) return;
    // 本地删除
    context.read<ChatBloc>().add(DeleteMessagesLocally([message.id]));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)?.chatMessageDeleted ?? 'Message deleted'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 显示删除确认对话框
  Future<bool> _showDeleteConfirmDialog() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ChatDeleteConfirmSheet(),
    );
    return result ?? false;
  }

  /// 撤回消息
  Future<void> _recallMessage(MessageEntity message) async {
    if (!message.isFromMe) return;

    // 显示撤回确认对话框
    final confirmed = await showRecallConfirmDialog(context);
    if (!confirmed) return;

    if (!mounted) return;
    // 保存撤回的消息内容，用于"重新编辑"
    if (message.type == MessageType.text) {
      _lastRecalledContent = message.content;
    }

    // 记录撤回的消息 ID
    setState(() {
      _recalledMessageIds.add(message.id);
    });

    // 调用撤回 API
    context.read<ChatBloc>().add(RedactMessage(message.id));
  }

  /// 进入多选模式
  void _enterMultiSelectMode() {
    setState(() {
      _resetAiSmartReplyState();
      _isMultiSelectMode = true;
      _selectedMessageIds.clear();
    });
  }

  /// 退出多选模式
  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedMessageIds.clear();
    });
    if (!_showSearchBar &&
        !_showRewriteBar &&
        _inputController.text.trim().isEmpty) {
      _handleSmartReplyStateChanged(context.read<ChatBloc>().state);
    }
  }

  /// 切换消息选中状态
  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
      } else {
        _selectedMessageIds.add(messageId);
      }
    });
  }

  /// 批量删除选中的消息
  Future<void> _deleteSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;

    // 获取选中的消息（过滤掉已撤回的消息）
    final messages = context.read<ChatBloc>().state.messages;
    final selectedMessages = messages
        .where(
          (m) =>
              _selectedMessageIds.contains(m.id) &&
              m.type != MessageType.redacted,
        )
        .toList();

    // 如果过滤后没有可删除的消息，直接返回
    if (selectedMessages.isEmpty) {
      _exitMultiSelectMode();
      return;
    }

    // 检查是否所有消息都是自己发送的
    final myMessages = selectedMessages.where((m) => m.isFromMe).toList();
    final otherMessages = selectedMessages.where((m) => !m.isFromMe).toList();

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.chatDeleteMessages ?? 'Delete messages'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S
                      .of(context)
                      ?.chatDeleteMessagesConfirm(selectedMessages.length) ??
                  'Are you sure you want to delete ${selectedMessages.length} messages?',
            ),
            if (otherMessages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                S.of(context)?.chatNoteOtherMessages(otherMessages.length) ??
                    'Note: ${otherMessages.length} messages are from others, can only delete locally.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
            if (myMessages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                S
                        .of(context)
                        ?.chatMyMessagesWillBeRecalled(myMessages.length) ??
                    '${myMessages.length} messages from you will be recalled.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              S.of(context)?.commonDelete ?? 'Delete',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    final chatBloc = context.read<ChatBloc>();
    int redactedCount = 0;
    int localDeletedCount = 0;

    // 撤回自己的消息（服务器端删除）
    for (final msg in myMessages) {
      chatBloc.add(RedactMessage(msg.id));
      redactedCount++;
    }

    // 对于他人消息，从本地删除（仅在本地 UI 中移除）
    if (otherMessages.isNotEmpty) {
      final otherMessageIds = otherMessages.map((m) => m.id).toList();
      chatBloc.add(DeleteMessagesLocally(otherMessageIds));
      localDeletedCount = otherMessages.length;
    }

    if (mounted) {
      String message;
      if (redactedCount > 0 && localDeletedCount > 0) {
        message =
            S
                .of(context)
                ?.chatRecalledCount(redactedCount, localDeletedCount) ??
            'Recalled $redactedCount messages, deleted $localDeletedCount locally';
      } else if (redactedCount > 0) {
        message =
            S.of(context)?.chatRecalledMessages(redactedCount) ??
            'Recalled $redactedCount messages';
      } else {
        message =
            S.of(context)?.chatDeletedLocally(localDeletedCount) ??
            'Deleted $localDeletedCount messages (locally)';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }

    _exitMultiSelectMode();
  }

  /// 撤回选中的消息（仅限自己发送的、未撤回的消息）
  Future<void> _recallSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;

    final messages = context.read<ChatBloc>().state.messages;
    final myMessages = messages
        .where(
          (m) =>
              _selectedMessageIds.contains(m.id) &&
              m.isFromMe &&
              m.type != MessageType.redacted,
        )
        .toList();

    if (myMessages.isEmpty) {
      _exitMultiSelectMode();
      return;
    }

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.chatRecall ?? '撤回消息'),
        content: Text('确定撤回 ${myMessages.length} 条消息？撤回后所有人将无法看到这些消息。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              S.of(context)?.chatRecall ?? 'Recall',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final chatBloc = context.read<ChatBloc>();
    for (final msg in myMessages) {
      chatBloc.add(RedactMessage(msg.id));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.chatRecalledMessages(myMessages.length) ??
                '已撤回 ${myMessages.length} 条消息',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }

    _exitMultiSelectMode();
  }

  /// 批量转发选中的消息
  Future<void> _forwardSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;

    // 获取选中的消息（过滤掉红包和转账消息，这些不能转发）
    final messages = context.read<ChatBloc>().state.messages;
    final selectedMessages = messages
        .where(
          (m) =>
              _selectedMessageIds.contains(m.id) &&
              m.type != MessageType.redPacket &&
              m.type != MessageType.transfer &&
              m.type != MessageType.paymentRequest,
        )
        .toList();

    if (selectedMessages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.chatRedPacketTransferCannotForward ??
                'Red envelopes, transfers and payment requests cannot be forwarded',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final isDark = context.isDarkMode;

    // 显示转发目标选择对话框
    final targetRoomId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => MultiForwardSheet(
        selectedCount: selectedMessages.length,
        isDark: isDark,
      ),
    );

    if (targetRoomId == null || !mounted) return;

    // 执行批量转发
    int successCount = 0;
    int failCount = 0;

    for (final message in selectedMessages) {
      try {
        await _simpleForwardMessage(message, targetRoomId);
        successCount++;
      } catch (e) {
        debugLog('Forward message failed: $e');
        failCount++;
      }
    }

    if (mounted) {
      String resultMsg;
      if (failCount == 0) {
        resultMsg =
            S.of(context)?.chatForwardedCount(successCount) ??
            'Forwarded $successCount messages';
      } else {
        resultMsg =
            S.of(context)?.chatForwardComplete(successCount, failCount) ??
            'Forward complete: $successCount succeeded, $failCount failed';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultMsg),
          duration: const Duration(seconds: 2),
          backgroundColor: failCount == 0 ? Colors.green : Colors.orange,
        ),
      );
    }

    _exitMultiSelectMode();
  }

  /// 引用消息
  void _quoteMessage(MessageEntity message) {
    context.read<ChatBloc>().add(SetReplyTarget(message));
  }

  /// 进入编辑模式
  void _enterEditMode(MessageEntity message) {
    // 仅文本消息可编辑
    if (message.type != MessageType.text || !message.isFromMe) return;
    setState(() {
      _resetAiSmartReplyState();
    });
    context.read<ChatBloc>().add(SetEditTarget(message));
    _inputController.text = message.content;
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: message.content.length),
    );
    _inputFocusNode.requestFocus();
  }

  /// 提醒（@某人）
  void _remindMessage(MessageEntity message) {
    // 群聊中才能使用提醒功能
    if (widget.conversation.type != ConversationType.group) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.chatRemindOnlyInGroup ??
                'Remind feature is only available in group chat',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    // 显示群成员选择器
    _showMemberPicker(message);
  }

  /// 显示群成员选择器（@某人）
  Future<void> _showMemberPicker(MessageEntity message) async {
    final isDark = context.isDarkMode;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => MemberPickerSheet(
        roomId: widget.conversation.id,
        isDark: isDark,
        onMemberSelected: (memberName, memberId) {
          Navigator.pop(ctx);
          _insertMention(memberName, memberId);
        },
      ),
    );
  }

  /// 插入@提及
  void _insertMention(String memberName, String memberId) {
    final suggestion = ChatMentionSuggestion(
      type: ChatMentionSuggestionType.user,
      label: memberName,
      displayName: memberName,
      userId: memberId,
    );
    final currentText = _inputController.text;
    final cursorPos = _inputController.selection.baseOffset;
    final insertion = ChatMentionHelper.applySuggestion(
      text: currentText,
      triggerPosition: cursorPos >= 0 ? cursorPos : currentText.length,
      cursorOffset: cursorPos >= 0 ? cursorPos : currentText.length,
      suggestion: suggestion,
    );

    _inputController.text = insertion.text;
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: insertion.cursorOffset),
    );
    setState(() {
      _composerMentions = ChatMentionHelper.mergeSelection(
        selections: _composerMentions,
        selection: insertion.selection,
      );
    });
    _inputFocusNode.requestFocus();
  }

  /// 重新编辑撤回的消息
  void _onReEditRecalledMessage() {
    if (_lastRecalledContent != null) {
      _inputController.text = _lastRecalledContent!;
      _inputFocusNode.requestFocus();
      // 移动光标到末尾
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: _inputController.text.length),
      );
      _lastRecalledContent = null;
    }
  }

  /// 保存媒体文件（图片/视频）
  Future<void> _saveMedia(MessageEntity message) async {
    final imageUrl = message.metadata?.httpUrl ?? message.content;
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.chatNoMediaUrlAvailable ?? 'No media URL available',
          ),
        ),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.chatSaving ?? 'Saving...')),
      );

      // 下载文件
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
          imageUrl,
          client: MatrixClientManager.instance.client,
        ),
      );

      if (response.statusCode == 200) {
        // 保存到相册
        final result = await SaverGallery.saveImage(
          response.bodyBytes,
          fileName: 'n42_${DateTime.now().millisecondsSinceEpoch}.jpg',
          skipIfExists: false,
        );

        if (mounted) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.commonSavedToGallery ?? 'Saved to gallery',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.commonFailedToSave ?? 'Failed to save',
                ),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S
                        .of(context)
                        ?.chatDownloadFailed(response.statusCode.toString()) ??
                    'Download failed: ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugLog('Save media error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatErrorWithMessage(e.toString()) ?? 'Error: $e',
            ),
          ),
        );
      }
    }
  }
}
