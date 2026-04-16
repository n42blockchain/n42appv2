// Tests for BackupEvent subclasses in backup_event.dart.
// Pure Dart Equatable event classes — no platform deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/backup/backup_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // LoadBackupList
  // ─────────────────────────────────────────────────

  group('LoadBackupList', () {
    test('is a BackupEvent', () {
      expect(const LoadBackupList(), isA<BackupEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadBackupList(), equals(const LoadBackupList()));
    });
  });

  // ─────────────────────────────────────────────────
  // CreateBackup
  // ─────────────────────────────────────────────────

  group('CreateBackup', () {
    test('defaults: roomIds=null, includeMedia=false, includeKeys=false, password=null', () {
      const e = CreateBackup();
      expect(e.roomIds, isNull);
      expect(e.includeMedia, isFalse);
      expect(e.includeKeys, isFalse);
      expect(e.password, isNull);
    });

    test('stores all optional fields', () {
      const e = CreateBackup(
        roomIds: ['!r1:s', '!r2:s'],
        includeMedia: true,
        includeKeys: true,
        password: 'secret',
      );
      expect(e.roomIds, ['!r1:s', '!r2:s']);
      expect(e.includeMedia, isTrue);
      expect(e.includeKeys, isTrue);
      expect(e.password, 'secret');
    });

    test('same fields → equal', () {
      expect(
        const CreateBackup(includeMedia: true),
        equals(const CreateBackup(includeMedia: true)),
      );
    });

    test('different includeMedia → not equal', () {
      expect(
        const CreateBackup(includeMedia: true),
        isNot(equals(const CreateBackup(includeMedia: false))),
      );
    });

    test('different password → not equal', () {
      expect(
        const CreateBackup(password: 'a'),
        isNot(equals(const CreateBackup(password: 'b'))),
      );
    });

    test('is a BackupEvent', () {
      expect(const CreateBackup(), isA<BackupEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // DeleteBackup
  // ─────────────────────────────────────────────────

  group('DeleteBackup', () {
    test('stores backupId', () {
      const e = DeleteBackup('backup_001');
      expect(e.backupId, 'backup_001');
    });

    test('same id → equal', () {
      expect(const DeleteBackup('id'), equals(const DeleteBackup('id')));
    });

    test('different id → not equal', () {
      expect(
        const DeleteBackup('a'),
        isNot(equals(const DeleteBackup('b'))),
      );
    });

    test('is a BackupEvent', () {
      expect(const DeleteBackup('id'), isA<BackupEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // PreviewBackup
  // ─────────────────────────────────────────────────

  group('PreviewBackup', () {
    test('stores filePath', () {
      const e = PreviewBackup(filePath: '/path/to/backup.zip');
      expect(e.filePath, '/path/to/backup.zip');
    });

    test('password defaults to null', () {
      const e = PreviewBackup(filePath: '/path/to/backup.zip');
      expect(e.password, isNull);
    });

    test('stores password when provided', () {
      const e = PreviewBackup(filePath: '/path/to/backup.zip', password: 'abc');
      expect(e.password, 'abc');
    });

    test('same fields → equal', () {
      expect(
        const PreviewBackup(filePath: '/p', password: 'pw'),
        equals(const PreviewBackup(filePath: '/p', password: 'pw')),
      );
    });

    test('different filePath → not equal', () {
      expect(
        const PreviewBackup(filePath: '/a'),
        isNot(equals(const PreviewBackup(filePath: '/b'))),
      );
    });

    test('is a BackupEvent', () {
      expect(const PreviewBackup(filePath: '/p'), isA<BackupEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // RestoreFromBackup
  // ─────────────────────────────────────────────────

  group('RestoreFromBackup', () {
    test('stores backupFilePath', () {
      const e = RestoreFromBackup(backupFilePath: '/path/backup.zip');
      expect(e.backupFilePath, '/path/backup.zip');
    });

    test('defaults: password=null, roomIds=null, restoreSettings=true, restoreKeys=false', () {
      const e = RestoreFromBackup(backupFilePath: '/path');
      expect(e.password, isNull);
      expect(e.roomIds, isNull);
      expect(e.restoreSettings, isTrue);
      expect(e.restoreKeys, isFalse);
    });

    test('stores all fields', () {
      const e = RestoreFromBackup(
        backupFilePath: '/path',
        password: 'pw',
        roomIds: ['!r:s'],
        restoreSettings: false,
        restoreKeys: true,
      );
      expect(e.password, 'pw');
      expect(e.roomIds, ['!r:s']);
      expect(e.restoreSettings, isFalse);
      expect(e.restoreKeys, isTrue);
    });

    test('same fields → equal', () {
      expect(
        const RestoreFromBackup(backupFilePath: '/p', restoreKeys: true),
        equals(const RestoreFromBackup(backupFilePath: '/p', restoreKeys: true)),
      );
    });

    test('is a BackupEvent', () {
      expect(
        const RestoreFromBackup(backupFilePath: '/p'),
        isA<BackupEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // EstimateBackupSize
  // ─────────────────────────────────────────────────

  group('EstimateBackupSize', () {
    test('roomIds defaults to null', () {
      const e = EstimateBackupSize();
      expect(e.roomIds, isNull);
    });

    test('includeMedia defaults to false', () {
      expect(const EstimateBackupSize().includeMedia, isFalse);
    });

    test('stores includeMedia=true', () {
      const e = EstimateBackupSize(includeMedia: true);
      expect(e.includeMedia, isTrue);
    });

    test('same fields → equal', () {
      expect(
        const EstimateBackupSize(includeMedia: true),
        equals(const EstimateBackupSize(includeMedia: true)),
      );
    });

    test('is a BackupEvent', () {
      expect(const EstimateBackupSize(), isA<BackupEvent>());
    });
  });
}
