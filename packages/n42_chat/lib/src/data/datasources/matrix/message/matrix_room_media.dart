import 'package:matrix/matrix.dart' as matrix;

import '../../../../domain/entities/group_album_entity.dart';
import '../../../../domain/entities/group_file_entity.dart';
import '../matrix_client_manager.dart';
import 'matrix_event_mapper.dart';
import '../../../../core/utils/debug_log.dart';

/// Matrix 房间媒体和文件处理器
///
/// 封装群文件管理和群相册媒体获取功能
class MatrixRoomMedia {
  final MatrixClientManager _clientManager;
  final MatrixEventMapper _eventMapper;

  MatrixRoomMedia(this._clientManager, this._eventMapper);

  matrix.Client? get _client => _clientManager.client;

  // ============================================
  // 群文件管理
  // ============================================

  /// 获取房间文件列表
  Future<List<GroupFileEntity>> getRoomFiles(
    String roomId, {
    GroupFileType? type,
    int limit = 50,
    String? fromEventId,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return [];

    try {
      final timeline = await room.getTimeline();
      await timeline.requestHistory(historyCount: limit * 3);

      final allEvents = timeline.events;
      final files = <GroupFileEntity>[];
      bool foundFromEvent = fromEventId == null;

      for (final event in allEvents) {
        if (!foundFromEvent) {
          if (event.eventId == fromEventId) {
            foundFromEvent = true;
          }
          continue;
        }

        final msgType = event.messageType;
        if (msgType != matrix.MessageTypes.File &&
            msgType != matrix.MessageTypes.Image &&
            msgType != matrix.MessageTypes.Video &&
            msgType != matrix.MessageTypes.Audio) {
          continue;
        }

        final info = event.content['info'] as Map<String, dynamic>?;
        final mxcUrl = event.content['url'] as String?;
        if (mxcUrl == null || mxcUrl.isEmpty) continue;

        final mimeType = info?['mimetype'] as String? ?? 'application/octet-stream';
        final fileType = GroupFileEntity.typeFromMime(mimeType);

        // 应用类型筛选
        if (type != null && fileType != type) continue;

        final sender = event.senderFromMemoryOrFallback;
        final thumbnailMxc = info?['thumbnail_url'] as String?;

        files.add(GroupFileEntity(
          eventId: event.eventId,
          name: event.body.isNotEmpty ? event.body : 'unnamed',
          url: mxcUrl,
          httpUrl: _eventMapper.convertMxcToHttp(mxcUrl),
          size: info?['size'] as int? ?? 0,
          mimeType: mimeType,
          fileType: fileType,
          senderId: event.senderId,
          senderName: sender.calcDisplayname(),
          sentAt: event.originServerTs,
          roomId: roomId,
          thumbnailUrl: _eventMapper.convertMxcToHttp(thumbnailMxc),
          width: info?['w'] as int?,
          height: info?['h'] as int?,
          duration: info?['duration'] as int?,
        ));

        if (files.length >= limit) break;
      }

      debugLog('MatrixMessageDataSource: Found ${files.length} files in room $roomId');
      return files;
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to get room files: $e');
      return [];
    }
  }

  // ============================================
  // 群相册媒体获取
  // ============================================

  /// 获取房间媒体文件列表
  ///
  /// 从 timeline 中提取 m.image、m.video 类型的消息事件
  Future<List<AlbumMediaEntity>> getRoomMedia(
    String roomId, {
    AlbumFilter? filter,
    int limit = 50,
    String? beforeEventId,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return [];

    try {
      final timeline = await room.getTimeline();

      // 请求足够的历史消息以获取媒体
      await timeline.requestHistory(historyCount: limit * 3);

      // 过滤出媒体事件
      final allEvents = timeline.events;
      final mediaEntities = <AlbumMediaEntity>[];
      bool foundBeforeEvent = beforeEventId == null;

      for (final event in allEvents) {
        // 处理分页：跳过 beforeEventId 之前（时间更新）的事件
        if (!foundBeforeEvent) {
          if (event.eventId == beforeEventId) {
            foundBeforeEvent = true;
          }
          continue;
        }

        // 只处理媒体消息
        final msgType = event.messageType;
        if (msgType != matrix.MessageTypes.Image &&
            msgType != matrix.MessageTypes.Video) {
          continue;
        }

        final entity = _eventToAlbumMedia(event, room);
        if (entity == null) continue;

        // 应用筛选器
        if (filter != null && !filter.matches(entity)) continue;

        mediaEntities.add(entity);

        if (mediaEntities.length >= limit) break;
      }

      debugLog('MatrixMessageDataSource: Found ${mediaEntities.length} media items in room $roomId');
      return mediaEntities;
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to get room media: $e');
      return [];
    }
  }

  /// 将 Matrix Event 转换为 AlbumMediaEntity
  AlbumMediaEntity? _eventToAlbumMedia(matrix.Event event, matrix.Room room) {
    try {
      final info = event.content['info'] as Map<String, dynamic>?;
      final mxcUrl = event.content['url'] as String?;
      if (mxcUrl == null || mxcUrl.isEmpty) return null;

      final thumbnailMxc = info?['thumbnail_url'] as String?;
      final mimeType = info?['mimetype'] as String? ?? '';
      final sender = event.senderFromMemoryOrFallback;

      // 确定媒体类型
      final bool isVideo = event.messageType == matrix.MessageTypes.Video ||
          mimeType.startsWith('video/');
      final mediaType = isVideo ? AlbumMediaType.video : AlbumMediaType.image;

      // 提取视频时长
      final int? duration = isVideo ? (info?['duration'] as int?) : null;

      return AlbumMediaEntity(
        eventId: event.eventId,
        roomId: room.id,
        url: mxcUrl,
        httpUrl: _eventMapper.convertMxcToHttp(mxcUrl),
        thumbnailUrl: _eventMapper.convertMxcToHttp(
          thumbnailMxc,
          width: 400,
          height: 400,
        ),
        type: mediaType,
        mimeType: mimeType.isNotEmpty ? mimeType : 'application/octet-stream',
        size: info?['size'] as int? ?? 0,
        width: info?['w'] as int?,
        height: info?['h'] as int?,
        duration: duration,
        senderId: event.senderId,
        senderName: sender.calcDisplayname(),
        senderAvatarUrl: _eventMapper.buildHttpUrl(
          sender.avatarUrl?.toString(),
          width: 80,
          height: 80,
          method: 'crop',
        ),
        sentAt: event.originServerTs,
        caption: event.body.isNotEmpty &&
                event.body != event.content['filename']
            ? event.body
            : null,
      );
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to convert event to album media: $e');
      return null;
    }
  }
}
