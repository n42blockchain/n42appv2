import 'dart:async';
import 'dart:typed_data';

import '../../domain/entities/moment_entity.dart';
import '../../domain/repositories/moment_repository.dart';
import '../datasources/local/preferences_datasource.dart';
import '../datasources/matrix/matrix_moment_datasource.dart';

/// 动态仓库实现
class MomentRepositoryImpl implements IMomentRepository {
  final MatrixMomentDataSource _momentDataSource;
  final PreferencesDataSource _storageDataSource;

  /// 动态缓存
  final List<MomentEntity> _momentsCache = [];

  /// 未读数量
  int _unreadCount = 0;

  MomentRepositoryImpl(this._momentDataSource, this._storageDataSource);

  @override
  Future<List<MomentEntity>> getMoments({
    int limit = 20,
    String? beforeId,
  }) async {
    final moments = await _momentDataSource.getMoments(
      limit: limit,
      beforeId: beforeId,
    );

    // 填充点赞和评论
    final enrichedMoments = <MomentEntity>[];
    for (final moment in moments) {
      final likes = await _momentDataSource.getMomentLikes(moment.id);
      final comments = await _momentDataSource.getMomentComments(moment.id);

      enrichedMoments.add(
        moment.copyWith(
          likes: likes,
          comments: comments,
          isLikedByMe: likes.any((l) => l.userId == _getCurrentUserId()),
        ),
      );
    }

    // 应用隐私过滤
    final filteredMoments = await _filterMoments(enrichedMoments);

    // 更新缓存
    if (beforeId == null) {
      _momentsCache.clear();
    }
    _momentsCache.addAll(filteredMoments);
    await _updateUnreadCount(_momentsCache);

    return filteredMoments;
  }

  @override
  Stream<List<MomentEntity>> watchMoments() {
    final stream = _momentDataSource.watchMoments();
    if (stream == null) {
      return Stream.value([]);
    }

    return stream.asyncMap((moments) async {
      final enrichedMoments = <MomentEntity>[];
      for (final moment in moments) {
        final likes = await _momentDataSource.getMomentLikes(moment.id);
        final comments = await _momentDataSource.getMomentComments(moment.id);

        enrichedMoments.add(
          moment.copyWith(
            likes: likes,
            comments: comments,
            isLikedByMe: likes.any((l) => l.userId == _getCurrentUserId()),
          ),
        );
      }
      final filteredMoments = await _filterMoments(enrichedMoments);
      await _updateUnreadCount(filteredMoments);
      return filteredMoments;
    });
  }

  @override
  Future<List<MomentEntity>> getUserMoments(
    String userId, {
    int limit = 20,
    String? beforeId,
  }) async {
    final moments = await _momentDataSource.getUserMoments(
      userId,
      limit: limit,
      beforeId: beforeId,
    );

    final enrichedMoments = <MomentEntity>[];
    for (final moment in moments) {
      final likes = await _momentDataSource.getMomentLikes(moment.id);
      final comments = await _momentDataSource.getMomentComments(moment.id);

      enrichedMoments.add(
        moment.copyWith(
          likes: likes,
          comments: comments,
          isLikedByMe: likes.any((l) => l.userId == _getCurrentUserId()),
        ),
      );
    }

    // 应用隐私过滤（查看特定用户朋友圈时也需要检查权限）
    return await _filterMoments(enrichedMoments);
  }

  @override
  Future<MomentEntity?> getMomentById(String momentId) async {
    final moment = await _momentDataSource.getMomentById(momentId);
    if (moment == null) return null;

    final likes = await _momentDataSource.getMomentLikes(momentId);
    final comments = await _momentDataSource.getMomentComments(momentId);

    final enrichedMoment = moment.copyWith(
      likes: likes,
      comments: comments,
      isLikedByMe: likes.any((l) => l.userId == _getCurrentUserId()),
    );

    final visibleMoments = await _filterMoments([enrichedMoment]);
    return visibleMoments.isEmpty ? null : visibleMoments.first;
  }

  @override
  Future<MomentEntity> postTextMoment({
    required String content,
    MomentLocation? location,
    MomentVisibility visibility = MomentVisibility.public,
    List<String> visibilityUserIds = const [],
  }) async {
    final momentId = await _momentDataSource.postMoment(
      content: content,
      location: location,
      visibility: visibility,
      visibilityUserIds: visibilityUserIds,
    );

    final moment = await getMomentById(momentId);
    if (moment == null) {
      throw Exception('Failed to retrieve posted moment');
    }

    return moment;
  }

  @override
  Future<MomentEntity> postImageMoment({
    String? content,
    required List<MomentMediaInput> images,
    MomentLocation? location,
    MomentVisibility visibility = MomentVisibility.public,
    List<String> visibilityUserIds = const [],
  }) async {
    final mediaData = images
        .map(
          (img) => MomentMediaData(
            bytes: img.bytes,
            filename: img.filename,
            mimeType: img.mimeType,
            width: img.width,
            height: img.height,
          ),
        )
        .toList();

    final momentId = await _momentDataSource.postMoment(
      content: content,
      media: mediaData,
      location: location,
      visibility: visibility,
      visibilityUserIds: visibilityUserIds,
    );

    final moment = await getMomentById(momentId);
    if (moment == null) {
      throw Exception('Failed to retrieve posted moment');
    }

    return moment;
  }

  @override
  Future<MomentEntity> postVideoMoment({
    String? content,
    required MomentMediaInput video,
    Uint8List? thumbnailBytes,
    MomentLocation? location,
    MomentVisibility visibility = MomentVisibility.public,
    List<String> visibilityUserIds = const [],
  }) async {
    final mediaData = [
      MomentMediaData(
        bytes: video.bytes,
        filename: video.filename,
        mimeType: video.mimeType,
        width: video.width,
        height: video.height,
        duration: video.duration,
        thumbnailBytes: thumbnailBytes,
      ),
    ];

    final momentId = await _momentDataSource.postMoment(
      content: content,
      media: mediaData,
      location: location,
      visibility: visibility,
      visibilityUserIds: visibilityUserIds,
    );

    final moment = await getMomentById(momentId);
    if (moment == null) {
      throw Exception('Failed to retrieve posted moment');
    }

    return moment;
  }

  @override
  Future<void> deleteMoment(String momentId) async {
    await _momentDataSource.deleteMoment(momentId);
    _momentsCache.removeWhere((m) => m.id == momentId);
  }

  @override
  Future<void> likeMoment(String momentId) async {
    await _momentDataSource.likeMoment(momentId);

    // 更新缓存
    final index = _momentsCache.indexWhere((m) => m.id == momentId);
    if (index >= 0) {
      final moment = _momentsCache[index];
      _momentsCache[index] = moment.copyWith(isLikedByMe: true);
    }
  }

  @override
  Future<void> unlikeMoment(String momentId) async {
    await _momentDataSource.unlikeMoment(momentId);

    // 更新缓存
    final index = _momentsCache.indexWhere((m) => m.id == momentId);
    if (index >= 0) {
      final moment = _momentsCache[index];
      _momentsCache[index] = moment.copyWith(isLikedByMe: false);
    }
  }

  @override
  Future<MomentComment> commentMoment({
    required String momentId,
    required String content,
    String? replyToCommentId,
    String? replyToUserId,
  }) async {
    final commentId = await _momentDataSource.commentMoment(
      momentId: momentId,
      content: content,
      replyToCommentId: replyToCommentId,
      replyToUserId: replyToUserId,
    );

    // 获取最新评论
    final comments = await _momentDataSource.getMomentComments(momentId);
    final comment = comments.firstWhere((c) => c.id == commentId);

    return comment;
  }

  @override
  Future<void> deleteComment(String momentId, String commentId) async {
    await _momentDataSource.deleteComment(momentId, commentId);
  }

  @override
  Future<List<MomentLike>> getMomentLikes(String momentId) async {
    return await _momentDataSource.getMomentLikes(momentId);
  }

  @override
  Future<List<MomentComment>> getMomentComments(String momentId) async {
    return await _momentDataSource.getMomentComments(momentId);
  }

  @override
  Future<void> setMomentVisibilitySettings({
    bool allowStrangers = false,
    int visibleDays = 0,
  }) async {
    await _storageDataSource.saveMomentSettings(
      allowStrangers: allowStrangers,
      visibleDays: visibleDays,
    );
  }

  @override
  Future<Map<String, dynamic>> getMomentVisibilitySettings() async {
    return await _storageDataSource.getMomentSettings() ??
        {'allowStrangers': false, 'visibleDays': 0};
  }

  @override
  Future<void> hideMomentsFromUser(String userId) async {
    final hiddenUsers = await getHiddenMomentUsers();
    if (!hiddenUsers.contains(userId)) {
      hiddenUsers.add(userId);
      await _storageDataSource.saveHiddenMomentUsers(hiddenUsers);
    }
  }

  @override
  Future<void> showMomentsFromUser(String userId) async {
    final hiddenUsers = await getHiddenMomentUsers();
    hiddenUsers.remove(userId);
    await _storageDataSource.saveHiddenMomentUsers(hiddenUsers);
  }

  @override
  Future<List<String>> getHiddenMomentUsers() async {
    return await _storageDataSource.getHiddenMomentUsers() ?? [];
  }

  @override
  Future<void> hideMyMomentsFromUser(String userId) async {
    final blockedUsers = await getBlockedMomentUsers();
    if (!blockedUsers.contains(userId)) {
      blockedUsers.add(userId);
      await _storageDataSource.saveBlockedMomentUsers(blockedUsers);
    }
  }

  @override
  Future<void> showMyMomentsToUser(String userId) async {
    final blockedUsers = await getBlockedMomentUsers();
    blockedUsers.remove(userId);
    await _storageDataSource.saveBlockedMomentUsers(blockedUsers);
  }

  @override
  Future<List<String>> getBlockedMomentUsers() async {
    return await _storageDataSource.getBlockedMomentUsers() ?? [];
  }

  @override
  Future<int> getUnreadMomentCount() async {
    return _unreadCount;
  }

  @override
  Future<void> markMomentsAsRead() async {
    _unreadCount = 0;
    await _storageDataSource.saveMomentLastReadTime(DateTime.now());
  }

  @override
  Future<void> refreshMoments() async {
    _momentsCache.clear();
    await getMoments();
  }

  Future<void> _updateUnreadCount(List<MomentEntity> moments) async {
    final currentUserId = _getCurrentUserId();
    final lastReadTime = await _storageDataSource.getMomentLastReadTime();
    if (lastReadTime == null) {
      _unreadCount = moments
          .where((moment) => !_isFromCurrentUser(moment, currentUserId))
          .length;
      return;
    }

    _unreadCount = moments.where((moment) {
      if (_isFromCurrentUser(moment, currentUserId)) return false;
      return moment.timestamp.isAfter(lastReadTime);
    }).length;
  }

  /// 应用隐私过滤规则
  ///
  /// 过滤顺序：
  /// 1. 过滤我隐藏的用户的动态（不看 TA 的朋友圈）
  /// 2. 过滤屏蔽我查看的用户的动态（TA 不让我看）
  /// 3. 过滤超出可见天数的动态
  /// 4. 过滤可见性设置（public/private/partial/excluded）
  Future<List<MomentEntity>> _filterMoments(List<MomentEntity> moments) async {
    if (moments.isEmpty) return moments;

    final currentUserId = _getCurrentUserId();

    // 并行加载所有过滤设置
    final results = await Future.wait([
      getHiddenMomentUsers(),
      getBlockedMomentUsers(),
      getMomentVisibilitySettings(),
    ]);

    final hiddenUsers = results[0] as List<String>;
    // results[1] is blockedUsers - only used when others view my moments, not here
    final settings = results[2] as Map<String, dynamic>;
    final visibleDays = settings['visibleDays'] as int? ?? 0;

    // 计算时间截止点
    DateTime? cutoffTime;
    if (visibleDays > 0) {
      cutoffTime = DateTime.now().subtract(Duration(days: visibleDays));
    }

    final hiddenSet = hiddenUsers.toSet();
    // blockedUsers 仅在别人查看我的动态时生效，此处不需过滤

    return moments.where((moment) {
      // 自己的动态始终可见
      if (_isFromCurrentUser(moment, currentUserId)) return true;

      // 1. 我设置了不看 TA 的朋友圈
      if (hiddenSet.contains(moment.userId)) return false;

      // 2. TA 设置了不让我看（blockedUsers 存储的是我屏蔽的人列表，
      //    但这里的语义是"不让 TA 看我的朋友圈"，即我的 blockedUsers 列表
      //    用于过滤别人查看我的动态，而非我查看别人的动态。
      //    此处逻辑为：如果对方的 blockedUsers 包含我，对方的动态不应显示给我。
      //    但由于我们只能读取本地存储，这里 blockedUsers 代表"我不让谁看我的"，
      //    不适用于过滤别人的动态给我看。故此处跳过 blockedUsers 过滤。）
      //    注：blockedSet 在此不过滤他人动态，仅在别人查看我的动态时生效。

      // 3. 过滤超出可见天数的动态
      if (cutoffTime != null && moment.timestamp.isBefore(cutoffTime)) {
        return false;
      }

      // 4. 过滤可见性设置
      switch (moment.visibility) {
        case MomentVisibility.public:
          return true;
        case MomentVisibility.private:
          // 仅发布者自己可见（非自己的 private 动态不显示）
          return false;
        case MomentVisibility.partial:
          // 仅 visibilityUserIds 中的用户可见
          if (currentUserId == null) return false;
          return moment.visibilityUserIds.contains(currentUserId);
        case MomentVisibility.excluded:
          // visibilityUserIds 中的用户不可见
          if (currentUserId == null) return true;
          return !moment.visibilityUserIds.contains(currentUserId);
      }
    }).toList();
  }

  String? _getCurrentUserId() {
    return _momentDataSource.currentUserId;
  }

  bool _isFromCurrentUser(MomentEntity moment, String? currentUserId) {
    if (moment.isFromMe) {
      return true;
    }
    return currentUserId != null && moment.userId == currentUserId;
  }
}
