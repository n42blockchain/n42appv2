import 'dart:async';
import 'package:collection/collection.dart';

import 'package:matrix/matrix.dart' as matrix;

class EncryptedSendNotReady implements Exception {
  static const code = 'n42.encryption_not_ready';
  static const recipientMissingCode = '$code.recipient_keys_missing';
  final bool retryable;
  final bool recipientKeysMissing;
  const EncryptedSendNotReady({
    this.retryable = false,
    this.recipientKeysMissing = false,
  });
  @override
  String toString() => recipientKeysMissing ? recipientMissingCode : code;
}

/// Establish key delivery before publishing encrypted content. Never downgrade
/// the room to plaintext or trust devices rejected by the configured policy.
class EncryptedSendGuard {
  static final _instances = Expando<EncryptedSendGuard>();
  static Future<void> prepare(matrix.Room room) async {
    if (!room.encrypted) return;
    final guard = _instances[room.client] ??= EncryptedSendGuard();
    final pending = guard._preparing[room.id];
    if (pending != null) return pending;
    final operation = guard
        ._prepareWithRetry(room)
        .timeout(const Duration(seconds: 30))
        .onError(
          (Object error, StackTrace stack) =>
              throw error is EncryptedSendNotReady
                  ? error
                  : const EncryptedSendNotReady(),
        );
    guard._preparing[room.id] = operation;
    try {
      await operation;
    } on EncryptedSendNotReady {
      rethrow;
    } catch (_) {
      throw const EncryptedSendNotReady();
    } finally {
      if (identical(guard._preparing[room.id], operation))
        guard._preparing.remove(room.id);
    }
  }

  final Map<String, Future<void>> _preparing = {};

  Future<void> _prepareWithRetry(matrix.Room room) async {
    final userId = room.client.userID;
    final deviceId = room.client.deviceID;
    for (var attempt = 0; ; attempt++) {
      try {
        await _prepare(room);
        return;
      } on EncryptedSendNotReady catch (error) {
        if (!error.retryable || attempt >= 1) rethrow;
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (room.client.userID != userId || room.client.deviceID != deviceId) {
          throw const EncryptedSendNotReady();
        }
      }
    }
  }

  final Map<String, String> _delivered = {};

  Future<void> _prepare(matrix.Room room) async {
    final client = room.client;
    final userId = client.userID;
    final deviceId = client.deviceID;
    final encryption = client.encryption;
    if (userId == null ||
        deviceId == null ||
        !client.encryptionEnabled ||
        encryption == null) {
      throw const EncryptedSendNotReady();
    }
    await client.firstSyncReceived;
    final members = await room.requestParticipants();
    final users =
        members
            .where((u) => u.membership == matrix.Membership.join)
            .map((u) => u.id)
            .toSet()
          ..add(userId);
    // Force a refresh after a peer logs in on a new device. The SDK otherwise
    // may reuse its pre-login list until a later sync response arrives.
    for (final id in users) {
      client.userDeviceKeys[id]?.outdated = true;
    }
    await client.updateUserDeviceKeys(additionalUsers: users);
    if (users.any((id) => client.userDeviceKeys[id]?.outdated != false)) {
      throw const EncryptedSendNotReady(retryable: true);
    }
    final devices = await room.getUserDeviceKeys();
    for (final id in users) {
      final active = devices
          .where((d) => d.userId == id && !d.blocked)
          .toList();
      if (active.isEmpty)
        throw EncryptedSendNotReady(
          retryable: true,
          recipientKeysMissing: id != userId,
        );
      if (active.any(
        (d) =>
            !d.isValid ||
            // The current device originates this session; the SDK excludes it
            // from delivery, while every destination must pass sharing policy.
            (!(d.userId == userId && d.deviceId == deviceId) &&
                !d.encryptToDevice) ||
            d.curve25519Key == null,
      )) {
        throw const EncryptedSendNotReady();
      }
    }
    final recipients = devices
        .where(
          (d) =>
              users.contains(d.userId) &&
              !d.blocked &&
              !(d.userId == userId && d.deviceId == deviceId),
        )
        .toList();
    final olm = encryption.olmManager;
    await olm.getOlmSessionsForDevicesFromDatabase(
      recipients.map((d) => d.curve25519Key!).toList(),
    );
    final missing = recipients
        .where((d) => olm.olmSessions[d.curve25519Key]?.isNotEmpty != true)
        .toList();
    if (missing.isNotEmpty) await olm.startOutgoingOlmSessions(missing);
    if (recipients.any(
      (d) => olm.olmSessions[d.curve25519Key]?.isNotEmpty != true,
    )) {
      throw const EncryptedSendNotReady(retryable: true);
    }
    final keys = encryption.keyManager;
    await keys.loadOutboundGroupSession(room.id);
    final existing = keys.getOutboundGroupSession(room.id);
    final targetMap = <String, Map<String, bool>>{};
    for (final d in devices) {
      if (d.deviceId != null)
        (targetMap[d.userId] ??= {})[d.deviceId!] = !d.encryptToDevice;
    }
    if (existing != null &&
        !const DeepCollectionEquality().equals(existing.devices, targetMap)) {
      // SDK incremental key re-sharing catches transport errors internally.
      // Rotate instead, so a failed distribution cannot be marked as delivered.
      await keys.clearOrUseOutboundGroupSession(
        room.id,
        wipe: true,
        use: false,
      );
    }
    await keys.prepareOutboundGroupSession(room.id);
    final session = keys.getOutboundGroupSession(room.id)?.outboundGroupSession;
    if (session == null) throw const EncryptedSendNotReady();
    final fingerprint =
        '${session.sessionId}|${recipients.map((d) => '${d.userId}/${d.deviceId}/${d.curve25519Key}').join('|')}';
    if (_delivered[room.id] != fingerprint) {
      // Await all recipients, including devices beyond the SDK's first chunk.
      await client.sendToDeviceEncrypted(
        List.of(recipients),
        matrix.EventTypes.RoomKey,
        {
          'algorithm': matrix.AlgorithmTypes.megolmV1AesSha2,
          'room_id': room.id,
          'session_id': session.sessionId,
          'session_key': session.sessionKey,
        },
      );
      _delivered[room.id] = fingerprint;
    }
    if (client.userID != userId ||
        client.deviceID != deviceId ||
        !client.isLogged()) {
      throw const EncryptedSendNotReady();
    }
  }
}
