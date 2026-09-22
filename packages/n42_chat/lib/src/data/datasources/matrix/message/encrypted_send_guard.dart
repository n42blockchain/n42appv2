import 'dart:async';
import 'package:collection/collection.dart';

import 'package:matrix/matrix.dart' as matrix;

import '../../../../core/utils/debug_log.dart';

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
    encGuardLog('prepare: room=${room.id} start');
    final guard = _instances[room.client] ??= EncryptedSendGuard();
    final pending = guard._preparing[room.id];
    if (pending != null) {
      encGuardLog('prepare: room=${room.id} reusing in-flight prepare');
      return pending;
    }
    final operation = guard
        ._prepareWithRetry(room)
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            encGuardLog('prepare: room=${room.id} timed out after 30s');
            throw const EncryptedSendNotReady();
          },
        )
        .onError(
          (Object error, StackTrace stack) {
            encGuardLog(
              'prepare: room=${room.id} failed with $error',
            );
            throw error is EncryptedSendNotReady
                ? error
                : const EncryptedSendNotReady();
          },
        );
    guard._preparing[room.id] = operation;
    try {
      await operation;
      encGuardLog('prepare: room=${room.id} ready');
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
        encGuardLog(
          'room=${room.id} attempt=$attempt failed '
          'retryable=${error.retryable} recipientKeysMissing='
          '${error.recipientKeysMissing}',
        );
        if (!error.retryable || attempt >= 1) rethrow;
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (room.client.userID != userId || room.client.deviceID != deviceId) {
          encGuardLog(
            'room=${room.id} aborting retry: client identity changed '
            '(userId $userId -> ${room.client.userID}, '
            'deviceId $deviceId -> ${room.client.deviceID})',
          );
          throw const EncryptedSendNotReady();
        }
        encGuardLog('room=${room.id} retrying (attempt ${attempt + 1})');
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
      encGuardLog(
        'room=${room.id} step=client-state fail userId=$userId '
        'deviceId=$deviceId encryptionEnabled=${client.encryptionEnabled} '
        'encryption=${encryption != null}',
      );
      throw const EncryptedSendNotReady();
    }
    await client.firstSyncReceived;
    encGuardLog('room=${room.id} step=firstSyncReceived ok');
    final members = await room.requestParticipants();
    final users =
        members
            .where((u) => u.membership == matrix.Membership.join)
            .map((u) => u.id)
            .toSet()
          ..add(userId);
    encGuardLog('room=${room.id} step=participants users=$users');
    // Force a refresh after a peer logs in on a new device. The SDK otherwise
    // may reuse its pre-login list until a later sync response arrives.
    for (final id in users) {
      client.userDeviceKeys[id]?.outdated = true;
    }
    await client.updateUserDeviceKeys(additionalUsers: users);
    final stillOutdated = users
        .where((id) => client.userDeviceKeys[id]?.outdated != false)
        .toList();
    if (stillOutdated.isNotEmpty) {
      encGuardLog(
        'room=${room.id} step=updateUserDeviceKeys fail still outdated: '
        '$stillOutdated',
      );
      throw const EncryptedSendNotReady(retryable: true);
    }
    final devices = await room.getUserDeviceKeys();
    encGuardLog(
      'room=${room.id} step=getUserDeviceKeys count=${devices.length} '
      'devices=${devices.map((d) => '${d.userId}/${d.deviceId}(blocked=${d.blocked},valid=${d.isValid},e2d=${d.encryptToDevice},hasKey=${d.curve25519Key != null})').toList()}',
    );
    for (final id in users) {
      final active = devices
          .where((d) => d.userId == id && !d.blocked)
          .toList();
      if (active.isEmpty) {
        encGuardLog(
          'room=${room.id} step=active-devices fail user=$id has no '
          'unblocked device (recipientKeysMissing=${id != userId})',
        );
        throw EncryptedSendNotReady(
          retryable: true,
          recipientKeysMissing: id != userId,
        );
      }
      if (active.any(
        (d) =>
            !d.isValid ||
            // The current device originates this session; the SDK excludes it
            // from delivery, while every destination must pass sharing policy.
            (!(d.userId == userId && d.deviceId == deviceId) &&
                !d.encryptToDevice) ||
            d.curve25519Key == null,
      )) {
        encGuardLog(
          'room=${room.id} step=active-devices fail user=$id has an '
          'invalid/non-e2d/keyless device',
        );
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
    if (missing.isNotEmpty) {
      encGuardLog(
        'room=${room.id} step=olm-sessions missing='
        '${missing.map((d) => '${d.userId}/${d.deviceId}').toList()}, '
        'starting outgoing sessions',
      );
      await olm.startOutgoingOlmSessions(missing);
    }
    final stillMissing = recipients
        .where((d) => olm.olmSessions[d.curve25519Key]?.isNotEmpty != true)
        .toList();
    if (stillMissing.isNotEmpty) {
      encGuardLog(
        'room=${room.id} step=olm-sessions fail still missing after '
        'startOutgoingOlmSessions: '
        '${stillMissing.map((d) => '${d.userId}/${d.deviceId}').toList()}',
      );
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
      encGuardLog(
        'room=${room.id} step=outbound-session device set changed, rotating',
      );
      await keys.clearOrUseOutboundGroupSession(
        room.id,
        wipe: true,
        use: false,
      );
    }
    await keys.prepareOutboundGroupSession(room.id);
    final session = keys.getOutboundGroupSession(room.id)?.outboundGroupSession;
    if (session == null) {
      encGuardLog('room=${room.id} step=outbound-session fail: null session');
      throw const EncryptedSendNotReady();
    }
    final fingerprint =
        '${session.sessionId}|${recipients.map((d) => '${d.userId}/${d.deviceId}/${d.curve25519Key}').join('|')}';
    if (_delivered[room.id] != fingerprint) {
      encGuardLog(
        'room=${room.id} step=sendToDeviceEncrypted sending room key to '
        '${recipients.length} recipients',
      );
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
      encGuardLog('room=${room.id} step=sendToDeviceEncrypted ok');
    }
    if (client.userID != userId ||
        client.deviceID != deviceId ||
        !client.isLogged()) {
      encGuardLog(
        'room=${room.id} step=final-identity-check fail '
        'userId $userId -> ${client.userID}, '
        'deviceId $deviceId -> ${client.deviceID}, '
        'isLogged=${client.isLogged()}',
      );
      throw const EncryptedSendNotReady();
    }
  }
}
