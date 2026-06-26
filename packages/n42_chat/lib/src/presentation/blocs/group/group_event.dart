import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/bot_config_entity.dart';
import '../../../domain/entities/content_filter_entity.dart';
import '../../../domain/entities/token_gate_entity.dart';

/// 群聊事件基类
abstract class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

/// 加载群聊列表
class LoadGroups extends GroupEvent {
  const LoadGroups();
}

/// 刷新群聊列表
class RefreshGroups extends GroupEvent {
  const RefreshGroups();
}

/// 加载群详情
class LoadGroupDetails extends GroupEvent {
  final String roomId;

  const LoadGroupDetails(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// 加载群成员
class LoadGroupMembers extends GroupEvent {
  final String roomId;

  const LoadGroupMembers(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// 创建群聊
class CreateGroup extends GroupEvent {
  final String name;
  final List<String> inviteUserIds;
  final String? topic;
  final bool isPublic;
  final bool enableEncryption;
  final Uint8List? avatar;

  const CreateGroup({
    required this.name,
    this.inviteUserIds = const [],
    this.topic,
    this.isPublic = false,
    this.enableEncryption = false,
    this.avatar,
  });

  @override
  List<Object?> get props => [
    name,
    inviteUserIds,
    topic,
    isPublic,
    enableEncryption,
    avatar,
  ];
}

/// 更新群名称
class UpdateGroupName extends GroupEvent {
  final String roomId;
  final String name;

  const UpdateGroupName(this.roomId, this.name);

  @override
  List<Object?> get props => [roomId, name];
}

/// 更新群话题
class UpdateGroupTopic extends GroupEvent {
  final String roomId;
  final String topic;

  const UpdateGroupTopic(this.roomId, this.topic);

  @override
  List<Object?> get props => [roomId, topic];
}

/// 更新群公告
class UpdateGroupAnnouncement extends GroupEvent {
  final String roomId;
  final String announcement;

  const UpdateGroupAnnouncement(this.roomId, this.announcement);

  @override
  List<Object?> get props => [roomId, announcement];
}

/// 更新群头像
class UpdateGroupAvatar extends GroupEvent {
  final String roomId;
  final Uint8List avatar;

  const UpdateGroupAvatar(this.roomId, this.avatar);

  @override
  List<Object?> get props => [roomId, avatar];
}

/// 更新群可见性
class UpdateGroupVisibility extends GroupEvent {
  final String roomId;
  final bool isPublic;

  const UpdateGroupVisibility(this.roomId, this.isPublic);

  @override
  List<Object?> get props => [roomId, isPublic];
}

/// 邀请成员
class InviteMembers extends GroupEvent {
  final String roomId;
  final List<String> userIds;

  const InviteMembers(this.roomId, this.userIds);

  @override
  List<Object?> get props => [roomId, userIds];
}

/// 踢出成员
class KickMember extends GroupEvent {
  final String roomId;
  final String userId;
  final String? reason;

  const KickMember(this.roomId, this.userId, {this.reason});

  @override
  List<Object?> get props => [roomId, userId, reason];
}

/// 设置管理员
class SetAsAdmin extends GroupEvent {
  final String roomId;
  final String userId;

  const SetAsAdmin(this.roomId, this.userId);

  @override
  List<Object?> get props => [roomId, userId];
}

/// 取消管理员
class RemoveAdmin extends GroupEvent {
  final String roomId;
  final String userId;

  const RemoveAdmin(this.roomId, this.userId);

  @override
  List<Object?> get props => [roomId, userId];
}

/// 离开群
class LeaveGroup extends GroupEvent {
  final String roomId;

  const LeaveGroup(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// 解散群
class DeleteGroup extends GroupEvent {
  final String roomId;

  const DeleteGroup(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// 加载群邀请
class LoadGroupInvites extends GroupEvent {
  const LoadGroupInvites();
}

/// 接受群邀请
class AcceptGroupInvite extends GroupEvent {
  final String roomId;

  const AcceptGroupInvite(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// 拒绝群邀请
class RejectGroupInvite extends GroupEvent {
  final String roomId;

  const RejectGroupInvite(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// 群列表已更新
class GroupsUpdated extends GroupEvent {
  const GroupsUpdated();
}

/// 设置代币门控
class SetTokenGate extends GroupEvent {
  final String roomId;
  final TokenGateConfig config;

  const SetTokenGate(this.roomId, this.config);

  @override
  List<Object?> get props => [roomId, config];
}

/// 验证代币门控
class VerifyTokenGate extends GroupEvent {
  final String roomId;

  const VerifyTokenGate(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// 设置 Bot 配置
class SetBotConfig extends GroupEvent {
  final String roomId;
  final BotConfig config;

  const SetBotConfig(this.roomId, this.config);

  @override
  List<Object?> get props => [roomId, config];
}

/// 设置关键词过滤
class SetContentFilter extends GroupEvent {
  final String roomId;
  final ContentFilterConfig config;

  const SetContentFilter(this.roomId, this.config);

  @override
  List<Object?> get props => [roomId, config];
}

/// 设置群人数上限
class SetMaxMembers extends GroupEvent {
  final String roomId;
  final int? maxMembers; // null = 取消上限

  const SetMaxMembers(this.roomId, this.maxMembers);

  @override
  List<Object?> get props => [roomId, maxMembers];
}

/// 加载子频道列表
class LoadChannels extends GroupEvent {
  final String roomId;

  const LoadChannels(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// 创建子频道
class CreateChannel extends GroupEvent {
  final String parentRoomId;
  final String name;
  final String? topic;
  final String? category;

  const CreateChannel({
    required this.parentRoomId,
    required this.name,
    this.topic,
    this.category,
  });

  @override
  List<Object?> get props => [parentRoomId, name, topic, category];
}

/// 更新子频道
class UpdateChannel extends GroupEvent {
  final String parentRoomId;
  final String channelRoomId;
  final String? name;
  final String? topic;
  final String? category;

  const UpdateChannel({
    required this.parentRoomId,
    required this.channelRoomId,
    this.name,
    this.topic,
    this.category,
  });

  @override
  List<Object?> get props => [
    parentRoomId,
    channelRoomId,
    name,
    topic,
    category,
  ];
}

/// 删除子频道
class DeleteChannel extends GroupEvent {
  final String parentRoomId;
  final String channelRoomId;

  const DeleteChannel({
    required this.parentRoomId,
    required this.channelRoomId,
  });

  @override
  List<Object?> get props => [parentRoomId, channelRoomId];
}

/// 订阅成员加入事件（用于 Bot 自动欢迎）
class SubscribeToMemberJoins extends GroupEvent {
  final String roomId;

  const SubscribeToMemberJoins(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// 成员加入时内部触发（Bot 自动发送欢迎消息）
class MemberJoined extends GroupEvent {
  final String roomId;
  final String userId;

  const MemberJoined(this.roomId, this.userId);

  @override
  List<Object?> get props => [roomId, userId];
}
