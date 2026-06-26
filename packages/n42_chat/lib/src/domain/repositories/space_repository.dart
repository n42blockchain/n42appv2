import 'dart:typed_data';

import '../entities/group_entity.dart';
import '../entities/space_entity.dart';

/// Space（社群）仓库接口
abstract class ISpaceRepository {
  // ============================================
  // Space 列表
  // ============================================

  /// 获取当前用户已加入的 Space 列表
  Future<List<SpaceEntity>> getJoinedSpaces();

  /// 监听已加入 Space 列表的实时变化
  Stream<List<SpaceEntity>> watchJoinedSpaces();

  /// 搜索/发现公开 Space
  Future<List<SpaceEntity>> discoverPublicSpaces({String? searchQuery});

  // ============================================
  // Space 详情
  // ============================================

  /// 获取 Space 详情（含子频道列表）
  Future<SpaceEntity?> getSpaceDetail(String spaceId);

  /// 刷新 Space 层级结构（重新拉取所有子房间）
  Future<SpaceEntity?> refreshSpaceHierarchy(String spaceId);

  /// 获取社区分享链接
  Future<String> getSpaceInviteLink(String spaceId);

  // ============================================
  // Space 生命周期
  // ============================================

  /// 创建新 Space，返回新建 Space 的 roomId
  Future<String> createSpace({
    required String name,
    String? description,
    SpaceType type = SpaceType.public,
    Uint8List? avatar,
    List<String> topics = const [],
  });

  /// 加入 Space
  Future<void> joinSpace(String spaceId);

  /// 离开 Space
  Future<void> leaveSpace(String spaceId);

  /// 删除 Space（仅管理员）
  Future<void> deleteSpace(String spaceId);

  // ============================================
  // Space 信息管理
  // ============================================

  /// 更新 Space 名称
  Future<void> setSpaceName(String spaceId, String name);

  /// 更新 Space 描述
  Future<void> setSpaceDescription(String spaceId, String description);

  /// 更新 Space 头像
  Future<void> setSpaceAvatar(String spaceId, Uint8List avatar);

  // ============================================
  // 频道管理
  // ============================================

  /// 在 Space 下创建频道，返回新频道的 roomId
  Future<String> createChannel(
    String spaceId, {
    required String name,
    String? topic,
    bool isPublic = true,
  });

  /// 删除频道（将频道从 Space 中移除并解散）
  Future<void> deleteChannel(String spaceId, String channelId);

  // ============================================
  // 成员管理
  // ============================================

  /// 获取 Space 成员列表
  Future<List<GroupMember>> getSpaceMembers(String spaceId);

  /// 邀请成员加入 Space
  Future<void> inviteMember(String spaceId, String userId);

  /// 踢出成员
  Future<void> kickMember(String spaceId, String userId, {String? reason});

  /// 封禁成员
  Future<void> banMember(String spaceId, String userId, {String? reason});

  /// 设置成员权限等级（50 = 管理员，0 = 普通成员）
  Future<void> setMemberPowerLevel(
    String spaceId,
    String userId,
    int powerLevel,
  );
}
