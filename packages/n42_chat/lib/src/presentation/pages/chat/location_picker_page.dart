import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/debug_log.dart';

/// 位置选择页面（微信风格）
class ChatLocationPickerPage extends StatefulWidget {
  const ChatLocationPickerPage({super.key});

  @override
  State<ChatLocationPickerPage> createState() => _ChatLocationPickerPageState();
}

class _ChatLocationPickerPageState extends State<ChatLocationPickerPage> {
  Position? _currentPosition;
  String _currentAddress = 'Getting location...';
  bool _isLoading = true;
  String? _errorMessage;

  // 地图控制器
  final MapController _mapController = MapController();

  // 地图中心点（拖动地图时更新）
  LatLng? _mapCenter;

  // 附近地点列表
  List<NearbyPlace> _nearbyPlaces = [];
  int _selectedPlaceIndex = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 检查位置服务
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _errorMessage = S.of(context)?.chatLocationServiceNotEnabled ?? 'Location service not enabled';
        });
        return;
      }

      // 检查权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _errorMessage = S.of(context)?.chatLocationPermissionDenied ?? 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _errorMessage = S.of(context)?.chatLocationPermissionDeniedPermanent ?? 'Location permission permanently denied';
        });
        return;
      }

      // 获取当前位置
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _mapCenter = LatLng(position.latitude, position.longitude);
      });

      // 获取地址
      await _getAddressFromPosition(position);

      // 生成附近地点
      _generateNearbyPlaces(position);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = S.of(context)?.chatGetLocationFailed(e.toString()) ?? 'Failed to get location: $e';
      });
    }
  }

  Future<void> _getAddressFromPosition(Position position) async {
    try {
      setState(() {
        _currentAddress = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      debugLog('Get address error: $e');
    }
  }

  /// 搜索地点（使用 geocoding）
  Timer? _searchDebounce;

  void _searchPlaces(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      // 清空搜索时恢复附近地点
      if (_currentPosition != null) {
        setState(() => _generateNearbyPlaces(_currentPosition!));
      }
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final locations = await geocoding.locationFromAddress(query);
        if (!mounted) return;

        final results = <NearbyPlace>[];
        for (final loc in locations.take(5)) {
          final placemarks = await geocoding.placemarkFromCoordinates(
            loc.latitude,
            loc.longitude,
          );
          final pm = placemarks.isNotEmpty ? placemarks.first : null;
          results.add(NearbyPlace(
            name: pm?.name ?? query,
            address: [pm?.street, pm?.locality, pm?.country]
                .where((s) => s != null && s.isNotEmpty)
                .join(', '),
            latitude: loc.latitude,
            longitude: loc.longitude,
            icon: Icons.location_on,
            iconColor: AppColors.primary,
          ));
        }

        if (mounted) {
          setState(() {
            _nearbyPlaces = results;
            _selectedPlaceIndex = 0;
          });
          // 移动地图到第一个搜索结果
          if (results.isNotEmpty) {
            _mapController.move(
              LatLng(results.first.latitude, results.first.longitude),
              15.0,
            );
          }
        }
      } catch (e) {
        debugLog('Place search error: $e');
      }
    });
  }

  void _generateNearbyPlaces(Position position) {
    final l10n = S.of(context);
    final myLocation = l10n?.chatMyLocation ?? 'My Location';
    final currentLocation = l10n?.chatCurrentLocation ?? 'Current Location';

    _nearbyPlaces = [
      NearbyPlace(
        name: myLocation,
        address: _currentAddress,
        latitude: position.latitude,
        longitude: position.longitude,
        icon: Icons.my_location,
        iconColor: AppColors.primary,
      ),
      NearbyPlace(
        name: currentLocation,
        address: '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
        latitude: position.latitude,
        longitude: position.longitude,
        icon: Icons.location_on,
        iconColor: AppColors.error,
      ),
      NearbyPlace(
        name: l10n?.chatNearbyPlace(1) ?? 'Nearby Place 1',
        address: l10n?.chatApproximateDistance('100m') ?? 'About 100m',
        latitude: position.latitude + 0.001,
        longitude: position.longitude + 0.001,
        icon: Icons.place,
        iconColor: AppColors.warning,
      ),
      NearbyPlace(
        name: l10n?.chatNearbyPlace(2) ?? 'Nearby Place 2',
        address: l10n?.chatApproximateDistance('200m') ?? 'About 200m',
        latitude: position.latitude - 0.001,
        longitude: position.longitude + 0.002,
        icon: Icons.place,
        iconColor: AppColors.warning,
      ),
      NearbyPlace(
        name: l10n?.chatNearbyPlace(3) ?? 'Nearby Place 3',
        address: l10n?.chatApproximateDistance('500m') ?? 'About 500m',
        latitude: position.latitude + 0.002,
        longitude: position.longitude - 0.002,
        icon: Icons.place,
        iconColor: AppColors.warning,
      ),
    ];
  }

  void _confirmLocation() {
    if (_currentPosition == null) return;

    final selectedPlace = _nearbyPlaces.isNotEmpty
        ? _nearbyPlaces[_selectedPlaceIndex]
        : null;

    Navigator.pop(context, {
      'latitude': selectedPlace?.latitude ?? _currentPosition!.latitude,
      'longitude': selectedPlace?.longitude ?? _currentPosition!.longitude,
      'address': _currentAddress,
      'name': selectedPlace?.name ?? (S.of(context)?.chatMyLocation ?? 'My Location'),
    });
  }

  void _moveToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.surfaceColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: context.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context)?.chatLocationTitle ?? 'Location',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _currentPosition != null ? _confirmLocation : null,
            child: Text(
              S.of(context)?.chatSendButton ?? 'Send',
              style: TextStyle(
                color: _currentPosition != null
                    ? AppColors.primary
                    : context.textTertiary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(S.of(context)?.chatGettingLocation ?? 'Getting location...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: context.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: context.textTertiary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _getCurrentLocation,
                        child: Text(S.of(context)?.commonRetry ?? 'Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // 地图预览区域 - 交互式 FlutterMap
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _mapCenter ?? const LatLng(0, 0),
                              initialZoom: 15.0,
                              onPositionChanged: (pos, hasGesture) {
                                if (hasGesture) {
                                  _mapCenter = pos.center;
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.n42.wallet',
                              ),
                            ],
                          ),
                          // 中心固定 pin（地图拖动时 pin 不动）
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Icon(
                                Icons.location_on,
                                color: AppColors.error,
                                size: 40,
                              ),
                            ),
                          ),
                          // 重新定位按钮
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FloatingActionButton.small(
                              heroTag: 'relocate',
                              onPressed: _moveToCurrentLocation,
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.my_location,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 搜索框
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: context.surfaceColor,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: S.of(context)?.chatSearchLocation ?? 'Search location',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppColors.inputBgOf(isDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          _searchPlaces(value);
                        },
                      ),
                    ),
                    // 附近地点列表
                    Expanded(
                      child: ListView.builder(
                        itemCount: _nearbyPlaces.length,
                        itemBuilder: (context, index) {
                          final place = _nearbyPlaces[index];
                          final isSelected = index == _selectedPlaceIndex;

                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: place.iconColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                place.icon,
                                color: place.iconColor,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              place.name,
                              style: TextStyle(
                                color: context.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              place.address,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedPlaceIndex = index;
                              });
                              // 移动地图到选中的地点
                              _mapController.move(
                                LatLng(place.latitude, place.longitude),
                                15.0,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

/// 附近地点数据类
class NearbyPlace {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final IconData icon;
  final Color iconColor;

  NearbyPlace({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.icon,
    required this.iconColor,
  });
}

/// 位置详情页面 - 微信/WhatsApp风格
class ChatLocationDetailPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const ChatLocationDetailPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<ChatLocationDetailPage> createState() => _ChatLocationDetailPageState();
}

class _ChatLocationDetailPageState extends State<ChatLocationDetailPage> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final center = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: Stack(
        children: [
          // 全屏地图
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.n42.wallet',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 56,
                      height: 56,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 顶部导航栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 底部位置信息卡片
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 拖动指示条
                      Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: context.dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // 位置信息
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.locationName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // 操作按钮
                      Row(
                        children: [
                          // 复制坐标
                          Expanded(
                            child: _LocationActionButton(
                              icon: Icons.copy_rounded,
                              label: S.of(context)?.chatCopy ?? 'Copy',
                              isDark: isDark,
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: '${widget.latitude}, ${widget.longitude}'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(S.of(context)?.commonAddressCopied ?? 'Coordinates copied'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 在地图中打开
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final url = 'https://maps.google.com/?q=${widget.latitude},${widget.longitude}';
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              icon: const Icon(Icons.navigation_rounded, size: 20),
                              label: Text(S.of(context)?.chatMapPreview ?? 'Open in Maps'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 位置详情页面的操作按钮
class _LocationActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _LocationActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgOf(isDark),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: context.textPrimary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
