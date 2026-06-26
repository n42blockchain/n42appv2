import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/voice_room_entity.dart';
import '../../../domain/repositories/voice_room_repository.dart';
import '../../../services/voip/voice_room_service.dart';
import 'voice_room_event.dart';
import 'voice_room_state.dart';

/// 语音聊天室 BLoC
class VoiceRoomBloc extends Bloc<VoiceRoomEvent, VoiceRoomState> {
  final IVoiceRoomRepository _repository;
  final VoiceRoomService _voiceRoomService;

  StreamSubscription<VoiceRoomEntity?>? _roomSubscription;
  StreamSubscription<List<VoiceRoomEntity>>? _activeRoomsSubscription;
  StreamSubscription<VoiceRoomServiceState>? _serviceStateSubscription;
  Timer? _durationTimer;

  VoiceRoomBloc({
    required IVoiceRoomRepository repository,
    required VoiceRoomService voiceRoomService,
  })  : _repository = repository,
        _voiceRoomService = voiceRoomService,
        super(VoiceRoomState.initial()) {
    on<CreateVoiceRoom>(_onCreateVoiceRoom);
    on<LoadActiveVoiceRooms>(_onLoadActiveVoiceRooms);
    on<JoinVoiceRoom>(_onJoinVoiceRoom);
    on<LeaveVoiceRoom>(_onLeaveVoiceRoom);
    on<RaiseHand>(_onRaiseHand);
    on<LowerHand>(_onLowerHand);
    on<ApproveSpeaker>(_onApproveSpeaker);
    on<DemoteToListener>(_onDemoteToListener);
    on<ToggleMute>(_onToggleMute);
    on<EndVoiceRoom>(_onEndVoiceRoom);
    on<VoiceRoomUpdated>(_onVoiceRoomUpdated);
    on<ActiveVoiceRoomsUpdated>(_onActiveVoiceRoomsUpdated);
    on<DurationTick>(_onDurationTick);

    // 监听服务状态变化
    _serviceStateSubscription = _voiceRoomService.stateStream.listen((serviceState) {
      if (isClosed) return;
      if (!serviceState.isConnected && state.isConnected) {
        add(const LeaveVoiceRoom());
      }
    });

    // 订阅活跃房间列表
    _activeRoomsSubscription = _repository.watchActiveVoiceRooms().listen(
      (rooms) {
        if (!isClosed) add(ActiveVoiceRoomsUpdated(rooms));
      },
    );
  }

  Future<void> _onCreateVoiceRoom(
    CreateVoiceRoom event,
    Emitter<VoiceRoomState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final room = await _repository.createVoiceRoom(
        name: event.name,
        topic: event.topic,
      );
      if (room != null) {
        emit(state.copyWith(room: room, isLoading: false));
        // 自动加入创建的房间
        add(JoinVoiceRoom(room.roomId));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to create voice room'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadActiveVoiceRooms(
    LoadActiveVoiceRooms event,
    Emitter<VoiceRoomState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final rooms = await _repository.getActiveVoiceRooms();
      emit(state.copyWith(activeRooms: rooms, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onJoinVoiceRoom(
    JoinVoiceRoom event,
    Emitter<VoiceRoomState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final joined = await _voiceRoomService.joinRoom(event.roomId);
      if (joined) {
        final room = await _repository.getVoiceRoom(event.roomId);
        if (room != null) {
          _voiceRoomService.syncFromRoom(room);
        }
        emit(state.copyWith(
          room: room,
          isConnected: true,
          isLoading: false,
          myRole: _voiceRoomService.myRole,
          isMuted: _voiceRoomService.isMuted,
        ));

        // 订阅房间更新
        unawaited(_roomSubscription?.cancel());
        _roomSubscription = _repository.watchVoiceRoom(event.roomId).listen(
          (room) {
            if (room != null && !isClosed) {
              add(VoiceRoomUpdated(room));
            }
          },
        );

        // 开始计时
        _startDurationTimer();
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to join voice room'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLeaveVoiceRoom(
    LeaveVoiceRoom event,
    Emitter<VoiceRoomState> emit,
  ) async {
    await _voiceRoomService.leaveRoom();
    unawaited(_roomSubscription?.cancel());
    _durationTimer?.cancel();
    emit(state.copyWith(
      clearRoom: true,
      isConnected: false,
      myRole: VoiceRoomRole.listener,
      isHandRaised: false,
      isMuted: true,
      duration: 0,
    ));
  }

  Future<void> _onRaiseHand(RaiseHand event, Emitter<VoiceRoomState> emit) async {
    try {
      final success = await _voiceRoomService.raiseHand();
      if (success) {
        emit(state.copyWith(isHandRaised: true));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to raise hand: $e'));
    }
  }

  Future<void> _onLowerHand(LowerHand event, Emitter<VoiceRoomState> emit) async {
    try {
      final success = await _voiceRoomService.lowerHand();
      if (success) {
        emit(state.copyWith(isHandRaised: false));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to lower hand: $e'));
    }
  }

  Future<void> _onApproveSpeaker(ApproveSpeaker event, Emitter<VoiceRoomState> emit) async {
    try {
      await _voiceRoomService.approveSpeaker(event.userId);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to approve speaker: $e'));
    }
  }

  Future<void> _onDemoteToListener(DemoteToListener event, Emitter<VoiceRoomState> emit) async {
    try {
      await _voiceRoomService.demoteToListener(event.userId);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to demote to listener: $e'));
    }
  }

  Future<void> _onToggleMute(ToggleMute event, Emitter<VoiceRoomState> emit) async {
    try {
      await _voiceRoomService.toggleMute();
      emit(state.copyWith(isMuted: _voiceRoomService.isMuted, clearError: true));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to toggle mute: $e'));
    }
  }

  Future<void> _onEndVoiceRoom(EndVoiceRoom event, Emitter<VoiceRoomState> emit) async {
    if (state.room == null) return;
    final success = await _repository.endVoiceRoom(state.room!.roomId);
    if (success) {
      add(const LeaveVoiceRoom());
    } else {
      emit(state.copyWith(error: 'Failed to end voice room'));
    }
  }

  void _onVoiceRoomUpdated(VoiceRoomUpdated event, Emitter<VoiceRoomState> emit) {
    _voiceRoomService.syncFromRoom(event.room);
    emit(state.copyWith(
      room: event.room,
      myRole: _voiceRoomService.myRole,
      isMuted: _voiceRoomService.isMuted,
    ));
  }

  void _onActiveVoiceRoomsUpdated(ActiveVoiceRoomsUpdated event, Emitter<VoiceRoomState> emit) {
    emit(state.copyWith(activeRooms: event.rooms));
  }

  void _onDurationTick(DurationTick event, Emitter<VoiceRoomState> emit) {
    if (state.isConnected) {
      emit(state.copyWith(duration: state.duration + 1));
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed && state.isConnected) {
        add(const DurationTick());
      }
    });
  }

  @override
  Future<void> close() {
    _roomSubscription?.cancel();
    _activeRoomsSubscription?.cancel();
    _serviceStateSubscription?.cancel();
    _durationTimer?.cancel();
    return super.close();
  }
}
