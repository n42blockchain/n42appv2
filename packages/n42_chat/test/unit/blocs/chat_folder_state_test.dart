// Tests for ChatFolderState in chat_folder_state.dart.
// ChatFolderEntity-typed fields (folders) are kept empty in tests,
// so selectedFolder / systemFolders / customFolders return null / [].

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/chat_folder/chat_folder_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('ChatFolderState constructor defaults', () {
    const s = ChatFolderState();

    test('folders defaults to empty list', () {
      expect(s.folders, isEmpty);
    });

    test('selectedFolderId defaults to "all"', () {
      expect(s.selectedFolderId, 'all');
    });

    test('isLoading defaults to false', () {
      expect(s.isLoading, isFalse);
    });

    test('error defaults to null', () {
      expect(s.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // ChatFolderState.initial()
  // ─────────────────────────────────────────────────

  group('ChatFolderState.initial()', () {
    test('isLoading is true', () {
      expect(ChatFolderState.initial().isLoading, isTrue);
    });

    test('selectedFolderId is still "all"', () {
      expect(ChatFolderState.initial().selectedFolderId, 'all');
    });

    test('error is null', () {
      expect(ChatFolderState.initial().error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // selectedFolder getter
  // ─────────────────────────────────────────────────

  group('ChatFolderState.selectedFolder', () {
    test('returns null when folders list is empty', () {
      expect(const ChatFolderState().selectedFolder, isNull);
    });

    test('returns null when selectedFolderId does not match any folder', () {
      const s = ChatFolderState(selectedFolderId: 'nonexistent');
      expect(s.selectedFolder, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // systemFolders / customFolders getters (empty-list case)
  // ─────────────────────────────────────────────────

  group('ChatFolderState.systemFolders', () {
    test('empty when folders list is empty', () {
      expect(const ChatFolderState().systemFolders, isEmpty);
    });
  });

  group('ChatFolderState.customFolders', () {
    test('empty when folders list is empty', () {
      expect(const ChatFolderState().customFolders, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — scalar overrides
  // ─────────────────────────────────────────────────

  group('ChatFolderState.copyWith scalar', () {
    const base = ChatFolderState(
      selectedFolderId: 'work',
      isLoading: true,
      error: 'load failed',
    );

    test('no overrides preserves all scalar fields', () {
      final copy = base.copyWith();
      expect(copy.selectedFolderId, 'work');
      expect(copy.isLoading, isTrue);
      expect(copy.error, 'load failed');
    });

    test('overrides selectedFolderId', () {
      final copy = base.copyWith(selectedFolderId: 'personal');
      expect(copy.selectedFolderId, 'personal');
    });

    test('overrides isLoading', () {
      final copy = base.copyWith(isLoading: false);
      expect(copy.isLoading, isFalse);
    });

    test('overrides error', () {
      final copy = base.copyWith(error: 'new error');
      expect(copy.error, 'new error');
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearError flag
  // ─────────────────────────────────────────────────

  group('ChatFolderState.copyWith clearError', () {
    const withError = ChatFolderState(error: 'folder not found');

    test('clearError=true sets error to null', () {
      final copy = withError.copyWith(clearError: true);
      expect(copy.error, isNull);
    });

    test('clearError=false preserves error', () {
      final copy = withError.copyWith(clearError: false);
      expect(copy.error, 'folder not found');
    });

    test('clearError=true overrides provided error', () {
      final copy = withError.copyWith(clearError: true, error: 'ignored');
      expect(copy.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('ChatFolderState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const ChatFolderState(), equals(const ChatFolderState()));
    });

    test('different isLoading → not equal', () {
      expect(
        const ChatFolderState(isLoading: true),
        isNot(equals(const ChatFolderState())),
      );
    });

    test('different selectedFolderId → not equal', () {
      expect(
        const ChatFolderState(selectedFolderId: 'work'),
        isNot(equals(const ChatFolderState())),
      );
    });

    test('different error → not equal', () {
      expect(
        const ChatFolderState(error: 'err'),
        isNot(equals(const ChatFolderState())),
      );
    });

    test('same fields → equal', () {
      expect(
        const ChatFolderState(selectedFolderId: 'work', isLoading: false),
        equals(const ChatFolderState(selectedFolderId: 'work', isLoading: false)),
      );
    });
  });
}
