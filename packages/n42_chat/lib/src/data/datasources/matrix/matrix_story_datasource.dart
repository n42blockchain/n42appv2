import 'dart:async';

import 'package:matrix/matrix.dart' as matrix;

import '../../../core/utils/matrix_utils.dart';
import 'matrix_client_manager.dart';
import '../../../core/utils/debug_log.dart';

/// Matrix Story 数据源
///
/// 使用 Matrix 协议实现 24 小时状态动态功能
/// Story 存储在用户的 moments 房间中，使用自定义事件类型
class MatrixStoryDataSource {
  final MatrixClientManager _clientManager;

  /// Story 事件类型
  static const String storyEventType = 'n42.story';

  /// Story 查看事件类型
  static const String storyViewEventType = 'n42.story.view';

  /// Moments 房间标签（复用 moments 房间）
  static const String momentRoomTag = 'n42.moments';

  /// Story 有效期（24小时）
  static const Duration storyExpiry = Duration(hours: 24);

  /// 缓存的 Story 房间
  matrix.Room? _storyRoom;

  /// Story 更新流控制器
  final StreamController<List<Map<String, dynamic>>> _storyStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  /// 同步订阅
  StreamSubscription<dynamic>? _syncSubscription;

  MatrixStoryDataSource(this._clientManager);

  matrix.Client? get _client => _clientManager.client;

  String? get _currentUserId => _client?.userID;

  /// 初始化，查找或创建 Story 房间
  Future<void> initialize() async {
    _storyRoom = await _getOrCreateStoryRoom();

    // 订阅同步事件以实时更新 Story
    await _syncSubscription?.cancel();
    _syncSubscription = _client?.onSync.stream.listen((_) async {
      final stories = await getStories();
      _storyStreamController.add(stories);
    });
  }

  /// 获取或创建用户的 Story 房间（复用 moments 房间）
  Future<matrix.Room?> _getOrCreateStoryRoom() async {
    if (_client == null) return null;

    // 查找现有的 moments 房间
    for (final room in _client!.rooms) {
      final tags = room.tags;
      if (tags.containsKey(momentRoomTag)) {
        return room;
      }
    }

    // 创建新的 moments 房间
    try {
      final roomId = await _client!.createRoom(
        name: 'My Moments',
        visibility: matrix.Visibility.private,
        preset: matrix.CreateRoomPreset.privateChat,
      );

      // 添加标签
      final room = _client!.getRoomById(roomId);
      if (room != null) {
        await room.addTag(momentRoomTag);
      }

      return room;
    } catch (e) {
      return null;
    }
  }

  /// 获取好友的 Story 房间列表
  Future<List<matrix.Room>> _getFriendStoryRooms() async {
    if (_client == null) return [];

    final rooms = <matrix.Room>[];

    // 获取所有已加入的 moments 房间
    for (final room in _client!.rooms) {
      if (room.membership != matrix.Membership.join) continue;

      final tags = room.tags;
      if (tags.containsKey(momentRoomTag)) {
        rooms.add(room);
      }
    }

    return rooms;
  }

  /// 监听 Story 更新
  Stream<List<Map<String, dynamic>>> watchStories() {
    // 初始获取一次
    getStories().then((stories) {
      if (!_storyStreamController.isClosed) {
        _storyStreamController.add(stories);
      }
    });

    return _storyStreamController.stream;
  }

  /// 获取所有未过期的 Stories
  Future<List<Map<String, dynamic>>> getStories() async {
    final rooms = await _getFriendStoryRooms();
    final stories = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (final room in rooms) {
      try {
        final timeline = await room.getTimeline();

        for (final event in timeline.events) {
          if (event.type != storyEventType) continue;
          if (event.redacted) continue;

          final content = event.content;
          final expiresAtStr = content['expires_at'] as String?;

          // 过滤已过期的 Story
          if (expiresAtStr != null) {
            final expiresAt = DateTime.tryParse(expiresAtStr);
            if (expiresAt != null && now.isAfter(expiresAt)) {
              continue;
            }
          }

          final storyData = _parseEventToStoryData(event, room);
          if (storyData != null) {
            stories.add(storyData);
          }
        }
      } catch (e) {
        // 如果获取时间线失败，继续处理下一个房间
        continue;
      }
    }

    // 按创建时间降序排序（最新的在前）
    stories.sort((a, b) {
      final aTime = DateTime.tryParse(a['created_at'] as String? ?? '');
      final bTime = DateTime.tryParse(b['created_at'] as String? ?? '');
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });

    return stories;
  }

  /// 发布 Story
  Future<String?> postStory({
    String? content,
    List<Map<String, dynamic>>? media,
    int? backgroundColor,
    int? textColor,
    String? musicUrl,
    String? musicTitle,
    String? musicArtist,
    int? musicStartAt,
  }) async {
    final room = await _getOrCreateStoryRoom();
    if (room == null) return null;

    final storyId = 'story_${DateTime.now().millisecondsSinceEpoch}';
    final createdAt = DateTime.now();
    final expiresAt = createdAt.add(storyExpiry);

    // 发送 Story 事件
    final eventContent = <String, dynamic>{
      'story_id': storyId,
      'content': content,
      'media': media ?? [],
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };

    // 可选字段
    if (backgroundColor != null) {
      eventContent['background_color'] = backgroundColor;
    }
    if (textColor != null) {
      eventContent['text_color'] = textColor;
    }

    // 音乐元数据
    if (musicUrl != null) {
      eventContent['music_url'] = musicUrl;
    }
    if (musicTitle != null) {
      eventContent['music_title'] = musicTitle;
    }
    if (musicArtist != null) {
      eventContent['music_artist'] = musicArtist;
    }
    if (musicStartAt != null) {
      eventContent['music_start_at'] = musicStartAt;
    }

    try {
      final eventId = await room.sendEvent(eventContent, type: storyEventType);
      return eventId;
    } catch (e) {
      return null;
    }
  }

  /// 删除 Story
  Future<void> deleteStory(String eventId) async {
    final room = _storyRoom ?? await _getOrCreateStoryRoom();
    if (room == null) return;

    try {
      await room.redactEvent(eventId);
    } catch (e) {
      // 忽略错误
      debugLog('Error: $e');
    }
  }

  /// 记录 Story 查看
  Future<void> recordStoryView(String storyId) async {
    final rooms = await _getFriendStoryRooms();

    for (final room in rooms) {
      try {
        final timeline = await room.getTimeline();

        for (final event in timeline.events) {
          if (event.type != storyEventType) continue;

          final content = event.content;
          if (content['story_id'] == storyId) {
            // 检查是否已经查看过
            final existingViews = await _getViewEventsForStory(
              room,
              event.eventId,
            );
            final alreadyViewed = existingViews.any(
              (v) => v['user_id'] == _currentUserId,
            );

            if (!alreadyViewed) {
              // 发送查看事件
              await room.sendEvent({
                'story_id': storyId,
                'story_event_id': event.eventId,
                'viewed_at': DateTime.now().toIso8601String(),
              }, type: storyViewEventType);
            }
            return;
          }
        }
      } catch (e) {
        continue;
      }
    }
  }

  /// 获取 Story 的查看者列表
  Future<List<Map<String, dynamic>>> getStoryViewers(String storyId) async {
    final rooms = await _getFriendStoryRooms();
    final viewers = <Map<String, dynamic>>[];

    for (final room in rooms) {
      try {
        final timeline = await room.getTimeline();

        // 先找到对应的 Story 事件
        String? storyEventId;
        for (final event in timeline.events) {
          if (event.type != storyEventType) continue;
          final content = event.content;
          if (content['story_id'] == storyId) {
            storyEventId = event.eventId;
            break;
          }
        }

        if (storyEventId == null) continue;

        // 获取所有查看事件
        final viewEvents = await _getViewEventsForStory(room, storyEventId);
        viewers.addAll(viewEvents);
      } catch (e) {
        continue;
      }
    }

    // 按查看时间排序
    viewers.sort((a, b) {
      final aTime = DateTime.tryParse(a['viewed_at'] as String? ?? '');
      final bTime = DateTime.tryParse(b['viewed_at'] as String? ?? '');
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });

    return viewers;
  }

  /// 获取指定 Story 的查看事件
  Future<List<Map<String, dynamic>>> _getViewEventsForStory(
    matrix.Room room,
    String storyEventId,
  ) async {
    final viewers = <Map<String, dynamic>>[];

    try {
      final timeline = await room.getTimeline();

      for (final event in timeline.events) {
        if (event.type != storyViewEventType) continue;
        if (event.redacted) continue;

        final content = event.content;
        if (content['story_event_id'] == storyEventId) {
          final user = room.unsafeGetUserFromMemoryOrFallback(event.senderId);
          viewers.add({
            'user_id': event.senderId,
            'user_name': user.displayName ?? event.senderId,
            'avatar_url': user.avatarUrl?.toString(),
            'viewed_at': content['viewed_at'] as String?,
          });
        }
      }
    } catch (e) {
      // 忽略错误
      debugLog('Error: $e');
    }

    return viewers;
  }

  /// 解析事件为 Story 数据
  Map<String, dynamic>? _parseEventToStoryData(
    matrix.Event event,
    matrix.Room room,
  ) {
    try {
      final content = event.content;
      final user = room.unsafeGetUserFromMemoryOrFallback(event.senderId);

      // 解析媒体列表
      final mediaList = <Map<String, dynamic>>[];
      final mediaContent = content['media'];
      if (mediaContent is List) {
        for (final m in mediaContent) {
          if (m is Map) {
            final mxcUrl = m['url'] as String?;
            mediaList.add({
              'url': mxcUrl ?? '',
              'http_url': mxcUrl != null ? _getHttpUrlFromMxc(mxcUrl) : null,
              'type': m['type'] as String? ?? 'image',
              'width': m['width'] as int?,
              'height': m['height'] as int?,
              'duration': m['duration'] as int?,
              'mime_type': m['mimeType'] as String?,
              'size': m['size'] as int?,
              'thumbnail_url': m['thumbnailUrl'] as String?,
            });
          }
        }
      }

      return {
        'id': content['story_id'] as String? ?? event.eventId,
        'event_id': event.eventId,
        'user_id': event.senderId,
        'user_name': user.displayName ?? event.senderId,
        'user_avatar_url': user.avatarUrl?.toString(),
        'content': content['content'] as String?,
        'media': mediaList,
        'created_at':
            content['created_at'] as String? ??
            event.originServerTs.toIso8601String(),
        'expires_at': content['expires_at'] as String?,
        'background_color': content['background_color'] as int?,
        'text_color': content['text_color'] as int?,
        'music_url': content['music_url'] as String?,
        'music_title': content['music_title'] as String?,
        'music_artist': content['music_artist'] as String?,
        'music_start_at': content['music_start_at'] as int?,
        'is_from_me': event.senderId == _currentUserId,
      };
    } catch (e) {
      return null;
    }
  }

  /// 将 MXC URL 转换为 HTTP URL
  String? _getHttpUrlFromMxc(String mxcUrl) {
    return MatrixUtils.getMediaDownloadUrl(mxcUrl, client: _client);
  }

  /// 释放资源
  void dispose() {
    _syncSubscription?.cancel();
    _storyStreamController.close();
  }
}
