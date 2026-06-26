import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/space_entity.dart';
import '../../../domain/repositories/space_repository.dart';
import 'space_event.dart';
import 'space_state.dart';

/// Space（社群）BLoC
///
/// 管理 Space 列表加载、Space 详情、成员管理及所有 CRUD 操作。
/// 通过 [ISpaceRepository] 与数据层解耦。
class SpaceBloc extends Bloc<SpaceEvent, SpaceState> {
  final ISpaceRepository _repository;

  StreamSubscription<List<SpaceEntity>>? _spacesSubscription;

  SpaceBloc({required ISpaceRepository repository})
      : _repository = repository,
        super(SpaceState.initial()) {
    on<LoadJoinedSpaces>(_onLoadJoinedSpaces);
    on<DiscoverPublicSpaces>(_onDiscoverPublicSpaces);
    on<LoadSpaceDetail>(_onLoadSpaceDetail);
    on<RefreshSpaceDetail>(_onRefreshSpaceDetail);
    on<SpaceListUpdated>(_onSpaceListUpdated);

    on<CreateSpace>(_onCreateSpace);
    on<JoinSpace>(_onJoinSpace);
    on<LeaveSpace>(_onLeaveSpace);
    on<DeleteSpace>(_onDeleteSpace);

    on<UpdateSpaceName>(_onUpdateSpaceName);
    on<UpdateSpaceDescription>(_onUpdateSpaceDescription);
    on<UpdateSpaceAvatar>(_onUpdateSpaceAvatar);

    on<CreateChannel>(_onCreateChannel);
    on<DeleteChannel>(_onDeleteChannel);

    on<LoadSpaceMembers>(_onLoadSpaceMembers);
    on<InviteMember>(_onInviteMember);
    on<KickMember>(_onKickMember);
    on<BanMember>(_onBanMember);
    on<SetMemberPowerLevel>(_onSetMemberPowerLevel);

    on<ClearSpaceError>(_onClearSpaceError);

    // 订阅实时 Space 列表变化
    _spacesSubscription = _repository.watchJoinedSpaces().listen(
      (spaces) {
        if (!isClosed) add(SpaceListUpdated(spaces));
      },
    );
  }

  // ──────────────────────────────────────────────
  // 加载类
  // ──────────────────────────────────────────────

  Future<void> _onLoadJoinedSpaces(
    LoadJoinedSpaces event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(status: SpaceStatus.loading));
    try {
      final spaces = await _repository.getJoinedSpaces();
      emit(state.copyWith(
        status: SpaceStatus.success,
        joinedSpaces: spaces,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SpaceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDiscoverPublicSpaces(
    DiscoverPublicSpaces event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isDiscovering: true));
    try {
      final spaces =
          await _repository.discoverPublicSpaces(searchQuery: event.searchQuery);
      emit(state.copyWith(
        isDiscovering: false,
        publicSpaces: spaces,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDiscovering: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadSpaceDetail(
    LoadSpaceDetail event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetail: true));
    try {
      final space = await _repository.getSpaceDetail(event.spaceId);
      emit(state.copyWith(
        isLoadingDetail: false,
        currentSpace: space,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDetail: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshSpaceDetail(
    RefreshSpaceDetail event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetail: true));
    try {
      final space = await _repository.refreshSpaceHierarchy(event.spaceId);
      emit(state.copyWith(
        isLoadingDetail: false,
        currentSpace: space,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDetail: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSpaceListUpdated(
    SpaceListUpdated event,
    Emitter<SpaceState> emit,
  ) {
    emit(state.copyWith(joinedSpaces: event.spaces));
  }

  // ──────────────────────────────────────────────
  // Space 生命周期
  // ──────────────────────────────────────────────

  Future<void> _onCreateSpace(
    CreateSpace event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isOperating: true));
    try {
      await _repository.createSpace(
        name: event.name,
        description: event.description,
        type: event.type,
        avatar: event.avatar,
        topics: event.topics,
      );
      // 创建后刷新列表
      final spaces = await _repository.getJoinedSpaces();
      emit(state.copyWith(
        isOperating: false,
        joinedSpaces: spaces,
        operationSuccess: 'Space created successfully',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOperating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onJoinSpace(
    JoinSpace event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isOperating: true));
    try {
      await _repository.joinSpace(event.spaceId);
      final spaces = await _repository.getJoinedSpaces();
      emit(state.copyWith(
        isOperating: false,
        joinedSpaces: spaces,
        operationSuccess: 'Joined space',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOperating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLeaveSpace(
    LeaveSpace event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isOperating: true));
    try {
      await _repository.leaveSpace(event.spaceId);
      final spaces = await _repository.getJoinedSpaces();
      emit(state.copyWith(
        isOperating: false,
        joinedSpaces: spaces,
        clearCurrentSpace: state.currentSpace?.id == event.spaceId,
        operationSuccess: 'Left space',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOperating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteSpace(
    DeleteSpace event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isOperating: true));
    try {
      await _repository.deleteSpace(event.spaceId);
      final spaces = await _repository.getJoinedSpaces();
      emit(state.copyWith(
        isOperating: false,
        joinedSpaces: spaces,
        clearCurrentSpace: state.currentSpace?.id == event.spaceId,
        operationSuccess: 'Space deleted',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOperating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // Space 信息管理
  // ──────────────────────────────────────────────

  Future<void> _onUpdateSpaceName(
    UpdateSpaceName event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isOperating: true));
    try {
      await _repository.setSpaceName(event.spaceId, event.name);
      final space = await _repository.getSpaceDetail(event.spaceId);
      emit(state.copyWith(
        isOperating: false,
        currentSpace: space,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOperating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateSpaceDescription(
    UpdateSpaceDescription event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isOperating: true));
    try {
      await _repository.setSpaceDescription(event.spaceId, event.description);
      final space = await _repository.getSpaceDetail(event.spaceId);
      emit(state.copyWith(
        isOperating: false,
        currentSpace: space,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOperating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateSpaceAvatar(
    UpdateSpaceAvatar event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isOperating: true));
    try {
      await _repository.setSpaceAvatar(event.spaceId, event.avatar);
      final space = await _repository.getSpaceDetail(event.spaceId);
      emit(state.copyWith(
        isOperating: false,
        currentSpace: space,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOperating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // 频道管理
  // ──────────────────────────────────────────────

  Future<void> _onCreateChannel(
    CreateChannel event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isOperating: true));
    try {
      await _repository.createChannel(
        event.spaceId,
        name: event.name,
        topic: event.topic,
        isPublic: event.isPublic,
      );
      // 刷新 Space 以更新子频道列表
      final space = await _repository.refreshSpaceHierarchy(event.spaceId);
      emit(state.copyWith(
        isOperating: false,
        currentSpace: space,
        operationSuccess: 'Channel created',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOperating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteChannel(
    DeleteChannel event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isOperating: true));
    try {
      await _repository.deleteChannel(event.spaceId, event.channelId);
      final space = await _repository.refreshSpaceHierarchy(event.spaceId);
      emit(state.copyWith(
        isOperating: false,
        currentSpace: space,
        operationSuccess: 'Channel deleted',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOperating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // 成员管理
  // ──────────────────────────────────────────────

  Future<void> _onLoadSpaceMembers(
    LoadSpaceMembers event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isLoadingMembers: true));
    try {
      final members = await _repository.getSpaceMembers(event.spaceId);
      emit(state.copyWith(
        isLoadingMembers: false,
        currentMembers: members,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMembers: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onInviteMember(
    InviteMember event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isOperating: true));
    try {
      await _repository.inviteMember(event.spaceId, event.userId);
      emit(state.copyWith(
        isOperating: false,
        operationSuccess: 'Invitation sent',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOperating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onKickMember(
    KickMember event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isOperating: true));
    try {
      await _repository.kickMember(event.spaceId, event.userId,
          reason: event.reason);
      final members = await _repository.getSpaceMembers(event.spaceId);
      emit(state.copyWith(
        isOperating: false,
        currentMembers: members,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOperating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onBanMember(
    BanMember event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isOperating: true));
    try {
      await _repository.banMember(event.spaceId, event.userId,
          reason: event.reason);
      final members = await _repository.getSpaceMembers(event.spaceId);
      emit(state.copyWith(
        isOperating: false,
        currentMembers: members,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOperating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSetMemberPowerLevel(
    SetMemberPowerLevel event,
    Emitter<SpaceState> emit,
  ) async {
    emit(state.copyWith(isOperating: true));
    try {
      await _repository.setMemberPowerLevel(
          event.spaceId, event.userId, event.powerLevel);
      final members = await _repository.getSpaceMembers(event.spaceId);
      emit(state.copyWith(
        isOperating: false,
        currentMembers: members,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOperating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClearSpaceError(ClearSpaceError event, Emitter<SpaceState> emit) {
    emit(state.copyWith(clearError: true, clearOperationSuccess: true));
  }

  @override
  Future<void> close() {
    _spacesSubscription?.cancel();
    return super.close();
  }
}
