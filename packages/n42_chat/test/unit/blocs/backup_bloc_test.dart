import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/chat_backup_service.dart';
import 'package:n42_chat/src/presentation/blocs/backup/backup_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/backup/backup_event.dart';
import 'package:n42_chat/src/presentation/blocs/backup/backup_state.dart';

class MockChatBackupService extends Mock implements ChatBackupService {}

BackupInfo _makeBackupInfo({String id = 'b-1'}) => BackupInfo(
      backupId: id,
      filePath: '/tmp/$id.n42backup',
      fileSizeBytes: 1024,
      createdAt: DateTime(2025, 6, 1),
      roomCount: 2,
      includesMedia: false,
      includesKeys: false,
    );

BackupResult _makeBackupResult({String id = 'b-new'}) => BackupResult(
      backupId: id,
      filePath: '/tmp/$id.n42backup',
      fileSizeBytes: 2048,
      roomCount: 3,
      messageCount: 100,
      createdAt: DateTime(2025, 6, 1),
    );

void main() {
  late MockChatBackupService mockService;

  setUp(() {
    mockService = MockChatBackupService();
  });

  BackupBloc buildBloc() => BackupBloc(backupService: mockService);

  group('initial state', () {
    test('BackupState.initial() has isLoading=true', () {
      final bloc = buildBloc();
      expect(bloc.state.isLoading, isTrue);
      expect(bloc.state.backups, isEmpty);
      expect(bloc.state.isCreating, isFalse);
      expect(bloc.state.isRestoring, isFalse);
      expect(bloc.state.error, isNull);
    });
  });

  group('LoadBackupList', () {
    blocTest<BackupBloc, BackupState>(
      'emits [loading, loaded] on success',
      build: buildBloc,
      // seed from non-loading state so we get both transitions
      seed: () => const BackupState(),
      setUp: () {
        when(() => mockService.listBackups())
            .thenAnswer((_) async => [_makeBackupInfo()]);
      },
      act: (bloc) => bloc.add(const LoadBackupList()),
      expect: () => [
        isA<BackupState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<BackupState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.backups.length, 'backups.length', 1),
      ],
    );

    blocTest<BackupBloc, BackupState>(
      'emits [loading, error] on failure',
      build: buildBloc,
      seed: () => const BackupState(),
      setUp: () {
        when(() => mockService.listBackups())
            .thenThrow(Exception('Disk read error'));
      },
      act: (bloc) => bloc.add(const LoadBackupList()),
      expect: () => [
        isA<BackupState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<BackupState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  group('CreateBackup', () {
    blocTest<BackupBloc, BackupState>(
      'emits creating → success then triggers LoadBackupList',
      build: buildBloc,
      seed: () => const BackupState(),
      setUp: () {
        when(
          () => mockService.createBackup(
            roomIds: any(named: 'roomIds'),
            includeMedia: any(named: 'includeMedia'),
            includeKeys: any(named: 'includeKeys'),
            password: any(named: 'password'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async => _makeBackupResult());
        when(() => mockService.listBackups())
            .thenAnswer((_) async => [_makeBackupInfo(id: 'b-new')]);
      },
      act: (bloc) => bloc.add(const CreateBackup()),
      expect: () => [
        isA<BackupState>().having((s) => s.isCreating, 'isCreating', isTrue),
        isA<BackupState>()
            .having((s) => s.isCreating, 'isCreating', isFalse)
            .having((s) => s.successMessage, 'successMessage', isNotNull),
        // LoadBackupList triggered: loading
        isA<BackupState>().having((s) => s.isLoading, 'isLoading', isTrue),
        // LoadBackupList complete: loaded
        isA<BackupState>().having((s) => s.isLoading, 'isLoading', isFalse),
      ],
    );

    blocTest<BackupBloc, BackupState>(
      'emits creating → error when createBackup throws',
      build: buildBloc,
      seed: () => const BackupState(),
      setUp: () {
        when(
          () => mockService.createBackup(
            roomIds: any(named: 'roomIds'),
            includeMedia: any(named: 'includeMedia'),
            includeKeys: any(named: 'includeKeys'),
            password: any(named: 'password'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenThrow(Exception('IO error'));
      },
      act: (bloc) => bloc.add(const CreateBackup()),
      expect: () => [
        isA<BackupState>().having((s) => s.isCreating, 'isCreating', isTrue),
        isA<BackupState>()
            .having((s) => s.isCreating, 'isCreating', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  group('DeleteBackup', () {
    blocTest<BackupBloc, BackupState>(
      'calls deleteBackup then triggers LoadBackupList',
      build: buildBloc,
      seed: () => const BackupState(),
      setUp: () {
        when(() => mockService.deleteBackup(any())).thenAnswer((_) async {});
        when(() => mockService.listBackups()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const DeleteBackup('b-1')),
      verify: (_) {
        verify(() => mockService.deleteBackup('b-1')).called(1);
      },
    );

    blocTest<BackupBloc, BackupState>(
      'emits error when deleteBackup throws',
      build: buildBloc,
      seed: () => const BackupState(),
      setUp: () {
        when(() => mockService.deleteBackup(any()))
            .thenThrow(Exception('Permission denied'));
      },
      act: (bloc) => bloc.add(const DeleteBackup('b-1')),
      expect: () => [
        isA<BackupState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  group('PreviewBackup', () {
    blocTest<BackupBloc, BackupState>(
      'emits [loading, preview loaded] on success',
      build: buildBloc,
      seed: () => const BackupState(),
      setUp: () {
        when(
          () => mockService.previewBackup(
            any(),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => BackupPreview(
              backupId: 'b-1',
              createdAt: DateTime(2025, 6, 1),
              roomCount: 2,
              roomNames: const ['General'],
              hasMedia: false,
              hasKeys: false,
              hasSettings: true,
            ));
      },
      act: (bloc) => bloc.add(const PreviewBackup(filePath: '/tmp/b-1.n42backup')),
      expect: () => [
        isA<BackupState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<BackupState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.preview, 'preview', isNotNull),
      ],
    );

    blocTest<BackupBloc, BackupState>(
      'emits error when previewBackup throws',
      build: buildBloc,
      seed: () => const BackupState(),
      setUp: () {
        when(
          () => mockService.previewBackup(
            any(),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('Invalid backup file'));
      },
      act: (bloc) => bloc.add(const PreviewBackup(filePath: '/tmp/bad.n42backup')),
      expect: () => [
        isA<BackupState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<BackupState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  group('EstimateBackupSize', () {
    blocTest<BackupBloc, BackupState>(
      'emits state with sizeEstimate on success',
      build: buildBloc,
      seed: () => const BackupState(),
      setUp: () {
        when(
          () => mockService.estimateBackupSize(
            roomIds: any(named: 'roomIds'),
            includeMedia: any(named: 'includeMedia'),
          ),
        ).thenAnswer((_) async => const BackupSizeEstimate(
              estimatedBytes: 1048576,
              roomCount: 5,
              includesMedia: false,
            ));
      },
      act: (bloc) => bloc.add(const EstimateBackupSize()),
      expect: () => [
        isA<BackupState>().having(
          (s) => s.sizeEstimate?.estimatedBytes,
          'sizeEstimate.estimatedBytes',
          1048576,
        ),
      ],
    );

    blocTest<BackupBloc, BackupState>(
      'silently ignores errors (no emit)',
      build: buildBloc,
      seed: () => const BackupState(),
      setUp: () {
        when(
          () => mockService.estimateBackupSize(
            roomIds: any(named: 'roomIds'),
            includeMedia: any(named: 'includeMedia'),
          ),
        ).thenThrow(Exception('Estimate failed'));
      },
      act: (bloc) => bloc.add(const EstimateBackupSize()),
      // Error is caught and logged; no state change
      expect: () => [],
    );
  });
}
