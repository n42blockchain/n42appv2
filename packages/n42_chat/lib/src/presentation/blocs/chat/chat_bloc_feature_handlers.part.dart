part of 'chat_bloc.dart';

/// 功能性 handler 方法
///
/// 包含：阅后即焚（自毁消息）、定时发送消息、语音转文字、
/// 置顶消息、消息翻译等。
extension ChatBlocFeatureHandlers on ChatBloc {
  // ============================================
  // 阅后即焚（自毁消息）
  // ============================================

  /// 开始消息的自毁倒计时
  Future<void> onStartMessageDestruction(
    StartMessageDestruction event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    try {
      // 查找消息
      final messageIndex = state.messages.indexWhere(
        (m) => m.id == event.messageId,
      );
      if (messageIndex == -1) return;

      final message = state.messages[messageIndex];

      // 检查是否是阅后即焚消息且倒计时未开始
      if (!message.isSelfDestructing || message.isDestructionStarted) return;

      // 计算销毁时间
      final destroyedAt = DateTime.now().add(
        Duration(seconds: message.selfDestructAfter!),
      );

      // 保存到本地存储
      await _secureStorage.setMessageDestroyedAt(
        _currentRoomId!,
        event.messageId,
        destroyedAt,
      );

      // 更新消息状态
      final updatedMessages = List<MessageEntity>.from(state.messages);
      updatedMessages[messageIndex] = message.copyWith(
        destroyedAt: destroyedAt,
      );

      if (!isClosed) {
        emit(state.copyWith(messages: updatedMessages));
      }

      debugLog(
        'ChatBloc: Started destruction countdown for message ${event.messageId}, will destroy at $destroyedAt',
      );
    } catch (e) {
      debugLog('ChatBloc: Failed to start message destruction: $e');
    }
  }

  /// 销毁已过期的阅后即焚消息
  Future<void> onDestroyExpiredMessages(
    DestroyExpiredMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    final now = DateTime.now();
    final expiredMessageIds = <String>[];

    // 找出所有已过期的消息
    for (final message in state.messages) {
      if (message.isSelfDestructing &&
          message.isDestructionStarted &&
          message.destroyedAt!.isBefore(now)) {
        expiredMessageIds.add(message.id);
      }
    }

    if (expiredMessageIds.isEmpty) return;

    debugLog(
      'ChatBloc: Destroying ${expiredMessageIds.length} expired messages',
    );

    // 从本地列表中移除
    _locallyDeletedMessageIds.addAll(expiredMessageIds);
    final updatedMessages = state.messages
        .where((m) => !expiredMessageIds.contains(m.id))
        .toList();

    if (!isClosed) {
      emit(state.copyWith(messages: updatedMessages));
    }

    // 异步撤回消息（不阻塞 UI）
    for (final messageId in expiredMessageIds) {
      try {
        await _messageRepository.redactMessage(
          _currentRoomId!,
          messageId,
          reason: 'Self-destructed',
        );
      } catch (e) {
        debugLog('ChatBloc: Failed to redact expired message $messageId: $e');
      }
    }

    // 清除销毁时间记录
    await _secureStorage.clearMessageDestructionTimes(
      _currentRoomId!,
      expiredMessageIds,
    );
  }

  /// 更新阅后即焚消息的倒计时状态
  void onUpdateDestructionCountdown(
    UpdateDestructionCountdown event,
    Emitter<ChatState> emit,
  ) {
    final messageIndex = state.messages.indexWhere(
      (m) => m.id == event.messageId,
    );
    if (messageIndex == -1) return;

    final message = state.messages[messageIndex];
    if (!message.isSelfDestructing) return;

    final updatedMessages = List<MessageEntity>.from(state.messages);
    updatedMessages[messageIndex] = message.copyWith(
      destroyedAt: event.destroyedAt,
    );

    if (!isClosed) {
      emit(state.copyWith(messages: updatedMessages));
    }
  }

  // ============================================
  // 定时发送消息
  // ============================================

  /// 发送定时消息
  Future<void> onSendScheduledMessage(
    SendScheduledMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    try {
      final normalizedText = event.text.trim();
      final payload = Map<String, dynamic>.from(event.payload ?? const {});
      if (!_isValidScheduledDraft(
        type: event.type,
        text: normalizedText,
        payload: payload,
      )) {
        return;
      }

      final selfDestructAfter = await _resolveSelfDestructAfter(
        event.selfDestructAfter,
      );
      // 生成临时消息ID
      final tempId = 'scheduled_${DateTime.now().millisecondsSinceEpoch}';

      // 获取当前用户ID
      final currentUserId = await _messageRepository.getCurrentUserId() ?? '';

      final draft = ScheduledMessageDraft(
        messageId: tempId,
        text: normalizedText,
        type: event.type,
        scheduledAt: event.scheduledAt,
        createdAt: DateTime.now(),
        selfDestructAfter: selfDestructAfter,
        mentionedUserIds: event.mentionedUserIds ?? const [],
        mentionsRoom: event.mentionsRoom,
        payload: payload,
      );

      // 保存定时消息到本地存储
      await _secureStorage.saveScheduledMessage(
        roomId: _currentRoomId!,
        messageId: tempId,
        text: draft.text,
        type: draft.type,
        payload: draft.payload,
        scheduledAt: draft.scheduledAt,
        selfDestructAfter: selfDestructAfter,
        mentionedUserIds: draft.mentionedUserIds,
        mentionsRoom: draft.mentionsRoom,
      );

      // 创建临时消息显示在UI中
      final tempMessage = draft.toPreviewMessage(
        roomId: _currentRoomId!,
        senderId: currentUserId,
      );

      // 添加到消息列表
      if (!isClosed) {
        emit(state.copyWith(messages: [tempMessage, ...state.messages]));
      }

      debugLog(
        'ChatBloc: Scheduled message saved - $tempId for ${event.scheduledAt}',
      );
    } catch (e) {
      debugLog('ChatBloc: Failed to schedule message: $e');
      if (!isClosed) {
        emit(state.copyWith(error: 'Failed to schedule message'));
      }
    }
  }

  /// 取消定时消息
  Future<void> onCancelScheduledMessage(
    CancelScheduledMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    try {
      final draft = await _findScheduledDraft(_currentRoomId!, event.messageId);
      if (draft != null) {
        await _removeScheduledDraftRecord(draft, emit);
      } else {
        await _secureStorage.removeScheduledMessage(
          _currentRoomId!,
          event.messageId,
        );
        _emitWithoutScheduledPreview(event.messageId, emit);
      }

      debugLog('ChatBloc: Scheduled message cancelled - ${event.messageId}');
    } catch (e) {
      debugLog('ChatBloc: Failed to cancel scheduled message: $e');
    }
  }

  /// 发送到期的定时消息
  Future<void> onSendDueScheduledMessages(
    SendDueScheduledMessages event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // 获取所有到期的定时消息
      final dueMessages = await _secureStorage.getDueScheduledMessages();
      if (dueMessages.isEmpty) return;

      debugLog('ChatBloc: Found ${dueMessages.length} due scheduled messages');

      for (final draft in dueMessages) {
        final roomId = draft.roomId;
        if (roomId == null || roomId.isEmpty) {
          debugLog(
            'ChatBloc: Skip scheduled message without room id - ${draft.messageId}',
          );
          continue;
        }

        try {
          await _sendScheduledDraft(draft);

          await _removeScheduledDraftRecord(draft, emit);

          debugLog('ChatBloc: Sent scheduled message - ${draft.messageId}');
        } catch (e) {
          debugLog(
            'ChatBloc: Failed to send scheduled message ${draft.messageId}: $e',
          );

          if (await _shouldDiscardFailedScheduledDraft(draft)) {
            await _removeScheduledDraftRecord(draft, emit);
            debugLog(
              'ChatBloc: Discarded scheduled draft with unreadable local attachment - ${draft.messageId}',
            );
          }
        }
      }
    } catch (e) {
      debugLog('ChatBloc: Failed to process due scheduled messages: $e');
    }
  }

  bool _isValidScheduledDraft({
    required MessageType type,
    required String text,
    required Map<String, dynamic> payload,
  }) {
    switch (type) {
      case MessageType.poll:
        final options = (payload['options'] as List<dynamic>?)
            ?.map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
        return text.isNotEmpty && (options?.length ?? 0) >= 2;
      case MessageType.image:
        return (payload['gifUrl'] as String?)?.isNotEmpty == true ||
            _hasValidScheduledLocalAttachmentPayload(payload);
      case MessageType.video:
      case MessageType.file:
        return _hasValidScheduledLocalAttachmentPayload(payload);
      case MessageType.sticker:
        return (payload['stickerId'] as String?)?.isNotEmpty == true &&
            (payload['packId'] as String?)?.isNotEmpty == true &&
            (payload['url'] as String?)?.isNotEmpty == true;
      default:
        return text.isNotEmpty;
    }
  }

  bool _hasValidScheduledLocalAttachmentPayload(Map<String, dynamic> payload) =>
      (payload['localPath'] as String?)?.isNotEmpty == true &&
      (payload['filename'] as String?)?.trim().isNotEmpty == true;

  Future<void> _sendScheduledDraft(ScheduledMessageDraft draft) async {
    final roomId = draft.roomId;
    if (roomId == null || roomId.isEmpty) {
      throw StateError('Scheduled draft missing roomId');
    }

    switch (draft.type) {
      case MessageType.poll:
        await _messageRepository.sendPollMessage(
          roomId,
          question: draft.text,
          options: draft.pollOptions,
          maxSelections: draft.pollMaxSelections,
          isAnonymous: draft.payload['isAnonymous'] as bool? ?? false,
        );
        return;
      case MessageType.image:
        if (draft.isGif) {
          await _messageRepository.sendGifMessage(
            roomId,
            gifUrl: draft.payload['gifUrl'] as String,
            previewUrl: draft.payload['previewUrl'] as String?,
            width: draft.payload['width'] as int?,
            height: draft.payload['height'] as int?,
            title: draft.text.isEmpty ? null : draft.text,
          );
          return;
        }

        await _sendScheduledLocalImage(draft);
        return;
      case MessageType.video:
        await _sendScheduledLocalVideo(draft);
        return;
      case MessageType.file:
        await _sendScheduledLocalFile(draft);
        return;
      case MessageType.sticker:
        await _messageRepository.sendStickerMessage(
          roomId,
          stickerId: draft.payload['stickerId'] as String,
          packId: draft.payload['packId'] as String,
          url: draft.payload['url'] as String,
          httpUrl: draft.payload['httpUrl'] as String?,
          name: draft.payload['name'] as String?,
          emoji: draft.payload['emoji'] as String?,
          width: draft.payload['width'] as int?,
          height: draft.payload['height'] as int?,
          mimeType: draft.payload['mimeType'] as String?,
          size: draft.payload['size'] as int?,
        );
        return;
      default:
        await _messageRepository.sendTextMessage(
          roomId,
          draft.text,
          selfDestructAfter: draft.selfDestructAfter,
          mentionedUserIds: draft.mentionedUserIds,
          mentionsRoom: draft.mentionsRoom,
        );
    }
  }

  Future<void> _sendScheduledLocalImage(ScheduledMessageDraft draft) async {
    final file = await _requireScheduledAttachmentFile(draft);
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw StateError('Scheduled image attachment is empty');
    }

    await _messageRepository.sendImageMessage(
      draft.roomId!,
      imageBytes: bytes,
      filename: draft.attachmentFilename,
      mimeType:
          draft.attachmentMimeType ??
          lookupMimeType(file.path, headerBytes: bytes) ??
          'image/jpeg',
      selfDestructAfter: draft.selfDestructAfter,
    );
  }

  Future<void> _sendScheduledLocalVideo(ScheduledMessageDraft draft) async {
    final file = await _requireScheduledAttachmentFile(draft);
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw StateError('Scheduled video attachment is empty');
    }

    Uint8List? thumbnailBytes;
    try {
      thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 320,
        quality: 75,
      );
    } catch (e) {
      debugLog(
        'ChatBloc: Failed to build thumbnail for scheduled video ${draft.messageId}: $e',
      );
    }

    await _messageRepository.sendVideoMessage(
      draft.roomId!,
      videoBytes: bytes,
      filename: draft.attachmentFilename,
      mimeType:
          draft.attachmentMimeType ?? lookupMimeType(file.path) ?? 'video/mp4',
      thumbnailBytes: thumbnailBytes,
      selfDestructAfter: draft.selfDestructAfter,
    );
  }

  Future<void> _sendScheduledLocalFile(ScheduledMessageDraft draft) async {
    final file = await _requireScheduledAttachmentFile(draft);
    final fileSize = draft.attachmentFileSize ?? await file.length();

    if (_requiresEncryptedFileUpload(draft.roomId!)) {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw StateError('Scheduled file attachment is empty');
      }

      await _messageRepository.sendFileMessage(
        draft.roomId!,
        fileBytes: bytes,
        filename: draft.attachmentFilename,
        mimeType:
            draft.attachmentMimeType ??
            lookupMimeType(file.path) ??
            'application/octet-stream',
        selfDestructAfter: draft.selfDestructAfter,
        fileSize: fileSize,
      );
      return;
    }

    await _messageRepository.sendFileMessage(
      draft.roomId!,
      filename: draft.attachmentFilename,
      mimeType:
          draft.attachmentMimeType ??
          lookupMimeType(file.path) ??
          'application/octet-stream',
      selfDestructAfter: draft.selfDestructAfter,
      filePath: file.path,
      fileSize: fileSize,
    );
  }

  bool _requiresEncryptedFileUpload(String roomId) {
    final client = _clientManager?.client;
    final room = client?.getRoomById(roomId);
    if (client == null || room == null) {
      return true;
    }

    return room.encrypted && client.fileEncryptionEnabled;
  }

  Future<File> _requireScheduledAttachmentFile(
    ScheduledMessageDraft draft,
  ) async {
    final path = draft.localAttachmentPath;
    if (path == null || path.isEmpty) {
      throw StateError('Scheduled draft missing local attachment path');
    }

    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('Scheduled attachment file not found', path);
    }

    return file;
  }

  Future<bool> _shouldDiscardFailedScheduledDraft(
    ScheduledMessageDraft draft,
  ) async {
    if (!draft.hasLocalAttachment) {
      return false;
    }

    final path = draft.localAttachmentPath;
    if (path == null || path.isEmpty) {
      return true;
    }

    try {
      final file = File(path);
      if (!await file.exists()) {
        return true;
      }

      return await file.length() <= 0;
    } catch (_) {
      return true;
    }
  }

  Future<ScheduledMessageDraft?> _findScheduledDraft(
    String roomId,
    String messageId,
  ) async {
    final drafts = await _secureStorage.getScheduledMessages(roomId);
    for (final draft in drafts) {
      if (draft.messageId == messageId) {
        return draft.copyWith(roomId: roomId);
      }
    }
    return null;
  }

  Future<void> _removeScheduledDraftRecord(
    ScheduledMessageDraft draft,
    Emitter<ChatState> emit,
  ) async {
    final roomId = draft.roomId;
    if (roomId == null || roomId.isEmpty) {
      return;
    }

    await _secureStorage.removeScheduledMessage(roomId, draft.messageId);
    await _deleteScheduledDraftArtifacts(draft);
    if (roomId == _currentRoomId) {
      _emitWithoutScheduledPreview(draft.messageId, emit);
    }
  }

  Future<void> _deleteScheduledDraftArtifacts(
    ScheduledMessageDraft draft,
  ) async {
    final path = draft.localAttachmentPath;
    if (path == null || path.isEmpty) {
      return;
    }

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugLog(
        'ChatBloc: Failed to delete scheduled attachment artifact ${draft.messageId}: $e',
      );
    }
  }

  void _emitWithoutScheduledPreview(String messageId, Emitter<ChatState> emit) {
    if (isClosed) {
      return;
    }

    final updatedMessages = state.messages
        .where((message) => message.id != messageId)
        .toList(growable: false);
    emit(state.copyWith(messages: updatedMessages));
  }

  // ============================================
  // 语音转文字
  // ============================================

  /// 语音消息转文字
  Future<void> onTranscribeVoiceMessage(
    TranscribeVoiceMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    try {
      // 查找消息
      final messageIndex = state.messages.indexWhere(
        (m) => m.id == event.messageId,
      );
      if (messageIndex == -1) {
        debugLog(
          'ChatBloc: Message not found for transcription: ${event.messageId}',
        );
        return;
      }

      final message = state.messages[messageIndex];

      // 检查是否是语音消息
      if (message.type != MessageType.voice &&
          message.type != MessageType.audio) {
        debugLog('ChatBloc: Message is not a voice message: ${message.type}');
        return;
      }

      // 检查是否已经有转录结果
      if (message.metadata?.hasTranscription == true) {
        debugLog('ChatBloc: Message already has transcription');
        return;
      }

      if (message.metadata?.isTranscribing == true) {
        debugLog('ChatBloc: Message is already transcribing');
        return;
      }

      // 更新状态为正在转录
      final updatedMessages = List<MessageEntity>.from(state.messages);
      updatedMessages[messageIndex] = message.copyWith(
        metadata: (message.metadata ?? const MessageMetadata())
            .copyWithTranscription(
              transcriptionStatus: TranscriptionStatus.transcribing,
            ),
      );

      if (!isClosed) {
        emit(state.copyWith(messages: updatedMessages));
      }

      // 获取语音文件路径
      String? audioPath = event.audioPath;
      if (audioPath == null && message.metadata?.mediaUrl != null) {
        // 如果没有提供路径，尝试下载音频
        final mxcUrl = message.metadata!.mediaUrl!;
        try {
          final bytes = await _messageRepository.downloadMedia(mxcUrl);
          if (bytes != null) {
            // 保存到临时文件
            final tempDir = Directory.systemTemp;
            final tempFile = File(
              '${tempDir.path}/voice_${event.messageId}.m4a',
            );
            await tempFile.writeAsBytes(bytes);
            audioPath = tempFile.path;
          }
        } catch (e) {
          debugLog('ChatBloc: Failed to download voice message: $e');
        }
      }

      if (audioPath == null) {
        debugLog('ChatBloc: No audio path available for transcription');
        add(
          VoiceTranscriptionCompleted(
            messageId: event.messageId,
            success: false,
          ),
        );
        return;
      }

      // 调用语音转文字服务
      final speechService = SpeechToTextService();
      if (!speechService.isConfigured) {
        debugLog('ChatBloc: Speech-to-text service not configured');
        add(
          VoiceTranscriptionCompleted(
            messageId: event.messageId,
            success: false,
          ),
        );
        return;
      }

      final transcription = await speechService.transcribe(
        audioPath,
        language: event.language,
      );

      // 发送完成事件
      add(
        VoiceTranscriptionCompleted(
          messageId: event.messageId,
          transcription: transcription,
          success: transcription != null,
        ),
      );
    } catch (e) {
      debugLog('ChatBloc: Failed to transcribe voice message: $e');
      add(
        VoiceTranscriptionCompleted(messageId: event.messageId, success: false),
      );
    }
  }

  /// 语音转文字完成
  void onVoiceTranscriptionCompleted(
    VoiceTranscriptionCompleted event,
    Emitter<ChatState> emit,
  ) {
    final messageIndex = state.messages.indexWhere(
      (m) => m.id == event.messageId,
    );
    if (messageIndex == -1) return;

    final message = state.messages[messageIndex];
    final updatedMessages = List<MessageEntity>.from(state.messages);

    updatedMessages[messageIndex] = message.copyWith(
      metadata: (message.metadata ?? const MessageMetadata())
          .copyWithTranscription(
            transcription: event.transcription,
            transcriptionStatus: event.success
                ? TranscriptionStatus.success
                : TranscriptionStatus.failed,
          ),
    );

    if (!isClosed) {
      emit(state.copyWith(messages: updatedMessages));
    }

    if (event.success) {
      debugLog(
        'ChatBloc: Voice transcription completed: ${event.transcription}',
      );
    } else {
      debugLog(
        'ChatBloc: Voice transcription failed for message ${event.messageId}',
      );
    }
  }

  // ============================================
  // 置顶消息处理
  // ============================================

  /// 加载置顶消息
  Future<void> onLoadPinnedMessages(
    LoadPinnedMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null || _groupRepository == null) return;

    try {
      final pinnedEventIds = await _groupRepository.getPinnedEventIds(
        _currentRoomId!,
      );
      final canPin = _groupRepository.canPinMessages(_currentRoomId!);

      // 从当前消息列表中查找置顶消息（优先内存缓存，fallback 远程拉取）
      final pinnedMessages = <MessageEntity>[];
      for (final eventId in pinnedEventIds) {
        // 快速路径：已在内存中
        final cached = state.messages.where((m) => m.id == eventId).firstOrNull;
        if (cached != null) {
          pinnedMessages.add(cached);
          continue;
        }
        // 慢速路径：从服务器/本地 DB 获取（历史置顶消息尚未分页到内存）
        final fetched = await _groupRepository.getMessageById(
          _currentRoomId!,
          eventId,
        );
        if (fetched != null) {
          pinnedMessages.add(fetched);
        }
      }

      emit(
        state.copyWith(
          pinnedMessages: pinnedMessages,
          canPinMessages: canPin,
          currentPinnedIndex: 0,
        ),
      );

      debugLog(
        'ChatBloc: Loaded ${pinnedMessages.length} pinned messages, canPin=$canPin',
      );
    } catch (e) {
      debugLog('ChatBloc: Failed to load pinned messages: $e');
    }
  }

  /// 置顶消息
  Future<void> onPinMessage(PinMessage event, Emitter<ChatState> emit) async {
    if (_currentRoomId == null || _groupRepository == null) return;

    try {
      await _groupRepository.pinMessage(_currentRoomId!, event.messageId);
      // 重新加载置顶消息
      add(const LoadPinnedMessages());
      debugLog('ChatBloc: Pinned message ${event.messageId}');
    } catch (e) {
      debugLog('ChatBloc: Failed to pin message: $e');
      emit(state.copyWith(error: 'Failed to pin message: $e'));
    }
  }

  /// 取消置顶消息
  Future<void> onUnpinMessage(
    UnpinMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null || _groupRepository == null) return;

    try {
      await _groupRepository.unpinMessage(_currentRoomId!, event.messageId);
      // 重新加载置顶消息
      add(const LoadPinnedMessages());
      debugLog('ChatBloc: Unpinned message ${event.messageId}');
    } catch (e) {
      debugLog('ChatBloc: Failed to unpin message: $e');
      emit(state.copyWith(error: 'Failed to unpin message: $e'));
    }
  }

  /// 切换显示的置顶消息
  void onNavigatePinnedMessage(
    NavigatePinnedMessage event,
    Emitter<ChatState> emit,
  ) {
    if (state.pinnedMessages.isEmpty) return;

    var newIndex = state.currentPinnedIndex + event.delta;
    // 循环显示
    if (newIndex < 0) {
      newIndex = state.pinnedMessages.length - 1;
    } else if (newIndex >= state.pinnedMessages.length) {
      newIndex = 0;
    }

    emit(state.copyWith(currentPinnedIndex: newIndex));
  }

  // ============================================
  // 消息翻译处理
  // ============================================

  /// 翻译消息
  Future<void> onTranslateMessage(
    TranslateMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_translationService == null) {
      debugLog('ChatBloc: Translation service not available');
      add(
        TranslationCompleted(
          messageId: event.messageId,
          success: false,
          error: 'Translation service not configured',
        ),
      );
      return;
    }

    // 检查是否已经在翻译中
    if (state.isTranslating(event.messageId)) {
      debugLog(
        'ChatBloc: Message ${event.messageId} is already being translated',
      );
      return;
    }

    // 检查是否已有翻译结果
    final existingTranslation = state.getTranslation(event.messageId);
    if (existingTranslation != null) {
      debugLog('ChatBloc: Message ${event.messageId} already has translation');
      return;
    }

    // 查找消息
    final message = state.messages.firstWhere(
      (m) => m.id == event.messageId,
      orElse: () => MessageEntity(
        id: '',
        roomId: '',
        senderId: '',
        senderName: '',
        content: '',
        timestamp: DateTime.now(),
        type: MessageType.text,
        status: MessageStatus.sent,
        isFromMe: false,
      ),
    );

    if (message.id.isEmpty || message.type != MessageType.text) {
      debugLog('ChatBloc: Cannot translate message - not a text message');
      return;
    }

    // 更新状态为正在翻译
    final newTranslatingIds = Set<String>.from(state.translatingMessageIds)
      ..add(event.messageId);
    emit(state.copyWith(translatingMessageIds: newTranslatingIds));

    try {
      debugLog(
        'ChatBloc: Translating message ${event.messageId} to ${event.targetLanguage}',
      );

      final result = await _translationService.translate(
        text: message.content,
        targetLanguage: event.targetLanguage,
      );

      add(
        TranslationCompleted(
          messageId: event.messageId,
          translatedText: result.translatedText,
          detectedSourceLanguage: result.detectedSourceLanguage,
          success: result.success,
          error: result.error,
        ),
      );
    } catch (e) {
      debugLog('ChatBloc: Translation error: $e');
      add(
        TranslationCompleted(
          messageId: event.messageId,
          success: false,
          error: e.toString(),
        ),
      );
    }
  }

  /// 翻译完成
  void onTranslationCompleted(
    TranslationCompleted event,
    Emitter<ChatState> emit,
  ) {
    // 移除正在翻译状态
    final newTranslatingIds = Set<String>.from(state.translatingMessageIds)
      ..remove(event.messageId);

    if (event.success && event.translatedText != null) {
      // 保存翻译结果
      final newTranslatedMessages = Map<String, String>.from(
        state.translatedMessages,
      )..[event.messageId] = event.translatedText!;

      // 保存检测到的源语言
      final newDetectedLanguages = Map<String, String>.from(
        state.detectedSourceLanguages,
      );
      if (event.detectedSourceLanguage != null) {
        newDetectedLanguages[event.messageId] = event.detectedSourceLanguage!;
      }

      emit(
        state.copyWith(
          translatingMessageIds: newTranslatingIds,
          translatedMessages: newTranslatedMessages,
          detectedSourceLanguages: newDetectedLanguages,
        ),
      );

      debugLog(
        'ChatBloc: Translation completed for message ${event.messageId}',
      );
    } else {
      // 翻译失败
      emit(
        state.copyWith(
          translatingMessageIds: newTranslatingIds,
          error: event.error ?? 'Translation failed',
        ),
      );

      debugLog(
        'ChatBloc: Translation failed for message ${event.messageId}: ${event.error}',
      );
    }
  }

  /// 清除消息翻译
  void onClearTranslation(ClearTranslation event, Emitter<ChatState> emit) {
    final newTranslatedMessages = Map<String, String>.from(
      state.translatedMessages,
    )..remove(event.messageId);
    final newDetectedLanguages = Map<String, String>.from(
      state.detectedSourceLanguages,
    )..remove(event.messageId);

    emit(
      state.copyWith(
        translatedMessages: newTranslatedMessages,
        detectedSourceLanguages: newDetectedLanguages,
      ),
    );

    debugLog('ChatBloc: Cleared translation for message ${event.messageId}');
  }

  /// 更新翻译设置
  Future<void> onUpdateTranslationSettings(
    UpdateTranslationSettings event,
    Emitter<ChatState> emit,
  ) async {
    final newAutoTranslate = event.autoTranslate ?? state.autoTranslate;
    final newTargetLang =
        event.defaultTargetLanguage ?? state.defaultTargetLanguage;
    final newSmartReply =
        event.smartReplyTranslate ?? state.smartReplyTranslate;

    emit(
      state.copyWith(
        autoTranslate: newAutoTranslate,
        defaultTargetLanguage: newTargetLang,
        smartReplyTranslate: newSmartReply,
      ),
    );

    // 持久化设置
    try {
      await _secureStorage.saveTranslationSettings(
        autoTranslate: newAutoTranslate,
        defaultTargetLanguage: newTargetLang,
        smartReplyTranslate: newSmartReply,
      );
    } catch (e) {
      debugLog('ChatBloc: Failed to save translation settings: $e');
    }

    // 如果刚开启自动翻译，对当前可见的未翻译消息触发翻译
    if (newAutoTranslate) {
      _autoTranslateMessages(emit);
    }

    // 如果刚开启智能回复翻译，立即检测对方语言
    if (newSmartReply && _translationService != null) {
      _detectRecipientLanguage(emit);
    }
  }

  /// 翻译设置加载完成
  void _onTranslationSettingsLoaded(
    TranslationSettingsLoaded event,
    Emitter<ChatState> emit,
  ) {
    emit(
      state.copyWith(
        autoTranslate: event.autoTranslate,
        defaultTargetLanguage: event.defaultTargetLanguage,
        smartReplyTranslate: event.smartReplyTranslate,
      ),
    );

    if (event.autoTranslate) {
      _autoTranslateMessages(emit);
    }

    // 如果智能回复翻译已开启，立即检测对方语言
    if (event.smartReplyTranslate && _translationService != null) {
      _detectRecipientLanguage(emit);
    }
  }

  /// 自动翻译未翻译的消息（每次最多 5 条，防止 API 洪水）
  void _autoTranslateMessages(Emitter<ChatState> emit) {
    if (_translationService == null) return;

    final targetLang = state.defaultTargetLanguage;
    final messagesToTranslate = state.messages
        .where(
          (m) =>
              !m.isFromMe &&
              m.type == MessageType.text &&
              m.content.trim().isNotEmpty &&
              !state.translatedMessages.containsKey(m.id) &&
              !state.translatingMessageIds.contains(m.id),
        )
        .take(5)
        .toList();

    for (final msg in messagesToTranslate) {
      // 检测消息语言，与目标语言相同则跳过
      _translationService.detectLanguage(msg.content).then((detected) {
        if (detected != targetLang && !isClosed) {
          add(TranslateMessage(messageId: msg.id, targetLanguage: targetLang));
        }
      });
    }
  }

  // ============================================
  // 智能回复翻译 — 对方语言检测
  // ============================================

  /// 检测对方最近消息的语言
  ///
  /// 从 state.messages 中取最近一条非自己的文本消息，
  /// 用 translationService.detectLanguage() 检测语言。
  void _detectRecipientLanguage(Emitter<ChatState> emit) {
    if (_translationService == null) return;

    // 找最近一条非自己的文本消息
    final recipientMsg = state.messages
        .where(
          (m) =>
              !m.isFromMe &&
              m.type == MessageType.text &&
              m.content.trim().isNotEmpty,
        )
        .firstOrNull;

    if (recipientMsg == null) return;

    // detectLanguage 基于字符集正则，几乎即时完成
    _translationService
        .detectLanguage(recipientMsg.content)
        .then((detected) {
          if (detected != null &&
              !isClosed &&
              state.detectedRecipientLanguage != detected) {
            add(RecipientLanguageDetected(detected));
          }
        })
        .catchError((Object e) {
          debugLog('ChatBloc: Failed to detect recipient language: $e');
        });
  }

  /// 处理对方语言检测完成事件
  void _onRecipientLanguageDetected(
    RecipientLanguageDetected event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(detectedRecipientLanguage: event.language));
    debugLog('ChatBloc: Detected recipient language: ${event.language}');
  }

  // ============================================
  // 房间信息（频道/权限）
  // ============================================

  /// 加载房间信息以判断频道类型和发言权限
  void _loadRoomInfo(String roomId) {
    Future.microtask(() async {
      if (_groupRepository == null) return;
      try {
        final group = await _groupRepository.getGroup(roomId);
        if (group == null || isClosed) return;

        final isChannel = group.isChannel;
        // 频道中：如果 membersCanSpeak == false 且当前用户不是管理员，则不能发言
        final canSend = !isChannel || group.membersCanSpeak || group.isAdmin;

        add(
          RoomInfoLoaded(
            isChannel: isChannel,
            canSendMessages: canSend,
            slowModeInterval: group.slowModeInterval,
          ),
        );
      } catch (e) {
        debugLog('ChatBloc: Failed to load room info: $e');
      }
    });
  }

  /// 处理房间信息加载完成
  void _onRoomInfoLoaded(RoomInfoLoaded event, Emitter<ChatState> emit) {
    emit(
      state.copyWith(
        isChannel: event.isChannel,
        canSendMessages: event.canSendMessages,
        slowModeInterval: event.slowModeInterval,
      ),
    );
  }
}
