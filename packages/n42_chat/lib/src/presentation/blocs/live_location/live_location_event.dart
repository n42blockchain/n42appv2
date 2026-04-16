import 'package:equatable/equatable.dart';

import '../../../domain/entities/live_location_entity.dart';

abstract class LiveLocationEvent extends Equatable {
  const LiveLocationEvent();

  @override
  List<Object?> get props => [];
}

/// 开始共享实时位置
class ObserveLiveLocationRoom extends LiveLocationEvent {
  final String roomId;

  const ObserveLiveLocationRoom({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

/// 开始共享实时位置
class StartLiveLocation extends LiveLocationEvent {
  final String roomId;
  final int durationMinutes;

  const StartLiveLocation({
    required this.roomId,
    required this.durationMinutes,
  });

  @override
  List<Object?> get props => [roomId, durationMinutes];
}

/// 停止共享实时位置
class StopLiveLocation extends LiveLocationEvent {
  final String roomId;

  const StopLiveLocation({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

/// 更新自己的位置
class UpdateMyLocation extends LiveLocationEvent {
  final double latitude;
  final double longitude;
  final double? accuracy;

  const UpdateMyLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracy];
}

/// 收到其他用户的位置更新
class LiveLocationUpdated extends LiveLocationEvent {
  final LiveLocationEntity location;

  const LiveLocationUpdated(this.location);

  @override
  List<Object?> get props => [location];
}

/// 位置快照同步
class LiveLocationSnapshotReceived extends LiveLocationEvent {
  final String roomId;
  final List<LiveLocationEntity> locations;

  const LiveLocationSnapshotReceived({
    required this.roomId,
    required this.locations,
  });

  @override
  List<Object?> get props => [roomId, locations];
}

/// 位置共享过期
class LiveLocationExpired extends LiveLocationEvent {
  final String userId;

  const LiveLocationExpired(this.userId);

  @override
  List<Object?> get props => [userId];
}
