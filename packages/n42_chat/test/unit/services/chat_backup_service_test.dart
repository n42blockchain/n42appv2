import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/chat_backup_service.dart';
import 'package:n42_chat/src/core/services/message_archive_service.dart';
import 'package:n42_chat/src/data/datasources/local/archive_database.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/local/secure_storage_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:shared_preferences/shared_preferences.dart';

class MockMatrixClientManager extends Mock implements MatrixClientManager {}

class MockMatrixClient extends Mock implements matrix.Client {}

class MockSecureStorageDataSource extends Mock
    implements SecureStorageDataSource {}

class MockMessageArchiveService extends Mock implements MessageArchiveService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMatrixClientManager clientManager;
  late MockMatrixClient client;
  late MockSecureStorageDataSource secureStorage;
  late MockMessageArchiveService archiveService;
  late PreferencesDataSource preferencesStorage;
  late Directory backupDir;

  setUpAll(() {
    registerFallbackValue(<ArchivedMessagesCompanion>[]);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    clientManager = MockMatrixClientManager();
    client = MockMatrixClient();
    secureStorage = MockSecureStorageDataSource();
    archiveService = MockMessageArchiveService();
    preferencesStorage = PreferencesDataSource();
    backupDir = await Directory.systemTemp.createTemp(
      'chat_backup_service_test',
    );

    when(() => clientManager.client).thenReturn(client);
    when(() => client.rooms).thenReturn(const <matrix.Room>[]);
    when(() => secureStorage.read(any())).thenAnswer((_) async => null);
    when(() => secureStorage.write(any(), any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    if (backupDir.existsSync()) {
      await backupDir.delete(recursive: true);
    }
  });

  ChatBackupService buildService() {
    return ChatBackupService(
      clientManager: clientManager,
      secureStorage: secureStorage,
      preferencesStorage: preferencesStorage,
      archiveService: archiveService,
      backupDirProvider: () async => backupDir,
    );
  }

  group('createBackup', () {
    test(
      'backs up real preference settings and does not claim key export',
      () async {
        final service = buildService();

        await preferencesStorage.saveSetting('n42_chat_language', 'zh');
        await preferencesStorage.saveAppearanceSettings(
          themeMode: 'dark',
          fontSize: 'medium',
          bubbleStyle: 'wechat',
        );
        await preferencesStorage.saveAutoDownloadSettings(<String, dynamic>{
          'wifiOnly': true,
          'images': true,
        });

        final result = await service.createBackup(includeKeys: true);
        final file = File(result.filePath);
        final data =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final manifest = data['manifest'] as Map<String, dynamic>;
        final settings = data['settings'] as Map<String, dynamic>;

        expect(manifest['includesKeys'], isFalse);
        expect(
          result.warnings,
          contains(
            'Encryption keys are backed up separately via Recovery Key in Security settings and are not included in .n42backup files.',
          ),
        );
        expect(
          (settings['n42_chat_settings'] as String?)?.contains(
            'n42_chat_language',
          ),
          isTrue,
        );
        expect(settings['n42_chat_appearance_settings'], isNotNull);
        expect(settings['n42_chat_auto_download_settings'], isNotNull);
      },
    );

    test(
      'verifyBackup rejects tampered backups when checksum no longer matches',
      () async {
        final service = buildService();
        final result = await service.createBackup();
        final file = File(result.filePath);
        final data =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final manifest = data['manifest'] as Map<String, dynamic>;
        manifest['backupId'] = 'tampered-backup-id';
        await file.writeAsString(jsonEncode(data));

        final isValid = await service.verifyBackup(file.path);

        expect(isValid, isFalse);
      },
    );

    test(
      'verifyBackup rejects encrypted backups when password is wrong',
      () async {
        final service = buildService();
        final result = await service.createBackup(password: 'secret-password');

        final isValid = await service.verifyBackup(
          result.filePath,
          password: 'wrong-password',
        );

        expect(isValid, isFalse);
      },
    );
  });

  group('restoreFromBackup', () {
    test(
      'restores nested preference settings and reports keys as unsupported',
      () async {
        final service = buildService();
        final backupFile = File('${backupDir.path}/restore_nested.n42backup');
        await backupFile.writeAsString(
          jsonEncode(<String, dynamic>{
            'manifest': <String, dynamic>{
              'backupId': 'backup-1',
              'createdAt': DateTime(2026, 3, 14).toIso8601String(),
              'includesKeys': true,
            },
            'rooms': <String, dynamic>{},
            'settings': <String, dynamic>{
              'preferences': <String, dynamic>{
                'n42_chat_settings': jsonEncode(<String, dynamic>{
                  'n42_chat_language': 'ja',
                }),
                'n42_chat_auto_download_settings': jsonEncode(<String, dynamic>{
                  'wifiOnly': true,
                }),
              },
            },
          }),
        );

        final result = await service.restoreFromBackup(
          backupFilePath: backupFile.path,
          restoreKeys: true,
        );

        expect(result.settingsRestored, 2);
        expect(result.roomsRestored, 0);
        expect(result.keysRestored, isFalse);
        expect(result.errors, isEmpty);
        expect(result.warnings, isNotEmpty);
        expect(await preferencesStorage.getSetting('n42_chat_language'), 'ja');
        expect(
          (await preferencesStorage.getAutoDownloadSettings())['wifiOnly'],
          isTrue,
        );
      },
    );

    test(
      'migrates legacy flat backup keys to current preference storage',
      () async {
        final service = buildService();
        final backupFile = File('${backupDir.path}/restore_legacy.n42backup');
        await backupFile.writeAsString(
          jsonEncode(<String, dynamic>{
            'manifest': <String, dynamic>{
              'backupId': 'backup-legacy',
              'createdAt': DateTime(2026, 3, 14).toIso8601String(),
            },
            'rooms': <String, dynamic>{},
            'settings': <String, dynamic>{
              'language': 'ko',
              'theme_mode': 'dark',
              'chat_font_size': '18',
            },
          }),
        );

        final result = await service.restoreFromBackup(
          backupFilePath: backupFile.path,
        );

        final appearance = await preferencesStorage.getAppearanceSettings();

        expect(result.settingsRestored, 3);
        expect(await preferencesStorage.getSetting('n42_chat_language'), 'ko');
        expect(appearance?['themeMode'], 'dark');
        expect(
          await preferencesStorage.read('n42_chat_message_font_size'),
          '18',
        );
      },
    );
  });

  group('restoreToArchive', () {
    test('writes archived messages through MessageArchiveService', () async {
      final service = buildService();
      final backupFile = File('${backupDir.path}/restore_archive.n42backup');
      await backupFile.writeAsString(
        jsonEncode(<String, dynamic>{
          'manifest': <String, dynamic>{
            'backupId': 'backup-archive',
            'createdAt': DateTime(2026, 3, 14).toIso8601String(),
          },
          'rooms': <String, dynamic>{
            '!room:server': <String, dynamic>{
              'messages': <Map<String, dynamic>>[
                <String, dynamic>{
                  'eventId': r'$event1',
                  'sender': '@alice:server',
                  'type': 'm.text',
                  'body': 'hello',
                  'timestamp': DateTime(2026, 3, 14, 12).toIso8601String(),
                },
              ],
            },
          },
        }),
      );
      when(
        () => archiveService.isEventArchived(any()),
      ).thenAnswer((_) async => false);
      when(
        () => archiveService.importArchivedMessages(any(), any()),
      ).thenAnswer((_) async => 1);

      final result = await service.restoreToArchive(
        backupFilePath: backupFile.path,
      );

      expect(result.roomsRestored, 1);
      expect(result.errors, isEmpty);
      final captured =
          verify(
                () => archiveService.importArchivedMessages(
                  '!room:server',
                  captureAny(),
                ),
              ).captured.single
              as List<ArchivedMessagesCompanion>;
      expect(captured, hasLength(1));
      expect(captured.first.eventId.value, r'$event1');
      expect(captured.first.type.value, 'm.room.message');
      expect(captured.first.msgtype.value, 'm.text');
    });
  });
}
