import 'dart:convert';

import '../../domain/entities/message_entity.dart';
import '../../domain/entities/message_reaction_entity.dart';
import '../../domain/repositories/message_action_repository.dart';
import '../datasources/local/preferences_datasource.dart';
import '../datasources/matrix/matrix_client_manager.dart';
import '../datasources/matrix/matrix_reaction_datasource.dart';
import '../../core/utils/debug_log.dart';

/// 消息操作仓库实现
class MessageActionRepositoryImpl implements IMessageActionRepository {
  final MatrixReactionDataSource _reactionDataSource;
  final MatrixClientManager _clientManager;
  final PreferencesDataSource _storage;

  // 内存缓存
  List<MessageEntity>? _cachedSavedMessages;
  Map<String, Map<String, dynamic>>? _cachedFavoriteMeta;

  MessageActionRepositoryImpl(
    this._reactionDataSource,
    this._clientManager,
    this._storage,
  );

  @override
  Future<void> addReaction(String roomId, String eventId, String emoji) async {
    await _reactionDataSource.addReaction(roomId, eventId, emoji);
  }

  @override
  Future<void> removeReaction(
    String roomId,
    String eventId,
    String emoji,
  ) async {
    await _reactionDataSource.removeReaction(roomId, eventId, emoji);
  }

  @override
  Future<void> toggleReaction(
    String roomId,
    String eventId,
    String emoji,
  ) async {
    final reactions = await _reactionDataSource.getReactions(roomId, eventId);
    final currentUserId = _clientManager.client?.userID;

    if (currentUserId == null) return;

    final hasReacted = reactions[emoji]?.contains(currentUserId) ?? false;

    if (hasReacted) {
      await removeReaction(roomId, eventId, emoji);
    } else {
      await addReaction(roomId, eventId, emoji);
    }
  }

  @override
  Future<List<MessageReactionEntity>> getReactions(
    String roomId,
    String eventId,
  ) async {
    final reactionsMap = await _reactionDataSource.getReactions(
      roomId,
      eventId,
    );
    final client = _clientManager.client;
    final room = client?.getRoomById(roomId);

    final reactions = <MessageReactionEntity>[];

    for (final entry in reactionsMap.entries) {
      final emoji = entry.key;
      final userIds = entry.value;

      final userNames = userIds.map((userId) {
        if (room != null) {
          final user = room.unsafeGetUserFromMemoryOrFallback(userId);
          return user.calcDisplayname();
        }
        return userId;
      }).toList();

      reactions.add(
        MessageReactionEntity(
          emoji: emoji,
          userIds: userIds,
          userNames: userNames,
        ),
      );
    }

    return reactions;
  }

  @override
  Future<MessageEntity?> replyToMessage(
    String roomId,
    String originalEventId,
    String content,
  ) async {
    final eventId = await _reactionDataSource.sendReply(
      roomId,
      originalEventId,
      content,
    );

    if (eventId == null) return null;

    return MessageEntity(
      id: eventId,
      roomId: roomId,
      senderId: _clientManager.client?.userID ?? '',
      senderName: '',
      content: content,
      timestamp: DateTime.now(),
      type: MessageType.text,
      status: MessageStatus.sending,
      replyToId: originalEventId,
    );
  }

  @override
  Future<MessageEntity?> editMessage(
    String roomId,
    String originalEventId,
    String newContent,
  ) async {
    final eventId = await _reactionDataSource.editMessage(
      roomId,
      originalEventId,
      newContent,
    );

    if (eventId == null) return null;

    return MessageEntity(
      id: eventId,
      roomId: roomId,
      senderId: _clientManager.client?.userID ?? '',
      senderName: '',
      content: newContent,
      timestamp: DateTime.now(),
      type: MessageType.text,
      status: MessageStatus.sending,
      isEdited: true,
    );
  }

  @override
  bool canEdit(String roomId, String senderId) {
    return _reactionDataSource.canEdit(roomId, senderId);
  }

  @override
  Future<void> redactMessage(
    String roomId,
    String eventId, {
    String? reason,
  }) async {
    await _reactionDataSource.redactMessage(roomId, eventId, reason: reason);
  }

  @override
  bool canRedact(String roomId, String senderId) {
    return _reactionDataSource.canRedact(roomId, senderId);
  }

  @override
  Future<MessageEntity?> forwardMessage(
    String fromRoomId,
    String eventId,
    String toRoomId,
  ) async {
    final newEventId = await _reactionDataSource.forwardMessage(
      fromRoomId,
      eventId,
      toRoomId,
    );

    if (newEventId == null) return null;

    return MessageEntity(
      id: newEventId,
      roomId: toRoomId,
      senderId: _clientManager.client?.userID ?? '',
      senderName: '',
      content: '',
      timestamp: DateTime.now(),
      type: MessageType.text,
      status: MessageStatus.sending,
    );
  }

  @override
  Future<Map<String, bool>> forwardToMultipleRooms(
    String fromRoomId,
    String eventId,
    List<String> toRoomIds,
  ) async {
    final results = <String, bool>{};

    for (final toRoomId in toRoomIds) {
      try {
        await forwardMessage(fromRoomId, eventId, toRoomId);
        results[toRoomId] = true;
      } catch (e) {
        results[toRoomId] = false;
      }
    }

    return results;
  }

  // ============================================
  // 收藏消息（持久化）
  // ============================================

  @override
  Future<void> saveMessage(MessageEntity message) async {
    final messages = await _loadSavedMessages();
    if (!messages.any((m) => m.id == message.id)) {
      messages.add(message);
      _cachedSavedMessages = messages;
      await _persistSavedMessages(messages);
    }
  }

  @override
  Future<void> unsaveMessage(String messageId) async {
    final messages = await _loadSavedMessages();
    messages.removeWhere((m) => m.id == messageId);
    _cachedSavedMessages = messages;
    await _persistSavedMessages(messages);

    // 同时清理该消息的元数据
    final meta = await _loadFavoriteMeta();
    meta.remove(messageId);
    _cachedFavoriteMeta = meta;
    await _persistFavoriteMeta(meta);
  }

  @override
  Future<List<MessageEntity>> getSavedMessages() async {
    final messages = await _loadSavedMessages();
    return List.unmodifiable(messages);
  }

  @override
  Future<bool> isMessageSaved(String messageId) async {
    final messages = await _loadSavedMessages();
    return messages.any((m) => m.id == messageId);
  }

  Future<List<MessageEntity>> _loadSavedMessages() async {
    if (_cachedSavedMessages != null) return _cachedSavedMessages!;

    try {
      final jsonStr = await _storage.getFavoriteMessages();
      if (jsonStr == null || jsonStr.isEmpty) {
        _cachedSavedMessages = [];
        return _cachedSavedMessages!;
      }

      final list = jsonDecode(jsonStr) as List<dynamic>;
      _cachedSavedMessages = list
          .map((e) => _messageFromJson(e as Map<String, dynamic>))
          .toList();
      return _cachedSavedMessages!;
    } catch (e) {
      debugLog('MessageActionRepository: Failed to load saved messages - $e');
      _cachedSavedMessages = [];
      return _cachedSavedMessages!;
    }
  }

  Future<void> _persistSavedMessages(List<MessageEntity> messages) async {
    try {
      final jsonStr = jsonEncode(messages.map(_messageToJson).toList());
      await _storage.saveFavoriteMessages(jsonStr);
    } catch (e) {
      debugLog(
        'MessageActionRepository: Failed to persist saved messages - $e',
      );
    }
  }

  // ============================================
  // 收藏标签 / 备注（持久化）
  // ============================================

  @override
  Future<void> editFavoriteTags(String favoriteId, List<String> tags) async {
    final meta = await _loadFavoriteMeta();
    final entry = meta[favoriteId] ?? {};
    entry['tags'] = tags;
    meta[favoriteId] = entry;
    _cachedFavoriteMeta = meta;
    await _persistFavoriteMeta(meta);
  }

  @override
  Future<void> editFavoriteRemark(String favoriteId, String remark) async {
    final meta = await _loadFavoriteMeta();
    final entry = meta[favoriteId] ?? {};
    entry['remark'] = remark;
    meta[favoriteId] = entry;
    _cachedFavoriteMeta = meta;
    await _persistFavoriteMeta(meta);
  }

  Future<Map<String, Map<String, dynamic>>> _loadFavoriteMeta() async {
    if (_cachedFavoriteMeta != null) return _cachedFavoriteMeta!;

    try {
      final jsonStr = await _storage.getFavoriteMeta();
      if (jsonStr == null || jsonStr.isEmpty) {
        _cachedFavoriteMeta = {};
        return _cachedFavoriteMeta!;
      }

      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      _cachedFavoriteMeta = decoded.map(
        (key, value) => MapEntry(key, value as Map<String, dynamic>),
      );
      return _cachedFavoriteMeta!;
    } catch (e) {
      debugLog('MessageActionRepository: Failed to load favorite meta - $e');
      _cachedFavoriteMeta = {};
      return _cachedFavoriteMeta!;
    }
  }

  Future<void> _persistFavoriteMeta(
    Map<String, Map<String, dynamic>> meta,
  ) async {
    try {
      await _storage.saveFavoriteMeta(jsonEncode(meta));
    } catch (e) {
      debugLog('MessageActionRepository: Failed to persist favorite meta - $e');
    }
  }

  // ============================================
  // MessageEntity JSON 序列化助手
  // ============================================

  Map<String, dynamic> _messageToJson(MessageEntity m) {
    return {
      'id': m.id,
      'roomId': m.roomId,
      'senderId': m.senderId,
      'senderName': m.senderName,
      'senderAvatarUrl': m.senderAvatarUrl,
      'content': m.content,
      'formattedContent': m.formattedContent,
      'timestamp': m.timestamp.toIso8601String(),
      'type': m.type.index,
      'status': m.status.index,
      'isFromMe': m.isFromMe,
      'isEdited': m.isEdited,
      'editedAt': m.editedAt?.toIso8601String(),
      'replyToId': m.replyToId,
      'replyToContent': m.replyToContent,
      'replyToSender': m.replyToSender,
      'threadRootId': m.threadRootId,
      'threadReplyCount': m.threadReplyCount,
      'threadLatestReply': m.threadLatestReply,
      'threadLatestReplySender': m.threadLatestReplySender,
      'threadLatestReplyTimestamp': m.threadLatestReplyTimestamp
          ?.toIso8601String(),
      if (m.metadata != null) 'metadata': _metadataToJson(m.metadata!),
    };
  }

  MessageEntity _messageFromJson(Map<String, dynamic> json) {
    return MessageEntity(
      id: json['id'] as String? ?? '',
      roomId: json['roomId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      content: json['content'] as String? ?? '',
      formattedContent: json['formattedContent'] as String?,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      type:
          MessageType.values.elementAtOrNull(json['type'] as int? ?? 0) ??
          MessageType.text,
      status:
          MessageStatus.values.elementAtOrNull(json['status'] as int? ?? 0) ??
          MessageStatus.sent,
      isFromMe: json['isFromMe'] as bool? ?? false,
      isEdited: json['isEdited'] as bool? ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.tryParse(json['editedAt'] as String)
          : null,
      replyToId: json['replyToId'] as String?,
      replyToContent: json['replyToContent'] as String?,
      replyToSender: json['replyToSender'] as String?,
      threadRootId: json['threadRootId'] as String?,
      threadReplyCount: json['threadReplyCount'] as int?,
      threadLatestReply: json['threadLatestReply'] as String?,
      threadLatestReplySender: json['threadLatestReplySender'] as String?,
      threadLatestReplyTimestamp: json['threadLatestReplyTimestamp'] != null
          ? DateTime.tryParse(json['threadLatestReplyTimestamp'] as String)
          : null,
      metadata: json['metadata'] != null
          ? _metadataFromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> _metadataToJson(MessageMetadata m) {
    return {
      'mediaUrl': m.mediaUrl,
      'httpUrl': m.httpUrl,
      'thumbnailUrl': m.thumbnailUrl,
      'mimeType': m.mimeType,
      'size': m.size,
      'width': m.width,
      'height': m.height,
      'duration': m.duration,
      'fileName': m.fileName,
      'isPlayed': m.isPlayed,
      'waveform': m.waveform,
      'transcription': m.transcription,
      'transcriptionStatus': m.transcriptionStatus?.index,
      'latitude': m.latitude,
      'longitude': m.longitude,
      'locationName': m.locationName,
      'amount': m.amount,
      'token': m.token,
      'transferStatus': m.transferStatus,
      'txHash': m.txHash,
      'paymentRequestId': m.paymentRequestId,
      'paymentReceiverAddress': m.paymentReceiverAddress,
      'paymentRequestExpiresAt': m.paymentRequestExpiresAt?.toIso8601String(),
      'redPacketId': m.redPacketId,
      'pollQuestion': m.pollQuestion,
      'pollOptions': m.pollOptions,
      'pollOptionIds': m.pollOptionIds,
      'myVotes': m.myVotes,
      'voteCounts': m.voteCounts,
      'totalVoters': m.totalVoters,
      'maxSelections': m.maxSelections,
      'pollEnded': m.pollEnded,
      'isAnonymousPoll': m.isAnonymousPoll,
      'musicTitle': m.musicTitle,
      'musicArtist': m.musicArtist,
      'musicUrl': m.musicUrl,
      'musicCover': m.musicCover,
      'callDuration': m.callDuration,
      'callEnded': m.callEnded,
      'isMissedCall': m.isMissedCall,
      'callEndReason': m.callEndReason,
      'callRoomId': m.callRoomId,
      'callPeerId': m.callPeerId,
    };
  }

  MessageMetadata _metadataFromJson(Map<String, dynamic> json) {
    return MessageMetadata(
      mediaUrl: json['mediaUrl'] as String?,
      httpUrl: json['httpUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      mimeType: json['mimeType'] as String?,
      size: json['size'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: json['duration'] as int?,
      fileName: json['fileName'] as String?,
      isPlayed: json['isPlayed'] as bool?,
      waveform: (json['waveform'] as List<dynamic>?)?.cast<int>(),
      transcription: json['transcription'] as String?,
      transcriptionStatus: json['transcriptionStatus'] != null
          ? TranscriptionStatus.values.elementAtOrNull(
              json['transcriptionStatus'] as int,
            )
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      amount: json['amount'] as String?,
      token: json['token'] as String?,
      transferStatus: json['transferStatus'] as String?,
      txHash: json['txHash'] as String?,
      paymentRequestId: json['paymentRequestId'] as String?,
      paymentReceiverAddress: json['paymentReceiverAddress'] as String?,
      paymentRequestExpiresAt: json['paymentRequestExpiresAt'] != null
          ? DateTime.tryParse(json['paymentRequestExpiresAt'] as String)
          : null,
      redPacketId: json['redPacketId'] as String?,
      pollQuestion: json['pollQuestion'] as String?,
      pollOptions: (json['pollOptions'] as List<dynamic>?)?.cast<String>(),
      pollOptionIds: (json['pollOptionIds'] as List<dynamic>?)?.cast<String>(),
      myVotes: (json['myVotes'] as List<dynamic>?)?.cast<String>(),
      voteCounts: (json['voteCounts'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as int),
      ),
      totalVoters: json['totalVoters'] as int?,
      maxSelections: json['maxSelections'] as int?,
      pollEnded: json['pollEnded'] as bool?,
      isAnonymousPoll: json['isAnonymousPoll'] as bool?,
      musicTitle: json['musicTitle'] as String?,
      musicArtist: json['musicArtist'] as String?,
      musicUrl: json['musicUrl'] as String?,
      musicCover: json['musicCover'] as String?,
      callDuration: json['callDuration'] as int?,
      callEnded: json['callEnded'] as bool?,
      isMissedCall: json['isMissedCall'] as bool?,
      callEndReason: json['callEndReason'] as String?,
      callRoomId: json['callRoomId'] as String?,
      callPeerId: json['callPeerId'] as String?,
    );
  }
}
