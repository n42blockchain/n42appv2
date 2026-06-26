import 'package:equatable/equatable.dart';

import '../../../domain/entities/group_entity.dart';
import '../../../domain/entities/space_entity.dart';

/// Space 页面状态枚举
enum SpaceStatus {
  initial,
  loading,
  success,
  failure,
}

/// Space BLoC 状态
class SpaceState extends Equatable {
  // ── 页面级状态 ──
  final SpaceStatus status;
  final String? errorMessage;

  // ── 已加入的 Space 列表 ──
  final List<SpaceEntity> joinedSpaces;

  // ── 发现/搜索结果 ──
  final List<SpaceEntity> publicSpaces;
  final bool isDiscovering;

  // ── 当前查看的 Space 详情 ──
  final SpaceEntity? currentSpace;
  final bool isLoadingDetail;

  // ── 成员列表 ──
  final List<GroupMember> currentMembers;
  final bool isLoadingMembers;

  // ── 操作状态（创建/加入/离开等） ──
  final bool isOperating;
  final String? operationSuccess; // 成功提示消息

  const SpaceState({
    this.status = SpaceStatus.initial,
    this.errorMessage,
    this.joinedSpaces = const [],
    this.publicSpaces = const [],
    this.isDiscovering = false,
    this.currentSpace,
    this.isLoadingDetail = false,
    this.currentMembers = const [],
    this.isLoadingMembers = false,
    this.isOperating = false,
    this.operationSuccess,
  });

  factory SpaceState.initial() => const SpaceState();

  bool get isLoading => status == SpaceStatus.loading;
  bool get hasError => status == SpaceStatus.failure;

  SpaceState copyWith({
    SpaceStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<SpaceEntity>? joinedSpaces,
    List<SpaceEntity>? publicSpaces,
    bool? isDiscovering,
    SpaceEntity? currentSpace,
    bool clearCurrentSpace = false,
    bool? isLoadingDetail,
    List<GroupMember>? currentMembers,
    bool? isLoadingMembers,
    bool? isOperating,
    String? operationSuccess,
    bool clearOperationSuccess = false,
  }) {
    return SpaceState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      joinedSpaces: joinedSpaces ?? this.joinedSpaces,
      publicSpaces: publicSpaces ?? this.publicSpaces,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      currentSpace:
          clearCurrentSpace ? null : (currentSpace ?? this.currentSpace),
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      currentMembers: currentMembers ?? this.currentMembers,
      isLoadingMembers: isLoadingMembers ?? this.isLoadingMembers,
      isOperating: isOperating ?? this.isOperating,
      operationSuccess: clearOperationSuccess
          ? null
          : (operationSuccess ?? this.operationSuccess),
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        joinedSpaces,
        publicSpaces,
        isDiscovering,
        currentSpace,
        isLoadingDetail,
        currentMembers,
        isLoadingMembers,
        isOperating,
        operationSuccess,
      ];
}
