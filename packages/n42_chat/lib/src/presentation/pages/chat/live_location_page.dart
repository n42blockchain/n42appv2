import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/live_location_entity.dart';
import '../../blocs/live_location/live_location_bloc.dart';
import '../../blocs/live_location/live_location_event.dart';
import '../../blocs/live_location/live_location_state.dart';
import '../../widgets/common/common_widgets.dart';

/// 实时位置共享页面
class LiveLocationPage extends StatelessWidget {
  final String roomId;

  const LiveLocationPage({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LiveLocationBloc>(
      create: (_) => GetIt.instance<LiveLocationBloc>()
        ..add(ObserveLiveLocationRoom(roomId: roomId)),
      child: BlocBuilder<LiveLocationBloc, LiveLocationState>(
        builder: (context, state) {
          return _LiveLocationView(
            roomId: roomId,
            state: state,
          );
        },
      ),
    );
  }
}

class _LiveLocationView extends StatefulWidget {
  final String roomId;
  final LiveLocationState state;

  const _LiveLocationView({
    required this.roomId,
    required this.state,
  });

  @override
  State<_LiveLocationView> createState() => _LiveLocationViewState();
}

class _LiveLocationViewState extends State<_LiveLocationView> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// 计算所有用户位置的中心点
  LatLng _computeCenter() {
    final sharings = widget.state.activeSharings.values.toList();
    if (sharings.isEmpty) return const LatLng(0, 0);
    if (sharings.length == 1) {
      return LatLng(sharings.first.latitude, sharings.first.longitude);
    }
    double latSum = 0, lngSum = 0;
    for (final loc in sharings) {
      latSum += loc.latitude;
      lngSum += loc.longitude;
    }
    return LatLng(latSum / sharings.length, lngSum / sharings.length);
  }

  /// 为每个分享者生成 Marker
  List<Marker> _buildMarkers() {
    return widget.state.activeSharings.values.map((location) {
      return Marker(
        point: LatLng(location.latitude, location.longitude),
        width: 48,
        height: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: location.avatarUrl != null
                    ? Image.network(
                        location.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, e, st) => Center(
                          child: Text(
                            location.displayName.isNotEmpty
                                ? location.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          location.displayName.isNotEmpty
                              ? location.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final center = _computeCenter();
    final markers = _buildMarkers();

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        title: Text(
          S.of(context)?.liveLocation ?? 'Live Location',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 地图区域
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: widget.state.activeSharings.isEmpty ? 2.0 : 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.n42.wallet',
                ),
                if (markers.isNotEmpty)
                  MarkerLayer(markers: markers),
              ],
            ),
          ),

          // 底部面板
          _buildBottomPanel(context),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 共享者列表
            if (widget.state.activeSharings.isNotEmpty)
              ...widget.state.activeSharings.values.map(
                (location) => _buildSharingItem(context, location),
              ),

            // 开始/停止共享按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: widget.state.isSharing
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context
                              .read<LiveLocationBloc>()
                              .add(StopLiveLocation(roomId: widget.roomId));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                            S.of(context)?.stopLiveLocation ??
                                'Stop Sharing'),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            _showDurationPicker(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                            S.of(context)?.startLiveLocation ??
                                'Share My Location'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharingItem(BuildContext context, LiveLocationEntity location) {
    return ListTile(
      leading: N42Avatar(
        imageUrl: location.avatarUrl,
        name: location.displayName,
        size: 40,
      ),
      title: Text(
        location.displayName,
        style: TextStyle(
          color: context.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _formatRemaining(context, location),
        style: TextStyle(
          color: context.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.my_location,
        color: AppColors.primary,
        size: 20,
      ),
      onTap: () {
        // 点击用户名片时移动地图到该用户位置
        _mapController.move(
          LatLng(location.latitude, location.longitude),
          15.0,
        );
      },
    );
  }

  String _formatRemaining(BuildContext context, LiveLocationEntity location) {
    final data = location.remainingTimeData;
    final l10n = S.of(context);
    switch (data.type) {
      case 'expired':
        return l10n?.locationExpired ?? 'Expired';
      case 'seconds':
        return l10n?.secondsRemaining(data.values[0]) ?? '${data.values[0]}s';
      case 'minutes':
        return l10n?.minutesRemaining(data.values[0]) ?? '${data.values[0]}min';
      case 'hoursMinutes':
        return l10n?.hoursMinutesRemaining(data.values[0], data.values[1]) ?? '${data.values[0]}h ${data.values[1]}min';
      default:
        return '';
    }
  }

  void _showDurationPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                S.of(context)?.selectDuration ?? 'Select Duration',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              title: Text(S.of(context)?.minutes15 ?? '15 minutes'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<LiveLocationBloc>().add(
                      StartLiveLocation(roomId: widget.roomId, durationMinutes: 15),
                    );
              },
            ),
            ListTile(
              title: Text(S.of(context)?.minutes30 ?? '30 minutes'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<LiveLocationBloc>().add(
                      StartLiveLocation(roomId: widget.roomId, durationMinutes: 30),
                    );
              },
            ),
            ListTile(
              title: Text(S.of(context)?.hour1 ?? '1 hour'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<LiveLocationBloc>().add(
                      StartLiveLocation(roomId: widget.roomId, durationMinutes: 60),
                    );
              },
            ),
            ListTile(
              title: Text(S.of(context)?.hours8 ?? '8 hours'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<LiveLocationBloc>().add(
                      StartLiveLocation(roomId: widget.roomId, durationMinutes: 480),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
