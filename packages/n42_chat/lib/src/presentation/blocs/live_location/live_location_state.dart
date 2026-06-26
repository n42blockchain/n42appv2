import 'package:equatable/equatable.dart';

import '../../../domain/entities/live_location_entity.dart';

class LiveLocationState extends Equatable {
  static const _sentinel = Object();

  final Map<String, LiveLocationEntity> activeSharings;
  final bool isSharing;
  final String? currentRoomId;
  final double? myLatitude;
  final double? myLongitude;
  final String? error;

  const LiveLocationState({
    this.activeSharings = const {},
    this.isSharing = false,
    this.currentRoomId,
    this.myLatitude,
    this.myLongitude,
    this.error,
  });

  LiveLocationState copyWith({
    Map<String, LiveLocationEntity>? activeSharings,
    bool? isSharing,
    Object? currentRoomId = _sentinel,
    Object? myLatitude = _sentinel,
    Object? myLongitude = _sentinel,
    String? error,
  }) {
    return LiveLocationState(
      activeSharings: activeSharings ?? this.activeSharings,
      isSharing: isSharing ?? this.isSharing,
      currentRoomId: currentRoomId == _sentinel
          ? this.currentRoomId
          : currentRoomId as String?,
      myLatitude: myLatitude == _sentinel
          ? this.myLatitude
          : myLatitude as double?,
      myLongitude: myLongitude == _sentinel
          ? this.myLongitude
          : myLongitude as double?,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        activeSharings,
        isSharing,
        currentRoomId,
        myLatitude,
        myLongitude,
        error,
      ];
}
