import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/chat_backup_service.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/local/secure_storage_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/chat_backup_v3_interop.dart';

class _Manager extends Mock implements MatrixClientManager {}

class _Client extends Mock implements matrix.Client {}

class _Secure extends Mock implements SecureStorageDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late _Manager manager;
  late _Secure secure;
  late PreferencesDataSource preferences;
  late ChatBackupService service;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('n42-backup-files-');
    manager = _Manager();
    secure = _Secure();
    final stored = <String, String?>{};
    when(
      () => secure.read(any()),
    ).thenAnswer((i) async => stored[i.positionalArguments[0]]);
    when(() => secure.write(any(), any())).thenAnswer((i) async {
      stored[i.positionalArguments[0] as String] =
          i.positionalArguments[1] as String?;
    });
    final client = _Client();
    when(() => manager.client).thenReturn(client);
    when(() => client.rooms).thenReturn([]);
    preferences = PreferencesDataSource();
    service = ChatBackupService(
      clientManager: manager,
      secureStorage: secure,
      preferencesStorage: preferences,
      backupDirProvider: () async => directory,
    );
  });
  tearDown(() async => directory.delete(recursive: true));

  for (final incremental in [false, true]) {
    test(
      '${incremental ? 'incremental' : 'full'} consecutive backups preserve both files',
      () async {
        Future<BackupResult> create() => incremental
            ? service.createIncrementalBackup()
            : service.createBackup();
        final first = await create();
        final originalBytes = await File(first.filePath).readAsBytes();
        final second = await create();
        expect(second.backupId, isNot(first.backupId));
        expect(second.filePath, isNot(first.filePath));
        expect(await File(first.filePath).readAsBytes(), originalBytes);
        expect((await service.listBackups()).map((b) => b.backupId).toSet(), {
          first.backupId,
          second.backupId,
        });
      },
    );
  }
  test(
    'full backup progress finishes only after a verifiable file exists',
    () async {
      final progress = <double>[];
      final result = await service.createBackup(onProgress: progress.add);
      expect(progress, [0.1, 0.85, 1.0]);
      expect(result.messageCount, 0);
      expect(result.roomCount, 0);
      expect(result.fileSizeBytes, await File(result.filePath).length());
      expect(await service.verifyBackup(result.filePath), isTrue);
      expect(
        (await service.previewBackup(result.filePath)).backupId,
        result.backupId,
      );
      verifyNever(() => secure.read(any()));
    },
  );
  test(
    'missing client rejects creation and does not leave a backup file',
    () async {
      when(() => manager.client).thenReturn(null);
      await expectLater(service.createBackup(), throwsStateError);
      await expectLater(service.createIncrementalBackup(), throwsStateError);
      expect(await directory.list().toList(), isEmpty);
      final estimate = await service.estimateBackupSize(includeMedia: true);
      expect(estimate.estimatedBytes, 0);
      expect(estimate.roomCount, 0);
    },
  );
  test(
    'empty backup estimate includes settings and increases for media',
    () async {
      final plain = await service.estimateBackupSize();
      final media = await service.estimateBackupSize(includeMedia: true);
      expect(plain.estimatedBytes, greaterThan(0));
      expect(media.estimatedBytes, greaterThanOrEqualTo(plain.estimatedBytes));
      expect(media.includesMedia, isTrue);
    },
  );
  test(
    'AES-GCM round trip protects content and restores supported settings',
    () async {
      await preferences.write(
        'n42_chat_settings',
        '{"fixture":"confidential-value"}',
      );
      final result = await service.createBackup(password: 'fixture-password');
      final raw = await File(result.filePath).readAsBytes();
      expect(utf8.decode(raw.take(8).toList()), 'N42ENC3:');
      expect(
        utf8.decode(raw, allowMalformed: true),
        isNot(contains('confidential-value')),
      );
      expect(
        (await service.previewBackup(
          result.filePath,
          password: 'fixture-password',
        )).backupId,
        result.backupId,
      );
      expect(
        await service.verifyBackup(
          result.filePath,
          password: 'fixture-password',
        ),
        isTrue,
      );
      await preferences.write('n42_chat_settings', '{}');
      final restored = await service.restoreFromBackup(
        backupFilePath: result.filePath,
        password: 'fixture-password',
      );
      expect(restored.errors, isEmpty);
      expect(restored.settingsRestored, 1);
      expect(
        await preferences.read('n42_chat_settings'),
        contains('confidential-value'),
      );
    },
  );
  test(
    'wrong password fails verification and leaves settings untouched',
    () async {
      await preferences.write('n42_chat_settings', '{"fixture":"original"}');
      final result = await service.createBackup(password: 'right-password');
      await preferences.write('n42_chat_settings', '{"fixture":"current"}');
      expect(
        await service.verifyBackup(result.filePath, password: 'wrong-password'),
        isFalse,
      );
      final restored = await service.restoreFromBackup(
        backupFilePath: result.filePath,
        password: 'wrong-password',
      );
      expect(restored.errors, isNotEmpty);
      expect(restored.settingsRestored, 0);
      expect(await preferences.read('n42_chat_settings'), contains('current'));
    },
  );
  test(
    'protected backup requires a password for both preview and restore',
    () async {
      final result = await service.createBackup(password: 'fixture-password');
      await expectLater(
        service.previewBackup(result.filePath),
        throwsStateError,
      );
      expect(await service.verifyBackup(result.filePath), isFalse);
      expect(
        (await service.restoreFromBackup(
          backupFilePath: result.filePath,
        )).errors,
        isNotEmpty,
      );
    },
  );
  test('ciphertext tampering is rejected before restore writes', () async {
    final result = await service.createBackup(password: 'fixture-password');
    final file = File(result.filePath);
    final raw = await file.readAsBytes();
    raw[raw.length - 1] ^= 1;
    await file.writeAsBytes(raw);
    expect(
      await service.verifyBackup(result.filePath, password: 'fixture-password'),
      isFalse,
    );
    expect(
      (await service.restoreFromBackup(
        backupFilePath: result.filePath,
        password: 'fixture-password',
      )).settingsRestored,
      0,
    );
  });
  test('incremental password protection remains verifiable', () async {
    final result = await service.createIncrementalBackup(
      password: 'fixture-password',
    );
    expect(
      await service.verifyBackup(result.filePath, password: 'fixture-password'),
      isTrue,
    );
    expect(
      (await service.previewBackup(
        result.filePath,
        password: 'fixture-password',
      )).hasSettings,
      isFalse,
    );
    final next = await service.createIncrementalBackup();
    final manifest = jsonDecode(
      await File(next.filePath).readAsString(),
    )['manifest'];
    expect(
      manifest['lastBackupTimestamp'],
      result.createdAt.millisecondsSinceEpoch,
    );
  });
  test(
    'restoring without settings does not change current preferences',
    () async {
      await preferences.write('n42_chat_settings', '{"fixture":"old"}');
      final result = await service.createBackup();
      await preferences.write('n42_chat_settings', '{"fixture":"current"}');
      final progress = <double>[];
      final restored = await service.restoreFromBackup(
        backupFilePath: result.filePath,
        restoreSettings: false,
        restoreKeys: true,
        onProgress: progress.add,
      );
      expect(restored.settingsRestored, 0);
      expect(restored.keysRestored, isFalse);
      expect(restored.warnings, isNotEmpty);
      expect(await preferences.read('n42_chat_settings'), contains('current'));
      expect(progress, [0.1, 0.5, 1.0]);
      verifyNever(() => secure.write(any(), any()));
    },
  );
  test('empty password uses the ordinary readable backup format', () async {
    final result = await service.createBackup(password: '');
    expect(
      jsonDecode(await File(result.filePath).readAsString()),
      isA<Map<String, dynamic>>(),
    );
    expect(await service.verifyBackup(result.filePath), isTrue);
  });
  test('list ignores unrelated files and directories', () async {
    await File('${directory.path}/notes.txt').writeAsString('ignore');
    await Directory('${directory.path}/folder.n42backup').create();
    expect(await service.listBackups(), isEmpty);
    final result = await service.createBackup(includeMedia: true);
    final listed = (await service.listBackups()).single;
    expect(listed.backupId, result.backupId);
    expect(listed.includesMedia, isTrue);
    expect(listed.includesKeys, isFalse);
    expect(listed.fileSizeBytes, result.fileSizeBytes);
  });
  test('encrypted file can be listed and deleted without decrypting', () async {
    final result = await service.createBackup(password: 'fixture-password');
    final listed = (await service.listBackups()).single;
    expect(listed.filePath, result.filePath);
    await service.deleteBackup(listed.backupId);
    expect(await File(result.filePath).exists(), isFalse);
  });
  test('deleting an unknown backup preserves an existing one', () async {
    final result = await service.createBackup();
    await service.deleteBackup('not-present');
    expect(await File(result.filePath).exists(), isTrue);
    await service.deleteBackup(result.backupId);
    expect(await service.listBackups(), isEmpty);
  });
  for (final content in ['not json', '[]', 'N42ENC3:', 'N42ENC2:', 'N42ENC:']) {
    test('malformed backup $content cannot restore settings', () async {
      final file = File('${directory.path}/bad.n42backup');
      await file.writeAsString(content);
      expect(
        await service.verifyBackup(file.path, password: 'fixture-password'),
        isFalse,
      );
      expect(
        (await service.restoreFromBackup(
          backupFilePath: file.path,
          password: 'fixture-password',
        )).errors,
        isNotEmpty,
      );
    });
  }
  test('missing archive service returns an explicit restore failure', () async {
    final result = await service.createBackup();
    final restored = await service.restoreToArchive(
      backupFilePath: result.filePath,
    );
    expect(restored.errors, contains('Archive service not available'));
  });

  for (final format in ['v3', 'legacyRoundedV3']) {
    test(
      'independent Python AES-GCM $format fixture restores correctly',
      () async {
        const fixture = chatBackupV3Interop;
        final file = File('${directory.path}/interop.n42backup');
        await file.writeAsBytes(base64Decode(fixture[format]!));
        final password = fixture['fixturePassword']!;
        final preview = await service.previewBackup(
          file.path,
          password: password,
        );
        expect(preview.backupId, fixture['backupId']);
        final restored = await service.restoreFromBackup(
          backupFilePath: file.path,
          password: password,
        );
        expect(restored.errors, isEmpty);
        expect(
          jsonDecode((await preferences.read('n42_chat_settings'))!)['theme'],
          'fixture-dark',
        );
      },
    );
  }

  for (final length in [1, 15, 16, 17, 31]) {
    test(
      'encrypted payload length $length survives block boundaries',
      () async {
        final value = List.filled(length, 'x').join();
        await preferences.write(
          'n42_chat_settings',
          jsonEncode({'value': value}),
        );
        final result = await service.createBackup(
          password: 'boundary-password',
        );
        await preferences.write('n42_chat_settings', '{}');
        final restored = await service.restoreFromBackup(
          backupFilePath: result.filePath,
          password: 'boundary-password',
        );
        expect(restored.errors, isEmpty);
        expect(
          jsonDecode((await preferences.read('n42_chat_settings'))!)['value'],
          value,
        );
      },
    );
  }
  test(
    'legacy rounded v3 output is recoverable only with a valid authentication tag',
    () async {
      BackupResult? result;
      List<int>? wire;
      var padding = 0;
      for (var length = 1; length <= 16 && padding == 0; length++) {
        await preferences.write(
          'n42_chat_settings',
          jsonEncode({'value': List.filled(length, 'x').join()}),
        );
        result = await service.createBackup(password: 'legacy-password');
        wire = await File(result.filePath).readAsBytes();
        padding = (16 - (wire.length - 52) % 16) % 16;
      }
      expect(padding, greaterThan(0));
      // Recreate the old writer's rounded ciphertext+tag buffer and split its
      // last 16 bytes as the tag, exactly as that on-disk v3 layout did.
      final rounded = [
        ...wire!.sublist(68),
        ...wire.sublist(52, 68),
        ...List.filled(padding, 0),
      ];
      final legacy = [
        ...wire.sublist(0, 52),
        ...rounded.sublist(rounded.length - 16),
        ...rounded.sublist(0, rounded.length - 16),
      ];
      final file = File(result!.filePath);
      await file.writeAsBytes(legacy);
      expect(
        (await service.previewBackup(
          file.path,
          password: 'legacy-password',
        )).backupId,
        result.backupId,
      );
      expect(
        await service.verifyBackup(file.path, password: 'wrong-password'),
        isFalse,
      );
      legacy[68] ^= 1;
      await file.writeAsBytes(legacy);
      expect(
        await service.verifyBackup(file.path, password: 'legacy-password'),
        isFalse,
      );
    },
  );

  for (final position in [8, 40, 52, 68]) {
    test(
      'modifying protected byte $position rejects salt nonce tag or ciphertext changes',
      () async {
        final result = await service.createBackup(password: 'tamper-password');
        final file = File(result.filePath);
        final wire = await file.readAsBytes();
        wire[position] ^= 1;
        await file.writeAsBytes(wire);
        expect(
          await service.verifyBackup(file.path, password: 'tamper-password'),
          isFalse,
        );
      },
    );
  }
  test('missing backup file is not reported as verified or restored', () async {
    final path = '${directory.path}/missing.n42backup';
    expect(await service.verifyBackup(path), isFalse);
    expect(
      (await service.restoreFromBackup(backupFilePath: path)).errors,
      isNotEmpty,
    );
  });
}
