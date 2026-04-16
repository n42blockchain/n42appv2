import 'dart:typed_data';
import 'package:matrix/matrix.dart' as matrix;

import '../../../../domain/entities/message_entity.dart';
import '../matrix_client_manager.dart';
import 'matrix_event_mapper.dart';
import 'matrix_text_message_content.dart';
import '../../../../core/utils/debug_log.dart';

/// Matrix 消息线程处理器 (MSC3440)
///
/// 封装线程消息的发送、获取和监听操作
class MatrixThreadHandler {
  final MatrixClientManager _clientManager;
  final MatrixEventMapper _eventMapper;

  MatrixThreadHandler(this._clientManager, this._eventMapper);

  matrix.Client? get _client => _clientManager.client;

  /// 发送线程内消息
  ///
  /// 按照 MSC3440 构建 m.relates_to 结构
  Future<String?> sendThreadMessage(
    String roomId,
    String threadRootEventId,
    String text,
  ) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return null;

    return room.sendEvent(
      buildTextMessageContent(text),
      threadRootEventId: threadRootEventId,
      threadLastEventId: threadRootEventId,
    );
  }

  /// 发送线程内图片消息
  Future<String?> sendThreadImageMessage(
    String roomId,
    String threadRootEventId, {
    required Uint8List imageBytes,
    required String filename,
    String? mimeType,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return null;

    final actualMimeType = mimeType ?? 'image/jpeg';

    // 上传图片
    final uri = await _client!.uploadContent(
      imageBytes,
      filename: filename,
      contentType: actualMimeType,
    );

    final content = <String, dynamic>{
      'msgtype': 'm.image',
      'body': filename,
      'url': uri.toString(),
      'info': {'mimetype': actualMimeType, 'size': imageBytes.length},
    };

    return room.sendEvent(
      content,
      threadRootEventId: threadRootEventId,
      threadLastEventId: threadRootEventId,
    );
  }

  /// 发送线程内文件消息
  Future<String?> sendThreadFileMessage(
    String roomId,
    String threadRootEventId, {
    required Uint8List fileBytes,
    required String filename,
    String? mimeType,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return null;

    final actualMimeType = mimeType ?? 'application/octet-stream';

    // 上传文件
    final uri = await _client!.uploadContent(
      fileBytes,
      filename: filename,
      contentType: actualMimeType,
    );

    final content = <String, dynamic>{
      'msgtype': 'm.file',
      'body': filename,
      'url': uri.toString(),
      'info': {'mimetype': actualMimeType, 'size': fileBytes.length},
    };

    return room.sendEvent(
      content,
      threadRootEventId: threadRootEventId,
      threadLastEventId: threadRootEventId,
    );
  }

  /// 获取线程内的消息列表
  ///
  /// 使用 Matrix /relations API (MSC3440) 获取线程消息
  Future<List<MessageEntity>> getThreadMessages(
    String roomId,
    String threadRootEventId, {
    int limit = 50,
    String? fromToken,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return [];

    try {
      // 使用 Matrix /relations API
      final response = await _client!.request(
        matrix.RequestType.GET,
        '/client/v1/rooms/${Uri.encodeComponent(roomId)}/relations/${Uri.encodeComponent(threadRootEventId)}/m.thread',
        query: {'limit': limit.toString(), 'from': ?fromToken},
      );

      final chunk = response['chunk'] as List<dynamic>? ?? [];
      final messages = <MessageEntity>[];

      for (final eventJson in chunk) {
        try {
          final event = matrix.Event.fromJson(
            eventJson as Map<String, dynamic>,
            room,
          );
          messages.add(_eventMapper.mapEventToMessage(event, room));
        } catch (e) {
          debugLog('ThreadMessages: Failed to parse event: $e');
        }
      }

      // 按时间升序排列
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to get thread messages: $e');
      // 回退方案：从 timeline 过滤线程消息
      return _getThreadMessagesFromTimeline(room, threadRootEventId);
    }
  }

  /// 从 timeline 中过滤线程消息（回退方案）
  ///
  /// 在服务器不支持 /relations API 时使用此方法。
  /// Matrix SDK 6.0 不再提供同步 timeline 访问，
  /// 此方法通过 getTimeline() 异步获取。
  Future<List<MessageEntity>> _getThreadMessagesFromTimeline(
    matrix.Room room,
    String threadRootEventId,
  ) async {
    final messages = <MessageEntity>[];
    try {
      final timeline = await room.getTimeline();
      for (final event in timeline.events) {
        if (event.eventId == threadRootEventId) {
          messages.add(_eventMapper.mapEventToMessage(event, room));
          continue;
        }

        final relatesTo =
            event.content['m.relates_to'] as Map<String, dynamic>?;
        if (relatesTo?['rel_type'] == 'm.thread' &&
            relatesTo?['event_id'] == threadRootEventId) {
          messages.add(_eventMapper.mapEventToMessage(event, room));
        }
      }
    } catch (e) {
      debugLog('MatrixMessageDataSource: Fallback thread fetch failed: $e');
    }
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  /// 监听线程消息更新
  Stream<List<MessageEntity>> watchThreadMessages(
    String roomId,
    String threadRootEventId,
  ) async* {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      return;
    }

    yield await getThreadMessages(roomId, threadRootEventId);

    await for (final sync in room.client.onSync.stream) {
      final roomUpdated =
          sync.rooms?.join?.containsKey(roomId) == true ||
          sync.rooms?.leave?.containsKey(roomId) == true;
      if (!roomUpdated) {
        continue;
      }
      yield await getThreadMessages(roomId, threadRootEventId);
    }
  }

  /// 获取房间内所有线程根消息
  Future<List<MessageEntity>> getRoomThreadRoots(String roomId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return [];

    try {
      // 使用 Matrix /threads API
      final response = await _client!.request(
        matrix.RequestType.GET,
        '/client/v1/rooms/${Uri.encodeComponent(roomId)}/threads',
        query: {'limit': '50'},
      );

      final chunk = response['chunk'] as List<dynamic>? ?? [];
      final messages = <MessageEntity>[];

      for (final eventJson in chunk) {
        try {
          final event = matrix.Event.fromJson(
            eventJson as Map<String, dynamic>,
            room,
          );
          messages.add(_eventMapper.mapEventToMessage(event, room));
        } catch (e) {
          debugLog('ThreadRoots: Failed to parse event: $e');
        }
      }

      return messages;
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to get thread roots: $e');
      return [];
    }
  }
}
