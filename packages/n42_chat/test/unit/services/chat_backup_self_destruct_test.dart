import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/chat_backup_service.dart';

/// Backups must not outlive the messages they contain: a self-destruct or
/// view-once message whose plaintext lands in a backup file would survive long
/// after it burned in-app. Export excludes them at the source; restore rejects
/// them on the way in, because the archive schema has no self-destruct column
/// that could catch them later.
void main() {
  group('backup restore rejects ephemeral entries', () {
    test('plain message entry is restorable', () {
      expect(
        ChatBackupService.isEphemeralBackupEntryForTest({
          'eventId': r'$e:example.org',
          'sender': '@a:example.org',
          'body': 'hello',
        }),
        isFalse,
      );
    });

    test('matrix-shaped self-destruct marker is rejected', () {
      expect(
        ChatBackupService.isEphemeralBackupEntryForTest({
          'eventId': r'$e:example.org',
          'n42.self_destruct': {'seconds': 30},
        }),
        isTrue,
      );
    });

    test('view-once marker is rejected', () {
      expect(
        ChatBackupService.isEphemeralBackupEntryForTest({
          'eventId': r'$e:example.org',
          'n42.self_destruct': {'after': 1},
        }),
        isTrue,
      );
    });

    test('legacy/alternate backup field spellings are rejected', () {
      expect(
        ChatBackupService.isEphemeralBackupEntryForTest({
          'selfDestruct': {'seconds': 10},
        }),
        isTrue,
      );
      expect(
        ChatBackupService.isEphemeralBackupEntryForTest({
          'isSelfDestructing': true,
        }),
        isTrue,
      );
      expect(
        ChatBackupService.isEphemeralBackupEntryForTest({'isViewOnce': true}),
        isTrue,
      );
    });

    test('explicitly false flags do not reject a normal message', () {
      expect(
        ChatBackupService.isEphemeralBackupEntryForTest({
          'eventId': r'$e:example.org',
          'isSelfDestructing': false,
          'isViewOnce': false,
        }),
        isFalse,
      );
    });
  });
}
