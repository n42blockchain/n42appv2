// Extended tests for BackupBloc — covers RestoreFromBackup handler paths
// not in existing tests:
//   RestoreFromBackup (success, hasErrors, failure)

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/chat_backup_service.dart';
import 'package:n42_chat/src/presentation/blocs/backup/backup_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/backup/backup_event.dart';
import 'package:n42_chat/src/presentation/blocs/backup/backup_state.dart';

class MockChatBackupService extends Mock implements ChatBackupService {}

void main() {
  late MockChatBackupService mockService;

  setUp(() {
    mockService = MockChatBackupService();
  });

  setUpAll(() {
    registerFallbackValue(<Map<String, dynamic>>[]);
  });

  BackupBloc buildBloc() => BackupBloc(backupService: mockService);

  // ─────────────────────────────────────────────────
  // RestoreFromBackup — success (no errors)
  // ─────────────────────────────────────────────────

  group('RestoreFromBackup — success', () {
    blocTest<BackupBloc, BackupState>(
      'emits isRestoring→success message when result has no errors',
      build: () {
        when(
          () => mockService.restoreFromBackup(
            backupFilePath: any(named: 'backupFilePath'),
            password: any(named: 'password'),
            roomIds: any(named: 'roomIds'),
            restoreSettings: any(named: 'restoreSettings'),
            restoreKeys: any(named: 'restoreKeys'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async => const RestoreResult(
              roomsRestored: 3,
              settingsRestored: 5,
              keysRestored: false,
            ));
        return buildBloc();
      },
      seed: () => const BackupState(),
      act: (bloc) => bloc.add(const RestoreFromBackup(
        backupFilePath: '/tmp/backup.n42backup',
      )),
      expect: () => [
        isA<BackupState>()
            .having((s) => s.isRestoring, 'isRestoring', isTrue)
            .having((s) => s.progress, 'progress', 0),
        isA<BackupState>()
            .having((s) => s.isRestoring, 'isRestoring', isFalse)
            .having((s) => s.successMessage, 'successMessage', isNotNull)
            .having((s) => s.error, 'error', isNull),
      ],
    );

    blocTest<BackupBloc, BackupState>(
      'appends warnings to success message without treating restore as failure',
      build: () {
        when(
          () => mockService.restoreFromBackup(
            backupFilePath: any(named: 'backupFilePath'),
            password: any(named: 'password'),
            roomIds: any(named: 'roomIds'),
            restoreSettings: any(named: 'restoreSettings'),
            restoreKeys: any(named: 'restoreKeys'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async => const RestoreResult(
              settingsRestored: 2,
              warnings: [
                'Encryption keys are backed up separately via Recovery Key in Security settings and are not included in .n42backup files.',
              ],
            ));
        return buildBloc();
      },
      seed: () => const BackupState(),
      act: (bloc) => bloc.add(const RestoreFromBackup(
        backupFilePath: '/tmp/backup_with_warning.n42backup',
      )),
      expect: () => [
        isA<BackupState>()
            .having((s) => s.isRestoring, 'isRestoring', isTrue),
        isA<BackupState>()
            .having((s) => s.isRestoring, 'isRestoring', isFalse)
            .having((s) => s.error, 'error', isNull)
            .having((s) => s.successMessage, 'successMessage', contains('Recovery Key')),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // RestoreFromBackup — hasErrors branch
  // ─────────────────────────────────────────────────

  group('RestoreFromBackup — has errors', () {
    blocTest<BackupBloc, BackupState>(
      'emits error message when result.hasErrors is true',
      build: () {
        when(
          () => mockService.restoreFromBackup(
            backupFilePath: any(named: 'backupFilePath'),
            password: any(named: 'password'),
            roomIds: any(named: 'roomIds'),
            restoreSettings: any(named: 'restoreSettings'),
            restoreKeys: any(named: 'restoreKeys'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async => const RestoreResult(
              roomsRestored: 1,
              errors: ['Room !a:s failed', 'Room !b:s failed'],
            ));
        return buildBloc();
      },
      seed: () => const BackupState(),
      act: (bloc) => bloc.add(const RestoreFromBackup(
        backupFilePath: '/tmp/partial.n42backup',
      )),
      expect: () => [
        isA<BackupState>()
            .having((s) => s.isRestoring, 'isRestoring', isTrue),
        isA<BackupState>()
            .having((s) => s.isRestoring, 'isRestoring', isFalse)
            .having((s) => s.error, 'error', contains('errors'))
            .having((s) => s.successMessage, 'successMessage', isNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // RestoreFromBackup — failure (throws)
  // ─────────────────────────────────────────────────

  group('RestoreFromBackup — failure', () {
    blocTest<BackupBloc, BackupState>(
      'emits error when restoreFromBackup throws',
      build: () {
        when(
          () => mockService.restoreFromBackup(
            backupFilePath: any(named: 'backupFilePath'),
            password: any(named: 'password'),
            roomIds: any(named: 'roomIds'),
            restoreSettings: any(named: 'restoreSettings'),
            restoreKeys: any(named: 'restoreKeys'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenThrow(Exception('Decryption failed'));
        return buildBloc();
      },
      seed: () => const BackupState(),
      act: (bloc) => bloc.add(const RestoreFromBackup(
        backupFilePath: '/tmp/corrupt.n42backup',
        password: 'wrong-password',
      )),
      expect: () => [
        isA<BackupState>()
            .having((s) => s.isRestoring, 'isRestoring', isTrue),
        isA<BackupState>()
            .having((s) => s.isRestoring, 'isRestoring', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });
}
