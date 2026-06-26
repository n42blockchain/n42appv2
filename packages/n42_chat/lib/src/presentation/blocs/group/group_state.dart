import 'package:equatable/equatable.dart';

import '../../../domain/entities/channel_entity.dart';
import '../../../domain/entities/group_entity.dart';
import '../../../domain/entities/token_gate_entity.dart';

/// 群聊状态枚举
enum GroupStatus {
  /// 初始状态
  initial,

  /// 加载中
  loading,

  /// 列表已加载
  loaded,

  /// 群已创建
  created,

  /// 操作成功
  success,

  /// 代币门控已验证
  tokenGateVerified,

  /// 错误
  error,
}

/// 群聊状态（单一 State + copyWith 模式）
class GroupState extends Equatable {
  /// 当前状态
  final GroupStatus status;

  /// 群聊列表
  final List<GroupEntity> groups;

  /// 群邀请列表
  final List<GroupEntity> invites;

  /// 当前查看的群详情
  final GroupEntity? currentGroup;

  /// 当前群成员列表
  final List<GroupMember> members;

  /// 新创建的群 roomId
  final String? createdRoomId;

  /// 操作成功消息
  final String? successMessage;

  /// 错误消息
  final String? errorMessage;

  /// 代币门控验证结果
  final TokenGateVerificationResult? tokenGateResult;

  /// 代币门控验证的 roomId
  final String? tokenGateRoomId;

  /// 当前群组的子频道列表
  final List<ChannelEntity> channels;

  const GroupState({
    this.status = GroupStatus.initial,
    this.groups = const [],
    this.invites = const [],
    this.currentGroup,
    this.members = const [],
    this.createdRoomId,
    this.successMessage,
    this.errorMessage,
    this.tokenGateResult,
    this.tokenGateRoomId,
    this.channels = const [],
  });

  const GroupState.initial() : this();

  /// 是否正在加载
  bool get isLoading => status == GroupStatus.loading;

  /// 是否已加载列表
  bool get isLoaded => status == GroupStatus.loaded || groups.isNotEmpty;

  /// 是否有错误
  bool get hasError => status == GroupStatus.error && errorMessage != null;

  GroupState copyWith({
    GroupStatus? status,
    List<GroupEntity>? groups,
    List<GroupEntity>? invites,
    GroupEntity? currentGroup,
    List<GroupMember>? members,
    String? createdRoomId,
    String? successMessage,
    String? errorMessage,
    TokenGateVerificationResult? tokenGateResult,
    String? tokenGateRoomId,
    List<ChannelEntity>? channels,
  }) {
    return GroupState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      invites: invites ?? this.invites,
      currentGroup: currentGroup ?? this.currentGroup,
      members: members ?? this.members,
      createdRoomId: createdRoomId,
      successMessage: successMessage,
      errorMessage: errorMessage,
      tokenGateResult: tokenGateResult ?? this.tokenGateResult,
      tokenGateRoomId: tokenGateRoomId ?? this.tokenGateRoomId,
      channels: channels ?? this.channels,
    );
  }

  @override
  List<Object?> get props => [
        status,
        groups,
        invites,
        currentGroup,
        members,
        createdRoomId,
        successMessage,
        errorMessage,
        tokenGateResult,
        tokenGateRoomId,
        channels,
      ];

  @override
  String toString() => 'GroupState(status: $status, groups: ${groups.length}, members: ${members.length})';
}
