import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/friendly_display_name.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/moment_entity.dart';
import '../../../domain/repositories/moment_repository.dart';
import '../../../n42_chat.dart';
import '../../widgets/common/common_widgets.dart';

/// A coarse coordinate used by Nearby. Keeping the location loader injectable
/// makes the privacy and sorting behaviour testable without a platform plugin.
class NearbyCoordinate {
  final double latitude;
  final double longitude;

  const NearbyCoordinate(this.latitude, this.longitude);
}

typedef NearbyLocationLoader = Future<NearbyCoordinate> Function();

/// Privacy-preserving nearby discovery.
///
/// N42 does not publish continuous device presence. The page only reads the
/// current location after an explicit tap and compares it with locations that
/// people deliberately attached to *public* Moments. Exact coordinates are
/// never rendered; only rounded distance bands are shown.
class NearbyPage extends StatefulWidget {
  final IMomentRepository? momentRepository;
  final NearbyLocationLoader? locationLoader;

  const NearbyPage({super.key, this.momentRepository, this.locationLoader});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  bool _enabled = false;
  bool _loading = false;
  String? _error;
  List<_NearbyPerson> _people = const [];

  IMomentRepository get _repository =>
      widget.momentRepository ?? getIt<IMomentRepository>();

  Future<void> _enableAndLoad() async {
    setState(() {
      _enabled = true;
      _loading = true;
      _error = null;
    });

    try {
      final current = await (widget.locationLoader ?? _loadDeviceLocation)();
      final moments = await _repository.getMoments(limit: 100);
      final latestByUser = <String, _NearbyPerson>{};

      for (final moment in moments) {
        final location = moment.location;
        if (location == null ||
            moment.isDeleted ||
            moment.visibility != MomentVisibility.public ||
            moment.userId.isEmpty) {
          continue;
        }

        final distance = Geolocator.distanceBetween(
          current.latitude,
          current.longitude,
          location.latitude,
          location.longitude,
        );
        final candidate = _NearbyPerson(
          moment: moment,
          distanceMeters: distance,
        );
        final existing = latestByUser[moment.userId];
        if (existing == null ||
            moment.timestamp.isAfter(existing.moment.timestamp)) {
          latestByUser[moment.userId] = candidate;
        }
      }

      final people = latestByUser.values.toList()
        ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      if (!mounted) return;
      setState(() {
        _people = people;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<NearbyCoordinate> _loadDeviceLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location Services are turned off');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Enable location permission in system settings');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return NearbyCoordinate(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final title = S.of(context)?.discoverNearbyPeople ?? 'Nearby';
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: title,
        actions: [
          if (_enabled)
            IconButton(
              tooltip: 'Refresh',
              onPressed: _loading ? null : _enableAndLoad,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: !_enabled ? _buildPrivacyGate(context) : _buildResults(context),
    );
  }

  Widget _buildPrivacyGate(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.near_me_outlined,
                color: AppColors.primary,
                size: 42,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Discover nearby public posts',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your location is used once on this device to sort public Moments. '
              'It is not uploaded, broadcast, or shown to other people.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 15,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey('nearby-enable'),
                onPressed: _enableAndLoad,
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Use my location'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _NearbyMessage(
        icon: Icons.location_off_outlined,
        title: 'Nearby is unavailable',
        message: _error!,
        actionLabel: 'Try again',
        onAction: _enableAndLoad,
      );
    }
    if (_people.isEmpty) {
      return const _NearbyMessage(
        icon: Icons.people_outline,
        title: 'No nearby posts yet',
        message: 'Public Moments with a location will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _enableAndLoad,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _people.length + 1,
        separatorBuilder: (_, index) => index == 0
            ? const SizedBox.shrink()
            : Divider(height: 1, indent: 80, color: context.dividerColor),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              color: AppColors.primary.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Approximate distance · public location posts only',
                style: TextStyle(color: context.textSecondary, fontSize: 12),
              ),
            );
          }
          final person = _people[index - 1];
          final friendlyName = FriendlyDisplayName.resolve(
            displayName: person.moment.userName,
            userId: person.moment.userId,
          );
          return ListTile(
            key: ValueKey('nearby-${person.moment.userId}'),
            leading: N42Avatar(
              name: friendlyName,
              imageUrl: person.moment.userAvatarUrl,
              size: 48,
            ),
            title: Text(
              friendlyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              person.moment.content?.trim().isNotEmpty == true
                  ? person.moment.content!.trim()
                  : 'Public location post',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              _formatDistance(person.distanceMeters),
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
            onTap: () =>
                N42Chat.openUserProfile(person.moment.userId, context: context),
          );
        },
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 100) return '<100 m';
    if (meters < 1000) return '${(meters / 100).round() * 100} m';
    if (meters < 10000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${(meters / 1000).round()} km';
  }
}

class _NearbyPerson {
  final MomentEntity moment;
  final double distanceMeters;

  const _NearbyPerson({required this.moment, required this.distanceMeters});
}

class _NearbyMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _NearbyMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSecondary, height: 1.4),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
