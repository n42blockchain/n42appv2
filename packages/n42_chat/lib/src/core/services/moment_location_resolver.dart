import 'package:geocoding/geocoding.dart';

import '../../domain/entities/moment_entity.dart';

/// Resolve a human-readable address without losing coordinates if lookup fails.
Future<MomentLocation> resolveMomentLocation(
  double latitude,
  double longitude,
) async {
  try {
    final places = await placemarkFromCoordinates(
      latitude,
      longitude,
    ).timeout(const Duration(seconds: 8));
    if (places.isNotEmpty) {
      final place = places.first;
      final parts = <String>{};
      for (final value in [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ]) {
        if (value != null && value.trim().isNotEmpty) parts.add(value.trim());
      }
      final address = parts.join(', ');
      final label = address.isNotEmpty ? address : place.name?.trim();
      if (label != null && label.isNotEmpty) {
        return MomentLocation(
          latitude: latitude,
          longitude: longitude,
          name: label,
          address: label,
        );
      }
    }
  } catch (_) {
    // Offline/geocoder-unavailable fallback preserves the selected coordinate.
  }
  return MomentLocation(latitude: latitude, longitude: longitude);
}
