import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:matrix/matrix.dart' as matrix;

import '../../../domain/entities/group_album_entity.dart';
import '../../../domain/entities/group_file_entity.dart';
import '../../../domain/entities/live_location_entity.dart';
import '../../../domain/entities/message_entity.dart';
import 'matrix_client_manager.dart';
import 'message/matrix_event_mapper.dart';
import 'message/matrix_media_uploader.dart';
import 'message/matrix_message_operations.dart';
import 'message/matrix_message_sender.dart';
import 'message/matrix_poll_handler.dart';
import 'message/matrix_room_media.dart';
import 'message/matrix_thread_handler.dart';

/// Matrix消息数据源
///
/// 封装Matrix SDK的消息相关操作。
/// 内部通过组合多个职责子类实现，保持对外接口不变。
class MatrixMessageDataSource {
  final MatrixClientManager _clientManager;

  /// 子组件：各职责处理器
  late final MatrixMediaUploader _uploader;
  late final MatrixEventMapper _eventMapper;
  late final MatrixMessageSender _sender;
  late final MatrixMessageOperations _operations;
  late final MatrixPollHandler _pollHandler;
  late final MatrixThreadHandler _threadHandler;
  late final MatrixRoomMedia _roomMedia;

  MatrixMessageDataSource(this._clientManager) {
    _uploader = MatrixMediaUploader(_clientManager);
    _eventMapper = MatrixEventMapper(() => _client);
    _sender = MatrixMessageSender(_clientManager, _uploader);
    _operations = MatrixMessageOperations(_clientManager);
    _pollHandler = MatrixPollHandler(_clientManager);
    _threadHandler = MatrixThreadHandler(_clientManager, _eventMapper);
    _roomMedia = MatrixRoomMedia(_clientManager, _eventMapper);
  }

  /// 获取Matrix客户端
  matrix.Client? get _client => _clientManager.client;
  String? get currentUserId => _client?.userID;

  // ============================================
  // 消息获取
  // ============================================

  /// 获取房间的时间线
  Future<matrix.Timeline?> getTimeline(String roomId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return null;

    return await room.getTimeline();
  }

  /// 获取房间消息历史
  Future<List<matrix.Event>> getMessages(
    String roomId, {
    int limit = 50,
    String? fromEventId,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return [];

    final timeline = await room.getTimeline();

    // 如果需要加载更多历史消息
    if (fromEventId != null) {
      await timeline.requestHistory(historyCount: limit);
    }

    // 过滤出消息事件
    return timeline.events
        .where((event) => _eventMapper.isMessageEvent(event))
        .take(limit)
        .toList();
  }

  /// 加载更多历史消息
  Future<bool> loadMoreMessages(String roomId, {int count = 50}) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return false;

    final timeline = await room.getTimeline();

    try {
      await timeline.requestHistory(historyCount: count);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 根据事件ID获取消息
  Future<matrix.Event?> getMessageById(String roomId, String eventId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return null;

    return await room.getEventById(eventId);
  }

  List<LiveLocationEntity> getActiveLiveLocations(String roomId) {
    final room = _client?.getRoomById(roomId);
    if (room == null) return const [];

    final shareStates = room.states['n42.live_location'];
    if (shareStates == null || shareStates.isEmpty) {
      return const [];
    }

    final updateStates = room.states['n42.live_location.update'] ?? const {};
    final memberStates = room.states[matrix.EventTypes.RoomMember] ?? const {};
    final now = DateTime.now();
    final locations = <LiveLocationEntity>[];

    for (final entry in shareStates.entries) {
      final userId = entry.key;
      final sharingEvent = entry.value;
      final sharingContent = sharingEvent.content;
      if (sharingContent['sharing'] != true) {
        continue;
      }

      final expiresAt =
          DateTime.tryParse(sharingContent['expires_at'] as String? ?? '') ??
          DateTime.tryParse(sharingContent['started_at'] as String? ?? '') ??
          now;
      if (!expiresAt.isAfter(now)) {
        continue;
      }

      final updateEvent = updateStates[userId];
      final updateContent = updateEvent?.content;
      final latitude = _toDouble(updateContent?['latitude']);
      final longitude = _toDouble(updateContent?['longitude']);
      if (latitude == null || longitude == null) {
        continue;
      }

      final updatedAt =
          DateTime.tryParse(updateContent?['updated_at'] as String? ?? '') ??
          DateTime.tryParse(sharingContent['started_at'] as String? ?? '') ??
          now;
      final durationMinutes =
          _toInt(sharingContent['duration_minutes']) ??
          expiresAt.difference(updatedAt).inMinutes.clamp(1, 1440).toInt();

      final memberEvent = memberStates[userId];
      final memberContent = memberEvent?.content ?? const <String, dynamic>{};
      final avatarUrl = memberContent['avatar_url'] as String?;
      final httpAvatarUrl = avatarUrl != null && avatarUrl.startsWith('mxc://')
          ? _eventMapper.getMediaUrl(avatarUrl)?.toString()
          : avatarUrl;

      locations.add(
        LiveLocationEntity(
          userId: userId,
          displayName: memberContent['displayname'] as String? ?? userId,
          avatarUrl: httpAvatarUrl,
          latitude: latitude,
          longitude: longitude,
          accuracy: _toDouble(updateContent?['accuracy']),
          updatedAt: updatedAt,
          expiresAt: expiresAt,
          durationMinutes: durationMinutes,
        ),
      );
    }

    locations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return locations;
  }

  Stream<List<LiveLocationEntity>> watchLiveLocations(String roomId) async* {
    yield getActiveLiveLocations(roomId);

    final syncStream = _client?.onSync.stream;
    if (syncStream == null) {
      return;
    }

    await for (final _ in syncStream) {
      yield getActiveLiveLocations(roomId);
    }
  }

  // ============================================
  // 消息发送
  // ============================================

  /// 发送文本消息
  Future<String?> sendTextMessage(
    String roomId,
    String text, {
    int? selfDestructAfter,
    List<String>? mentionedUserIds,
    bool mentionsRoom = false,
  }) => _sender.sendTextMessage(
    roomId,
    text,
    selfDestructAfter: selfDestructAfter,
    mentionedUserIds: mentionedUserIds,
    mentionsRoom: mentionsRoom,
  );

  /// 发送图片消息
  Future<String?> sendImageMessage(
    String roomId, {
    required Uint8List imageBytes,
    required String filename,
    String? mimeType,
    int? selfDestructAfter,
  }) => _sender.sendImageMessage(
    roomId,
    imageBytes: imageBytes,
    filename: filename,
    mimeType: mimeType,
    selfDestructAfter: selfDestructAfter,
  );

  /// 发送语音消息
  Future<String?> sendVoiceMessage(
    String roomId, {
    required Uint8List audioBytes,
    required String filename,
    required int duration,
    String? mimeType,
    int? selfDestructAfter,
  }) => _sender.sendVoiceMessage(
    roomId,
    audioBytes: audioBytes,
    filename: filename,
    duration: duration,
    mimeType: mimeType,
    selfDestructAfter: selfDestructAfter,
  );

  /// 发送视频消息
  Future<String?> sendVideoMessage(
    String roomId, {
    required Uint8List videoBytes,
    required String filename,
    String? mimeType,
    Uint8List? thumbnailBytes,
    int? selfDestructAfter,
  }) => _sender.sendVideoMessage(
    roomId,
    videoBytes: videoBytes,
    filename: filename,
    mimeType: mimeType,
    thumbnailBytes: thumbnailBytes,
    selfDestructAfter: selfDestructAfter,
  );

  /// 发送文件消息
  Future<String?> sendFileMessage(
    String roomId, {
    Uint8List? fileBytes,
    required String filename,
    String? mimeType,
    int? selfDestructAfter,
    String? filePath,
    Stream<List<int>>? fileStream,
    int? fileSize,
  }) => _sender.sendFileMessage(
    roomId,
    fileBytes: fileBytes,
    filename: filename,
    mimeType: mimeType,
    selfDestructAfter: selfDestructAfter,
    filePath: filePath,
    fileStream: fileStream,
    fileSize: fileSize,
  );

  /// 发送位置消息
  Future<String?> sendLocationMessage(
    String roomId, {
    required double latitude,
    required double longitude,
    String? description,
  }) => _sender.sendLocationMessage(
    roomId,
    latitude: latitude,
    longitude: longitude,
    description: description,
  );

  /// 发送 GIF 消息
  Future<String?> sendGifMessage(
    String roomId, {
    required String gifUrl,
    String? previewUrl,
    int? width,
    int? height,
    String? title,
  }) => _sender.sendGifMessage(
    roomId,
    gifUrl: gifUrl,
    previewUrl: previewUrl,
    width: width,
    height: height,
    title: title,
  );

  /// 发送贴纸消息
  Future<String?> sendStickerMessage(
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
  }) => _sender.sendStickerMessage(
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

  /// 发送自定义消息
  Future<String> sendCustomMessage({
    required String roomId,
    required String msgType,
    required Map<String, dynamic> content,
  }) => _sender.sendCustomMessage(
    roomId: roomId,
    msgType: msgType,
    content: content,
  );

  /// 发送自定义房间事件（不直接展示为聊天消息）
  Future<String> sendRoomEvent({
    required String roomId,
    required String type,
    required Map<String, dynamic> content,
  }) => _sender.sendRoomEvent(roomId: roomId, type: type, content: content);

  /// 重发消息
  Future<bool> resendMessage(String roomId, String eventId) =>
      _sender.resendMessage(roomId, eventId);

  /// 发送系统通知/拍一拍消息
  Future<MessageEntity?> sendNoticeMessage({
    required String roomId,
    required String notice,
  }) => _sender.sendNoticeMessage(roomId: roomId, notice: notice);

  /// 发送联系人名片消息
  Future<String?> sendContactCard(
    String roomId, {
    required String userId,
    required String displayName,
    String? avatarUrl,
    String? matrixId,
  }) => _sender.sendContactCard(
    roomId,
    userId: userId,
    displayName: displayName,
    avatarUrl: avatarUrl,
    matrixId: matrixId,
  );

  // ============================================
  // 消息操作
  // ============================================

  /// 撤回消息
  Future<bool> redactMessage(String roomId, String eventId, {String? reason}) =>
      _operations.redactMessage(roomId, eventId, reason: reason);

  /// 删除发送失败的消息
  Future<bool> deleteFailedMessage(String roomId, String eventId) =>
      _operations.deleteFailedMessage(roomId, eventId);

  /// 回复消息
  Future<String?> replyToMessage(
    String roomId,
    String replyToEventId,
    String text, {
    int? selfDestructAfter,
    List<String>? mentionedUserIds,
    bool mentionsRoom = false,
  }) => _operations.replyToMessage(
    roomId,
    replyToEventId,
    text,
    selfDestructAfter: selfDestructAfter,
    mentionedUserIds: mentionedUserIds,
    mentionsRoom: mentionsRoom,
  );

  /// 编辑消息
  Future<String?> editMessage(
    String roomId,
    String originalEventId,
    String newText,
  ) => _operations.editMessage(roomId, originalEventId, newText);

  /// 添加消息表情回应
  Future<bool> addReaction(String roomId, String eventId, String emoji) =>
      _operations.addReaction(roomId, eventId, emoji);

  // ============================================
  // 消息已读状态
  // ============================================

  /// 标记消息已读
  Future<void> markMessageAsRead(String roomId, String eventId) =>
      _operations.markMessageAsRead(roomId, eventId);

  /// 发送正在输入状态
  Future<void> sendTypingNotification(String roomId, bool isTyping) =>
      _operations.sendTypingNotification(roomId, isTyping);

  /// 获取房间成员的拍一拍后缀
  Future<String?> getMemberPokeText({
    required String roomId,
    required String userId,
  }) => _operations.getMemberPokeText(roomId: roomId, userId: userId);

  /// 设置当前用户在房间中的拍一拍后缀
  Future<void> setMemberPokeText({
    required String roomId,
    required String pokeText,
  }) => _operations.setMemberPokeText(roomId: roomId, pokeText: pokeText);

  // ============================================
  // 投票功能 (MSC3381 Polls)
  // ============================================

  /// 发送投票消息
  Future<String?> sendPollMessage(
    String roomId, {
    required String question,
    required List<String> options,
    int maxSelections = 1,
    bool isAnonymous = false,
  }) => _pollHandler.sendPollMessage(
    roomId,
    question: question,
    options: options,
    maxSelections: maxSelections,
    isAnonymous: isAnonymous,
  );

  /// 发送转发的投票快照
  Future<String?> sendForwardedPollSnapshot(
    String roomId, {
    required String question,
    required List<String> options,
    required List<String> optionIds,
    required Map<String, int> voteCounts,
    required int totalVoters,
    int maxSelections = 1,
  }) => _pollHandler.sendForwardedPollSnapshot(
    roomId,
    question: question,
    options: options,
    optionIds: optionIds,
    voteCounts: voteCounts,
    totalVoters: totalVoters,
    maxSelections: maxSelections,
  );

  /// 投票响应
  Future<bool> voteOnPoll(
    String roomId, {
    required String pollEventId,
    required List<String> selectedOptionIds,
  }) => _pollHandler.voteOnPoll(
    roomId,
    pollEventId: pollEventId,
    selectedOptionIds: selectedOptionIds,
  );

  /// 结束投票
  Future<bool> endPoll(String roomId, String pollEventId) =>
      _pollHandler.endPoll(roomId, pollEventId);

  /// 获取消息的反应聚合结果
  Future<Map<String, dynamic>?> getReactionAggregations(
    String roomId,
    String eventId,
  ) => _pollHandler.getReactionAggregations(roomId, eventId);

  /// 获取投票的聚合结果
  Future<Map<String, dynamic>?> getPollAggregations(
    String roomId,
    String pollEventId,
  ) => _pollHandler.getPollAggregations(roomId, pollEventId);

  // ============================================
  // 消息监听
  // ============================================

  /// 监听房间消息更新
  Stream<matrix.Event>? watchRoomMessages(String roomId) {
    return _client?.onTimelineEvent.stream.where((event) {
      return event.room.id == roomId && _eventMapper.isMessageEvent(event);
    });
  }

  /// 监听投票响应事件
  Stream<Map<String, dynamic>>? watchPollResponses(String roomId) {
    return _client?.onTimelineEvent.stream
        .where((event) {
          return event.room.id == roomId &&
              (event.type == 'org.matrix.msc3381.poll.response' ||
                  event.type == 'org.matrix.msc3381.poll.end');
        })
        .map((event) {
          final type = event.type;
          final relatesTo =
              event.content['m.relates_to'] as Map<String, dynamic>?;
          final pollEventId = relatesTo?['event_id'] as String?;

          if (type == 'org.matrix.msc3381.poll.response') {
            final pollResponse =
                event.content['org.matrix.msc3381.poll.response']
                    as Map<String, dynamic>?;
            final answers = pollResponse?['answers'] as List<dynamic>?;
            final senderId = event.senderId;

            return {
              'type': 'vote',
              'pollEventId': pollEventId,
              'answers': answers ?? [],
              'senderId': senderId,
              'isCurrentUser': senderId == _client?.userID,
            };
          } else {
            return {'type': 'end', 'pollEventId': pollEventId};
          }
        });
  }

  /// 监听消息发送状态
  Stream<matrix.SyncUpdate>? get onSyncUpdate => _client?.onSync.stream;

  // ============================================
  // 事件映射
  // ============================================

  /// 将Matrix事件转换为消息实体
  MessageEntity mapEventToMessage(matrix.Event event, matrix.Room room) =>
      _eventMapper.mapEventToMessage(event, room);

  /// 获取媒体下载URL
  Uri? getMediaUrl(String? mxcUrl, {int? width, int? height}) =>
      _eventMapper.getMediaUrl(mxcUrl, width: width, height: height);

  // ============================================
  // 群文件管理
  // ============================================

  /// 获取房间文件列表
  Future<List<GroupFileEntity>> getRoomFiles(
    String roomId, {
    GroupFileType? type,
    int limit = 50,
    String? fromEventId,
  }) => _roomMedia.getRoomFiles(
    roomId,
    type: type,
    limit: limit,
    fromEventId: fromEventId,
  );

  // ============================================
  // 实时位置共享
  // ============================================

  /// 开始实时位置共享
  Future<void> startLiveLocation(String roomId, int durationMinutes) =>
      _operations.startLiveLocation(roomId, durationMinutes);

  /// 更新实时位置
  Future<void> updateLiveLocation(
    String roomId,
    double latitude,
    double longitude,
    double? accuracy,
  ) => _operations.updateLiveLocation(roomId, latitude, longitude, accuracy);

  /// 停止实时位置共享
  Future<void> stopLiveLocation(String roomId) =>
      _operations.stopLiveLocation(roomId);

  double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  // ============================================
  // 群相册媒体获取
  // ============================================

  /// 获取房间媒体文件列表
  Future<List<AlbumMediaEntity>> getRoomMedia(
    String roomId, {
    AlbumFilter? filter,
    int limit = 50,
    String? beforeEventId,
  }) => _roomMedia.getRoomMedia(
    roomId,
    filter: filter,
    limit: limit,
    beforeEventId: beforeEventId,
  );

  // ============================================
  // 消息线程 (MSC3440)
  // ============================================

  /// 发送线程内消息
  Future<String?> sendThreadMessage(
    String roomId,
    String threadRootEventId,
    String text,
  ) => _threadHandler.sendThreadMessage(roomId, threadRootEventId, text);

  /// 发送线程内图片消息
  Future<String?> sendThreadImageMessage(
    String roomId,
    String threadRootEventId, {
    required Uint8List imageBytes,
    required String filename,
    String? mimeType,
  }) => _threadHandler.sendThreadImageMessage(
    roomId,
    threadRootEventId,
    imageBytes: imageBytes,
    filename: filename,
    mimeType: mimeType,
  );

  /// 发送线程内文件消息
  Future<String?> sendThreadFileMessage(
    String roomId,
    String threadRootEventId, {
    required Uint8List fileBytes,
    required String filename,
    String? mimeType,
  }) => _threadHandler.sendThreadFileMessage(
    roomId,
    threadRootEventId,
    fileBytes: fileBytes,
    filename: filename,
    mimeType: mimeType,
  );

  /// 获取线程内的消息列表
  Future<List<MessageEntity>> getThreadMessages(
    String roomId,
    String threadRootEventId, {
    int limit = 50,
    String? fromToken,
  }) => _threadHandler.getThreadMessages(
    roomId,
    threadRootEventId,
    limit: limit,
    fromToken: fromToken,
  );

  /// 监听线程消息更新
  Stream<List<MessageEntity>> watchThreadMessages(
    String roomId,
    String threadRootEventId,
  ) => _threadHandler.watchThreadMessages(roomId, threadRootEventId);

  /// 获取房间内所有线程根消息
  Future<List<MessageEntity>> getRoomThreadRoots(String roomId) =>
      _threadHandler.getRoomThreadRoots(roomId);
}
