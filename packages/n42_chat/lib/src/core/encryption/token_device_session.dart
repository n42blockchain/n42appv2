import 'package:matrix/matrix.dart';

/// A newly issued token can bootstrap a device only before that device has
/// published an encryption identity. A token cannot replace lost private keys.
Future<void> validateFreshTokenDevice(
  MatrixApi api,
  String userId,
  String deviceId,
) async {
  final owner = await api.getTokenOwner().timeout(const Duration(seconds: 20));
  if (owner.userId != userId || owner.deviceId != deviceId) {
    throw StateError('Token does not belong to the requested account device');
  }
  final keys = await api
      .queryKeys({
        userId: [deviceId],
      })
      .timeout(const Duration(seconds: 20));
  if (keys.failures?.isNotEmpty == true ||
      keys.deviceKeys == null ||
      keys.deviceKeys?[userId]?.containsKey(deviceId) == true) {
    throw StateError(
      'Stored device encryption session unavailable; sign in again',
    );
  }
}
