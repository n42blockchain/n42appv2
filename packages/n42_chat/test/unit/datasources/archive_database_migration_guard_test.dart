import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/data/datasources/local/archive_database.dart';

void main() {
  group('archive migration guards', () {
    test('accepts only a 256-bit hexadecimal passphrase', () {
      expect(
        isValidArchivePassphraseForTest(List.filled(64, 'a').join()),
        isTrue,
      );
      expect(
        isValidArchivePassphraseForTest(List.filled(32, 'F0').join()),
        isTrue,
      );
      expect(
        isValidArchivePassphraseForTest(List.filled(64, 'g').join()),
        isFalse,
      );
      expect(
        isValidArchivePassphraseForTest(List.filled(63, 'a').join()),
        isFalse,
      );
    });

    test('restores a backup left before encrypted replacement', () async {
      final directory = await Directory.systemTemp.createTemp(
        'n42_archive_recovery_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final archive = File('${directory.path}/archive.db');
      final backup = File('${archive.path}.plaintext.bak');
      await backup.writeAsString('plaintext history');

      recoverInterruptedArchiveMigrationForTest(archive);

      expect(await archive.readAsString(), 'plaintext history');
      expect(backup.existsSync(), isFalse);
    });

    test('rolls back when encrypted replacement cannot be installed', () async {
      final directory = await Directory.systemTemp.createTemp(
        'n42_archive_rollback_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final archive = File('${directory.path}/archive.db');
      final missingEncrypted = File('${directory.path}/missing.enc');
      await archive.writeAsString('plaintext history');

      expect(
        () => replacePlaintextArchiveForTest(archive, missingEncrypted),
        throwsA(isA<FileSystemException>()),
      );
      expect(await archive.readAsString(), 'plaintext history');
      expect(File('${archive.path}.plaintext.bak').existsSync(), isFalse);
    });
  });
}
