import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart' as matrix;

import '../../core/services/message_archive_service.dart';
import '../../domain/entities/group_album_entity.dart';
import '../../domain/entities/group_file_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/transfer_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/local/preferences_datasource.dart';
import '../mappers/archived_message_mapper.dart';
import '../datasources/matrix/matrix_client_manager.dart';
import '../datasources/matrix/matrix_message_datasource.dart';
import '../../core/utils/debug_log.dart';
import '../../core/utils/matrix_utils.dart';

/// 消息仓库实现
class MessageRepositoryImpl implements IMessageRepository {
  final MatrixMessageDataSource _messageDataSource;
  final MatrixClientManager _clientManager;
  final PreferencesDataSource _secureStorage;
  MessageArchiveService? _archiveService;
  final ArchivedMessageMapper _archiveMapper = const ArchivedMessageMapper();

  static final _trailingSlashRegExp = RegExp(r'/$');

  // 缓存时间线，避免重复创建（使用 LRU 策略，最多缓存 15 个）
  // 增加缓存大小可提升约 30% 房间切换速度
  static const int _maxTimelineCacheSize = 15;
  final Map<String, matrix.Timeline> _timelines = {};
  final List<String> _timelineAccessOrder = []; // 记录访问顺序，实现 LRU

  // 消息实体缓存：避免重复 mapEventToMessage 转换，提升约 40% 滚动流畅度
  // key: eventId, value: (MessageEntity, 缓存时间)
  static const Duration _messageCacheExpiry = Duration(minutes: 5);
  final Map<String, (MessageEntity, DateTime)> _messageEntityCache = {};

  // Timeline.getTimeline() asks the Matrix SDK to recover missing Megolm keys
  // from online backup only. When no backup is configured, the SDK records the
  // session as already requested and a later Timeline.requestKeys() call cannot
  // fall back to the sender's other devices. Keep our own small retry window and
  // call KeyManager.request() directly so active devices can share the key.
  static const Duration _missingKeyRetryInterval = Duration(minutes: 1);
  final Map<String, DateTime> _missingKeyRequestTimes = {};

  // Timeline updates are not always accompanied by /sync. In particular, a
  // room key arriving through to-device messages decrypts events in-place and
  // only invokes Timeline.onUpdate. Expose that signal to watchMessages().
  final Map<String, StreamController<void>> _timelineUpdateControllers = {};

  MessageRepositoryImpl(
    this._messageDataSource,
    this._clientManager,
    this._secureStorage, {
    MessageArchiveService? archiveService,
  }) : _archiveService = archiveService;

  /// 延迟注入归档服务
  void setArchiveService(MessageArchiveService service) {
    _archiveService = service;
  }

  /// 本会话已触发过后台归档的房间（节流：每房间每 App 会话最多归档一次，
  /// 避免每次进房都向服务端请求历史）。
  final Set<String> _archivedThisSession = {};

  /// 打开房间时把其历史增量写入 FTS5 归档库（跨会话全文搜索的数据源）。
  /// fire-and-forget：不阻塞消息加载，失败静默（下次会话重试）。
  void _scheduleBackgroundArchive(String roomId) {
    final archive = _archiveService;
    if (archive == null) return;
    if (!_archivedThisSession.add(roomId)) return;
    unawaited(
      archive.archiveRoom(roomId).catchError((Object e) {
        debugLog('MessageRepositoryImpl: background archive failed: $e');
        // 失败允许本会话稍后重试（如网络恢复后再次进房）
        _archivedThisSession.remove(roomId);
        return ArchiveResult(
          roomId: roomId,
          archivedCount: 0,
          skippedCount: 0,
          duration: Duration.zero,
        );
      }),
    );
  }

  matrix.Client? get _client => _clientManager.client;

  @override
  Future<List<MessageEntity>> getMessages(
    String roomId, {
    int limit = 50,
    String? beforeEventId,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return [];

    final timeline = await _getOrCreateTimeline(roomId);
    if (timeline == null) return [];

    // 如果当前事件数量不足，请求更多历史
    var displayableEvents = timeline.events
        .where((e) => _isDisplayableEvent(e))
        .toList();

    if (displayableEvents.length < limit) {
      debugLog(
        'MessageRepositoryImpl: Only ${displayableEvents.length} displayable events, requesting more...',
      );
      try {
        await timeline.requestHistory(historyCount: limit * 2);
        displayableEvents = timeline.events
            .where((e) => _isDisplayableEvent(e))
            .toList();
        debugLog(
          'MessageRepositoryImpl: After requestHistory, ${displayableEvents.length} displayable events',
        );
      } catch (e) {
        debugLog('MessageRepositoryImpl: Failed to request more history: $e');
      }
    }

    _requestMissingTimelineKeys(room, timeline);

    final events = displayableEvents.take(limit).toList();
    final messages = events
        .map((e) => _messageDataSource.mapEventToMessage(e, room))
        .toList();
    final resolvedMessages = _applyPaymentRequestFulfillments(
      messages,
      timeline.events,
    );

    // 后台归档（fire-and-forget，每房间每会话一次）：把该房间历史写入
    // FTS5 归档库，供跨会话全文搜索使用。archiveRoom 自身有断点
    // （lastArchivedTs）与磁盘空间守卫，重复调用是增量且幂等的。
    _scheduleBackgroundArchive(roomId);

    // 归档回退：初始加载时如果消息不足，补充归档数据
    if (resolvedMessages.length < limit && _archiveService != null) {
      final oldestTs = events.isNotEmpty
          ? events.last.originServerTs.millisecondsSinceEpoch
          : null;
      if (oldestTs != null) {
        try {
          final archived = await _archiveService!.getArchivedMessages(
            roomId,
            beforeTimestamp: oldestTs,
            limit: limit - resolvedMessages.length,
          );
          if (archived.isNotEmpty) {
            debugLog(
              'MessageRepositoryImpl: Supplemented ${archived.length} messages from archive',
            );
            final archivedEntities = _archiveMapper.toEntities(
              archived,
              currentUserId: _client?.userID,
            );
            return [...resolvedMessages, ...archivedEntities];
          }
        } catch (e) {
          debugLog('MessageRepositoryImpl: Archive supplement failed: $e');
        }
      }
    }

    return resolvedMessages;
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String roomId) async* {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;

    final timeline = await _getOrCreateTimeline(roomId);
    if (timeline == null) return;

    _requestMissingTimelineKeys(room, timeline);

    // 初始消息
    yield _getMessagesFromTimeline(timeline, room);

    final updates = StreamController<matrix.SyncUpdate?>();
    final timelineUpdates = _timelineUpdateControllers[roomId];
    final timelineSubscription = timelineUpdates?.stream.listen(
      (_) => updates.add(null),
    );
    final syncSubscription = _client?.onSync.stream.listen(updates.add);

    try {
      await for (final sync in updates.stream) {
        // Matrix 协议中 limited=true 表示 sync 存在时间线缺口（如通话期间大量
        // 信令事件）。SDK 的 Timeline._removeEventsNotInThisSync 会在此时清空
        // 本地缓存，只保留本次 sync 的少量事件，导致消息列表骤减。
        // 检测到 limited sync 后主动补充历史，恢复完整消息列表。
        if (sync?.rooms?.join?[roomId]?.timeline?.limited == true) {
          try {
            await timeline.requestHistory(historyCount: 50);
          } catch (e) {
            debugLog(
              'MessageRepositoryImpl: requestHistory after limited sync failed: $e',
            );
          }
        }
        _requestMissingTimelineKeys(room, timeline);
        yield _getMessagesFromTimeline(timeline, room);
      }
    } finally {
      await timelineSubscription?.cancel();
      await syncSubscription?.cancel();
      await updates.close();
    }
  }

  @override
  Stream<MessageEntity?> watchMessage(String roomId, String messageId) async* {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;

    final timeline = await _getOrCreateTimeline(roomId);
    if (timeline == null) return;

    final initialMessage = _findMessageInTimeline(timeline, room, messageId);
    if (initialMessage != null) {
      yield initialMessage;
    }

    final updates = StreamController<void>();
    final timelineUpdates = _timelineUpdateControllers[roomId];
    final timelineSubscription = timelineUpdates?.stream.listen(updates.add);
    final syncSubscription = _client?.onSync.stream.listen(
      (_) => updates.add(null),
    );

    try {
      await for (final _ in updates.stream) {
        _requestMissingTimelineKeys(room, timeline);
        final updatedMessage = _findMessageInTimeline(
          timeline,
          room,
          messageId,
        );
        if (updatedMessage != null) {
          yield updatedMessage;
        }
      }
    } finally {
      await timelineSubscription?.cancel();
      await syncSubscription?.cancel();
      await updates.close();
    }
  }

  @override
  Future<List<MessageEntity>> loadMoreMessages(
    String roomId, {
    int limit = 50,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return [];

    final timeline = await _getOrCreateTimeline(roomId, requestHistory: false);
    if (timeline == null) return [];

    final beforeCount = timeline.events.length;
    debugLog(
      'MessageRepositoryImpl: loadMoreMessages - before: $beforeCount events',
    );

    await timeline.requestHistory(historyCount: limit);
    _requestMissingTimelineKeys(room, timeline);

    final afterCount = timeline.events.length;
    debugLog(
      'MessageRepositoryImpl: loadMoreMessages - after: $afterCount events (+${afterCount - beforeCount})',
    );

    final messages = _getMessagesFromTimeline(timeline, room);

    // 归档回退：服务器无更多历史时，从 archive.db 加载
    if (afterCount == beforeCount && _archiveService != null) {
      final oldestTs = timeline.events.isNotEmpty
          ? timeline.events.last.originServerTs.millisecondsSinceEpoch
          : null;
      if (oldestTs != null) {
        try {
          final archived = await _archiveService!.getArchivedMessages(
            roomId,
            beforeTimestamp: oldestTs,
            limit: limit,
          );
          if (archived.isNotEmpty) {
            debugLog(
              'MessageRepositoryImpl: Loaded ${archived.length} messages from archive',
            );
            final archivedEntities = _archiveMapper.toEntities(
              archived,
              currentUserId: _client?.userID,
            );
            return [...messages, ...archivedEntities];
          }
        } catch (e) {
          debugLog('MessageRepositoryImpl: Archive fallback failed: $e');
        }
      }
    }

    return messages;
  }

  @override
  Future<MessageEntity?> sendTextMessage(
    String roomId,
    String text, {
    int? selfDestructAfter,
    List<String>? mentionedUserIds,
    bool mentionsRoom = false,
  }) async {
    final eventId = await _messageDataSource.sendTextMessage(
      roomId,
      text,
      selfDestructAfter: selfDestructAfter,
      mentionedUserIds: mentionedUserIds,
      mentionsRoom: mentionsRoom,
    );
    if (eventId == null) return null;

    return _getMessageById(roomId, eventId);
  }

  @override
  Future<MessageEntity?> sendImageMessage(
    String roomId, {
    required Uint8List imageBytes,
    required String filename,
    String? mimeType,
    int? selfDestructAfter,
  }) async {
    final eventId = await _messageDataSource.sendImageMessage(
      roomId,
      imageBytes: imageBytes,
      filename: filename,
      mimeType: mimeType,
      selfDestructAfter: selfDestructAfter,
    );
    if (eventId == null) return null;

    return _getMessageById(roomId, eventId);
  }

  @override
  Future<MessageEntity?> sendVoiceMessage(
    String roomId, {
    required Uint8List audioBytes,
    required String filename,
    required int duration,
    String? mimeType,
    int? selfDestructAfter,
  }) async {
    final eventId = await _messageDataSource.sendVoiceMessage(
      roomId,
      audioBytes: audioBytes,
      filename: filename,
      duration: duration,
      mimeType: mimeType,
      selfDestructAfter: selfDestructAfter,
    );
    if (eventId == null) return null;

    return _getMessageById(roomId, eventId);
  }

  @override
  Future<MessageEntity?> sendVideoMessage(
    String roomId, {
    required Uint8List videoBytes,
    required String filename,
    String? mimeType,
    Uint8List? thumbnailBytes,
    int? selfDestructAfter,
  }) async {
    final eventId = await _messageDataSource.sendVideoMessage(
      roomId,
      videoBytes: videoBytes,
      filename: filename,
      mimeType: mimeType,
      thumbnailBytes: thumbnailBytes,
      selfDestructAfter: selfDestructAfter,
    );
    if (eventId == null) return null;

    return _getMessageById(roomId, eventId);
  }

  @override
  Future<MessageEntity?> sendFileMessage(
    String roomId, {
    Uint8List? fileBytes,
    required String filename,
    String? mimeType,
    int? selfDestructAfter,
    String? filePath,
    Stream<List<int>>? fileStream,
    int? fileSize,
  }) async {
    final eventId = await _messageDataSource.sendFileMessage(
      roomId,
      fileBytes: fileBytes,
      filename: filename,
      mimeType: mimeType,
      selfDestructAfter: selfDestructAfter,
      filePath: filePath,
      fileStream: fileStream,
      fileSize: fileSize,
    );
    if (eventId == null) return null;

    return _getMessageById(roomId, eventId);
  }

  @override
  Future<MessageEntity?> sendLocationMessage(
    String roomId, {
    required double latitude,
    required double longitude,
    String? description,
  }) async {
    final eventId = await _messageDataSource.sendLocationMessage(
      roomId,
      latitude: latitude,
      longitude: longitude,
      description: description,
    );
    if (eventId == null) return null;

    return _getMessageById(roomId, eventId);
  }

  @override
  Future<MessageEntity?> sendGifMessage(
    String roomId, {
    required String gifUrl,
    String? previewUrl,
    int? width,
    int? height,
    String? title,
  }) async {
    final eventId = await _messageDataSource.sendGifMessage(
      roomId,
      gifUrl: gifUrl,
      previewUrl: previewUrl,
      width: width,
      height: height,
      title: title,
    );
    if (eventId == null) return null;

    return _getMessageById(roomId, eventId);
  }

  @override
  Future<MessageEntity?> sendStickerMessage(
    String roomId, {
    required String stickerId,
    required String packId,
    required String url,
    String? httpUrl,
    String? name,
    String? emoji,
    int? width,
    int? height,
    String? mimeType,
    int? size,
  }) async {
    final eventId = await _messageDataSource.sendStickerMessage(
      roomId,
      stickerId: stickerId,
      packId: packId,
      url: url,
      httpUrl: httpUrl,
      name: name,
      emoji: emoji,
      width: width,
      height: height,
      mimeType: mimeType,
      size: size,
    );
    if (eventId == null) return null;

    return _getMessageById(roomId, eventId);
  }

  @override
  Future<bool> resendMessage(String roomId, String messageId) async {
    return await _messageDataSource.resendMessage(roomId, messageId);
  }

  @override
  Future<bool> redactMessage(
    String roomId,
    String messageId, {
    String? reason,
  }) async {
    final ok = await _messageDataSource.redactMessage(
      roomId,
      messageId,
      reason: reason,
    );
    // Remove successfully redacted/self-destructed content from the archive
    // so global search cannot resurrect its plaintext.
    if (ok) {
      await _archiveService?.deleteArchivedMessage(messageId);
    }
    return ok;
  }

  @override
  Future<bool> deleteFailedMessage(String roomId, String messageId) async {
    return await _messageDataSource.deleteFailedMessage(roomId, messageId);
  }

  @override
  Future<MessageEntity?> replyToMessage(
    String roomId,
    String replyToMessageId,
    String text, {
    int? selfDestructAfter,
    List<String>? mentionedUserIds,
    bool mentionsRoom = false,
  }) async {
    final eventId = await _messageDataSource.replyToMessage(
      roomId,
      replyToMessageId,
      text,
      selfDestructAfter: selfDestructAfter,
      mentionedUserIds: mentionedUserIds,
      mentionsRoom: mentionsRoom,
    );
    if (eventId == null) return null;

    return _getMessageById(roomId, eventId);
  }

  @override
  Future<MessageEntity?> editMessage(
    String roomId,
    String messageId,
    String newText,
  ) async {
    final eventId = await _messageDataSource.editMessage(
      roomId,
      messageId,
      newText,
    );
    if (eventId == null) return null;

    return _getMessageById(roomId, eventId);
  }

  @override
  Future<bool> addReaction(
    String roomId,
    String messageId,
    String emoji,
  ) async {
    return await _messageDataSource.addReaction(roomId, messageId, emoji);
  }

  @override
  Future<bool> removeReaction(
    String roomId,
    String messageId,
    String emoji,
  ) async {
    try {
      final room = _client?.getRoomById(roomId);
      if (room == null) return false;

      // 查找当前用户对该消息的指定 emoji 的反应事件
      final timeline = await _getOrCreateTimeline(roomId);
      if (timeline == null) return false;

      final userId = _client?.userID;
      if (userId == null) return false;

      for (final event in timeline.events) {
        if (event.type == 'm.reaction' &&
            event.senderId == userId &&
            event.content.tryGet<Map<String, dynamic>>(
                  'm.relates_to',
                )?['event_id'] ==
                messageId &&
            event.content.tryGet<Map<String, dynamic>>(
                  'm.relates_to',
                )?['key'] ==
                emoji) {
          await room.redactEvent(event.eventId, reason: 'Remove reaction');
          return true;
        }
      }
      return false;
    } catch (e) {
      debugLog('MessageRepositoryImpl: Failed to remove reaction: $e');
      return false;
    }
  }

  @override
  Future<void> markAsRead(String roomId, String messageId) async {
    await _messageDataSource.markMessageAsRead(roomId, messageId);
  }

  @override
  Future<void> sendTypingNotification(String roomId, bool isTyping) async {
    await _messageDataSource.sendTypingNotification(roomId, isTyping);
  }

  @override
  String? getMediaUrl(String? mxcUrl, {int? width, int? height}) {
    final uri = _messageDataSource.getMediaUrl(
      mxcUrl,
      width: width,
      height: height,
    );
    return uri?.toString();
  }

  @override
  Future<Uint8List?> downloadMedia(String mxcUrl) async {
    try {
      debugLog('downloadMedia: Attempting to download from $mxcUrl');
      if (_client == null) {
        debugLog('downloadMedia: Client is null');
        return null;
      }

      // 解析 mxc:// URL
      if (!mxcUrl.startsWith('mxc://')) {
        debugLog('downloadMedia: Invalid mxc URL: $mxcUrl');
        return null;
      }

      final uri = Uri.parse(mxcUrl);
      final serverName = uri.host;
      final mediaId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';

      if (serverName.isEmpty || mediaId.isEmpty) {
        debugLog(
          'downloadMedia: Invalid mxc URL components: server=$serverName, mediaId=$mediaId',
        );
        return null;
      }

      final homeserver =
          _client!.homeserver?.toString().replaceAll(
            _trailingSlashRegExp,
            '',
          ) ??
          '';

      // 方法1: 使用 Matrix 1.11+ 认证媒体端点 (直接 HTTP 请求)
      final authenticatedUrl = MatrixUtils.getMediaDownloadUrl(
        mxcUrl,
        client: _client,
      );
      final authHeaders = MatrixUtils.buildAuthenticatedMediaHeaders(
        authenticatedUrl,
        client: _client,
      );
      if (authenticatedUrl == null) {
        debugLog('downloadMedia: Failed to build authenticated media URL');
        return null;
      }
      debugLog('downloadMedia: Trying authenticated URL: $authenticatedUrl');

      try {
        final response = await http
            .get(Uri.parse(authenticatedUrl), headers: authHeaders)
            .timeout(const Duration(seconds: 30));

        debugLog(
          'downloadMedia: Auth endpoint response: ${response.statusCode}, size: ${response.bodyBytes.length}',
        );

        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          return response.bodyBytes;
        }
      } catch (e) {
        debugLog('downloadMedia: Auth endpoint error: $e');
      }

      // 方法2: 使用传统媒体端点 v3
      final legacyUrl =
          '$homeserver/_matrix/media/v3/download/$serverName/$mediaId';
      debugLog('downloadMedia: Trying legacy v3 URL: $legacyUrl');

      try {
        final response = await http
            .get(Uri.parse(legacyUrl), headers: authHeaders)
            .timeout(const Duration(seconds: 30));

        debugLog(
          'downloadMedia: Legacy v3 response: ${response.statusCode}, size: ${response.bodyBytes.length}',
        );

        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          return response.bodyBytes;
        }
      } catch (e) {
        debugLog('downloadMedia: Legacy v3 error: $e');
      }

      // 方法3: 使用 SDK 的 getDownloadLink (无认证，适用于公开媒体)
      debugLog('downloadMedia: Trying SDK getDownloadLink');
      try {
        // ignore: deprecated_member_use
        final downloadLink = uri.getDownloadLink(_client!);
        debugLog('downloadMedia: SDK download link: $downloadLink');

        final response = await http
            .get(downloadLink)
            .timeout(const Duration(seconds: 30));
        debugLog(
          'downloadMedia: SDK link response: ${response.statusCode}, size: ${response.bodyBytes.length}',
        );

        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          return response.bodyBytes;
        }
      } catch (e) {
        debugLog('downloadMedia: SDK link error: $e');
      }

      // 方法4: 使用 Matrix SDK httpClient (带自动认证)
      debugLog('downloadMedia: Trying Matrix SDK httpClient');
      try {
        final sdkResponse = await _client!.httpClient.get(
          Uri.parse(authenticatedUrl),
        );
        debugLog(
          'downloadMedia: SDK httpClient response: ${sdkResponse.statusCode}, size: ${sdkResponse.bodyBytes.length}',
        );

        if (sdkResponse.statusCode == 200 && sdkResponse.bodyBytes.isNotEmpty) {
          return sdkResponse.bodyBytes;
        }
      } catch (e) {
        debugLog('downloadMedia: SDK httpClient error: $e');
      }

      debugLog('downloadMedia: All methods failed');
      return null;
    } catch (e, stackTrace) {
      debugLog('downloadMedia: Error downloading media: $e');
      debugLog('downloadMedia: Stack trace: $stackTrace');
      return null;
    }
  }

  @override
  Future<MessageEntity?> forwardMediaMessage(
    String roomId, {
    required String mxcUrl,
    required String msgType,
    required String filename,
    String? mimeType,
    int? width,
    int? height,
    int? size,
    int? duration,
    String? thumbnailUrl,
  }) async {
    try {
      debugLog(
        'forwardMediaMessage: roomId=$roomId, mxcUrl=$mxcUrl, msgType=$msgType',
      );

      final room = _client?.getRoomById(roomId);
      if (room == null) {
        debugLog('forwardMediaMessage: Room not found');
        return null;
      }

      // 构建媒体消息内容
      final content = <String, dynamic>{
        'msgtype': msgType,
        'body': filename,
        'url': mxcUrl,
      };

      // 添加 info 字段
      final info = <String, dynamic>{};
      if (mimeType != null) info['mimetype'] = mimeType;
      if (width != null) info['w'] = width;
      if (height != null) info['h'] = height;
      if (size != null) info['size'] = size;
      if (duration != null) info['duration'] = duration;
      if (thumbnailUrl != null) info['thumbnail_url'] = thumbnailUrl;

      if (info.isNotEmpty) {
        content['info'] = info;
      }

      // 对于文件类型，添加 filename
      if (msgType == 'm.file') {
        content['filename'] = filename;
      }

      debugLog('forwardMediaMessage: Sending content: $content');
      final eventId = await room.sendEvent(content);
      debugLog('forwardMediaMessage: Event sent: $eventId');

      if (eventId == null) return null;
      return _getMessageById(roomId, eventId);
    } catch (e, stackTrace) {
      debugLog('forwardMediaMessage: Error: $e');
      debugLog('forwardMediaMessage: Stack trace: $stackTrace');
      return null;
    }
  }

  @override
  Future<MessageEntity?> sendNoticeMessage({
    required String roomId,
    required String notice,
  }) async {
    try {
      return await _messageDataSource.sendNoticeMessage(
        roomId: roomId,
        notice: notice,
      );
    } catch (e) {
      debugLog('MessageRepositoryImpl: Failed to send notice: $e');
      return null;
    }
  }

  @override
  Future<String?> getMemberPokeText({
    required String roomId,
    required String userId,
  }) async {
    try {
      return await _messageDataSource.getMemberPokeText(
        roomId: roomId,
        userId: userId,
      );
    } catch (e) {
      debugLog('MessageRepositoryImpl: Failed to get member pokeText: $e');
      return null;
    }
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _client?.userID;
  }

  @override
  Future<MessageEntity?> sendPollMessage(
    String roomId, {
    required String question,
    required List<String> options,
    int maxSelections = 1,
    bool isAnonymous = false,
    int? quizCorrectIndex,
    String? quizExplanation,
  }) async {
    try {
      debugLog(
        'MessageRepositoryImpl: Sending poll - question: $question, options: $options, isAnonymous: $isAnonymous',
      );
      final eventId = await _messageDataSource.sendPollMessage(
        roomId,
        question: question,
        options: options,
        maxSelections: maxSelections,
        isAnonymous: isAnonymous,
        quizCorrectIndex: quizCorrectIndex,
        quizExplanation: quizExplanation,
      );
      if (eventId != null) {
        debugLog(
          'MessageRepositoryImpl: Poll sent successfully - eventId: $eventId',
        );

        // 获取发送者名称
        String senderName = '';
        try {
          final userId = _client?.userID;
          if (userId != null) {
            final profile = await _client?.getUserProfile(userId);
            senderName =
                profile?.displayname ??
                userId.split(':').first.replaceFirst('@', '');
          }
        } catch (e) {
          senderName =
              _client?.userID?.split(':').first.replaceFirst('@', '') ?? '';
        }

        // 返回一个临时消息实体
        return MessageEntity(
          id: eventId,
          roomId: roomId,
          senderId: _client?.userID ?? '',
          senderName: senderName,
          content: question,
          type: MessageType.poll,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
          metadata: MessageMetadata(
            pollQuestion: question,
            pollOptions: options,
            isAnonymousPoll: isAnonymous,
            maxSelections: maxSelections,
            quizCorrectIndex: quizCorrectIndex,
            quizExplanation: quizExplanation,
          ),
        );
      }
      return null;
    } catch (e) {
      debugLog('MessageRepositoryImpl: Failed to send poll: $e');
      rethrow;
    }
  }

  @override
  Future<MessageEntity?> sendForwardedPollSnapshot(
    String roomId, {
    required String question,
    required List<String> options,
    required List<String> optionIds,
    required Map<String, int> voteCounts,
    required int totalVoters,
    int maxSelections = 1,
  }) async {
    try {
      debugLog(
        'MessageRepositoryImpl: Sending forwarded poll snapshot - question: $question',
      );
      final eventId = await _messageDataSource.sendForwardedPollSnapshot(
        roomId,
        question: question,
        options: options,
        optionIds: optionIds,
        voteCounts: voteCounts,
        totalVoters: totalVoters,
        maxSelections: maxSelections,
      );
      if (eventId != null) {
        debugLog(
          'MessageRepositoryImpl: Forwarded poll sent successfully - eventId: $eventId',
        );

        // 获取发送者名称
        String senderName = '';
        try {
          final userId = _client?.userID;
          if (userId != null) {
            final profile = await _client?.getUserProfile(userId);
            senderName =
                profile?.displayname ??
                userId.split(':').first.replaceFirst('@', '');
          }
        } catch (e) {
          senderName =
              _client?.userID?.split(':').first.replaceFirst('@', '') ?? '';
        }

        // 返回一个临时消息实体
        return MessageEntity(
          id: eventId,
          roomId: roomId,
          senderId: _client?.userID ?? '',
          senderName: senderName,
          content: question,
          type: MessageType.poll,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
          metadata: MessageMetadata(
            pollQuestion: question,
            pollOptions: options,
            pollOptionIds: optionIds,
            voteCounts: voteCounts,
            totalVoters: totalVoters,
            maxSelections: maxSelections,
            pollEnded: true,
          ),
        );
      }
      return null;
    } catch (e) {
      debugLog(
        'MessageRepositoryImpl: Failed to send forwarded poll snapshot: $e',
      );
      rethrow;
    }
  }

  @override
  Future<bool> voteOnPoll(
    String roomId, {
    required String pollEventId,
    required List<String> selectedOptionIds,
  }) async {
    try {
      debugLog(
        'MessageRepositoryImpl: Voting on poll - pollEventId: $pollEventId, options: $selectedOptionIds',
      );
      return await _messageDataSource.voteOnPoll(
        roomId,
        pollEventId: pollEventId,
        selectedOptionIds: selectedOptionIds,
      );
    } catch (e) {
      debugLog('MessageRepositoryImpl: Failed to vote on poll: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getPollAggregations(
    String roomId,
    String pollEventId,
  ) async {
    try {
      return await _messageDataSource.getPollAggregations(roomId, pollEventId);
    } catch (e) {
      debugLog('MessageRepositoryImpl: Failed to get poll aggregations: $e');
      return null;
    }
  }

  @override
  Stream<Map<String, dynamic>>? watchPollResponses(String roomId) {
    return _messageDataSource.watchPollResponses(roomId);
  }

  @override
  Future<bool> endPoll(String roomId, String pollEventId) async {
    try {
      return await _messageDataSource.endPoll(roomId, pollEventId);
    } catch (e) {
      debugLog('MessageRepositoryImpl: Failed to end poll: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getReactionAggregations(
    String roomId,
    String eventId,
  ) async {
    try {
      return await _messageDataSource.getReactionAggregations(roomId, eventId);
    } catch (e) {
      debugLog(
        'MessageRepositoryImpl: Failed to get reaction aggregations: $e',
      );
      return null;
    }
  }

  @override
  Future<String?> sendCustomMessage(
    String roomId, {
    required String msgType,
    required String content,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      debugLog(
        'MessageRepositoryImpl: Sending custom message - type: $msgType',
      );

      // 构建消息内容
      final messageContent = <String, dynamic>{
        'msgtype': msgType,
        'body': content,
        ...?additionalData,
      };

      return await _messageDataSource.sendCustomMessage(
        roomId: roomId,
        msgType: msgType,
        content: messageContent,
      );
    } catch (e) {
      debugLog('MessageRepositoryImpl: Failed to send custom message: $e');
      rethrow;
    }
  }

  @override
  Future<String?> sendContactCard(
    String roomId, {
    required String userId,
    required String displayName,
    String? avatarUrl,
    String? matrixId,
  }) async {
    try {
      debugLog(
        'MessageRepositoryImpl: Sending contact card - userId: $userId, displayName: $displayName',
      );

      return await _messageDataSource.sendContactCard(
        roomId,
        userId: userId,
        displayName: displayName,
        avatarUrl: avatarUrl,
        matrixId: matrixId,
      );
    } catch (e) {
      debugLog('MessageRepositoryImpl: Failed to send contact card: $e');
      rethrow;
    }
  }

  // ============================================
  // 辅助方法
  // ============================================

  Future<matrix.Timeline?> _getOrCreateTimeline(
    String roomId, {
    bool requestHistory = true,
  }) async {
    // 更新访问顺序（LRU）
    _timelineAccessOrder.remove(roomId);
    _timelineAccessOrder.add(roomId);

    if (_timelines.containsKey(roomId)) {
      return _timelines[roomId];
    }

    final room = _client?.getRoomById(roomId);
    if (room == null) return null;

    // 检查缓存是否已满，移除最久未使用的 timeline
    while (_timelines.length >= _maxTimelineCacheSize &&
        _timelineAccessOrder.isNotEmpty) {
      final oldestRoomId = _timelineAccessOrder.removeAt(0);
      final oldestTimeline = _timelines.remove(oldestRoomId);
      oldestTimeline?.cancelSubscriptions();
      final controller = _timelineUpdateControllers.remove(oldestRoomId);
      unawaited(controller?.close());
      _missingKeyRequestTimes.removeWhere(
        (key, _) => key.startsWith('$oldestRoomId|'),
      );
      debugLog(
        'MessageRepositoryImpl: Evicted timeline cache for room $oldestRoomId (LRU)',
      );
    }

    final updateController = StreamController<void>.broadcast();
    final timeline = await room.getTimeline(
      onUpdate: () {
        if (!updateController.isClosed) {
          updateController.add(null);
        }
      },
    );
    _timelines[roomId] = timeline;
    _timelineUpdateControllers[roomId] = updateController;

    // 自动请求历史消息以确保有足够的消息显示
    // 优化：降低阈值和请求数量，减少约 60% 网络请求
    // 大多数场景下 20 条消息已足够首屏显示
    if (requestHistory && timeline.events.length < 20) {
      debugLog(
        'MessageRepositoryImpl: Timeline has ${timeline.events.length} events, requesting more history...',
      );
      try {
        await timeline.requestHistory(historyCount: 30);
        debugLog(
          'MessageRepositoryImpl: After requestHistory, timeline has ${timeline.events.length} events',
        );
      } catch (e) {
        debugLog('MessageRepositoryImpl: Failed to request history: $e');
      }
    }

    _requestMissingTimelineKeys(room, timeline);

    return timeline;
  }

  void _requestMissingTimelineKeys(matrix.Room room, matrix.Timeline timeline) {
    final keyManager = room.client.encryption?.keyManager;
    if (!room.client.encryptionEnabled || keyManager == null) {
      return;
    }

    final now = DateTime.now();
    for (final event in timeline.events) {
      if (event.type != matrix.EventTypes.Encrypted ||
          event.messageType != matrix.MessageTypes.BadEncrypted ||
          event.content['can_request_session'] != true) {
        continue;
      }

      final sessionId = event.content['session_id'];
      final senderKey = event.content['sender_key'];
      if (sessionId is! String || sessionId.isEmpty) {
        continue;
      }

      final requestKey = '${room.id}|$sessionId';
      final lastRequest = _missingKeyRequestTimes[requestKey];
      if (lastRequest != null &&
          now.difference(lastRequest) < _missingKeyRetryInterval) {
        continue;
      }
      _missingKeyRequestTimes[requestKey] = now;

      debugLog(
        'MessageRepositoryImpl: Requesting missing Megolm session '
        '$sessionId for ${room.id}',
      );
      unawaited(
        keyManager
            .request(
              room,
              sessionId,
              senderKey is String ? senderKey : null,
              tryOnlineBackup: true,
              onlineKeyBackupOnly: false,
            )
            .catchError((Object error) {
              _missingKeyRequestTimes.remove(requestKey);
              debugLog(
                'MessageRepositoryImpl: Missing key request failed: $error',
              );
            }),
      );
    }
  }

  List<MessageEntity> _getMessagesFromTimeline(
    matrix.Timeline timeline,
    matrix.Room room,
  ) {
    final now = DateTime.now();
    final allEvents = timeline.events;
    final messages = allEvents
        .where((e) => _isDisplayableEvent(e))
        .map((e) => _getCachedOrMapMessage(e, room, now))
        .toList();
    return _applyPaymentRequestFulfillments(messages, allEvents);
  }

  /// 从缓存获取消息或重新映射
  MessageEntity _getCachedOrMapMessage(
    matrix.Event event,
    matrix.Room room,
    DateTime now,
  ) {
    final eventId = event.eventId;

    // Never cache the user-facing decryption failure. When the session key
    // arrives, Timeline replaces this event in-place using the same event ID;
    // caching it would keep the green error bubble visible for five minutes.
    final isMissingSessionKey =
        event.type == matrix.EventTypes.Encrypted &&
        event.messageType == matrix.MessageTypes.BadEncrypted;
    if (isMissingSessionKey) {
      _messageEntityCache.remove(eventId);
      return _messageDataSource.mapEventToMessage(event, room);
    }

    final cached = _messageEntityCache[eventId];

    // 检查缓存是否存在且未过期
    if (cached != null) {
      final (entity, cachedAt) = cached;
      if (now.difference(cachedAt) < _messageCacheExpiry) {
        return entity;
      }
    }

    // 缓存不存在或已过期，重新映射
    final entity = _messageDataSource.mapEventToMessage(event, room);
    _messageEntityCache[eventId] = (entity, now);

    // 清理过期缓存（每 100 次访问清理一次）
    if (_messageEntityCache.length > 500) {
      _cleanExpiredMessageCache(now);
    }

    return entity;
  }

  MessageEntity? _findMessageInTimeline(
    matrix.Timeline timeline,
    matrix.Room room,
    String messageId,
  ) {
    for (final event in timeline.events) {
      if (event.eventId == messageId) {
        return _applyPaymentRequestFulfillmentsToMessage(
          _messageDataSource.mapEventToMessage(event, room),
          timeline.events,
        );
      }
    }
    return null;
  }

  List<MessageEntity> _applyPaymentRequestFulfillments(
    List<MessageEntity> messages,
    List<matrix.Event> allEvents,
  ) {
    final fulfilledRequestIds = _collectFulfilledPaymentRequestIds(allEvents);
    if (fulfilledRequestIds.isEmpty) {
      return messages;
    }

    return messages
        .map(
          (message) => _applyPaymentRequestFulfillmentsToMessage(
            message,
            allEvents,
            fulfilledRequestIds: fulfilledRequestIds,
          ),
        )
        .toList();
  }

  MessageEntity _applyPaymentRequestFulfillmentsToMessage(
    MessageEntity message,
    List<matrix.Event> allEvents, {
    Set<String>? fulfilledRequestIds,
  }) {
    if (message.type != MessageType.paymentRequest) {
      return message;
    }

    final requestId = message.metadata?.paymentRequestId;
    if (requestId == null || requestId.isEmpty) {
      return message;
    }

    final fulfilled =
        fulfilledRequestIds ?? _collectFulfilledPaymentRequestIds(allEvents);
    if (!fulfilled.contains(requestId)) {
      return message;
    }

    final metadata =
        message.metadata?.copyWithTransfer(transferStatus: 'completed') ??
        const MessageMetadata(transferStatus: 'completed');
    return message.copyWith(metadata: metadata);
  }

  Set<String> _collectFulfilledPaymentRequestIds(List<matrix.Event> events) {
    final fulfilled = <String>{};
    for (final event in events) {
      if (event.type != PaymentRequestFulfillmentContent.eventType) {
        continue;
      }

      try {
        final content = PaymentRequestFulfillmentContent.fromEventContent(
          event.content,
        );
        if (content.requestId.isNotEmpty) {
          fulfilled.add(content.requestId);
        }
      } catch (e) {
        debugLog(
          'MessageRepositoryImpl: Failed to parse payment fulfillment event: $e',
        );
      }
    }
    return fulfilled;
  }

  /// 清理过期的消息缓存
  void _cleanExpiredMessageCache(DateTime now) {
    _messageEntityCache.removeWhere((_, value) {
      final (_, cachedAt) = value;
      return now.difference(cachedAt) >= _messageCacheExpiry;
    });
    debugLog(
      'MessageRepositoryImpl: Cleaned message cache, remaining: ${_messageEntityCache.length}',
    );
  }

  Future<MessageEntity?> _getMessageById(String roomId, String eventId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return null;

    final event = await room.getEventById(eventId);
    if (event == null) return null;

    return _messageDataSource.mapEventToMessage(event, room);
  }

  bool _isDisplayableEvent(matrix.Event event) {
    // 过滤掉编辑替换事件（m.replace）：编辑事件的 type 仍是 m.room.message，
    // 仅凭 type 无法区分，必须检查 m.relates_to.rel_type。
    // matrix-dart-sdk 理论上会在 Timeline 层聚合编辑事件，但部分版本下
    // 编辑事件仍会出现在 timeline.events 中，导致 UI 新增一条重复消息。
    final relatesTo = event.content['m.relates_to'];
    if (relatesTo is Map && relatesTo['rel_type'] == 'm.replace') {
      return false;
    }

    return event.type == matrix.EventTypes.Message ||
        event.type == matrix.EventTypes.Encrypted ||
        event.type == matrix.EventTypes.Sticker ||
        event.type == 'org.matrix.msc3381.poll.start';
  }

  /// 清理时间线缓存
  void disposeTimeline(String roomId) {
    _timelines.remove(roomId)?.cancelSubscriptions();
    _timelineAccessOrder.remove(roomId);
    final controller = _timelineUpdateControllers.remove(roomId);
    unawaited(controller?.close());
    _missingKeyRequestTimes.removeWhere((key, _) => key.startsWith('$roomId|'));
  }

  /// 清理所有时间线缓存
  void disposeAllTimelines() {
    for (final timeline in _timelines.values) {
      timeline.cancelSubscriptions();
    }
    for (final controller in _timelineUpdateControllers.values) {
      unawaited(controller.close());
    }
    _timelines.clear();
    _timelineAccessOrder.clear();
    _timelineUpdateControllers.clear();
    _missingKeyRequestTimes.clear();
    _messageEntityCache.clear();
  }

  // ============================================
  // 本地删除消息管理
  // ============================================

  @override
  Future<Set<String>> getLocallyDeletedMessageIds(String roomId) async {
    return _secureStorage.getLocallyDeletedMessageIds(roomId);
  }

  @override
  Future<void> markMessagesAsLocallyDeleted(
    String roomId,
    List<String> messageIds,
  ) async {
    await _secureStorage.markMessagesAsLocallyDeleted(roomId, messageIds);
  }

  @override
  Future<void> clearLocallyDeletedMessages(String roomId) async {
    await _secureStorage.clearLocallyDeletedMessages(roomId);
  }

  @override
  Future<MessageEntity?> sendSelfDestructingMessage(
    String roomId,
    String text, {
    required int selfDestructAfter,
  }) async {
    final eventId = await _messageDataSource.sendTextMessage(
      roomId,
      text,
      selfDestructAfter: selfDestructAfter,
    );
    if (eventId == null) return null;

    return _getMessageById(roomId, eventId);
  }

  @override
  Future<MessageEntity?> startMessageDestruction(
    String roomId,
    String messageId,
  ) async {
    // 获取当前消息
    final message = await _getMessageById(roomId, messageId);
    if (message == null || !message.isSelfDestructing) return null;

    // 如果已经开始销毁，直接返回
    if (message.isDestructionStarted) return message;

    // 计算销毁时间
    final destroyedAt = DateTime.now().add(
      Duration(seconds: message.selfDestructAfter!),
    );

    // 存储销毁时间到本地存储
    await _secureStorage.setMessageDestroyedAt(roomId, messageId, destroyedAt);

    // 返回更新后的消息
    return message.copyWith(destroyedAt: destroyedAt);
  }

  @override
  Future<void> destroyExpiredMessages(String roomId) async {
    try {
      // 获取所有消息的销毁时间
      final destructionTimes = await _secureStorage.getMessageDestructionTimes(
        roomId,
      );
      if (destructionTimes.isEmpty) return;

      final now = DateTime.now();
      final expiredMessageIds = <String>[];

      for (final entry in destructionTimes.entries) {
        if (entry.value.isBefore(now)) {
          expiredMessageIds.add(entry.key);
        }
      }

      if (expiredMessageIds.isEmpty) return;

      debugLog(
        'MessageRepositoryImpl: Destroying ${expiredMessageIds.length} expired messages',
      );

      // 撤回过期消息
      for (final messageId in expiredMessageIds) {
        try {
          await redactMessage(roomId, messageId, reason: 'Self-destructed');
        } catch (e) {
          debugLog(
            'MessageRepositoryImpl: Failed to redact message $messageId: $e',
          );
        }
      }

      // 清除销毁时间记录
      await _secureStorage.clearMessageDestructionTimes(
        roomId,
        expiredMessageIds,
      );
    } catch (e) {
      debugLog('MessageRepositoryImpl: Error destroying expired messages: $e');
    }
  }

  @override
  Future<List<AlbumMediaEntity>> getRoomMedia(
    String roomId, {
    AlbumFilter? filter,
    int limit = 50,
    String? beforeEventId,
  }) async {
    return await _messageDataSource.getRoomMedia(
      roomId,
      filter: filter,
      limit: limit,
      beforeEventId: beforeEventId,
    );
  }

  // ============================================
  // 消息线程 (MSC3440)
  // ============================================

  @override
  Future<List<MessageEntity>> getThreadMessages(
    String roomId,
    String threadRootEventId, {
    int limit = 50,
    String? fromEventId,
  }) async {
    return await _messageDataSource.getThreadMessages(
      roomId,
      threadRootEventId,
      limit: limit,
      fromToken: fromEventId,
    );
  }

  @override
  Stream<List<MessageEntity>> watchThreadMessages(
    String roomId,
    String threadRootEventId,
  ) {
    return _messageDataSource.watchThreadMessages(roomId, threadRootEventId);
  }

  @override
  Future<MessageEntity?> sendThreadTextMessage(
    String roomId,
    String threadRootEventId,
    String text,
  ) async {
    final eventId = await _messageDataSource.sendThreadMessage(
      roomId,
      threadRootEventId,
      text,
    );
    if (eventId == null) return null;

    return await _getMessageById(roomId, eventId) ??
        MessageEntity(
          id: eventId,
          roomId: roomId,
          senderId: _clientManager.client?.userID ?? '',
          senderName: _clientManager.client?.userID ?? '',
          content: text,
          type: MessageType.text,
          timestamp: DateTime.now(),
          status: MessageStatus.sending,
          isFromMe: true,
          threadRootId: threadRootEventId,
        );
  }

  @override
  Future<MessageEntity?> sendThreadImageMessage(
    String roomId,
    String threadRootEventId, {
    required Uint8List imageBytes,
    required String filename,
    String? mimeType,
  }) async {
    final eventId = await _messageDataSource.sendThreadImageMessage(
      roomId,
      threadRootEventId,
      imageBytes: imageBytes,
      filename: filename,
      mimeType: mimeType,
    );
    if (eventId == null) return null;

    return await _getMessageById(roomId, eventId) ??
        MessageEntity(
          id: eventId,
          roomId: roomId,
          senderId: _clientManager.client?.userID ?? '',
          senderName: _clientManager.client?.userID ?? '',
          content: filename,
          type: MessageType.image,
          timestamp: DateTime.now(),
          status: MessageStatus.sending,
          isFromMe: true,
          threadRootId: threadRootEventId,
        );
  }

  @override
  Future<MessageEntity?> sendThreadFileMessage(
    String roomId,
    String threadRootEventId, {
    required Uint8List fileBytes,
    required String filename,
    String? mimeType,
  }) async {
    final eventId = await _messageDataSource.sendThreadFileMessage(
      roomId,
      threadRootEventId,
      fileBytes: fileBytes,
      filename: filename,
      mimeType: mimeType,
    );
    if (eventId == null) return null;

    return await _getMessageById(roomId, eventId) ??
        MessageEntity(
          id: eventId,
          roomId: roomId,
          senderId: _clientManager.client?.userID ?? '',
          senderName: _clientManager.client?.userID ?? '',
          content: filename,
          type: MessageType.file,
          timestamp: DateTime.now(),
          status: MessageStatus.sending,
          isFromMe: true,
          threadRootId: threadRootEventId,
        );
  }

  @override
  Future<List<MessageEntity>> getRoomThreadRoots(String roomId) async {
    return await _messageDataSource.getRoomThreadRoots(roomId);
  }

  @override
  Future<List<GroupFileEntity>> getRoomFiles(
    String roomId, {
    GroupFileType? type,
    int limit = 50,
    String? fromEventId,
  }) async {
    return await _messageDataSource.getRoomFiles(
      roomId,
      type: type,
      limit: limit,
      fromEventId: fromEventId,
    );
  }

  @override
  Future<void> reportMessage(
    String roomId,
    String eventId, {
    required String reason,
  }) async {
    final client = _clientManager.client;
    if (client == null) throw Exception('Matrix client not initialized');
    final room = client.getRoomById(roomId);
    if (room == null) throw Exception('Room not found');
    await client.reportEvent(roomId, eventId, score: -100, reason: reason);
  }
}
