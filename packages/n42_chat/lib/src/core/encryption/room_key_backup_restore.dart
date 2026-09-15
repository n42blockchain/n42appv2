import 'package:matrix/matrix.dart';

/// Restore and verify the downloaded sessions. The SDK may silently skip
/// locked, mismatched or undecryptable backups, so a completed HTTP request is
/// not by itself evidence that historical messages can be decrypted.
Future<int> restoreRoomKeyBackup(Client client) async {
  final keys = client.encryption?.keyManager;
  if (keys == null || !await keys.isCached()) {
    throw StateError('Unlock the room-key backup before restoring messages');
  }
  final info = await keys.getRoomKeysBackupInfo();
  final backup = await client.getRoomKeys(info.version);
  await keys.loadFromResponse(backup);
  var restored = 0;
  for (final room in backup.rooms.entries) {
    for (final sessionId in room.value.sessions.keys) {
      final session = await keys.loadInboundGroupSession(room.key, sessionId);
      if (session?.isValid != true) {
        throw StateError('Some room keys could not be restored');
      }
      restored++;
    }
  }
  return restored;
}
