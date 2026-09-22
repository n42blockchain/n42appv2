import 'package:matrix/matrix.dart';

/// A newly issued token can bootstrap a device only before that device has
/// published an encryption identity. A token cannot replace lost private keys.
/// The token cannot safely resume its original encryption identity.
class SessionReauthenticationRequired extends StateError {
  SessionReauthenticationRequired(super.message);
}

Future<void> validateFreshTokenDevice(
  MatrixApi api,
  String userId,
  String deviceId,
) async {
  final owner = await api.getTokenOwner().timeout(const Duration(seconds: 20));
  if (owner.userId != userId || owner.deviceId != deviceId) {
    throw SessionReauthenticationRequired(
      'Token does not belong to the requested account device',
    );
  }
  final keys = await api
      .queryKeys({
        userId: [deviceId],
      }, timeout: 10000)
      .timeout(const Duration(seconds: 20));
  if (keys.failures?.isNotEmpty == true ||
      keys.deviceKeys == null ||
      keys.deviceKeys?[userId]?.containsKey(deviceId) == true) {
    throw SessionReauthenticationRequired(
      'Stored device encryption session unavailable; sign in again',
    );
  }
}
