import 'dart:typed_data';
import 'dart:async';

import 'package:matrix/matrix.dart' as matrix;

import '../../../core/utils/matrix_utils.dart';
import '../../../domain/entities/moment_entity.dart';
import 'matrix_client_manager.dart';
import '../../../core/utils/debug_log.dart';

/// Matrix 动态数据源
///
/// 使用 Matrix 协议实现朋友圈功能
/// 动态存储在用户的个人状态房间中，使用自定义事件类型
class MatrixMomentDataSource {
  final MatrixClientManager _clientManager;

  /// 动态事件类型
  static const String momentEventType = 'n42.moment';

  /// 动态点赞事件类型
  static const String momentLikeEventType = 'n42.moment.like';

  /// 动态评论事件类型
  static const String momentCommentEventType = 'n42.moment.comment';

  /// 动态房间标签
  static const String momentRoomTag = 'n42.moments';

  /// 缓存的动态列表
  final List<MomentEntity> _cachedMoments = [];

  /// momentId → roomId 索引（加速 like/unlike/comment/delete 查找）
  final Map<String, String> _momentRoomIndex = {};

  /// momentId → eventId 索引
  final Map<String, String> _momentEventIndex = {};

  MatrixMomentDataSource(this._clientManager);

  matrix.Client? get _client => _clientManager.client;

  String? get _currentUserId => _client?.userID;

  /// 公开当前用户ID（供 Repository 使用）
  String? get currentUserId => _currentUserId;

  /// 缓存的动态房间引用
  matrix.Room? _cachedMomentRoom;

  /// Moment 房间邀请原因标识
  static const String momentInviteReason = 'n42_moments';

  /// 获取或创建用户的动态房间
  Future<matrix.Room?> _getOrCreateMomentRoom() async {
    if (_client == null) {
      debugLog('MatrixMomentDataSource: Client is null');
      return null;
    }

    // 先检查缓存
    if (_cachedMomentRoom != null) {
      return _cachedMomentRoom;
    }

    debugLog(
      'MatrixMomentDataSource: Looking for moment room, '
      'total rooms: ${_client!.rooms.length}',
    );

    // 查找现有的动态房间
    for (final room in _client!.rooms) {
      final tags = room.tags;
      if (tags.containsKey(momentRoomTag)) {
        debugLog(
          'MatrixMomentDataSource: Found existing moment room: ${room.id}',
        );
        _cachedMomentRoom = room;
        return room;
      }
    }

    // 如果房间列表为空，可能同步尚未完成，等待同步
    if (_client!.rooms.isEmpty) {
      debugLog('MatrixMomentDataSource: No rooms found, waiting for sync...');
      try {
        await _client!.onSync.stream.first.timeout(const Duration(seconds: 15));
        debugLog(
          'MatrixMomentDataSource: Sync completed, '
          'rooms: ${_client!.rooms.length}',
        );

        // 同步后再次查找
        for (final room in _client!.rooms) {
          final tags = room.tags;
          if (tags.containsKey(momentRoomTag)) {
            debugLog(
              'MatrixMomentDataSource: Found moment room after sync: ${room.id}',
            );
            _cachedMomentRoom = room;
            return room;
          }
        }
      } on TimeoutException {
        debugLog(
          'MatrixMomentDataSource: Sync timeout, proceeding to create room',
        );
      }
    }

    // 创建新的动态房间
    debugLog('MatrixMomentDataSource: Creating new moment room...');
    try {
      final roomId = await _client!.createRoom(
        name: 'My Moments',
        visibility: matrix.Visibility.private,
        preset: matrix.CreateRoomPreset.privateChat,
        powerLevelContentOverride: {
          'events': {
            // 只有房主（power level 50+）才能发布动态
            momentEventType: 50,
            // 所有成员（power level 0+）可以点赞和评论
            momentLikeEventType: 0,
            momentCommentEventType: 0,
          },
          'events_default': 0,
          'state_default': 50,
          'invite': 50,
          'redact': 50,
        },
      );

      debugLog('MatrixMomentDataSource: Room created with id: $roomId');

      // 等待房间出现在本地存储中
      matrix.Room? room = _client!.getRoomById(roomId);

      if (room == null) {
        debugLog(
          'MatrixMomentDataSource: Room not in local store yet, waiting...',
        );
        // 等待同步将房间带入本地
        for (var i = 0; i < 10; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          room = _client!.getRoomById(roomId);
          if (room != null) break;
        }
      }

      if (room == null) {
        debugLog(
          'MatrixMomentDataSource: Room still null after waiting, '
          'trying sync...',
        );
        try {
          await _client!.onSync.stream.first.timeout(
            const Duration(seconds: 10),
          );
          room = _client!.getRoomById(roomId);
        } on TimeoutException {
          debugLog('MatrixMomentDataSource: Sync timeout after room creation');
        }
      }

      // 添加标签
      if (room != null) {
        await room.addTag(momentRoomTag);
        _cachedMomentRoom = room;
        debugLog('MatrixMomentDataSource: Moment room ready: ${room.id}');
      } else {
        debugLog('MatrixMomentDataSource: Failed to get room after creation');
      }

      return room;
    } catch (e) {
      debugLog('MatrixMomentDataSource: Error creating moment room: $e');
      return null;
    }
  }

  /// 获取好友的动态房间列表
  Future<List<matrix.Room>> _getFriendMomentRooms() async {
    if (_client == null) return [];

    final rooms = <matrix.Room>[];

    // 获取所有已加入的动态房间
    for (final room in _client!.rooms) {
      if (room.membership != matrix.Membership.join) continue;

      final tags = room.tags;
      if (tags.containsKey(momentRoomTag)) {
        rooms.add(room);
      }
    }

    return rooms;
  }

  /// 发布动态
  Future<MomentEntity> postMoment({
    String? content,
    List<MomentMediaData>? media,
    MomentLocation? location,
    MomentVisibility visibility = MomentVisibility.public,
    List<String> visibilityUserIds = const [],
  }) async {
    final room = await _getOrCreateMomentRoom();
    if (room == null) {
      final isLoggedIn = _client?.isLogged() ?? false;
      final roomCount = _client?.rooms.length ?? 0;
      throw Exception(
        'Failed to get moment room '
        '(logged_in=$isLoggedIn, rooms=$roomCount)',
      );
    }

    final momentId = 'moment_${DateTime.now().millisecondsSinceEpoch}';

    // 上传媒体文件
    final uploadedMedia = <Map<String, dynamic>>[];
    if (media != null) {
      for (final m in media) {
        // 确保视频有正确的 mimeType
        String? contentType = m.mimeType;
        if (m.isVideo && (contentType == null || contentType.isEmpty)) {
          final lower = m.filename.toLowerCase();
          if (lower.endsWith('.mov')) {
            contentType = 'video/quicktime';
          } else {
            contentType = 'video/mp4';
          }
        } else if (!m.isVideo && (contentType == null || contentType.isEmpty)) {
          contentType = 'image/jpeg';
        }

        debugLog(
          'MatrixMomentDataSource: Uploading media: '
          '${m.filename}, type: $contentType, '
          'size: ${m.bytes.length}, isVideo: ${m.isVideo}',
        );

        final uri = await _client!.uploadContent(
          m.bytes,
          filename: m.filename,
          contentType: contentType,
        );

        // 视频单独上传缩略图（Matrix thumbnail API 不支持视频缩略图）
        String? thumbnailMxcUrl;
        if (m.isVideo && m.thumbnailBytes != null) {
          try {
            final thumbUri = await _client!.uploadContent(
              m.thumbnailBytes!,
              filename: '${m.filename}_thumb.jpg',
              contentType: 'image/jpeg',
            );
            thumbnailMxcUrl = thumbUri.toString();
            debugLog(
              'MatrixMomentDataSource: Video thumbnail uploaded: $thumbnailMxcUrl',
            );
          } catch (e) {
            debugLog(
              'MatrixMomentDataSource: Failed to upload video thumbnail: $e',
            );
          }
        }

        uploadedMedia.add({
          'url': uri.toString(),
          'type': m.isVideo ? 'video' : 'image',
          'width': m.width,
          'height': m.height,
          'duration': m.duration,
          'mimeType': m.mimeType,
          'size': m.bytes.length,
          'thumbnail_url': thumbnailMxcUrl,
        });
      }
    }

    // 发送动态事件
    final eventContent = {
      'moment_id': momentId,
      'content': content,
      'media': uploadedMedia,
      'location': location != null
          ? {
              'latitude': location.latitude,
              'longitude': location.longitude,
              'name': location.name,
              'address': location.address,
            }
          : null,
      'visibility': visibility.name,
      'visibility_user_ids': visibilityUserIds,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final now = DateTime.now();
    final sentEventId = await room.sendEvent(eventContent, type: momentEventType);

    // Update index immediately so subsequent operations can find it
    _momentRoomIndex[momentId] = room.id;
    if (sentEventId != null) {
      _momentEventIndex[momentId] = sentEventId;
    }

    // Build entity directly from known data — local cache needs /sync to
    // reflect the new event, so getMomentById would return null immediately.
    final userId = _currentUserId!;
    final user = room.unsafeGetUserFromMemoryOrFallback(userId);
    final mediaEntities = uploadedMedia.map((m) {
      final mxcUrl = m['url'] as String;
      final thumbMxcUrl = m['thumbnail_url'] as String?;
      return MomentMedia(
        url: mxcUrl,
        httpUrl: _getHttpUrlFromMxc(mxcUrl),
        thumbnailUrl: thumbMxcUrl != null ? _getHttpUrlFromMxc(thumbMxcUrl) : null,
        type: m['type'] == 'video' ? MomentMediaType.video : MomentMediaType.image,
        width: m['width'] as int?,
        height: m['height'] as int?,
        duration: m['duration'] as int?,
        mimeType: m['mimeType'] as String?,
        size: m['size'] as int?,
      );
    }).toList();

    final entity = MomentEntity(
      id: momentId,
      userId: userId,
      userName: user.displayName ?? userId,
      userAvatarUrl: user.avatarUrl?.toString(),
      content: content,
      media: mediaEntities,
      location: location,
      timestamp: now,
      visibility: visibility,
      visibilityUserIds: visibilityUserIds,
      isFromMe: true,
    );

    _cachedMoments.insert(0, entity);

    return entity;
  }

  /// 获取动态列表
  Future<List<MomentEntity>> getMoments({
    int limit = 20,
    String? beforeId,
  }) async {
    final rooms = await _getFriendMomentRooms();
    final moments = <MomentEntity>[];

    // Only clear indices on full (non-paginated) load to avoid
    // destroying index entries from previous pages during pagination
    if (beforeId == null) {
      _momentRoomIndex.clear();
      _momentEventIndex.clear();
    }

    for (final room in rooms) {
      try {
        final timeline = await room.getTimeline();

        for (final event in timeline.events) {
          if (event.type != momentEventType) continue;

          final momentId = event.content['moment_id'] as String?;
          if (momentId != null) {
            _momentRoomIndex[momentId] = room.id;
            _momentEventIndex[momentId] = event.eventId;
          }

          final moment = _parseEventToMoment(event, room);
          if (moment != null && !moment.isDeleted) {
            moments.add(moment);
          }
        }
      } catch (e) {
        continue;
      }
    }

    // 按时间排序
    moments.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // 分页
    int startIndex = 0;
    if (beforeId != null) {
      startIndex = moments.indexWhere((m) => m.id == beforeId) + 1;
    }

    _cachedMoments.clear();
    _cachedMoments.addAll(moments);

    return moments.skip(startIndex).take(limit).toList();
  }

  /// 获取用户的动态（直接查询该用户的 moment 房间）
  Future<List<MomentEntity>> getUserMoments(
    String userId, {
    int limit = 20,
    String? beforeId,
  }) async {
    // Optimize: if requesting own moments, use own room directly
    if (userId == _currentUserId) {
      final room = await _getOrCreateMomentRoom();
      if (room == null) return [];
      return _getMomentsFromRoom(room, limit: limit, beforeId: beforeId);
    }
    // For other users, filter from cached moments or reload
    if (_cachedMoments.isEmpty) {
      await getMoments(limit: 100);
    }
    final userMoments = _cachedMoments.where((m) => m.userId == userId).toList();
    int startIndex = 0;
    if (beforeId != null) {
      startIndex = userMoments.indexWhere((m) => m.id == beforeId) + 1;
    }
    return userMoments.skip(startIndex).take(limit).toList();
  }

  /// 从单个房间获取 moments
  Future<List<MomentEntity>> _getMomentsFromRoom(
    matrix.Room room, {
    int limit = 20,
    String? beforeId,
  }) async {
    final moments = <MomentEntity>[];
    try {
      final timeline = await room.getTimeline();
      for (final event in timeline.events) {
        if (event.type != momentEventType) continue;
        final moment = _parseEventToMoment(event, room);
        if (moment != null && !moment.isDeleted) {
          moments.add(moment);
        }
      }
    } catch (_) {}
    moments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    int startIndex = 0;
    if (beforeId != null) {
      startIndex = moments.indexWhere((m) => m.id == beforeId) + 1;
    }
    return moments.skip(startIndex).take(limit).toList();
  }

  /// 通过索引查找 moment 所在房间，失败时回退全量查找
  Future<matrix.Room?> _findRoomForMoment(String momentId) async {
    // 1. Try index
    final roomId = _momentRoomIndex[momentId];
    if (roomId != null) {
      final room = _client?.getRoomById(roomId);
      if (room != null) return room;
    }
    // 2. Fallback: rebuild index
    await getMoments(limit: 200);
    final fallbackRoomId = _momentRoomIndex[momentId];
    if (fallbackRoomId != null) return _client?.getRoomById(fallbackRoomId);
    return null;
  }

  /// 获取单条动态
  Future<MomentEntity?> getMomentById(String momentId) async {
    // 先从缓存查找
    final cached = _cachedMoments.where((m) => m.id == momentId).firstOrNull;
    if (cached != null) return cached;

    // 通过索引定位房间
    final room = await _findRoomForMoment(momentId);
    if (room == null) return null;

    try {
      final timeline = await room.getTimeline();
      for (final event in timeline.events) {
        if (event.type != momentEventType) continue;
        if (event.content['moment_id'] == momentId) {
          return _parseEventToMoment(event, room);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 删除动态（使用索引定位 eventId）
  Future<void> deleteMoment(String momentId) async {
    final room = await _getOrCreateMomentRoom();
    if (room == null) return;

    try {
      // Use cached eventId if available
      final eventId = _momentEventIndex[momentId];
      if (eventId != null) {
        await room.redactEvent(eventId);
      } else {
        // Fallback: search in timeline
        final timeline = await room.getTimeline();
        for (final event in timeline.events) {
          if (event.type != momentEventType) continue;
          if (event.content['moment_id'] == momentId) {
            await room.redactEvent(event.eventId);
            break;
          }
        }
      }
      _cachedMoments.removeWhere((m) => m.id == momentId);
      _momentRoomIndex.remove(momentId);
      _momentEventIndex.remove(momentId);
    } catch (e) {
      debugLog('Error: $e');
    }
  }

  /// 点赞动态（使用索引定位房间，避免全量遍历）
  Future<void> likeMoment(String momentId) async {
    final room = await _findRoomForMoment(momentId);
    if (room == null) return;

    final eventId = _momentEventIndex[momentId];
    await room.sendEvent({
      'moment_id': momentId,
      'moment_event_id': eventId ?? '',
      'action': 'like',
      'timestamp': DateTime.now().toIso8601String(),
    }, type: momentLikeEventType);
  }

  /// 取消点赞（只需遍历目标房间的 timeline）
  Future<void> unlikeMoment(String momentId) async {
    final room = await _findRoomForMoment(momentId);
    if (room == null) return;

    try {
      final timeline = await room.getTimeline();
      for (final event in timeline.events) {
        if (event.type != momentLikeEventType) continue;
        if (event.content['moment_id'] == momentId &&
            event.senderId == _currentUserId) {
          await room.redactEvent(event.eventId);
          return;
        }
      }
    } catch (_) {}
  }

  /// 评论动态（使用索引定位房间）
  Future<String> commentMoment({
    required String momentId,
    required String content,
    String? replyToCommentId,
    String? replyToUserId,
  }) async {
    final room = await _findRoomForMoment(momentId);
    if (room == null) throw Exception('Moment not found');

    final eventId = _momentEventIndex[momentId];
    final commentId = 'comment_${DateTime.now().millisecondsSinceEpoch}';

    await room.sendEvent({
      'moment_id': momentId,
      'moment_event_id': eventId ?? '',
      'comment_id': commentId,
      'content': content,
      'reply_to_comment_id': replyToCommentId,
      'reply_to_user_id': replyToUserId,
      'timestamp': DateTime.now().toIso8601String(),
    }, type: momentCommentEventType);

    return commentId;
  }

  /// 删除评论（只遍历目标房间）
  Future<void> deleteComment(String momentId, String commentId) async {
    final room = await _findRoomForMoment(momentId);
    if (room == null) return;

    try {
      final timeline = await room.getTimeline();
      for (final event in timeline.events) {
        if (event.type != momentCommentEventType) continue;
        final content = event.content;
        if (content['moment_id'] == momentId &&
            content['comment_id'] == commentId) {
          await room.redactEvent(event.eventId);
          return;
        }
      }
    } catch (_) {}
  }

  /// 获取动态的点赞列表（使用索引定位房间）
  Future<List<MomentLike>> getMomentLikes(String momentId) async {
    final likes = <MomentLike>[];
    final room = await _findRoomForMoment(momentId);
    if (room == null) return likes;

    try {
      final timeline = await room.getTimeline();
      for (final event in timeline.events) {
        if (event.type != momentLikeEventType) continue;
        final content = event.content;
        if (content['moment_id'] == momentId) {
          final user = room.unsafeGetUserFromMemoryOrFallback(event.senderId);
          likes.add(
            MomentLike(
              userId: event.senderId,
              userName: user.displayName ?? event.senderId,
              userAvatarUrl: user.avatarUrl?.toString(),
              timestamp: event.originServerTs,
            ),
          );
        }
      }
    } catch (_) {}

    return likes;
  }

  /// 获取动态的评论列表（使用索引定位房间）
  Future<List<MomentComment>> getMomentComments(String momentId) async {
    final comments = <MomentComment>[];
    final room = await _findRoomForMoment(momentId);
    if (room == null) return comments;

    try {
      final timeline = await room.getTimeline();
      for (final event in timeline.events) {
        if (event.type != momentCommentEventType) continue;
        final content = event.content;
        if (content['moment_id'] == momentId) {
          final user = room.unsafeGetUserFromMemoryOrFallback(event.senderId);
          String? replyToUserName;
          if (content['reply_to_user_id'] != null) {
            final replyToUser = room.unsafeGetUserFromMemoryOrFallback(
              content['reply_to_user_id'] as String,
            );
            replyToUserName = replyToUser.displayName;
          }
          comments.add(
            MomentComment(
              id: content['comment_id'] as String,
              userId: event.senderId,
              userName: user.displayName ?? event.senderId,
              userAvatarUrl: user.avatarUrl?.toString(),
              content: content['content'] as String,
              timestamp: event.originServerTs,
              replyToCommentId: content['reply_to_comment_id'] as String?,
              replyToUserId: content['reply_to_user_id'] as String?,
              replyToUserName: replyToUserName,
            ),
          );
        }
      }
    } catch (_) {}

    comments.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return comments;
  }

  /// 监听动态更新
  Stream<List<MomentEntity>>? watchMoments() {
    if (_client == null) return null;

    return _client!.onSync.stream.asyncMap((_) async {
      return await getMoments();
    });
  }

  /// 解析事件为动态实体
  MomentEntity? _parseEventToMoment(matrix.Event event, matrix.Room room) {
    try {
      final content = event.content;
      final user = room.unsafeGetUserFromMemoryOrFallback(event.senderId);

      // 解析媒体
      final mediaList = <MomentMedia>[];
      final mediaContent = content['media'];
      if (mediaContent is List) {
        for (final m in mediaContent) {
          if (m is Map) {
            final mxcUrl = m['url'] as String?;
            final isVideo = m['type'] == 'video';
            // 视频缩略图：使用上传时存储的 thumbnail_url（Matrix thumbnail API 不支持视频）
            final storedThumbnailMxcUrl = m['thumbnail_url'] as String?;
            String? resolvedThumbnailUrl;
            if (isVideo && storedThumbnailMxcUrl != null) {
              resolvedThumbnailUrl = _getHttpUrlFromMxc(storedThumbnailMxcUrl);
            }

            mediaList.add(
              MomentMedia(
                url: mxcUrl ?? '',
                httpUrl: mxcUrl != null ? _getHttpUrlFromMxc(mxcUrl) : null,
                thumbnailUrl: resolvedThumbnailUrl,
                type: isVideo ? MomentMediaType.video : MomentMediaType.image,
                width: m['width'] as int?,
                height: m['height'] as int?,
                duration: m['duration'] as int?,
                mimeType: m['mimeType'] as String?,
                size: m['size'] as int?,
              ),
            );
          }
        }
      }

      // 解析位置
      MomentLocation? location;
      final locationContent = content['location'];
      if (locationContent is Map) {
        location = MomentLocation(
          latitude: (locationContent['latitude'] as num).toDouble(),
          longitude: (locationContent['longitude'] as num).toDouble(),
          name: locationContent['name'] as String?,
          address: locationContent['address'] as String?,
        );
      }

      // 解析可见性
      MomentVisibility visibility = MomentVisibility.public;
      final visibilityStr = content['visibility'] as String?;
      if (visibilityStr != null) {
        visibility = MomentVisibility.values.firstWhere(
          (v) => v.name == visibilityStr,
          orElse: () => MomentVisibility.public,
        );
      }

      return MomentEntity(
        id: content['moment_id'] as String? ?? event.eventId,
        userId: event.senderId,
        userName: user.displayName ?? event.senderId,
        userAvatarUrl: user.avatarUrl?.toString(),
        content: content['content'] as String?,
        media: mediaList,
        location: location,
        timestamp: event.originServerTs,
        visibility: visibility,
        visibilityUserIds:
            (content['visibility_user_ids'] as List?)?.cast<String>() ?? [],
        isDeleted: event.redacted,
        isFromMe: event.senderId == _currentUserId,
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取 HTTP URL
  String? _getHttpUrlFromMxc(String mxcUrl) {
    return MatrixUtils.getMediaDownloadUrl(mxcUrl, client: _client);
  }

  /// 上传文件
  Future<String> uploadMedia(
    Uint8List bytes,
    String filename,
    String? mimeType,
  ) async {
    if (_client == null) throw Exception('Client not initialized');

    final uri = await _client!.uploadContent(
      bytes,
      filename: filename,
      contentType: mimeType,
    );
    return uri.toString();
  }

  // ============================================
  // 好友可见性：邀请与自动加入
  // ============================================

  /// 邀请好友加入我的 Moment 房间
  ///
  /// 在好友关系建立时调用，使好友可以看到我的朋友圈
  Future<void> inviteFriendToMomentRoom(String userId) async {
    if (_client == null) return;

    final room = await _getOrCreateMomentRoom();
    if (room == null) {
      debugLog(
        'MatrixMomentDataSource: Cannot invite $userId - moment room is null',
      );
      return;
    }

    // 检查用户是否已经在房间中
    try {
      final members = room.getParticipants();
      final alreadyMember = members.any(
        (m) => m.id == userId && m.membership == matrix.Membership.join,
      );
      final alreadyInvited = members.any(
        (m) => m.id == userId && m.membership == matrix.Membership.invite,
      );

      if (alreadyMember || alreadyInvited) {
        debugLog('MatrixMomentDataSource: $userId already in moment room');
        return;
      }
    } catch (e) {
      // getParticipants 可能失败，继续尝试邀请
      debugLog('Error: $e');
    }

    try {
      debugLog(
        'MatrixMomentDataSource: Inviting $userId to moment room ${room.id}',
      );
      await _client!.inviteUser(room.id, userId, reason: momentInviteReason);
      debugLog('MatrixMomentDataSource: Successfully invited $userId');
    } catch (e) {
      debugLog('MatrixMomentDataSource: Failed to invite $userId: $e');
    }
  }

  /// 处理 Moment 房间邀请
  ///
  /// 在同步时调用，自动加入被标记为 Moment 的房间邀请
  /// 并进行回邀（确保双向可见）
  Future<void> processMomentInvites() async {
    if (_client == null) return;

    for (final room in _client!.rooms) {
      if (room.membership != matrix.Membership.invite) continue;

      // 检查是否是 Moment 房间邀请
      if (!_isMomentRoomInvite(room)) continue;

      debugLog(
        'MatrixMomentDataSource: Auto-joining moment room invite: ${room.id}',
      );

      try {
        // 自动加入
        await room.join();
        debugLog('MatrixMomentDataSource: Joined moment room: ${room.id}');

        // 添加本地标签以标识这是好友的 Moment 房间
        await room.addTag(momentRoomTag);

        // 获取房间创建者（即该 Moment 房间的拥有者）
        final creatorId = _getRoomCreatorId(room);
        if (creatorId != null && creatorId != _client!.userID) {
          debugLog('MatrixMomentDataSource: Reciprocal invite for $creatorId');
          // 回邀：邀请对方加入我的 Moment 房间
          await inviteFriendToMomentRoom(creatorId);
        }
      } catch (e) {
        debugLog('MatrixMomentDataSource: Failed to auto-join moment room: $e');
      }
    }
  }

  /// 判断一个邀请是否是 Moment 房间邀请
  bool _isMomentRoomInvite(matrix.Room room) {
    // 方法 1: 检查邀请事件的 reason 字段
    try {
      final myUserId = _client?.userID;
      if (myUserId != null) {
        final memberEvent = room.getState(
          matrix.EventTypes.RoomMember,
          myUserId,
        );
        if (memberEvent != null) {
          final reason = memberEvent.content['reason'] as String?;
          if (reason == momentInviteReason) {
            return true;
          }
        }
      }
    } catch (e) {
      // 忽略错误
      debugLog('Error: $e');
    }

    // 方法 2: 检查房间名称（降级方案）
    try {
      final name = room.name;
      if (name == 'My Moments') {
        return true;
      }
    } catch (e) {
      // 忽略错误
      debugLog('Error: $e');
    }

    return false;
  }

  /// 获取房间创建者 ID
  String? _getRoomCreatorId(matrix.Room room) {
    try {
      final createEvent = room.getState(matrix.EventTypes.RoomCreate);
      if (createEvent != null) {
        return createEvent.senderId;
      }
    } catch (e) {
      // 忽略错误
      debugLog('Error: $e');
    }

    // 降级：尝试从成员中找到不是自己的用户
    try {
      final members = room.getParticipants();
      for (final member in members) {
        if (member.id != _client?.userID && member.powerLevel >= 50) {
          return member.id;
        }
      }
    } catch (e) {
      // 忽略错误
      debugLog('Error: $e');
    }

    return null;
  }

  /// 为所有现有好友发送 Moment 房间邀请
  ///
  /// 用于一次性迁移：对已有好友发送邀请
  Future<void> inviteAllFriendsToMomentRoom(List<String> friendUserIds) async {
    for (final userId in friendUserIds) {
      await inviteFriendToMomentRoom(userId);
    }
  }
}

/// 动态媒体数据
class MomentMediaData {
  final Uint8List bytes;
  final String filename;
  final String? mimeType;
  final int? width;
  final int? height;
  final int? duration;

  /// 视频缩略图字节（本地提取的帧，上传后存 thumbnail_url）
  final Uint8List? thumbnailBytes;

  const MomentMediaData({
    required this.bytes,
    required this.filename,
    this.mimeType,
    this.width,
    this.height,
    this.duration,
    this.thumbnailBytes,
  });

  bool get isVideo {
    final mime = mimeType?.toLowerCase() ?? '';
    return mime.startsWith('video/') ||
        filename.toLowerCase().endsWith('.mp4') ||
        filename.toLowerCase().endsWith('.mov');
  }
}
