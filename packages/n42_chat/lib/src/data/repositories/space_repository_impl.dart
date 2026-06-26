import 'dart:async';
import 'dart:typed_data';

import '../../domain/entities/group_entity.dart' show GroupMember;
import '../../domain/entities/space_entity.dart';
import '../../domain/repositories/space_repository.dart';
import '../datasources/matrix/matrix_space_datasource.dart';

/// Space 仓库实现
///
/// 将 MatrixSpaceDataSource 的底层操作转换为业务领域对象。
/// 维护本地 Space 列表缓存，减少重复网络请求。
class SpaceRepositoryImpl implements ISpaceRepository {
  static const int _spaceHierarchyPageSize = 50;
  static const int _maxHierarchyPages = 50;

  final MatrixSpaceDataSource _dataSource;

  /// 本地 Space 缓存（以 spaceId 为 key）
  final Map<String, SpaceEntity> _spaceCache = {};

  SpaceRepositoryImpl(this._dataSource);

  // ============================================
  // Space 列表
  // ============================================

  @override
  Future<List<SpaceEntity>> getJoinedSpaces() async {
    final rooms = _dataSource.getJoinedSpaces();
    final spaces = rooms.map((r) => _dataSource.roomToSpaceEntity(r)).toList();
    // 更新缓存
    for (final s in spaces) {
      _spaceCache[s.id] = s;
    }
    return spaces;
  }

  @override
  Stream<List<SpaceEntity>> watchJoinedSpaces() {
    return _dataSource.watchJoinedSpaces().map(
      (rooms) => rooms.map((r) => _dataSource.roomToSpaceEntity(r)).toList(),
    );
  }

  @override
  Future<List<SpaceEntity>> discoverPublicSpaces({String? searchQuery}) async {
    final chunks = await _dataSource.discoverPublicSpaces(
      searchQuery: searchQuery,
    );
    return chunks.map(_dataSource.publicRoomToSpaceEntity).toList();
  }

  // ============================================
  // Space 详情
  // ============================================

  @override
  Future<SpaceEntity?> getSpaceDetail(String spaceId) async {
    final room = _dataSource.getSpace(spaceId);
    if (room == null) return null;

    final base = _dataSource.roomToSpaceEntity(room);
    final withChildren = await _enrichWithChildren(base);
    _spaceCache[spaceId] = withChildren;
    return withChildren;
  }

  @override
  Future<SpaceEntity?> refreshSpaceHierarchy(String spaceId) async {
    _spaceCache.remove(spaceId);
    return getSpaceDetail(spaceId);
  }

  @override
  Future<String> getSpaceInviteLink(String spaceId) async {
    return _dataSource.getSpaceInviteLink(spaceId);
  }

  // ============================================
  // Space 生命周期
  // ============================================

  @override
  Future<String> createSpace({
    required String name,
    String? description,
    SpaceType type = SpaceType.public,
    Uint8List? avatar,
    List<String> topics = const [],
  }) async {
    return _dataSource.createSpace(
      name: name,
      description: description,
      isPublic: type == SpaceType.public,
      avatar: avatar,
      topics: topics,
    );
  }

  @override
  Future<void> joinSpace(String spaceId) async {
    await _dataSource.joinSpace(spaceId);
    _spaceCache.remove(spaceId); // 使缓存失效，下次重新拉取
  }

  @override
  Future<void> leaveSpace(String spaceId) async {
    await _dataSource.leaveSpace(spaceId);
    _spaceCache.remove(spaceId);
  }

  @override
  Future<void> deleteSpace(String spaceId) async {
    await _dataSource.deleteSpace(spaceId);
    _spaceCache.remove(spaceId);
  }

  // ============================================
  // Space 信息管理
  // ============================================

  @override
  Future<void> setSpaceName(String spaceId, String name) async {
    await _dataSource.setSpaceName(spaceId, name);
    _invalidateCacheEntry(spaceId, (s) => s.copyWith(name: name));
  }

  @override
  Future<void> setSpaceDescription(String spaceId, String description) async {
    await _dataSource.setSpaceDescription(spaceId, description);
    _invalidateCacheEntry(spaceId, (s) => s.copyWith(description: description));
  }

  @override
  Future<void> setSpaceAvatar(String spaceId, Uint8List avatar) async {
    await _dataSource.setSpaceAvatar(spaceId, avatar);
    _spaceCache.remove(spaceId);
  }

  // ============================================
  // 频道管理
  // ============================================

  @override
  Future<String> createChannel(
    String spaceId, {
    required String name,
    String? topic,
    bool isPublic = true,
  }) async {
    final channelId = await _dataSource.createChannel(
      spaceId,
      name: name,
      topic: topic,
      isPublic: isPublic,
    );
    _spaceCache.remove(spaceId); // 子房间列表变化，使缓存失效
    return channelId;
  }

  @override
  Future<void> deleteChannel(String spaceId, String channelId) async {
    await _dataSource.deleteChannel(spaceId, channelId);
    _spaceCache.remove(spaceId);
  }

  // ============================================
  // 成员管理
  // ============================================

  @override
  Future<List<GroupMember>> getSpaceMembers(String spaceId) async {
    final users = _dataSource.getSpaceMembers(spaceId);
    return users.map(_dataSource.matrixUserToMember).toList();
  }

  @override
  Future<void> inviteMember(String spaceId, String userId) async {
    await _dataSource.inviteMember(spaceId, userId);
  }

  @override
  Future<void> kickMember(
    String spaceId,
    String userId, {
    String? reason,
  }) async {
    await _dataSource.kickMember(spaceId, userId, reason: reason);
  }

  @override
  Future<void> banMember(
    String spaceId,
    String userId, {
    String? reason,
  }) async {
    await _dataSource.banMember(spaceId, userId, reason: reason);
  }

  @override
  Future<void> setMemberPowerLevel(
    String spaceId,
    String userId,
    int powerLevel,
  ) async {
    await _dataSource.setMemberPowerLevel(spaceId, userId, powerLevel);
  }

  // ============================================
  // 内部辅助
  // ============================================

  /// 通过 Space hierarchy API 填充子房间列表
  Future<SpaceEntity> _enrichWithChildren(SpaceEntity base) async {
    final childrenByRoomId = <String, SpaceChild>{};
    String? nextBatch;

    for (var page = 0; page < _maxHierarchyPages; page++) {
      final hierarchy = await _dataSource.getSpaceHierarchy(
        base.id,
        maxDepth: 1,
        limit: _spaceHierarchyPageSize,
        from: nextBatch,
      );
      if (hierarchy == null) {
        break;
      }

      for (final chunk in hierarchy.rooms) {
        if (chunk.roomId == base.id) {
          continue;
        }
        childrenByRoomId.putIfAbsent(
          chunk.roomId,
          () => _dataSource.hierarchyRoomToChild(chunk),
        );
      }

      nextBatch = hierarchy.nextBatch;
      if (nextBatch == null || nextBatch.isEmpty) {
        break;
      }
    }

    final children = childrenByRoomId.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return base.copyWith(children: children);
  }

  /// 局部更新缓存条目（不删除，保留数据连续性）
  void _invalidateCacheEntry(
    String spaceId,
    SpaceEntity Function(SpaceEntity) updater,
  ) {
    final cached = _spaceCache[spaceId];
    if (cached != null) {
      _spaceCache[spaceId] = updater(cached);
    }
  }
}
