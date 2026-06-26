import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../data/datasources/matrix/matrix_message_datasource.dart';
import '../../../domain/entities/live_location_entity.dart';
import 'live_location_event.dart';
import 'live_location_state.dart';
import '../../../core/utils/debug_log.dart';

class LiveLocationBloc extends Bloc<LiveLocationEvent, LiveLocationState> {
  final MatrixMessageDataSource _messageDataSource;
  Timer? _locationUpdateTimer;
  Timer? _expiryCheckTimer;
  StreamSubscription<List<LiveLocationEntity>>? _liveLocationsSubscription;

  LiveLocationBloc({
    required MatrixMessageDataSource messageDataSource,
  })  : _messageDataSource = messageDataSource,
        super(const LiveLocationState()) {
    on<ObserveLiveLocationRoom>(_onObserveLiveLocationRoom);
    on<StartLiveLocation>(_onStartLiveLocation);
    on<StopLiveLocation>(_onStopLiveLocation);
    on<UpdateMyLocation>(_onUpdateMyLocation);
    on<LiveLocationUpdated>(_onLiveLocationUpdated);
    on<LiveLocationSnapshotReceived>(_onLiveLocationSnapshotReceived);
    on<LiveLocationExpired>(_onLiveLocationExpired);
  }

  Future<void> _onObserveLiveLocationRoom(
    ObserveLiveLocationRoom event,
    Emitter<LiveLocationState> emit,
  ) async {
    await _liveLocationsSubscription?.cancel();
    emit(state.copyWith(currentRoomId: event.roomId, error: null));

    _liveLocationsSubscription = _messageDataSource
        .watchLiveLocations(event.roomId)
        .listen(
      (locations) {
        if (!isClosed) {
          add(LiveLocationSnapshotReceived(
            roomId: event.roomId,
            locations: locations,
          ));
        }
      },
      onError: (Object error) {
        debugLog('LiveLocationBloc: Failed to watch live locations: $error');
      },
    );
  }

  Future<void> _onStartLiveLocation(
    StartLiveLocation event,
    Emitter<LiveLocationState> emit,
  ) async {
    try {
      // 检查定位服务是否启用
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(state.copyWith(error: 'Location services are disabled'));
        return;
      }

      // 检查定位权限
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(state.copyWith(error: 'Location permission denied'));
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        emit(state.copyWith(
          error: 'Location permission permanently denied. '
              'Please enable it in system settings.',
        ));
        return;
      }

      // 发送 live_location 状态事件到 Matrix
      await _messageDataSource.startLiveLocation(
        event.roomId,
        event.durationMinutes,
      );

      emit(state.copyWith(
        isSharing: true,
        currentRoomId: event.roomId,
      ));

      // 启动位置更新定时器（每 10 秒）
      _startLocationUpdates(event.roomId);

      // 启动过期检查定时器
      _startExpiryCheck();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onStopLiveLocation(
    StopLiveLocation event,
    Emitter<LiveLocationState> emit,
  ) async {
    try {
      await _messageDataSource.stopLiveLocation(event.roomId);

      _locationUpdateTimer?.cancel();
      _expiryCheckTimer?.cancel();

      emit(state.copyWith(
        isSharing: false,
        currentRoomId: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onUpdateMyLocation(
    UpdateMyLocation event,
    Emitter<LiveLocationState> emit,
  ) {
    emit(state.copyWith(
      myLatitude: event.latitude,
      myLongitude: event.longitude,
    ));

    // 发送位置更新到 Matrix
    if (state.isSharing && state.currentRoomId != null) {
      _messageDataSource.updateLiveLocation(
        state.currentRoomId!,
        event.latitude,
        event.longitude,
        event.accuracy,
      );
    }
  }

  void _onLiveLocationUpdated(
    LiveLocationUpdated event,
    Emitter<LiveLocationState> emit,
  ) {
    final updatedSharings = Map<String, LiveLocationEntity>.from(state.activeSharings);
    if (event.location.isExpired) {
      updatedSharings.remove(event.location.userId);
    } else {
      updatedSharings[event.location.userId] = event.location;
    }

    emit(state.copyWith(activeSharings: updatedSharings));
  }

  void _onLiveLocationSnapshotReceived(
    LiveLocationSnapshotReceived event,
    Emitter<LiveLocationState> emit,
  ) {
    final activeSharings = <String, LiveLocationEntity>{
      for (final location in event.locations) location.userId: location,
    };
    final currentUserId = _messageDataSource.currentUserId;
    final isSharingFromSnapshot = currentUserId != null &&
        activeSharings.containsKey(currentUserId);

    emit(state.copyWith(
      currentRoomId: event.roomId,
      activeSharings: activeSharings,
      isSharing: isSharingFromSnapshot ||
          (state.isSharing && state.currentRoomId == event.roomId),
      error: null,
    ));
  }

  void _onLiveLocationExpired(
    LiveLocationExpired event,
    Emitter<LiveLocationState> emit,
  ) {
    final updatedSharings = Map<String, LiveLocationEntity>.from(state.activeSharings);
    updatedSharings.remove(event.userId);
    emit(state.copyWith(activeSharings: updatedSharings));
  }

  void _startLocationUpdates(String roomId) {
    _locationUpdateTimer?.cancel();

    // 立即获取一次位置，不等待第一个 Timer 间隔
    _fetchAndEmitPosition();

    // 每 10 秒获取一次位置
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchAndEmitPosition(),
    );
  }

  Future<void> _fetchAndEmitPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      add(UpdateMyLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      ));
    } catch (e) {
      debugLog('LiveLocationBloc: Failed to get position: $e');
    }
  }

  void _startExpiryCheck() {
    _expiryCheckTimer?.cancel();
    _expiryCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        for (final entry in state.activeSharings.entries) {
          if (entry.value.isExpired) {
            add(LiveLocationExpired(entry.key));
          }
        }
      },
    );
  }

  @override
  Future<void> close() {
    _locationUpdateTimer?.cancel();
    _expiryCheckTimer?.cancel();
    _liveLocationsSubscription?.cancel();
    return super.close();
  }
}
