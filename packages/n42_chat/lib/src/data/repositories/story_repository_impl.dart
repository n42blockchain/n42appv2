import 'dart:convert';

import '../../domain/entities/story_entity.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/local/preferences_datasource.dart';
import '../datasources/matrix/matrix_story_datasource.dart';
import '../../core/utils/debug_log.dart';

/// Story 仓库实现
///
/// 使用 MatrixStoryDataSource 进行网络操作，
/// 使用 PreferencesDataSource 追踪本地已查看的 Story
class StoryRepositoryImpl implements IStoryRepository {
  final MatrixStoryDataSource _storyDataSource;
  final PreferencesDataSource _storageDataSource;

  /// 本地已查看 Story ID 存储键
  static const String _viewedStoriesKey = 'n42_viewed_stories';

  StoryRepositoryImpl(this._storyDataSource, this._storageDataSource);

  @override
  Stream<List<UserStories>> watchStories() {
    return _storyDataSource.watchStories().asyncMap((storiesData) async {
      final viewedIds = await _getViewedStoryIds();
      return _groupStoriesByUser(storiesData, viewedIds);
    });
  }

  @override
  Future<List<UserStories>> getStories() async {
    final storiesData = await _storyDataSource.getStories();
    final viewedIds = await _getViewedStoryIds();
    return _groupStoriesByUser(storiesData, viewedIds);
  }

  @override
  Future<List<StoryEntity>> getMyStories() async {
    final storiesData = await _storyDataSource.getStories();
    final viewedIds = await _getViewedStoryIds();

    // 过滤当前用户的 Story
    final myStories = storiesData.where((data) {
      return data['is_from_me'] == true;
    }).toList();

    return myStories.map((data) => _mapToStoryEntity(data, viewedIds)).toList();
  }

  @override
  Future<StoryEntity?> postStory({
    String? content,
    List<StoryMediaData>? media,
    int? backgroundColor,
    int? textColor,
  }) async {
    // 验证至少有内容或媒体
    if ((content == null || content.isEmpty) &&
        (media == null || media.isEmpty)) {
      return null;
    }

    // 处理媒体上传
    List<Map<String, dynamic>>? mediaData;
    if (media != null && media.isNotEmpty) {
      mediaData = await _uploadMedia(media);
      if (mediaData == null) {
        return null;
      }
    }

    // 发布 Story
    final eventId = await _storyDataSource.postStory(
      content: content,
      media: mediaData,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );

    if (eventId == null) {
      return null;
    }

    // 获取新发布的 Story
    final storiesData = await _storyDataSource.getStories();
    final viewedIds = await _getViewedStoryIds();

    // 查找刚发布的 Story
    final storyData = storiesData.firstWhere(
      (data) => data['event_id'] == eventId,
      orElse: () => <String, dynamic>{},
    );

    if (storyData.isEmpty) {
      return null;
    }

    return _mapToStoryEntity(storyData, viewedIds);
  }

  @override
  Future<void> deleteStory(String storyId) async {
    // storyId 可能是 story_id 或 event_id
    // 需要先找到对应的 event_id
    final storiesData = await _storyDataSource.getStories();
    final storyData = storiesData.firstWhere(
      (data) => data['id'] == storyId || data['event_id'] == storyId,
      orElse: () => <String, dynamic>{},
    );

    if (storyData.isNotEmpty) {
      final eventId = storyData['event_id'] as String?;
      if (eventId != null) {
        await _storyDataSource.deleteStory(eventId);
      }
      return;
    }

    if (storyId.startsWith(r'$')) {
      await _storyDataSource.deleteStory(storyId);
    }
  }

  @override
  Future<void> recordView(String storyId) async {
    // 调用数据源记录查看
    await _storyDataSource.recordStoryView(storyId);

    // 本地也记录已查看
    await _markStoryAsViewed(storyId);
  }

  @override
  Future<List<StoryViewer>> getViewers(String storyId) async {
    final viewersData = await _storyDataSource.getStoryViewers(storyId);

    return viewersData.map((data) {
      return StoryViewer(
        userId: data['user_id'] as String? ?? '',
        userName: data['user_name'] as String? ?? '',
        avatarUrl: data['avatar_url'] as String?,
        viewedAt:
            DateTime.tryParse(data['viewed_at'] as String? ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  // ============================================
  // 私有辅助方法
  // ============================================

  /// 将 Stories 按用户分组
  ///
  /// [storiesData] 原始 Story 数据列表
  /// [viewedIds] 本地已查看的 Story ID 集合
  List<UserStories> _groupStoriesByUser(
    List<Map<String, dynamic>> storiesData,
    Set<String> viewedIds,
  ) {
    // 按 userId 分组
    final Map<String, List<StoryEntity>> groupedStories = {};
    final Map<String, Map<String, dynamic>> userInfo = {};

    for (final data in storiesData) {
      final userId = data['user_id'] as String?;
      if (userId == null) continue;

      final story = _mapToStoryEntity(data, viewedIds);

      if (!groupedStories.containsKey(userId)) {
        groupedStories[userId] = [];
        userInfo[userId] = {
          'user_name': data['user_name'],
          'user_avatar_url': data['user_avatar_url'],
        };
      }
      groupedStories[userId]!.add(story);
    }

    // 转换为 UserStories 列表
    final userStoriesList = <UserStories>[];

    for (final entry in groupedStories.entries) {
      final userId = entry.key;
      final stories = entry.value;
      final info = userInfo[userId]!;

      // 按创建时间降序排序（最新的在前）
      stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final allViewed = stories.every((s) => s.isViewed);
      final lastUpdated = stories.isNotEmpty
          ? stories
                .map((s) => s.createdAt)
                .reduce((a, b) => a.isAfter(b) ? a : b)
          : DateTime.now();

      userStoriesList.add(
        UserStories(
          userId: userId,
          userName: info['user_name'] as String? ?? userId,
          avatarUrl: info['user_avatar_url'] as String?,
          stories: stories,
          allViewed: allViewed,
          lastUpdated: lastUpdated,
        ),
      );
    }

    // 按最后更新时间排序，未读的排在前面
    userStoriesList.sort((a, b) {
      // 未读优先
      if (a.hasUnviewed && !b.hasUnviewed) return -1;
      if (!a.hasUnviewed && b.hasUnviewed) return 1;
      // 然后按最后更新时间降序
      return b.lastUpdated.compareTo(a.lastUpdated);
    });

    return userStoriesList;
  }

  /// 将单个 Map 数据转换为 StoryEntity
  StoryEntity _mapToStoryEntity(
    Map<String, dynamic> data,
    Set<String> viewedIds,
  ) {
    final id = data['id'] as String? ?? '';
    final eventId = data['event_id'] as String? ?? '';

    // 解析媒体列表
    final mediaList = <StoryMedia>[];
    final mediaData = data['media'];
    if (mediaData is List) {
      for (final m in mediaData) {
        if (m is Map<String, dynamic>) {
          mediaList.add(_mapToStoryMedia(m));
        }
      }
    }

    // 解析创建时间和过期时间
    final createdAt =
        DateTime.tryParse(data['created_at'] as String? ?? '') ??
        DateTime.now();
    final expiresAt =
        DateTime.tryParse(data['expires_at'] as String? ?? '') ??
        createdAt.add(const Duration(hours: 24));

    // 判断是否已查看
    final isViewed = viewedIds.contains(id) || viewedIds.contains(eventId);

    return StoryEntity(
      id: id,
      eventId: eventId,
      userId: data['user_id'] as String? ?? '',
      userName: data['user_name'] as String? ?? '',
      userAvatarUrl: data['user_avatar_url'] as String?,
      content: data['content'] as String?,
      media: mediaList,
      createdAt: createdAt,
      expiresAt: expiresAt,
      viewedBy: const [], // 查看者列表需要单独获取
      isViewed: isViewed,
      backgroundColor: data['background_color'] as int?,
      textColor: data['text_color'] as int?,
    );
  }

  /// 将媒体 Map 转换为 StoryMedia
  StoryMedia _mapToStoryMedia(Map<String, dynamic> data) {
    final typeStr = data['type'] as String? ?? 'image';
    final type = typeStr == 'video'
        ? StoryMediaType.video
        : StoryMediaType.image;

    return StoryMedia(
      type: type,
      url: data['url'] as String? ?? '',
      httpUrl: data['http_url'] as String?,
      thumbnailUrl: data['thumbnail_url'] as String?,
      width: data['width'] as int?,
      height: data['height'] as int?,
      duration: data['duration'] as int?,
      mimeType: data['mime_type'] as String?,
      size: data['size'] as int?,
    );
  }

  /// 上传媒体文件
  ///
  /// 返回上传后的媒体数据列表，失败返回 null
  Future<List<Map<String, dynamic>>?> _uploadMedia(
    List<StoryMediaData> mediaList,
  ) async {
    // 注意：MatrixStoryDataSource.postStory 直接接受媒体数据
    // 实际的上传由 Matrix SDK 处理
    // 这里只需要转换格式

    final result = <Map<String, dynamic>>[];

    for (final media in mediaList) {
      result.add({
        'type': media.type.name,
        'bytes': media.bytes,
        'filename': media.filename,
        'mimeType': media.mimeType,
        'width': media.width,
        'height': media.height,
        'duration': media.duration,
        'size': media.size,
      });
    }

    return result;
  }

  /// 获取本地已查看的 Story ID 集合
  Future<Set<String>> _getViewedStoryIds() async {
    try {
      final data = await _storageDataSource.getSetting(_viewedStoriesKey);
      if (data == null) return {};

      final ids = jsonDecode(data) as List<dynamic>;
      return ids.cast<String>().toSet();
    } catch (e) {
      return {};
    }
  }

  /// 将 Story 标记为已查看
  Future<void> _markStoryAsViewed(String storyId) async {
    try {
      final viewedIds = await _getViewedStoryIds();
      viewedIds.add(storyId);

      // 限制存储的已查看 ID 数量（保留最近 500 个）
      final idsList = viewedIds.toList();
      if (idsList.length > 500) {
        idsList.removeRange(0, idsList.length - 500);
      }

      await _storageDataSource.saveSetting(
        _viewedStoriesKey,
        jsonEncode(idsList),
      );
    } catch (e) {
      // 忽略存储错误
      debugLog('Error: $e');
    }
  }
}
