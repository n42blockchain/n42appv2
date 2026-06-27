part of 'chat_bloc.dart';

/// 消息发送相关 handler 方法
///
/// 包含：文本、图片、语音、文件、视频、位置、GIF、贴纸、
/// 联系人名片、自定义消息（红包/转账/音乐）、系统通知、拍一拍等。
extension ChatBlocSendHandlers on ChatBloc {
  static final _whitespaceRe = RegExp(r'\s+');

  bool _canSendUserMessage(Emitter<ChatState> emit, String actionLabel) {
    if (_currentRoomId == null) {
      debugLog('ChatBloc: Cannot send $actionLabel - no room ID');
      return false;
    }

    if (state.slowModeInterval > 0 && state.lastMessageSentAt != null) {
      final elapsed = DateTime.now()
          .difference(state.lastMessageSentAt!)
          .inSeconds;
      if (elapsed < state.slowModeInterval) {
        final remaining = state.slowModeInterval - elapsed;
        emit(state.copyWith(error: 'Slow mode: wait ${remaining}s'));
        return false;
      }
    }

    return true;
  }

  ChatState _buildPostSendState({
    List<MessageEntity>? messages,
    bool isSending = false,
  }) {
    return state.copyWith(
      messages: messages,
      isSending: isSending,
      clearReplyTarget: true,
      lastMessageSentAt: DateTime.now(),
    );
  }

  /// 发送文本消息
  Future<void> onSendTextMessage(
    SendTextMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null || event.text.trim().isEmpty) return;

    // 斜杠命令拦截
    final trimmed = event.text.trim();
    if (trimmed.startsWith('/')) {
      final parts = trimmed.substring(1).split(_whitespaceRe);
      final cmd = parts.isNotEmpty ? parts[0].toLowerCase() : '';
      final args = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      add(ExecuteSlashCommand(command: cmd, args: args));
      return;
    }

    // 慢速模式检查
    if (state.slowModeInterval > 0 && state.lastMessageSentAt != null) {
      final elapsed = DateTime.now()
          .difference(state.lastMessageSentAt!)
          .inSeconds;
      if (elapsed < state.slowModeInterval) {
        final remaining = state.slowModeInterval - elapsed;
        emit(state.copyWith(error: 'Slow mode: wait ${remaining}s'));
        return;
      }
    }

    // 智能回复翻译：发送前自动翻译为对方语言
    String textToSend = event.text;
    String? originalText;
    final selfDestructAfter = await _resolveSelfDestructAfter(
      event.selfDestructAfter,
    );

    if (state.smartReplyTranslate &&
        _translationService != null &&
        state.detectedRecipientLanguage != null) {
      final recipientLang = state.detectedRecipientLanguage!;
      final userLang = getDeviceLanguageCode();
      if (translationLanguageBaseCode(recipientLang) !=
          translationLanguageBaseCode(userLang)) {
        try {
          final result = await _translationService.translate(
            text: event.text,
            targetLanguage: recipientLang,
          );
          if (result.success && result.translatedText.isNotEmpty) {
            textToSend = result.translatedText;
            originalText = event.text;
          }
        } catch (e) {
          debugLog(
            'ChatBloc: Smart reply translation failed, sending original: $e',
          );
        }
      }
    }

    emit(state.copyWith(isSending: true, clearError: true));

    try {
      // 如果有回复目标，使用回复功能
      if (state.replyTarget != null) {
        final sentMsg = await _messageRepository.replyToMessage(
          _currentRoomId!,
          state.replyTarget!.id,
          textToSend,
          selfDestructAfter: selfDestructAfter,
          mentionedUserIds: event.mentionedUserIds,
          mentionsRoom: event.mentionsRoom,
        );
        var newState = state.copyWith(
          isSending: false,
          clearReplyTarget: true,
          lastMessageSentAt: DateTime.now(),
        );
        // 记录智能回复原文
        if (originalText != null && sentMsg != null) {
          final newOriginals = Map<String, String>.from(
            newState.smartReplyOriginals,
          )..[sentMsg.id] = originalText;
          // 超过 100 条时清理最早的
          if (newOriginals.length > 100) {
            final keysToRemove = newOriginals.keys
                .take(newOriginals.length - 100)
                .toList();
            for (final k in keysToRemove) {
              newOriginals.remove(k);
            }
          }
          newState = newState.copyWith(smartReplyOriginals: newOriginals);
        }
        emit(newState);
      } else {
        final sentMsg = await _messageRepository.sendTextMessage(
          _currentRoomId!,
          textToSend,
          selfDestructAfter: selfDestructAfter,
          mentionedUserIds: event.mentionedUserIds,
          mentionsRoom: event.mentionsRoom,
        );
        var newState = state.copyWith(
          isSending: false,
          lastMessageSentAt: DateTime.now(),
        );
        // 记录智能回复原文
        if (originalText != null && sentMsg != null) {
          final newOriginals = Map<String, String>.from(
            newState.smartReplyOriginals,
          )..[sentMsg.id] = originalText;
          if (newOriginals.length > 100) {
            final keysToRemove = newOriginals.keys
                .take(newOriginals.length - 100)
                .toList();
            for (final k in keysToRemove) {
              newOriginals.remove(k);
            }
          }
          newState = newState.copyWith(smartReplyOriginals: newOriginals);
        }
        emit(newState);
      }
    } catch (e) {
      emit(state.copyWith(isSending: false, error: 'Failed to send'));
    }
  }

  /// 发送图片消息
  Future<void> onSendImageMessage(
    SendImageMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (!_canSendUserMessage(emit, 'image')) {
      return;
    }

    emit(state.copyWith(isSending: true, clearError: true));

    try {
      final selfDestructAfter = await _resolveSelfDestructAfter(
        event.selfDestructAfter,
      );
      debugLog(
        'ChatBloc: Sending image ${event.filename}, size: ${event.imageBytes.length}',
      );
      await _messageRepository.sendImageMessage(
        _currentRoomId!,
        imageBytes: event.imageBytes,
        filename: event.filename,
        mimeType: event.mimeType,
        selfDestructAfter: selfDestructAfter,
      );
      debugLog('ChatBloc: Image sent successfully');
      emit(_buildPostSendState());
    } catch (e, stackTrace) {
      debugLog('ChatBloc: Send image error - $e');
      debugLog('ChatBloc: Stack trace - $stackTrace');
      emit(state.copyWith(isSending: false, error: 'Failed to send image: $e'));
    }
  }

  /// 发送语音消息
  Future<void> onSendVoiceMessage(
    SendVoiceMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (!_canSendUserMessage(emit, 'voice')) {
      return;
    }

    emit(state.copyWith(isSending: true, clearError: true));

    try {
      final selfDestructAfter = await _resolveSelfDestructAfter(
        event.selfDestructAfter,
      );
      debugLog(
        'ChatBloc: Sending voice ${event.filename}, size: ${event.audioBytes.length}, duration: ${event.duration}ms',
      );
      await _messageRepository.sendVoiceMessage(
        _currentRoomId!,
        audioBytes: event.audioBytes,
        filename: event.filename,
        duration: event.duration,
        mimeType: event.mimeType,
        selfDestructAfter: selfDestructAfter,
      );
      debugLog('ChatBloc: Voice sent successfully');
      emit(_buildPostSendState());
    } catch (e, stackTrace) {
      debugLog('ChatBloc: Send voice error - $e');
      debugLog('ChatBloc: Stack trace - $stackTrace');
      emit(state.copyWith(isSending: false, error: 'Failed to send voice: $e'));
    }
  }

  /// 发送文件消息
  Future<void> onSendFileMessage(
    SendFileMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (!_canSendUserMessage(emit, 'file')) return;

    emit(state.copyWith(isSending: true, clearError: true));

    try {
      final selfDestructAfter = await _resolveSelfDestructAfter(
        event.selfDestructAfter,
      );
      if (event.filePath != null || event.fileStream != null) {
        await _messageRepository.sendFileMessage(
          _currentRoomId!,
          filename: event.filename,
          mimeType: event.mimeType,
          selfDestructAfter: selfDestructAfter,
          filePath: event.filePath,
          fileStream: event.fileStream,
          fileSize: event.fileSize,
        );
      } else if (event.fileBytes != null) {
        await _messageRepository.sendFileMessage(
          _currentRoomId!,
          fileBytes: event.fileBytes!,
          filename: event.filename,
          mimeType: event.mimeType,
          selfDestructAfter: selfDestructAfter,
          fileSize: event.fileSize,
        );
      } else {
        throw Exception('No file content available');
      }
      emit(_buildPostSendState());
    } catch (e) {
      emit(state.copyWith(isSending: false, error: 'Failed to send file'));
    }
  }

  /// 发送视频消息（带缩略图）
  Future<void> onSendVideoMessage(
    SendVideoMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (!_canSendUserMessage(emit, 'video')) return;

    emit(state.copyWith(isSending: true, clearError: true));

    try {
      final selfDestructAfter = await _resolveSelfDestructAfter(
        event.selfDestructAfter,
      );
      debugLog(
        'ChatBloc: Sending video with thumbnail: ${event.thumbnailBytes?.length ?? 0} bytes',
      );
      await _messageRepository.sendVideoMessage(
        _currentRoomId!,
        videoBytes: event.videoBytes,
        filename: event.filename,
        mimeType: event.mimeType,
        thumbnailBytes: event.thumbnailBytes,
        selfDestructAfter: selfDestructAfter,
      );
      debugLog('ChatBloc: Video sent successfully');
      emit(_buildPostSendState());
    } catch (e, stackTrace) {
      debugLog('ChatBloc: Send video error - $e');
      debugLog('ChatBloc: Stack trace - $stackTrace');
      emit(state.copyWith(isSending: false, error: 'Failed to send video: $e'));
    }
  }

  /// 发送位置消息
  Future<void> onSendLocationMessage(
    SendLocationMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (!_canSendUserMessage(emit, 'location')) return;

    emit(state.copyWith(isSending: true, clearError: true));

    try {
      await _messageRepository.sendLocationMessage(
        _currentRoomId!,
        latitude: event.latitude,
        longitude: event.longitude,
        description: event.description,
      );
      emit(_buildPostSendState());
    } catch (e) {
      emit(state.copyWith(isSending: false, error: 'Failed to send location'));
    }
  }

  /// 发送 GIF 消息
  Future<void> onSendGifMessage(
    SendGifMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (!_canSendUserMessage(emit, 'GIF')) {
      return;
    }

    emit(state.copyWith(isSending: true, clearError: true));

    try {
      debugLog('ChatBloc: Sending GIF from ${event.gifUrl}');
      await _messageRepository.sendGifMessage(
        _currentRoomId!,
        gifUrl: event.gifUrl,
        previewUrl: event.previewUrl,
        width: event.width,
        height: event.height,
        title: event.title,
      );
      debugLog('ChatBloc: GIF sent successfully');
      emit(_buildPostSendState());
    } catch (e, stackTrace) {
      debugLog('ChatBloc: Send GIF error - $e');
      debugLog('ChatBloc: Stack trace - $stackTrace');
      emit(state.copyWith(isSending: false, error: 'Failed to send GIF: $e'));
    }
  }

  /// 发送贴纸消息
  Future<void> onSendStickerMessage(
    SendStickerMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (!_canSendUserMessage(emit, 'sticker')) {
      return;
    }

    emit(state.copyWith(isSending: true, clearError: true));

    try {
      debugLog(
        'ChatBloc: Sending sticker ${event.stickerId} from pack ${event.packId}',
      );
      await _messageRepository.sendStickerMessage(
        _currentRoomId!,
        stickerId: event.stickerId,
        packId: event.packId,
        url: event.url,
        httpUrl: event.httpUrl,
        name: event.name,
        emoji: event.emoji,
        width: event.width,
        height: event.height,
        mimeType: event.mimeType,
        size: event.size,
      );
      debugLog('ChatBloc: Sticker sent successfully');
      emit(_buildPostSendState());
    } catch (e, stackTrace) {
      debugLog('ChatBloc: Send sticker error - $e');
      debugLog('ChatBloc: Stack trace - $stackTrace');
      emit(
        state.copyWith(isSending: false, error: 'Failed to send sticker: $e'),
      );
    }
  }

  /// 发送自定义消息（红包、转账等）
  Future<void> onSendCustomMessage(
    SendCustomMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (!_canSendUserMessage(emit, 'custom message')) return;

    try {
      debugLog(
        'ChatBloc: Sending custom message - type: ${event.type}, content: ${event.content}',
      );

      // 获取当前用户ID
      final currentUserId = await _messageRepository.getCurrentUserId() ?? '';

      // 创建临时消息（用于乐观更新）
      final tempMessage = MessageEntity(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        roomId: _currentRoomId!,
        senderId: currentUserId,
        senderName: 'Me',
        content: event.content,
        type: event.type,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        isFromMe: true,
        metadata: event.metadata,
      );

      // 乐观更新 UI
      if (!isClosed) {
        emit(state.copyWith(messages: [tempMessage, ...state.messages]));
      }

      // 根据消息类型发送
      String? eventId;

      if (event.type == MessageType.redPacket) {
        // 发送红包消息（使用自定义消息类型）
        eventId = await _messageRepository.sendCustomMessage(
          _currentRoomId!,
          msgType: 'n42.red_packet',
          content: event.content,
          additionalData: {
            'amount': event.metadata?.amount ?? '0',
            'token': event.metadata?.token ?? 'ETH',
            'status': 'pending',
            if (event.metadata?.redPacketId != null)
              'red_packet_id': event.metadata!.redPacketId,
          },
        );
      } else if (event.type == MessageType.transfer) {
        // 发送转账消息
        eventId = await _messageRepository.sendCustomMessage(
          _currentRoomId!,
          msgType: 'n42.transfer',
          content: event.content,
          additionalData: {
            'amount': event.metadata?.amount ?? '0',
            'token': event.metadata?.token ?? 'ETH',
            'status': 'pending',
          },
        );
      } else if (event.type == MessageType.music) {
        // 发送音乐分享消息
        eventId = await _messageRepository.sendCustomMessage(
          _currentRoomId!,
          msgType: 'n42.music',
          content: event.content,
          additionalData: {
            'title': event.metadata?.musicTitle ?? '',
            'artist': event.metadata?.musicArtist ?? '',
            'url': event.metadata?.musicUrl ?? '',
            'cover': event.metadata?.musicCover ?? '',
          },
        );
      } else if (event.type == MessageType.codeBlock) {
        // 发送代码块消息：body 用 markdown 围栏 ```lang\ncode\n``` 编码语言，
        // N42 客户端按 MessageType.codeBlock 富渲染；其它客户端回退为代码围栏文本。
        eventId = await _messageRepository.sendCustomMessage(
          _currentRoomId!,
          msgType: 'n42.code_block',
          content: event.content,
          additionalData: const {},
        );
      } else if (event.type == MessageType.tip) {
        // 发送打赏消息（金额/代币/链上交易哈希）
        eventId = await _messageRepository.sendCustomMessage(
          _currentRoomId!,
          msgType: 'n42.tip',
          content: event.content,
          additionalData: {
            'amount': event.metadata?.amount ?? '0',
            'token': event.metadata?.token ?? '',
            if (event.metadata?.txHash != null)
              'tx_hash': event.metadata!.txHash,
          },
        );
      } else if (event.type == MessageType.event &&
          event.metadata?.event != null) {
        // 发送日程/事件消息（标题/起止时间/地点/描述）
        eventId = await _messageRepository.sendCustomMessage(
          _currentRoomId!,
          msgType: EventMessageData.msgType,
          content: event.content,
          additionalData: event.metadata!.event!.toContent(),
        );
      }

      if (eventId != null) {
        debugLog('ChatBloc: Custom message sent - eventId: $eventId');

        // 更新消息状态为已发送
        if (!isClosed) {
          final updatedMessages = state.messages.map((msg) {
            if (msg.id == tempMessage.id) {
              return msg.copyWith(id: eventId, status: MessageStatus.sent);
            }
            return msg;
          }).toList();

          emit(_buildPostSendState(messages: updatedMessages));
        }
      } else {
        // 发送失败，更新状态
        if (!isClosed) {
          final updatedMessages = state.messages.map((msg) {
            if (msg.id == tempMessage.id) {
              return msg.copyWith(status: MessageStatus.failed);
            }
            return msg;
          }).toList();

          emit(
            state.copyWith(messages: updatedMessages, error: 'Failed to send'),
          );
        }
      }
    } catch (e) {
      debugLog('ChatBloc: Failed to send custom message: $e');
      if (!isClosed) {
        emit(state.copyWith(error: 'Failed to send: $e'));
      }
    }
  }

  /// 发送联系人名片消息
  Future<void> onSendContactCardMessage(
    SendContactCardMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (!_canSendUserMessage(emit, 'contact card')) return;

    try {
      await _messageRepository.sendCustomMessage(
        _currentRoomId!,
        msgType: 'n42.contact_card',
        content: '[Contact Card] ${event.displayName}',
        additionalData: {
          'user_id': event.userId,
          'display_name': event.displayName,
          if (event.avatarUrl != null) 'avatar_url': event.avatarUrl,
        },
      );
      emit(_buildPostSendState());
    } catch (e) {
      debugLog('ChatBloc: Failed to send contact card: $e');
    }
  }

  /// 发送系统通知/拍一拍消息
  Future<void> onSendSystemNotice(
    SendSystemNotice event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    try {
      await _messageRepository.sendNoticeMessage(
        roomId: _currentRoomId!,
        notice: event.notice,
      );
      debugLog('ChatBloc: System notice sent: ${event.notice}');
    } catch (e) {
      debugLog('ChatBloc: Failed to send system notice: $e');
    }
  }

  /// 发送拍一拍消息
  Future<void> onSendPokeMessage(
    SendPokeMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (!_canSendUserMessage(emit, 'poke')) return;

    try {
      // 微信拍一拍逻辑：统一使用"拍人者"设置的后缀
      // 例如：拍人者设置后缀"的头"，则无论拍谁都显示"XXX 拍了拍 YYY 的头"
      final String? pokeText = event.pokerPokeText;

      debugLog('ChatBloc: Using poker\'s pokeText: $pokeText');

      // 构造拍一拍消息
      String pokeMessage;
      if (pokeText != null && pokeText.isNotEmpty) {
        pokeMessage = '「${event.pokerName}」拍了拍「${event.targetName}」$pokeText';
      } else {
        pokeMessage = '「${event.pokerName}」拍了拍「${event.targetName}」';
      }

      debugLog('ChatBloc: Sending poke message: $pokeMessage');

      // 发送系统消息
      await _messageRepository.sendNoticeMessage(
        roomId: _currentRoomId!,
        notice: pokeMessage,
      );

      emit(_buildPostSendState());
      debugLog('ChatBloc: Poke message sent successfully');
    } catch (e) {
      debugLog('ChatBloc: Failed to send poke message: $e');
    }
  }
}
