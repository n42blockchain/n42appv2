import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/space_entity.dart';

/// Space BLoC 事件基类
abstract class SpaceEvent extends Equatable {
  const SpaceEvent();

  @override
  List<Object?> get props => [];
}

// ──────────────────────────────────────────────
// 加载类事件
// ──────────────────────────────────────────────

/// 加载已加入的 Space 列表
class LoadJoinedSpaces extends SpaceEvent {
  const LoadJoinedSpaces();
}

/// 搜索/发现公开 Space
class DiscoverPublicSpaces extends SpaceEvent {
  final String? searchQuery;
  const DiscoverPublicSpaces({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

/// 加载 Space 详情（含子频道层级）
class LoadSpaceDetail extends SpaceEvent {
  final String spaceId;
  const LoadSpaceDetail(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}

/// 刷新 Space 详情（强制重新拉取）
class RefreshSpaceDetail extends SpaceEvent {
  final String spaceId;
  const RefreshSpaceDetail(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}

/// 后台 Space 列表更新（来自 Stream）
class SpaceListUpdated extends SpaceEvent {
  final List<SpaceEntity> spaces;
  const SpaceListUpdated(this.spaces);

  @override
  List<Object?> get props => [spaces];
}

// ──────────────────────────────────────────────
// Space 生命周期事件
// ──────────────────────────────────────────────

/// 创建 Space
class CreateSpace extends SpaceEvent {
  final String name;
  final String? description;
  final SpaceType type;
  final Uint8List? avatar;
  final List<String> topics;

  const CreateSpace({
    required this.name,
    this.description,
    this.type = SpaceType.public,
    this.avatar,
    this.topics = const [],
  });

  @override
  List<Object?> get props => [name, description, type, topics];
}

/// 加入 Space
class JoinSpace extends SpaceEvent {
  final String spaceId;
  const JoinSpace(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}

/// 离开 Space
class LeaveSpace extends SpaceEvent {
  final String spaceId;
  const LeaveSpace(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}

/// 删除/解散 Space
class DeleteSpace extends SpaceEvent {
  final String spaceId;
  const DeleteSpace(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}

// ──────────────────────────────────────────────
// Space 信息管理事件
// ──────────────────────────────────────────────

/// 更新 Space 名称
class UpdateSpaceName extends SpaceEvent {
  final String spaceId;
  final String name;
  const UpdateSpaceName(this.spaceId, this.name);

  @override
  List<Object?> get props => [spaceId, name];
}

/// 更新 Space 描述
class UpdateSpaceDescription extends SpaceEvent {
  final String spaceId;
  final String description;
  const UpdateSpaceDescription(this.spaceId, this.description);

  @override
  List<Object?> get props => [spaceId, description];
}

/// 更新 Space 头像
class UpdateSpaceAvatar extends SpaceEvent {
  final String spaceId;
  final Uint8List avatar;
  const UpdateSpaceAvatar(this.spaceId, this.avatar);

  @override
  List<Object?> get props => [spaceId];
}

// ──────────────────────────────────────────────
// 频道管理事件
// ──────────────────────────────────────────────

/// 创建频道
class CreateChannel extends SpaceEvent {
  final String spaceId;
  final String name;
  final String? topic;
  final bool isPublic;

  const CreateChannel({
    required this.spaceId,
    required this.name,
    this.topic,
    this.isPublic = true,
  });

  @override
  List<Object?> get props => [spaceId, name, topic, isPublic];
}

/// 删除频道
class DeleteChannel extends SpaceEvent {
  final String spaceId;
  final String channelId;
  const DeleteChannel(this.spaceId, this.channelId);

  @override
  List<Object?> get props => [spaceId, channelId];
}

// ──────────────────────────────────────────────
// 成员管理事件
// ──────────────────────────────────────────────

/// 加载成员列表
class LoadSpaceMembers extends SpaceEvent {
  final String spaceId;
  const LoadSpaceMembers(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}

/// 邀请成员
class InviteMember extends SpaceEvent {
  final String spaceId;
  final String userId;
  const InviteMember(this.spaceId, this.userId);

  @override
  List<Object?> get props => [spaceId, userId];
}

/// 踢出成员
class KickMember extends SpaceEvent {
  final String spaceId;
  final String userId;
  final String? reason;
  const KickMember(this.spaceId, this.userId, {this.reason});

  @override
  List<Object?> get props => [spaceId, userId, reason];
}

/// 封禁成员
class BanMember extends SpaceEvent {
  final String spaceId;
  final String userId;
  final String? reason;
  const BanMember(this.spaceId, this.userId, {this.reason});

  @override
  List<Object?> get props => [spaceId, userId, reason];
}

/// 设置成员权限等级
class SetMemberPowerLevel extends SpaceEvent {
  final String spaceId;
  final String userId;

  /// 50 = 管理员，0 = 普通成员
  final int powerLevel;
  const SetMemberPowerLevel(this.spaceId, this.userId, this.powerLevel);

  @override
  List<Object?> get props => [spaceId, userId, powerLevel];
}

/// 清除错误状态
class ClearSpaceError extends SpaceEvent {
  const ClearSpaceError();
}
