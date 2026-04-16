// Tests for BackupState in backup_state.dart.
// BackupInfo / BackupPreview / BackupSizeEstimate are service types;
// they are kept null/empty to avoid native deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/backup/backup_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('BackupState constructor defaults', () {
    const s = BackupState();

    test('backups defaults to empty list', () {
      expect(s.backups, isEmpty);
    });

    test('preview defaults to null', () {
      expect(s.preview, isNull);
    });

    test('sizeEstimate defaults to null', () {
      expect(s.sizeEstimate, isNull);
    });

    test('isLoading defaults to false', () {
      expect(s.isLoading, isFalse);
    });

    test('isCreating defaults to false', () {
      expect(s.isCreating, isFalse);
    });

    test('isRestoring defaults to false', () {
      expect(s.isRestoring, isFalse);
    });

    test('progress defaults to 0', () {
      expect(s.progress, 0.0);
    });

    test('error defaults to null', () {
      expect(s.error, isNull);
    });

    test('successMessage defaults to null', () {
      expect(s.successMessage, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // BackupState.initial()
  // ─────────────────────────────────────────────────

  group('BackupState.initial()', () {
    test('isLoading is true', () {
      expect(BackupState.initial().isLoading, isTrue);
    });

    test('isCreating remains false', () {
      expect(BackupState.initial().isCreating, isFalse);
    });

    test('error is null', () {
      expect(BackupState.initial().error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — scalar overrides
  // ─────────────────────────────────────────────────

  group('BackupState.copyWith scalar', () {
    const base = BackupState(
      isLoading: true,
      isCreating: false,
      isRestoring: false,
      progress: 0.3,
      error: 'old error',
      successMessage: 'done',
    );

    test('no overrides preserves all scalar fields', () {
      final copy = base.copyWith();
      expect(copy.isLoading, isTrue);
      expect(copy.isCreating, isFalse);
      expect(copy.progress, closeTo(0.3, 1e-10));
      expect(copy.error, 'old error');
      expect(copy.successMessage, 'done');
    });

    test('overrides isLoading', () {
      final copy = base.copyWith(isLoading: false);
      expect(copy.isLoading, isFalse);
    });

    test('overrides isCreating', () {
      final copy = base.copyWith(isCreating: true);
      expect(copy.isCreating, isTrue);
    });

    test('overrides isRestoring', () {
      final copy = base.copyWith(isRestoring: true);
      expect(copy.isRestoring, isTrue);
    });

    test('overrides progress', () {
      final copy = base.copyWith(progress: 0.75);
      expect(copy.progress, closeTo(0.75, 1e-10));
    });

    test('overrides error', () {
      final copy = base.copyWith(error: 'new error');
      expect(copy.error, 'new error');
    });

    test('overrides successMessage', () {
      final copy = base.copyWith(successMessage: 'backup created');
      expect(copy.successMessage, 'backup created');
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearError flag
  // ─────────────────────────────────────────────────

  group('BackupState.copyWith clearError', () {
    const withError = BackupState(error: 'backup failed');

    test('clearError=true sets error to null', () {
      final copy = withError.copyWith(clearError: true);
      expect(copy.error, isNull);
    });

    test('clearError=false preserves error when no new value given', () {
      final copy = withError.copyWith(clearError: false);
      expect(copy.error, 'backup failed');
    });

    test('clearError=true overrides an explicit error value', () {
      final copy = withError.copyWith(clearError: true, error: 'ignored');
      expect(copy.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearSuccess flag
  // ─────────────────────────────────────────────────

  group('BackupState.copyWith clearSuccess', () {
    const withSuccess = BackupState(successMessage: 'backup done');

    test('clearSuccess=true sets successMessage to null', () {
      final copy = withSuccess.copyWith(clearSuccess: true);
      expect(copy.successMessage, isNull);
    });

    test('clearSuccess=false preserves successMessage', () {
      final copy = withSuccess.copyWith(clearSuccess: false);
      expect(copy.successMessage, 'backup done');
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearPreview flag
  // ─────────────────────────────────────────────────

  group('BackupState.copyWith clearPreview', () {
    test('clearPreview=true sets preview to null (starts null)', () {
      const s = BackupState();
      final copy = s.copyWith(clearPreview: true);
      expect(copy.preview, isNull);
    });

    test('clearPreview=false preserves null preview', () {
      const s = BackupState();
      final copy = s.copyWith(clearPreview: false);
      expect(copy.preview, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('BackupState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const BackupState(), equals(const BackupState()));
    });

    test('different isLoading → not equal', () {
      expect(
        const BackupState(isLoading: true),
        isNot(equals(const BackupState())),
      );
    });

    test('different progress → not equal', () {
      expect(
        const BackupState(progress: 0.5),
        isNot(equals(const BackupState())),
      );
    });

    test('different error → not equal', () {
      expect(
        const BackupState(error: 'err'),
        isNot(equals(const BackupState())),
      );
    });

    test('same fields → equal', () {
      expect(
        const BackupState(isCreating: true, progress: 0.5),
        equals(const BackupState(isCreating: true, progress: 0.5)),
      );
    });
  });
}
